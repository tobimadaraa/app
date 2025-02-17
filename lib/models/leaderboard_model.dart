class LeaderboardModel {
  final int leaderboardRank;
  final String gameName;
  final String tagLine;
  int cheaterReports;
  int toxicityReports;
  final int pageViews;
  final List<String> lastCheaterReported;
  final List<String> lastToxicityReported;
  final int? rankedRating;
  final int? numberOfWins;
  LeaderboardModel({
    required this.leaderboardRank,
    required this.gameName,
    required this.tagLine,
    required this.cheaterReports,
    required this.toxicityReports,
    required this.pageViews,
    required this.lastCheaterReported,
    this.rankedRating,
    this.numberOfWins,
    required this.lastToxicityReported,
  });

  // Factory constructor to convert JSON from API response
  factory LeaderboardModel.fromJson(Map<String, dynamic> json,
      {bool includeStats = true}) {
    ("DEBUG: Decoding JSON - ${json.toString()}");

    // Check if the data comes from the API, Firestore, or Local Storage
    bool isFromApi =
        json.containsKey('gameName') && json.containsKey('tagLine');

    return LeaderboardModel(
      leaderboardRank: json['leaderboardRank'] ??
          json['leaderboardRank'] ??
          -1, // Riot API handling/ Handle both API & Local cases
      gameName: isFromApi
          ? json['gameName'].toString().trim()
          : json['gameName'].toString().trim(),
      tagLine: isFromApi
          ? json['tagLine'].toString().trim()
          : json['tagLine'].toString().trim(),
      rankedRating: includeStats ? json['rankedRating'] ?? 0 : null,
      numberOfWins: includeStats ? json['numberOfWins'] ?? 0 : null,
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
      'leaderboardRank': leaderboardRank,
      'gameName': gameName, // ✅ Ensure always using `username`
      'tagLine': tagLine, // ✅ Ensure always using `tagline`
      'cheater_reported': cheaterReports,
      'toxicity_reported': toxicityReports,
      'page_views': pageViews,
      'last_cheater_reported': lastCheaterReported,
      'last_toxicity_reported': lastToxicityReported,
    };
  }

  LeaderboardModel copyWith({
    int? leaderboardRank,
    String? gameName,
    String? tagLine,
    int? cheaterReports,
    int? toxicityReports,
    int? pageViews,
    List<String>? lastCheaterReported,
    List<String>? lastToxicityReported,
    int? rankedRating,
    int? numberOfWins,
  }) {
    return LeaderboardModel(
      leaderboardRank: leaderboardRank ?? this.leaderboardRank,
      gameName: gameName ?? this.gameName,
      tagLine: tagLine ?? this.tagLine,
      cheaterReports: cheaterReports ?? this.cheaterReports,
      toxicityReports: toxicityReports ?? this.toxicityReports,
      pageViews: pageViews ?? this.pageViews,
      lastCheaterReported: lastCheaterReported ?? this.lastCheaterReported,
      lastToxicityReported: lastToxicityReported ?? this.lastToxicityReported,
      rankedRating: rankedRating ?? this.rankedRating,
      numberOfWins: numberOfWins ?? this.numberOfWins,
    );
  }
}
