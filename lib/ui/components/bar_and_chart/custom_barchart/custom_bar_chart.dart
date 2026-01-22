// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use
import 'dart:developer' as dev;
import 'dart:math';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/barchart_table_dialog/bar_chart_table_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  _CustomBarChartState createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> {
  List<BarChartGroupData> barGroups = [];

  // State variables for filtering
 bool hideTarget = false;
  bool hideProjection = false;
  bool hideActuals = false;

  @override
  void initState() {
    super.initState();
    _createBarGroups();
  }

  // FIXED: Ensure chart updates when parent passes new data
  @override
  void didUpdateWidget(CustomBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allCategory != widget.allCategory ||
        oldWidget.categoryPerformance != widget.categoryPerformance ||
        oldWidget.monthlyPerformance != widget.monthlyPerformance ||
        oldWidget.staffProjection != widget.staffProjection ||
        oldWidget.categoryTarget != widget.categoryTarget) {
      _createBarGroups();
    }
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

      // Logic to determine which rods to show
      List<BarChartRodData> rods = [];

      // 1. Target Rod Logic
      if (!widget.isDayOrRange && !hideTarget) {
          rods.add(BarChartRodData(
            toY: target.toDouble(),
            color: const Color(0xff3b6491),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ));
      }
    //  if (!widget.isDayOrRange) {
    //     if (!hideTarget) { // Only check if we should hide it
    //       rods.add(BarChartRodData(
    //         toY: target.toDouble(),
    //         color: const Color(0xff3b6491),
    //         width: 8,
    //         borderRadius: BorderRadius.zero,
    //         borderSide: BorderSide.none,
    //       ));
    //     }
    //   }

      // 2. Projection Rod Logic
      if (!widget.isDayOrRange && widget.staffProjection == "1" && !hideProjection) {
          rods.add(BarChartRodData(
            toY: projection.toDouble(),
            color: const Color(0xff15396a),
            width: 8,
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide.none,
          ));
      }
    //  if (!widget.isDayOrRange && widget.staffProjection == "1") {
    //     if (!hideProjection) { // Only check if we should hide it
    //       rods.add(BarChartRodData(
    //         toY: projection.toDouble(),
    //         color: const Color(0xff15396a),
    //         width: 8,
    //         borderRadius: BorderRadius.zero,
    //         borderSide: BorderSide.none,
    //       ));
    //     }
    //   }

      // 3. Actuals Rod Logic
      // Show ONLY if we are NOT in TargetOnly mode AND NOT in ProjectionOnly mode
      if (!hideActuals) {
        rods.add(BarChartRodData(
          toY: actual.toDouble(),
          color: const Color(0xff7a8f3d),
          width: 8,
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ));
      }
    //  if (!hideActuals) { // Only check if we should hide it
    //     rods.add(BarChartRodData(
    //       toY: actual.toDouble(),
    //       color: const Color(0xff7a8f3d),
    //       width: 8,
    //       borderRadius: BorderRadius.zero,
    //       borderSide: BorderSide.none,
    //     ));
    //   }

      return BarChartGroupData(
        x: index,
        barRods: rods,
      );
    }).toList();
  }

  void _showSalesmanPopup(int cid, String category) {
    Provider.of<DashboardProvider>(context, listen: false)
        .fetchchartCategoryPerformmenc(cid);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
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
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.fetchchartValuePerformance(month, "year");

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
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
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      )
                    ],
                  );
                } else if (snapshot.hasData) {
                  final categories = snapshot.data!.data;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pop();
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
                  return const SizedBox.shrink();
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
            } catch (e) {}
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
            } catch (e) {}
          }
        }
      },
      child: Expanded(child: customUnderlinedText(categoryName ?? '')),
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
    return MyRegularText(
      label: value.toInt().toString(),
      fontSize: 10.6,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  double getDynamicReservedSize() {
    final maxValue = barGroups.isNotEmpty
        ? barGroups
            .map((group) => group.barRods.isNotEmpty
                ? group.barRods
                    .map((rod) => rod.toY)
                    .reduce((a, b) => a > b ? a : b)
                : 0)
            .reduce((a, b) => a > b ? a : b)
        : 0;
    int digitCount = maxValue.toInt().toString().length;
    return (digitCount * 8);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Global Max based on ALL data to ensure Y-axis is stable
    double globalMax = 0;
    for (var category in widget.allCategory) {
      CategoryPerformancee? perf = widget.categoryPerformance.firstWhere(
        (p) => p.category == category.category,
        orElse: () => CategoryPerformancee(
            cid: -1,
            category: category.category,
            actualProjection: 0,
            actualTarget: 0,
            actualSales: 0),
      );

      MonthlyPerformancee? monthPerf = widget.monthlyPerformance.firstWhere(
        (p) => p.cid == category.category,
        orElse: () => MonthlyPerformancee(
            cid: '', actualProjection: 0, actualSales: 0, actualTarget: 0),
      );

      num target = widget.isMonthly
          ? monthPerf.actualTarget ?? 0
          : perf.actualTarget ?? 0;
      num projection = widget.isMonthly
          ? monthPerf.actualProjection ?? 0
          : perf.actualProjection ?? 0;
      num actual = widget.isMonthly
          ? monthPerf.actualSales ?? 0
          : perf.actualSales ?? 0;
          if (!widget.isDayOrRange) {
        // ONLY consider Target for Max Height if it is NOT HIDDEN
        if (!hideTarget) {
           if (target > globalMax) globalMax = target.toDouble();
        }
        
        // ONLY consider Projection for Max Height if it is NOT HIDDEN
        if (widget.staffProjection == "1" && !hideProjection) {
           if (projection > globalMax) globalMax = projection.toDouble();
        }
      }
      
      // ONLY consider Actuals for Max Height if it is NOT HIDDEN
      if (!hideActuals) {
         if (actual > globalMax) globalMax = actual.toDouble();
      }
    }

    if (globalMax == 0) globalMax = 10;
    final maxBarValue = globalMax;

    

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
                trackColor: MaterialStateProperty.all(Colors.transparent),
                trackBorderColor:
                    MaterialStateProperty.all(Colors.transparent),
                thickness: MaterialStateProperty.all(6),
                radius: const Radius.circular(10),
                minThumbLength: 50,
              ),
              child: Stack(
                clipBehavior:Clip.none,
                children: [
                  Scrollbar(
                    controller:
                        Provider.of<DashboardProvider>(context, listen: false)
                            .scrollController,
                    interactive: true,
                    thumbVisibility: true,
                    trackVisibility: false,
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
                                                      Icons.close);
                                                  return;
                                                }
                                                final int index = touchResponse
                                                    .spot!.touchedBarGroupIndex;

                                                if (widget.categoryTarget ==
                                                    '0') {
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
                                                      perfMonth.cid ?? '');
                                                } else {
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
                                                          '');
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      color: Colors.white,
                      width: dynamicMaxY.toString().length * 7 + 10,
                      padding: const EdgeInsets.only(top: 6, bottom: 53),
                      child: BarChart(
                        BarChartData(
                          backgroundColor: Colors.transparent,
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
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: const [],
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
              // --- TARGET BUTTON ---
              _buildLegend(
                color: const Color(0xff3b6491),
                label: 'Target',
                opacity: hideTarget ? 0.3 : 1.0,
                onTap: () {
                  setState(() {
                    // 1. Toggle Target
                    hideTarget = !hideTarget;
                    
                 
                    _createBarGroups();
                  });
                },
              ),
              
              // --- PROJECTION BUTTON ---
              if (widget.staffProjection == "1")
                _buildLegend(
                  color: const Color(0xff15396a),
                  label: 'Projection',
                  opacity: hideProjection ? 0.3 : 1.0,
                  onTap: () {
                    setState(() {
                      // 1. Toggle Projection
                      hideProjection = !hideProjection;

                      // 2. Logic: If we show Projection, HIDE Actuals to Zoom in
                      // if (!hideProjection) {
                      //    hideActuals = true;
                      // }

                      _createBarGroups();
                    });
                  },
                ),
            ],

            // --- ACTUALS BUTTON ---
            _buildLegend(
              color: const Color(0xff7a8f3d),
              label: 'Actuals',
              opacity: hideActuals ? 0.3 : 1.0,
              onTap: () {
                setState(() {
                  // Simply toggle Actuals. 
                  // If turned ON, the loop in build() will see it, 
                  // find the huge value, and resize the Y-axis automatically.
                  hideActuals = !hideActuals;
                  _createBarGroups();
                });
              },
            ),
          ],
        ),
    
      ],
    );
  }



  Widget _buildLegend(
      {required Color color,
      required String label,
      VoidCallback? onTap,
      double opacity = 1.0}) {
    return InkWell(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: Row(
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
        ),
      ),
    );
  }
}
// Widget customUnderlinedText(String text) {
//   const int maxLength = 20; 
  
