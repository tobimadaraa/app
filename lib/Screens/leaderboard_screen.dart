// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/input_field.dart';
import 'package:flutter_application_2/components/leaderboard_list.dart';
import 'package:flutter_application_2/components/report_button.dart';
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

String newUserId = '';
String newTagLine = '';
String? _tagLineError;
String? _usernameError;

class _LeaderBoardState extends State<LeaderBoard> {
  List<String> usernames = [];
  List<String> taglines = [];
  List<String> leaderboardNames = [];
  late Future<List<LeaderboardModel>> leaderboardFuture;
  @override
  void initState() {
    super.initState();
    leaderboardFuture = Get.find<UserRepository>().getLeaderboard().then((
      data,
    ) {
      setState(() {
        usernames = data.map((e) => e.username).toList();
        taglines = data.map((e) => e.tagline).toList();
        leaderboardNames =
            data.map((e) => '${e.username}#${e.tagline}').toList();
      });
      return data;
    });
  }

  int reportedValue = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputField(
                labelText: 'Enter Riot ID',
                hintText: 'e.g. your username',
                errorText: _usernameError,
                //errorText: newUserId.isEmpty ? 'UserId is required' : null,
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
                errorText: _tagLineError, // ? 'Tag line is required' : null,
                onChanged: (value) {
                  setState(() {
                    newTagLine = value;
                    _tagLineError = Validator.validateTagline(
                      value,
                    ); // Update error on typing
                  });
                },
              ),
            ),
            ReportButton(
              newUserId: newUserId,
              newTagLine: newTagLine,
              onSuccess: () async {
                setState(() {
                  leaderboardFuture =
                      Get.find<UserRepository>().getLeaderboard();
                });
              },
            ),
            Expanded(
              child: LeaderboardList(leaderboardFuture: leaderboardFuture),
            ),
          ], // Display all widgets from the list
        ),
      ),
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
                delegate: MySearchDelegate(leaderboardNames),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: Column(
          children: [
            const Text("Valorant Cheater", style: TextStyle(fontSize: 15)),
            SizedBox(height: 8),
            Text(
              'Leaderboard',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue[200],
    );
    // );
  }
}
