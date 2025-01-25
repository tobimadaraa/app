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
      final userDoc = _db.collection("Users").doc(user.userId);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        // Increment timesReported if the user already exists
        await userDoc.update({'Times Reported': FieldValue.increment(1)});
      } else {
        // Create a new user with default timesReported
        await userDoc.set(user.toJson());
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
          rating: data['Rating'] ?? 0,
          username: data['User Id'] ?? '',
          timesReported: data['Times Reported'] ?? 0,
        );
      }).toList();
    } catch (error) {
      print(error.toString());
      return [];
    }
  }
}
