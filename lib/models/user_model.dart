class UserModel {
  final String gameName;
  final String tagLine;
  // final DateTime lastReported;

  const UserModel({
    required this.gameName,
    required this.tagLine,
    // required this.lastReported,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameName': gameName,
      'tagLine': tagLine,
      // 'last_reported': lastReported.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      gameName: json['gameName'] ?? '',
      tagLine: json['tagLine'] ?? '',
      // lastReported:
      //     json['last_reported'] != null
      //         ? DateTime.parse(json['last_reported'])
      //         : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? gameName,
    String? tagLine,
    DateTime? lastReported,
  }) {
    return UserModel(
      gameName: gameName ?? this.gameName,
      tagLine: tagLine ?? this.tagLine,
      // lastReported: lastReported ?? this.lastReported,
    );
  }
}
