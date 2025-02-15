// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

/// Updates the stored Dodge List in SharedPreferences when a new user is reported.
Future<void> updateDodgeListStorage(String username, String tagline) async {
  final prefs = await SharedPreferences.getInstance();

  // Load existing dodge list from storage
  String? storedList = prefs.getString("dodge_list");
  List<LeaderboardModel> dodgeList = [];

  if (storedList != null) {
    List<dynamic> jsonData = jsonDecode(storedList);
    dodgeList = jsonData.map((e) => LeaderboardModel.fromJson(e)).toList();
  }

  // Check if the user already exists in the dodge list
  bool userExists = dodgeList.any((user) =>
      user.username.toLowerCase() == username.toLowerCase() &&
      user.tagline.toLowerCase() == tagline.toLowerCase());

  if (!userExists) {
    print("🟢 Adding $username#$tagline to stored Dodge List...");

    // Fetch full leaderboard to find the reported user
    final userRepository = UserRepository();
    List<LeaderboardModel> data =
        await userRepository.firestoreGetLeaderboard();

    LeaderboardModel? reportedUser = data.firstWhereOrNull((user) =>
        user.username.toLowerCase() == username.toLowerCase() &&
        user.tagline.toLowerCase() == tagline.toLowerCase());

    if (reportedUser != null) {
      dodgeList.add(reportedUser);

      // Save updated dodge list back into storage
      await prefs.setString(
          "dodge_list", jsonEncode(dodgeList.map((e) => e.toJson()).toList()));

      print("✅ Dodge List Updated in Storage!");
    } else {
      print("❌ User not found in leaderboard, not adding to Dodge List.");
    }
  } else {
    print("⚠️ User is already in the Dodge List.");
  }
}
