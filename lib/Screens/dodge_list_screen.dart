import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/dodge_list_view.dart';
import 'package:flutter_application_2/components/dodge_list_input_fields.dart';
import 'package:flutter_application_2/controllers/dodge_list_controller.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:get/get.dart';

class DodgeList extends StatefulWidget {
  const DodgeList({super.key});

  @override
  State<DodgeList> createState() => _DodgeListState();
}

class _DodgeListState extends State<DodgeList> {
  final DodgeListController dodgeListController = Get.put(
    DodgeListController(),
  );

  String newUserId = "";
  String newTagLine = "";
  String? usernameError;
  String? tagLineError;

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
          DodgeListInputFields(
            usernameError: usernameError,
            tagLineError: tagLineError,
            onUsernameChanged: (value) {
              setState(() {
                newUserId = value;
                usernameError = value.isEmpty ? "Enter a Riot ID" : null;
              });
            },
            onTaglineChanged: (value) {
              setState(() {
                newTagLine = value;
                tagLineError = value.isEmpty ? "Enter a Tagline" : null;
              });
            },
            onAddUser: _addUserToDodgeList,
          ),
          DodgeListView(dodgeListController: dodgeListController),
        ],
      ),
    );
  }
}
