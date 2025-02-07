import 'package:flutter_application_2/shared/classes/local_storage_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class DodgeListController extends GetxController {
  RxList<LeaderboardModel> dodgeList = <LeaderboardModel>[].obs;
  final UserRepository _userRepository = Get.find<UserRepository>();

  @override
  void onInit() {
    super.onInit();
    _loadDodgeList();
  }

  /// **Load Dodge List from Local Storage & Sync with Firestore**
  Future<void> _loadDodgeList() async {
    // Load locally stored dodge list
    List<LeaderboardModel> storedList =
        await LocalStorageService.loadDodgeList();

    // Check Firestore for updated report counts
    List<LeaderboardModel> firestoreData =
        await _userRepository.getLeaderboard();

    // ✅ Sync Local Storage with Firestore
    for (var user in storedList) {
      var updatedUser = firestoreData.firstWhereOrNull(
        (firestoreUser) =>
            firestoreUser.username.toLowerCase() ==
                user.username.toLowerCase() &&
            firestoreUser.tagline.toLowerCase() == user.tagline.toLowerCase(),
      );

      if (updatedUser != null) {
        // Replace local storage data with updated Firestore data
        user.cheaterReports = updatedUser.cheaterReports;
        user.toxicityReported = updatedUser.toxicityReported;
      }
    }

    dodgeList.assignAll(storedList);
  }

  /// **Adds a User to the Dodge List & Saves Locally**
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

  /// **Removes a User from the Dodge List**
  void removeUser(LeaderboardModel user) {
    dodgeList.removeWhere(
      (existing) =>
          existing.username.toLowerCase() == user.username.toLowerCase() &&
          existing.tagline.toLowerCase() == user.tagline.toLowerCase(),
    );
    LocalStorageService.saveDodgeList(dodgeList);
  }

  /// **🔥 Refresh Dodge List from Firestore**
  Future<void> refreshDodgeList() async {
    List<LeaderboardModel> updatedList = await _userRepository.getLeaderboard();

    for (var user in dodgeList) {
      var updatedUser = updatedList.firstWhereOrNull(
        (firestoreUser) =>
            firestoreUser.username.toLowerCase() ==
                user.username.toLowerCase() &&
            firestoreUser.tagline.toLowerCase() == user.tagline.toLowerCase(),
      );

      if (updatedUser != null) {
        user.cheaterReports =
            updatedUser.cheaterReports; // ✅ Updates Cheater Reports
        user.toxicityReported = updatedUser
            .toxicityReported; // ✅ Now correctly updates Toxicity Reports
      }
    }

    update(); // ✅ Refresh the UI
  }
}
