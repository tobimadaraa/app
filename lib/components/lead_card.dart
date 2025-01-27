import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/colour_classes.dart';

class LeadCard extends StatelessWidget {
  final String text;
  final String leaderboardnumber;
  final String leaderboardname;
  final String timesReported;
  final void Function() onPressed;
  const LeadCard({
    super.key,
    required this.text,
    required this.leaderboardname,
    required this.leaderboardnumber,
    required this.timesReported,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: CustomColours.backGroundColor,
      child: SizedBox(
        child: InkWell(
          onTap: onPressed,
          child: Row(
            children: [
              // Leaderboard Number (Grey Box)
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Rating (Text)
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

              // Riot ID + Tagline (Combined)
              Expanded(
                flex: 5,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      leaderboardname, // Should already include "#Tagline" from LeaderboardList
                      style: TextStyle(
                        color: CustomColours.whiteDiscordText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis, // Fix text overflow
                    ),
                  ),
                ),
              ),

              // Times Reported (Fixed Layout)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.only(right: 8),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$timesReported times reported', // Single text widget
                    style: TextStyle(
                      color: CustomColours.whiteDiscordText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
