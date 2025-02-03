import 'package:flutter/material.dart';

class ReportLevelHelper {
  // Normal cheater color thresholds (green, yellow, red)
  static Color getCheaterLevelColor(int cheaterReports) {
    if (cheaterReports < 3) {
      return Colors.green;
    } else if (cheaterReports < 7) {
      return Colors.amber;
    } else {
      return Colors.orange;
    }
  }

  // For famous users: calculate a ratio of reports to page views and assign a color.
  // Adjust these thresholds as needed.
  static Color getCheaterLevelColorRatio(int cheaterReports, int pageViews) {
    double ratio = pageViews > 0 ? (cheaterReports / pageViews) : 0.0;
    if (ratio < 0.001) {
      return Colors.green;
    } else if (ratio < 0.005) {
      return Colors.amber;
    } else {
      return Colors.orange;
    }
  }

  // Normal toxicity color thresholds (blue shades)
  static Color getToxicityLevelColor(int toxicityReports) {
    if (toxicityReports < 3) {
      return const Color(0xFF81D4FA); // Light Blue
    } else if (toxicityReports < 7) {
      return const Color(0xFF29B6F6); // Medium Blue
    } else {
      return const Color(0xFF0288D1); // Dark Blue
    }
  }

  // For famous users (toxicity): calculate a ratio.
  static Color getToxicityLevelColorRatio(int toxicityReports, int pageViews) {
    double ratio = pageViews > 0 ? (toxicityReports / pageViews) : 0.0;
    if (ratio < 0.001) {
      return const Color(0xFF81D4FA);
    } else if (ratio < 0.005) {
      return const Color(0xFF29B6F6);
    } else {
      return const Color(0xFF0288D1);
    }
  }
}
