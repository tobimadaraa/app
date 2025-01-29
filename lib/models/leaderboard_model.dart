class LeaderboardModel {
  final int leaderboardNumber;
  final String username;
  final String tagline;
  final int timesReported;
  final List<String> lastReported;
  LeaderboardModel({
    required this.leaderboardNumber,
    required this.username,
    required this.tagline,
    required this.timesReported,
    required this.lastReported,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      leaderboardNumber: json['leaderboardNumber'] ?? 0,
      // rating: json['rating'] ?? 0,
      username: json['username'] ?? '',
      tagline: json['tagline'] ?? '',
      timesReported: json['times_reported'] ?? 0,
      lastReported:
          (json['last_reported'] != null)
              ? List<String>.from(
                json['last_reported'],
              ) // Convert Firestore list
              : [], // Handle missing data
    );
  }
}
