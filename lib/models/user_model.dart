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
      userId: json['user_id'] ?? '',
      tagline: json['tag_line'] ?? '',
      timesReported: json['times_reported'] ?? 0, // Add this line
      lastReported:
          json['last_reported'] != null
              ? DateTime.parse(json['last_reported'])
              : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? userId,
    String? tagline,
    int? timesReported,
    DateTime? lastReported,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      tagline: tagline ?? this.tagline,
      timesReported: timesReported ?? this.timesReported,
      lastReported: lastReported ?? this.lastReported,
    );
  }
}