//   String displayText = text;
  
//   // Check if text is longer than the limit
//   if (text.length > maxLength) {
//     // Take the first 20 characters and add "..."
//     displayText = '${text.substring(0, maxLength)}...';
//   }

//   return Container(
//     decoration: const BoxDecoration(
//       border: Border(
//         bottom: BorderSide(
//           color: primaryColor,  // Make sure primaryColor is imported
//           width: 1.5,
//         ),
//       ),
//     ),
//     child: Padding(
//       padding: const EdgeInsets.only(bottom: 2.0),
//       child: MyRegularText(
//         label: displayText, 
//         style: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 13,
//           color: Colors.black,
//           overflow: TextOverflow.ellipsis, 
//         ),
//       ),
//     ),
//   );
// }

Widget customUnderlinedText(String text) {
 
  const int maxLength = 10; 
  
  String displayText = text;
  
  // Check if text is longer than the limit
  if (text.length > maxLength) {
    // Take the first 8 characters and add "..."
    displayText = '${text.substring(0, maxLength)}...';
  }
  // ---------------------------------

  return Stack(
    alignment: Alignment.centerLeft,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: MyRegularText(
          // Use the modified 'displayText' instead of the original 'text'
          label: displayText, 
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.black,
            // You can keep this as a failsafe, but the manual truncation handles it now
            overflow: TextOverflow.ellipsis, 
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 1.5,
          color: primaryColor,
        ),
      ),
    ],
  );
}



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
  _CustomBarChartCustomerDashState createState() =>
      _CustomBarChartCustomerDashState();
}

