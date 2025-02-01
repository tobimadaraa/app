import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  final _db = FirebaseFirestore.instance;
  Future<void> createUser(
    UserModel user, {
    bool isToxicityReport = false,
  }) async {
    try {
      // Query for matching Riot ID and tagline
      final query =
          await _db
              .collection("Users")
              .where('user_id', isEqualTo: user.userId)
              .where('tag_line', isEqualTo: user.tagline)
              .get();

      String newReportTime = DateTime.now().toIso8601String();

      if (query.docs.isNotEmpty) {
        // Update the existing user's report count
        final doc = query.docs.first.reference;
        if (isToxicityReport) {
          await doc.update({
            'toxicity_reported': FieldValue.increment(1),
            // Update only the toxicity-related last reported times
            'last_toxicity_reported': FieldValue.arrayUnion([newReportTime]),
          });
        } else {
          await doc.update({
            'cheater_reported': FieldValue.increment(1),
            // Update only the cheater-related last reported times
            'last_cheater_reported': FieldValue.arrayUnion([newReportTime]),
          });
        }
      } else {
        // Check if Riot ID exists with a different tagline
        final idQuery =
            await _db
                .collection("Users")
                .where('user_id', isEqualTo: user.userId)
                .get();

        if (idQuery.docs.isNotEmpty) {
          // Riot ID exists with a different tagline, create new user
          await _db.collection("Users").add({
            ...user.toJson(), // Include all fields from user
            'cheater_reported': isToxicityReport ? 0 : 1,
            'toxicity_reported': isToxicityReport ? 1 : 0,
            // Initialize the arrays based on the report type:
            'last_cheater_reported': isToxicityReport ? [] : [newReportTime],
            'last_toxicity_reported': isToxicityReport ? [newReportTime] : [],
            'page_views': 0,
          });
        } else {
          // Completely new user: create both counters with one set to 1 based on the report type.
          await _db.collection("Users").add({
            ...user.toJson(),
            'cheater_reported': isToxicityReport ? 0 : 1,
            'toxicity_reported': isToxicityReport ? 1 : 0,
            'last_cheater_reported': isToxicityReport ? [] : [newReportTime],
            'last_toxicity_reported': isToxicityReport ? [newReportTime] : [],
            'page_views': 0,
          });
        }
      }

      Get.snackbar(
        "Success",
        "User data updated successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to update user data.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print(error.toString());
    }
  }

  Future<void> incrementPageViews(String userId, String tagline) async {
    try {
      // Query for the user document by user_id and tag_line.
      final query =
          await _db
              .collection("Users")
              .where('user_id', isEqualTo: userId)
              .where('tag_line', isEqualTo: tagline)
              .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({'page_views': FieldValue.increment(1)});
        print("Page views incremented for $userId");
      } else {
        print("User not found for incrementing page views");
      }
    } catch (error) {
      print("Error incrementing page views: $error");
    }
  }

  Future<List<LeaderboardModel>> getLeaderboard() async {
    try {
      final snapshot = await _db.collection("Users").get();
      if (snapshot.docs.isEmpty) {
        print("Firestore: No users found.");
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardModel(
          leaderboardNumber: 0, // Calculate rank as needed
          username: data['user_id'] ?? '',
          tagline: data['tag_line'] ?? '',
          cheaterReports: data['cheater_reported'] ?? 0,
          toxicityReported: data['toxicity_reported'] ?? 0,
          pageViews: data['page_views'] ?? 0,
          // Choose one of the following based on your UI design:
          // If you want to display both arrays, add two fields to LeaderboardModel.
          // Otherwise, if you only want the latest timestamp, extract the last element:
          lastCheaterReported:
              (data['last_cheater_reported'] != null &&
                      data['last_cheater_reported'] is List &&
                      (data['last_cheater_reported'] as List).isNotEmpty)
                  ? List<String>.from(data['last_cheater_reported'])
                  : [],
          lastToxicityReported:
              (data['last_toxicity_reported'] != null &&
                      data['last_toxicity_reported'] is List &&
                      (data['last_toxicity_reported'] as List).isNotEmpty)
                  ? List<String>.from(data['last_toxicity_reported'])
                  : [],
        );
      }).toList();
    } catch (error) {
      print("Error fetching leaderboard: $error");
      return [];
    }
  }
}
