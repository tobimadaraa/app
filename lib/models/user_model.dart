class UserModel {
  final String userId;
  final String tagline;
  final int timesReported;
  final DateTime lastReported;

  const UserModel({
    required this.userId,
    required this.tagline,
    this.timesReported = 0,
    required this.lastReported,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tag_line': tagline,
      'times_reported': timesReported,
      'last_reported': lastReported.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      tagline: json['tag_line'],
      lastReported:
          json['last_reported'] != null
              ? DateTime.parse(json['last_reported']) // Parse if exists
              : DateTime.now(), // Default to now if null
    );
  }
}
