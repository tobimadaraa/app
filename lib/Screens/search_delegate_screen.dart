import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/Screens/user_detail_screen.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/repository/user_repository.dart';

class CustomSearchPage extends StatefulWidget {
  final LeaderboardType leaderboardType;
  const CustomSearchPage({super.key, required this.leaderboardType});

  @override
  _CustomSearchPageState createState() => _CustomSearchPageState();
}

class _CustomSearchPageState extends State<CustomSearchPage> {
  String query = '';
  final TextEditingController _controller = TextEditingController();

  // _performSearch replicates your original FirestoreSearchDelegate logic.
  Future<List<LeaderboardModel>> _performSearch(String queryText) {
    if (widget.leaderboardType == LeaderboardType.ranked) {
      // Full leaderboard search (15k users)
      return Get.find<UserRepository>().searchPlayersInBatches(queryText);
    } else {
      // Custom "Users" leaderboard search (for cheater, toxicity, honours)
      return Get.find<UserRepository>().searchUsers(queryText.toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141429),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141429),
        toolbarHeight: 60,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 35,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // Remove Center so the TextField can take full width.
        title: Padding(
          padding: const EdgeInsets.only(right: 12), // Adjust as needed
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                // Remove default icon spacing by constraining it
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                // Wrap the icon in Padding to set its left spacing
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 0),
                  child: Icon(Icons.search, size: 20, color: Colors.grey),
                ),
                // contentPadding only affects the text area; leave out left/right so text sits close to the icon
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: 'Search for user',
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
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<LeaderboardModel>>(
        future: _performSearch(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there's no data or the returned list is empty:
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                query.isEmpty ? 'No suggestions' : 'No results found',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final results = snapshot.data!;
          return ListView.separated(
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final suggestion = results[index];
              return ListTile(
                title: Text(
                  '${suggestion.gameName}#${suggestion.tagLine}',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final fullUser = await Get.find<UserRepository>()
                      .getFullUserData(suggestion.gameName, suggestion.tagLine);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(
                        user: fullUser ?? suggestion,
                        leaderboardType: widget.leaderboardType,
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
}
