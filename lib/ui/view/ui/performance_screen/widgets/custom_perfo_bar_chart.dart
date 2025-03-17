// ignore_for_file: use_build_context_synchronously, deprecated_member_use, library_private_types_in_public_api

import 'dart:math';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomPerfoBarChart extends StatefulWidget {
  final List<CategoryPerformance> categoryPerformance;
  final String staffProjection;
  final String targetType;
  const CustomPerfoBarChart({
    super.key,
    required this.categoryPerformance,
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
        staffProjection: widget.staffProjection,
        targetType: widget.targetType);
  }

  void _showSalesmanPopup(int cid, String category) async {
    bool isConnected = await ConnectivityService().isOnline();
    if (isConnected) {
      showDialog(
        context: context,
        builder: (context) {
          return Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              provider.fetchchartCategoryPerformmenc(cid);
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.zero,
                titlePadding: EdgeInsets.zero,
                content: FutureBuilder<ResponseModelCp>(
                  future: provider.responseModelCp,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      final categories = snapshot.data!.data;
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  dialogCloseButton1(context, red)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                headingRowHeight: 40,
                                dataRowHeight: 30,
                                columnSpacing: 40,
                                headingRowColor: WidgetStatePropertyAll(
                                    Colors.blueGrey.shade50),
                                border: TableBorder.all(
                                    color: Colors.grey, width: 1),
                                columns: [
                                  const DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Name',
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (widget.targetType == "1")
                                    const DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Target',
                                        fontSize: 13,
                                      ),
                                    ),
                                  if (widget.staffProjection == "1")
                                    const DataColumn(
                                      label: DialogTableHeaderText(
                                        text: 'Projection',
                                        fontSize: 13,
                                      ),
                                    ),
                                  const DataColumn(
                                    label: DialogTableHeaderText(
                                      text: 'Actual',
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                rows: categories!.map((s) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            s.fullname,
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (widget.targetType == "1")
                                        DataCell(
                                          Center(
                                            child: Text(
                                              formatAmount(s.targetTotal),
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (widget.staffProjection == "1")
                                        DataCell(
                                          Center(
                                            child: Text(
                                              formatAmount(s.projectionTotal),
                                              style: const TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            formatAmount(s.orderTotal),
                                            style: const TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const NodataWidget();
                    }
                  },
                ),
              );
            },
          );
        },
      );
    } else {
      showNoInternetSnackBar(context);
    }
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= 0 &&
        value.toInt() < widget.categoryPerformance.length) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        child: Transform.rotate(
          angle: -1.34 / 4,
          child: MyRegularText(
            label: widget.categoryPerformance[value.toInt()].category ?? '',
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: Colors.black,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return MyRegularText(
      label: value.toInt().toString(),
      fontSize: 8.6,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        // Calculate maxBarValue from provider.barGroups
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


        return widget.categoryPerformance.isEmpty
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
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
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: SingleChildScrollView(
                                  controller: Provider.of<DashboardProvider>(
                                          context,
                                          listen: false)
                                      .scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const ClampingScrollPhysics(),
                                  child: SizedBox(
                                    width: provider.barGroups.length * 66.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          barGroups: provider.barGroups,
                                          maxY: dynamicMaxY > 0
                                              ? dynamicMaxY
                                              : 100,
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
                                                    touchResponse) {
                                              if (touchResponse != null &&
                                                  touchResponse.spot != null &&
                                                  event is FlTapUpEvent) {
                                                final int index = touchResponse
                                                    .spot!.touchedBarGroupIndex;

                                                CategoryPerformance perf =
                                                    widget.categoryPerformance
                                                        .firstWhere(
                                                  (performance) =>
                                                      performance.category ==
                                                      widget
                                                          .categoryPerformance[
                                                              index]
                                                          .category,
                                                );
                                                _showSalesmanPopup(
                                                    perf.cid ?? 0,
                                                    widget
                                                            .categoryPerformance[
                                                                index]
                                                            .category ??
                                                        '');
                                              }
                                            },
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
                                          // reservedSize: getDynamicReservedSize(),
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
                      if (widget.targetType == "1")
                        _buildLegend(
                            color: const Color(0xff3b6491), label: 'Target'),
                      if (widget.staffProjection == "1")
                        _buildLegend(
                            color: const Color(0xff15396a),
                            label: 'Projection'),
                      _buildLegend(
                          color: const Color(0xff7a8f3d), label: 'Actuals'),
                    ],
                  ),
                ],
              );
      },
    );
  }
  
  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 6,
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
}
