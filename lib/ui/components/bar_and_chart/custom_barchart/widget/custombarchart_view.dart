import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/salesman_popup.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/show_salesman_popup.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBarChartView extends StatelessWidget {
  final double finalWidth;
  final double dynamicMaxY;
  final int dynamicInterval;
  final List<BarChartGroupData> barGroups;
  final String targetType;
  final bool isDayOrRange;
  final String staffProjection;
  final List<Category> allCategory;
  final List<MonthlyPerformancee> monthlyPerformance;
  final List<CategoryPerformancee> categoryPerformance;

  const CustomBarChartView({
    super.key,
    required this.finalWidth,
    required this.dynamicMaxY,
    required this.dynamicInterval,
    required this.barGroups,
    required this.targetType,
    required this.isDayOrRange,
    required this.staffProjection,
    required this.allCategory,
    required this.monthlyPerformance,
    required this.categoryPerformance,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: finalWidth,
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: dynamicMaxY,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: dynamicInterval.toDouble(),
                  getTitlesWidget: (value, meta) => MyRegularText(
                    label: value.toInt().toString(),
                    fontSize: 8.6,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  reservedSize: dynamicMaxY.toString().length * 7 + 10,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final label = allCategory[value.toInt()].category ?? '';
                    return Transform.rotate(
                      angle: -1.34 / 4,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: MyRegularText(
                          label: label,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xffe0e0e0), width: 0.9),
            ),
            barTouchData: BarTouchData(
              touchCallback: (FlTouchEvent event, BarTouchResponse? touchRes) {
                if (touchRes?.spot != null && event is FlTapUpEvent) {
                  final int index = touchRes!.spot!.touchedBarGroupIndex;
                  final category = allCategory[index].category ?? '';

                  if (targetType == '0') {
                    final MonthlyPerformancee perf =
                        monthlyPerformance.firstWhere((e) => e.cid == category);
                    showSalesmanPopupMonthly(
                      cid: perf.cid ?? '',
                      month: perf.cid ?? '',
                      context: context,
                      isDayOrRange: isDayOrRange,
                      staffProjection: staffProjection,
                      targetType: targetType,
                    );
                  } else {
                    final CategoryPerformancee perf = categoryPerformance
                        .firstWhere((e) => e.category == category);
                    showSalesmanPopup(
                      cid: perf.cid ?? 0,
                      category: category,
                      context: context,
                      isDayOrRange: isDayOrRange,
                      staffProjection: staffProjection,
                      targetType: targetType,
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}