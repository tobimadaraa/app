import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/lead_card.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/utils/report_level_helper.dart';

class LeaderboardList extends StatelessWidget {
  final Future<List<LeaderboardModel>> leaderboardFuture;
  final bool showToxicity; // Determines which leaderboard to show

  const LeaderboardList({
    super.key,
    required this.leaderboardFuture,
    required this.showToxicity,
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
          return const Center(child: Text("No data available"));
        } else {
          final leaderboard = snapshot.data!;
          // Sort the leaderboard based on the selected leaderboard type:
          leaderboard.sort(
            (a, b) =>
                showToxicity
                    ? b.toxicityReported.compareTo(a.toxicityReported)
                    : b.cheaterReports.compareTo(a.cheaterReports),
          );

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final model = leaderboard[index];
              final rank = index + 1; // Rank starts at 1

              // Choose the appropriate report count for display.
              // For cheater leaderboard, use cheaterReports; for toxicity, use toxicityReported.
              final displayReportCount =
                  showToxicity
                      ? model.toxicityReported.toString()
                      : model.cheaterReports.toString();

              // Determine the label:
              final reportLabel =
                  showToxicity ? 'Toxicity Reports' : 'Cheater Reports';

              // Determine the background color:
              final backgroundColor =
                  showToxicity
                      ? ReportLevelHelper.getToxicityLevelColor(
                        model.toxicityReported,
                      )
                      : ReportLevelHelper.getCheaterLevelColor(
                        model.cheaterReports,
                      );

              return LeadCard(
                text: rank.toString(),
                leaderboardname: '${model.username}#${model.tagline}',
                reportLabel: reportLabel,
                cheaterReports: displayReportCount,
                toxicityReports: model.toxicityReported.toString(),
                backgroundColor: backgroundColor,
                lastReported: model.lastReported,
              );
            },
          );
        }
      },
    );
  }
}
