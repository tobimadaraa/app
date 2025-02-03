// lib/components/report_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/validators.dart';
import 'package:get/get.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;
  final String buttonText;
  final bool isToxicity;

  // Now buttonText and isToxicity are optional with default values.
  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
    this.buttonText = 'Report Cheater', // Default text
    this.isToxicity = false, // Default report type is for cheater
  });

  @override
  ReportButtonState createState() => ReportButtonState();
}

class ReportButtonState extends State<ReportButton> {
  final UserRepository _userRepository = Get.find<UserRepository>();

  Future<void> _handleReport() async {
    // Step 1: Validate input fields
    if (widget.newUserId.isEmpty || widget.newTagLine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Riot ID and Tagline')),
      );
      return;
    }

    // Step 2: Validate formats using the validators
    final taglineError = Validator.validateTagline(widget.newTagLine);
    final userNameError = Validator.validateUsername(widget.newUserId);

    if (taglineError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(taglineError)));
      return;
    }

    if (userNameError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userNameError)));
      return;
    }

    // Step 3: Create a new user object
    final user = UserModel(
      userId: widget.newUserId.toLowerCase(),
      tagline: widget.newTagLine.toLowerCase(),
    );

    // Step 4: Interact with the repository
    try {
      // Pass an extra parameter (isToxicity) so that the repository knows which field to update.
      await _userRepository.createUser(
        user,
        isToxicityReport: widget.isToxicity,
      );
      await widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data submitted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _handleReport,
      child: Text(
        widget.buttonText,
      ), // Uses the passed in or default button text
    );
  }
}
