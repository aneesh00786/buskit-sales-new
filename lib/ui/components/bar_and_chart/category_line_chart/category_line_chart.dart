import 'dart:developer' as dev;
import 'dart:math';

import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart/widget/show_salesman_popup.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:fl_chart/fl_chart.dart';

// ignore: must_be_immutable
class CustomBarChartCustomerDash extends StatefulWidget {
  final List<FullCategory> allCategory;
  final List<CategoryPerformancez> categoryPerformance;
  final String customerId;
  bool isScroll;

  final dynamic year;

  CustomBarChartCustomerDash({
    super.key,
    required this.allCategory,
    required this.categoryPerformance,
    required this.customerId,
    required this.year,
    this.isScroll = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomBarChartCustomerDashState createState() =>
      _CustomBarChartCustomerDashState();
}

class _CustomBarChartCustomerDashState
    extends State<CustomBarChartCustomerDash> {
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    super.initState();
    _createBarGroups();
  }

  void _createBarGroups() {
    barGroups = widget.allCategory.asMap().entries.map((entry) {
      int index = entry.key;
      FullCategory category = entry.value;

      CategoryPerformancez? perf = widget.categoryPerformance.firstWhere(
        (performance) => performance.category == category.categoryName,
        orElse: () => CategoryPerformancez(
          cid: -1,
          category: category.categoryName,
          totalPrice: 0,
        ),
      );

      double target = 0.0;
      try {
        target = perf.totalPrice.toDouble();
      } catch (e) {
        target = 0.0;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: target,
            color: const Color(0xff7a8f3d),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
        ],
      );
    }).toList();
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    Widget text = Transform.rotate(
      angle: -1.34 / 4,
      child: MyRegularText(
        label: widget.allCategory[value.toInt()].categoryName,
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
      fontSize: 10.6,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  double getDynamicReservedSize() {
    final maxValue = barGroups
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    int digitCount = maxValue.toInt().toString().length;
    return (digitCount * 8);
  }

  Widget getBottomTitlesDummy(double value, TitleMeta meta) {
    Widget text = Transform.rotate(
      angle: -1.34 / 4,
      child: MyRegularText(
        label: widget.allCategory[value.toInt()].categoryName,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        final maxBarValue = barGroups
            .map((group) => group.barRods
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
          dynamicInterval = 5000;
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
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
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
                        controller: provider.scrollController,
                        trackVisibility: true,
                        thumbVisibility: true,
                        radius: const Radius.circular(10),
                        thickness: 5,
                        interactive: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            controller: provider.scrollController,
                            child: SizedBox(
                              width: barGroups.length * 66.0,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    barGroups: barGroups,
                                    maxY: dynamicMaxY.toDouble(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: dynamicInterval.toDouble(),
                                          getTitlesWidget: getLeftTitles,
                                          reservedSize:
                                              dynamicMaxY.toString().length *
                                                      7 +
                                                  10,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: getBottomTitles,
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
                                    barTouchData: BarTouchData(
                                      touchCallback: (FlTouchEvent event,
                                          BarTouchResponse? touchResponse) {
                                        if (touchResponse != null &&
                                            touchResponse.spot != null &&
                                            event is FlTapUpEvent) {
                                          final int index = touchResponse
                                              .spot!.touchedBarGroupIndex;

                                          CategoryPerformancez perf = widget
                                              .categoryPerformance
                                              .firstWhere((performance) =>
                                                  performance.category ==
                                                  widget.allCategory[index]
                                                      .categoryName);

                                          showSalesmanPopup(
                                              cid: perf.cid,
                                              category: widget
                                                  .allCategory[index]
                                                  .categoryName,
                                              context: context,
                                              customerId: widget.customerId,
                                              year: widget.year);
                                        }
                                      },
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipPadding: EdgeInsets.zero,
                                        tooltipMargin: 8,
                                        getTooltipItem: (
                                          BarChartGroupData group,
                                          int groupIndex,
                                          BarChartRodData rod,
                                          int rodIndex,
                                        ) {
                                          return BarTooltipItem(
                                            rod.toY.toString(),
                                            const TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 0, top: 3),
                          color: white,
                          width: dynamicMaxY.toString().length * 7 + 10,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: dynamicMaxY.toDouble(),
                              // barGroups: barGroups,
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
                                    getTitlesWidget: getBottomTitlesDummy,
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
                                  color: Colors.transparent,
                                  width: 0.9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!widget.isScroll) ...[
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SizedBox(
                        width: barGroups.length * 66.0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: barGroups,
                              maxY: dynamicMaxY.toDouble(),
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
                                    getTitlesWidget: getBottomTitles,
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
                                    final int index = touchResponse
                                        .spot!.touchedBarGroupIndex;

                                    CategoryPerformancez perf = widget
                                        .categoryPerformance
                                        .firstWhere((performance) =>
                                            performance.category ==
                                            widget.allCategory[index]
                                                .categoryName);

                                    showSalesmanPopup(
                                        cid: perf.cid,
                                        category: widget
                                            .allCategory[index].categoryName,
                                        context: context,
                                        customerId: widget.customerId,
                                        year: widget.year);
                                  }
                                },
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipPadding: EdgeInsets.zero,
                                  tooltipMargin: 8,
                                  getTooltipItem: (
                                    BarChartGroupData group,
                                    int groupIndex,
                                    BarChartRodData rod,
                                    int rodIndex,
                                  ) {
                                    return BarTooltipItem(
                                      rod.toY.toString(),
                                      const TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 0, top: 3),
                        color: white,
                        width: dynamicMaxY.toString().length * 7 + 10,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: dynamicMaxY.toDouble(),
                            // barGroups: barGroups,
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
                                  getTitlesWidget: getBottomTitlesDummy,
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
                                color: Colors.transparent,
                                width: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  double getRoundedUpperLimit() {
    final maxValue = barGroups
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    return (maxValue / 50).ceil() * 50;
  }
}
