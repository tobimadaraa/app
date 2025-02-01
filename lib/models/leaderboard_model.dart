class LeaderboardModel {
  final int leaderboardNumber;
  final String username;
  final String tagline;
  final int cheaterReports;
  final int toxicityReported;
  final int pageViews;
  final List<String> lastCheaterReported;
  final List<String> lastToxicityReported;

  LeaderboardModel({
    required this.leaderboardNumber,
    required this.username,
    required this.tagline,
    required this.cheaterReports,
    required this.toxicityReported,
    required this.pageViews,
    required this.lastCheaterReported,
    required this.lastToxicityReported,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      leaderboardNumber: json['leaderboardNumber'] ?? 0,
      username: json['username'] ?? '',
      tagline: json['tagline'] ?? '',
      cheaterReports: json['cheater_reported'] ?? 0,
      toxicityReported: json['toxicity_reported'] ?? 0,
      pageViews: json['page_views'] ?? 0,
      lastCheaterReported:
          (json['last_cheater_reported'] != null &&
                  json['last_cheater_reported'] is List)
              ? List<String>.from(json['last_cheater_reported'])
              : [],
      lastToxicityReported:
          (json['last_toxicity_reported'] != null &&
                  json['last_toxicity_reported'] is List)
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
      'toxicity_reported': toxicityReported,
      'page_views': pageViews,
      'last_cheater_reported': lastCheaterReported,
      'last_toxic_reported': lastToxicityReported,
    };
  }

  //String get fullRiotId => '${username.toLowerCase()}#${tagline.toLowerCase()}';
}
