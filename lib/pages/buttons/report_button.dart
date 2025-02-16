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
    // ignore: avoid_print
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
      // 1️⃣ Attempt to report the player; capture success/failure.
      final success = await _userRepository.reportPlayer(
        username: widget.newUserId.toLowerCase(),
        tagline: widget.newTagLine.toLowerCase(),
        isToxicityReport: widget.isToxicity,
      );

      // 2️⃣ If `success` is false, show an error snackbar and return.
      if (!success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Get.context != null) {
            Get.snackbar(
              "Error",
              "Player does not exist or could not be reported.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
        return;
      }

      // 3️⃣ If `success` is true, show the success snackbar.
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

      // 4️⃣ Call the onSuccess callback to refresh data.
      await widget.onSuccess();

      // 5️⃣ Safely update the UI if we're still mounted.
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      // If the repository method throws an exception for other reasons:
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
