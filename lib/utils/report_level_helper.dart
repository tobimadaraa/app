import 'package:flutter/material.dart';

class ReportLevelHelper {
  static Color getGameNameColor({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
  }) {
    // Always use the base color regardless of report counts.
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

  /// Returns an icon widget if [count] exceeds [threshold].
  /// You can freely pass in the desired [icon], [color], [size], and [threshold].
  static List<Widget> buildReportBadges({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
    int threshold = 10,
    double iconSize = 16,
  }) {
    // Create a list with badge info.
    List<Map<String, dynamic>> badgesData = [
      {
        'count': cheaterReports,
        'icon': Icons.error,
        'color': Colors.red,
      },
      {
        'count': toxicityReports,
        'icon': Icons.warning,
        'color': Colors.amber,
      },
      {
        'count': honourReports,
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];

    // Sort the badges in descending order of count.
    badgesData.sort((a, b) => b['count'].compareTo(a['count']));

    // Build icon widgets only for counts above the threshold.
    List<Widget> badges = [];
    for (var badge in badgesData) {
      if (badge['count'] > threshold) {
        badges.add(Icon(badge['icon'], color: badge['color'], size: iconSize));
      }
    }
    return badges;
  }
}
