
// import 'package:timezone/timezone.dart' as tz;
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart'; // For debugPrint

// class TimeUtils {
//   /// Converts an existing DateTime to the specified dynamic timezone,
//   /// assuming the original DateTime should be treated as UTC.
//   static String formatTimeInZone(DateTime dateTime, String timeZoneName, {String format = 'hh:mm:ss a'}) {
//     try {
//       final location = tz.getLocation(timeZoneName);
      
//       // 1. Force the DateTime to be treated as UTC (Mirroring the backend logic)
//       final utcDateTime = DateTime.utc(
//         dateTime.year,
//         dateTime.month,
//         dateTime.day,
//         dateTime.hour,
//         dateTime.minute,
//         dateTime.second,
//       );

//       // 2. Convert that strict UTC time to the target timezone
//       final tz.TZDateTime timeInZone = tz.TZDateTime.from(utcDateTime, location);
      
//       return DateFormat(format).format(timeInZone);
//     } catch (e) {
//       debugPrint('Error converting time for zone $timeZoneName: $e');
//       // Fallback
//       return DateFormat(format).format(dateTime);
//     }
//   }
// }

import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class TimeUtils {
  /// Fetches the timezone directly from Hive.
  static String _getCompanyTimeZone() {
    try {
      if (Hive.isBoxOpen('settingsBox')) {
        final box = Hive.box('settingsBox');
        final storedData = box.get('all_settings_data');
        
        if (storedData != null && storedData is List) {
          for (var item in storedData) {
            if (item is Map && item['key'] == 'time_zone') {
              return item['value'].toString();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error reading timezone from Hive: $e');
    }
    // Safe fallback if Hive isn't loaded yet
    return 'Australia/Melbourne'; 
  }

  /// Converts an existing DateTime to the dynamic timezone.
  static String formatTimeInZone(DateTime dateTime, {String? timeZoneName, String format = 'hh:mm:ss a'}) {
    try {
      // 1. Get timezone (either passed in, or fetched automatically from Hive)
      final targetZone = timeZoneName ?? _getCompanyTimeZone();
      final location = tz.getLocation(targetZone);
      
      // 2. Force the DateTime to be treated as UTC
      final utcDateTime = DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );

      // 3. Convert that strict UTC time to the target timezone
      final tz.TZDateTime timeInZone = tz.TZDateTime.from(utcDateTime, location);
      
      return DateFormat(format).format(timeInZone);
    } catch (e) {
      debugPrint('🚨 Error converting time for zone: $e');
      // Fallback returns the un-converted time (which is why you saw 01:50 PM)
      return DateFormat(format).format(dateTime);
    }
  }
}