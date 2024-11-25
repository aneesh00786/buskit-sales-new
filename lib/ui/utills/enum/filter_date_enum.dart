import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:flutter/cupertino.dart';

enum FilterDateEnum {
  thisMonth,
  today,
  thisWeek,
  thisYear,
  range,
}

extension FilterDateExtension on FilterDateEnum {
  String get name {
    switch (this) {
      case FilterDateEnum.thisMonth:
        return "This Month";
      case FilterDateEnum.today:
        return "Today";
      case FilterDateEnum.thisWeek:
        return "This Week";
      case FilterDateEnum.thisYear:
        return "This Year";
      case FilterDateEnum.range:
        return "Range";
    }
  }

  (DateTime? startDate, DateTime? endDate) selectDateRange(BuildContext context,
      {DateTime? startDate, DateTime? endDate}) {
    switch (this) {
      case FilterDateEnum.thisYear:
        return NkCommonFunction.todayDate;
      case FilterDateEnum.today:
        return NkCommonFunction.yesterdayDate;
      case FilterDateEnum.thisWeek:
        return NkCommonFunction.thisWeekDate;
      case FilterDateEnum.thisMonth:
        return NkCommonFunction.thisMonthDate;
      case FilterDateEnum.range:
        return NkCommonFunction.dateRange(context, startDate ?? DateTime.now(),
            endDate ?? DateTime.now().add(const Duration(days: 1)));
    }
  }
}
