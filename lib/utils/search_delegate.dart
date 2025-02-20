import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class FirestoreSearchDelegate extends SearchDelegate {
  final LeaderboardType leaderboardType;
  FirestoreSearchDelegate(this.leaderboardType);

  /// Chooses which search method to use based on the leaderboard type.
  Future<List<LeaderboardModel>> _performSearch(String queryText) {
    // For ranked leaderboards, use the existing searchPlayersInBatches method.
    if (leaderboardType == LeaderboardType.ranked) {
      return Get.find<UserRepository>().searchPlayersInBatches(queryText);
    } else {
      // For honours, cheaters, toxicity, etc. use the searchUsers method that queries the Users doc.
      return Get.find<UserRepository>().searchUsers(queryText.toLowerCase());
    }
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.black,
          size: 28,
        ),
        onPressed: () => close(context, null),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.black,
          ),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
              showSuggestions(context);
            }
          },
        ),
      ];

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<LeaderboardModel>>(
      future: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found'));
        }
        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final suggestion = results[index];
            return ListTile(
              title: Text('${suggestion.gameName}#${suggestion.tagLine}'),
              onTap: () {
                // Directly navigate to the detail page.
                close(context, suggestion);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(
                      user: suggestion,
                      leaderboardType: leaderboardType,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<LeaderboardModel>>(
      future: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No suggestions'));
        }
        final suggestions = snapshot.data!;
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              title: Text('${suggestion.gameName}#${suggestion.tagLine}'),
              onTap: () {
                close(context, suggestion);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(
                      user: suggestion,
                      leaderboardType: leaderboardType,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
