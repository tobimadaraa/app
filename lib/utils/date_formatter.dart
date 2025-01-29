import 'package:intl/intl.dart';

class DateFormatter {
  /// Converts an ISO date string into a user-friendly format
  static String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return "Invalid Date"; // Fallback in case of an error
    }
  }
}
