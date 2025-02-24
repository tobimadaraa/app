// ignore_for_file: avoid_print

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
    await prefs.remove("lastReport_cheater");
    await prefs.remove("lastReport_toxicity");
    await prefs.remove("lastReport_honour");
    setState(() {
      // _reportResetTriggerCheater++;
      // _reportResetTriggerToxicity++;
      // _reportResetTriggerHonour++;
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
        _isActiveLoading = true;
        _errorMessage = null; // ✅ Reset error message
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
        setState(() {
          print(
              "🔄 Updating UI with ${newUsers.length} users for $selectedLeaderboard");
          _loadedUsers.addAll(newUsers);
          _currentStartIndex += newUsers.length;
          _hasMoreData = newUsers.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
        print("⚠️ No more data available, stopping load requests.");
      }
    } catch (e) {
      print("❌ ERROR: Failed to load leaderboard: $e");

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
    } finally {
      if (requestId == _latestRequestId) {
        _isLoadingMore = false;
        _isActiveLoading = false;
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
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
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
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.black,
            size: 28, // adjust size as needed
          ),
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
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Leaderboard',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
      body: Stack(children: [
        // 1) Background color (instead of an image)
        Container(
          color: Colors.white,
        ),

        // 2) Main content
        SafeArea(
            child: Padding(
                // Apply consistent padding around all widgets
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
                      ] else if (selectedLeaderboard ==
                          LeaderboardType.toxicity) ...[
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
                      ] else if (selectedLeaderboard ==
                          LeaderboardType.honour) ...[
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
                        height: selectedLeaderboard == LeaderboardType.ranked
                            ? 0
                            : 8,
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
                            _isActiveLoading = false;
                          });
                          _loadLeaderboard();
                        },
                      ),

                      // Spacing below the toggles
                      //const SizedBox(height: 8),

                      Expanded(
                          child: _isInitialLoading
                              ? _buildSkeletonLoader()
                              : _errorMessage != null
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 4.0),
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                fontSize: 14, // ✅ Smaller text
                                                fontWeight: FontWeight
                                                    .w500, // ✅ Medium weight, not bold
                                                color: Colors
                                                    .black, // ✅ Softer color instead of bright blue
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(
                                              height:
                                                  10), // ✅ Reduce space between text & button
                                          ElevatedButton(
                                            onPressed: _refreshLeaderboard,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey
                                                  .shade200, // ✅ Lighter grey background
                                              shape:
                                                  const CircleBorder(), // ✅ Circular button
                                              elevation: 2, // ✅ Softer shadow
                                              padding: const EdgeInsets.all(
                                                  12), // ✅ Smaller button size
                                            ),
                                            child: Icon(Icons.refresh,
                                                color: Colors.black,
                                                size:
                                                    24), // ✅ Darker grey icon, smaller size
                                          ),
                                        ],
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: _refreshLeaderboard,
                                      child: ListView.builder(
                                          controller: _scrollController,
                                          itemCount: _loadedUsers.length +
                                              (_isLoadingMore ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (index >= _loadedUsers.length) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                              // );
                                            }
                                            final user = _loadedUsers[index];
                                            final bool isClickable =
                                                selectedLeaderboard ==
                                                        LeaderboardType
                                                            .cheater ||
                                                    selectedLeaderboard ==
                                                        LeaderboardType
                                                            .toxicity ||
                                                    selectedLeaderboard ==
                                                        LeaderboardType.honour;
                                            return Column(
                                              children: [
                                                ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 16,
                                                          right: 8,
                                                          top: 2,
                                                          bottom: 2),
                                                  title: RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        color: selectedLeaderboard ==
                                                                LeaderboardType
                                                                    .ranked
                                                            ? Colors.grey[900]
                                                            : ReportLevelHelper
                                                                .getGameNameColor(
                                                                cheaterReports:
                                                                    user.cheaterReports,
                                                                toxicityReports:
                                                                    user.toxicityReports,
                                                                honourReports: user
                                                                    .honourReports,
                                                              ),
                                                        fontSize: 17,
                                                        height: 1.0,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                '${user.gameName}#${user.tagLine} '),
                                                        ...ReportLevelHelper
                                                            .buildReportBadges(
                                                          cheaterReports: user
                                                              .cheaterReports,
                                                          toxicityReports: user
                                                              .toxicityReports,
                                                          honourReports: user
                                                              .honourReports,

                                                          //iconSize: 20,
                                                        ).map(
                                                          (icon) => WidgetSpan(
                                                            alignment:
                                                                PlaceholderAlignment
                                                                    .middle,
                                                            child: icon,
                                                          ),
                                                        )
                                                        // .toList(),
                                                      ],
                                                    ),
                                                  ),
                                                  subtitle: selectedLeaderboard ==
                                                          LeaderboardType.ranked
                                                      ? Text(
                                                          'Rank: ${user.leaderboardRank} | Rating: ${user.rankedRating ?? "N/A"} | Wins: ${user.numberOfWins ?? "N/A"}',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              height: 1.0,
                                                              color: Colors
                                                                  .grey[600]),
                                                        )
                                                      : selectedLeaderboard ==
                                                              LeaderboardType
                                                                  .cheater
                                                          ? Text(
                                                              'Rank: ${user.leaderboardRank} | Cheater Reports: ${user.cheaterReports}',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  height: 1.0,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            )
                                                          : selectedLeaderboard ==
                                                                  LeaderboardType
                                                                      .toxicity
                                                              ? Text(
                                                                  'Rank: ${user.leaderboardRank} | Toxicity Reports: ${user.toxicityReports}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.0,
                                                                      color: Colors
                                                                              .grey[
                                                                          600]),
                                                                )
                                                              : selectedLeaderboard ==
                                                                      LeaderboardType
                                                                          .honour
                                                                  ? Text(
                                                                      'Rank: ${user.leaderboardRank} | Honour Reports: ${user.honourReports}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          height:
                                                                              1.0,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    )
                                                                  : null,
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
                                                Divider(
                                                  color: Colors.grey,
                                                  thickness: 0.3,
                                                  height: 0,
                                                ),
                                              ],
                                            );
                                          })))
                    ])))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await resetAllReportCooldowns();
          Get.snackbar("Reset", "All report cooldowns have been reset");
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
