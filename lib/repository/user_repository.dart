import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      // Query for matching Riot ID and tagline
      final query =
          await _db
              .collection("Users")
              .where('user_id', isEqualTo: user.userId)
              .where('tag_line', isEqualTo: user.tagline)
              .get();

      if (query.docs.isNotEmpty) {
        // Update the existing user's report count
        final doc = query.docs.first.reference;
        await doc.update({
          'times_reported': FieldValue.increment(1),
          'last_reported': user.lastReported.toIso8601String(),
        });
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
            'times_reported': 1, // Set to 1 for the first report
          });
        } else {
          // Completely new user
          await _db.collection("Users").doc(user.userId).set({
            ...user.toJson(), // Include all fields from user
            'times_reported': 1, // Set to 1 for the first report
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

  Future<List<LeaderboardModel>> getLeaderboard() async {
    try {
      final snapshot = await _db.collection("Users").get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardModel(
          leaderboardNumber: 0, // You can calculate rank separately
          rating: data['rating'] ?? 0,
          username: data['user_id'] ?? '',
          tagline: data['tag_line'] ?? '',
          timesReported: data['times_reported'] ?? 0,
          lastReported:
              data['last_reported'] != null
                  ? DateTime.parse(
                    data['last_reported'],
                  ) // Parse ISO 8601 string
                  : DateTime.now(), // Default to now if null
        );
      }).toList();
    } catch (error) {
      // ignore: avoid_print
      print(error.toString());
      return [];
    }
  }
}
