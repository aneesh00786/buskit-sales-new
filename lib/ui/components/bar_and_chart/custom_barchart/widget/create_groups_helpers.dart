import 'dart:math';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

List<BarChartGroupData> createBarGroups({
  required List<Category> allCategory,
  required String staffProjection,
  required List<CategoryPerformancee> categoryPerformance,
  required List<MonthlyPerformancee> monthlyPerformance,
  required bool isMonthly,
  required bool isDayOrRange,
}) {
  return allCategory.asMap().entries.map((entry) {
    final int index = entry.key;
    final Category category = entry.value;
    CategoryPerformancee defaultPerf = CategoryPerformancee(
      cid: -1,
      category: category.category,
      actualProjection: 0.0,
      actualTarget: 0.0,
      actualSales: 0.0,
      salesman: [],
    );
    final CategoryPerformancee perf = isMonthly
        ? defaultPerf
        : categoryPerformance.firstWhere(
            (p) => p.category == category.category,
            orElse: () {
              dev.log(
                  'No match found in categoryPerformance for ${category.category}');
              return defaultPerf;
            },
          );
    final MonthlyPerformancee monthPerf = monthlyPerformance.firstWhere(
      (p) => p.cid == category.category,
      orElse: () => MonthlyPerformancee(
        cid: '',
        actualProjection: 0.0,
        actualSales: 0.0,
        actualTarget: 0.0,
        barType: '',
        month: '',
        week: '',
        year: 0,
      ),
    );
    final num target =
        isMonthly ? monthPerf.actualTarget ?? 0.0 : perf.actualTarget ?? 0.0;
    final num projection = isMonthly
        ? monthPerf.actualProjection ?? 0.0
        : perf.actualProjection ?? 0.0;
    final num actual =
        isMonthly ? monthPerf.actualSales ?? 0.0 : perf.actualSales ?? 0.0;
    List<BarChartRodData> rods = [];
    if (!isDayOrRange) {
      rods.add(
        BarChartRodData(
          toY: target.toDouble(),
          color: const Color(0xff3b6491),
          width: 8,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
      );

      if (staffProjection == "1") {
        rods.add(
          BarChartRodData(
            toY: projection.toDouble(),
            color: const Color(0xff15396a),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
        );
      }
    }
    rods.add(
      BarChartRodData(
        toY: actual.toDouble(),
        color: const Color(0xff7a8f3d),
        width: 8,
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
    );

    return BarChartGroupData(
      x: index,
      barRods: rods,
    );
  }).toList();
}

Widget getBottomTitles(
    double value, TitleMeta meta, List<Category> allCategory) {
  Widget text = Transform.rotate(
    angle: -1.34 / 4,
    child: MyRegularText(
      label: allCategory[value.toInt()].category ?? '',
      fontWeight: FontWeight.w500,
      fontSize: 11,
      color: Colors.black,
    ),
  );
  return Container(
    margin: const EdgeInsets.only(top: 12),
    child: text,
  );
}

Widget getLeftTitles(double value, TitleMeta meta) {
  return MyRegularText(
    label: value.toInt().toString(),
    fontSize: 8.6,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
}

double getRoundedUpperLimit({required List<BarChartGroupData> barGroups}) {
  final maxValue = barGroups
      .map((group) =>
          group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
      .reduce((a, b) => a > b ? a : b);
  return (maxValue / 1000).ceil() * 1000;
}

double getDynamicReservedSize({required List<BarChartGroupData> barGroups}) {
  final maxValue = barGroups
      .map((group) =>
          group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
      .reduce((a, b) => a > b ? a : b);
  int digitCount = maxValue.toInt().toString().length;
  return (digitCount * 8);
}

Widget getBottomTitlesDummy(
  double value,
  TitleMeta meta,
  List<Category> allCategory,
) {
  Widget text = Transform.rotate(
    angle: -1.34 / 4,
    child: MyRegularText(
      label: allCategory[value.toInt()].category ?? '',
      fontWeight: FontWeight.w500,
      fontSize: 11,
      color: Colors.white,
    ),
  );
  return Container(
    margin: const EdgeInsets.only(top: 12),
    child: text,
  );
}

Widget buildLegend(
    {required Color color,
    required String label,
    required BuildContext context}) {
  return Row(
    children: [
      CircleAvatar(
        radius: ResponsiveInfo.isMobileDimension(context) ? 5.45 : 6.10,
        backgroundColor: color,
      ),
      const SizedBox(width: 2),
      MyRegularText(
        label: label,
        color: secondaryTextColor,
        fontSize: 11.6,
        fontWeight: FontWeight.w600,
      ),
      const SizedBox(width: 10),
    ],
  );
}
