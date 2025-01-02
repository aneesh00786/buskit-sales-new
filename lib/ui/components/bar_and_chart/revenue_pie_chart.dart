/// Package import
// import 'package:busskit_admin/ui/components/color/colors.dart';
// import 'package:busskit_admin/ui/utills/const_string.dart';
// import 'package:busskit_admin/ui/utills/extentions/string_extention.dart';
// import 'package:busskit_admin/ui/view/ui/dashboard/model/dashboard_response.dart';
// import 'package:busskit_admin/ui/theme/custom_fonts.dart';
// import 'package:busskit_admin/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
// import 'package:busskit_admin/ui/view/ui/dashboard1/provider/dash_models.dart';
// import 'package:busskit_admin/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// import 'package:busskit_admin/measurements/ResponsiveInfo.dart';
// import 'package:busskit_admin/ui/components/color/colors.dart';
// import 'package:busskit_admin/ui/components/common_size/nk_general_size.dart';
// import 'package:busskit_admin/ui/components/widgets/my_regular_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:syncfusion_flutter_charts/charts.dart';

import '../common_size/nk_general_size.dart';

/// Chart import

/// Local imports

/// Render the default doughnut chart.
// class DoughnutDefaultCustomerDash extends StatefulWidget {
//   final Revenu categoryData;

//   const DoughnutDefaultCustomerDash({Key? key, required this.categoryData})
//       : super(key: key);

//   @override
//   _DoughnutDefaultState createState() => _DoughnutDefaultState();
// }

// /// State class of doughnut chart.
// class _DoughnutDefaultState extends State<DoughnutDefault> {
//   _DoughnutDefaultState();

//   late TooltipBehavior _tooltip;

//   @override
//   void initState() {
//     _tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y%');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _buildDefaultDoughnutChart();
//   }

//   /// Return the circular chart with default doughnut series.
//   SfCircularChart _buildDefaultDoughnutChart() {
//     return SfCircularChart(
//       //margin: const EdgeInsets.only(left: 120),
//       legend: Legend(
//           itemPadding: 2,
//           textStyle: TextStyle(fontSize: 7),
//           isVisible: true,
//           overflowMode: LegendItemOverflowMode.scroll,
//           position: LegendPosition.bottom),
//       series: _getDefaultDoughnutSeries(),

//       centerX: '50%',

//       centerY: '50%',
//       tooltipBehavior: _tooltip,
//     );
//   }

//   /// Returns the doughnut series which need to be render.
//   List<DoughnutSeries<ChartSampleData, String>> _getDefaultDoughnutSeries() {
//     return <DoughnutSeries<ChartSampleData, String>>[
//       DoughnutSeries<ChartSampleData, String>(
//           radius: '80%',
//           explode: true,
//           explodeOffset: '16%',
//           dataSource: <ChartSampleData>[
//             ChartSampleData(
//                 text:
//                     "${widget.categoryData.totalSell?.percentage.toString() ?? "0"} %",
//                 x: "$totalString $revenue ${(widget.categoryData.totalSell?.totalPrice ?? '').nkValueWithCurrencySymbol}",
//                 y: widget.categoryData.totalSell?.percentage?.toDouble() ?? 0.0,
//                 color: revenueProgressBarColor),
//             ChartSampleData(
//                 text:
//                     "${widget.categoryData.sell?.percentage.toString() ?? "0"} %",
//                 x: "$booking $revenue ${(widget.categoryData.sell?.totalPrice ?? '').nkValueWithCurrencySymbol}",
//                 y: widget.categoryData.sell?.percentage?.toDouble() ?? 0.0,
//                 color: revenueProgressBarFilledColor),
//           ],
//           pointColorMapper: (ChartSampleData data, _) => data.color,
//           xValueMapper: (ChartSampleData data, _) => data.x,
//           yValueMapper: (ChartSampleData data, _) => data.y,
//           dataLabelMapper: (ChartSampleData data, _) => data.text,
//           dataLabelSettings: const DataLabelSettings(isVisible: true))
//     ];
//   }
// }
class Revenuss {
  final RevenueData? totalSell;
  final RevenueData? sell;

  Revenuss({this.totalSell, this.sell});
}

// Define the RevenueData class
class RevenueData {
  final double? percentage;
  final double? totalPrice;

  RevenueData({this.percentage, this.totalPrice});
}

// Define the ChartSampleData class
class ChartSampleData {
  final String x;
  final double y;
  final Color color;
  final String text;

  ChartSampleData(
      {required this.x,
      required this.y,
      required this.color,
      required this.text});
}

// Define constants for testing
const String totalString = "Total";
const String revenue = "Revenue";
const String booking = "Booking";
const Color revenueProgressBarColor = Colors.blue;
const Color revenueProgressBarFilledColor = Colors.green;

// Extend DoughnutDefault with the StatefulWidget and dummy data
// class DoughnutDefault extends StatefulWidget {
//   final Revenuss categoryData;
//   final dynamic booking; // New parameter for booking
//   final dynamic order; // New parameter for order
//   final Color barColor; // New parameter for bar color
//   final Widget sabik;

//   const DoughnutDefault({
//     super.key,
//     required this.categoryData,
//     required this.booking,
//     required this.order,
//     required this.barColor,
//     required this.sabik,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _DoughnutDefaultState createState() => _DoughnutDefaultState();
// }

// class _DoughnutDefaultState extends State<DoughnutDefault> {
//   late TooltipBehavior _tooltip;

