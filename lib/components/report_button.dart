import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/validators.dart'; // Import validator
import 'package:get/get.dart';

class ReportButton extends StatefulWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;

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
  Future<void> _handleReport() async {
    // Check for empty fields
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

    // Validate tagline format
    final taglineError = Validator.validateTagline(widget.newTagLine);
    final userNameError = Validator.validateUsername(widget.newUserId);
    if (taglineError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(taglineError)), // Show specific error
        );
      }
      return;
    }

    if (userNameError != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userNameError)));
      }
      return;
    }
    // Proceed if validation passes
    final user = UserModel(
      userId: widget.newUserId,
      tagline: widget.newTagLine,
      timesReported: 0,
      lastReported: DateTime.now(),
    );

    try {
      await Get.find<UserRepository>().createUser(user);
      if (mounted) {
        await widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data submitted successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())), // Show actual error
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: _handleReport, child: const Text("Report"));
  }
}
