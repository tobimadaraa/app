import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:get/get.dart';

class ReportButton extends StatelessWidget {
  final String newUserId;
  final String newTagLine;
  final Future<void> Function() onSuccess;

  const ReportButton({
    Key? key,
    required this.newUserId,
    required this.newTagLine,
    required this.onSuccess,
  }) : super(key: key);

  void _handleReport(BuildContext context) {
    if (newUserId.isNotEmpty && newTagLine.isNotEmpty) {
      final user = UserModel(
        userId: newUserId,
        tagLine: newTagLine,
        timesReported: 0,
        lastReported: DateTime.now(),
      );

      Get.find<UserRepository>()
          .createUser(user)
          .then((_) async {
            await onSuccess(); // Trigger the onSuccess callback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User data submitted successfully!'),
              ),
            );
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to submit user data!')),
            );
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Riot ID and Tagline')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _handleReport(context),
      child: const Text("Report"),
    );
  }
}
