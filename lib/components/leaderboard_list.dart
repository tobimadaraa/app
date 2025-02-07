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
    return FutureBuilder<List<LeaderboardModel>>(
      future: leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No reports found"));
        }

        final List<LeaderboardModel> leaderboard = List.from(snapshot.data!);

        // 🔥 Fix Sorting: Use `selectedLeaderboard` instead of `showToxicity`
        leaderboard.sort((a, b) {
          if (selectedLeaderboard == LeaderboardType.toxicity) {
            return b.toxicityReported.compareTo(a.toxicityReported);
          } else if (selectedLeaderboard == LeaderboardType.cheater) {
            return b.cheaterReports.compareTo(a.cheaterReports);
          } else {
            return a.leaderboardNumber
                .compareTo(b.leaderboardNumber); // ✅ Fix Ranked Sorting
          }
        });
        return ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final model = leaderboard[index];
            final rank = index + 1; // Rank starts at 1

            // Determine if the user is famous (pageViews >= 20000)
            bool isFamous = model.pageViews >= 20000;

            // 🔥 Fix Background Color Logic
            final backgroundColor =
                selectedLeaderboard == LeaderboardType.toxicity
                    ? (isFamous
                        ? ReportLevelHelper.getToxicityLevelColorRatio(
                            model.toxicityReported, model.pageViews)
                        : ReportLevelHelper.getToxicityLevelColor(
                            model.toxicityReported))
                    : selectedLeaderboard == LeaderboardType.cheater
                        ? (isFamous
                            ? ReportLevelHelper.getCheaterLevelColorRatio(
                                model.cheaterReports, model.pageViews)
                            : ReportLevelHelper.getCheaterLevelColor(
                                model.cheaterReports))
                        : Colors.purple; // Example color for Ranked leaderboard

            // 🔥 Fix Report Label
            final reportLabel = selectedLeaderboard == LeaderboardType.toxicity
                ? 'Toxicity Reports'
                : selectedLeaderboard == LeaderboardType.cheater
                    ? 'Cheater Reports'
                    : 'Ranked Stats';

            return LeadCard(
              text: rank.toString(), // Rank number
              leaderboardname:
                  '${model.username.toLowerCase()}#${model.tagline.toLowerCase()}',
              reportLabel: reportLabel,
              cheaterReports: model.cheaterReports.toString(),
              toxicityReports: model.toxicityReported.toString(),
              backgroundColor: backgroundColor,
              isFamous: isFamous,
              lastReported: selectedLeaderboard == LeaderboardType.toxicity
                  ? (model.lastToxicityReported.isNotEmpty
                      ? model.lastToxicityReported
                      : ["Hasn't been reported here yet"])
                  : selectedLeaderboard == LeaderboardType.cheater
                      ? (model.lastCheaterReported.isNotEmpty
                          ? model.lastCheaterReported
                          : ["Hasn't been reported here yet"])
                      : ["No data for this category"],
            );
          },
        );
      },
    );
  }
}
