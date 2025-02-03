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
          return const Center(child: Text("No reports found"));
        }

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

            final reportLabel =
                showToxicity ? 'Toxicity Reports' : 'Cheater Reports';

            // Handle last reported messages
            // String lastReportedText;
            // if (showToxicity) {
            //   lastReportedText =
            //       model.lastToxicityReported.isNotEmpty
            //           ? model.lastToxicityReported.last
            //           : "Hasn't been reported here yet";
            // } else {
            //   lastReportedText =
            //       model.lastCheaterReported.isNotEmpty
            //           ? model.lastCheaterReported.last
            //           : "Hasn't been reported here yet";
            // }

            return LeadCard(
              text: rank.toString(), // Rank number
              leaderboardname:
                  '${model.username.toLowerCase()}#${model.tagline.toLowerCase()}',
              reportLabel: reportLabel,
              cheaterReports:
                  showToxicity
                      ? model.toxicityReported.toString()
                      : model.cheaterReports.toString(),
              toxicityReports: model.toxicityReported.toString(), // If needed
              backgroundColor: backgroundColor,
              isFamous: isFamous,
              lastReported:
                  showToxicity
                      ? (model.lastToxicityReported.isNotEmpty
                          ? model.lastToxicityReported
                          : [
                            "Hasn't been reported here yet",
                          ]) // ✅ Pass full list or default message
                      : (model.lastCheaterReported.isNotEmpty
                          ? model.lastCheaterReported
                          : [
                            "Hasn't been reported here yet",
                          ]), // ✅ Pass full list or default message  // Updated last reported field
            );
          },
        );
      },
    );
  }
}
