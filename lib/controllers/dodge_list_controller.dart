import 'package:flutter_application_2/shared/classes/local_storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class DodgeListController extends GetxController {
  RxList<LeaderboardModel> dodgeList = <LeaderboardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load the stored dodge list when the controller is initialized.
    _loadDodgeList();
  }

  Future<void> _loadDodgeList() async {
    List<LeaderboardModel> storedList =
        await LocalStorageService.loadDodgeList();
    dodgeList.assignAll(storedList);
  }

  /// Adds a user to the dodge list if they’re not already added, then saves locally.
  void addUser(LeaderboardModel user) {
    bool alreadyAdded = dodgeList.any(
      (existing) =>
          existing.username.toLowerCase() == user.username.toLowerCase() &&
          existing.tagline.toLowerCase() == user.tagline.toLowerCase(),
    );
    if (!alreadyAdded) {
      dodgeList.add(user);
      LocalStorageService.saveDodgeList(dodgeList);
    }
  }

  /// Removes a user from the dodge list and saves locally.
  void removeUser(LeaderboardModel user) {
    dodgeList.removeWhere(
      (existing) =>
          existing.username.toLowerCase() == user.username.toLowerCase() &&
          existing.tagline.toLowerCase() == user.tagline.toLowerCase(),
    );
    LocalStorageService.saveDodgeList(dodgeList);
  }
}
