// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/valorant_api.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  final _db = FirebaseFirestore.instance;
  final RiotApiService riotApiService = RiotApiService();
  List<LeaderboardModel> _fullLeaderboard = [];

  Future<void> loadFullLeaderboard() async {
    try {
      print("DEBUG: Sending request to Riot API...");
      List<LeaderboardModel> riotLeaderboard =
          await riotApiService.getLeaderboard(startIndex: 0, size: 200);
      _fullLeaderboard = riotLeaderboard;
      print(
          "DEBUG: Loaded full leaderboard with ${_fullLeaderboard.length} players.");
    } catch (error) {
      print("ERROR: Failed to fetch full leaderboard - $error");
    }
  }

  // Normalize a string by trimming and converting to lowercase.
  String normalize(String input) {
    return input.trim().toLowerCase();
  }

  /// Helper: Check the stored leaderboard in Firebase (only batches 0–7).
  /// This scans through the stored leaderboard docs to see if the user exists.
  /// Returns a LeaderboardModel if found, otherwise null.
  Future<LeaderboardModel?> checkFirebaseStoredLeaderboard(
      String username, String tagline) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference leaderboardRef =
        firestore.collection("LeaderboardDoc");

    for (int batchIndex = 0; batchIndex < 8; batchIndex++) {
      try {
        DocumentSnapshot docSnapshot =
            await leaderboardRef.doc("batch_$batchIndex").get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data is Map<String, dynamic> && data.containsKey("players")) {
            List<dynamic> players = data["players"];
            for (var playerMap in players) {
              if (playerMap is Map<String, dynamic>) {
                String storedUser = normalize(playerMap["username"] ?? "");
                String storedTag = normalize(playerMap["tagline"] ?? "");
                if (storedUser == normalize(username) &&
                    storedTag == normalize(tagline)) {
                  print(
                      "DEBUG: Found user in stored leaderboard in batch_$batchIndex");

                  // Convert the batch data to a LeaderboardModel
                  int rank = 0;
                  if (playerMap["leaderboardNumber"] is int) {
                    rank = playerMap["leaderboardNumber"];
                  }
                  // Or parse if it's stored as a string:
                  // int rank = int.tryParse(playerMap["leaderboardNumber"]?.toString() ?? "0") ?? 0;

                  return LeaderboardModel(
                    leaderboardNumber: rank,
                    username: playerMap["username"] ?? "",
                    tagline: playerMap["tagline"] ?? "",
                    cheaterReports: playerMap["cheater_reported"] ?? 0,
                    toxicityReports: playerMap["toxicity_reported"] ?? 0,
                    pageViews: playerMap["page_views"] ?? 0,
                    lastCheaterReported: playerMap["last_cheater_reported"]
                            is List
                        ? List<String>.from(playerMap["last_cheater_reported"])
                        : [],
                    lastToxicityReported: playerMap["last_toxicity_reported"]
                            is List
                        ? List<String>.from(playerMap["last_toxicity_reported"])
                        : [],
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        print("ERROR: Could not check batch_$batchIndex: $e");
        // Continue checking remaining batches.
      }
    }
    print("DEBUG: User not found in any of batches 0-7.");
    return null;
  }

  /// **Helper: Check Stored Leaderboard in Firebase (Batches 0-7)**
  // Future<bool> checkFirebaseStoredLeaderboard(
  //     String username, String tagline) async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   final CollectionReference leaderboardRef =
  //       firestore.collection("LeaderboardDoc");

  //   // Only check batches 0 through 7
  //   for (int batchIndex = 0; batchIndex < 8; batchIndex++) {
  //     try {
  //       DocumentSnapshot docSnapshot =
  //           await leaderboardRef.doc("batch_$batchIndex").get();
  //       if (docSnapshot.exists) {
  //         final data = docSnapshot.data();
  //         if (data is Map<String, dynamic> && data.containsKey("players")) {
  //           List<dynamic> players = data["players"];
  //           for (var playerMap in players) {
  //             if (playerMap is Map<String, dynamic>) {
  //               String storedUser = normalize(playerMap["username"] ?? "");
  //               String storedTag = normalize(playerMap["tagline"] ?? "");
  //               if (storedUser == normalize(username) &&
  //                   storedTag == normalize(tagline)) {
  //                 print(
  //                     "DEBUG: Found user in stored leaderboard in batch_$batchIndex");
  //                 return true;
  //               }
  //             }
  //           }
  //         }
  //       } else {
  //         print("DEBUG: Document batch_$batchIndex does not exist.");
  //       }
  //     } catch (e) {
  //       print("ERROR: Could not check batch_$batchIndex: $e");
  //       // Continue checking remaining batches even if one fails.
  //     }
  //   }
  //   print("DEBUG: User not found in any of batches 0-7.");
  //   return false;
  // }

  /// **Report a Player (with Verification)**
  /// Report a player for cheater/toxicity.
  /// The logic is:
  /// 1. Check if the user exists in the "Users" collection.
  ///    - If so, update their report counts.
  /// 2. If not, check the stored leaderboard (batches 0-7).
  ///    - If found there, add them to Firestore.
  /// 3. If not found in either, then the user is considered invalid.
  Future<bool> reportPlayer({
    required String username,
    required String tagline,
    required bool isToxicityReport,
  }) async {
    print(
        "DEBUG: reportPlayer() called for $username#$tagline at ${DateTime.now().toIso8601String()}");

    try {
      String newReportTime = DateTime.now().toIso8601String();

      // 1️⃣ Check Firestore first to see if the user already exists.
      print("DEBUG: Searching Firestore for player: $username#$tagline");
      final query = await _db
          .collection("Users")
          .where('username', isEqualTo: normalize(username))
          .where('tagline', isEqualTo: normalize(tagline))
          .get();

      print(
          "DEBUG: Firestore query result: Found ${query.docs.length} documents.");

      if (query.docs.isNotEmpty) {
        // User exists in Firestore → update their report counts.
        final docRef = query.docs.first.reference;
        print("DEBUG: Updating Firestore document: ${docRef.id}");
        await docRef.update({
          if (isToxicityReport) 'toxicity_reported': FieldValue.increment(1),
          if (!isToxicityReport) 'cheater_reported': FieldValue.increment(1),
          if (isToxicityReport)
            'last_toxicity_reported': FieldValue.arrayUnion([newReportTime]),
          if (!isToxicityReport)
            'last_cheater_reported': FieldValue.arrayUnion([newReportTime]),
        });
        print("DEBUG: Successfully updated player reports in Firestore.");
        return true;
      }

      // 2️⃣ If not found in Firestore, check the stored leaderboard in Firebase.
      print(
          "DEBUG: Player not found in Firestore. Checking stored leaderboard in Firebase...");
      final LeaderboardModel? storedPlayerModel =
          await checkFirebaseStoredLeaderboard(username, tagline);
      if (storedPlayerModel == null) {
        print("ERROR: User not found in Riot API or stored leaderboard.");
        return false;
      }

      // 3️⃣ If found, add the new player to Firestore.
      print(
          "DEBUG: User verified from stored leaderboard. Adding new player to Firestore...");
      await _db.collection("Users").add({
        'leaderboardNumber': storedPlayerModel.leaderboardNumber,
        'username': normalize(username),
        'tagline': normalize(tagline),
        // store the rank
        'cheater_reported': isToxicityReport ? 0 : 1,
        'toxicity_reported': isToxicityReport ? 1 : 0,
        'last_cheater_reported': isToxicityReport ? [] : [newReportTime],
        'last_toxicity_reported': isToxicityReport ? [newReportTime] : [],
        'page_views': 0,
      });
      print("DEBUG: Successfully added new player.");
      return true;
    } catch (error) {
      print("ERROR: Failed to report player - $error");
      return false;
    }
  }

  Future<List<LeaderboardModel>> getReportedUsersFromFirebase(
      {required bool forToxicity,
      required LeaderboardType leaderboardType}) async {
    try {
      // Fetch all reported users from the "Users" collection.
      QuerySnapshot snapshot = await _db.collection("Users").get();
      List<LeaderboardModel> reportedUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LeaderboardModel(
          leaderboardNumber: data['leaderboardNumber'] ?? 0,
          username: data['username'] ??
              "", // Ensure you're using consistent field names!
          tagline: data['tagline'] ?? "",
          cheaterReports: data['cheater_reported'] ?? 0,
          toxicityReports: data['toxicity_reported'] ?? 0,
          pageViews: data['page_views'] ?? 0,
          lastCheaterReported: data['last_cheater_reported'] is List
              ? List<String>.from(data['last_cheater_reported'])
              : [],
          lastToxicityReported: data['last_toxicity_reported'] is List
              ? List<String>.from(data['last_toxicity_reported'])
              : [],
        );
      }).toList();

      // Filter based on the leaderboard type.
      if (forToxicity) {
        // Only include users with toxicity reports > 0.
        reportedUsers =
            reportedUsers.where((user) => user.toxicityReports > 0).toList();
        // Optionally sort by toxicityReports descending.
        reportedUsers
            .sort((a, b) => b.toxicityReports.compareTo(a.toxicityReports));
      } else {
        // For cheater leaderboard.
        reportedUsers =
            reportedUsers.where((user) => user.cheaterReports > 0).toList();
        reportedUsers
            .sort((a, b) => b.cheaterReports.compareTo(a.cheaterReports));
      }

      return reportedUsers;
    } catch (e) {
      print("Error fetching reported users from Firebase: $e");
      return [];
    }
  }

  /// **Get Leaderboard from Firestore**
  Future<List<LeaderboardModel>> firestoreGetLeaderboard() async {
    try {
      List<LeaderboardModel> riotLeaderboard =
          await riotApiService.getLeaderboard(startIndex: 0, size: 200);

      final snapshot = await _db.collection("Users").get();
      Map<String, Map<String, dynamic>> firestoreUsers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String username = normalize(data['username'] ?? '');
        String tagline = normalize(data['tagline'] ?? '');
        firestoreUsers["$username#$tagline"] = data;
      }

      List<LeaderboardModel> mergedLeaderboard = riotLeaderboard.map((player) {
        String fullUsername = normalize("${player.username}#${player.tagline}");

        if (firestoreUsers.containsKey(fullUsername)) {
          final firestoreData = firestoreUsers[fullUsername]!;
          return LeaderboardModel(
            leaderboardNumber: player.leaderboardNumber,
            username: player.username,
            tagline: player.tagline,
            cheaterReports: firestoreData['cheater_reported'] ?? 0,
            toxicityReports: firestoreData['toxicity_reported'] ?? 0,
            pageViews: firestoreData['page_views'] ?? 0,
            lastCheaterReported: firestoreData['last_cheater_reported'] is List
                ? List<String>.from(firestoreData['last_cheater_reported'])
                : [],
            lastToxicityReported:
                firestoreData['last_toxicity_reported'] is List
                    ? List<String>.from(firestoreData['last_toxicity_reported'])
                    : [],
          );
        } else {
          return player;
        }
      }).toList();

      Map<String, LeaderboardModel> uniquePlayers = {};
      for (var player in mergedLeaderboard) {
        String key = normalize("${player.username}#${player.tagline}");
        uniquePlayers[key] = player;
      }

      return uniquePlayers.values.toList();
    } catch (error) {
      print("ERROR: Fetching merged leaderboard failed: $error");
      return [];
    }
  }

  /// Get Dodge List from Firestore
  Future<List<LeaderboardModel>> firestoreGetDodgeList() async {
    try {
      final snapshot = await _db.collection("DodgeList").get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardModel(
          leaderboardNumber: -1,
          username: data['username'] ?? '',
          tagline: data['tagline'] ?? '',
          cheaterReports: data['cheater_reported'] ?? 0,
          toxicityReports: data['toxicity_reported'] ?? 0,
          pageViews: data['page_views'] ?? 0,
          lastCheaterReported: data['last_cheater_reported'] is List
              ? List<String>.from(data['last_cheater_reported'])
              : [],
          lastToxicityReported: data['last_toxicity_reported'] is List
              ? List<String>.from(data['last_toxicity_reported'])
              : [],
        );
      }).toList();
    } catch (error) {
      print("ERROR: Fetching Dodge List failed: $error");
      return [];
    }
  }

  /// Add to Dodge List
  Future<void> addToDodgeList(LeaderboardModel user) async {
    try {
      await _db
          .collection("DodgeList")
          .doc("${user.username}#${user.tagline}")
          .set({
        "username": user.username,
        "tagline": user.tagline,
        "cheater_reported": user.cheaterReports,
        "toxicity_reported": user.toxicityReports,
        "page_views": user.pageViews,
        "last_cheater_reported": user.lastCheaterReported,
        "last_toxicity_reported": user.lastToxicityReported,
      });
      print(
          "DEBUG: User added to Dodge List -> ${user.username}#${user.tagline}");
    } catch (error) {
      print("ERROR: Adding user to Dodge List failed: $error");
    }
  }

  /// Remove from Dodge List
  Future<void> removeFromDodgeList(LeaderboardModel user) async {
    try {
      await _db
          .collection("DodgeList")
          .doc("${user.username}#${user.tagline}")
          .delete();
      print(
          "DEBUG: User removed from Dodge List -> ${user.username}#${user.tagline}");
    } catch (error) {
      print("ERROR: Removing user from Dodge List failed: $error");
    }
  }

  /// Increment Page Views for a Player
  Future<void> incrementPageViews(String username, String tagline) async {
    try {
      final query = await _db
          .collection("Users")
          .where('username', isEqualTo: username)
          .where('tagline', isEqualTo: tagline)
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({'page_views': FieldValue.increment(1)});
      }
    } catch (error) {
      print("ERROR: Failed to increment page views: $error");
    }
  }
}
