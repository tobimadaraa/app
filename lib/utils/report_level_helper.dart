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

  /// ✅ Returns a **list of widgets** displaying icons with labels.
  /// - **Cheater (Red)**
  /// - **Very Toxic (Yellow)**
  /// - **Honorable (Green)**
  static List<Widget> buildReportBadges({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
    int threshold = 10,
    double iconSize = 16,
  }) {
    List<Map<String, dynamic>> badgesData = [
      {
        'count': cheaterReports,
        'icon': Icons.error,
        'color': Colors.red,
        'label': 'Cheater'
      },
      {
        'count': toxicityReports,
        'icon': Icons.warning,
        'color': Colors.amber,
        'label': 'Very Toxic'
      },
      {
        'count': honourReports,
        'icon': Icons.check_circle,
        'color': Colors.green,
        'label': 'Honorable'
      },
    ];

    // Sort the badges in descending order of count.
    badgesData.sort((a, b) => b['count'].compareTo(a['count']));

    // Build widgets **only** for values above the threshold.
    List<Widget> badges = [];
    for (var badge in badgesData) {
      if (badge['count'] > threshold) {
        badges.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: badge['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badge['color'], width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badge['icon'], color: badge['color'], size: iconSize),
                const SizedBox(width: 4),
                Text(
                  badge['label'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: badge['color'],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return badges;
  }
}
