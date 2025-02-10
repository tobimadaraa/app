import 'package:flutter/material.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:get/get.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;
  final String buttonText;
  final bool isToxicity; // ✅ Ensure this is correctly passed

  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
    required this.isToxicity, // ✅ Now it's always required
    required this.buttonText,
  });

  @override
  ReportButtonState createState() => ReportButtonState();
}

class ReportButtonState extends State<ReportButton> {
  final UserRepository _userRepository = UserRepository();

  Future<void> _handleReport() async {
    print(
        "DEBUG: Report button pressed for ${widget.newUserId}#${widget.newTagLine}");
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
        isToxicityReport:
            widget.isToxicity, // ✅ Ensure this boolean is correctly passed
      );

      Get.snackbar(
        "Success",
        widget.isToxicity
            ? "Player successfully reported as toxic!"
            : "Player successfully reported as a cheater!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await widget.onSuccess(); // ✅ Refresh leaderboard
      setState(() {}); // ✅ Force UI refresh
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
