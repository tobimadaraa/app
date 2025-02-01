// lib/Screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/input_field.dart';
import 'package:flutter_application_2/components/leaderboard_list.dart';
import 'package:flutter_application_2/pages/buttons/report_button.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/search_delegate.dart';
import 'package:flutter_application_2/utils/validators.dart';
import 'package:get/get.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});
  static const Color myCustomColor = Color(0xFF808080);

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  List<LeaderboardModel> leaderboardList = []; // Full list
  late Future<List<LeaderboardModel>> leaderboardFuture;

  String newUserId = '';
  String newTagLine = '';
  String? _tagLineError;
  String? _usernameError;

  // Toggle to switch leaderboard types
  bool showToxicityLeaderboard = false;

  @override
  void initState() {
    super.initState();
    leaderboardFuture = Get.find<UserRepository>().getLeaderboard().then((
      data,
    ) {
      setState(() {
        leaderboardList = data; // Store the full list
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
        title: Column(
          children: const [
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
          // Input Fields and Report Button (unchanged)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputField(
              labelText: 'Enter Riot ID',
              hintText: 'e.g. your username',
              errorText: _usernameError,
              onChanged: (value) {
                setState(() {
                  newUserId = value;
                  _usernameError = Validator.validateUsername(value);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputField(
              labelText: 'Enter Tagline',
              hintText: 'e.g. NA1 (max 6 letters/numbers)',
              errorText: _tagLineError,
              onChanged: (value) {
                setState(() {
                  newTagLine = value;
                  _tagLineError = Validator.validateTagline(value);
                });
              },
            ),
          ),
          ReportButton(
            newUserId: newUserId,
            newTagLine: newTagLine,
            onSuccess: () async {
              setState(() {
                leaderboardFuture = Get.find<UserRepository>()
                    .getLeaderboard()
                    .then((data) {
                      setState(() {
                        leaderboardList = data;
                      });
                      return data;
                    });
              });
            },
            buttonText: reportButtonText,
            isToxicity: showToxicityLeaderboard,
          ),
          // Toggle Button Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showToxicityLeaderboard = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        showToxicityLeaderboard ? Colors.grey : Colors.blue,
                  ),
                  child: const Text('Cheater Leaderboard'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showToxicityLeaderboard = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        showToxicityLeaderboard ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Toxicity Leaderboard'),
                ),
              ],
            ),
          ),
          // Leaderboard List
          Expanded(
            child: LeaderboardList(
              leaderboardFuture: leaderboardFuture,
              showToxicity: showToxicityLeaderboard, // pass the toggle
            ),
          ),
        ],
      ),
    );
  }
}
