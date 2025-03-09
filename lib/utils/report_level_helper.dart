import 'package:flutter/material.dart';

class ReportLevelHelper {
  static Color getGameNameColor({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
  }) {
    return const Color(0xFF424242);
  }

  /// ✅ Returns a **list of widgets** displaying a MAX of 3 badges.
  /// - **Cheater → Hacker**
  /// - **Toxic → Very Toxic**
  /// - **Nice Guy → Honourable**
  static List<Widget> buildReportBadges({
    required int cheaterReports,
    required int toxicityReports,
    required int honourReports,
  }) {
    List<Map<String, dynamic>> allBadges = [];

    // 🟥 Cheater → Hacker (Restored Original Colors)
    if (cheaterReports > 25) {
      allBadges.add({
        'label': 'Hacker',
        'color': const Color(0xFFFF0000), // Bright Red
      });
    } else if (cheaterReports > 10) {
      allBadges.add({
        'label': 'Cheater',
        'color': const Color(0xFFFF6347), // Tomato Red
      });
    }

    // 🟦 Toxic → Very Toxic (Restored Original Colors)
    if (toxicityReports > 25) {
      allBadges.add({
        'label': 'Very Toxic',
        'color': const Color(0xFFB026FF), // Dark Orange Color(0xFFFFA500)
      });
    } else if (toxicityReports > 10) {
      allBadges.add({
        'label': 'Toxic',
        'color': const Color(0XFF9966CC), // Orange
      });
    }

    // 🟩 Nice Guy → Honourable (Restored Original Colors)
    if (honourReports > 25) {
      allBadges.add({
        'label': 'Honourable',
        'color': const Color(0XFF0EF67E), // Sea Green 6BAF88
      });
    } else if (honourReports > 10) {
      allBadges.add({
        'label': 'Nice Guy',
        'color': const Color(0XFF36A06B), // Spring Green
      });
    }

    // Sort by highest count (Cheater > Toxicity > Honour)
    allBadges.sort((a, b) => b['label'].compareTo(a['label']));

    // ✅ Display only MAX 3 badges
    List<Map<String, dynamic>> selectedBadges = allBadges.take(3).toList();

    // Generate badge widgets
    List<Widget> badgeWidgets = selectedBadges.map((badge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: badge['color']!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badge['color']!, width: 1),
        ),
        child: Text(
          badge['label']!,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: badge['color'],
          ),
        ),
      );
    }).toList();

    return [
      Wrap(
        //spacing: 0,
        //runSpacing: 0,
        children: badgeWidgets,
      )
    ];
  }
}
