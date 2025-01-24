class UserModel {
  final String userId;
  final String tagLine;

  const UserModel({required this.userId, required this.tagLine});

  toJson() {
    return {'User Id ': userId, 'Tag Line': tagLine};
  }
}
