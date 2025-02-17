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
    // Log the button press.
    print(
        "DEBUG: Report button pressed for ${widget.newUserId}#${widget.newTagLine}");

    // Validate inputs.
    if (widget.newUserId.isEmpty || widget.newTagLine.isEmpty) {
      // Delay the snackbar until after the current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Error",
            "Please enter both Riot ID and Tagline.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
      return;
    }

    try {
      // Report the player.
      await _userRepository.reportPlayer(
        gameName: widget.newUserId.toLowerCase(),
        tagLine: widget.newTagLine.toLowerCase(),
        isToxicityReport: widget.isToxicity,
      );

      // Delay the success snackbar until after the current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Success",
            widget.isToxicity
                ? "Player successfully reported as toxic!"
                : "Player successfully reported as a cheater!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      });

      // Call the onSuccess callback to refresh data.
      await widget.onSuccess();

      // Safely update the UI.
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      // Delay the error snackbar until after the current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Error",
            error.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
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
