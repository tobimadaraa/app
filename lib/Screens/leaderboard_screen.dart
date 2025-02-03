import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';

import 'package:flutter_application_2/components/leaderboard_input_fields.dart';
import 'package:flutter_application_2/components/leaderboard_list.dart';
import 'package:flutter_application_2/components/leaderboard_toggle.dart';
import 'package:flutter_application_2/pages/buttons/report_button.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/search_delegate.dart';
import 'package:flutter_application_2/utils/validators.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final UserRepository userRepository = Get.find<UserRepository>();

  List<LeaderboardModel> leaderboardList = [];
  late Future<List<LeaderboardModel>> leaderboardFuture;

  // String? _tagLineError;
  // String? _usernameError;
  // String newUserId = "";
  // String newTagLine = "";

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    leaderboardFuture = userRepository.getLeaderboard().then((data) {
      setState(() {
        leaderboardList = data;
      });
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportButtonText =
        showToxicityLeaderboard ? 'Report Toxic' : 'Report Cheater';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/homepage');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(leaderboardList),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: const Column(
          children: [
            Text("Valorant Cheater", style: TextStyle(fontSize: 15)),
            SizedBox(height: 8),
            Text(
              'Leaderboard',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue[200],
      body: Column(
        children: [
          // Input Fields
          LeaderboardInputFields(
            usernameError: globalUsernameError,
            taglineError: globalTagLineError,
            onUsernameChanged: (value) {
              setState(() {
                newUserId = value;
                globalUsernameError = Validator.validateUsername(value);
              });
            },
            onTaglineChanged: (value) {
              setState(() {
                newTagLine = value;
                globalTagLineError = Validator.validateTagline(value);
              });
            },
          ),

          // Report Button
          ReportButton(
            newUserId: newUserId,
            newTagLine: newTagLine,
            onSuccess: _loadLeaderboard,
            buttonText: reportButtonText,
            isToxicity: showToxicityLeaderboard,
          ),

          // Toggle Buttons (Separated into LeaderboardToggle)
          LeaderboardToggle(
            showToxicityLeaderboard: showToxicityLeaderboard,
            onToggleCheater:
                () => setState(() => showToxicityLeaderboard = false),
            onToggleToxic: () => setState(() => showToxicityLeaderboard = true),
          ),

          // Leaderboard List
          Expanded(
            child: LeaderboardList(
              leaderboardFuture: leaderboardFuture,
              showToxicity: showToxicityLeaderboard,
            ),
          ),
        ],
      ),
    );
  }
}
