import 'package:flutter/material.dart';

class ReportLevelHelper {
  static Color getGameNameColor({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
  }) {
    // Only change color if at least one report count exceeds 10.
    const Color textColor = Color(0xFF424242);
    if (cheaterReports <= 10 && toxicityReports <= 10 && honourReports <= 10) {
      return textColor;
    }
    // After 10 reports, the highest count determines the color.
    if (honourReports >= cheaterReports && honourReports >= toxicityReports) {
      return Colors.green;
    } else if (cheaterReports >= toxicityReports) {
      return Colors.red;
    } else {
      return Colors.amber;
    }
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
}
