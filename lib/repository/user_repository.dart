// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/services/valorant_api.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  final _db = FirebaseFirestore.instance;
  final RiotApiService riotApiService = RiotApiService();

  /// **🔥 Report a Player (Only If They Exist)**
  Future<void> reportPlayer({
    required String username,
    required String tagline,
    required bool isToxicityReport,
  }) async {
    try {
      final query = await _db
          .collection("Users")
          .where('user_id', isEqualTo: username)
          .where('tag_line', isEqualTo: tagline)
          .get();

      String newReportTime = DateTime.now().toIso8601String();

      if (query.docs.isNotEmpty) {
        // ✅ Player exists → Update report count
        final doc = query.docs.first.reference;
        await doc.update({
          if (isToxicityReport) 'toxicity_reported': FieldValue.increment(1),
          if (!isToxicityReport) 'cheater_reported': FieldValue.increment(1),
          if (isToxicityReport)
            'last_toxicity_reported': FieldValue.arrayUnion([newReportTime]),
          if (!isToxicityReport)
            'last_cheater_reported': FieldValue.arrayUnion([newReportTime]),
        });

        return;
      }

      // ❌ Player does NOT exist in Firestore → Check if they exist in the Ranked Leaderboard
      List<LeaderboardModel> rankedLeaderboard =
          await riotApiService.getLeaderboard();
      LeaderboardModel? rankedUser = rankedLeaderboard.firstWhereOrNull(
        (user) =>
            user.username.toLowerCase() == username.toLowerCase() &&
            user.tagline.toLowerCase() == tagline.toLowerCase(),
      );

      if (rankedUser == null) {
        throw Exception(
            "Player $username#$tagline not found in Ranked Leaderboard.");
      }

      // ✅ Add Player to Firestore with Initial Report
      await _db.collection("Users").add({
        'user_id': username,
        'tag_line': tagline,
        'cheater_reported': isToxicityReport ? 0 : 1,
        'toxicity_reported': isToxicityReport ? 1 : 0,
        'last_cheater_reported': isToxicityReport ? [] : [newReportTime],
        'last_toxicity_reported': isToxicityReport ? [newReportTime] : [],
        'page_views': 0,
      });

      print("DEBUG: Added $username#$tagline to Firestore.");
    } catch (error) {
      throw Exception("Failed to report player: $error");
    }
  }

  /// **🔥 Get Leaderboard from Firestore**
  Future<List<LeaderboardModel>> firestoreGetLeaderboard() async {
    try {
      // 1️⃣ Fetch Riot's Leaderboard
      List<LeaderboardModel> riotLeaderboard =
          await riotApiService.getLeaderboard();

      // 2️⃣ Fetch Firestore Users
      final snapshot = await _db.collection("Users").get();
      Map<String, Map<String, dynamic>> firestoreUsers =
          {}; // Store users as {username -> data}

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String username = data['user_id'] ?? '';
        String tagline = data['tag_line'] ?? '';

        // 🔥 Store Firestore user data for quick lookup
        firestoreUsers["$username#$tagline"] = data;
      }

      // 3️⃣ Merge Riot leaderboard with Firestore Data
      List<LeaderboardModel> mergedLeaderboard = riotLeaderboard.map((player) {
        String fullUsername = "${player.username}#${player.tagline}";

        if (firestoreUsers.containsKey(fullUsername)) {
          final firestoreData = firestoreUsers[fullUsername]!;

          // 🔥 If user exists in Firestore, use Firestore data for reports
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
          // 🔥 If user does NOT exist in Firestore, default reports to 0
          return LeaderboardModel(
            leaderboardNumber: player.leaderboardNumber,
            username: player.username,
            tagline: player.tagline,
            cheaterReports: 0,
            toxicityReports: 0,
            pageViews: 0,
            lastCheaterReported: [],
            lastToxicityReported: [],
          );
        }
      }).toList();

      return mergedLeaderboard;
    } catch (error) {
      print("ERROR: Fetching merged leaderboard failed: $error");
      return [];
    }
  }

  Future<List<LeaderboardModel>> firestoreGetDodgeList() async {
    try {
      final snapshot = await _db.collection("DodgeList").get();

      if (snapshot.docs.isEmpty) {
        print("DEBUG: Dodge list is empty.");
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        print(
            "DEBUG: Dodge List Data -> ${data['user_id']} | Tag: ${data['tag_line']}");

        return LeaderboardModel(
          leaderboardNumber: -1, // Dodge List has no rank
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
      print("ERROR: Fetching dodge list failed: $error");
      return [];
    }
  }

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
      print(
          "DEBUG: User added to Dodge List -> ${user.username}#${user.tagline}");
    } catch (error) {
      print("ERROR: Adding user to Dodge List failed: $error");
    }
  }

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
        print("DEBUG: Page views incremented for $username#$tagline");
      } else {
        print("DEBUG: User not found for incrementing page views.");
      }
    } catch (error) {
      print("ERROR: Failed to increment page views: $error");
    }
  }
}
