// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';
import 'package:flutter_application_2/shared/classes/notifiers.dart';
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
import 'package:shimmer/shimmer.dart';

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
  bool isCheaterSelected =
      true; // 🚨 Default to "Cheater" when Reports is selected

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
  bool _isInitialLoading = true;
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
    // If you need the full leaderboard loaded before showing data, await it here.
    await userRepository.loadFullLeaderboard();
    _scrollController.addListener(_onScroll);
    await _loadLeaderboard(); // Load the appropriate leaderboard
    // When all loading is finished, remove the initial loading flag.
    setState(() {
      _isInitialLoading = false;
    });
  }

  /// Track the latest active request
  int _latestRequestId = 0;

  /// Keep track of whether a leaderboard is actively loading
  bool _isActiveLoading = false;
  Future<void> _loadLeaderboard(
      {bool loadMore = false, bool forceRefresh = false}) async {
    print("📢 LB Current Active Request ID: $_latestRequestId");
    print("🔍 LB _isActiveLoading: $_isActiveLoading");
    print("🔍 LB _isLoadingMore: $_isLoadingMore");

    if (_isLoadingMore || (!_hasMoreData && loadMore)) return;

    _latestRequestId++; // 🔥 Generate a unique request ID
    final int requestId = _latestRequestId; // 🔥 Capture this request’s ID

    print(
        "📢 Starting new request: Request ID $requestId for $selectedLeaderboard");

    if (!loadMore) {
      setState(() {
        _loadedUsers.clear();
        _currentStartIndex = 0;
        _hasMoreData = true;
        _isActiveLoading = true; // ✅ Mark as actively loading
      });
    }

    _isLoadingMore = true;
    setState(() {});

    try {
      List<LeaderboardModel> newUsers = [];

      if (selectedLeaderboard == LeaderboardType.ranked) {
        print("⏳ Fetching Ranked leaderboard...");
        newUsers = await riotApiService.getLeaderboard(
          startIndex: _currentStartIndex,
          size: _pageSize,
          forceRefresh: forceRefresh,
        );

        print("✅ Ranked leaderboard received for request ID $requestId");
      } else {
        // For cheater or toxicity, fetch from your "Users" collection only.
        print("⏳ Fetching Firebase leaderboard for reported users...");

        // Decide if it's toxicity or cheater
        // bool forToxic = (selectedLeaderboard == LeaderboardType.toxicity &&
        //     !isCheaterSelected);

        // Call your custom function
        List<LeaderboardModel> allUsers =
            await userRepository.getReportedUsersFromFirebase(
          leaderboardType: selectedLeaderboard,
        );

        // Apply pagination
        newUsers = allUsers.skip(_currentStartIndex).take(_pageSize).toList();
        print("✅ Firebase leaderboard received for request ID $requestId");
      }
      // 🚨 Ensure response is for the latest request before updating UI
      if (requestId != _latestRequestId) {
        print(
            "🚨 Ignoring outdated response: Request $requestId (Current: $_latestRequestId)");
        return;
      }

      if (newUsers.isNotEmpty) {
        setState(() {
          print(
              "🔄 Updating UI with ${newUsers.length} users for $selectedLeaderboard");
          _loadedUsers.addAll(newUsers);
          _currentStartIndex += newUsers.length;
          _hasMoreData = newUsers.length ==
              _pageSize; // ✅ Correctly updates when no more data exists
        });
      } else {
        setState(() {
          _hasMoreData =
              false; // ✅ Ensure it stops loading when no more data is available
        });
        print("⚠️ No more data available, stopping load requests.");
      }
    } catch (e) {
      print("❌ ERROR: Failed to load leaderboard: $e");
    } finally {
      if (requestId == _latestRequestId) {
        _isLoadingMore = false; // ✅ Always reset loading state
        _isActiveLoading = false; // ✅ Ensure we mark loading as done
        print("✅ Finished loading Request $requestId, UI can update");
        setState(() {});
      } else {
        print("⚠️ Request $requestId finished but was ignored.");
      }
    }
  }

  Future<void> _refreshLeaderboard() async {
    setState(() {
      _loadedUsers.clear();
      _currentStartIndex = 0;
      _hasMoreData = true;
      _isInitialLoading = true;
    });
    // Force refresh: set forceRefresh to true.
    riotApiService.clearCache();
    await _loadLeaderboard(forceRefresh: true);
    setState(() {
      _isInitialLoading = false;
    });
  }

  /// **🖱 Detect Bottom Scroll & Load More**
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // ✅ Triggers earlier
      _loadLeaderboard(loadMore: true);
    }
  }

  Widget _buildSkeletonLoader() {
    // Here, we create 10 skeleton items as an example.
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.cyan.shade400,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
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
              onPressed: () async {
                showSearch(
                  context: context,
                  delegate: FirestoreSearchDelegate(selectedLeaderboard),
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
              selectedLeaderboard == LeaderboardType.toxicity ||
              selectedLeaderboard == LeaderboardType.honour) ...[
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

                // 🔔 Notify DodgeListScreen if it's open
                dodgeListEventNotifier.triggerUpdate();

                await _loadLeaderboard(); // ✅ Refresh leaderboard, but DON'T report again
              },
              buttonText: selectedLeaderboard == LeaderboardType.cheater
                  ? 'Report Cheater'
                  : selectedLeaderboard == LeaderboardType.toxicity
                      ? 'Report for Toxicity'
                      : 'Honour Player', // ✅ Correct Honour label

              isToxicity: selectedLeaderboard ==
                  LeaderboardType.toxicity, // ✅ Ensure correct flag
              isHonour: selectedLeaderboard ==
                  LeaderboardType.honour, // ✅ New Honour flag added
            ),
          ],
          Column(
            children: [
              LeaderboardToggle(
                  selectedLeaderboard: selectedLeaderboard,
                  onSelectLeaderboard: (LeaderboardType type) {
                    setState(() {
                      selectedLeaderboard = type;

                      // ✅ Reset inputs when switching away from Honour/Cheater/Toxicity
                      if (type == LeaderboardType.ranked) {
                        newUserId = "";
                        newTagLine = "";
                      }

                      _loadedUsers.clear();
                      _currentStartIndex = 0;
                      _hasMoreData = true;
                      _latestRequestId++; // 🔥 Cancel previous requests
                      _isLoadingMore = false;
                      _isActiveLoading = false;
                    });

                    _loadLeaderboard();
                  }),
            ],
          ),
          Expanded(
            child: _isInitialLoading
                ? _buildSkeletonLoader()
                : RefreshIndicator(
                    onRefresh: _refreshLeaderboard,
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
                        final bool isClickable = selectedLeaderboard ==
                                LeaderboardType.cheater ||
                            selectedLeaderboard == LeaderboardType.toxicity ||
                            selectedLeaderboard == LeaderboardType.honour;

                        return ListTile(
                          title: Text('${user.gameName}#${user.tagLine}'),
                          subtitle: Text(
                            selectedLeaderboard == LeaderboardType.cheater
                                ? 'Rank: ${user.leaderboardRank} | Cheater Reports: ${user.cheaterReports}'
                                : selectedLeaderboard ==
                                        LeaderboardType.toxicity
                                    ? 'Rank: ${user.leaderboardRank} | Toxicity Reports: ${user.toxicityReports}'
                                    : selectedLeaderboard ==
                                            LeaderboardType.honour
                                        ? 'Rank: ${user.leaderboardRank} | Honour Reports: ${user.honourReports}'
                                        : selectedLeaderboard ==
                                                LeaderboardType.ranked
                                            ? 'Rank: ${user.leaderboardRank} | Rating: ${user.rankedRating ?? "N/A"} | Wins: ${user.numberOfWins ?? "N/A"}'
                                            : '',
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
          )
        ]));
  }
}
