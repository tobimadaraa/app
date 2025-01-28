import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/validators.dart'; // Import validator
import 'package:get/get.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess; // Callback after successful report

  const ReportButton({
    super.key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
  });

  @override
  ReportButtonState createState() => ReportButtonState();
}

class ReportButtonState extends State<ReportButton> {
  // Get an instance of UserRepository
  final UserRepository _userRepository = Get.find<UserRepository>();

  Future<void> _handleReport() async {
    // Step 1: Validate input fields
    if (widget.newUserId.isEmpty || widget.newTagLine.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both Riot ID and Tagline'),
          ),
        );
      }
      return;
    }

    // Step 2: Validate formats using the validators
    final taglineError = Validator.validateTagline(widget.newTagLine);
    final userNameError = Validator.validateUsername(widget.newUserId);

    if (taglineError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(taglineError)), // Display specific error
        );
      }
      return;
    }

    if (userNameError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userNameError)), // Display specific error
        );
      }
      return;
    }

    // Step 3: Create a new user object
    final user = UserModel(
      userId: widget.newUserId,
      tagline: widget.newTagLine,
      timesReported: 0, // Initialize report count
      lastReported: DateTime.now(), // Record the current time
    );

    // Step 4: Interact with the repository
    try {
      await _userRepository.createUser(user); // Pass user to the repository

      if (mounted) {
        await widget.onSuccess(); // Trigger success callback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data submitted successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())), // Show error details
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a simple button for reporting
    return TextButton(
      onPressed: _handleReport, // Handle button press
      child: const Text("Report"),
    );
  }
}
