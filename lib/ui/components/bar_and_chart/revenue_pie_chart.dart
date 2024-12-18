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
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
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
                    _showValueDialog(context, widget.categoryData, title);
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

//   void _showValueDialog(BuildContext context, Revenue categoryData, String title) {
//     // Implement your dialog here
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(title == 'Order Revenue'
//             ? 'Total Order Revenue: \$${categoryData.orderRevenueData?.fold(0.0, (sum, item) => sum + (item.totalOrderRevenue?.toDouble() ?? 0.0)).toStringAsFixed(2)}'
//             : 'Total Booking Revenue: \$${categoryData.bookingRevenueData?.fold(0.0, (sum, item) => sum + (item.total ?? 0.0)).toStringAsFixed(2)}'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }

  void _showValueDialog(
      BuildContext context, Revenuee categoryData, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AlertDialog(
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins_Regular',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: SizedBox(
                            width: 25.8,
                            height: 25.8,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.5),
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
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      dataRowHeight: 30,
                      headingRowHeight: 40,
                      columnSpacing: 30,
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
                      ],
                      rows: categoryData.orderRevenueData!.map((item) {
                        log('DATE ${item.orderCreatAt}');
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
                                item.status.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                              ),
                            )),
                            DataCell(Center(
                              child: Text(
                                '\$${item.total}',
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
                    ),
                  ),
                ],
              ),
            ),
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
  final Color dColor;
  final Widget sabik;
  final Widget sabik1;

  const DoughnutDefaultDelivery({
    Key? key,
    required this.deliveryData,
    required this.aColor,
    required this.bColor,
    required this.cColor,
    required this.dColor,
    required this.sabik,
    required this.sabik1,
  }) : super(key: key);

  @override
  _DoughnutDefaultDeliveryState createState() =>
      _DoughnutDefaultDeliveryState();
}

