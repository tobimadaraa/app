import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/classm.dart';

// seperate onto its own class

class LeadCard extends StatelessWidget {
  final String text;
  final String leaderboardnumber;
  final String leaderboardname;
  final String numberofgameswon;
  // this will always be the same text dont need to pass it
  final void Function() onPressed;
  const LeadCard({
    super.key,
    required this.text,
    required this.leaderboardname,
    required this.leaderboardnumber,
    required this.numberofgameswon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: CustomColours.backGroundColor,
      child: SizedBox(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[700],
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  leaderboardnumber,
                  style: TextStyle(
                    color: CustomColours.whiteDiscordText,
                    fontSize: 16, // Adjust font size as needed
                    //),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: CustomColours.backGroundColor,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: CustomColours.whiteDiscordText,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3, // 4 out of 5 (80%)
              child: Container(
                color: Colors.transparent, // Original background color
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  leaderboardname,
                  style: TextStyle(
                    color: CustomColours.whiteDiscordText,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3, // 4 out of 5 (80%)
              child: Container(
                color: Colors.transparent, // Original background color
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Text(
                      numberofgameswon,
                      style: TextStyle(
                        color: CustomColours.whiteDiscordText,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      ' games won', // games text string here
                      style: TextStyle(
                        color: CustomColours.whiteDiscordText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
