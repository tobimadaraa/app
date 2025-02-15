import 'package:flutter_application_2/models/leaderboard_model.dart';

class CachedLeaderboard {
  final List<LeaderboardModel> data;
  final DateTime timestamp;

  CachedLeaderboard({
    required this.data,
    required this.timestamp,
  });
}
