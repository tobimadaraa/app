// // ignore_for_file: avoid_print

// import 'dart:async'; // Import for delay function
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_application_2/models/leaderboard_model.dart';
// import 'package:flutter_application_2/repository/valorant_api.dart';

// Future<void> storeLeaderboardInBatches() async {
//   final RiotApiService riotApiService = RiotApiService();
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final CollectionReference leaderboardRef =
//       firestore.collection("LeaderboardDoc");

//   const int batchSize = 2000; // Each batch contains 2000 players
//   const int pageSize = 200; // Riot API only allows fetching 200 at a time
//   const int totalPlayers = 15000; // Max leaderboard size
//   final int totalBatches = (totalPlayers / batchSize).ceil();

//   for (int batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
//     int startFrom = batchIndex * batchSize;
//     List<LeaderboardModel> allPlayers = [];

//     // **1️⃣ Fetch players in pages of 200**
//     for (int page = 0; page < (batchSize / pageSize).ceil(); page++) {
//       int startIndex = startFrom + (page * pageSize);
//       try {
//         List<LeaderboardModel> playersPage =
//             await riotApiService.getLeaderboard(
//           startIndex: startIndex,
//           size: pageSize,
//           forceRefresh: true,
//         );

//         print(
//             "Fetched page $page (Starting from $startIndex): ${playersPage.length} players");
//         allPlayers.addAll(playersPage);

//         if (playersPage.length < pageSize) {
//           print("Reached the end of the leaderboard at page $page.");
//           break;
//         }
//       } catch (error) {
//         print("Error fetching page $page: $error");
//         break;
//       }
//     }

//     // **2️⃣ Store players in Firestore under batch_X**
//     List<Map<String, dynamic>> playersJson =
//         allPlayers.map((player) => player.toJson()).toList();
//     DocumentReference docRef = leaderboardRef.doc("batch_$batchIndex");
//     await docRef.set({"players": playersJson});

//     print(
//         "✅ Stored ${allPlayers.length} players in document batch_$batchIndex");

//     // **3️⃣ Wait 20 seconds before fetching the next batch**
//     if (batchIndex < totalBatches - 1) {
//       print("⏳ Waiting 20 seconds before fetching batch ${batchIndex + 1}...");
//       await Future.delayed(Duration(seconds: 20));
//     }
//   }

//   print("✅ All leaderboard batches stored successfully!");
// }

// Future<void> main() async {
//   await storeLeaderboardInBatches();
//   print("Leaderboard has been stored in Firestore.");
// }
