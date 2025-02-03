import 'package:get/get.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class LeaderboardService {
  final UserRepository _userRepository =
      Get.find<UserRepository>(); // Inject repository

  Future<List<LeaderboardModel>> fetchLeaderboard() async {
    return await _userRepository.getLeaderboard();
  }
}
