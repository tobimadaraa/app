import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/lead_card.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/report_level_helper.dart';
// Import the enum

class LeaderboardList extends StatelessWidget {
  final Future<List<LeaderboardModel>> leaderboardFuture;
  final LeaderboardType selectedLeaderboard; // Use enum instead of boolean

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
// 🔥 Fix Sorting: Use `selectedLeaderboard`
        leaderboard.sort((a, b) {
          if (selectedLeaderboard == LeaderboardType.toxicity) {
            return b.toxicityReports.compareTo(a.toxicityReports);
          } else if (selectedLeaderboard == LeaderboardType.cheater) {
            return b.cheaterReports.compareTo(a.cheaterReports);
          } else {
            return a.leaderboardNumber.compareTo(b.leaderboardNumber);
          }
        });

        return ListView.builder(
          key: ValueKey(
              selectedLeaderboard), // 🔥 Force UI Refresh when switching
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final model = leaderboard[index];
            final rank = index + 1;
            if (selectedLeaderboard == LeaderboardType.ranked) {
              print(
                  "DEBUG: Rank: $rank, Player: ${model.username}, Rating: ${model.rankedRating}, Wins: ${model.numberOfWins}");
            }
            // ✅ DEBUG  - Verify if data is correct

            // ✅ Check if the user is "famous" (lots of page views)
            bool isFamous = model.pageViews >= 20000;

            // ✅ Fix Background Color Logic
            final backgroundColor =
                selectedLeaderboard == LeaderboardType.toxicity
                    ? (isFamous
                        ? ReportLevelHelper.getToxicityLevelColorRatio(
                            model.toxicityReports, model.pageViews)
                        : ReportLevelHelper.getToxicityLevelColor(
                            model.toxicityReports))
                    : selectedLeaderboard == LeaderboardType.cheater
                        ? (isFamous
                            ? ReportLevelHelper.getCheaterLevelColorRatio(
                                model.cheaterReports, model.pageViews)
                            : ReportLevelHelper.getCheaterLevelColor(
                                model.cheaterReports))
                        : Colors.green; // Default color for Ranked leaderboard

            // ✅ Fix Report Label
            final reportLabel = selectedLeaderboard == LeaderboardType.toxicity
                ? 'Toxicity Reports'
                : selectedLeaderboard == LeaderboardType.cheater
                    ? 'Cheater Reports'
                    : 'Ranked Stats';

            return LeadCard(
              key: ValueKey(model.username), // 🔥 Ensures individual updates
              text: rank.toString(), // Rank number

              leaderboardname:
                  '${model.username.toLowerCase()}#${model.tagline.toLowerCase()}',
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
              // ✅ Fix: Ensure no null value is passed
              cheaterReports: selectedLeaderboard == LeaderboardType.cheater
                  ? (model.cheaterReports).toString() // ✅ If null, default to 0
                  : "",

              toxicityReports: selectedLeaderboard == LeaderboardType.toxicity
                  ? model.toxicityReports.toString()
                  : "",
              backgroundColor: backgroundColor,
              isFamous: isFamous,

              lastReported: selectedLeaderboard == LeaderboardType.toxicity
                  ? (model.lastToxicityReported.isNotEmpty
                      ? model.lastToxicityReported
                      : ["No reports yet"])
                  : (model.lastCheaterReported.isNotEmpty
                      ? model.lastCheaterReported
                      : ["No reports yet"]),
            );
          },
        );
      },
    );
  }
}
