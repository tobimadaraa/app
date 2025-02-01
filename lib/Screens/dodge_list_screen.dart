// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/dodge_list_controller.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/components/input_field.dart';
import 'package:flutter_application_2/utils/validators.dart';
import 'package:get/get.dart';

class DodgeList extends StatefulWidget {
  const DodgeList({super.key});

  @override
  State<DodgeList> createState() => _DodgeListState();
}

class _DodgeListState extends State<DodgeList> {
  // Use the DodgeListController.
  final DodgeListController dodgeListController = Get.put(
    DodgeListController(),
  );

  String newUserId = "";
  String newTagLine = "";
  String? usernameError;
  String? tagLineError;

  /// This method fetches the leaderboard and attempts to add a matching user.
  Future<void> _addUserToDodgeList() async {
    try {
      List<LeaderboardModel> data =
          await Get.find<UserRepository>().getLeaderboard();
      LeaderboardModel? userFound = data.firstWhereOrNull(
        (user) =>
            user.username.toLowerCase() == newUserId.toLowerCase() &&
            user.tagline.toLowerCase() == newTagLine.toLowerCase(),
      );
      if (userFound != null) {
        dodgeListController.addUser(userFound);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added to dodge list")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not found")));
      }
    } catch (error) {
      print("Error fetching leaderboard: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error fetching user")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColours.bluebuttonBackGroundColor,
        title: const Center(child: Text("My Dodge List")),
      ),
      body: Column(
        children: [
          // Input for Riot ID
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputField(
              labelText: 'Enter Riot ID',
              hintText: 'e.g. your username',
              errorText: usernameError,
              onChanged: (value) {
                setState(() {
                  newUserId = value;
                  usernameError = Validator.validateUsername(value);
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Input for Tagline
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputField(
              labelText: 'Enter Tagline',
              hintText: 'e.g. NA1',
              errorText: tagLineError,
              onChanged: (value) {
                setState(() {
                  newTagLine = value;
                  tagLineError = Validator.validateTagline(value);
                });
              },
            ),
          ),
          // Add to dodge list button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _addUserToDodgeList,
              child: const Text("Add to dodgelist"),
            ),
          ),
          // Display the Dodge List using Obx.
          Expanded(
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
                        bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Delete User"),
                              content: const Text(
                                "Are you sure you want to delete this user from your dodge list?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text("Yes"),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text("No"),
                                ),
                              ],
                            );
                          },
                        );
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
          ),
        ],
      ),
    );
  }
}
