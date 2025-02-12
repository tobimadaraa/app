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
    ("DEBUG: Decoding JSON - ${json.toString()}");

    // Check if the data comes from the API, Firestore, or Local Storage
    bool isFromApi =
        json.containsKey('gameName') && json.containsKey('tagLine');

    return LeaderboardModel(
      leaderboardNumber: json['leaderboardRank'] ??
          json['leaderboardNumber'] ??
          -1, // Handle both API & Local cases
      username: isFromApi
          ? json['gameName'].toString().trim()
          : json['username'].toString().trim(),
      tagline: isFromApi
          ? json['tagLine'].toString().trim()
          : json['tagline'].toString().trim(),
      cheaterReports: json['cheater_reported'] ?? 0,
      toxicityReports: json['toxicity_reported'] ?? 0,
      pageViews: json['page_views'] ?? 0,
      lastCheaterReported: json['last_cheater_reported'] is List
          ? List<String>.from(json['last_cheater_reported'])
          : [],
      lastToxicityReported: json['last_toxicity_reported'] is List
          ? List<String>.from(json['last_toxicity_reported'])
          : [],
    );
  }

  get leaderboardType => null;

  Map<String, dynamic> toJson() {
    return {
      'leaderboardNumber': leaderboardNumber,
      'username': username, // ✅ Ensure always using `username`
      'tagline': tagline, // ✅ Ensure always using `tagline`
      'cheater_reported': cheaterReports,
      'toxicity_reported': toxicityReports,
      'page_views': pageViews,
      'last_cheater_reported': lastCheaterReported,
      'last_toxicity_reported': lastToxicityReported,
    };
  }
}
