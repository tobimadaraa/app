import 'package:get/get.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class DodgeListController extends GetxController {
  // Use an RxList to automatically update the UI when the list changes.
  RxList<LeaderboardModel> dodgeList = <LeaderboardModel>[].obs;

  /// Adds a user to the dodge list if they aren't already added.
  void addUser(LeaderboardModel user) {
    bool alreadyAdded = dodgeList.any(
      (existing) =>
          existing.username.toLowerCase() == user.username.toLowerCase() &&
          existing.tagline.toLowerCase() == user.tagline.toLowerCase(),
    );
    if (!alreadyAdded) {
      dodgeList.add(user);
    }
  }
}
