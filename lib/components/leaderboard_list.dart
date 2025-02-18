import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/lead_card.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/report_level_helper.dart';

class LeaderboardList extends StatelessWidget {
  final Future<List<LeaderboardModel>> leaderboardFuture;
  final LeaderboardType selectedLeaderboard;

  const LeaderboardList({
    super.key,
    required this.leaderboardFuture,
    required this.selectedLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    print(
        "LeaderboardList.build() is running with selectedLeaderboard: $selectedLeaderboard");

    return FutureBuilder<List<LeaderboardModel>>(
      future: leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("DEBUG: Waiting for leaderboard data...");
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("ERROR: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print("DEBUG: No reports found.");
          return const Center(child: Text("No reports found"));
        }

        final List<LeaderboardModel> leaderboard = List.from(snapshot.data!);

// ✅ **Step 3: Filter out users who shouldn't be in a leaderboard*

// 🔥 **Step 4: Sorting logic based on leaderboard type**
        // leaderboard.sort((a, b) {
        //   if (selectedLeaderboard == LeaderboardType.cheater) {
        //     return b.cheaterReports.compareTo(a.cheaterReports);
        //   } else if (selectedLeaderboard == LeaderboardType.toxicity) {
        //     return b.toxicityReports.compareTo(a.toxicityReports);
        //   } else if (selectedLeaderboard == LeaderboardType.honour) {
        //     return b.honourReports.compareTo(a.honourReports);
        //   } else if (selectedLeaderboard == LeaderboardType.ranked) {
        //     return a.leaderboardRank.compareTo(b.leaderboardRank);
        //   } else {
        //     return 0;
        //   }
        // });

        return ListView.builder(
          key: ValueKey(
              selectedLeaderboard), // 🔥 Force UI Refresh when switching
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final model = leaderboard[index];
            final leaderboardRank = index + 1;
            if (selectedLeaderboard == LeaderboardType.ranked) {
              print(
                  "DEBUG: LeaderboardRank: $leaderboardRank, Player: ${model.gameName}, Rating: ${model.rankedRating}, Wins: ${model.numberOfWins}");
            }

            // ✅ **Check if the user is "famous" (lots of page views)**
            bool isFamous = model.pageViews >= 20000;

            // ✅ **Fix Background Color Logic**
            final backgroundColor = selectedLeaderboard ==
                    LeaderboardType.cheater
                ? (isFamous
                    ? ReportLevelHelper.getCheaterLevelColorRatio(
                        model.cheaterReports, model.pageViews)
                    : ReportLevelHelper.getCheaterLevelColor(
                        model.cheaterReports))
                : selectedLeaderboard == LeaderboardType.toxicity
                    ? (isFamous
                        ? ReportLevelHelper.getToxicityLevelColorRatio(
                            model.toxicityReports, model.pageViews)
                        : ReportLevelHelper.getToxicityLevelColor(
                            model.toxicityReports))
                    : selectedLeaderboard == LeaderboardType.honour
                        ? Colors.purple.shade400 // 🔥 Custom color for Honours
                        : Colors.green; // Default color for Ranked leaderboard

            // ✅ **Fix Report Label**
            final reportLabel = selectedLeaderboard == LeaderboardType.cheater
                ? 'Cheater Reports'
                : selectedLeaderboard == LeaderboardType.toxicity
                    ? 'Toxicity Reports'
                    : selectedLeaderboard == LeaderboardType.honour
                        ? 'Honour Reports' // 🔥 New Honour reports label
                        : 'Ranked Stats';

            return LeadCard(
              key: ValueKey(model.gameName),
              text: leaderboardRank.toString(),
              leaderboardname:
                  '${model.gameName.toLowerCase()}#${model.tagLine.toLowerCase()}',
              reportLabel: reportLabel,
              rating: selectedLeaderboard == LeaderboardType.ranked
                  ? (model.rankedRating != null
                      ? model.rankedRating.toString()
                      : "N/A")
                  : null,
              numberOfWins: selectedLeaderboard == LeaderboardType.ranked
                  ? (model.numberOfWins != null
                      ? model.numberOfWins.toString()
                      : "N/A")
                  : null,
              cheaterReports: selectedLeaderboard == LeaderboardType.cheater
                  ? model.cheaterReports.toString()
                  : "",
              toxicityReports: selectedLeaderboard == LeaderboardType.toxicity
                  ? model.toxicityReports.toString()
                  : "",
              honourReports: selectedLeaderboard == LeaderboardType.honour
                  ? model.honourReports.toString()
                  : "",
              backgroundColor: backgroundColor,
              isFamous: isFamous,
              lastReported: selectedLeaderboard == LeaderboardType.cheater
                  ? (model.lastCheaterReported.isNotEmpty
                      ? model.lastCheaterReported
                      : ["No reports yet"])
                  : selectedLeaderboard == LeaderboardType.toxicity
                      ? (model.lastToxicityReported.isNotEmpty
                          ? model.lastToxicityReported
                          : ["No reports yet"])
                      : selectedLeaderboard == LeaderboardType.honour
                          ? (model.lastHonourReported.isNotEmpty
                              ? model.lastHonourReported
                              : ["No reports yet"])
                          : [],
            );
          },
        );
      },
    );
  }
}