class _DoughnutDefaultDeliveryState extends State<DoughnutDefaultDelivery> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y%');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderProcessingValue = _getOrderValueByStatus(5);
    final packedForDeliveryValue = _getOrderValueByStatus(10);
    final outForDeliveryValue = _getOrderValueByStatus(1);
    final deliveredValue = _getOrderValueByStatus(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: fl_chart.PieChart(
            fl_chart.PieChartData(
              startDegreeOffset: 250,
              sectionsSpace: 0.6,
              centerSpaceRadius: 60,
              sections: [
                fl_chart.PieChartSectionData(
                  value: orderProcessingValue,
                  color: widget.aColor,
                  radius: 25,
                  showTitle: false,
                ),
                fl_chart.PieChartSectionData(
                  value: packedForDeliveryValue,
                  color: widget.bColor,
                  radius: 25,
                  showTitle: false,
                ),
                fl_chart.PieChartSectionData(
                  value: outForDeliveryValue,
                  color: widget.cColor,
                  radius: 25,
                  showTitle: false,
                ),
                fl_chart.PieChartSectionData(
                  value: deliveredValue,
                  color: widget.dColor,
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
                    final PieChartSectionData touchedSectionData =
                        section.touchedSection ?? PieChartSectionData();
                    final title = touchedSectionData.value ==
                            orderProcessingValue
                        ? 'Order Processing'
                        : touchedSectionData.value == packedForDeliveryValue
                            ? 'Packed for Delivery'
                            : touchedSectionData.value == outForDeliveryValue
                                ? 'Out for Delivery'
                                : touchedSectionData.value == deliveredValue
                                    ? 'Delivered'
                                    : 'Unknown';
                    final status = touchedSectionData.value ==
                            orderProcessingValue
                        ? 5
                        : touchedSectionData.value == packedForDeliveryValue
                            ? 10
                            : touchedSectionData.value == outForDeliveryValue
                                ? 1
                                : touchedSectionData.value == deliveredValue
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
        widget.sabik1,
        const SizedBox(height: 2.5),
        widget.sabik,
      ],
    );
  }

  double _getOrderValueByStatus(int status) {
    final order = widget.deliveryData.order?.totalOrders?.lastWhere(
      (orderDetails) => orderDetails.orderStatus == status,
      orElse: () => OrderDetails(
        orderId: '',
        orderStatus: status,
        orderTotal: 0,
        transactionDate: '',
        orderProcessing: 0,
        packedForDelivery: 0,
        outForDelivery: 0,
        delivered: 0,
        id: 0,
        customerId: '',
        salesmanId: '',
        paymentStatus: 0,
        paymentType: 0,
        paymentDetail: '',
        cartId: '',
        orderCreateAt: '',
        receivedAmount: 0,
        checkDueDate: '',
        transactionDetails: '',
        checkNumber: 0,
      ),
    );
    return status == 5
        ? order!.orderProcessing!.toDouble()
        : status == 10
            ? order!.packedForDelivery!.toDouble()
            : status == 1
                ? order!.outForDelivery!.toDouble()
                : status == 2
                    ? order!.delivered!.toDouble()
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
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: SizedBox(
                          width: 25.8,
                          height: 25.8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.5),
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ),
                          ),
                        ),
                      )
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
                    rows: filteredOrders.map((orderDetails) {
                      return DataRow(
                        cells: [
                          DataCell(Center(
                            child: Text(
                                getFormattedOrderCreatAt(
                                    orderDetails.orderCreateAt ?? ''),
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center),
                          )),
                          DataCell(Center(
                            child: Text(orderDetails.orderId ?? '',
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center),
                          )),
                          DataCell(Center(
                            child: Text(
                                _getStatusName(orderDetails.orderStatus ?? 0),
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center),
                          )),
                          DataCell(Center(
                            child: Text("\$${orderDetails.orderTotal}",
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusName(int status) {
    switch (status) {
      case 5:
        return 'Order Processing';
      case 10:
        return 'Packed for Delivery';
      case 1:
        return 'Out for Delivery';
      case 2:
        return 'Delivered';
      default:
        return 'Unknown';
    }
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
                _pendingPaymentCollectionDialog(context, collection);
              }
            },
          ),
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
                _pendingPaymentCollectionDialog(context, collection);
              } else if (details.pointIndex == 1) {
                _pendingPaymentCollectionDialog(context, collection);
              }
            },
          ),
        ],
      ),
    );
  }

  void _pendingPaymentCollectionDialog(
      BuildContext context, Collection collection) {
    String selectedPaymentMethod = 'Cash';
    RxInt selectedPaymentMethodInt = 0.obs;

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

    double calculateTotalBalanceAmount() {
      double total = 0;
      for (int i = 0; i < selectedItems.length; i++) {
        if (selectedItems[i]) {
          final receivable =
              collection.order!.pendingAmount![i].receivableAmount;
          if (receivable == null) {
            total += collection.order!.pendingAmount![i].orderTotal!.toDouble();
          } else {
            total += receivable;
          }
        }
      }
      return total;
    }

    void processPayments(List<PendingAmount> selectedItems, int enteredAmount) {
      // Your processing logic for payments, without the controller
      print("Processing payments with amount: $enteredAmount");
      for (var item in selectedItems) {
        print(
            "Processing item: ${item.orderId} with amount: ${item.orderTotal}");
        // Add further logic to adjust amounts, mark items as paid, etc.
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header of the dialog
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
                      const Text(
                        'Payment',
                        style: TextStyle(
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
                // First table
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DataTable(
                          dataRowHeight: 30,
                          headingRowHeight: 40,
                          border: TableBorder.all(color: Colors.grey.shade300),
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
                          rows: collection.order!.pendingAmount!
                              .asMap()
                              .entries
                              .map<DataRow>((entry) {
                            int index = entry.key;
                            var payment = entry.value;
                            return DataRow(cells: [
                              DataCell(Center(
                                  child: Text(getFormattedOrderCreatAt(
                                      payment.orderCreatAt)))),
                              DataCell(Center(
                                  child: Text(payment.orderId.toString()))),
                              DataCell(Center(
                                  child:
                                      Text(formatAmount(payment.orderTotal)))),
                              DataCell(Center(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xff008000),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      getStatusLabel(payment.orderStatus),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                              DataCell(
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: payment.paymentStatus == 0
                                          ? Colors.red
                                          : Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: payment.paymentStatus == 0
                                            ? Colors.red
                                            : Colors.green,
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
                                      initialValue:
                                          payment.orderTotal.toString(),
                                      index: index,
                                      orderId: payment.orderId.toString(),
                                      orderTotal: payment.orderTotal!.toInt(),
                                      receivable:
                                          payment.receivableAmount != null
                                              ? double.tryParse(payment
                                                          .receivableAmount
                                                          .toString())
                                                      ?.toInt() ??
                                                  0
                                              : 0,
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
                                      // Update selected items list when checkbox is toggled
                                      selectedItems[index] = value ?? false;

                                      // Recalculate total balance amount
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
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                    ),
                                    dropdownColor: Colors.white,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Cash', child: Text('Cash')),
                                      DropdownMenuItem(
                                          value: 'Cheque',
                                          child: Text('Cheque')),
                                      DropdownMenuItem(
                                          value: 'Bank Transfer',
                                          child: Text('Bank Transfer')),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        selectedPaymentMethod = value;
                                        // Map the selected value to the corresponding integer
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        int enteredAmount = int.tryParse(
                                                receivedAmountController
                                                    .text) ??
                                            0;
                                        if (enteredAmount > 0) {
                                          // Gather selected items
                                          List<PendingAmount>
                                              selectedItemsList = [];
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
          ),
        );
      },
    );
  }
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
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SizedBox(
                        width: 25.8,
                        height: 25.8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.5),
                            child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Display DataTable of data based on the selected section
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
                  rows: _buildDataRows(collection, title),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

List<DataRow> _buildDataRows(Collection collection, String title) {
  switch (title) {
    case 'Completed':
      return collection.payment!.completedOrders!
          .map((completedOrder) => DataRow(
                cells: [
                  DataCell(
                    Center(
                      child: Text(
                        completedOrder.getFormattedOrderCreatAt(
                            completedOrder.orderCreatAt),
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
                        completedOrder.cartId,
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
                        completedOrder.transactionDetails,
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
                        '\$${completedOrder.orderTotal}',
                        style: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          .toList();
    case 'Pending':
      return collection.order!.pendingAmount!
          .map((pendingAmount) => DataRow(
                cells: [
                  DataCell(
                    Center(
                      child: Text(
                        getFormattedOrderCreatAt(
                          pendingAmount.orderCreatAt,
                        ),
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
                        pendingAmount.cartId ?? '',
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
                        pendingAmount.transactionDetails ?? '',
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
                        '\$${pendingAmount.orderTotal}',
                        style: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          .toList();
    case 'Due':
      return collection.due!.dueAmount!
          .map((dueAmount) => DataRow(
                cells: [
                  DataCell(
                    Center(
                      child: Text(
                        getFormattedOrderCreatAt(dueAmount.orderCreatAt),
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
                        dueAmount.cartId,
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
                        dueAmount.transactionDetails,
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
                        '\$${dueAmount.orderTotal}',
                        style: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          .toList();
    case 'Overdue':
      return collection.overdue!.overdueAmount!
          .map((overdueAmount) => DataRow(
                cells: [
                  DataCell(
                    Center(
                      child: Text(
                        getFormattedOrderCreatAt(overdueAmount.orderCreatAt),
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
                        overdueAmount.cartId ?? '',
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
                        overdueAmount.transactionDetails ?? '',
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
                        '\$${overdueAmount.orderTotal}',
                        style: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          .toList();
    default:
      return [];
  }
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
                            section.touchedSection!;
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

String getStatusLabel(int? orderStatus) {
  switch (orderStatus) {
    case 5:
      return 'Order Processing';
    case 10:
      return 'Packed for Delivery';
    case 1:
      return 'Out for Delivery';
    case 2:
      return 'Delivered';
    case 0:
      return 'Pre Order';
    default:
      return 'Unknown';
  }
}
