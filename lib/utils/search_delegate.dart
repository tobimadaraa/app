import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class MySearchDelegate extends SearchDelegate {
  final List<LeaderboardModel> leaderboard;
  final LeaderboardType leaderboardType;
  MySearchDelegate(this.leaderboard, this.leaderboardType);

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
    // Filter the leaderboard based on the query
    final matchQuery = leaderboard.where((user) {
      final fullName = '${user.username}#${user.tagline}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    // Display "no results" message if the filtered list is empty
    if (matchQuery.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    // Build the filtered list of results
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final result = matchQuery[index];

        return ListTile(
          title: Text('${result.username}#${result.tagline}'),
          onTap: () {
            // Increment page views before navigating
            Get.find<UserRepository>().incrementPageViews(
              result.username,
              result.tagline,
            );

            // Navigate to the user detail page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(
                  user: result,
                  leaderboardType: leaderboardType,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggest matching results as the user types
    final matchQuery = leaderboard.where((user) {
      final fullName = '${user.username}#${user.tagline}'.toLowerCase();
      return fullName.startsWith(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final result = matchQuery[index];

        return ListTile(
          title: Text('${result.username}#${result.tagline}'),
          onTap: () {
            // Increment page views before navigating
            Get.find<UserRepository>().incrementPageViews(
              result.username,
              result.tagline,
            );

            // Navigate to the user detail page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailPage(
                  user: result,
                  leaderboardType: leaderboardType,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
