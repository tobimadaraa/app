// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/user_detail_page.dart';
import 'package:flutter_application_2/shared/classes/notifiers.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';
import 'package:flutter_application_2/utils/report_level_helper.dart';
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
  String? _errorMessage;
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

  Future<void> resetAllReportCooldowns() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear old keys if needed:
    await prefs.remove("lastReport_cheater");
    await prefs.remove("lastReport_toxicity");
    await prefs.remove("lastReport_honour");
    // Clear the new keys for each report type.
    await prefs.remove("reportCount_cheater");
    await prefs.remove("reportStart_cheater");
    await prefs.remove("reportCount_toxicity");
    await prefs.remove("reportStart_toxicity");
    await prefs.remove("reportCount_honour");
    await prefs.remove("reportStart_honour");
    setState(() {
      // Trigger a UI update if necessary.
    });
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
    await userRepository.loadFullLeaderboard(loadAll: false);
    userRepository.loadFullLeaderboard(loadAll: true);
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
  //bool _isActiveLoading = false;
  Future<void> _loadLeaderboard(
      {bool loadMore = false, bool forceRefresh = false}) async {
    if (_isLoadingMore || (!_hasMoreData && loadMore)) return;

    _latestRequestId++;
    final int requestId = _latestRequestId;

    if (!loadMore) {
      if (mounted) {
        setState(() {
          _loadedUsers.clear();
          _currentStartIndex = 0;
          _hasMoreData = true;
          //_isActiveLoading = true;
          _errorMessage = null;
        });
      }
    }

    _isLoadingMore = true;
    if (mounted) setState(() {});

    try {
      List<LeaderboardModel> newUsers = [];

      if (selectedLeaderboard == LeaderboardType.ranked) {
        print("⏳ Fetching Firebase ranked leaderboard...");
        List<LeaderboardModel> fullLeaderboard;

        // If the user hasn't scrolled past 500, use quick load mode.
        if (_currentStartIndex < 500) {
          fullLeaderboard =
              await userRepository.loadFullLeaderboard(loadAll: false);
        } else {
          // The user scrolled past 500, so load the full leaderboard.
          fullLeaderboard =
              await userRepository.loadFullLeaderboard(loadAll: true);
        }

        newUsers =
            fullLeaderboard.skip(_currentStartIndex).take(_pageSize).toList();
        print(
            "✅ Firebase ranked leaderboard received for request ID $requestId");
      } else {
        // Existing logic for reported users...
        print("⏳ Fetching Firebase leaderboard for reported users...");
        List<LeaderboardModel> allUsers =
            await userRepository.getReportedUsersFromFirebase(
          leaderboardType: selectedLeaderboard,
        );
        newUsers = allUsers.skip(_currentStartIndex).take(_pageSize).toList();
        print("✅ Firebase leaderboard received for request ID $requestId");
      }

      if (requestId != _latestRequestId) {
        print(
            "🚨 Ignoring outdated response: Request $requestId (Current: $_latestRequestId)");
        return;
      }

      if (newUsers.isNotEmpty) {
        if (mounted) {
          setState(() {
            _loadedUsers.addAll(newUsers);
            _currentStartIndex += newUsers.length;
            _hasMoreData = newUsers.length == _pageSize;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasMoreData = false;
          });
        }
        print("⚠️ No more data available, stopping load requests.");
      }
    } catch (e) {
      print("❌ ERROR: Failed to load leaderboard: $e");
      if (mounted) {
        if (e.toString().contains("403")) {
          setState(() {
            _errorMessage = "Error loading leaderboard. Please try again.";
          });
        } else if (e.toString().contains("429")) {
          setState(() {
            _errorMessage =
                "Too many requests to Riot Servers, please wait and try again";
          });
        }
      }
    } finally {
      if (mounted && requestId == _latestRequestId) {
        _isLoadingMore = false;
        //  _isActiveLoading = false;
        setState(() {});
        print("✅ Finished loading Request $requestId, UI can update");
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
            baseColor: Color(0xff2c3154),
            highlightColor: Colors.grey.shade600,
            child: Container(
              height: 60,
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () async {
                showSearch(
                  context: context,
                  delegate: FirestoreSearchDelegate(selectedLeaderboard),
                );
              },
            ),
          ),
        ],
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Kanit',
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withAlpha((0.08 * 255).toInt()),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),

      // ✅ **Stack for background layers (Gradient + Eclipse)**
      body: Stack(children: [
        // **1️⃣ Base Background Color**
        Container(color: const Color(0xFF141429)),

        // **3️⃣ Positioned Eclipse (Blurred Circle from Figma)**
        Positioned(
          top: -22, // Matches Figma position
          left: 312, // Matches Figma position
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFA54CFF).withOpacity(0.6),
                  blurRadius: 197, // Softer glow effect
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -22, // Matches Figma position
          left: -13, // Matches Figma position
          child: Container(
            width: 110, // Slightly smaller than the right glow
            height: 110,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF37D5F8).withOpacity(0.6), // Light Blue Glow
                  blurRadius: 193, // Matches requested blur
                  spreadRadius: 40, // Similar spread for balanced effect
                ),
              ],
            ),
          ),
        ),
        // 2) Main content
        SafeArea(
            // child: Padding(
            // Apply consistent padding around all widgets
            // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Only show Input Fields & Report Button if Cheater/Toxic/Honour
              if (selectedLeaderboard == LeaderboardType.cheater) ...[
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
                const SizedBox(height: 8),
                // Use a unique ValueKey for the cheater button
                ReportButton(
                  key: const ValueKey("reportButton_cheater"),
                  newUserId: newUserId,
                  newTagLine: newTagLine,
                  onSuccess: () async {
                    setState(() {
                      _loadedUsers.clear();
                      _currentStartIndex = 0;
                      _hasMoreData = true;
                    });
                    dodgeListEventNotifier.triggerUpdate();
                    await _loadLeaderboard();
                  },
                  buttonText: 'Report Cheater',
                  isToxicity: false,
                  isHonour: false,
                  cooldownDuration: const Duration(hours: 24),
                  reportType:
                      "cheater", // This makes the SharedPreferences key "lastReport_cheater"
                  resetTrigger:
                      0, // You can leave this at 0 if you’re not using it
                ),
              ] else if (selectedLeaderboard == LeaderboardType.toxicity) ...[
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
                const SizedBox(height: 8),
                // Unique ValueKey for the toxicity button
                ReportButton(
                  key: const ValueKey("reportButton_toxicity"),
                  newUserId: newUserId,
                  newTagLine: newTagLine,
                  onSuccess: () async {
                    setState(() {
                      _loadedUsers.clear();
                      _currentStartIndex = 0;
                      _hasMoreData = true;
                    });
                    dodgeListEventNotifier.triggerUpdate();
                    await _loadLeaderboard();
                  },
                  buttonText: 'Report for Toxicity',
                  isToxicity: true,
                  isHonour: false,
                  cooldownDuration: const Duration(hours: 24),
                  reportType:
                      "toxicity", // SharedPreferences key becomes "lastReport_toxicity"
                  resetTrigger: 0,
                ),
              ] else if (selectedLeaderboard == LeaderboardType.honour) ...[
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
                const SizedBox(height: 8),
                // Unique ValueKey for the honour button
                ReportButton(
                  key: const ValueKey("reportButton_honour"),
                  newUserId: newUserId,
                  newTagLine: newTagLine,
                  onSuccess: () async {
                    setState(() {
                      _loadedUsers.clear();
                      _currentStartIndex = 0;
                      _hasMoreData = true;
                    });
                    dodgeListEventNotifier.triggerUpdate();
                    await _loadLeaderboard();
                  },
                  buttonText: 'Honour Player',
                  isToxicity: false,
                  isHonour: true,
                  cooldownDuration: const Duration(hours: 24),
                  reportType:
                      "honour", // SharedPreferences key becomes "lastReport_honour"
                  resetTrigger: 0,
                ),
              ],
              // Spacing below the button (or the block above)
              SizedBox(
                height: 20,
              ),

              // Toggle Buttons
              LeaderboardToggle(
                  selectedLeaderboard: selectedLeaderboard,
                  onSelectLeaderboard: (LeaderboardType type) {
                    setState(() {
                      selectedLeaderboard = type;
                      if (type == LeaderboardType.ranked) {
                        newUserId = "";
                        newTagLine = "";
                      }
                      _loadedUsers.clear();
                      _currentStartIndex = 0;
                      _hasMoreData = true;
                      _latestRequestId++;
                      _isLoadingMore = false;
                      _isInitialLoading =
                          true; // Set loading state when switching
                    });
                    _loadLeaderboard().then((_) {
                      setState(() {
                        _isInitialLoading = false;
                      });
                    });
                  }),

              // Spacing below the toggles
              //const SizedBox(height: 8),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: _isInitialLoading
                    ? _buildSkeletonLoader()
                    : _errorMessage != null
                        ? _errorMessage!.contains("404")
                            ? const Center(
                                child: Text(
                                  "No data available yet",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 4.0),
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _refreshLeaderboard,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        shape: const CircleBorder(),
                                        elevation: 2,
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      child: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : _loadedUsers.isEmpty
                            ? const Center(
                                child: Text(
                                  "No data available yet",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _refreshLeaderboard,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: _loadedUsers.length +
                                      (_isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= _loadedUsers.length) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    final user = _loadedUsers[index];
                                    final bool isClickable =
                                        selectedLeaderboard ==
                                                LeaderboardType.cheater ||
                                            selectedLeaderboard ==
                                                LeaderboardType.toxicity ||
                                            selectedLeaderboard ==
                                                LeaderboardType.honour;
                                    return Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff2c3154),
                                        borderRadius: index == 0
                                            ? const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              )
                                            : BorderRadius.zero,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                            leading: CircleAvatar(
                                              radius: 30,
                                              backgroundColor:
                                                  Colors.transparent,
                                              backgroundImage: const AssetImage(
                                                  'assets/userprofile.webp'),
                                            ),
                                            // Title only shows game name and tagline now.
                                            title: Text(
                                              '${user.gameName}#${user.tagLine}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                height: 1.0,
                                              ),
                                            ),
                                            // Subtitle is now a Column with the rank info on top and badges below.
                                            subtitle: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedLeaderboard ==
                                                          LeaderboardType.ranked
                                                      ? 'Rank: ${user.leaderboardRank} | Wins: ${user.numberOfWins ?? "N/A"}'
                                                      : 'Rank: ${user.leaderboardRank}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    height: 1.0,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                // Use a plain Row so the badges are displayed at their intrinsic size
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: ReportLevelHelper
                                                          .buildReportBadges(
                                                    cheaterReports:
                                                        user.cheaterReports,
                                                    toxicityReports:
                                                        user.toxicityReports,
                                                    honourReports:
                                                        user.honourReports,
                                                  )
                                                      .map(
                                                        (badge) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 4.0),
                                                          child: badge,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ],
                                            ),

                                            // Trailing widget remains unchanged
                                            trailing: Text(
                                              selectedLeaderboard ==
                                                      LeaderboardType.ranked
                                                  ? "${user.rankedRating ?? 0} pts"
                                                  : selectedLeaderboard ==
                                                          LeaderboardType
                                                              .cheater
                                                      ? "Cheater Reports: ${user.cheaterReports}"
                                                      : selectedLeaderboard ==
                                                              LeaderboardType
                                                                  .toxicity
                                                          ? "Toxicity Reports: ${user.toxicityReports}"
                                                          : "Honour Reports: ${user.honourReports}",
                                              style: const TextStyle(
                                                color: Color(0xff37d5f8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            onTap: isClickable
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UserDetailPage(
                                                          user: user,
                                                          leaderboardType:
                                                              selectedLeaderboard,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                          ),
                                          if (index != _loadedUsers.length - 1)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Divider(
                                                color: Colors.grey[800],
                                                thickness: 1,
                                                height: 1,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
              )
            ]))
      ]), //]),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () async {
                await resetAllReportCooldowns();
                Get.snackbar("Reset", "All report cooldowns have been reset");
              },
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }
}
