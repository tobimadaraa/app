// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/services/valorant_api.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  final _db = FirebaseFirestore.instance;
  final RiotApiService riotApiService = RiotApiService(); // ✅ Use Riot API

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
        // ✅ Player exists in Firestore → Update their report count
        final doc = query.docs.first.reference;
        if (isToxicityReport) {
          await doc.update({
            'toxicity_reported': FieldValue.increment(1),
            'last_toxicity_reported': FieldValue.arrayUnion([newReportTime]),
          });
        } else {
          await doc.update({
            'cheater_reported': FieldValue.increment(1),
            'last_cheater_reported': FieldValue.arrayUnion([newReportTime]),
          });
        }
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

      // ✅ Add the Player to Firestore and start with 1 report
      await _db.collection("Users").add({
        'user_id': username,
        'tag_line': tagline,
        'cheater_reported': isToxicityReport ? 0 : 1,
        'toxicity_reported': isToxicityReport ? 1 : 0,
        'last_cheater_reported': isToxicityReport ? [] : [newReportTime],
        'last_toxicity_reported': isToxicityReport ? [newReportTime] : [],
        'page_views': 0,
      });
    } catch (error) {
      throw Exception("Failed to report player: $error");
    }
  }

  /// **🔥 Get Custom Leaderboard from Firestore**
  Future<List<LeaderboardModel>> getLeaderboard() async {
    try {
      final snapshot = await _db.collection("Users").get();
      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardModel(
          leaderboardNumber: 0,
          username: data['user_id'] ?? '',
          tagline: data['tag_line'] ?? '',
          cheaterReports:
              data['cheater_reported'] ?? 0, // ✅ Make sure it's updating
          toxicityReported: data['toxicity_reported'] ?? 0,
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
      print("Error fetching leaderboard: $error");
      return [];
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
        print("Page views incremented for $username#$tagline");
      } else {
        print("User not found for incrementing page views");
      }
    } catch (error) {
      print("Error incrementing page views: $error");
    }
  }
}
