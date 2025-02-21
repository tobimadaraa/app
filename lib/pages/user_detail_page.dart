import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/date_formatter.dart';

class UserDetailPage extends StatelessWidget {
  final LeaderboardModel user;
  final LeaderboardType leaderboardType; // e.g. ranked, honours, etc.

  const UserDetailPage({
    super.key,
    required this.user,
    required this.leaderboardType,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRanked = leaderboardType == LeaderboardType.ranked;
    final bool isHonours = leaderboardType == LeaderboardType.honour;

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
            if (isHonours)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Honours:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Times Honoured: ${user.honourReports}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  /// ✅ **Expandable Last Reported Section**
                  ExpansionTile(
                    title: const Text(
                      "View Last Honours Reports",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    children: user.lastHonourReported.isNotEmpty
                        ? user.lastHonourReported.map((timestamp) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 16.0),
                              child: Text(
                                DateFormatter.formatDate(timestamp),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList()
                        : [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text("No honours yet.",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                  ),
                ],
              )
            else if (!isRanked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cheater Reports: ${user.cheaterReports}  |  Toxicity Reports: ${user.toxicityReports}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  /// ✅ **Expandable Last Cheater Reports**
                  ExpansionTile(
                    title: const Text(
                      "View Last Cheater Reports",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    children: user.lastCheaterReported.isNotEmpty
                        ? user.lastCheaterReported.map((timestamp) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 16.0),
                              child: Text(
                                DateFormatter.formatDate(timestamp),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList()
                        : [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text("No cheater reports yet.",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                  ),

                  /// ✅ **Expandable Last Toxicity Reports**
                  ExpansionTile(
                    title: const Text(
                      "View Last Toxicity Reports",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    children: user.lastToxicityReported.isNotEmpty
                        ? user.lastToxicityReported.map((timestamp) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 16.0),
                              child: Text(
                                DateFormatter.formatDate(timestamp),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList()
                        : [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text("No toxicity reports yet.",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                  ),
                ],
              )
            else
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
