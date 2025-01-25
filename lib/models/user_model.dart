class UserModel {
  final String userId;
  final String tagLine;
  final int timesReported;
  final DateTime reportedTime;

  const UserModel({
    required this.userId,
    required this.tagLine,
    this.timesReported = 0,
    required this.reportedTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'User Id': userId,
      'Tag Line': tagLine,
      'Times Reported': timesReported,
      'Reported Time': reportedTime.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['User Id'],
      tagLine: json['Tag Line'],
      reportedTime:
          json['Reported Time'] != null
              ? DateTime.parse(json['Reported Time']) // Parse if exists
              : DateTime.now(), // Default to now if null
    );
  }
}
