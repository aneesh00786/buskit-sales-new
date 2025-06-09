
// ignore_for_file: deprecated_member_use
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:flutter/material.dart';
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
    super.key,
    required this.categoryData,
    required this.booking,
    required this.order,
    required this.legend1,
    required this.aColor,
    required this.bColor,
    required this.legend2,
    this.isBig = false,
  });
  @override
  // ignore: library_private_types_in_public_api
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
                    (fl_chart.FlTouchEvent event, fl_chart.PieTouchResponse? response) {
                  if (event is fl_chart.FlTapUpEvent &&
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
class ChartData2 {
  final String label;
  final num value;
  final Color color;

  ChartData2(this.label, this.value, this.color);
}



