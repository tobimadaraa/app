import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/colour_classes.dart';
import 'package:intl/intl.dart';

class LeadCard extends StatefulWidget {
  final String text;
  final String leaderboardname;
  final String reportLabel;
  final String cheaterReports;
  final String toxicityReports;
  final Color backgroundColor;
  final bool isFamous; // New flag: indicates whether to display a star icon
  final List<String> lastReported;

  const LeadCard({
    super.key,
    required this.text,
    required this.leaderboardname,
    required this.reportLabel,
    required this.cheaterReports,
    required this.toxicityReports,
    required this.backgroundColor,
    required this.isFamous,
    required this.lastReported,
  });

  @override
  LeadCardState createState() => LeadCardState();
}

class LeadCardState extends State<LeadCard> {
  bool isExpanded = false;

  // Helper to format timestamps.
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
                // Rank or rating.
                Expanded(
                  flex: 2,
                  child: Container(
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
                // Username + Tagline with optional star for famous users.
                Expanded(
                  flex: 5,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
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
                        if (widget.isFamous)
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                      ],
                    ),
                  ),
                ),
                // Report count (with label).
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(right: 8),
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${widget.cheaterReports}\n${widget.reportLabel}',
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
          // Expanded section showing last reported times.
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
