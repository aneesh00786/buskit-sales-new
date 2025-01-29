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
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/collection_dialog_table.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/show_ordersstatus_value_dialog.dart';
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
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../common_size/nk_general_size.dart';

class Revenuss {
  final RevenueData? totalSell;
  final RevenueData? sell;

  Revenuss({this.totalSell, this.sell});
}

class RevenueData {
  final double? percentage;
  final double? totalPrice;

  RevenueData({this.percentage, this.totalPrice});
}

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
const String totalString = "Total";
const String revenue = "Revenue";
const String booking = "Booking";
const Color revenueProgressBarColor = Colors.blue;
const Color revenueProgressBarFilledColor = Colors.green;

class DoughnutDefault extends StatefulWidget {
  final Revenuee categoryData;
  final dynamic booking;
  final dynamic order;
  final Color aColor;
  final Color bColor;
  final Widget legend1;
  final Widget legend2;
  final bool isBig;

  const DoughnutDefault({
    Key? key,
    required this.categoryData,
    required this.booking,
    required this.order,
    required this.legend1,
    required this.aColor,
    required this.bColor,
    required this.legend2,
    this.isBig = false,
  }) : super(key: key);

  @override
  _DoughnutDefaultState createState() => _DoughnutDefaultState();
}

class _DoughnutDefaultState extends State<DoughnutDefault> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final totalOrderRevenue = (widget.categoryData.orderRevenueData != null &&
            widget.categoryData.orderRevenueData!.isNotEmpty)
        ? widget.categoryData.orderRevenueData!.last.totalOrderRevenue
                ?.toDouble() ??
            0.0
        : 0.0;

    final totalBookingRevenue =
        (widget.categoryData.bookingRevenueData != null &&
                widget.categoryData.bookingRevenueData!.isNotEmpty)
            ? widget.categoryData.bookingRevenueData!.last.totalBookingRevenue
                    ?.toDouble() ??
                0.0
            : 0.0;

    final totalRevenue = totalBookingRevenue + totalOrderRevenue;

    final orderRevenuePercentage = totalRevenue > 0
        ? ((totalOrderRevenue / totalRevenue) * 100).clamp(0.0, 100.0)
        : 0.0;
    final bookingRevenuePercentage = totalRevenue > 0
        ? ((totalBookingRevenue / totalRevenue) * 100).clamp(0.0, 100.0)
        : 0.0;

    if (totalRevenue == 0) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: fl_chart.PieChart(
            fl_chart.PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 1.5,
              centerSpaceRadius: widget.isBig ? 80 : 43,
              sections: [
                fl_chart.PieChartSectionData(
                  value: bookingRevenuePercentage,
                  color: widget.bColor,
                  radius: widget.isBig ? 60 : 25,
                  showTitle: false,
                ),
                fl_chart.PieChartSectionData(
                  value: orderRevenuePercentage,
                  color: widget.aColor,
                  radius: widget.isBig ? 60 : 25,
                  showTitle: false,
                ),
              ],
              pieTouchData: fl_chart.PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? response) {
                  if (event is FlTapUpEvent &&
                      response != null &&
                      response.touchedSection != null) {
                    int touchedIndex =
                        response.touchedSection!.touchedSectionIndex;

                    if (touchedIndex == 1) {
                      const title = 'Order';
                      showValueDialog(context, widget.categoryData, title);
                    } else if (touchedIndex == 0) {
                      const title = 'Pre-Order';
                      showValueDialog(context, widget.categoryData, title);
                    }
                  }
                },
              ),
            ),
          ),
        ),
        widget.legend1,
        const SizedBox(height: 4),
        widget.legend2,
      ],
    );
  }
}


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
  
  final bool isBig;

  const NestedPieChartj(
      {super.key,
      required this.completedOrdersCount,
      required this.pendingAmountCount,
      required this.dueAmountCount,
      required this.overdueAmountCount,
      required this.collection,
    this.isBig = false,});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: isBig ? 350 : 200,
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
                  showValueCollectionDialog(
                      context, collection, 'Recieved Payment');
                } else if (details.pointIndex == 1) {
                  pendingPaymentCollectionDialog(
                      context, 'Pending Payment', collection);
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
                  pendingPaymentCollectionDialog(
                      context, 'Due Payment', collection);
                } else if (details.pointIndex == 1) {
                  pendingPaymentCollectionDialog(
                      context, 'Over Due Payment', collection);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}
  void pendingPaymentCollectionDialog(
      BuildContext context, String title, Collection collection) {
    final ScrollController scrollController = ScrollController();
    if (collection.order == null || collection.order!.pendingAmount == null) {
      print("Order or pendingAmount is null.");
      return;
    }

    String selectedPaymentMethod = 'Cash';
    RxInt selectedPaymentMethodInt = 0.obs;

    DateTime parseCustomDate(String dateStr) {
      final dateFormat = DateFormat("dd/MM/yyyy");
      return dateFormat.parse(dateStr);
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
              dueDate); 
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
          return dueDate.isBefore(DateTime.now());
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

        if (_isDateToday(dueDate)) {
          return Colors.amber; // Today
        } else if (_isDateBeforeToday(dueDate)) {
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

DateTime normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _isDateBeforeToday(DateTime date) {
  final today = normalizeDate(DateTime.now());
  final normalizedDate = normalizeDate(date);
  return normalizedDate.isBefore(today);
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
                    showDetailedOrderInvoiceDialog(
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
  final Widget legend1;
  final Widget legend2;
  final bool isBig;

  const DoughnutDefaultCustomerDash({
    Key? key,
    required this.customerData,
    required this.booking,
    required this.order,
    required this.legend1,
    required this.aColor,
    required this.bColor,
    required this.legend2,
    this.isBig = false,
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
                  startDegreeOffset: -90,
                  sectionsSpace: 1.5,
                  centerSpaceRadius: widget.isBig ? 80 : 43,
                  sections: [
                    fl_chart.PieChartSectionData(
                      value: paymentCompleted?.toDouble(),
                      color: widget.aColor,
                      radius: widget.isBig ? 60 : 25,
                      showTitle: false,
                    ),
                    fl_chart.PieChartSectionData(
                      value: paymentRemaining?.toDouble(),
                      color: widget.bColor,
                      radius: widget.isBig ? 60 : 25,
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
                            paymentCompleted?.toDouble();
                        final title =
                            isPaymentCompleted ? 'Pre-Orders' : 'Orders';
                        final orderDetails = isPaymentCompleted
                            ? widget
                                .customerData.data.revenue.bookingRevenueData
                            : widget.customerData.data.revenue.orderRevenueData;
                        if (orderDetails != null && orderDetails.isNotEmpty) {
                          showValueDialogCusDash(context, orderDetails, title);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        widget.legend2,
      ],
    );
  }
}


// class DoughnutDefaultCustomerDash extends StatefulWidget {
//   final CustomerRevenueResponse customerData;
//   final dynamic booking;
//   final dynamic order;
//   final Color aColor;
//   final Color bColor;
//   final Widget sabik;
//   final Widget sabik1;

//   const DoughnutDefaultCustomerDash({
//     Key? key,
//     required this.customerData,
//     required this.booking,
//     required this.order,
//     required this.sabik,
//     required this.aColor,
//     required this.bColor,
//     required this.sabik1,
//   }) : super(key: key);

//   @override
//   _DoughnutDefaultCustomerDashState createState() =>
//       _DoughnutDefaultCustomerDashState();
// }

// class _DoughnutDefaultCustomerDashState
//     extends State<DoughnutDefaultCustomerDash> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final paymentCompleted =
//         widget.customerData.data.revenue.bookingRevenueData?.isNotEmpty == true
//             ? widget.customerData.data.revenue.bookingRevenueData!.last
//                 .totalBookingRevenue
//             : 0;
//     final paymentRemaining =
//         widget.customerData.data.revenue.orderRevenueData?.isNotEmpty == true
//             ? widget.customerData.data.revenue.orderRevenueData!.last
//                 .totalOrderRevenue
//             : 0;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 3,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               fl_chart.PieChart(
//                 fl_chart.PieChartData(
//                   startDegreeOffset: 250,
//                   sectionsSpace: 0.6,
//                   centerSpaceRadius: 43,
//                   sections: [
//                     fl_chart.PieChartSectionData(
//                       value: paymentCompleted?.toDouble(),
//                       color: widget.aColor,
//                       radius: 19.6,
//                       showTitle: false,
//                     ),
//                     fl_chart.PieChartSectionData(
//                       value: paymentRemaining?.toDouble(),
//                       color: widget.bColor,
//                       radius: 19.6,
//                       showTitle: false,
//                     ),
//                   ],
//                   pieTouchData: fl_chart.PieTouchData(
//                     touchCallback:
//                         (FlTouchEvent event, PieTouchResponse? response) {
//                       if (event is FlTapUpEvent &&
//                           response != null &&
//                           response.touchedSection != null) {
//                         final section = response.touchedSection!;
//                         final PieChartSectionData touchedSectionData =
//                             section.touchedSection ?? PieChartSectionData();
//                         final isPaymentCompleted = touchedSectionData.value ==
//                             paymentCompleted;
//                         final title =
//                             isPaymentCompleted ? 'Bookings' : 'Orders';
//                         final orderDetails = isPaymentCompleted
//                             ? widget
//                                 .customerData.data.revenue.bookingRevenueData
//                             : widget.customerData.data.revenue.orderRevenueData;
//                         if (orderDetails != null && orderDetails.isNotEmpty) {
//                           showValueDialogCusDash(context, orderDetails, title);
//                         }
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         InkWell(
//           onTap: () {
//             showValueDialogCusDash(context, orderDetails, title);
//           },
//           child: widget.sabik1,
//         ),
//         const SizedBox(height: 4),
//         widget.sabik,
//       ],
//     );
//   }
// }