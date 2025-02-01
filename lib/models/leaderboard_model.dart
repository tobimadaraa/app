class LeaderboardModel {
  final int leaderboardNumber;
  final String username;
  final String tagline;
  final int cheaterReports;
  final int toxicityReported;
  final List<String> lastReported;
  LeaderboardModel({
    required this.leaderboardNumber,
    required this.username,
    required this.tagline,
    required this.cheaterReports,
    required this.toxicityReported,
    required this.lastReported,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      leaderboardNumber: json['leaderboardNumber'] ?? 0,
      // rating: json['rating'] ?? 0,
      username: json['username'] ?? '',
      tagline: json['tagline'] ?? '',
      cheaterReports: json['cheater_reported'] ?? 0,
      toxicityReported: json['toxicity_reported'] ?? 0,
      lastReported:
          (json['last_reported'] != null)
              ? List<String>.from(
                json['last_reported'],
              ) // Convert Firestore list
              : [], // Handle missing data
    );
  }
}
