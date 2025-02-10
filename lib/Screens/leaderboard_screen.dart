import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/components/leaderboard_input_fields.dart';

import 'package:flutter_application_2/components/leaderboard_toggle.dart';
import 'package:flutter_application_2/pages/buttons/report_button.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:flutter_application_2/repository/valorant_api.dart';
import 'package:flutter_application_2/utils/search_delegate.dart';
import 'package:flutter_application_2/utils/validators.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  final RiotApiService riotApiService = RiotApiService();
  final UserRepository userRepository = Get.find<UserRepository>();

  final ScrollController _scrollController = ScrollController();
  List<LeaderboardModel> _loadedUsers = []; // List to store fetched users
  bool _isLoadingMore = false; // Prevent duplicate fetches
  int _currentStartIndex = 0; // Tracks where pagination starts
  final int _pageSize = 50; // How many users to fetch per page
  bool _hasMoreData = true; // Tracks if there are more players to fetch

  LeaderboardType selectedLeaderboard = LeaderboardType.ranked;
  String newUserId = "";
  String newTagLine = "";
  String? usernameError;
  String? taglineError;

  @override
  void initState() {
    super.initState();
    _initializeLeaderboardScreen();
    _scrollController.addListener(_onScroll);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeLeaderboardScreen() async {
    print("DEBUG: Initializing leaderboard screen...");
    setState(() {
      _loadedUsers.clear(); // Clear any stale data
      _currentStartIndex = 0;
      _hasMoreData = true;
    });
    await userRepository.loadFullLeaderboard();
    print("DEBUG: Full leaderboard has finished loading.");
    _scrollController.addListener(_onScroll);
    await _loadLeaderboard(); // Load the appropriate leaderboard
  }

  /// **🔥 Load More Users with Pagination**
  Future<void> _loadLeaderboard({bool loadMore = false}) async {
    if (_isLoadingMore || (!_hasMoreData && loadMore)) return;

    print("DEBUG: Fetching ${selectedLeaderboard.name} leaderboard...");
    if (!loadMore) {
      // Reset pagination and clear data for a new leaderboard type
      setState(() {
        _loadedUsers.clear();
        _currentStartIndex = 0;
        _hasMoreData = true;
      });
    }

    _isLoadingMore = true; // Prevent duplicate fetches
    setState(() {}); // Trigger loading state

    try {
      List<LeaderboardModel> newUsers = [];

      if (selectedLeaderboard == LeaderboardType.ranked) {
        print(
            "DEBUG: Fetching from Riot API start=$_currentStartIndex, size=$_pageSize");
        newUsers = await riotApiService.getLeaderboard(
          startIndex: _currentStartIndex,
          size: _pageSize,
        );
      } else {
        print("DEBUG: Fetching Firestore leaderboard...");
        List<LeaderboardModel> allUsers =
            await userRepository.firestoreGetLeaderboard();

        // Sort users based on the leaderboard type (toxicity or cheater reports)
        allUsers.sort((a, b) {
          return selectedLeaderboard == LeaderboardType.toxicity
              ? b.toxicityReports.compareTo(a.toxicityReports)
              : b.cheaterReports.compareTo(a.cheaterReports);
        });

        // Paginate sorted users
        newUsers = allUsers.skip(_currentStartIndex).take(_pageSize).toList();
      }

      if (newUsers.isNotEmpty) {
        setState(() {
          _loadedUsers.addAll(newUsers);
          _currentStartIndex += newUsers.length;
          _hasMoreData = newUsers.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }

      print(
          "DEBUG: Loaded ${newUsers.length} users. Total: ${_loadedUsers.length}");
    } catch (e) {
      print("❌ ERROR: Failed to load leaderboard: $e");
    } finally {
      _isLoadingMore = false;
      setState(() {}); // Stop loading state
    }
  }

  /// **🖱 Detect Bottom Scroll & Load More**
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // ✅ Triggers earlier
      print("DEBUG: Scroll reached bottom. Loading more...");
      _loadLeaderboard(loadMore: true);
    }
  }

  Future<void> _reportUser(bool isToxicityReport) async {
    try {
      await userRepository.reportPlayer(
        username: newUserId.trim(),
        tagline: newTagLine.trim(),
        isToxicityReport: isToxicityReport,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isToxicityReport
              ? "Player successfully reported for toxicity!"
              : "Player successfully reported as a cheater!"),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the leaderboard
      print("DEBUG: Refreshing leaderboard after report...");
      setState(() {
        _currentStartIndex = 0; // Reset pagination
        _hasMoreData = true;
        _loadedUsers.clear(); // Clear existing loaded users
      });
      await _loadLeaderboard(); // Reload leaderboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to report player: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
                delegate: MySearchDelegate(_loadedUsers),
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
      body: Column(
        children: [
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
              onSuccess: () => _reportUser(
                selectedLeaderboard == LeaderboardType.toxicity,
              ),
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
                return ListTile(
                  title: Text('${user.username}#${user.tagline}'),
                  subtitle: Text(
                    'Rank: ${user.leaderboardNumber} | Cheater Reports: ${user.cheaterReports} | Toxicity: ${user.toxicityReports}',
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
