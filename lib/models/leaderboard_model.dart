class LeaderboardModel {
  final int leaderboardRank;
  final String gameName;
  final String tagLine;
  int cheaterReports;
  int toxicityReports;
  int honourReports;
  final int pageViews;
  final List<String> lastCheaterReported;
  final List<String> lastToxicityReported;
  final List<String> lastHonourReported; // ✅ Ensure this exists
  final int? rankedRating;
  final int? numberOfWins;
  final int iconIndex; // 🟢 Added this field

  LeaderboardModel({
    required this.leaderboardRank,
    required this.gameName,
    required this.tagLine,
    required this.cheaterReports,
    required this.toxicityReports,
    this.honourReports = 0,
    required this.pageViews,
    required this.lastCheaterReported,
    required this.lastHonourReported,
    this.rankedRating,
    this.numberOfWins,
    required this.lastToxicityReported,
    required this.iconIndex, // 🟢 Make sure it's required
  });

  /// ✅ Factory constructor to convert JSON from Firestore or API response
  factory LeaderboardModel.fromJson(Map<String, dynamic> json,
      {bool includeStats = true}) {
    return LeaderboardModel(
      leaderboardRank: json['leaderboardRank'] ?? -1,
      gameName: json['gameName']?.toString().trim() ?? "Unknown",
      tagLine: json['tagLine']?.toString().trim() ?? "N/A",
      rankedRating: includeStats ? json['rankedRating'] ?? 0 : null,
      numberOfWins: includeStats ? json['numberOfWins'] ?? 0 : null,
      cheaterReports: json['cheater_reported'] ?? 0,
      toxicityReports: json['toxicity_reported'] ?? 0,
      honourReports: json['times_honoured'] ?? 0,
      pageViews: json['page_views'] ?? 0,
      lastCheaterReported: json['last_cheater_reported'] is List
          ? List<String>.from(json['last_cheater_reported'])
          : [],
      lastToxicityReported: json['last_toxicity_reported'] is List
          ? List<String>.from(json['last_toxicity_reported'])
          : [],
      lastHonourReported: json['last_time_honoured'] is List
          ? List<String>.from(json['last_time_honoured'])
          : [],

      iconIndex: json['iconIndex'] ?? 0, // 🟢 Ensuring default value
    );
  }

  /// ✅ Convert `LeaderboardModel` to JSON for Firestore/API
  Map<String, dynamic> toJson() {
    return {
      'leaderboardRank': leaderboardRank,
      'gameName': gameName,
      'tagLine': tagLine,
      'cheater_reported': cheaterReports,
      'toxicity_reported': toxicityReports,
      'times_honoured': honourReports,
      'page_views': pageViews,
      'last_cheater_reported': lastCheaterReported,
      'last_toxicity_reported': lastToxicityReported,
      'last_time_honoured': lastHonourReported,
      'iconIndex': iconIndex, // 🟢 Ensure this is saved to Firestore
    };
  }

  /// ✅ `copyWith` to modify instances without recreating everything
  LeaderboardModel copyWith({
    int? leaderboardRank,
    String? gameName,
    String? tagLine,
    int? cheaterReports,
    int? toxicityReports,
    int? pageViews,
    List<String>? lastCheaterReported,
    List<String>? lastToxicityReported,
    List<String>? lastHonourReported,
    int? rankedRating,
    int? numberOfWins,
    int? iconIndex, // 🟢 Add this so it can be modified
  }) {
    return LeaderboardModel(
      leaderboardRank: leaderboardRank ?? this.leaderboardRank,
      gameName: gameName ?? this.gameName,
      tagLine: tagLine ?? this.tagLine,
      cheaterReports: cheaterReports ?? this.cheaterReports,
      toxicityReports: toxicityReports ?? this.toxicityReports,
      honourReports: honourReports,
      pageViews: pageViews ?? this.pageViews,
      lastCheaterReported: lastCheaterReported ?? this.lastCheaterReported,
      lastToxicityReported: lastToxicityReported ?? this.lastToxicityReported,
      lastHonourReported: lastHonourReported ?? this.lastHonourReported,
      rankedRating: rankedRating ?? this.rankedRating,
      numberOfWins: numberOfWins ?? this.numberOfWins,
      iconIndex: iconIndex ?? this.iconIndex, // 🟢 Make sure it can be modified
    );
  }
}
