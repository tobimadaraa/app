// ignore_for_file: avoid_

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/valorant_api.dart';
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

  String normalize(String input) {
    return input.trim().toLowerCase();
  }

  /// **🔥 Report a Player (Only If They Exist)**
  Future<bool> reportPlayer({
    required String username,
    required String tagline,
    required bool isToxicityReport,
  }) async {
    print(
        "DEBUG: reportPlayer() called for $username#$tagline at ${DateTime.now().toIso8601String()}");

    try {
      String newReportTime = DateTime.now().toIso8601String();

      // **1️⃣ Check Firestore First**
      ("DEBUG: Searching Firestore for player: $username#$tagline");
      final query = await _db
          .collection("Users")
          .where('user_id', isEqualTo: username.toLowerCase().trim())
          .where('tag_line', isEqualTo: tagline.toLowerCase().trim())
          .get();

      print(
          "DEBUG: Firestore query result: Found ${query.docs.length} documents.");

      if (query.docs.isNotEmpty) {
        // ✅ Player exists in Firestore → Just update reports
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

      // **2️⃣ Firestore did NOT find the player → Check Riot API**
      print("DEBUG: Player not found in Firestore. Checking Riot API...");

      bool playerExists;
      try {
        playerExists =
            await riotApiService.checkPlayerExists(username, tagline);
        print("DEBUG: Riot API checkPlayerExists() returned: $playerExists");

        if (!playerExists) {
          print("ERROR: Player does NOT exist in Riot API. Cannot report.");
          return false; // 🚨 Prevents adding unknown players
        }
      } catch (error) {
        print("ERROR: Exception in checkPlayerExists(): $error");
        return false; // 🚨 Prevents app crashes
      }

      // **3️⃣ If Riot API also fails, handle it gracefully**
      if (!playerExists) {
        print(
            "ERROR: Player does NOT exist in Riot API. Skipping addition to Firestore.");
        return false; // ✅ Instead of breaking, just log the issue and continue
      }

      // **4️⃣ Riot API confirms player exists → Add them to Firestore**
      print(
          "DEBUG: Player exists in Riot API. Adding new player to Firestore...");
      print(
          "DEBUG: Player exists in Riot API. Adding new player to Firestore...");
      await _db.collection("Users").add({
        'user_id': username.toLowerCase().trim(),
        'tag_line': tagline.toLowerCase().trim(),
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

  /// **🔥 Get Leaderboard from Firestore**
  Future<List<LeaderboardModel>> firestoreGetLeaderboard() async {
    try {
      List<LeaderboardModel> riotLeaderboard =
          await riotApiService.getLeaderboard(startIndex: 0, size: 200);

      final snapshot = await _db.collection("Users").get();
      Map<String, Map<String, dynamic>> firestoreUsers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String username = normalize(data['user_id'] ?? '');
        String tagline = normalize(data['tag_line'] ?? '');
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
      ("ERROR: Fetching merged leaderboard failed: $error");
      return [];
    }
  }

  /// **🔥 Get Dodge List from Firestore**
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
          username: data['user_id'] ?? '',
          tagline: data['tag_line'] ?? '',
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
      ("ERROR: Fetching Dodge List failed: $error");
      return [];
    }
  }

  /// **🔥 Add to Dodge List**
  Future<void> addToDodgeList(LeaderboardModel user) async {
    try {
      await _db
          .collection("DodgeList")
          .doc("${user.username}#${user.tagline}")
          .set({
        "user_id": user.username,
        "tag_line": user.tagline,
        "cheater_reported": user.cheaterReports,
        "toxicity_reported": user.toxicityReports,
        "page_views": user.pageViews,
        "last_cheater_reported": user.lastCheaterReported,
        "last_toxicity_reported": user.lastToxicityReported,
      });
      ("DEBUG: User added to Dodge List -> ${user.username}#${user.tagline}");
    } catch (error) {
      ("ERROR: Adding user to Dodge List failed: $error");
    }
  }

  /// **🔥 Remove from Dodge List**
  Future<void> removeFromDodgeList(LeaderboardModel user) async {
    try {
      await _db
          .collection("DodgeList")
          .doc("${user.username}#${user.tagline}")
          .delete();
      ("DEBUG: User removed from Dodge List -> ${user.username}#${user.tagline}");
    } catch (error) {
      ("ERROR: Removing user from Dodge List failed: $error");
    }
  }

  /// **🔥 Increment Page Views for a Player**
  Future<void> incrementPageViews(String username, String tagline) async {
    try {
      final query = await _db
          .collection("Users")
          .where('user_id', isEqualTo: username)
          .where('tag_line', isEqualTo: tagline)
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({'page_views': FieldValue.increment(1)});
      }
    } catch (error) {
      ("ERROR: Failed to increment page views: $error");
    }
  }
}
