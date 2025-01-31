// my_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';

class MySearchDelegate extends SearchDelegate {
  final List<LeaderboardModel> leaderboard;

  MySearchDelegate(this.leaderboard);

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
        }
      },
    ),
  ];

  @override
  Widget buildResults(BuildContext context) {
    List<LeaderboardModel> matchQuery =
        leaderboard.where((user) {
          final fullName = '${user.username}#${user.tagline}'.toLowerCase();
          return fullName.contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text('${result.username}#${result.tagline}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(user: result),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<LeaderboardModel> matchQuery =
        leaderboard.where((user) {
          final fullName = '${user.username}#${user.tagline}'.toLowerCase();
          return fullName.startsWith(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text('${result.username}#${result.tagline}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(user: result),
              ),
            );
          },
        );
      },
    );
  }
}
