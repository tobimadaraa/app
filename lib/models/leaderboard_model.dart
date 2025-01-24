class LeaderboardModel {
  final int leaderboardNumber;
  final int rating;
  final String username;
  final int numberOfGamesWon;

  LeaderboardModel({
    required this.leaderboardNumber,
    required this.rating,
    required this.username,
    required this.numberOfGamesWon,
  });
}
//  Align(
//       alignment: Alignment.topLeft,
//       child: LeadCard(
//         textColor: Colors.white,
//         backgroundColor: Colors.grey,
//         leaderboardnumber: '1', remember camel case
//         text: '1120',
//         leaderboardname: 'FANCY YESicaN',
//         numberofgameswon: '116',
//         gameswontext: 'games won',
//         // ignore: avoid_print
//         onPressed: () {
//           // ignore: avoid_print
//           print('boop');
//         },
//         height: 70,
//         width: 40,
//       ),
//     ),
// //     ),