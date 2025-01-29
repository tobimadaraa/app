import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/lead_card.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class LeaderboardList extends StatelessWidget {
  final Future<List<LeaderboardModel>> leaderboardFuture;

  const LeaderboardList({super.key, required this.leaderboardFuture});

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
          leaderboard.sort(
            (a, b) => b.timesReported.compareTo(a.timesReported),
          );
          return ListView(
            children:
                leaderboard.map((model) {
                  return LeadCard(
                    //leaderboardnumber: model.leaderboardNumber.toString(),
                    text: model.rating.toString(),
                    leaderboardname: '${model.username}#${model.tagline}',
                    timesReported: model.timesReported.toString(),
                    onPressed: () {
                      // ignore: avoid_print
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
