// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/shared/classes/colour_classes.dart';

// //const Color myCustomColor = Color(0xFF808080);

// class RankingDataCard extends StatelessWidget {
//   final String text;
//   final String leaderboardnumber;
//   final String numberofgameswon;
//   final String timesReported;
//   final void Function() onPressed;
//   const RankingDataCard({
//     super.key,
//     required this.text,
//     required this.leaderboardnumber,
//     required this.timesReported,
//     required this.numberofgameswon,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       color: Colors.grey[700],
//       child: SizedBox(
//         height: 30,
//         child: Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: (Container(
//                 color: Colors.grey[700],
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   leaderboardnumber,
//                   style: TextStyle(
//                     color: CustomColours.whiteDiscordText,
//                     fontSize: 12, // Adjust font size as needed
//                     //),
//                   ),
//                 ),
//               )),
//             ),
//             Expanded(
//               flex: 2,
//               child: Container(
//                 color: Colors.grey[700],
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   text,
//                   style: TextStyle(
//                     color: CustomColours.whiteDiscordText,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 3, // 4 out of 5 (80%)
//               child: Container(
//                 color: Colors.grey[700], // Original background color
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.all(8.0),
//               ),
//             ),
//             Expanded(
//               flex: 3, // 4 out of 5 (80%)
//               child: Container(
//                 color: Colors.grey[700], // Original background color
//                 alignment: Alignment.centerRight,
//                 //padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Text(
//                       numberofgameswon,
//                       style: TextStyle(
//                         color: CustomColours.whiteDiscordText,
//                         fontSize: 12,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Text(
//                       timesReported,
//                       style: TextStyle(
//                         color: CustomColours.whiteDiscordText,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
