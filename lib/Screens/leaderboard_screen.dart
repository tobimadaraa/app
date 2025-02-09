import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';

import 'package:flutter_application_2/components/leaderboard_input_fields.dart';
import 'package:flutter_application_2/components/leaderboard_list.dart';
import 'package:flutter_application_2/components/leaderboard_toggle.dart';
import 'package:flutter_application_2/pages/buttons/report_button.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/services/valorant_api.dart';
import 'package:flutter_application_2/utils/search_delegate.dart';
import 'package:flutter_application_2/utils/validators.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final RiotApiService riotApiService = RiotApiService();
  final UserRepository userRepository =
      Get.find<UserRepository>(); // ✅ Firestore Repo

  Future<List<LeaderboardModel>>? leaderboardFuture;
  LeaderboardType selectedLeaderboard = LeaderboardType.ranked; // Default

  String newUserId = "";
  String newTagLine = "";
  String? usernameError;
  String? taglineError;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      leaderboardFuture = selectedLeaderboard == LeaderboardType.ranked
          ? riotApiService.getLeaderboard() // Riot API for Ranked
          : userRepository
              .firestoreGetLeaderboard(); // Firestore for Cheater/Toxicity
    });
  }

  @override
  Widget build(BuildContext context) {
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
                delegate: MySearchDelegate([]),
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
            Text("Valorant Leaderboard", style: TextStyle(fontSize: 15)),
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
          // **✅ Show User Input & Report Button only for Cheater/Toxicity Leaderboard**
          if (selectedLeaderboard == LeaderboardType.cheater ||
              selectedLeaderboard == LeaderboardType.toxicity) ...[
            LeaderboardInputFields(
              usernameError: usernameError,
              taglineError: taglineError,
              onUsernameChanged: (value) {
                setState(() {
                  newUserId = value;
                  usernameError = Validator.validateUsername(value);
                });
              },
              onTaglineChanged: (value) {
                setState(() {
                  newTagLine = value;
                  taglineError = Validator.validateTagline(value);
                });
              },
            ),
            ReportButton(
              newUserId: newUserId,
              newTagLine: newTagLine,
              onSuccess: _loadLeaderboard,
              buttonText: selectedLeaderboard == LeaderboardType.toxicity
                  ? 'Report for Toxicity'
                  : 'Report Cheater',
              isToxicity: selectedLeaderboard == LeaderboardType.toxicity,
            ),
          ],

          LeaderboardToggle(
            selectedLeaderboard: selectedLeaderboard,
            onSelectLeaderboard: (LeaderboardType type) {
              setState(() {
                selectedLeaderboard = type;
                _loadLeaderboard(); // 🔥 Ensure the correct leaderboard loads
              });
            },
          ),

          Expanded(
            child: LeaderboardList(
              leaderboardFuture: leaderboardFuture!,
              selectedLeaderboard: selectedLeaderboard,
            ),
          ),
        ],
      ),
    );
  }
}
