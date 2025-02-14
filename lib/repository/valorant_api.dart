// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/models/leaderboard_model.dart';

class RiotApiService {
  static const String apiKey = "hidden";
  static const String baseUrl =
      "https://eu.api.riotgames.com"; // Change region if needed

  // Function to fetch current Act ID
  Future<String> getCurrentActId() async {
    final url = Uri.parse('$baseUrl/val/content/v1/contents');

    final response = await http.get(
      url,
      headers: {
        'X-Riot-Token': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final acts = data['acts'];

      // Find the act where "isActive": true
      final currentAct =
          acts.firstWhere((act) => act['isActive'] == true, orElse: () => null);

      if (currentAct != null) {
        return currentAct['id'];
      } else {
        throw Exception("No active Act found.");
      }
    } else {
      throw Exception("Failed to fetch Act ID: ${response.statusCode}");
    }
  }

  List<LeaderboardModel> _cachedLeaderboard = [];

  Future<void> loadLeaderboardCache() async {
    _cachedLeaderboard = await getLeaderboard();
  }

  Future<bool> checkPlayerExists(String username, String tagline) async {
    if (_cachedLeaderboard.isEmpty) {
      await loadLeaderboardCache(); // Fetch leaderboard only once
    }

    bool exists = _cachedLeaderboard.any((player) =>
        player.username.toLowerCase() == username.toLowerCase() &&
        player.tagline.toLowerCase() == tagline.toLowerCase());

    print("DEBUG: Player exists check result for $username#$tagline: $exists");
    return exists;
  }

  // Function to fetch leaderboard using the current Act ID
  Future<List<LeaderboardModel>> getLeaderboard({
    int startIndex = 0,
    int size = 200,
    bool includeStats = true,
  }) async {
    String actId = await getCurrentActId(); // Fetch Act ID dynamically

    final response = await http.get(
        Uri.parse(
            '$baseUrl/val/ranked/v1/leaderboards/by-act/$actId?startIndex=$startIndex&size=$size'),
        headers: {'X-Riot-Token': apiKey});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> players = data['players'];

      return players
          .map((player) =>
              LeaderboardModel.fromJson(player, includeStats: includeStats))
          .toList();
    } else {
      throw Exception("Failed to fetch leaderboard: ${response.statusCode}");
    }
  }
}
