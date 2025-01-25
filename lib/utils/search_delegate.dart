import 'package:flutter/material.dart';

class MySearchDelegate extends SearchDelegate {
  final List<String> searchTerms;
  MySearchDelegate(this.searchTerms);

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
    List<String> matchQuery = [];
    for (var usernames in searchTerms) {
      if (usernames.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(usernames);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(title: Text(result));
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var usernames in searchTerms) {
      if (usernames.toLowerCase().startsWith(query.toLowerCase())) {
        matchQuery.add(usernames);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(title: Text(result));
      },
    );
  }
}
