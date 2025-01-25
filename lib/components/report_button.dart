import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
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
    if (widget.newUserId.isNotEmpty && widget.newTagLine.isNotEmpty) {
      final user = UserModel(
        userId: widget.newUserId,
        tagLine: widget.newTagLine,
        timesReported: 0,
        lastReported: DateTime.now(),
      );

      try {
        await Get.find<UserRepository>().createUser(user);
        if (mounted) {
          await widget.onSuccess(); // Trigger the success callback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data submitted successfully!')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit user data!')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both Riot ID and Tagline'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: _handleReport, child: const Text("Report"));
  }
}
