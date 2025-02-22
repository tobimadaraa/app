import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/date_formatter.dart';
import 'package:flutter/services.dart'; // ✅ Required for status bar color

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
      backgroundColor: Colors.grey[200], // 🌫 Same Grey Background
      appBar: AppBar(
        backgroundColor: Colors.grey[200], // ✅ Same as Scaffold
        elevation: 0, // ✅ Removes Shadow Effect
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // ✅ Blends Status Bar
        title: Text(
          '${user.gameName}#${user.tagLine}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
          children: [
            if (!isRanked) _buildReportCard(user) else _buildRankedStats(user),
          ],
        ),
      ),
    );
  }

  /// **📌 Report Card for Non-Ranked Players**
  Widget _buildReportCard(LeaderboardModel user) {
    return Card(
      color: Colors.white, // 🟢 White Card
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReportSection("Cheater Reports", user.cheaterReports),
            _buildReportSection("Toxicity Reports", user.toxicityReports),
            _buildReportSection("Times Honoured", user.honourReports),
            const SizedBox(height: 12),

            /// **Expandable Sections for Reports**
            _buildExpandableReport(
                "Last Cheater Reports", user.lastCheaterReported),
            _buildExpandableReport(
                "Last Toxicity Reports", user.lastToxicityReported),
            _buildExpandableReport(
                "Last Honour Reports", user.lastHonourReported),
          ],
        ),
      ),
    );
  }

  /// **📌 Ranked Stats for Players**
  Widget _buildRankedStats(LeaderboardModel user) {
    return Card(
      color: Colors.white, // 🟢 White Card
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "${user.rankedRating} RR",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "${user.numberOfWins} Games Won",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  /// **📌 Builds Each Report Line with Label & Count**
  Widget _buildReportSection(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  Colors.blue.withOpacity(0.2), // 🔵 Light Blue for consistency
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // 🔵 Blue Text for Readability
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **📌 Expandable Report Section (For Last Reports)**
  Widget _buildExpandableReport(String title, List<String> reports) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        color: Colors.white, // 🟢 White for Consistency
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          children: reports.isNotEmpty
              ? reports.map((timestamp) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 16.0),
                    child: Text(
                      DateFormatter.formatDate(timestamp),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList()
              : [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child:
                        Text("No reports yet.", style: TextStyle(fontSize: 14)),
                  ),
                ],
        ),
      ),
    );
  }
}
