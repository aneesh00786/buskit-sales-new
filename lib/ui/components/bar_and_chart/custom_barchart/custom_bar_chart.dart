// ignore_for_file: must_be_immutable
import 'dart:math';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/bar_chart_legend.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/create_groups_helpers.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/scrollable_chart_view.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/static_chart_view.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
class CustomBarChart extends StatefulWidget {
  final List<Category> allCategory;
  final List<CategoryPerformancee> categoryPerformance;
  final List<MonthlyPerformancee> monthlyPerformance;
  final String staffProjection;
  final String targetType;
  final bool isScroll;
  final bool isMonthly;
  final bool isDayOrRange;

  const CustomBarChart({
    super.key,
    required this.allCategory,
    required this.categoryPerformance,
    required this.monthlyPerformance,
    required this.staffProjection,
    required this.targetType,
    this.isScroll = true,
    this.isMonthly = false,
    this.isDayOrRange = false,
  });

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  List<BarChartGroupData>? barGroups;
  int? dynamicMaxY;
  int? dynamicInterval;
  @override
  void initState() {
    super.initState();
    barGroups = createBarGroups(
      allCategory: widget.allCategory,
      categoryPerformance: widget.categoryPerformance,
      isDayOrRange: widget.isDayOrRange,
      isMonthly: widget.isMonthly,
      monthlyPerformance: widget.monthlyPerformance,
      staffProjection: widget.staffProjection,
    );
    _calculateYAxisMetrics();
  }

  void _calculateYAxisMetrics() {
    final maxVal = barGroups!
        .expand((g) => g.barRods)
        .map((rod) => rod.toY)
        .fold<double>(0.0, max);

    final magnitude = pow(10, maxVal.toInt().toString().length - 1).toInt();
    dynamicMaxY = ((maxVal / magnitude).ceil()) * magnitude;

    dynamicInterval = [
      [1000000000, 200000000],
      [100000000, 20000000],
      [10000000, 2000000],
      [1000000, 200000],
      [500000, 100000],
      [200000, 50000],
      [100000, 20000],
      [50000, 10000],
      [10000, 2000],
      [5000, 1000],
      [1000, 500],
      [500, 100],
      [100, 50],
      [50, 10],
    ].firstWhere((pair) => dynamicMaxY! >= pair[0], orElse: () => [0, 5])[1];
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.isScroll
              ? ScrollableChartView(
                  barGroups: barGroups ?? [],
                  dynamicMaxY: dynamicMaxY ?? 0,
                  dynamicInterval: dynamicInterval ?? 0,
                  widget: widget,
                )
              : StaticChartView(
                  barGroups: barGroups ?? [],
                  dynamicMaxY: dynamicMaxY ?? 0,
                  dynamicInterval: dynamicInterval ?? 0,
                  widget: widget,
                ),
        ),
        BarChartLegend(
          isDayOrRange: widget.isDayOrRange,
          staffProjection: widget.staffProjection,
        ),
      ],
    );
  }
}


