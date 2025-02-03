import 'package:flutter/material.dart';
//import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/controllers/dodge_list_controller.dart';
import 'package:get/get.dart';

class DodgeListView extends StatelessWidget {
  final DodgeListController dodgeListController;

  const DodgeListView({super.key, required this.dodgeListController});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (dodgeListController.dodgeList.isEmpty) {
          return const Center(child: Text("No users in dodge list"));
        }
        return ListView.builder(
          itemCount: dodgeListController.dodgeList.length,
          itemBuilder: (context, index) {
            final user = dodgeListController.dodgeList[index];
            return ListTile(
              title: Text('${user.username}#${user.tagline}'),
              subtitle: Text(
                'Cheater Reports: ${user.cheaterReports}, Toxicity Reports: ${user.toxicityReported}\nPage Views: ${user.pageViews}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  bool? confirmDelete = await _showDeleteDialog(context);
                  if (confirmDelete == true) {
                    dodgeListController.removeUser(user);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User removed from dodge list"),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: const Text(
            "Are you sure you want to delete this user from your dodge list?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }
}