//   @override
//   void initState() {
//     _tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y%');
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 3,
//           child: CircularPercentIndicator(
//             // circular progress indicator
//             radius: (MediaQuery.of(context).orientation == Orientation.portrait)
//                 ? (ResponsiveInfo.isMobileDimension(context) ? 40 : 20)
//                 : (ResponsiveInfo.isMobileDimension(context)
//                     ? 60
//                     : 60), // radius for circle
//             lineWidth: 17.4, // width of circle line
//             percent: 60 / 160, // percentage value: 0.6 for 60% (60/100 = 0.6)
//             backgroundColor:
//                 const Color(0xffe1e4e6), // background of progress bar
//             circularStrokeCap: CircularStrokeCap
//                 .round, // corner shape of progress bar at start/end
//             progressColor: widget.barColor, // progress bar color
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 10)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 17 : 16),
//               width:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16),
//               decoration: const BoxDecoration(
//                 color: Color(0xff142b33),
//                 borderRadius: BorderRadius.all(Radius.circular(3.0)),
//               ),
//             ),
//             const SizedBox(width: 2),
//             MyRegularText(
//               label: widget.booking,
//               fontWeight: NkGeneralSize.nkGeneralFontWeight(),
//               color: secondaryTextColor,
//             ),
//             SizedBox(
//               width:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 8.3)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 7 : 8.3),
//             ),
//             Container(
//               height:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 10)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 17 : 16),
//               width:
//                   (MediaQuery.of(context).orientation == Orientation.portrait)
//                       ? (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16)
//                       : (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16),
//               decoration: const BoxDecoration(
//                 color: Color(0xff4455dd),
//                 borderRadius: BorderRadius.all(Radius.circular(3.0)),
//               ),
//             ),
//             const SizedBox(width: 2),
//             MyRegularText(
//               label: widget.order,
//               fontWeight: NkGeneralSize.nkGeneralFontWeight(),
//               color: secondaryTextColor,
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 4,
//         ),
//         widget.sabik,
//       ],
//     );
//   }

//   // ignore: unused_element
//   SfCircularChart _buildDefaultDoughnutChart() {
//     return SfCircularChart(
//       legend: const Legend(
//         textStyle: TextStyle(fontSize: 7),
//         isVisible: false,
//         overflowMode: LegendItemOverflowMode.scroll,
//         position: LegendPosition.bottom,
//       ),
//       series: _getDefaultDoughnutSeries(),
//       centerX: '50%',
//       tooltipBehavior: _tooltip,
//     );
//   }

//   List<DoughnutSeries<ChartSampleData, String>> _getDefaultDoughnutSeries() {
//     return <DoughnutSeries<ChartSampleData, String>>[
//       DoughnutSeries<ChartSampleData, String>(
//         radius: '80%',
//         explode: true,
//         explodeOffset: '10%',
//         dataSource: <ChartSampleData>[
//           ChartSampleData(
//             text:
//                 "${widget.categoryData.totalSell?.percentage.toString() ?? "0"} %",
//             x: "$totalString $revenue ${(widget.categoryData.totalSell?.totalPrice ?? 0).toString()}",
//             y: widget.categoryData.totalSell?.percentage ?? 0.0,
//             color: widget.barColor,
//           ),
//         ],
//         pointColorMapper: (ChartSampleData data, _) => data.color,
//         xValueMapper: (ChartSampleData data, _) => data.x,
//         yValueMapper: (ChartSampleData data, _) => data.y,
//         dataLabelMapper: (ChartSampleData data, _) => data.text,
//         dataLabelSettings: const DataLabelSettings(isVisible: true),
//       ),
//     ];
//   }
// }

// Extend DoughnutDefault with the StatefulWidget and dummy data

class DoughnutDefault extends StatefulWidget {
  final Revenuee categoryData;
  final String booking;
  final String order;
  final Color aColor;
  final Color bColor;
  final Widget sabik;
  final Widget sabik1;

  const DoughnutDefault({
    Key? key,
    required this.categoryData,
    required this.booking,
    required this.order,
    required this.sabik,
    required this.aColor,
    required this.bColor,
    required this.sabik1,
  }) : super(key: key);

  @override
  _DoughnutDefaultState createState() => _DoughnutDefaultState();
}

class _DoughnutDefaultState extends State<DoughnutDefault> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y%');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final totalBookingRevenue = widget.categoryData.bookingRevenueData?.fold(
          0.0,
          (sum, item) => sum + (item.total ?? 0.0),
        ) ??
        0.0;

    final totalOrderRevenue = widget.categoryData.orderRevenueData?.fold(
          0.0,
          (sum, item) => sum + (item.totalOrderRevenue?.toDouble() ?? 0.0),
        ) ??
        0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: fl_chart.PieChart(
            fl_chart.PieChartData(
              startDegreeOffset: 250,
              sectionsSpace: 0.7,
              centerSpaceRadius: 60,
              sections: [
                fl_chart.PieChartSectionData(
                  value: totalOrderRevenue,
                  color: widget.aColor,
                  radius: 25,
                  showTitle: false,
                ),
                fl_chart.PieChartSectionData(
                  value: totalBookingRevenue,
                  color: widget.bColor,
                  radius: 25,
                  showTitle: false,
                ),
              ],
              pieTouchData: fl_chart.PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.touchedSection != null) {
                    final section = response.touchedSection!;
                    final fl_chart.PieTouchedSection touchedSectionData =
                        section;
                    final title = touchedSectionData == totalOrderRevenue
                        ? 'Order Revenue'
                        : 'Booking Revenue';
                    showValueDialog(context, widget.categoryData, title);
                  }
                },
              ),
            ),
          ),
        ),
        widget.sabik1,
        const SizedBox(height: 4),
        widget.sabik,
      ],
    );
  }
