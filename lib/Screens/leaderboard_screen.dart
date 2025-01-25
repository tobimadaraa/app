// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/input_field.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/models/user_model.dart';
import 'package:flutter_application_2/components/lead_card.dart';
import 'package:flutter_application_2/components/ranking_data_card.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/utils/search_delegate.dart';
import 'package:get/get.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});
  static const Color myCustomColor = Color(0xFF808080);

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

String newUserId = '';
String newTagLine = '';

class _LeaderBoardState extends State<LeaderBoard> {
  late Future<List<LeaderboardModel>> leaderboardFuture;
  @override
  void initState() {
    super.initState();
    leaderboardFuture = Get.find<UserRepository>().getLeaderboard();
  }

  int myIndex = 0;
  int reportedValue = 0;
  List<LeaderboardModel> leaderboard = [
    LeaderboardModel(
      leaderboardNumber: 1,
      rating: 1,
      username: 'eung',
      timesReported: 12,
      lastReported: DateTime.now(),
    ),
    LeaderboardModel(
      leaderboardNumber: 2,
      rating: 5,
      username: 'un',
      timesReported: 52,
      lastReported: DateTime.now(),
    ),
    LeaderboardModel(
      leaderboardNumber: 3,
      rating: 6,
      username: 'roma',
      timesReported: 94,
      lastReported: DateTime.now(),
    ),
  ];
  List<String> usernames = [];
  List<Widget> getLeaderboardWidgets() {
    List<Widget> list = [];
    usernames.clear();
    list.add(
      RankingDataCard(
        leaderboardnumber: 'RANK',
        text: 'RATING',
        numberofgameswon: '',
        timesReported: 'reported ',

        onPressed: () {
          print('boop');
        },
        // height: 30,
        // width: 40,
      ),
    );
    for (var model in leaderboard) {
      list.add(
        LeadCard(
          leaderboardnumber: model.leaderboardNumber.toString(),
          text: model.rating.toString(),
          leaderboardname: model.username,
          timesReported: model.timesReported.toString(),
          // gameswontext: ' games won',
          onPressed: () {
            print('Leaderboard entry pressed');
          },
          //  height: 70,
          //  width: 40,
        ),
      );
      if (model.username.isNotEmpty) {
        usernames.add(model.username);
      }
    }
    return list;
  }

  List<Widget> widgetList = [
    RankingDataCard(
      // textColor: Colors.white,
      //backgroundColor: Colors.grey,
      leaderboardnumber: 'RANK',
      text: 'RATING',
      numberofgameswon: '',
      timesReported: 'timesReported',

      onPressed: () {
        print('boop');
      },
      // height: 30,
      // width: 40,
    ),
  ];
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
                errorText: newUserId.isEmpty ? 'UserId is required' : null,
                onChanged: (value) => setState(() => newUserId = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputField(
                labelText: 'Enter Tagline',
                hintText: 'e.g. your in-game Tag',
                errorText: newTagLine.isEmpty ? 'Tag line is required' : null,
                onChanged: (value) => setState(() => newTagLine = value),
              ),
            ),
            TextButton(
              onPressed: () {
                if (newUserId.isNotEmpty && newTagLine.isNotEmpty) {
                  final user = UserModel(
                    userId: newUserId,
                    tagLine: newTagLine,
                    timesReported: reportedValue,
                    lastReported: DateTime.now(),
                  );
                  Get.find<UserRepository>().createUser(user).then((_) {
                    setState(() {
                      leaderboardFuture =
                          Get.find<UserRepository>().getLeaderboard();
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User data submitted successfully!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter both Riot ID and Tagline'),
                    ),
                  );
                }
              },
              child: Text("Report"),
            ),
            Expanded(
              child: FutureBuilder<List<LeaderboardModel>>(
                future: leaderboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No data available");
                  } else {
                    final leaderboard = snapshot.data!;
                    return ListView(
                      children:
                          leaderboard.map((model) {
                            return LeadCard(
                              leaderboardnumber:
                                  model.leaderboardNumber.toString(),
                              text: model.rating.toString(),
                              leaderboardname: model.username,
                              timesReported: model.timesReported.toString(),
                              onPressed: () {
                                print('${model.username} pressed');
                              },
                            );
                          }).toList(),
                    );
                  }
                },
              ),
            ),
            //...getLeaderboardWidgets()
          ], // Display all widgets from the list
        ),
      ),
      appBar: AppBar(
        // toolbarHeight: 120,
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/homepage');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(usernames),
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
            const Text("Leaderboard", style: TextStyle(fontSize: 15)),
            SizedBox(height: 8),
            Text(
              'Radiant',
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
