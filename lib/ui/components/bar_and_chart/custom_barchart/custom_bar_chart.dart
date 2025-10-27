// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use
import 'dart:math';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/barchart_table_dialog/bar_chart_table_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class CustomBarChart extends StatefulWidget {
  final List<Category> allCategory;
  final List<CategoryPerformancee> categoryPerformance;
  final List<MonthlyPerformancee> monthlyPerformance;
  String staffProjection;
  String categoryTarget;
  bool isScroll;
  bool isMonthly;
  bool isDayOrRange;

  CustomBarChart({
    super.key,
    required this.allCategory,
    required this.categoryPerformance,
    required this.monthlyPerformance,
    required this.staffProjection,
    required this.categoryTarget,
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
    _createBarGroups();
  }

  void _createBarGroups() {
    barGroups = widget.allCategory.asMap().entries.map((entry) {
      int index = entry.key;
      Category category = entry.value;

      CategoryPerformancee? perf = widget.categoryPerformance.firstWhere(
        (performance) => performance.category == category.category,
        orElse: () => CategoryPerformancee(
          cid: -1,
          category: category.category,
          actualProjection: 0.0,
          actualTarget: 0.0,
          actualSales: 0.0,
          salesman: [],
        ),
      );

      MonthlyPerformancee? monthPerf = widget.monthlyPerformance
          .firstWhere((performance) => performance.cid == category.category,
              orElse: () => MonthlyPerformancee(
                    cid: '',
                    actualProjection: 0.0,
                    actualSales: 0.0,
                    actualTarget: 0.0,
                    barType: '',
                    month: '',
                    week: '',
                    year: 0,
                  ));

      num target = widget.isMonthly
          ? monthPerf.actualTarget ?? 0.0
          : perf.actualTarget ?? 0.0;
      num projection = widget.isMonthly
          ? monthPerf.actualProjection ?? 0.0
          : perf.actualProjection ?? 0.0;
      num actual = widget.isMonthly
          ? monthPerf.actualSales ?? 0.0
          : perf.actualSales ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          if (!widget.isDayOrRange) ...[
            BarChartRodData(
              toY: target.toDouble(),
              color: const Color(0xff3b6491),
              width: 8,
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide.none,
            ),
            if (widget.staffProjection == "1")
              BarChartRodData(
                toY: projection.toDouble(),
                color: const Color(0xff15396a),
                width: 8,
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide.none,
              ),
          ],
          BarChartRodData(
            toY: actual.toDouble(),
            color: const Color(0xff7a8f3d),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ),
        ],
      );
    }).toList();
  }

  void _showSalesmanPopup(int cid, String category) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            provider.fetchchartCategoryPerformmenc(cid);
            return FutureBuilder<ResponseModelCp>(
              future: provider.responseModelCp,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final categories = snapshot.data!.data;
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showBarchartDialog(
                        context,
                        category,
                        categories ?? [],
                        widget.categoryTarget,
                        widget.staffProjection,
                        provider,
                        cid,
                        isDayOrRange: widget.isDayOrRange);
                  });
                  return const SizedBox.shrink();
                } else {
                  return const AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Center(
                      child: Text('No data available'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _showSalesmanPopupMonthly(String cid, String month) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            provider.fetchchartValuePerformance(cid, "Month");
            return FutureBuilder<ResponseModelCp>(
              future: provider.responseModelNewCp,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final categories = snapshot.data!.data;
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showBarchartDialog(
                        context,
                        cid,
                        categories ?? [],
                        widget.categoryTarget,
                        widget.staffProjection,
                        provider,
                        0,
                        isDayOrRange: widget.isDayOrRange);
                  });
                  return const SizedBox.shrink();
                } else {
                  return const AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    content: Center(
                      child: Text('No data available'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    String? categoryName = widget.allCategory[index].category;

    Widget text = GestureDetector(
      onTap: () async {
        final isConnected = await ConnectivityService().isOnline();

        if (!isConnected) {
          showCustomToastDisplay(context, "You are Offline!", red, Icons.close);
        } else {
          if (widget.categoryTarget == '0') {
            try {
              MonthlyPerformancee perfMonth =
                  widget.monthlyPerformance.firstWhere(
                (performance) => performance.cid == categoryName,
              );
              if (perfMonth.actualProjection == 0 &&
                  perfMonth.actualSales == 0 &&
                  perfMonth.actualTarget == 0) {
                showCustomToastDisplay(
                    context, "No Record Found", red, Icons.close);
              } else {
                _showSalesmanPopupMonthly(
                    perfMonth.cid ?? '', perfMonth.cid ?? '');
              }
            } catch (e) {
              //
            }
          } else {
            try {
              CategoryPerformancee perf = widget.categoryPerformance.firstWhere(
                (performance) => performance.category == categoryName,
              );
              if (perf.actualProjection == 0 &&
                  perf.actualSales == 0 &&
                  perf.actualTarget == 0) {
                showCustomToastDisplay(
                    context, "No Record Found", red, Icons.close);
              } else {
                _showSalesmanPopup(perf.cid ?? 0, categoryName ?? '');
              }
            } catch (e) {
              //
            }
          }
        }
      },
      child: customUnderlinedText(categoryName ?? ''),
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: text,
    );
  }

  Widget getBottomTitlesDummy(double value, TitleMeta meta) {
    Widget text = MyRegularText(
      label: widget.allCategory[value.toInt()].category ?? '',
      fontWeight: FontWeight.w500,
      fontSize: 11,
      color: Colors.white,
    );
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: text,
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    // dev.log("value - ${value}");
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

  @override
  Widget build(BuildContext context) {
    final maxBarValue = barGroups.isNotEmpty
        ? barGroups
            .map((group) => group.barRods.isNotEmpty
                ? group.barRods
                    .map((rod) => rod.toY)
                    .reduce((a, b) => a > b ? a : b)
                : 0)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    int calculateNiceInterval(int maxY, int maxDivisions) {
      if (maxY <= 0) return 1;

      double roughInterval = maxY / maxDivisions;

      int exponent = (log(roughInterval) / ln10).floor();
      double base = pow(10, exponent).toDouble();

      List<double> steps = [1, 2, 5, 10];
      double niceInterval = steps.first;
      for (double step in steps) {
        if (base * step >= roughInterval) {
          niceInterval = base * step;
          break;
        }
      }

      return niceInterval.toInt();
    }

    final int magnitude =
        pow(10, maxBarValue.toInt().toString().length - 1).toInt();
    final int dynamicMaxY = ((maxBarValue / magnitude).ceil()) * magnitude;
    int maxDivisions = 6;
    int dynamicInterval = calculateNiceInterval(dynamicMaxY, maxDivisions);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.dragged)) {
                    return Colors.blueAccent.shade700;
                  }
                  return Colors.blueAccent.shade400;
                }),
                trackColor: MaterialStateProperty.all(Colors.blue.shade50),
                trackBorderColor:
                    MaterialStateProperty.all(Colors.blue.shade100),
                thickness: MaterialStateProperty.all(6),
                radius: const Radius.circular(10),
                minThumbLength: 50,
              ),
              child: Stack(
                children: [
                  /// MAIN SCROLLABLE CHART
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
                                double chartWidth = barGroups.length * 100.0;
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
                                      padding: const EdgeInsets.only(
                                          top: 3, bottom: 0),
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
                                                    getBottomTitles,
                                                reservedSize: 40,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            rightTitles: const AxisTitles(
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
                                                BarTouchResponse?
                                                    touchResponse) async {
                                              if (touchResponse != null &&
                                                  touchResponse.spot != null &&
                                                  event is FlTapUpEvent) {
                                                final isConnected =
                                                    await ConnectivityService()
                                                        .isOnline();

                                                if (!isConnected) {
                                                  showCustomToastDisplay(
                                                    context,
                                                    "You are Offline!",
                                                    red,
                                                    Icons.close,
                                                  );
                                                  return;
                                                }

                                                final int index = touchResponse
                                                    .spot!.touchedBarGroupIndex;

                                                if (widget.categoryTarget ==
                                                    '0') {
                                                  // Monthly performance
                                                  MonthlyPerformancee
                                                      perfMonth = widget
                                                          .monthlyPerformance
                                                          .firstWhere(
                                                    (performance) =>
                                                        performance.cid ==
                                                        widget
                                                            .allCategory[index]
                                                            .category,
                                                  );

                                                  _showSalesmanPopupMonthly(
                                                    perfMonth.cid ?? '',
                                                    perfMonth.cid ?? '',
                                                  );
                                                } else {
                                                  // Category performance
                                                  CategoryPerformancee perf =
                                                      widget.categoryPerformance
                                                          .firstWhere(
                                                    (performance) =>
                                                        performance.category ==
                                                        widget
                                                            .allCategory[index]
                                                            .category,
                                                  );

                                                  _showSalesmanPopup(
                                                    perf.cid ?? 0,
                                                    widget.allCategory[index]
                                                            .category ??
                                                        '',
                                                  );
                                                }
                                              }
                                            },
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                              tooltipPadding: EdgeInsets.zero,
                                              tooltipMargin: 8,
                                              getTooltipItem: (
                                                BarChartGroupData group,
                                                int groupIndex,
                                                BarChartRodData rod,
                                                int rodIndex,
                                              ) {
                                                return BarTooltipItem(
                                                  " ${rod.toY} ",
                                                  const TextStyle(
                                                    color: Colors.white,
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
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// FIXED LEFT TITLES
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      color: Colors.white, // background for axis area
                      width: dynamicMaxY.toString().length * 7 + 10,
                      padding: const EdgeInsets.only(top: 6, bottom: 53),
                      child: BarChart(
                        BarChartData(
                          minY: 0,
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
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: const [], // ✅ no bars here
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
            if (!widget.isDayOrRange) ...[
              // if (widget.categoryTarget == "1")
              _buildLegend(color: const Color(0xff3b6491), label: 'Target'),
              if (widget.staffProjection == "1")
                _buildLegend(
                    color: const Color(0xff15396a), label: 'Projection'),
            ],
            _buildLegend(color: const Color(0xff7a8f3d), label: 'Actuals'),
          ],
        ),
      ],
    );
  }

  double getRoundedUpperLimit() {
    final maxValue = barGroups
        .map((group) =>
            group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    return (maxValue / 1000).ceil() * 1000;
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 5),
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
}

Widget customUnderlinedText(String text) {
  return Stack(
    alignment: Alignment.centerLeft,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: MyRegularText(
          label: text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ),
      Positioned(
        bottom: 6,
        child: Container(
          height: 1.5,
          width: text.length * 8.0,
          color: primaryColor,
        ),
      ),
    ],
  );
}
