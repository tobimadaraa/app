class LeaderboardModel {
  final int leaderboardNumber;
  final int rating;
  final String username;
  final String tagline;
  final int timesReported;
  final DateTime lastReported;
  LeaderboardModel({
    required this.leaderboardNumber,
    required this.rating,
    required this.username,
    required this.tagline,
    required this.lastReported,
    required this.timesReported,
  });
}
