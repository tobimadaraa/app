import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/utils/date_formatter.dart';

class UserDetailPage extends StatelessWidget {
  final LeaderboardModel user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Use SingleChildScrollView to allow the content to scroll if it gets long.
    return Scaffold(
      appBar: AppBar(title: Text('${user.username}#${user.tagline}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the report counts
            Text(
              'Cheater Reports: ${user.cheaterReports}\nToxicity Reports: ${user.toxicityReported}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Section for Cheater Report Timestamps
            const Text(
              'Last Cheater Reported Times:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            user.lastCheaterReported.isNotEmpty
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      user.lastCheaterReported.map((timestamp) {
                        String formattedDate = DateFormatter.formatDate(
                          timestamp,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
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
            // Section for Toxicity Report Timestamps
            const Text(
              'Last Toxicity Reported Times:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            user.lastToxicityReported.isNotEmpty
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      user.lastToxicityReported.map((timestamp) {
                        String formattedDate = DateFormatter.formatDate(
                          timestamp,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
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
        ),
      ),
    );
  }
}
