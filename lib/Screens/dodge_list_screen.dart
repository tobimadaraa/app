// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/dodge_list_view.dart';
import 'package:flutter_application_2/components/dodge_list_input_fields.dart';
import 'package:flutter_application_2/components/user_controller.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:flutter_application_2/shared/classes/notifiers.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
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
  final UserController userController = Get.find<UserController>();
  String? usernameError;
  String? tagLineError;
  String newUserId = "";
  String newTagLine = "";
  bool isSearching = false; // Controls whether we're in "search mode"
  TextEditingController searchController = TextEditingController();
  List<LeaderboardModel> filteredDodgeList = []; // Holds the filtered results
  @override
  void initState() {
    super.initState();
    _loadDodgeList();
    syncDodgeListWithLeaderboard();
    print("🟡 DodgeListScreen: Listening for global update events...");
    dodgeListEventNotifier.addListener(_refreshDodgeListOnEvent);
  }

  @override
  void dispose() {
    dodgeListEventNotifier.removeListener(_refreshDodgeListOnEvent);
    super.dispose();
  }

  /// 🔄 Requeries Firestore and updates the cache when triggered
  void _refreshDodgeListOnEvent() {
    print("🔄 DodgeListScreen: Requerying Firestore due to event...");
    syncDodgeListWithLeaderboard(); // 🔄 Refresh the data from Firestore
  }

  Future<void> _loadDodgeList() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedList = prefs.getString("dodge_list");

    if (storedList != null) {
      List<dynamic> jsonData = jsonDecode(storedList);
      setState(() {
        dodgeList = jsonData.map((e) => LeaderboardModel.fromJson(e)).toList();
        // ➡️ Also copy dodgeList into filteredDodgeList initially
        filteredDodgeList = List.from(dodgeList);
      });
      print("✅ Loaded Dodge List from cache.");
    } else {
      print("❌ No cached Dodge List found, querying Firestore...");
    }
  }

  void _filterDodgeList(String query) {
    setState(() {
      // For premium users, search the entire list.
      // For non-premium, only search through the first 5 users.
      List<LeaderboardModel> sourceList = userController.isPremium.value
          ? dodgeList
          : (dodgeList.length > 5 ? dodgeList.sublist(0, 5) : dodgeList);

      if (query.isEmpty) {
        filteredDodgeList = List.from(sourceList);
      } else {
        final lowerQuery = query.toLowerCase();
        filteredDodgeList = sourceList.where((user) {
          return user.gameName.toLowerCase().contains(lowerQuery) ||
              user.tagLine.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  Future<void> _saveDodgeListToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonData =
        dodgeList.map((user) => user.toJson()).toList();

    String jsonString = jsonEncode(jsonData);
    await prefs.setString("dodge_list", jsonString);

    print("🟢 Dodge List cached successfully!");
  }

  Future<void> _addUserToDodgeList() async {
    try {
      // If the user is non-premium and the dodge list already has 5 users, do not add.
      if (!userController.isPremium.value && dodgeList.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Non-premium users can only add 5 users to the Dodge List"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        return; // Stop execution if the limit is reached.
      }

      // First, check in Firestore Users collection
      List<LeaderboardModel> data =
          await userRepository.firestoreGetLeaderboard();

      LeaderboardModel? userFound = data.firstWhere(
        (user) =>
            user.gameName.toLowerCase() == newUserId.toLowerCase() &&
            user.tagLine.toLowerCase() == newTagLine.toLowerCase(),
        orElse: () => LeaderboardModel(
            leaderboardRank: -1,
            gameName: "",
            tagLine: "",
            cheaterReports: 0,
            toxicityReports: 0,
            honourReports: 0,
            pageViews: 0,
            lastCheaterReported: [],
            lastToxicityReported: [],
            lastHonourReported: [],
            iconIndex: 0),
      );

      // Check if user already exists BEFORE ADDING
      bool alreadyExists = dodgeList.any((user) =>
          user.gameName.toLowerCase() == newUserId.toLowerCase() &&
          user.tagLine.toLowerCase() == newTagLine.toLowerCase());

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("User is already in Dodge List"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        return;
      }

      // If the user is found in Firestore
      if (userFound.gameName.isNotEmpty) {
        dodgeList.add(userFound);
        await _saveDodgeListToLocalStorage();
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("User added to Dodge List"),
            backgroundColor: CustomColours.buttoncolor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        return;
      }

      // If the user is not found in Firestore, check in the custom leaderboard batches
      LeaderboardModel? userFromBatches = await userRepository
          .checkFirebaseStoredLeaderboard(newUserId, newTagLine);

      if (userFromBatches != null) {
        // User found in the custom leaderboard
        dodgeList.add(userFromBatches);
        await _saveDodgeListToLocalStorage();
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("User added to Dodge List"),
            backgroundColor: CustomColours.buttoncolor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      } else {
        // User not found in Firestore or custom leaderboards
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("User not found in leaderboard"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error fetching user"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
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
                  "Are you sure you want to remove ${user.gameName}#${user.tagLine} from your Dodge List?"),
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
                existing.gameName.toLowerCase() ==
                    user.gameName.toLowerCase() &&
                existing.tagLine.toLowerCase() == user.tagLine.toLowerCase(),
          );
        });

        await _saveDodgeListToLocalStorage(); // ✅ Update local storage

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "${user.gameName}#${user.tagLine} removed from Dodge List"),
            backgroundColor: const Color(0xFFFF6347),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
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
    final bool isPremium = userController.isPremium.value;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                onChanged: _filterDodgeList,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search Riot ID or Tagline...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "Dodgelist",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Kanit',
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
        // centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  _filterDodgeList("");
                }
              });
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xFF141429)),
          Positioned(
            top: -22, // Matches Figma position
            left: 312, // Matches Figma position
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFA54CFF).withOpacity(0.6),
                    blurRadius: 197, // Softer glow effect
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -22, // Matches Figma position
            left: -13, // Matches Figma position
            child: Container(
              width: 110, // Slightly smaller than the right glow
              height: 110,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color:
                        Color(0xFF37D5F8).withOpacity(0.6), // Light Blue Glow
                    blurRadius: 193, // Matches requested blur
                    spreadRadius: 40, // Similar spread for balanced effect
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
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
                SizedBox(height: 16),
                Expanded(
                  child: DodgeListView(
                    dodgeList: isSearching ? filteredDodgeList : dodgeList,
                    onRemoveUser: _removeUserFromDodgeList,
                    isPremium: isPremium,
                    showPaywall: !isSearching,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔒 Lock Paywall Widget (Appears Inside the List)
// s

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
          user.gameName.toLowerCase() == dodgeUser.gameName.toLowerCase() &&
          user.tagLine.toLowerCase() == dodgeUser.tagLine.toLowerCase(),
    );

    if (leaderboardUser != null) {
      // 🔍 Check if report counts have increased
      if (leaderboardUser.cheaterReports > dodgeUser.cheaterReports ||
          leaderboardUser.toxicityReports > dodgeUser.toxicityReports) {
        print(
            "⚠️ Updated Reports for ${dodgeUser.gameName}#${dodgeUser.tagLine}");

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
