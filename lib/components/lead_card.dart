import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/colour_classes.dart';
import 'package:intl/intl.dart'; // Import the intl package

class LeadCard extends StatefulWidget {
  final String text;
  final String leaderboardname;
  final String reportLabel; // This will be used for the dynamic label
  final String
  cheaterReports; // Represents the cheater report count (as a String)
  final String
  toxicityReports; // Represents the toxicity report count (as a String)
  final Color
  backgroundColor; // New: The background color based on the report counts
  final List<String> lastReported; // List of timestamps

  const LeadCard({
    super.key,
    required this.text,
    required this.leaderboardname,
    required this.reportLabel,
    required this.cheaterReports,
    required this.toxicityReports,
    required this.backgroundColor,
    required this.lastReported,
  });

  @override
  LeadCardState createState() => LeadCardState();
}

class LeadCardState extends State<LeadCard> {
  bool isExpanded = false; // Track expansion state

  // Helper function to format the timestamp
  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM d, y h:mm a').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      // Use the passed-in background color
      color: widget.backgroundColor,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                // Rank or rating (Text)
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
                        widget.leaderboardname,
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
                // Report count (Dynamic using reportLabel)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(right: 8),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${widget.cheaterReports} ${widget.reportLabel}',
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
          // Expanded Section (Only shows if isExpanded is true)
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
                        "• ${_formatTimestamp(time)}",
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
