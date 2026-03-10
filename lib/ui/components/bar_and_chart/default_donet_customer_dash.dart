// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    super.key,
    required this.customerData,
    required this.booking,
    required this.order,
    required this.legend1,
    required this.aColor,
    required this.bColor,
    required this.legend2,
    this.isBig = false,
  });

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
                      value: paymentCompleted.toDouble(),
                      color: widget.aColor,
                      radius: widget.isBig ? 60 : 25,
                      showTitle: false,
                    ),
                    fl_chart.PieChartSectionData(
                      value: paymentRemaining.toDouble(),
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
                            paymentCompleted.toDouble();
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
