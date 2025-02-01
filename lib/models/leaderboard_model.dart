class LeaderboardModel {
  final int leaderboardNumber;
  final String username;
  final String tagline;
  final int cheaterReports;
  final int toxicityReported;
  final int pageViews; // New field for page views
  final List<String> lastReported;

  LeaderboardModel({
    required this.leaderboardNumber,
    required this.username,
    required this.tagline,
    required this.cheaterReports,
    required this.toxicityReported,
    required this.pageViews,
    required this.lastReported,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      leaderboardNumber: json['leaderboardNumber'] ?? 0,
      username: json['username'] ?? '',
      tagline: json['tagline'] ?? '',
      cheaterReports: json['cheater_reported'] ?? 0,
      toxicityReported: json['toxicity_reported'] ?? 0,
      pageViews:
          json['page_views'] ??
          0, // Read page_views from Firestore; default to 0 if missing
      lastReported:
          (json['last_reported'] != null)
              ? (json['last_reported'] is List)
                  ? List<String>.from(json['last_reported'])
                  : [json['last_reported'].toString()]
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaderboardNumber': leaderboardNumber,
      'username': username,
      'tagline': tagline,
      'cheater_reported': cheaterReports,
      'toxicity_reported': toxicityReported,
      'page_views': pageViews,
      'last_reported': lastReported,
    };
  }
}
