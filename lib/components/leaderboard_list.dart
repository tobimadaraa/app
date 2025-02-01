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
          // Sort based on the flag:
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

              // Determine if the user is famous (pageViews >= 20000)
              bool isFamous = model.pageViews >= 20000;

              // Determine the background color:
              // If showing toxicity leaderboard, use blue shades; if cheater, use green/yellow/red.
              // If the user is famous, you might adjust the calculation using ratio-based methods.
              final backgroundColor =
                  showToxicity
                      ? (isFamous
                          ? ReportLevelHelper.getToxicityLevelColorRatio(
                            model.toxicityReported,
                            model.pageViews,
                          )
                          : ReportLevelHelper.getToxicityLevelColor(
                            model.toxicityReported,
                          ))
                      : (isFamous
                          ? ReportLevelHelper.getCheaterLevelColorRatio(
                            model.cheaterReports,
                            model.pageViews,
                          )
                          : ReportLevelHelper.getCheaterLevelColor(
                            model.cheaterReports,
                          ));

              // Choose the appropriate report count to display.
              final displayReportCount =
                  showToxicity
                      ? model.toxicityReported.toString()
                      : model.cheaterReports.toString();

              final reportLabel =
                  showToxicity ? 'Toxicity Reports' : 'Cheater Reports';

              return LeadCard(
                text: rank.toString(),
                leaderboardname: '${model.username}#${model.tagline}',
                reportLabel: reportLabel,
                cheaterReports: displayReportCount,
                toxicityReports: model.toxicityReported.toString(),
                backgroundColor: backgroundColor,
                isFamous: isFamous,
                lastReported: model.lastReported,
              );
            },
          );
        }
      },
    );
  }
}
