import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';
import 'package:flutter_application_2/shared/classes/notifiers.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/shared/helperfile.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/components/leaderboard_input_fields.dart';
import 'package:flutter_application_2/components/leaderboard_toggle.dart';
import 'package:flutter_application_2/pages/buttons/report_button.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/repository/valorant_api.dart';
import 'package:flutter_application_2/utils/search_delegate.dart';
import 'package:flutter_application_2/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({
    super.key,
  });

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final RiotApiService riotApiService = RiotApiService();
  final UserRepository userRepository = Get.find<UserRepository>();

  final ScrollController _scrollController = ScrollController();
  final List<LeaderboardModel> _loadedUsers = []; // List to store fetched users
  bool _isLoadingMore = false; // Prevent duplicate fetches
  int _currentStartIndex = 0; // Tracks where pagination starts
  final int _pageSize = 50; // How many users to fetch per page
  bool _hasMoreData = true; // Tracks if there are more players to fetch

  LeaderboardType selectedLeaderboard = LeaderboardType.ranked;
  String newUserId = "";
  String newTagLine = "";
  String? usernameError;
  String? taglineError;
  // bool _isReportingUser = false;
  @override
  void initState() {
    super.initState();
    _initializeLeaderboardScreen();
    _scrollController.addListener(_onScroll);
    // _loadLeaderboard();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeLeaderboardScreen() async {
    setState(() {
      _loadedUsers.clear(); // Clear any stale data
      _currentStartIndex = 0;
      _hasMoreData = true;
    });
    await userRepository.loadFullLeaderboard();
    _scrollController.addListener(_onScroll);
    await _loadLeaderboard(); // Load the appropriate leaderboard
  }

  /// **🔥 Load More Users with Pagination**
  Future<void> _loadLeaderboard({bool loadMore = false}) async {
    if (_isLoadingMore || (!_hasMoreData && loadMore)) return;
    if (!loadMore) {
      // Reset pagination and clear data for a new leaderboard type
      setState(() {
        _loadedUsers.clear();
        _currentStartIndex = 0;
        _hasMoreData = true;
      });
    }

    _isLoadingMore = true; // Prevent duplicate fetches
    setState(() {});

    try {
      List<LeaderboardModel> newUsers = [];

      if (selectedLeaderboard == LeaderboardType.ranked) {
        // Fetch ranked leaderboard from Riot API
        newUsers = await riotApiService.getLeaderboard(
          startIndex: _currentStartIndex,
          size: _pageSize,
        );
      } else {
        // Fetch Firestore leaderboard
        // 🔥 New function to clear cache
        List<LeaderboardModel> allUsers =
            await userRepository.firestoreGetLeaderboard();
        // Filter and sort based on the selected leaderboard type
        if (selectedLeaderboard == LeaderboardType.cheater) {
          allUsers = allUsers
              .where((user) =>
                  user.cheaterReports > 0) // Filter only cheater reports
              .toList();
          allUsers.sort((a, b) => b.cheaterReports
              .compareTo(a.cheaterReports)); // Sort by cheater reports
        } else if (selectedLeaderboard == LeaderboardType.toxicity) {
          allUsers = allUsers
              .where((user) =>
                  user.toxicityReports > 0) // Filter only toxicity reports
              .toList();
          allUsers.sort((a, b) => b.toxicityReports
              .compareTo(a.toxicityReports)); // Sort by toxicity reports
        }

        // Paginate filtered data
        newUsers = allUsers.skip(_currentStartIndex).take(_pageSize).toList();
      }

      if (newUsers.isNotEmpty) {
        setState(() {
          _loadedUsers.addAll(newUsers);
          _currentStartIndex += newUsers.length;
          _hasMoreData = newUsers.length == _pageSize;
        });
        for (var user in newUsers) {
          final rating = user.rankedRating ?? -1; // Default to 0 if null
          final wins = user.numberOfWins ?? -1; // Default to 0 if null
          print(
              "Fetched from API: ${user.username} | Rank: ${user.leaderboardNumber} | Rating: $rating | Wins: $wins");
        }
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("❌ ERROR: Failed to load leaderboard: $e");
    } finally {
      _isLoadingMore = false;
      setState(() {});
    }
  }

  /// **🖱 Detect Bottom Scroll & Load More**
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // ✅ Triggers earlier
      _loadLeaderboard(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/homepage');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MySearchDelegate(_loadedUsers, selectedLeaderboard),
                );
              },
            ),
          ],
          backgroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          title: const Column(
            children: [
              Text("Valorant Leaderboard", style: TextStyle(fontSize: 15)),
              SizedBox(height: 8),
              Text(
                'Leaderboard',
                style: TextStyle(color: Colors.black, fontSize: 30),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.blue[200],
        body: Column(children: [
          if (selectedLeaderboard == LeaderboardType.cheater ||
              selectedLeaderboard == LeaderboardType.toxicity) ...[
            LeaderboardInputFields(
              usernameError: usernameError,
              taglineError: taglineError,
              onUsernameChanged: (value) {
                setState(() {
                  newUserId = value;
                  usernameError = Validator.validateUsername(value);
                });
              },
              onTaglineChanged: (value) {
                setState(() {
                  newTagLine = value;
                  taglineError = Validator.validateTagline(value);
                });
              },
            ),
            ReportButton(
              newUserId: newUserId,
              newTagLine: newTagLine,
              onSuccess: () async {
                setState(() {
                  _loadedUsers.clear(); // ✅ Clear old leaderboard data
                  _currentStartIndex = 0; // Reset pagination
                  _hasMoreData = true; // Allow new fetch
                });

                // 🔄 Update the stored dodge list data immediately
                // await updateDodgeListStorage(newUserId, newTagLine);
                (newUserId, newTagLine);

                // 🔔 Notify DodgeListScreen if it's open
                dodgeListEventNotifier.triggerUpdate();

                await _loadLeaderboard(); // ✅ Refresh leaderboard, but DON'T report again
              },
              buttonText: selectedLeaderboard == LeaderboardType.toxicity
                  ? 'Report for Toxicity'
                  : 'Report Cheater',
              isToxicity: selectedLeaderboard == LeaderboardType.toxicity,
            ),
          ],
          LeaderboardToggle(
            selectedLeaderboard: selectedLeaderboard,
            onSelectLeaderboard: (LeaderboardType type) {
              setState(() {
                selectedLeaderboard = type;
                _loadedUsers.clear(); // Clear the current leaderboard data
                _currentStartIndex = 0; // Reset pagination
                _hasMoreData = true; // Allow loading new data
              });
              _loadLeaderboard(); // Load the selected leaderboard
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _loadedUsers.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _loadedUsers.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                        child:
                            CircularProgressIndicator()), // ✅ Loading Spinner
                  );
                }

                final user = _loadedUsers[index];
                final bool isClickable =
                    selectedLeaderboard == LeaderboardType.cheater ||
                        selectedLeaderboard == LeaderboardType.toxicity;

                return ListTile(
                  title: Text('${user.username}#${user.tagline}'),
                  subtitle: Text(
                    selectedLeaderboard == LeaderboardType.ranked
                        ? 'Rank: ${user.leaderboardNumber} | Rating: ${user.rankedRating ?? "N/A"} | Wins: ${user.numberOfWins ?? "N/A"}'
                        : selectedLeaderboard == LeaderboardType.cheater
                            ? 'Rank: ${user.leaderboardNumber} | Cheater Reports: ${user.cheaterReports}'
                            : 'Rank: ${user.leaderboardNumber} | Toxicity Reports: ${user.toxicityReports}',
                  ),
                  onTap: isClickable
                      ? () {
                          // ✅ Navigate only if in Cheater/Toxicity leaderboard
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailPage(
                                  user: user,
                                  leaderboardType: selectedLeaderboard),
                            ),
                          );
                        }
                      : null, // ❌ Not clickable for Ranked leaderboard
                );
              },
            ),
          ),
        ]));
  }
}
