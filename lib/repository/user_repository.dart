import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      // Use `doc` to update or create user by userId
      final username = _db.collection("Users").doc(user.userId);
      final docSnapshot = await username.get();

      if (docSnapshot.exists) {
        // Increment lastReported if the user already exists
        await username.update({'times_reported': FieldValue.increment(1)});
      } else {
        // Create a new user with default lastReported
        await username.set(user.toJson());
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
