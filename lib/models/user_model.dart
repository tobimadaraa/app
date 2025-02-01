class UserModel {
  final String userId;
  final String tagline;
  // final DateTime lastReported;

  const UserModel({
    required this.userId,
    required this.tagline,
    // required this.lastReported,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'tag_line': tagline,
      // 'last_reported': lastReported.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      tagline: json['tag_line'] ?? '',
      // lastReported:
      //     json['last_reported'] != null
      //         ? DateTime.parse(json['last_reported'])
      //         : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? userId,
    String? tagline,
    DateTime? lastReported,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      tagline: tagline ?? this.tagline,
      // lastReported: lastReported ?? this.lastReported,
    );
  }
}
