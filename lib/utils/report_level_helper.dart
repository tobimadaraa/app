import 'package:flutter/material.dart';

class ReportLevelHelper {
  /// Returns a color based on the number of cheater reports.
  /// * Less than 3 reports → Green
  /// * 3 to 6 reports → Yellow
  /// * 7 or more reports → Red
  static Color getCheaterLevelColor(int timesReported) {
    if (timesReported < 3) {
      return Colors.green;
    } else if (timesReported < 7) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  /// Returns a color based on the number of toxicity reports.
  /// * Less than 3 reports → Light Blue
  /// * 3 to 6 reports → Medium Blue
  /// * 7 or more reports → Dark Blue
  static Color getToxicityLevelColor(int toxicityReported) {
    if (toxicityReported < 3) {
      return const Color(0xFF81D4FA); // Light Blue
    } else if (toxicityReported < 7) {
      return const Color(0xFF29B6F6); // Medium Blue
    } else {
      return const Color(0xFF0288D1); // Dark Blue
    }
  }

  /// Returns the combined level color based on which report count is higher.
  /// If toxicityReported is higher than timesReported, it uses the toxicity scale.
  /// Otherwise, it uses the cheater scale.
  static Color getCombinedLevelColor(int timesReported, int toxicityReported) {
    if (toxicityReported > timesReported) {
      return getToxicityLevelColor(toxicityReported);
    } else {
      return getCheaterLevelColor(timesReported);
    }
  }
}