void _showValueDialog(
    BuildContext context, Revenuee categoryData, String title) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.5;
            double maxDialogHeight = constraints.maxHeight * 0.5;
            double rowHeight = 30.0;
            double headerHeight = 40.0;
            double contentHeight = rowHeight *
                (categoryData.orderRevenueData?.length ?? 0) +
                rowHeight;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: Container(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog Header
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
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins_Regular',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Table Header (Fixed)
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child: Row(
                        children: const [
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Date',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Amount',
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    // Table Content (Scrollable)
                    Flexible(
                      child: SingleChildScrollView(
                        child: DataTable(
                          dataRowHeight: rowHeight,
                          headingRowHeight: 0, // Header already defined above
                          columnSpacing: 30,
                          columns: const [
                            DataColumn(label: SizedBox.shrink()),
                            DataColumn(label: SizedBox.shrink()),
                            DataColumn(label: SizedBox.shrink()),
                            DataColumn(label: SizedBox.shrink()),
                          ],
                          rows: [
                            ...categoryData.orderRevenueData!.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Text(
                                      getFormattedOrderCreatAt(
                                          item.orderCreatAt),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: Text(
                                      item.orderId ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: Text(
                                      getStatusName(item.orderStatus!.toInt()),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: Text(
                                      formatAmount(item.orderTotal),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                            DataRow(
                              cells: [
                                const DataCell(
                                  Center(
                                    child: DialogTableHeaderText(
                                      text: 'Total',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                DataCell(
                                  Center(
                                    child: DialogTableHeaderText(
                                      text: formatAmount(categoryData
                                          .orderRevenueData!
                                          .map((e) => e.orderTotal ?? 0.0)
                                          .reduce((a, b) => a + b)),
                                      fontSize: 13,
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
            );
          },
        ),
      );
    },
  );
}
}

class DoughnutDefaultDelivery extends StatefulWidget {
  final Delivery deliveryData;
  final Color aColor;
  final Color bColor;
  final Color cColor;
  final Widget legend1;
  final Widget legend2;

  const DoughnutDefaultDelivery({
    Key? key,
    required this.deliveryData,
    required this.aColor,
    required this.bColor,
    required this.cColor,
    required this.legend1,
    required this.legend2,
  }) : super(key: key);

  @override
  _DoughnutDefaultDeliveryState createState() =>
      _DoughnutDefaultDeliveryState();
}

class _DoughnutDefaultDeliveryState extends State<DoughnutDefaultDelivery> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate raw values
    final orderProcessingValue = _getOrderValueByStatus(5);
    final outForDeliveryValue = _getOrderValueByStatus(1);
    final deliveredValue = _getOrderValueByStatus(2);

    // Calculate total and percentages
    final totalValue =
        orderProcessingValue + outForDeliveryValue + deliveredValue;

    final orderProcessingPercentage = totalValue > 0
        ? (orderProcessingValue / totalValue * 100).clamp(0, 100)
        : 0.0;
    final outForDeliveryPercentage = totalValue > 0
        ? (outForDeliveryValue / totalValue * 100).clamp(0, 100)
        : 0.0;
    final deliveredPercentage = totalValue > 0
        ? (deliveredValue / totalValue * 100).clamp(0, 100)
        : 0.0;

    // Apply minimum percentage rule (5% for non-zero values)
    final adjustedPercentages = _adjustPercentages(
      [
        orderProcessingPercentage.toDouble(),
        outForDeliveryPercentage.toDouble(),
        deliveredPercentage.toDouble()
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: fl_chart.PieChart(
            fl_chart.PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: 43,
              sections: [
                fl_chart.PieChartSectionData(
                  value: adjustedPercentages[0],
                  color: widget.aColor,
                  radius: 25,
                  showTitle: false,
                  title: '${adjustedPercentages[0].toStringAsFixed(1)}%',
                ),
                fl_chart.PieChartSectionData(
                  value: adjustedPercentages[1],
                  color: widget.bColor,
                  radius: 25,
                  showTitle: false,
                  title: '${adjustedPercentages[1].toStringAsFixed(1)}%',
                ),
                fl_chart.PieChartSectionData(
                  value: adjustedPercentages[2],
                  color: widget.cColor,
                  radius: 25,
                  showTitle: false,
                  title: '${adjustedPercentages[2].toStringAsFixed(1)}%',
                ),
              ],
              pieTouchData: fl_chart.PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.touchedSection != null) {
                    final section = response.touchedSection!;
                    final title =
                        section.touchedSection!.value == adjustedPercentages[0]
                            ? 'Processing Orders'
                            : section.touchedSection!.value ==
                                    adjustedPercentages[1]
                                ? 'Packed & Ready for Delivery'
                                : section.touchedSection!.value ==
                                        adjustedPercentages[2]
                                    ? 'Delivered Orders'
                                    : 'Unknown';
                    final status =
                        section.touchedSection!.value == adjustedPercentages[0]
                            ? 5
                            : section.touchedSection!.value ==
                                    adjustedPercentages[1]
                                ? 1
                                : section.touchedSection!.value ==
                                        adjustedPercentages[2]
                                    ? 2
                                    : -1;

                    _showValueDialog(
                        context, widget.deliveryData, title, status);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.7),
        widget.legend1,
        const SizedBox(height: 2.5),
        widget.legend2,
      ],
    );
  }

  /// Adjust percentages to enforce minimum of 5% for non-zero values
  List<double> _adjustPercentages(List<double> percentages) {
    const minPercentage = 3.0;

    // Calculate adjusted values
    final adjustedPercentages = percentages.map((p) {
      if (p > 0 && p < minPercentage) {
        return minPercentage;
      }
      return p;
    }).toList();

    // Redistribute excess if needed
    final excess = adjustedPercentages.reduce((a, b) => a + b) - 100;
    if (excess > 0) {
      for (int i = 0; i < adjustedPercentages.length; i++) {
        if (adjustedPercentages[i] > minPercentage) {
          adjustedPercentages[i] -= excess;
          break;
        }
      }
    }

    return adjustedPercentages;
  }

  double _getOrderValueByStatus(int status) {
    final order = widget.deliveryData.order!.totalOrders!.last;

    return status == 5
        ? order.orderProcessing!.toDouble()
        : status == 1
            ? order.outForDelivery!.toDouble()
            : status == 2
                ? order.deliverd!.toDouble()
                : 0.0;
  }

  void _showValueDialog(
      BuildContext context, Delivery deliveryData, String title, int status) {
    showDialog(
      context: context,
      builder: (context) {
        // Filter orders based on status
        final filteredOrders = deliveryData.order!.totalOrders!
            .where((orderDetails) => orderDetails.orderStatus == status)
            .toList();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          content: SingleChildScrollView(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      dialogCloseButton1(context, red),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                      // ignore: deprecated_member_use
                      dataRowHeight: 39,
                      headingRowHeight: 41,
                      columns: const [
                        DataColumn(
                          label: DialogTableHeaderText(
                            text: 'Customer',
                            fontSize: 13,
                          ),
                        ),
                        DataColumn(
                          label: DialogTableHeaderText(
                            text: 'Date',
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
                            text: 'Status',
                            fontSize: 13,
                          ),
                        ),
                        DataColumn(
                          label: DialogTableHeaderText(
                            text: 'Amount',
                            fontSize: 13,
                          ),
                        ),
                      ],
                      rows: [
                        ...filteredOrders.map((orderDetails) {
                          return DataRow(
                            cells: [
                              DataCell(Center(
                                child:
                                    Text(orderDetails.businessName.toString(),
                                        style: const TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center),
                              )),
                              DataCell(Center(
                                child: Text(
                                    getFormattedOrderCreatAt(
                                        orderDetails.orderCreatAt ?? ''),
                                    style: const TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center),
                              )),
                              DataCell(Center(
                                child: InkWell(
                                  onTap: () {
                                    _showDetailedPaymentOrderDialog(
                                        context, orderDetails, true);
                                  },
                                  child: Text(orderDetails.invoiceId.toString(),
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                              )),
                              DataCell(Center(
                                child: Text(
                                    getStatusName(
                                        orderDetails.orderStatus ?? 0),
                                    style: const TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center),
                              )),
                              DataCell(Center(
                                child:
                                    Text(formatAmount(orderDetails.orderTotal),
                                        style: const TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center),
                              )),
                            ],
                          );
                        }),
                        DataRow(
                          cells: [
                            const DataCell(
                              Center(
                                child: Text(
                                  'Total',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins_Regular'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            DataCell(
                              Center(
                                child: Text(
                                  formatAmount(filteredOrders
                                      .map((e) => e.orderTotal ?? 0.0)
                                      .reduce((a, b) => a + b)),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins_Regular'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class ChartSampleData {
//   String x;
//   double y;
//   String text;
//   Color color;

//   ChartSampleData(
//       {required this.x,
//       required this.y,
//       required this.text,
//       required this.color});
// }
class DoughnutDefaultR extends StatefulWidget {
  final dynamic bookingCount;
  final dynamic orderCount;
  final Color bookingColor;
  final Color orderColor;
  final Color coplt;
  final Color pending;
  final dynamic copmT;
  final dynamic pendt;
  final List<ChartData> chartData;

  const DoughnutDefaultR({
    super.key,
    required this.bookingCount,
    required this.orderCount,
    required this.bookingColor,
    required this.orderColor,
    required this.chartData,
    required this.coplt,
    required this.pending,
    required this.copmT,
    required this.pendt,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DoughnutDefaultRState createState() => _DoughnutDefaultRState();
}

class _DoughnutDefaultRState extends State<DoughnutDefaultR> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                child: Container(
                  transform: Matrix4.translationValues(25.0, 25.0, 0.0),
                  width: 125,
                  height: 125,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    // Adjust position to create the overlay effect
                    // This depends on how much of each color you want to show
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 10)
                      : (ResponsiveInfo.isMobileDimension(context) ? 17 : 16),
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16)
                      : (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16),
              decoration: BoxDecoration(
                color: widget.bookingColor,
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
            ),
            const SizedBox(width: 2),
            MyRegularText(
              label: widget.bookingCount,
              fontWeight: NkGeneralSize.nkGeneralFontWeight(),
              color: secondaryTextColor,
            ),
            SizedBox(
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 8.3)
                      : (ResponsiveInfo.isMobileDimension(context) ? 7 : 8.3),
            ),
            Container(
              height:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 10)
                      : (ResponsiveInfo.isMobileDimension(context) ? 17 : 16),
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16)
                      : (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16),
              decoration: BoxDecoration(
                color: widget.orderColor,
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
            ),
            const SizedBox(width: 2),
            MyRegularText(
              label: widget.orderCount,
              fontWeight: NkGeneralSize.nkGeneralFontWeight(),
              color: secondaryTextColor,
            ),
          ],
        ),
        const SizedBox(height: 3.9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 10)
                      : (ResponsiveInfo.isMobileDimension(context) ? 17 : 16),
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16)
                      : (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16),
              decoration: BoxDecoration(
                color: widget.coplt,
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
            ),
            const SizedBox(width: 2),
            MyRegularText(
              label: widget.copmT,
              fontWeight: NkGeneralSize.nkGeneralFontWeight(),
              color: secondaryTextColor,
            ),
            SizedBox(
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 8.3)
                      : (ResponsiveInfo.isMobileDimension(context) ? 7 : 8.3),
            ),
            Container(
              height:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 6.2 : 10)
                      : (ResponsiveInfo.isMobileDimension(context) ? 17 : 16),
              width:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16)
                      : (ResponsiveInfo.isMobileDimension(context) ? 10.2 : 16),
              decoration: BoxDecoration(
                color: widget.pending,
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
            ),
            const SizedBox(width: 2),
            MyRegularText(
              label: widget.pendt,
              fontWeight: NkGeneralSize.nkGeneralFontWeight(),
              color: secondaryTextColor,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of any resources here if needed
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}

class ChartData2 {
  final String label;
  final int value;
  final Color color;

  ChartData2(this.label, this.value, this.color);
}

class NestedPieChartj extends StatelessWidget {
  final int completedOrdersCount;
  final int pendingAmountCount;
  final int dueAmountCount;
  final int overdueAmountCount;
  final Collection collection;

  const NestedPieChartj(
      {super.key,
      required this.completedOrdersCount,
      required this.pendingAmountCount,
      required this.dueAmountCount,
      required this.overdueAmountCount,
      required this.collection});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfCircularChart(
        series: <CircularSeries>[
          // Outer Pie Chart
          DoughnutSeries<ChartData2, String>(
            dataSource: [
              ChartData2(
                  'Completed', completedOrdersCount, const Color(0xFF5A7725)),
              ChartData2(
                  'Pending', pendingAmountCount, const Color(0xFFA30C13)),
            ],
            xValueMapper: (ChartData2 data, _) => data.label,
            yValueMapper: (ChartData2 data, _) => data.value,
            pointColorMapper: (ChartData2 data, _) => data.color,
            radius: '90%',
            innerRadius: '65%',
            strokeColor: white,
            strokeWidth: 2,
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex == 0) {
                _showValueDialog(context, 'Completed', collection);
              } else if (details.pointIndex == 1) {
                _pendingPaymentCollectionDialog(
                    context, 'Pending Payment', collection);
              }
            },
          ),
          // Inner Pie Chart
          DoughnutSeries<ChartData2, String>(
            dataSource: [
              ChartData2('Due', dueAmountCount, const Color(0xFFFFADB5)),
              ChartData2(
                  'Overdue', overdueAmountCount, const Color(0xFFFF6584)),
            ],
            xValueMapper: (ChartData2 data, _) => data.label,
            yValueMapper: (ChartData2 data, _) => data.value,
            pointColorMapper: (ChartData2 data, _) => data.color,
            radius: '57%',
            innerRadius: '45%',
            strokeColor: white,
            strokeWidth: 0.5,
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex == 0) {
                _pendingPaymentCollectionDialog(
                    context, 'Due Payment', collection);
              } else if (details.pointIndex == 1) {
                _pendingPaymentCollectionDialog(
                    context, 'Over Due Payment', collection);
              }
            },
          ),
        ],
      ),
    );
  }

 void _pendingPaymentCollectionDialog(
      BuildContext context, String title, Collection collection) {
    final ScrollController scrollController = ScrollController();
    // Ensure order and pendingAmount are not null
    if (collection.order == null || collection.order!.pendingAmount == null) {
      print("Order or pendingAmount is null.");
      return; // Exit the function early if data is missing
    }

    String selectedPaymentMethod = 'Cash';
    RxInt selectedPaymentMethodInt = 0.obs;

    DateTime parseCustomDate(String date) {
      final parts = date.split('/');
      return DateTime(
        int.parse(parts[2]), // Year
        int.parse(parts[1]), // Month
        int.parse(parts[0]), // Day
      );
    }

    RxList<bool> selectedItems = List<bool>.generate(
      collection.order!.pendingAmount!.length,
      (index) => false,
    ).obs;

    void updateSelectedItems() {
      selectedItems.value = List<bool>.generate(
        collection.order!.pendingAmount!.length,
        (index) => false,
      );
    }

    updateSelectedItems();

    bool isWithinThreeDays(DateTime date) {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfThreeDaysFromNow = startOfToday
          .add(Duration(days: 3, hours: 23, minutes: 59, seconds: 59));
      return date.isAtSameMomentAs(startOfToday) ||
          (date.isAfter(startOfToday) &&
              date.isBefore(endOfThreeDaysFromNow)) ||
          date.isAtSameMomentAs(endOfThreeDaysFromNow);
    }

    List<PendingAmount> filteredPendingAmount = [];
    if (title == 'Due Payment') {
      filteredPendingAmount = collection.order!.pendingAmount!.where((item) {
        if (item.dueDate == null || item.dueDate is! List) return false;
        try {
          String dateString = item.dueDate![0];
          DateTime dueDate = parseCustomDate(dateString);
          return isWithinThreeDays(
              dueDate); // Check for due dates within 3 days
        } catch (e) {
          print("Error parsing dueDate: ${item.dueDate}, error: $e");
          return false;
        }
      }).toList();
    } else if (title == 'Over Due Payment') {
      filteredPendingAmount = collection.order!.pendingAmount!.where((item) {
        if (item.dueDate == null || item.dueDate is! List) return false;
        try {
          String dateString = item.dueDate![0];
          DateTime dueDate = parseCustomDate(dateString);
          return dueDate.isBefore(DateTime.now()); // Only overdue items
        } catch (e) {
          print("Error parsing dueDate: ${item.dueDate}, error: $e");
          return false;
        }
      }).toList();
    } else if (title == 'Pending Payment') {
      filteredPendingAmount = collection.order!.pendingAmount!.toList();
    }

    Color getDueDateColor(String dueDateStr) {
      try {
        DateTime dueDate = parseCustomDate(dueDateStr);

        // Update: Check if the due date is today
        if (_isDateToday(dueDate)) {
          return Colors.amber; // Today
        } else if (_isDateBeforeToday(dueDate.toString())) {
          return Colors.red; // Overdue
        } else if (isWithinThreeDays(dueDate)) {
          return Colors.amber; // Within 3 days (includes today)
        } else {
          return Colors.green; // Future due dates
        }
      } catch (e) {
        print("Error parsing dueDate: $dueDateStr, error: $e");
        return Colors.grey; // Default color for invalid date or error
      }
    }

    double calculateTotalBalanceAmount() {
      double total = 0;
      for (int i = 0; i < selectedItems.length; i++) {
        if (selectedItems[i]) {
          final receivable =
              collection.order!.pendingAmount![i].receivableAmount;
          if (receivable == null) {
            total +=
                collection.order!.pendingAmount![i].orderTotal?.toDouble() ??
                    0.0;
          } else {
            total += receivable;
          }
        }
      }
      return total;
    }

    void processPayments(List<PendingAmount> selectedItems, int enteredAmount) {
      print("Processing payments with amount: $enteredAmount");
      for (var item in selectedItems) {
        print(
            "Processing item: ${item.orderId} with amount: ${item.orderTotal}");
      }
    }

    RxDouble totalBalanceAmount = RxDouble(calculateTotalBalanceAmount());

    final balanceAmountController = TextEditingController(
      text: totalBalanceAmount.value.toStringAsFixed(2),
    );

    final receivedAmountController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 45,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xff008000),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins_Regular',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dialogCloseButton1(context, red),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 1.3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
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
                    child: Scrollbar(
                      controller: scrollController,
                      interactive: true,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 30,
                            horizontalMargin: 15,
                            dataRowHeight: 30,
                            headingRowHeight: 40,
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            columns: const [
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Customer',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Date',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Order No.',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Amount',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Status',
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
                                  text: 'Due Date',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Payment',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Receivable',
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Select',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            rows: [
                              ...filteredPendingAmount
                                  .asMap()
                                  .entries
                                  .map<DataRow>(
                                (entry) {
                                  int index = entry.key;
                                  var payment = entry.value;
                                  return DataRow(cells: [
                                    DataCell(Center(
                                        child: Text(
                                            payment.businessName.toString()))),
                                    DataCell(Center(
                                        child: Text(getFormattedOrderCreatAt(
                                            payment.orderCreatAt)))),
                                    DataCell(Center(
                                        child:
                                            Text(payment.orderId.toString()))),
                                    DataCell(Center(
                                        child: Text(
                                            formatAmount(payment.orderTotal)))),
                                    DataCell(Center(
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xff008000),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                ),
                                                child: Text(
                                                    getStatusName(payment
                                                            .orderStatus
                                                            ?.toInt() ??
                                                        0),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    )))))),
                                    DataCell(Center(
                                        child: InkWell(
                                            onTap: () {
                                              showDetailedOrderInvoiceDialog(
                                                  context, payment, true);
                                            },
                                            child: Text(
                                              payment.invoiceId.toString(),
                                              style: const TextStyle(
                                                  color: primaryColor),
                                            )))),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          payment.dueDate != null &&
                                                  payment.dueDate!.isNotEmpty
                                              ? payment.dueDate!.first
                                                  .toString()
                                                  .replaceAll('/', '-')
                                              : 'N/A', // Empty string for null or empty dueDate
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: payment.dueDate != null &&
                                                    payment.dueDate!.isNotEmpty
                                                ? getDueDateColor(
                                                    payment.dueDate!.first)
                                                : Colors
                                                    .grey, // Set color to grey for null or empty dueDate
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: payment.paymentStatus == 0
                                                ? Colors.red
                                                : payment.paymentStatus == 1
                                                    ? Colors.green
                                                    : payment.paymentStatus == 3
                                                        ? Colors.yellow
                                                        : Colors.grey,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: payment.paymentStatus == 0
                                                  ? Colors.red
                                                  : payment.paymentStatus == 1
                                                      ? Colors.green
                                                      : payment.paymentStatus ==
                                                              3
                                                          ? Colors.yellow
                                                          : Colors.grey,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Icon(
                                              payment.paymentStatus == 0
                                                  ? Icons.close
                                                  : Icons.done,
                                              color: Colors.white,
                                              size: 14.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3.0),
                                          child: EditablePendingPaymentCell(
                                            initialValue: (payment.orderTotal! -
                                                            payment
                                                                .receivedAmount! ==
                                                        payment.orderTotal
                                                    ? payment.orderTotal
                                                    : payment.orderTotal! -
                                                        payment.receivedAmount!)
                                                .toString(),
                                            index: index,
                                            orderId: payment.orderId.toString(),
                                            orderTotal:
                                                payment.orderTotal?.toInt() ??
                                                    0,
                                            receivable:
                                                payment.receivableAmount ??
                                                    payment.orderTotal! -
                                                        payment.receivedAmount!,
                                            onValueChanged: (newValue, index) {
                                              // Handle editable cells if necessary
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(child: Obx(() {
                                        return Checkbox(
                                          value: selectedItems[index],
                                          onChanged: (bool? value) {
                                            selectedItems[index] =
                                                value ?? false;

                                            totalBalanceAmount.value =
                                                calculateTotalBalanceAmount();
                                            balanceAmountController.text =
                                                totalBalanceAmount.value
                                                    .toStringAsFixed(2);
                                          },
                                        );
                                      })),
                                    ),
                                  ]);
                                },
                              ),
                              DataRow(cells: [
                                const DataCell(
                                  Center(
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins_Regular'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                DataCell(
                                  Center(
                                    child: Text(
                                      formatAmount(
                                        filteredPendingAmount
                                            .map((e) => e.orderTotal ?? 0.0)
                                            .fold(0.0, (a, b) => a + b),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins_Regular'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                DataCell(
                                  Center(
                                    child: Text(
                                      formatAmount(
                                        filteredPendingAmount
                                            .map((e) =>
                                                e.receivableAmount ??
                                                e.orderTotal ??
                                                0.0)
                                            .fold(0.0, (a, b) => a + b),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins_Regular'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const DataCell(Text('')),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Second table
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        dataRowHeight: 35,
                        headingRowHeight: 30,
                        columns: const [
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Payment Method',
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Balance Amount',
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Received Amount',
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Remarks',
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(label: Text('')),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(
                                DropdownButtonFormField<String>(
                                  value: selectedPaymentMethod,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  dropdownColor: Colors.white,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Cash', child: Text('Cash')),
                                    DropdownMenuItem(
                                        value: 'Cheque', child: Text('Cheque')),
                                    DropdownMenuItem(
                                        value: 'Bank Transfer',
                                        child: Text('Bank Transfer')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectedPaymentMethod = value;
                                      switch (value) {
                                        case 'Cash':
                                          selectedPaymentMethodInt.value = 0;
                                          break;
                                        case 'Cheque':
                                          selectedPaymentMethodInt.value = 1;
                                          break;
                                        case 'Bank Transfer':
                                          selectedPaymentMethodInt.value = 2;
                                          break;
                                      }
                                    }
                                  },
                                  hint: const Text('Select'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 24.0, color: Colors.black),
                                  iconSize: 24.0,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Text(addCurrencySymbol()),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        controller: balanceAmountController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Text(addCurrencySymbol()),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        controller: receivedAmountController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter Amount',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: remarksController,
                                  decoration: InputDecoration(
                                    hintText: 'Remarks',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      int enteredAmount = int.tryParse(
                                              receivedAmountController.text) ??
                                          0;
                                      if (enteredAmount > 0) {
                                        List<PendingAmount> selectedItemsList =
                                            [];
                                        for (int i = 0;
                                            i < selectedItems.length;
                                            i++) {
                                          if (selectedItems[i]) {
                                            selectedItemsList.add(collection
                                                .order!.pendingAmount![i]);
                                          }
                                        }

                                        processPayments(
                                            selectedItemsList, enteredAmount);

                                        updateSelectedItems();
                                      } else {
                                        print("Please enter a valid amount.");
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shadowColor: Colors.transparent,
                                      backgroundColor:
                                          primaryColor.withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text('Submit',
                                        style: TextStyle(fontSize: 14)),
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
            ],
          ),
        );
      },
    );
  }
}

bool _isDateBeforeToday(String dateString) {
  try {
    final dateFormat = DateFormat("dd/MM/yyyy");
    final date = dateFormat.parse(dateString);
    return date.isBefore(DateTime.now().toLocal());
  } catch (e) {
    return false;
  }
}

bool _isDateToday(DateTime date) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday
      .add(const Duration(days: 1))
      .subtract(const Duration(seconds: 1));
  return date.isAtSameMomentAs(startOfToday) ||
      (date.isAfter(startOfToday) && date.isBefore(endOfToday));
}

void _showValueDialog(
    BuildContext context, String title, Collection collection) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        content: SingleChildScrollView(
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
                    const Text(
                      'Received Payment',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    dialogCloseButton1(context, red),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  // ignore: deprecated_member_use
                  dataRowHeight: 35,
                  headingRowHeight: 40,
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(
                      label: DialogTableHeaderText(
                        text: 'Customer',
                        fontSize: 13.5,
                      ),
                    ),
                    DataColumn(
                      label: DialogTableHeaderText(
                        text: 'Date',
                        fontSize: 13.5,
                      ),
                    ),
                    DataColumn(
                      label: DialogTableHeaderText(
                        text: 'Invoice',
                        fontSize: 13.5,
                      ),
                    ),
                    DataColumn(
                      label: DialogTableHeaderText(
                        text: 'Status',
                        fontSize: 13.5,
                      ),
                    ),
                    DataColumn(
                      label: DialogTableHeaderText(
                        text: 'Amount',
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                  rows: _buildDataRows(context, collection, title),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

List<DataRow> _buildDataRows(
    BuildContext context, Collection collection, String title) {
  return [
    ...collection.payment!.completedOrders!.map((completedOrder) => DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(
                  completedOrder.businessName ?? '',
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  getFormattedOrderCreatAt(completedOrder.orderCreatAt),
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            DataCell(
              Center(
                child: InkWell(
                  onTap: () {
                    _showDetailedPaymentOrderDialog(
                        context, completedOrder, true);
                  },
                  child: Text(
                    completedOrder.invoiceId ?? '',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  getStatusName(completedOrder.orderStatus?.toInt() ?? 0),
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  formatAmount(completedOrder.orderTotal),
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        )),
    DataRow(
      cells: [
        const DataCell(
          Center(
            child: Text(
              'Total',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins_Regular'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        DataCell(
          Center(
            child: Text(
              formatAmount(collection.payment!.completedOrders!
                  .map((e) => e.orderTotal ?? 0.0)
                  .reduce((a, b) => a + b)),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins_Regular'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  ];
}

class DoughnutDefaultCustomerDash extends StatefulWidget {
  final CustomerRevenueResponse customerData;
  final dynamic booking;
  final dynamic order;
  final Color aColor;
  final Color bColor;
  final Widget sabik;
  final Widget sabik1;

  const DoughnutDefaultCustomerDash({
    Key? key,
    required this.customerData,
    required this.booking,
    required this.order,
    required this.sabik,
    required this.aColor,
    required this.bColor,
    required this.sabik1,
  }) : super(key: key);

  @override
  _DoughnutDefaultCustomerDashState createState() =>
      _DoughnutDefaultCustomerDashState();
}

class _DoughnutDefaultCustomerDashState
    extends State<DoughnutDefaultCustomerDash> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the lists are empty and set default values if they are
    final paymentCompleted =
        widget.customerData.data.revenue.bookingRevenueData?.isNotEmpty == true
            ? widget.customerData.data.revenue.bookingRevenueData!.last
                .totalBookingRevenue
            : 0;
    final paymentRemaining =
        widget.customerData.data.revenue.orderRevenueData?.isNotEmpty == true
            ? widget.customerData.data.revenue.orderRevenueData!.last
                .totalOrderRevenue
            : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              fl_chart.PieChart(
                fl_chart.PieChartData(
                  startDegreeOffset: 250,
                  sectionsSpace: 0.6,
                  centerSpaceRadius: 43,
                  sections: [
                    fl_chart.PieChartSectionData(
                      value: paymentCompleted.toDouble(),
                      color: widget.aColor,
                      radius: 19.6,
                      showTitle: false,
                    ),
                    fl_chart.PieChartSectionData(
                      value: paymentRemaining.toDouble(),
                      color: widget.bColor,
                      radius: 19.6,
                      showTitle: false,
                    ),
                  ],
                  pieTouchData: fl_chart.PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                      if (event is FlTapUpEvent &&
                          response != null &&
                          response.touchedSection != null) {
                        final section = response.touchedSection!;
                        final PieChartSectionData touchedSectionData =
                            section.touchedSection ?? PieChartSectionData();
                        final isPaymentCompleted = touchedSectionData.value ==
                            paymentCompleted.toDouble();
                        final title =
                            isPaymentCompleted ? 'Bookings' : 'Orders';
                        final orderDetails = isPaymentCompleted
                            ? widget
                                .customerData.data.revenue.bookingRevenueData
                            : widget.customerData.data.revenue.orderRevenueData;
                        if (orderDetails != null && orderDetails.isNotEmpty) {
                          _showValueDialog(context, orderDetails, title);
                        }
                      }
                    },
                  ),
                ),
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       formatAmount(totalRevenue),
              //       style: const TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => OrdersScreen()));
          },
          child: widget.sabik1,
        ),
        const SizedBox(height: 4),
        widget.sabik,
      ],
    );
  }

  void _showValueDialog(
      BuildContext context, List<dynamic> orderDetails, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8), // Add small curve border
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            title: Container(
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
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Poppins_Regular',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  dialogCloseButton1(context, red),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: DataTable(
                dataRowHeight: 30,
                headingRowHeight: 40,
                columnSpacing: 15,
                columns: const [
                  DataColumn(
                    label: DialogTableHeaderText(
                      text: 'Date',
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
                      text: 'Status',
                      fontSize: 13,
                    ),
                  ),
                  DataColumn(
                    label: DialogTableHeaderText(
                      text: 'Amount',
                      fontSize: 13,
                    ),
                  ),
                  // DataColumn(
                  //   label: DialogTableHeaderText(
                  //     text: 'Payment Status',
                  //     fontSize: 13,
                  //   ),
                  // ),
                ],
                rows: orderDetails.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Center(
                        child: Text(
                          getFormattedOrderCreatAt(item.orderCreatAt),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      )),
                      DataCell(Center(
                        child: Text(
                          item.orderId,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      )),
                      DataCell(Center(
                        child: Text(
                          item.orderStatus.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      )),
                      DataCell(Center(
                        child: Text(
                          formatAmount(item.orderTotal),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      )),
                      // DataCell(
                      //   Center(
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //         color: item.paymentStatus == 0
                      //             ? Colors.red
                      //             : Colors.green,
                      //         shape: BoxShape.circle,
                      //         border: Border.all(
                      //           color: item.paymentStatus == 0
                      //               ? Colors.red
                      //               : Colors.green,
                      //         ),
                      //       ),
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(1.0),
                      //         child: Icon(
                      //           item.paymentStatus == 0
                      //               ? Icons.close
                      //               : Icons.done,
                      //           color: Colors.white,
                      //           size: 13,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showDetailedPaymentOrderDialog(
  BuildContext context,
  var orderData,
  final bool invoice,
) async {
  DashBoardController dashBoardController = Get.put(DashBoardController());

  var pendingOrderData = await dashBoardController.loadSpecificOrderInvoiceData(
      orderId: orderData.orderId.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: white,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [const Spacer(), dialogCloseButton1(context, red)],
                ),
                const SizedBox(height: 16),
                MyCommnonContainer(
                  isCommonBorder: true,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            invoice ? 'INVOICE' : 'CUSTOMER & ORDER',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            NKDateUtils.commonDayFormat2(
                                NKDateUtils.formatStringUTCDateTime(
                                    pendingOrderData.orderCreatAt.toString())),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name : ${pendingOrderData.businessName}'),
                              Text('Email : ${pendingOrderData.email}'),
                              Text('Phone : ${pendingOrderData.mobileno}'),
                              Text(
                                  'Salesman : ${pendingOrderData.salesmanName}'),
                            ],
                          ),
                          if (invoice) ...[
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Payment Status : ',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      TextSpan(
                                        text:
                                            (pendingOrderData.paymentStatus == 0
                                                ? 'NOT PAID'
                                                : 'COMPLETED'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              pendingOrderData.paymentStatus ==
                                                      0
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                    'Payment Mode : ${_getPaymentTypeName(pendingOrderData.paymentStatus!)}'),
                              ],
                            ),
                          ],
                          const Spacer(),
                          ClipOval(
                            child: Container(
                              height: 50,
                              width: 50,
                              color: Colors.lightBlue[100],
                              child: pendingOrderData.imageUrl != null
                                  ? Image.network(
                                      '${pendingOrderData.imageUrl}',
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.person,
                                      color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('ITEMS ORDERED',
                            style: TextStyle(fontSize: 18))),
                    const Spacer(),
                    Text(
                        'Order Status : ${getStatusName(pendingOrderData.orderStatus!)}',
                        style: const TextStyle(fontSize: 18))
                  ],
                ),
                const Divider(
                  color: black,
                ),
                Obx(() {
                  return dashBoardController.isInvoiceLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DataTable(
                                    dataRowHeight: 40,
                                    headingRowHeight: 40,
                                    horizontalMargin: 20,
                                    headingTextStyle: const TextStyle(
                                      color: black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Expanded(
                                          flex: 2,
                                          child: Text(
                                            'ITEMS NAME',
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          flex: 2,
                                          child: Text(
                                            'QUANTITY',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          flex: 2,
                                          child: Text(
                                            'PRICE',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          flex: 2,
                                          child: Text(
                                            'TOTAL',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: dashBoardController
                                        .fetchSpecificOrderData!.cart!
                                        .map((item) {
                                      return DataRow(cells: [
                                        DataCell(
                                            Text(item.productName.toString())),
                                        DataCell(Center(
                                            child: Text(
                                                item.quantity.toString(),
                                                maxLines: 1))),
                                        DataCell(Center(
                                            child: Text(
                                          formatAmount(item.price),
                                          maxLines: 1,
                                        ))),
                                        DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatAmount(item.price),
                                                maxLines: 1))),
                                      ]);
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          color: black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatAmount(dashBoardController
                                            .fetchSpecificOrderData!
                                            .orderTotal),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                  if (dashBoardController
                                          .fetchSpecificOrderData!
                                          .cart!
                                          .first
                                          .tax !=
                                      null) ...[
                                    Row(
                                      children: [
                                        Text(
                                          '${dashBoardController.fetchSpecificOrderData!.cart!.first.taxName} - ${dashBoardController.fetchSpecificOrderData!.cart!.first.tax} %',
                                          style: const TextStyle(
                                            color: black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatAmount(
                                              '${dashBoardController.fetchSpecificOrderData!.orderTotal! * dashBoardController.fetchSpecificOrderData!.cart!.first.tax! / 100}'),
                                          // formatAmount(invoiceData.cart!.first.tax),
                                          // taxAmount), // Use the calculated tax amount here
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                  Divider(color: Colors.grey.shade400),
                                  Row(
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          color: black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        dashBoardController
                                                    .fetchSpecificOrderData!
                                                    .cart!
                                                    .first
                                                    .tax !=
                                                null
                                            ? formatAmount(
                                                '${(dashBoardController.fetchSpecificOrderData!.orderTotal! + dashBoardController.fetchSpecificOrderData!.orderTotal! * dashBoardController.fetchSpecificOrderData!.cart!.first.tax! / 100)}')
                                            : formatAmount(dashBoardController
                                                .fetchSpecificOrderData!
                                                .orderTotal),
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Currency  \$',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            )
            // }),
            ),
      );
    },
  );
}

String _getPaymentTypeName(int paymentType) {
  switch (paymentType) {
    case 0:
      return 'Cash';
    case 1:
      return 'Cheque';
    case 2:
      return 'Bank Transfer';
    default:
      return 'Unknown';
  }
}
