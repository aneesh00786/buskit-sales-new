library;

import 'package:intl/intl.dart';

class NKDateUtils {
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayFormat = DateFormat('dd');
  static final DateFormat _firstDayFormat = DateFormat('MMM dd');
  static final DateFormat _fullDayFormat = DateFormat('EEE dd MMM, yyyy');
  // static final DateFormat _apiDayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _apiDayFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _commonDayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _commonDayFormat2 = DateFormat('dd-MM-yyyy');
  static final DateFormat _commonFullDateTimeFormat =
      DateFormat('dd/MM/yyyy hh:mm');
  static final DateFormat _commonFullDateTimeFormat2 =
      DateFormat('dd/MM/yyyy  hh:mm a');
  static String commonFullDateTimeFormat(DateTime d) =>
      _commonFullDateTimeFormat.format(d);
  static String commonFullDateTimeFormat2(DateTime d) =>
      _commonFullDateTimeFormat2.format(d);
  static String formatMonth(DateTime d) => _monthFormat.format(d);

  static String formatDay(DateTime d) => _dayFormat.format(d);

  static String formatFirstDay(DateTime d) => _firstDayFormat.format(d);

  static String fullDayFormat(DateTime d) => _fullDayFormat.format(d);

  static String apiDayFormat(DateTime d) => _apiDayFormat.format(d);

  static String commonDayFormat(DateTime d) => _commonDayFormat.format(d);

  static String commonDayFormat2(DateTime d) => _commonDayFormat2.format(d);
  static final DateFormat _commonTimeFormat = DateFormat('hh:mm');
  static String commonTimeFormat(DateTime d) => _commonTimeFormat.format(d);
  
  static final DateFormat _commonTimeOnlyFormat = DateFormat('hh:mm a');
  static String commonTimeOnlyFormat(DateTime d) => _commonTimeOnlyFormat.format(d);

  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static const List months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  /// The list of days in a given month
  static List<DateTime> daysInMonth(DateTime month) {
    var first = firstDayOfMonth(month);
    // var daysBefore = first.weekday;
    // var firstToDisplay = first.subtract(Duration(days: daysBefore));
    var last = NKDateUtils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    // var lastToDisplay = last.add(Duration(days: daysAfter));
    return daysRange(first, last).toList();
  }

  static Iterable<DateTime> daysRange(DateTime first, DateTime last) {
    var listOfDates = List<DateTime>.generate(
        last.day, (i) => DateTime(first.year, first.month, i + 1));
    return listOfDates;
  }

  static bool isFirstDayOfMonth(DateTime day) {
    return isSameDay(firstDayOfMonth(day), day);
  }

  static bool isLastDayOfMonth(DateTime day) {
    return isSameDay(lastDayOfMonth(day), day);
  }

  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }

  static DateTime firstDayOfWeek(DateTime day) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    day = DateTime.utc(day.year, day.month, day.day, 12);

    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar works from Sunday - Monday
    var decreaseNum = day.weekday % 7;
    return day.subtract(Duration(days: decreaseNum));
  }

  static DateTime lastDayOfWeek(DateTime day) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    day = DateTime.utc(day.year, day.month, day.day, 12);

    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar's Week starts on Sunday
    var increaseNum = day.weekday % 7;
    return day.add(Duration(days: 7 - increaseNum));
  }

  /// The last day of a given month
  static DateTime lastDayOfMonth(DateTime month) {
    var beginningNextMonth = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1));
  }

  /// Returns a [DateTime] for each day the given range.
  ///
  /// [start] inclusive
  /// [end] exclusive
  static Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
    var i = start;
    var offset = start.timeZoneOffset;
    while (i.day <= end.day) {
      yield i;
      i = i.add(const Duration(days: 1));
      var timeZoneDiff = i.timeZoneOffset - offset;
      if (timeZoneDiff.inSeconds != 0) {
        offset = i.timeZoneOffset;
        i = i.subtract(Duration(seconds: timeZoneDiff.inSeconds));
      }
    }
  }

  /// Whether or not two times are on the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameWeek(DateTime a, DateTime b) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    a = DateTime.utc(a.year, a.month, a.day);
    b = DateTime.utc(b.year, b.month, b.day);

    var diff = a.toUtc().difference(b.toUtc()).inDays;
    if (diff.abs() >= 7) {
      return false;
    }

    var min = a.isBefore(b) ? a : b;
    var max = a.isBefore(b) ? b : a;
    var result = max.weekday % 7 - min.weekday % 7 >= 0;
    return result;
  }

  static DateTime previousMonth(DateTime m) {
    var year = m.year;
    var month = m.month;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return DateTime(year, month);
  }

  static DateTime nextMonth(DateTime m) {
    var year = m.year;
    var month = m.month;

    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }
    return DateTime(year, month);
  }

  static DateTime previousWeek(DateTime w) {
    return w.subtract(const Duration(days: 7));
  }

  static DateTime nextWeek(DateTime w) {
    return w.add(const Duration(days: 7));
  }

  static Duration difrancenceBetweenDate(DateTime a, DateTime b) {
    return b.difference(a);
  }

  static String formatDate(DateTime date) {
    //FORMAT LIKE "Thursday 03 March 2022"
    return DateFormat('EEEE dd MMMM yyyy').format(date);
  }

  static String formatDateYMD(DateTime date) {
    //FORMAT LIKE "Thursday 03 March 2022"
    return DateFormat('yMMMMd').format(date);
  }

  static String formatDateRemiders(DateTime date) {
    //FORMAT LIKE "Thursday 03 March 2022"
    return DateFormat('hh:mm').format(date);
  }

  static DateTime formatStringDateTime(String date) {
    //FORMAT LIKE "Thursday 03 March 2022"
    return DateFormat("dd-MM-yyyy hh:mm:ss").parse(date);
  }

  static DateTime formatStringUTCDateTime(String date) {
    //FORMAT LIKE "Thursday 03 March 2022"

    return DateTime.parse(date).toLocal();
  }

  static String timeFormat(Duration duration) {
    int seconds = duration.inSeconds;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else if (minutes > 0) {
      return '${minutes.remainder(60).toString().padLeft(2, '0')}:${seconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return seconds.remainder(60).toString().padLeft(2, '0');
    }
  }

  static DateTime yearStartDate(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime yearEndDate(DateTime date) {
    return DateTime(date.year, 12, 31);
  }
}
