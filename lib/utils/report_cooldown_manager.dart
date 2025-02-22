import 'package:shared_preferences/shared_preferences.dart';

class ReportCooldownManager {
  static const String _lastReportKey = 'lastReportTime';

  // Call this when a report is successfully submitted.
  static Future<void> updateLastReportTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReportKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Check if 24 hours have passed since the last report.
  static Future<bool> canReport() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReportTimeMillis = prefs.getInt(_lastReportKey);
    if (lastReportTimeMillis == null) return true;
    final lastReportTime =
        DateTime.fromMillisecondsSinceEpoch(lastReportTimeMillis);
    return DateTime.now().difference(lastReportTime) >=
        const Duration(hours: 24);
  }

  // Optionally, calculate the remaining cooldown time.
  static Future<Duration> timeUntilNextReport() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReportTimeMillis = prefs.getInt(_lastReportKey);
    if (lastReportTimeMillis == null) return Duration.zero;
    final lastReportTime =
        DateTime.fromMillisecondsSinceEpoch(lastReportTimeMillis);
    final elapsed = DateTime.now().difference(lastReportTime);
    return const Duration(hours: 24) - elapsed;
  }
}
