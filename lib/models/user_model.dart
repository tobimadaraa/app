class UserModel {
  final String userId;
  final String tagLine;
  final int timesReported;
  final DateTime lastReported;

  const UserModel({
    required this.userId,
    required this.tagLine,
    this.timesReported = 0,
    required this.lastReported,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tag_line': tagLine,
      'times_reported': timesReported,
      'last_reported ': lastReported.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      tagLine: json['tag_line'],
      lastReported:
          json['last_reported'] != null
              ? DateTime.parse(json['last_reported']) // Parse if exists
              : DateTime.now(), // Default to now if null
    );
  }
}
