// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/models/leaderboard_model.dart';

class RiotApiService {
  // --- Singleton Implementation ---
  static final RiotApiService _instance = RiotApiService._internal();

  factory RiotApiService() {
    return _instance;
  }

  RiotApiService._internal();

  // --- API Details ---
  static const String apiKey = "hidden";
  static const String baseUrl =
      "https://eu.api.riotgames.com"; // Change region if needed

  // Cache expiry time
  static const Duration cacheDuration = Duration(minutes: 5);

  // --- Caching Variables ---
  // Cache for each page (key = actId-startIndex-size)
  final Map<String, _PageCache> _pageCache = {};

  // Full cached leaderboard storage (merged from all pages)
  List<LeaderboardModel> cachedLeaderboard = [];
  DateTime? _lastFullFetchTime;
  // Caching act ID to ensure it stays consistent during the cacheDuration.
  String? _cachedActId;
  DateTime? _cachedActIdTimestamp;
  void clearCache() {
    _pageCache.clear();
    cachedLeaderboard.clear();
    _cachedActId = null; // optional: also reset the cached act ID if you want
    _cachedActIdTimestamp = null;
    _lastFullFetchTime = null;
    print("⚠️ Cache cleared. Next request will be forced from Riot API.");
  }

  /// **Fetch the Current Act ID with Caching**
  Future<String> getCurrentActId() async {
    // If we have a cached act id and it is still fresh, use it.
    if (_cachedActId != null &&
        _cachedActIdTimestamp != null &&
        DateTime.now().difference(_cachedActIdTimestamp!) < cacheDuration) {
      print("✅ Using cached Act ID: $_cachedActId");
      return _cachedActId!;
    }

    // Otherwise, fetch a new Act ID from the API.
    final url = Uri.parse('$baseUrl/val/content/v1/contents');
    final response = await http.get(
      url,
      headers: {'X-Riot-Token': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final acts = data['acts'];

      // Find the act where "isActive": true
      final currentAct =
          acts.firstWhere((act) => act['isActive'] == true, orElse: () => null);

      if (currentAct != null) {
        String actId = currentAct['id'];
        // Cache the act id and timestamp
        _cachedActId = actId;
        _cachedActIdTimestamp = DateTime.now();
        print("✅ Fetched new Act ID: $actId");
        return actId;
      } else {
        throw Exception("No active Act found.");
      }
    } else {
      throw Exception("Failed to fetch Act ID: ${response.statusCode}");
    }
  }

  Future<List<LeaderboardModel>> getLeaderboard({
    required int startIndex,
    required int size,
    bool includeStats = true,
    bool forceRefresh = false,
  }) async {
    final actId = await getCurrentActId();
    final cacheKey = _buildCacheKey(actId, startIndex, size);
    print("🔑 Cache Key: $cacheKey");
    // Only check cache if not forcing refresh.
    if (!forceRefresh) {
      final cachedPage = _pageCache[cacheKey];
      if (cachedPage != null) {
        final timeSinceLastFetch =
            DateTime.now().difference(cachedPage.fetchTime);
        if (timeSinceLastFetch < cacheDuration) {
          print(
              "✅ Using cached page: startIndex=$startIndex (age: ${timeSinceLastFetch.inSeconds}s)");
          return cachedPage.data;
        } else {
          print(
              "🔄 forceRefresh=true. Skipping cache for startIndex=$startIndex");
        }
      }
    } else {
      print(
          "🔄 Force refresh requested. Skipping cache for startIndex=$startIndex");
    }

    // 2️⃣ If we got here, we need to fetch fresh data.
    print("⏳ Fetching leaderboard from Riot API for startIndex=$startIndex...");
    final response = await http.get(
      Uri.parse(
          '$baseUrl/val/ranked/v1/leaderboards/by-act/$actId?startIndex=$startIndex&size=$size'),
      headers: {'X-Riot-Token': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> players = data['players'];

      final leaderboardPage = players
          .map((player) =>
              LeaderboardModel.fromJson(player, includeStats: includeStats))
          .toList();

      // Update the cache with fresh data.
      _pageCache[cacheKey] = _PageCache(
        fetchTime: DateTime.now(),
        data: leaderboardPage,
      );

      _mergeCachedPages();
      print("✅ Fetched and cached leaderboard page: startIndex=$startIndex");
      return leaderboardPage;
    } else if (response.statusCode == 400) {
      print("Skipping Riot API request: Using cached data instead.");
      return []; // ✅ Return an empty list to maintain a valid return type
    } else {
      throw Exception("Failed to fetch leaderboard: ${response.statusCode}");
    }
  }

  /// Merge all cached pages into one big leaderboard list.
  void _mergeCachedPages() {
    if (_pageCache.isNotEmpty) {
      // Keep the cached list reference instead of creating a new one every time.
      cachedLeaderboard.clear();
      for (var page in _pageCache.values) {
        cachedLeaderboard.addAll(page.data);
      }
    }
  }

  /// Check if a player exists using the merged leaderboard cache.
  Future<bool> checkPlayerExists(String gameName, String tagLine) async {
    // 1️⃣ If full cache is fresh, use it instead of fetching.
    if (_lastFullFetchTime != null &&
        DateTime.now().difference(_lastFullFetchTime!) < cacheDuration) {
      print("✅ Using cached full leaderboard for player check.");
    } else {
      // 2️⃣ Otherwise, preload enough data for the check.
      print("⏳ Fetching enough leaderboard pages for checkPlayerExists...");
      await getLeaderboard(startIndex: 0, size: 500);
      _lastFullFetchTime = DateTime.now();
      print(
          "DEBUG: Cached leaderboard has ${cachedLeaderboard.length} players.");
      for (int i = 0; i < 10 && i < cachedLeaderboard.length; i++) {
        print(
            "Player $i: ${cachedLeaderboard[i].gameName}#${cachedLeaderboard[i].tagLine}");
      }
    }

    // 3️⃣ Check if the player exists in the cached leaderboard.
    return cachedLeaderboard.any((player) =>
        player.gameName.toLowerCase() == gameName.toLowerCase() &&
        player.tagLine.toLowerCase() == tagLine.toLowerCase());
  }

  /// Create a unique cache key for each page request.
  String _buildCacheKey(String actId, int startIndex, int size) {
    return '$actId-$startIndex-$size';
  }
}

/// Helper class to store cached pages.
class _PageCache {
  final DateTime fetchTime;
  final List<LeaderboardModel> data;

  _PageCache({required this.fetchTime, required this.data});
}
