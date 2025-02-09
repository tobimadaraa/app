class LeaderboardModel {
  final int leaderboardNumber;
  final String username;
  final String tagline;
  int cheaterReports;
  int toxicityReports;
  final int pageViews;
  final List<String> lastCheaterReported;
  final List<String> lastToxicityReported;

  LeaderboardModel({
    required this.leaderboardNumber,
    required this.username,
    required this.tagline,
    required this.cheaterReports,
    required this.toxicityReports,
    required this.pageViews,
    required this.lastCheaterReported,
    required this.lastToxicityReported,
  });

  // Factory constructor to convert JSON from API response
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      leaderboardNumber: json['leaderboardRank'] ?? 0, // Matches API response
      username: json['gameName'] ?? '',
      tagline: json['tagLine'] ?? '',
      cheaterReports: json['cheater_reported'] ?? 0, // Optional custom field
      toxicityReports: json['toxicity_reported'] ?? 0, // Optional custom field
      pageViews: json['page_views'] ?? 0, // Optional custom field
      lastCheaterReported: json['last_cheater_reported'] is List
          ? List<String>.from(json['last_cheater_reported'])
          : [],
      lastToxicityReported: json['last_toxicity_reported'] is List
          ? List<String>.from(json['last_toxicity_reported'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaderboardNumber': leaderboardNumber,
      'username': username.toLowerCase(),
      'tagline': tagline.toLowerCase(),
      'cheater_reported': cheaterReports,
      'toxicity_reported': toxicityReports, // ✅ Corrected this line
      'page_views': pageViews,
      'last_cheater_reported': lastCheaterReported,
      'last_toxicity_reported':
          lastToxicityReported, // ✅ Corrected key name here
    };
  }
}
