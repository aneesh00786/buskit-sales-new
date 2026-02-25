// import 'package:timezone/timezone.dart' as tz;
// import 'package:intl/intl.dart';

// class TimeUtils {
//   /// Converts an existing DateTime to the specified dynamic timezone.
//   static String formatTimeInZone(DateTime dateTime, String timeZoneName, {String format = 'hh:mm:ss a'}) {
//     try {
//       final location = tz.getLocation(timeZoneName);
//       // Converts the DateTime (whether local or UTC) to the target timezone
//       final tz.TZDateTime timeInZone = tz.TZDateTime.from(dateTime, location);
//       return DateFormat(format).format(timeInZone);
//     } catch (e) {
//       print('Error converting time for zone $timeZoneName: $e');
//       // Fallback to normal formatting if timezone fails
//       return DateFormat(format).format(dateTime);
//     }
//   }
// }
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class TimeUtils {
  /// Converts an existing DateTime to the specified dynamic timezone,
  /// assuming the original DateTime should be treated as UTC.
  static String formatTimeInZone(DateTime dateTime, String timeZoneName, {String format = 'hh:mm:ss a'}) {
    try {
      final location = tz.getLocation(timeZoneName);
      
      // 1. Force the DateTime to be treated as UTC (Mirroring the backend logic)
      final utcDateTime = DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );

      // 2. Convert that strict UTC time to the target timezone
      final tz.TZDateTime timeInZone = tz.TZDateTime.from(utcDateTime, location);
      
      return DateFormat(format).format(timeInZone);
    } catch (e) {
      debugPrint('Error converting time for zone $timeZoneName: $e');
      // Fallback
      return DateFormat(format).format(dateTime);
    }
  }
}