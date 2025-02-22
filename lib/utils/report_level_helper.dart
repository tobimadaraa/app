import 'package:flutter/material.dart';

class ReportLevelHelper {
  static Color getGameNameColor({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
  }) {
    return const Color(0xFF424242);
  }

  static Color getCheaterLevelColor(int cheaterReports) {
    if (cheaterReports < 3) return Colors.green;
    if (cheaterReports < 7) return Colors.amber;
    return Colors.red;
  }

  static Color getToxicityLevelColor(int toxicityReports) {
    if (toxicityReports < 3) return const Color(0xFF81D4FA); // light blue
    if (toxicityReports < 7) return const Color(0xFF29B6F6); // medium blue
    return const Color(0xFF0288D1); // dark blue
  }

  static Color getToxicityLevelColorRatio(int toxicityReports, int pageViews) {
    double ratio = pageViews > 0 ? toxicityReports / pageViews : 0;
    if (ratio < 0.001) return const Color(0xFF81D4FA);
    if (ratio < 0.005) return const Color(0xFF29B6F6);
    return const Color(0xFF0288D1);
  }

  /// ✅ Returns a **list of widgets** displaying labels only.
  /// - **Cheater (Red)**
  /// - **Very Toxic (Yellow)**
  /// - **Honorable (Green)**
  static List<Widget> buildReportBadges({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
    int threshold = 10,
  }) {
    List<Map<String, dynamic>> badgesData = [
      {
        'count': cheaterReports,
        'color': const Color(0xFFFF6347),
        'label': 'Cheater'
      },
      {
        'count': toxicityReports,
        'color': const Color(0xFFC79220),
        'label': 'Very Toxic'
      },
      {
        'count': honourReports,
        'color': Color(0xff2E8B57),
        'label': 'Honorable'
      },
    ];

    // Sort badges in descending order of count.
    badgesData.sort((a, b) => b['count'].compareTo(a['count']));

    // Build only labels without icons
    List<Widget> badges = [];
    for (var badge in badgesData) {
      if (badge['count'] > threshold) {
        badges.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: badge['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badge['color'], width: 1),
            ),
            child: Text(
              badge['label'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badge['color'],
              ),
            ),
          ),
        );
      }
    }

    return [
      Wrap(
        spacing: 4,
        runSpacing: 0,
        children: badges,
      )
    ];
  }
}
