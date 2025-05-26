// ignore_for_file: must_be_immutable

import 'dart:developer' as dev;
import 'dart:math';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/barchart_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/create_groups.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/salesman_popup.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view/ui/dashboard1/provider/dash_provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'widget/show_salesman_popup.dart';

class CustomBarChart extends StatefulWidget {
  final List<Category> allCategory;
  final List<CategoryPerformancee> categoryPerformance;
  final List<MonthlyPerformancee> monthlyPerformance;
  String staffProjection;
  String targetType;
  bool isScroll;
  bool isMonthly;
  bool isDayOrRange;

  CustomBarChart({
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
  // ignore: library_private_types_in_public_api
  _CustomBarChartState createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  List<BarChartGroupData> barGroups = [];

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
  }

  @override
  Widget build(BuildContext context) {
    final maxBarValue = barGroups.isEmpty
        ? 0.0
        : barGroups
            .map((group) => group.barRods.isEmpty
                ? 0.0
                : group.barRods
                    .map((rod) => rod.toY)
                    .reduce((a, b) => a > b ? a : b))
            .reduce((a, b) => a > b ? a : b);

    dev.log("MAX BAR VALUE : $maxBarValue");
    final int magnitude =
        pow(10, maxBarValue.toInt().toString().length - 1).toInt();
    final int dynamicMaxY = ((maxBarValue / magnitude).ceil()) * magnitude;
    final int dynamicInterval;
    if (dynamicMaxY >= 1000000000) {
      dynamicInterval = 200000000;
    } else if (dynamicMaxY >= 100000000) {
      dynamicInterval = 20000000;
    } else if (dynamicMaxY >= 10000000) {
      dynamicInterval = 2000000;
    } else if (dynamicMaxY >= 1000000) {
      dynamicInterval = 200000;
    } else if (dynamicMaxY >= 500000) {
      dynamicInterval = 100000;
    } else if (dynamicMaxY >= 200000) {
      dynamicInterval = 50000;
    } else if (dynamicMaxY >= 100000) {
      dynamicInterval = 20000;
    } else if (dynamicMaxY >= 50000) {
      dynamicInterval = 10000;
    } else if (dynamicMaxY >= 10000) {
      dynamicInterval = 2000;
    } else if (dynamicMaxY >= 5000) {
      dynamicInterval = 1000;
    } else if (dynamicMaxY >= 1000) {
      dynamicInterval = 500;
    } else if (dynamicMaxY >= 500) {
      dynamicInterval = 100;
    } else if (dynamicMaxY >= 100) {
      dynamicInterval = 50;
    } else if (dynamicMaxY >= 50) {
      dynamicInterval = 10;
    } else {
      dynamicInterval = 5;
    }
    return Column(
      children: [
        if (widget.isScroll) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.dragged)) {
                      return Colors.blueAccent.shade700;
                    }
                    return Colors.blueAccent.shade400;
                  }),
                  trackColor: WidgetStateProperty.all(Colors.blue.shade50),
                  trackBorderColor:
                      WidgetStateProperty.all(Colors.blue.shade100),
                  thickness: WidgetStateProperty.all(6),
                  radius: const Radius.circular(10),
                  minThumbLength: 50,
                ),
                child: Stack(
                  children: [
                    Scrollbar(
                      controller:
                          Provider.of<DashboardProvider>(context, listen: false)
                              .scrollController,
                      interactive: true,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                double chartWidth = barGroups.length * 66.0;
                                double minWidth = constraints.maxWidth;
                                double finalWidth = chartWidth > minWidth
                                    ? chartWidth
                                    : minWidth;
                                return SingleChildScrollView(
                                  controller: Provider.of<DashboardProvider>(
                                          context,
                                          listen: false)
                                      .scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  child: SizedBox(
                                    width: finalWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY: dynamicMaxY.toDouble(),
                                          barGroups: barGroups,
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval:
                                                    dynamicInterval.toDouble(),
                                                getTitlesWidget: getLeftTitles,
                                                reservedSize: dynamicMaxY
                                                            .toString()
                                                            .length *
                                                        7 +
                                                    10,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget:
                                                    (value, meta) =>
                                                        getBottomTitles(
                                                            value,
                                                            meta,
                                                            widget.allCategory),
                                                reservedSize: 40,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: Border.all(
                                              color: const Color(0xffe0e0e0),
                                              width: 0.9,
                                            ),
                                          ),
                                          barTouchData: widget.targetType == '0'
                                              ? BarTouchData(
                                                  touchCallback:
                                                      (FlTouchEvent event,
                                                          BarTouchResponse?
                                                              touchResponse) {
                                                    if (touchResponse != null &&
                                                        touchResponse.spot !=
                                                            null &&
                                                        event is FlTapUpEvent) {
                                                      final int index =
                                                          touchResponse.spot!
                                                              .touchedBarGroupIndex;

                                                      {
                                                        MonthlyPerformancee
                                                            perfMonth = widget
                                                                .monthlyPerformance
                                                                .firstWhere(
                                                          (performance) =>
                                                              performance.cid ==
                                                              widget
                                                                  .allCategory[
                                                                      index]
                                                                  .category,
                                                        );
                                                        showSalesmanPopupMonthly(
                                                            cid:
                                                                perfMonth.cid ??
                                                                    '',
                                                            month:
                                                                perfMonth.cid ??
                                                                    '',
                                                            context: context,
                                                            isDayOrRange: widget
                                                                .isDayOrRange,
                                                            staffProjection: widget
                                                                .staffProjection,
                                                            targetType: widget
                                                                .targetType);
                                                      }
                                                    }
                                                  },
                                                )
                                              : BarTouchData(
                                                  touchCallback:
                                                      (FlTouchEvent event,
                                                          BarTouchResponse?
                                                              touchResponse) {
                                                    if (touchResponse != null &&
                                                        touchResponse.spot !=
                                                            null &&
                                                        event is FlTapUpEvent) {
                                                      final int index =
                                                          touchResponse.spot!
                                                              .touchedBarGroupIndex;

                                                      {
                                                        CategoryPerformancee
                                                            perf = widget
                                                                .categoryPerformance
                                                                .firstWhere(
                                                          (performance) =>
                                                              performance
                                                                  .category ==
                                                              widget
                                                                  .allCategory[
                                                                      index]
                                                                  .category,
                                                        );

                                                        showSalesmanPopup(
                                                          cid: perf.cid ?? 0,
                                                          category: widget
                                                                  .allCategory[
                                                                      index]
                                                                  .category ??
                                                              '',
                                                          context: context,
                                                          isDayOrRange: widget
                                                              .isDayOrRange,
                                                          staffProjection: widget
                                                              .staffProjection,
                                                          targetType:
                                                              widget.targetType,
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    BarChartDataWidget(
                        dynamicMaxY: dynamicMaxY,
                        dynamicInterval: dynamicInterval,
                        widget: widget),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (!widget.isScroll) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: getRoundedUpperLimit(barGroups: barGroups),
                          barGroups: barGroups,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: dynamicInterval.toDouble(),
                                getTitlesWidget: getLeftTitles,
                                reservedSize:
                                    dynamicMaxY.toString().length * 7 + 10,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) =>
                                    getBottomTitles(
                                        value, meta, widget.allCategory),
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xffe0e0e0),
                              width: 0.9,
                            ),
                          ),
                          barTouchData: BarTouchData(
                            touchCallback: (FlTouchEvent event,
                                BarTouchResponse? touchResponse) {
                              if (touchResponse != null &&
                                  touchResponse.spot != null &&
                                  event is FlTapUpEvent) {
                                final int index =
                                    touchResponse.spot!.touchedBarGroupIndex;
                                CategoryPerformancee perf =
                                    widget.categoryPerformance.firstWhere(
                                  (performance) =>
                                      performance.category ==
                                      widget.allCategory[index].category,
                                );
                                showSalesmanPopup(
                                  cid: perf.cid ?? 0,
                                  category:
                                      widget.allCategory[index].category ?? '',
                                  context: context,
                                  isDayOrRange: widget.isDayOrRange,
                                  staffProjection: widget.staffProjection,
                                  targetType: widget.targetType,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  BarChartDataWidget(
                        dynamicMaxY: dynamicMaxY,
                        dynamicInterval: dynamicInterval,
                        widget: widget),

                  // Commented Code ========
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 10.0),
                  //   child: Container(
                  //     padding: const EdgeInsets.only(bottom: 0, top: 3),
                  //     color: white,
                  //     width: dynamicMaxY.toString().length * 7 + 10,
                  //     child: BarChart(
                  //       BarChartData(
                  //         alignment: BarChartAlignment.spaceAround,
                  //         maxY: dynamicMaxY.toDouble(),
                  //         titlesData: FlTitlesData(
                  //           leftTitles: AxisTitles(
                  //             sideTitles: SideTitles(
                  //               showTitles: true,
                  //               interval: dynamicInterval.toDouble(),
                  //               getTitlesWidget: getLeftTitles,
                  //               reservedSize:
                  //                   dynamicMaxY.toString().length * 7 + 10,
                  //             ),
                  //           ),
                  //           bottomTitles: AxisTitles(
                  //             sideTitles: SideTitles(
                  //               showTitles: true,
                  //               getTitlesWidget: (value, meta) =>
                  //                   getBottomTitlesDummy(
                  //                       value, meta, widget.allCategory),
                  //               reservedSize: 40,
                  //             ),
                  //           ),
                  //           topTitles: AxisTitles(
                  //             sideTitles: SideTitles(showTitles: false),
                  //           ),
                  //           rightTitles: AxisTitles(
                  //             sideTitles: SideTitles(showTitles: false),
                  //           ),
                  //         ),
                  //         borderData: FlBorderData(
                  //           show: true,
                  //           border: Border.all(
                  //             color: Colors.transparent,
                  //             width: 0.9,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!widget.isDayOrRange) ...[
              buildLegend(
                  color: const Color(0xff3b6491),
                  label: 'Target',
                  context: context),
              if (widget.staffProjection == "1")
                buildLegend(
                    color: const Color(0xff15396a),
                    label: 'Projection',
                    context: context),
            ],
            buildLegend(
                color: const Color(0xff7a8f3d),
                label: 'Actuals',
                context: context),
          ],
        ),
      ],
    );
  }
}


