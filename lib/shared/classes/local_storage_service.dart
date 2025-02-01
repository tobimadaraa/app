import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class LocalStorageService {
  static const String dodgeListKey = 'dodgeList';

  /// Saves the given dodge list locally as a list of JSON strings.
  static Future<void> saveDodgeList(List<LeaderboardModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert each model to JSON and then encode it as a string.
    List<String> jsonList =
        list.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(dodgeListKey, jsonList);
  }

  /// Loads the dodge list from local storage.
  static Future<List<LeaderboardModel>> loadDodgeList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(dodgeListKey);
    if (jsonList != null) {
      return jsonList.map((jsonStr) {
        Map<String, dynamic> jsonData = jsonDecode(jsonStr);
        return LeaderboardModel.fromJson(jsonData);
      }).toList();
    }
    return [];
  }
}
