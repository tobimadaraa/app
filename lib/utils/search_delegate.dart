import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class FirestoreSearchDelegate extends SearchDelegate {
  final LeaderboardType leaderboardType;
  FirestoreSearchDelegate(this.leaderboardType);

  Future<List<LeaderboardModel>> _performSearch(String queryText) {
    if (leaderboardType == LeaderboardType.ranked) {
      return Get.find<UserRepository>().searchPlayersInBatches(queryText);
    } else {
      return Get.find<UserRepository>().searchUsers(queryText.toLowerCase());
    }
  }

  @override
  TextStyle? get searchFieldStyle => const TextStyle(color: Colors.white);
  @override // ✅ Fix: Add this to avoid the error
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141429), // ✅ Matches Leaderboard background
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff1d223c)
            .withOpacity(0.4), // ✅ Background with border effect
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // ✅ Rounded search bar
          borderSide: const BorderSide(
              color: Colors.grey, width: 1.0), // ✅ Border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: Colors.grey, width: 1.0), // ✅ Border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: Colors.white, width: 1.5), // ✅ White border when active
        ),
        hintStyle: const TextStyle(color: Colors.white), // ✅ White hint text
      ),
      scaffoldBackgroundColor: const Color(0xFF141429), // ✅ Match background
    );
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
        onPressed: () => close(context, null),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
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
    return _buildSearchContainer(
      context,
      FutureBuilder<List<LeaderboardModel>>(
        future: _performSearch(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No results found',
                    style: TextStyle(color: Colors.white)));
          }
          final results = snapshot.data!;
          return ListView.separated(
            itemCount: results.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final suggestion = results[index];
              return ListTile(
                title: Text('${suggestion.gameName}#${suggestion.tagLine}',
                    style: const TextStyle(
                        color: Colors.white)), // ✅ White text inside results
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
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchContainer(
      context,
      FutureBuilder<List<LeaderboardModel>>(
        future: _performSearch(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No suggestions',
                    style: TextStyle(color: Colors.white)));
          }
          final suggestions = snapshot.data!;
          return ListView.separated(
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey, // ✅ Divider between users
              thickness: 0.5,
              height: 1,
              indent: 10, // ✅ Shortens divider from the left
              endIndent: 10, // ✅ Shortens divider from the right
            ),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                title: Text('${suggestion.gameName}#${suggestion.tagLine}',
                    style: const TextStyle(
                        color:
                            Colors.white)), // ✅ White text inside suggestions
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
      ),
    );
  }

  Widget _buildSearchContainer(BuildContext context, Widget child) {
    return Stack(
      children: [
        // ✅ Fix Background Issue
        Container(color: const Color(0xFF141429)),

        SafeArea(child: child),
      ],
    );
  }
}