class _CustomBarChartCustomerDashState
    extends State<CustomBarChartCustomerDash> {
  List<BarChartGroupData> barGroups = [];
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _createBarGroups();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSalesmanPopup(dynamic cid, String category) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Consumer<CustomersProvider>(
          builder: (context, provider, child) {
            provider.fetchChartCategoryPerformance(
                widget.customerId, cid, widget.year);

            return FutureBuilder<ProductResponse>(
              future: provider.productResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitFadingCube(
                      color: primaryColor,
                      size: 20.0,
                    ),
                  );
                } else if (snapshot.hasError ||
                    snapshot.data?.data.isEmpty == true) {
                  return Dialog(
                    insetPadding:
                        isPhonePortrait(context) || isPhoneLandscape(context)
                            ? EdgeInsets.zero
                            : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 45,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Poppins_Regular',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              // dialogCloseButton(context, red),/////////////
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No data found',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final categories = snapshot.data!.data;

                  return Dialog(
                    insetPadding:
                        isPhonePortrait(context) || isPhoneLandscape(context)
                            ? EdgeInsets.zero
                            : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ScrollbarTheme(
                      data: const ScrollbarThemeData(
                        thickness: WidgetStatePropertyAll(5),
                        thumbColor: WidgetStatePropertyAll(Colors.blue),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height: 45,
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // dialogCloseButton(context, red),/////
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: DataTable(
                                    dataRowHeight: 50,
                                    headingRowHeight: 40,
                                    columnSpacing: 30,
                                    headingRowColor: WidgetStatePropertyAll(
                                        Colors.grey.shade300),
                                    border: TableBorder.all(color: Colors.grey),
                                    columns: const [
                                      DataColumn(
                                        label: DialogTableHeaderText(
                                          text: 'Product',
                                          fontSize: 13,
                                        ),
                                      ),
                                      DataColumn(
                                        label: DialogTableHeaderText(
                                          text: 'Invoice',
                                          fontSize: 13,
                                        ),
                                      ),
                                      DataColumn(
                                        label: DialogTableHeaderText(
                                          text: 'Quantity',
                                          fontSize: 13,
                                        ),
                                      ),
                                      DataColumn(
                                        label: DialogTableHeaderText(
                                          text: 'Price',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    rows: [
                                      ...categories.map((s) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Center(
                                              child: Text(
                                                '${s.productName} ${s.variationName}',
                                                style: const TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )),
                                            DataCell(Center(
                                              child: Text(
                                                s.orderId,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )),
                                            DataCell(Center(
                                              child: Text(
                                                '${s.quantity}',
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )),
                                            DataCell(Center(
                                              child: Text(
                                                formatAmount(s.totalPrice),
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )),
                                          ],
                                        );
                                      }),
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 50),
                                              child: const Text(
                                                'Total',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const DataCell(SizedBox.shrink()),
                                          const DataCell(SizedBox.shrink()),
                                          DataCell(
                                            Center(
                                              child: Text(
                                                formatAmount(
                                                    categories.fold<double>(
                                                  0.0,
                                                  (sum, s) =>
                                                      sum +
                                                      (num.parse(s.totalPrice)),
                                                )),
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            );
          },
        );
      },
    );
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
    int index = value.toInt();
    String? categoryName = widget.allCategory[index].categoryName;

    Widget text = GestureDetector(
      onTap: () {
        final perfIndex = widget.categoryPerformance.indexWhere(
          (performance) =>
              performance.category == widget.allCategory[index].categoryName,
        );

        if (perfIndex == -1) {
          showCustomToastDisplay(context, "No Record Found", red, Icons.close);
        } else {
          final perf = widget.categoryPerformance[perfIndex];
          if (perf.totalPrice == 0) {
            showCustomToastDisplay(
                context, "No Record Found", red, Icons.close);
          } else {
            _showSalesmanPopup(
                perf.cid, widget.allCategory[index].categoryName);
          }
        }
      },
      child: Expanded(child: customUnderlinedText(categoryName)),
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

        dev.log("MAX BAR VALUE : $maxBarValue");
        final int magnitude =
            pow(10, maxBarValue.toInt().toString().length - 1).toInt();
        final int dynamicMaxY = ((maxBarValue / magnitude).ceil()) * magnitude;
        int maxDivisions = 6;
        int dynamicInterval = calculateNiceInterval(dynamicMaxY, maxDivisions);
        return Column(
          children: [
            if (widget.isScroll) ...[
              Expanded(
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
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
                      Scrollbar(
                        controller: _scrollController,
                        trackVisibility: true,
                        thumbVisibility: true,
                        radius: const Radius.circular(10),
                        thickness: 5,
                        interactive: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: LayoutBuilder(builder: (context, constraints) {
                            double chartWidth = barGroups.length * 100.0;
                            double minWidth = constraints.maxWidth;
                            double finalWidth =
                                chartWidth > minWidth ? chartWidth : minWidth;

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              controller: _scrollController,
                              child: SizedBox(
                                width: finalWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      barGroups: barGroups,
                                      maxY: dynamicMaxY.toDouble(),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            interval:
                                                dynamicInterval.toDouble(),
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
                                                  Icons.close);
                                              return;
                                            }
                                            final int index = touchResponse
                                                .spot!.touchedBarGroupIndex;

                                            CategoryPerformancez perf = widget
                                                .categoryPerformance
                                                .firstWhere((performance) =>
                                                    performance.category ==
                                                    widget.allCategory[index]
                                                        .categoryName);

                                            _showSalesmanPopup(
                                                perf.cid,
                                                widget.allCategory[index]
                                                    .categoryName);
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
                            );
                          }),
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
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
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
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
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
                                    BarTouchResponse? touchResponse) async {
                                  if (touchResponse != null &&
                                      touchResponse.spot != null &&
                                      event is FlTapUpEvent) {
                                    final isConnected =
                                        await ConnectivityService().isOnline();
                                    if (!isConnected) {
                                      showCustomToastDisplay(context,
                                          "You are Offline!", red, Icons.close);
                                      return;
                                    }
                                    final int index = touchResponse
                                        .spot!.touchedBarGroupIndex;

                                    CategoryPerformancez perf = widget
                                        .categoryPerformance
                                        .firstWhere((performance) =>
                                            performance.category ==
                                            widget.allCategory[index]
                                                .categoryName);

                                    _showSalesmanPopup(perf.cid,
                                        widget.allCategory[index].categoryName);
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
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
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

