import 'package:flutter/material.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/validators.dart'; // <-- Import the validators.
import 'package:get/get.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;
  final String buttonText;
  final bool isToxicity;
  final bool isHonour; // ✅ New Honour flag added

  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
    required this.isToxicity,
    required this.isHonour, // ✅ Now it's always required
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
      bool reportResult = await _userRepository.reportPlayer(
        gameName: widget.newUserId.toLowerCase(),
        tagLine: widget.newTagLine.toLowerCase(),
        isToxicityReport: widget.isToxicity,
        isHonourReport: widget.isHonour, // ✅ Ensure Honour Report is passed
      );

      if (!reportResult) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Get.context != null) {
            Get.snackbar(
              "Error",
              "User not found.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Get.context != null) {
          Get.snackbar(
            "Success",
            widget.isHonour
                ? "Player successfully honoured!"
                : widget.isToxicity
                    ? "Player successfully reported as toxic!"
                    : "Player successfully reported as a cheater!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      });

      await widget.onSuccess();

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
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
    // ✅ Validate inputs using the Validator class
    final bool isValid = Validator.validateUsername(widget.newUserId) == null &&
        Validator.validateTagline(widget.newTagLine) == null;

    // Determine button background color based on report type and validity.
    final Color? reportButtonColor;
    if (widget.isHonour) {
      reportButtonColor = isValid
          ? Colors.green
          : Colors.grey.shade200; // Colors.green.shade900;
    } else if (widget.isToxicity) {
      reportButtonColor = isValid ? Colors.amber : Colors.grey.shade200;
    } else {
      // Report Cheater
      reportButtonColor = isValid ? Colors.red : Colors.grey.shade200;
    }

    return TextButton(
      onPressed: isValid
          ? _handleReport
          : null, // Button disabled if inputs are invalid.Color(0xFFB71C1C)
      style: TextButton.styleFrom(
        backgroundColor: reportButtonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(widget.buttonText, style: const TextStyle(fontSize: 16)),
    );
  }
}
