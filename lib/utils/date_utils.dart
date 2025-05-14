import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String getDateRange(String selectedTime) {
    DateTime now = DateTime.now();
    DateTime fromDate;
    DateTime toDate;

    switch (selectedTime) {
      case "Today":
        fromDate = DateTime(now.year, now.month, now.day);
        toDate = fromDate.add(Duration(days: 1));
        break;

      case "Yesterday":
        fromDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
        toDate = DateTime(now.year, now.month, now.day);
        break;

      case "This week":
        fromDate = now.subtract(Duration(days: now.weekday - 1)); // Start of the week (Monday)
        toDate = fromDate.add(Duration(days: 7)); // End of the week (Sunday)
        break;

      case "Last week":
        fromDate = now.subtract(Duration(days: now.weekday + 6)); // Start of last week
        toDate = fromDate.add(Duration(days: 7)); // End of last week
        break;

      case "Last 30 days":
        fromDate = now.subtract(Duration(days: 30));
        toDate = now;
        break;

      case "Last 6 months":
        fromDate = DateTime(now.year, now.month - 6, now.day);
        toDate = now;
        break;

      case "Last 12 months":
        fromDate = DateTime(now.year - 1, now.month, now.day);
        toDate = now;
        break;
      
      case "Month to date":
      fromDate = DateTime(now.year, now.month, 1);
      toDate = DateTime(now.year, now.month, 31); 
      break;

    case "Year to date":
        fromDate = DateTime(now.year, 1, 1);
        toDate = DateTime(now.year, 12, 31); 
        break;

      default:
        return "";
    }

    return "${_formatDateWithOffset(fromDate)}--${_formatDateWithOffset(toDate)}";
  }

  static String _formatDateWithOffset(DateTime date) {
    // Get the time zone offset dynamically
    Duration offset = date.timeZoneOffset;
    String offsetSign = offset.isNegative ? "-" : "+";
    int absHours = offset.inHours.abs();
    int absMinutes = (offset.inMinutes.abs() % 60);

    // Format offset correctly: ±hh:mm
    String formattedOffset = "$offsetSign${absHours.toString().padLeft(2, '0')}:${absMinutes.toString().padLeft(2, '0')}";

    // Format date in ISO 8601 with offset
    return "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date)}$formattedOffset";
  }

  static String getDateRangeFromDates(fromDate, toDate){
        return "${_formatDateWithOffset(fromDate)}--${_formatDateWithOffset(toDate)}";
  }
}
