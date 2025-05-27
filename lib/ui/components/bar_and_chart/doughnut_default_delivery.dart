import 'package:busskit_salesexecutive/ui/components/bar_and_chart/show_ordersstatus_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;

class DoughnutDefaultDelivery extends StatefulWidget {
  final Delivery deliveryData;
  final Color aColor;
  final Color bColor;
  final Color cColor;
  final Widget legend1;
  final Widget legend2;
  final bool isBig;

  const DoughnutDefaultDelivery({
    super.key,
    required this.deliveryData,
    required this.aColor,
    required this.bColor,
    required this.cColor,
    required this.legend1,
    required this.legend2,
    this.isBig = false,
  });

  @override
  // ignore: library_private_types_in_public_api
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
    final orderProcessingValue = _getOrderValueByStatus(5);
    final outForDeliveryValue = _getOrderValueByStatus(1);
    final deliveredValue = _getOrderValueByStatus(2);
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
              centerSpaceRadius: widget.isBig ? 80 : 43,
              sections: [
                fl_chart.PieChartSectionData(
                  value: adjustedPercentages[0],
                  color: widget.aColor,
                  radius: widget.isBig ? 60 : 25,
                  showTitle: false,
                  title: '${adjustedPercentages[0].toStringAsFixed(1)}%',
                ),
                fl_chart.PieChartSectionData(
                  value: adjustedPercentages[1],
                  color: widget.bColor,
                  radius: widget.isBig ? 60 : 25,
                  showTitle: false,
                  title: '${adjustedPercentages[1].toStringAsFixed(1)}%',
                ),
                fl_chart.PieChartSectionData(
                  value: adjustedPercentages[2],
                  color: widget.cColor,
                  radius: widget.isBig ? 60 : 25,
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
                        section.touchedSection?.value == adjustedPercentages[0]
                            ? 'Processing Orders'
                            : section.touchedSection?.value ==
                                    adjustedPercentages[1]
                                ? 'Packed & Ready for Delivery'
                                : section.touchedSection!.value ==
                                        adjustedPercentages[2]
                                    ? 'Delivered Orders'
                                    : 'Unknown';
                    final status =
                        section.touchedSection?.value == adjustedPercentages[0]
                            ? 5
                            : section.touchedSection!.value ==
                                    adjustedPercentages[1]
                                ? 1
                                : section.touchedSection!.value ==
                                        adjustedPercentages[2]
                                    ? 2
                                    : -1;

                    showValueOrderDialog(
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

  List<double> _adjustPercentages(List<double> percentages) {
    const minPercentage = 3.0;
    final adjustedPercentages = percentages.map((p) {
      if (p > 0 && p < minPercentage) {
        return minPercentage;
      }
      return p;
    }).toList();
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
}
