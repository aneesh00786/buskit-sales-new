import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/create_groups_helpers.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/salesman_popup.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/show_salesman_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

FlTitlesData getTitlesData(int maxY, int interval, List<Category> allCategory) {
  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: interval.toDouble(),
        getTitlesWidget: getLeftTitles,
        reservedSize: maxY.toString().length * 7 + 10,
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) =>
            getBottomTitles(value, meta, allCategory),
        reservedSize: 40,
      ),
    ),
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

BarTouchData getBarTouchData(
  BuildContext context,
  List<BarChartGroupData> barGroups,
  List<Category> allCategory,
  List<CategoryPerformancee> categoryPerformance,
  List<MonthlyPerformancee> monthlyPerformance,
  bool isDayOrRange,
  String staffProjection,
  String targetType,
) {
  return BarTouchData(
    touchCallback: (event, response) {
      if (response != null && response.spot != null && event is FlTapUpEvent) {
        final int index = response.spot!.touchedBarGroupIndex;

        if (targetType == '0') {
          final monthPerf = monthlyPerformance
              .firstWhere((p) => p.cid == allCategory[index].category);
          showSalesmanPopupMonthly(
            cid: monthPerf.cid ?? '',
            month: monthPerf.month ?? '',
            context: context,
            isDayOrRange: isDayOrRange,
            staffProjection: staffProjection,
            targetType: targetType,
          );
        } else {
          final perf = categoryPerformance
              .firstWhere((p) => p.category == allCategory[index].category);
          showSalesmanPopup(
            cid: perf.cid ?? 0,
            category: allCategory[index].category ?? '',
            context: context,
            isDayOrRange: isDayOrRange,
            staffProjection: staffProjection,
            targetType: targetType,
          );
        }
      }
    },
  );
}