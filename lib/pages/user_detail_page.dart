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
        title: Text('${user.gameName}#${user.tagLine}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Colors.grey.withOpacity(0.2), // 20% opaque grey
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHonours)
              // ONLY show honours details for honours tabs:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Honours:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Times Honoured: ${user.honourReports}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Time Honoured:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  user.lastHonourReported.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.lastHonourReported.map((timestamp) {
                            String formattedDate =
                                DateFormatter.formatDate(timestamp);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        )
                      : const Text(
                          'No honours yet.',
                          style: TextStyle(fontSize: 16),
                        ),
                ],
              )
            else if (!isRanked)
              // For non-ranked non-honours (e.g., cheater/toxic types)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cheater Reports: ${user.cheaterReports}\nToxicity Reports: ${user.toxicityReports}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last Cheater Reported Times:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  user.lastCheaterReported.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.lastCheaterReported.map((timestamp) {
                            String formattedDate =
                                DateFormatter.formatDate(timestamp);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        )
                      : const Text(
                          'No cheater reports yet.',
                          style: TextStyle(fontSize: 16),
                        ),
                  const SizedBox(height: 24),
                  const Text(
                    'Last Toxicity Reported Times:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  user.lastToxicityReported.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.lastToxicityReported.map((timestamp) {
                            String formattedDate =
                                DateFormatter.formatDate(timestamp);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        )
                      : const Text(
                          'No toxicity reports yet.',
                          style: TextStyle(fontSize: 16),
                        ),
                ],
              )
            else
              // For ranked leaderboards:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.rankedRating}rr ',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${user.numberOfWins} games won',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
