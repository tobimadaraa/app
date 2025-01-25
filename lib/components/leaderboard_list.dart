import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/lead_card.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class LeaderboardList extends StatelessWidget {
  final Future<List<LeaderboardModel>> leaderboardFuture;

  const LeaderboardList({Key? key, required this.leaderboardFuture})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaderboardModel>>(
      future: leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available"));
        } else {
          final leaderboard = snapshot.data!;
          return ListView(
            children:
                leaderboard.map((model) {
                  return LeadCard(
                    leaderboardnumber: model.leaderboardNumber.toString(),
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
    );
  }
}
