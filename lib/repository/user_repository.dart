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

  Future<List<LeaderboardModel>> loadFullLeaderboard() async {
    try {
      print("DEBUG: Sending request to Riot API...");
      List<LeaderboardModel> riotLeaderboard =
          await riotApiService.getLeaderboard(startIndex: 0, size: 200);
      _fullLeaderboard = riotLeaderboard;
      print(
          "DEBUG: Loaded full leaderboard with ${_fullLeaderboard.length} players.");
      return _fullLeaderboard;
    } catch (error) {
      print("ERROR: Failed to fetch full leaderboard - $error");
      return [];
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
      String gameName, String tagLine) async {
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
                String storedUser = normalize(playerMap["gameName"] ?? "");
                String storedTag = normalize(playerMap["tagLine"] ?? "");
                if (storedUser == normalize(gameName) &&
                    storedTag == normalize(tagLine)) {
                  print(
                      "DEBUG: Found user in stored leaderboard in batch_$batchIndex");

                  // Convert the batch data to a LeaderboardModel
                  int leaderboardRank = 0;
                  if (playerMap["leaderboardRank"] is int) {
                    leaderboardRank = playerMap["leaderboardRank"];
                  }
                  // Or parse if it's stored as a string:
                  // int leaderboardRank = int.tryParse(playerMap["leaderboardRank"]?.toString() ?? "0") ?? 0;

                  return LeaderboardModel(
                      leaderboardRank: leaderboardRank,
                      gameName: playerMap["gameName"] ?? "",
                      tagLine: playerMap["tagLine"] ?? "",
                      cheaterReports: playerMap["cheater_reported"] ?? 0,
                      toxicityReports: playerMap["toxicity_reported"] ?? 0,
                      honourReports: data['times_honoured'] ?? 0,
                      pageViews: playerMap["page_views"] ?? 0,
                      lastCheaterReported:
                          playerMap["last_cheater_reported"] is List
                              ? List<String>.from(
                                  playerMap["last_cheater_reported"])
                              : [],
                      lastToxicityReported:
                          playerMap["last_toxicity_reported"] is List
                              ? List<String>.from(
                                  playerMap["last_toxicity_reported"])
                              : [],
                      lastHonourReported: data['last_time_honoured'] is List
                          ? List<String>.from(data['last_time_honoured'])
                          : []);
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

  Future<bool> reportPlayer({
    required String gameName,
    required String tagLine,
    required bool isToxicityReport,
    required bool isHonourReport, // ✅ New Honour flag added
  }) async {
    print(
        "DEBUG: reportPlayer() called for $gameName#$tagLine at ${DateTime.now().toIso8601String()}");

    try {
      String newReportTime = DateTime.now().toIso8601String();

      // 1️⃣ Check Firestore first to see if the user already exists.
      print("DEBUG: Searching Firestore for player: $gameName#$tagLine");
      final query = await _db
          .collection("Users")
          .where('gameName', isEqualTo: normalize(gameName))
          .where('tagLine', isEqualTo: normalize(tagLine))
          .get();

      print(
          "DEBUG: Firestore query result: Found ${query.docs.length} documents.");

      if (query.docs.isNotEmpty) {
        // ✅ User exists in Firestore → Update their report counts.
        final docRef = query.docs.first.reference;
        print("DEBUG: Updating Firestore document: ${docRef.id}");

        await docRef.update({
          if (isToxicityReport) 'toxicity_reported': FieldValue.increment(1),
          if (!isToxicityReport && !isHonourReport)
            'cheater_reported': FieldValue.increment(1),
          if (isHonourReport)
            'times_honoured':
                FieldValue.increment(1), // ✅ Increment Honour Reports
          if (isToxicityReport)
            'last_toxicity_reported': FieldValue.arrayUnion([newReportTime]),
          if (!isToxicityReport && !isHonourReport)
            'last_cheater_reported': FieldValue.arrayUnion([newReportTime]),
          if (isHonourReport)
            'last_time_honoured':
                FieldValue.arrayUnion([newReportTime]), // ✅ Honour timestamps
        });

        print("DEBUG: Successfully updated player reports in Firestore.");
        return true;
      }

      // 2️⃣ If not found in Firestore, check the stored leaderboard in Firebase.
      print(
          "DEBUG: Player not found in Firestore. Checking stored leaderboard in Firebase...");
      final LeaderboardModel? storedPlayerModel =
          await checkFirebaseStoredLeaderboard(gameName, tagLine);

      if (storedPlayerModel == null) {
        print("ERROR: User not found in Riot API or stored leaderboard.");
        return false;
      }

      // 3️⃣ If found, add the new player to Firestore.
      print(
          "DEBUG: User verified from stored leaderboard. Adding new player to Firestore...");

      await _db.collection("Users").add({
        'leaderboardRank': storedPlayerModel.leaderboardRank,
        'gameName': normalize(gameName),
        'tagLine': normalize(tagLine),
        'searchKey':
            ('${normalize(gameName)}#${normalize(tagLine)}').toLowerCase(),
        'times_honoured': isHonourReport ? 1 : storedPlayerModel.honourReports,
        'cheater_reported': isHonourReport
            ? 0
            : isToxicityReport
                ? 0
                : 1,
        'toxicity_reported': isHonourReport
            ? 0
            : isToxicityReport
                ? 1
                : 0,
        'last_cheater_reported': isHonourReport
            ? []
            : isToxicityReport
                ? []
                : [newReportTime],
        'last_toxicity_reported': isHonourReport
            ? []
            : isToxicityReport
                ? [newReportTime]
                : [],
        'last_time_honoured': isHonourReport
            ? [newReportTime]
            : storedPlayerModel.lastHonourReported,
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
      {required LeaderboardType leaderboardType}) async {
    try {
      // Fetch all reported users from the "Users" collection.
      QuerySnapshot snapshot = await _db.collection("Users").get();
      List<LeaderboardModel> reportedUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LeaderboardModel(
            leaderboardRank: data['leaderboardRank'] ?? 0,
            gameName: data['gameName'] ?? "",
            tagLine: data['tagLine'] ?? "",
            cheaterReports: data['cheater_reported'] ?? 0,
            toxicityReports: data['toxicity_reported'] ?? 0,
            honourReports: data['times_honoured'] ?? 0,
            pageViews: data['page_views'] ?? 0,
            lastCheaterReported: data['last_cheater_reported'] is List
                ? List<String>.from(data['last_cheater_reported'])
                : [],
            lastToxicityReported: data['last_toxicity_reported'] is List
                ? List<String>.from(data['last_toxicity_reported'])
                : [],
            lastHonourReported: data['last_time_honoured'] is List
                ? List<String>.from(data['last_time_honoured'])
                : []);
      }).toList();

      // **Filter based on the leaderboard type**
      if (leaderboardType == LeaderboardType.toxicity) {
        reportedUsers =
            reportedUsers.where((user) => user.toxicityReports > 0).toList();
        reportedUsers
            .sort((a, b) => b.toxicityReports.compareTo(a.toxicityReports));
      } else if (leaderboardType == LeaderboardType.cheater) {
        reportedUsers =
            reportedUsers.where((user) => user.cheaterReports > 0).toList();
        reportedUsers
            .sort((a, b) => b.cheaterReports.compareTo(a.cheaterReports));
      } else if (leaderboardType == LeaderboardType.honour) {
        reportedUsers =
            reportedUsers.where((user) => user.honourReports > 0).toList();
        reportedUsers
            .sort((a, b) => b.honourReports.compareTo(a.honourReports));
      }

      return reportedUsers;
    } catch (e) {
      print("❌ Error fetching reported users from Firebase: $e");
      return [];
    }
  }

  Future<List<LeaderboardModel>> searchPlayersInBatches(
      String queryText) async {
    if (queryText.isEmpty) return [];

    final lowercaseQuery = queryText.toLowerCase();
    final List<LeaderboardModel> results = [];
    final Set<String> uniqueKeys = {}; // Track duplicates here

    try {
      // Suppose you have 8 batch documents: batch_0 to batch_7.
      for (int i = 0; i < 8; i++) {
        final docSnapshot =
            await _db.collection("LeaderboardDoc").doc("batch_$i").get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final players = data["players"] as List<dynamic>;

          // Filter locally using searchKey.
          final filteredPlayers = players.where((player) {
            final searchKey = (player["searchKey"] ?? "").toString();
            return searchKey.startsWith(lowercaseQuery);
          }).toList();

          // Convert to LeaderboardModel but only add if not already in uniqueKeys
          for (var playerData in filteredPlayers) {
            final mapData = playerData as Map<String, dynamic>;
            final user = LeaderboardModel.fromJson(mapData);

            // Build a unique key for the user
            final uniqueKey =
                '${user.gameName.toLowerCase()}#${user.tagLine.toLowerCase()}';

            // If we haven't seen this user before, add them
            if (!uniqueKeys.contains(uniqueKey)) {
              uniqueKeys.add(uniqueKey);
              results.add(user);
            }
          }
        }
      }
      return results;
    } catch (error) {
      print("Error searching players in batches: $error");
      return [];
    }
  }

  /// **Get Leaderboard from Firestore**
  Future<List<LeaderboardModel>> firestoreGetLeaderboard() async {
    try {
      // Fetch the leaderboard data from Firestore
      final snapshot = await _db.collection("Users").get();
      List<LeaderboardModel> firestoreLeaderboard = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String gameName = normalize(data['gameName'] ?? '');
        String tagLine = normalize(data['tagLine'] ?? '');

        // Create LeaderboardModel from Firestore data
        firestoreLeaderboard.add(LeaderboardModel(
            leaderboardRank:
                data['rank'] ?? 0, // Assuming 'rank' is in Firestore
            gameName: gameName,
            tagLine: tagLine,
            cheaterReports: data['cheater_reported'] ?? 0,
            toxicityReports: data['toxicity_reported'] ?? 0,
            honourReports: data['times_honoured'] ?? 0,
            pageViews: data['page_views'] ?? 0,
            lastCheaterReported: data['last_cheater_reported'] is List
                ? List<String>.from(data['last_cheater_reported'])
                : [],
            lastToxicityReported: data['last_toxicity_reported'] is List
                ? List<String>.from(data['last_toxicity_reported'])
                : [],
            lastHonourReported: data['last_time_honoured'] is List
                ? List<String>.from(data['last_time_honoured'])
                : []));
      }

      // Return the list of leaderboard data fetched from Firestore
      return firestoreLeaderboard;
    } catch (error) {
      print("ERROR: Fetching Firestore leaderboard failed: $error");
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
            leaderboardRank: -1,
            gameName: data['gameName'] ?? '',
            tagLine: data['tagLine'] ?? '',
            cheaterReports: data['cheater_reported'] ?? 0,
            toxicityReports: data['toxicity_reported'] ?? 0,
            honourReports: data['times_honoured'] ?? 0,
            pageViews: data['page_views'] ?? 0,
            lastCheaterReported: data['last_cheater_reported'] is List
                ? List<String>.from(data['last_cheater_reported'])
                : [],
            lastToxicityReported: data['last_toxicity_reported'] is List
                ? List<String>.from(data['last_toxicity_reported'])
                : [],
            lastHonourReported: data['last_time_honoured'] is List
                ? List<String>.from(data['last_time_honoured'])
                : []);
      }).toList();
    } catch (error) {
      print("ERROR: Fetching Dodge List failed: $error");
      return [];
    }
  }

  /// Add to Dodge List
  // Future<void> addToDodgeList(LeaderboardModel user) async {
  //   try {
  //     await _db
  //         .collection("DodgeList")
  //         .doc("${user.gameName}#${user.tagLine}")
  //         .set({
  //       "gameName": user.gameName,
  //       "tagLine": user.tagLine,
  //       "cheater_reported": user.cheaterReports,
  //       "toxicity_reported": user.toxicityReports,
  //       "page_views": user.pageViews,
  //       "last_cheater_reported": user.lastCheaterReported,
  //       "last_toxicity_reported": user.lastToxicityReported,
  //     });
  //     print(
  //         "DEBUG: User added to Dodge List -> ${user.gameName}#${user.tagLine}");
  //   } catch (error) {
  //     print("ERROR: Adding user to Dodge List failed: $error");
  //   }
  // }

  /// Remove from Dodge List
  Future<void> removeFromDodgeList(LeaderboardModel user) async {
    try {
      await _db
          .collection("DodgeList")
          .doc("${user.gameName}#${user.tagLine}")
          .delete();
      print(
          "DEBUG: User removed from Dodge List -> ${user.gameName}#${user.tagLine}");
    } catch (error) {
      print("ERROR: Removing user from Dodge List failed: $error");
    }
  }

  /// Increment Page Views for a Player
  Future<void> incrementPageViews(String gameName, String tagLine) async {
    try {
      final query = await _db
          .collection("Users")
          .where('gameName', isEqualTo: gameName)
          .where('tagLine', isEqualTo: tagLine)
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({'page_views': FieldValue.increment(1)});
      }
    } catch (error) {
      print("ERROR: Failed to increment page views: $error");
    }
  }

  Future<List<LeaderboardModel>> searchUsers(String queryText) async {
    String lowerQuery = queryText.toLowerCase();
    QuerySnapshot snapshot = await _db
        .collection('Users')
        .where('searchKey', isGreaterThanOrEqualTo: lowerQuery)
        .where('searchKey', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      return LeaderboardModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
