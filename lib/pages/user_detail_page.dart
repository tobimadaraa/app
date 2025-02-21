import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/date_formatter.dart';

class UserDetailPage extends StatelessWidget {
  final LeaderboardModel user;
  final LeaderboardType leaderboardType;

  const UserDetailPage({
    super.key,
    required this.user,
    required this.leaderboardType,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRanked = leaderboardType == LeaderboardType.ranked;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${user.gameName}#${user.tagLine}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isRanked) // Show this for all NON-ranked users
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// **Cheater Reports on a New Line**
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: "Cheater Reports: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "${user.cheaterReports}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// **Toxicity Reports on a New Line**
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: "Toxicity Reports: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "${user.toxicityReports}",
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// **Honour Reports on a New Line**
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: "Honour Reports: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "${user.honourReports}",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// **Expandable Last Cheater Reports on a New Line**
                  ExpandableReportSection(
                    title: "Last Cheater Reports",
                    reports: user.lastCheaterReported,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 6),

                  /// **Expandable Last Toxicity Reports on a New Line**
                  ExpandableReportSection(
                    title: "Last Toxicity Reports",
                    reports: user.lastToxicityReported,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 6),

                  /// **Expandable Last Honour Reports on a New Line**
                  ExpandableReportSection(
                    title: "Last Honour Reports",
                    reports: user.lastHonourReported,
                    color: Colors.green,
                  ),
                ],
              )
            else
              // Ranked user section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${user.rankedRating} RR",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  Text("${user.numberOfWins} games won",
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// **Reusable Expandable Report Section**
class ExpandableReportSection extends StatefulWidget {
  final String title;
  final List<String> reports;
  final Color color;

  const ExpandableReportSection({
    super.key,
    required this.title,
    required this.reports,
    required this.color,
  });

  @override
  _ExpandableReportSectionState createState() =>
      _ExpandableReportSectionState();
}

class _ExpandableReportSectionState extends State<ExpandableReportSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Smaller rounded edges
              ),
              minimumSize: const Size(150, 35), // Smaller button
            ),
            child: Text(
              _isExpanded ? "Hide ${widget.title}" : "View ${widget.title}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: widget.reports.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widget.reports.map((timestamp) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 6.0),
                        child: Center(
                          child: Text(
                            DateFormatter.formatDate(timestamp),
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Center(
                      child: Text(
                        "No reports yet.",
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
