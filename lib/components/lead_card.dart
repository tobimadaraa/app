import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/colour_classes.dart';
import 'package:intl/intl.dart'; // Import the intl package

class LeadCard extends StatefulWidget {
  final String text;
  final String leaderboardname;
  final String timesReported;
  final List<String> lastReported; // List of timestamps

  const LeadCard({
    super.key,
    required this.text,
    required this.leaderboardname,
    required this.timesReported,
    required this.lastReported, // Pass last_reported list
  });

  @override
  LeadCardState createState() => LeadCardState();
}

class LeadCardState extends State<LeadCard> {
  bool isExpanded = false; // Track expansion state

  // Helper function to format the timestamp
  String _formatTimestamp(String timestamp) {
    try {
      // Parse the timestamp (assuming it's in ISO 8601 format)
      DateTime dateTime = DateTime.parse(timestamp);
      // Format the DateTime object into a user-friendly format
      return DateFormat(
        'MMM d, y h:mm a',
      ).format(dateTime); // Example: Oct 5, 2023 2:30 PM
    } catch (e) {
      // If parsing fails, return the original timestamp
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: CustomColours.backGroundColor,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded; // Toggle expansion
              });
            },
            child: Row(
              children: [
                // Rating (Text)
                Expanded(
                  flex: 2,
                  child: Container(
                    color: CustomColours.backGroundColor,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.text,
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
                        widget.leaderboardname, // Should include "#Tagline"
                        style: TextStyle(
                          color: CustomColours.whiteDiscordText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                      '${widget.timesReported} times reported',
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

          // Expanded Section (Only Shows if isExpanded = true)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last Reported Times:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomColours.whiteDiscordText,
                    ),
                  ),
                  ...widget.lastReported.map(
                    (time) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "• ${_formatTimestamp(time)}", // Format the timestamp
                        style: TextStyle(
                          color: CustomColours.whiteDiscordText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
