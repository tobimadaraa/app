// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/Screens/user_detail_screen.dart';
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
  Widget buildSearchField(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: query),
      autofocus: true,
      style: searchFieldStyle,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xff1d223c).withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      onChanged: (value) {
        query = value;
        showSuggestions(context);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141429),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff1d223c).withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.white),
      ),
      scaffoldBackgroundColor: const Color(0xFF141429),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
        onPressed: () => close(context, null),
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return []; // No trailing actions
  }

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
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final suggestion = results[index];
              return ListTile(
                title: Text('${suggestion.gameName}#${suggestion.tagLine}',
                    style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  close(context, suggestion);
                  final fullUser = await Get.find<UserRepository>()
                      .getFullUserData(suggestion.gameName, suggestion.tagLine);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(
                          user: fullUser ?? suggestion,
                          leaderboardType: leaderboardType,
                        ),
                      ),
                    );
                  });
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
              color: Colors.grey,
              thickness: 0.5,
              height: 1,
              indent: 14,
              endIndent: 14,
            ),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text('${suggestion.gameName}#${suggestion.tagLine}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onTap: () async {
                  // First, fetch the full user data.
                  final fullUser = await Get.find<UserRepository>()
                      .getFullUserData(suggestion.gameName, suggestion.tagLine);
                  // Then close the search delegate.
                  close(context, suggestion);
                  // Finally, navigate to UserDetailPage.
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(
                        user: fullUser ?? suggestion,
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
        Container(color: const Color(0xFF141429)),
        SafeArea(child: child),
      ],
    );
  }
}
