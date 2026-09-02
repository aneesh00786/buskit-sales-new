// ignore_for_file: library_private_types_in_public_api

import 'dart:math';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/salesman_popup.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomPerfoBarChart extends StatefulWidget {
  final List<CategoryPerformance> categoryPerformance;
  final List<ValueTargetDatum> valuePerformance;
  final String staffProjection;
  final String targetType;

  const CustomPerfoBarChart({
    super.key,
    required this.categoryPerformance,
    required this.valuePerformance,
    required this.staffProjection,
    required this.targetType,
  });

  @override
  _CustomPerfoBarChartState createState() => _CustomPerfoBarChartState();
}

class _CustomPerfoBarChartState extends State<CustomPerfoBarChart> {
  List<BarChartGroupData> barGroups = [];

  @override
  void initState() {
    final provider = Provider.of<CustomersProvider>(context, listen: false);
    super.initState();
    provider.createBarGroups(
        categoryPerformance: widget.categoryPerformance,
        valuePerformance: widget.valuePerformance,
        staffProjection: widget.staffProjection,
        targetType: widget.targetType);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        final maxBarValue = provider.barGroups.isNotEmpty
            ? provider.barGroups
                .map((group) => group.barRods.isNotEmpty
                    ? group.barRods
                        .map((rod) => rod.toY)
                        .reduce((a, b) => a > b ? a : b)
                    : 0)
                .reduce((a, b) => a > b ? a : b)
            : 0;

        final int magnitude = pow(
                10,
                maxBarValue == 0
                    ? 0
                    : maxBarValue.floor().toString().length - 1)
            .toInt();
        final double dynamicMaxY =
            ((maxBarValue / magnitude).ceil() * magnitude).toDouble();

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

        return (widget.targetType == '0'
                ? widget.valuePerformance.isEmpty
                : widget.categoryPerformance.isEmpty)
            ? const SizedBox(
                height: 200,
                child: Center(child: NodataWidget()),
              )
            : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(MaterialState.dragged)) {
                              return Colors.blueAccent.shade700;
                            }
                            return Colors.blueAccent.shade400;
                          }),
                          trackColor:
                              MaterialStateProperty.all(Colors.blue.shade50),
                          trackBorderColor:
                              MaterialStateProperty.all(Colors.blue.shade100),
                          thickness: MaterialStateProperty.all(6),
                          radius: const Radius.circular(10),
                          minThumbLength: 50,
                        ),
                        child: Stack(
                          children: [
                            Scrollbar(
                              controller: Provider.of<DashboardProvider>(
                                      context,
                                      listen: false)
                                  .scrollController,
                              interactive: true,
                              thickness: 5,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        double chartWidth =
                                            barGroups.length * 100.0;
                                        double minWidth = constraints.maxWidth;
                                        double finalWidth =
                                            chartWidth > minWidth
                                                ? chartWidth
                                                : minWidth;
                                        return SingleChildScrollView(
                                          controller:
                                              Provider.of<DashboardProvider>(
                                                      context,
                                                      listen: false)
                                                  .scrollController,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          child: SizedBox(
                                            width: finalWidth,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 3.0),
                                              child: BarChart(
                                                BarChartData(
                                                  alignment: BarChartAlignment
                                                      .spaceAround,
                                                  barGroups: provider.barGroups,
                                                  maxY: dynamicMaxY > 0
                                                      ? dynamicMaxY
                                                      : 100,
                                                  titlesData: FlTitlesData(
                                                    leftTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        interval:
                                                            dynamicInterval
                                                                .toDouble(),
                                                        getTitlesWidget:
                                                            getLeftTitles,
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
                                                        getTitlesWidget: (value,
                                                                meta) =>
                                                            getBottomTitles(
                                                                value,
                                                                meta,
                                                                widget
                                                                    .targetType,
                                                                widget
                                                                    .valuePerformance,
                                                                widget
                                                                    .categoryPerformance),
                                                        reservedSize: 40,
                                                      ),
                                                    ),
                                                    topTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    rightTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                  ),
                                                  borderData: FlBorderData(
                                                    show: true,
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFFE2E8F0),
                                                      width: 0.9,
                                                    ),
                                                  ),
                                                  barTouchData: BarTouchData(
                                                    touchCallback:
                                                        (FlTouchEvent event,
                                                            BarTouchResponse?
                                                                touchResponse) {
                                                      if (touchResponse !=
                                                              null &&
                                                          touchResponse.spot !=
                                                              null &&
                                                          event
                                                              is FlTapUpEvent) {
                                                        final int index =
                                                            touchResponse.spot!
                                                                .touchedBarGroupIndex;

                                                        CategoryPerformance
                                                            perf = widget
                                                                .categoryPerformance
                                                                .firstWhere(
                                                          (performance) =>
                                                              performance
                                                                  .category ==
                                                              widget
                                                                  .categoryPerformance[
                                                                      index]
                                                                  .category,
                                                        );
                                                        showSalesmanPopup(
                                                            perf.cid ?? 0,
                                                            widget
                                                                    .categoryPerformance[
                                                                        index]
                                                                    .category ??
                                                                '',
                                                            context,
                                                            widget
                                                                .staffProjection);
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                padding:
                                    const EdgeInsets.only(bottom: 0, top: 3),
                                color: white,
                                width: dynamicMaxY.toString().length * 7 + 10,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
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
                                          getTitlesWidget: (value, meta) =>
                                              getBottomTitles(
                                                  value,
                                                  meta,
                                                  widget.targetType,
                                                  widget.valuePerformance,
                                                  widget.categoryPerformance),
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildLegend(
                          color: const Color(0xff3b6491), label: 'Target'),
                      if (widget.staffProjection == "1")
                        buildLegend(
                            color: const Color(0xff15396a),
                            label: 'Projection'),
                      buildLegend(
                          color: const Color(0xff7a8f3d), label: 'Actuals'),
                    ],
                  ),
                ],
              );
      },
    );
  }
}
