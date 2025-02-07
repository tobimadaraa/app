import 'package:flutter/material.dart';

import 'package:flutter_application_2/controllers/dodge_list_controller.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:get/get.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;
  final String buttonText;
  final bool isToxicity;

  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
    this.buttonText = 'Report Cheater',
    this.isToxicity = false,
  });

  @override
  ReportButtonState createState() => ReportButtonState();
}

class ReportButtonState extends State<ReportButton> {
  final UserRepository _userRepository = Get.find<UserRepository>();

  Future<void> _handleReport() async {
    if (widget.newUserId.isEmpty || widget.newTagLine.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both Riot ID and Tagline.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _userRepository.reportPlayer(
        username: widget.newUserId.toLowerCase(),
        tagline: widget.newTagLine.toLowerCase(),
        isToxicityReport: widget.isToxicity,
      );

      Get.snackbar(
        "Success",
        "Player successfully reported!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ Refresh Firestore Leaderboard & Dodge List
      await widget.onSuccess();
      Get.find<DodgeListController>()
          .refreshDodgeList(); // 🔥 Refresh Dodge List

      // ✅ Force UI Refresh
      setState(() {});
    } catch (error) {
      Get.snackbar(
        "Error",
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _handleReport,
      child: Text(widget.buttonText),
    );
  }
}
