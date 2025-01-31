// user_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class UserDetailPage extends StatelessWidget {
  final LeaderboardModel user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user.username}#${user.tagline}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: ${user.username}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tagline: ${user.tagline}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Text(
              'Times Reported: ${user.timesReported}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text('Last Reported:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Expanded(
              child:
                  user.lastReported.isNotEmpty
                      ? ListView.builder(
                        itemCount: user.lastReported.length,
                        itemBuilder: (context, index) {
                          return Text(
                            user.lastReported[index],
                            style: TextStyle(fontSize: 16),
                          );
                        },
                      )
                      : Text('No reports yet.', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
