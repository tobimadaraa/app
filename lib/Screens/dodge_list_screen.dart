import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/dodge_list_view.dart';
import 'package:flutter_application_2/components/dodge_list_input_fields.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final GlobalKey<DodgeListState> dodgeListKey = GlobalKey<DodgeListState>();

class DodgeList extends StatefulWidget {
  const DodgeList({super.key});
  @override
  State<DodgeList> createState() => DodgeListState();
}

class DodgeListState extends State<DodgeList> {
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
    syncDodgeListWithLeaderboard();
  }

  Future<void> _loadDodgeList() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedList = prefs.getString("dodge_list");
    ("DEBUG: Loaded raw Dodge List JSON: $storedList");
    if (storedList != null) {
      List<dynamic> jsonData = jsonDecode(storedList);
      setState(() {
        dodgeList = jsonData.map((e) => LeaderboardModel.fromJson(e)).toList();
      });
      for (var user in dodgeList) {
        ("DEBUG: Loaded User - ${user.username}#${user.tagline} | Cheater Reports: ${user.cheaterReports} | Toxicity Reports: ${user.toxicityReports}");
      }
    }
  }

  Future<void> _saveDodgeListToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonData =
        dodgeList.map((user) => user.toJson()).toList();

    String jsonString = jsonEncode(jsonData);
    ("DEBUG: Saving Dodge List JSON: $jsonString"); // ✅ Debug before saving

    await prefs.setString("dodge_list", jsonString);
  }

  Future<void> _addUserToDodgeList() async {
    try {
      // ✅ Fetch the full leaderboard
      List<LeaderboardModel> data =
          await userRepository.firestoreGetLeaderboard();

      // ✅ Find the user in the leaderboard
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
        // ✅ Store the user locally
        dodgeList.add(userFound);
        await _saveDodgeListToLocalStorage();

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added to Dodge List")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found in leaderboard")),
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
        setState(() {
          dodgeList.removeWhere(
            (existing) =>
                existing.username.toLowerCase() ==
                    user.username.toLowerCase() &&
                existing.tagline.toLowerCase() == user.tagline.toLowerCase(),
          );
        });

        await _saveDodgeListToLocalStorage(); // ✅ Update local storage

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

  Future<void> syncDodgeListWithLeaderboard() async {
    print("🔄 Syncing Dodge List with Leaderboard...");

    // ✅ Load Dodge List from Local Storage
    final prefs = await SharedPreferences.getInstance();
    String? storedList = prefs.getString("dodge_list");

    if (storedList == null) {
      print("❌ No stored Dodge List found.");
      return;
    }

    List<dynamic> jsonData = jsonDecode(storedList);
    List<LeaderboardModel> localDodgeList =
        jsonData.map((e) => LeaderboardModel.fromJson(e)).toList();

    // ✅ Fetch Latest Leaderboard Data from Firestore
    List<LeaderboardModel> latestLeaderboard =
        await userRepository.firestoreGetLeaderboard();

    bool isUpdated = false;

    for (var dodgeUser in localDodgeList) {
      // 🔹 Find the user in the latest leaderboard
      var leaderboardUser = latestLeaderboard.firstWhereOrNull(
        (user) =>
            user.username.toLowerCase() == dodgeUser.username.toLowerCase() &&
            user.tagline.toLowerCase() == dodgeUser.tagline.toLowerCase(),
      );

      if (leaderboardUser != null) {
        // 🔍 Check if report counts have increased
        if (leaderboardUser.cheaterReports > dodgeUser.cheaterReports ||
            leaderboardUser.toxicityReports > dodgeUser.toxicityReports) {
          print(
              "⚠️ Updated Reports for ${dodgeUser.username}#${dodgeUser.tagline}");

          // 🔄 Update the Dodge List user with new report counts
          dodgeUser.cheaterReports = leaderboardUser.cheaterReports;
          dodgeUser.toxicityReports = leaderboardUser.toxicityReports;
          isUpdated = true;
        }
      }
    }

    if (isUpdated) {
      print("✅ Dodge List Updated with Latest Reports!");

      // ✅ Save Updated Dodge List to Local Storage
      List<Map<String, dynamic>> updatedJson =
          localDodgeList.map((user) => user.toJson()).toList();
      await prefs.setString("dodge_list", jsonEncode(updatedJson));

      // ✅ Refresh Dodge List UI
      if (dodgeListKey.currentState != null) {
        dodgeListKey.currentState!._loadDodgeList();
      }
    } else {
      print("✅ Dodge List is Already Up-To-Date.");
    }
  }
}
