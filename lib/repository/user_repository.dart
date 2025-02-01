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
            'last_reported': FieldValue.arrayUnion([newReportTime]),
          });
        } else {
          await doc.update({
            'cheater_reported': FieldValue.increment(1),
            'last_reported': FieldValue.arrayUnion([newReportTime]),
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
            // Set the correct counter for the first report, and initialize the other to 0.
            'cheater_reported': isToxicityReport ? 0 : 1,
            'toxicity_reported': isToxicityReport ? 1 : 0,
            'last_reported': [newReportTime],
          });
        } else {
          // Completely new user: create both counters with one set to 1 based on the report type.
          await _db.collection("Users").add({
            ...user.toJson(),
            'cheater_reported': isToxicityReport ? 0 : 1,
            'toxicity_reported': isToxicityReport ? 1 : 0,
            'last_reported': [newReportTime],
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
      // ignore: avoid_print
      print(error.toString());
    }
  }

  Future<List<LeaderboardModel>> getLeaderboard() async {
    try {
      final snapshot = await _db.collection("Users").get();
      if (snapshot.docs.isEmpty) {
        // ignore: avoid_print
        print("Firestore: No users found.");
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardModel(
          leaderboardNumber: 0, // You can calculate rank separately
          username: data['user_id'] ?? '',
          tagline: data['tag_line'] ?? '',
          cheaterReports: data['cheater_reported'] ?? 0,
          // Read the new toxicity counter:
          toxicityReported: data['toxicity_reported'] ?? 0,
          lastReported:
              (data['last_reported'] != null)
                  ? (data['last_reported'] is List)
                      ? List<String>.from(data['last_reported'])
                      : [data['last_reported'].toString()]
                  : [],
        );
      }).toList();
    } catch (error) {
      // ignore: avoid_print
      print("Error fetching leaderboard: $error");
      return [];
    }
  }
}
