import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/dodge_list_view.dart';
import 'package:flutter_application_2/components/dodge_list_input_fields.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class DodgeList extends StatefulWidget {
  const DodgeList({super.key});

  @override
  State<DodgeList> createState() => _DodgeListState();
}

class _DodgeListState extends State<DodgeList> {
  List<LeaderboardModel> dodgeList = [];
  final UserRepository userRepository = UserRepository();

  String? usernameError;
  String? tagLineError;
  String newUserId = "";
  String newTagLine = "";

  @override
  void initState() {
    super.initState();
    _loadDodgeList();
  }

  Future<void> _loadDodgeList() async {
    List<LeaderboardModel> storedList = await userRepository
        .firestoreGetDodgeList(); // ✅ Use Dodge List function
    setState(() {
      dodgeList = storedList;
    });
  }

  Future<void> _addUserToDodgeList() async {
    try {
      List<LeaderboardModel> data =
          await userRepository.firestoreGetLeaderboard();
      LeaderboardModel? userFound = data.firstWhere(
        (user) =>
            user.username.toLowerCase() == newUserId.toLowerCase() &&
            user.tagline.toLowerCase() == newTagLine.toLowerCase(),
        orElse: () => LeaderboardModel(
            leaderboardNumber: -1,
            username: "",
            tagline: "",
            cheaterReports: 0,
            toxicityReports: 0,
            pageViews: 0,
            lastCheaterReported: [],
            lastToxicityReported: []),
      );

      if (userFound.username.isNotEmpty) {
        await userRepository.addToDodgeList(userFound); // ✅ Save in Firestore

        setState(() {
          dodgeList.add(userFound);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added to Dodge List")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching user")),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(LeaderboardModel user) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content: Text(
                  "Are you sure you want to remove ${user.username}#${user.tagline} from your Dodge List?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // ✅ Confirm
                  child:
                      const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // ❌ Cancel
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed
  }

  Future<void> _removeUserFromDodgeList(LeaderboardModel user) async {
    bool confirmDelete = await _showDeleteConfirmationDialog(user);

    if (confirmDelete) {
      try {
        await userRepository
            .removeFromDodgeList(user); // ✅ Remove from Firestore

        setState(() {
          dodgeList.removeWhere(
            (existing) =>
                existing.username.toLowerCase() ==
                    user.username.toLowerCase() &&
                existing.tagline.toLowerCase() == user.tagline.toLowerCase(),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${user.username}#${user.tagline} removed from Dodge List")),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error removing user")),
        );
      }
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
          Expanded(
            child: DodgeListView(
              dodgeList: dodgeList,
              onRemoveUser: _removeUserFromDodgeList, // ✅ Pass delete function
            ),
          ),
        ],
      ),
    );
  }
}
