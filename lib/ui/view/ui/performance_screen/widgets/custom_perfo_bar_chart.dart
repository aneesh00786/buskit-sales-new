// ignore_for_file: use_build_context_synchronously

import 'dart:developer' as dev;
import 'dart:math';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
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
    return widget.categoryPerformance.isEmpty
        ? SizedBox(
            height: 200, // Set an appropriate height
            child: Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        : Column(
            children: [
              Consumer<CustomersProvider>(
                builder: (context, provider, child) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(Colors.blue),
                        thickness: MaterialStateProperty.all(5),
                        radius: const Radius.circular(8),
                      ),
                      child: Scrollbar(
                        controller: Provider.of<DashboardProvider>(context,
                                listen: false)
                            .scrollController,
                        interactive: true,
                        thickness: 5,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: SingleChildScrollView(
                            controller: Provider.of<DashboardProvider>(context,
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
                                    alignment: BarChartAlignment.spaceAround,
                                    barGroups: provider.barGroups,
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: getLeftTitles,
                                          reservedSize: 40,
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
                                          CategoryPerformance perf = widget
                                              .categoryPerformance
                                              .firstWhere(
                                            (performance) =>
                                                performance.category ==
                                                widget
                                                    .categoryPerformance[index]
                                                    .category,
                                          );
                                          _showSalesmanPopup(
                                              perf.cid ?? 0,
                                              widget.categoryPerformance[index]
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
                        color: const Color(0xff15396a), label: 'Projection'),
                  _buildLegend(
                      color: const Color(0xff7a8f3d), label: 'Actuals'),
                ],
              ),
            ],
          );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       Consumer<CustomersProvider>(
  //         builder: (context, provider, child) => Expanded(
  //           child: Padding(
  //             padding: const EdgeInsets.only(bottom: 8.0),
  //             child: ScrollbarTheme(
  //               data: ScrollbarThemeData(
  //                 thumbColor: MaterialStateProperty.all(Colors.blue),
  //                 thickness: MaterialStateProperty.all(5),
  //                 radius: const Radius.circular(8),
  //               ),
  //               child: Scrollbar(
  //                 controller:
  //                     Provider.of<DashboardProvider>(context, listen: false)
  //                         .scrollController,
  //                 interactive: true,
  //                 thickness: 5,
  //                 thumbVisibility: true,
  //                 trackVisibility: true,
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(bottom: 10.0),
  //                   child: SingleChildScrollView(
  //                     controller:
  //                         Provider.of<DashboardProvider>(context, listen: false)
  //                             .scrollController,
  //                     scrollDirection: Axis.horizontal,
  //                     physics: const ClampingScrollPhysics(),
  //                     child: SizedBox(
  //                       width: provider.barGroups.length * 66.0,
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(top: 3.0),
  //                         child: BarChart(
  //                           BarChartData(
  //                             alignment: BarChartAlignment.spaceAround,
  //                             barGroups: provider.barGroups,
  //                             titlesData: FlTitlesData(
  //                               leftTitles: AxisTitles(
  //                                 sideTitles: SideTitles(
  //                                   showTitles: true,
  //                                   getTitlesWidget: getLeftTitles,
  //                                   reservedSize: 40,
  //                                 ),
  //                               ),
  //                               bottomTitles: AxisTitles(
  //                                 sideTitles: SideTitles(
  //                                   showTitles: true,
  //                                   getTitlesWidget: getBottomTitles,
  //                                   reservedSize: 40,
  //                                 ),
  //                               ),
  //                               topTitles: AxisTitles(
  //                                 sideTitles: SideTitles(showTitles: false),
  //                               ),
  //                               rightTitles: AxisTitles(
  //                                 sideTitles: SideTitles(showTitles: false),
  //                               ),
  //                             ),
  //                             borderData: FlBorderData(
  //                               show: true,
  //                               border: Border.all(
  //                                 color: const Color(0xffe0e0e0),
  //                                 width: 0.9,
  //                               ),
  //                             ),
  //                             barTouchData: BarTouchData(
  //                               touchCallback: (FlTouchEvent event,
  //                                   BarTouchResponse? touchResponse) {
  //                                 if (touchResponse != null &&
  //                                     touchResponse.spot != null &&
  //                                     event is FlTapUpEvent) {
  //                                   final int index = touchResponse
  //                                       .spot!.touchedBarGroupIndex;
  //                                   CategoryPerformance perf =
  //                                       widget.categoryPerformance.firstWhere(
  //                                     (performance) =>
  //                                         performance.category ==
  //                                         widget.categoryPerformance[index]
  //                                             .category,
  //                                   );
  //                                   _showSalesmanPopup(
  //                                       perf.cid ?? 0,
  //                                       widget.categoryPerformance[index]
  //                                               .category ??
  //                                           '');
  //                                 }
  //                               },
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           if (widget.targetType == "1")
  //             _buildLegend(color: const Color(0xff3b6491), label: 'Target'),
  //           if (widget.staffProjection == "1")
  //             _buildLegend(color: const Color(0xff15396a), label: 'Projection'),
  //           _buildLegend(color: const Color(0xff7a8f3d), label: 'Actuals'),
  //         ],
  //       ),
  //     ],
  //   );
  // }

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
