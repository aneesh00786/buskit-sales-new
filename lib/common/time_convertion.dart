

import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class TimeUtils {
 
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
    
    return 'Australia/Melbourne'; 
  }

 
  static String formatTimeInZone(DateTime dateTime, {String? timeZoneName, String format = 'hh:mm:ss a'}) {
    try {
     
      final targetZone = timeZoneName ?? _getCompanyTimeZone();
      final location = tz.getLocation(targetZone);
      
      
      final utcDateTime = DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );

     
      final tz.TZDateTime timeInZone = tz.TZDateTime.from(utcDateTime, location);
      
      return DateFormat(format).format(timeInZone);
    } catch (e) {
      debugPrint('🚨 Error converting time for zone: $e');
   
      return DateFormat(format).format(dateTime);
    }
  }
}