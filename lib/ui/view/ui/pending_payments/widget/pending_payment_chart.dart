// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:math';

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
class PendingPaymentChart extends StatelessWidget {
  final PendingPaymentController chartController;
  final Function(int) onBarTapped;

  PendingPaymentChart({
    super.key,
    required this.chartController,
    required this.onBarTapped,
  });

    SubscriptionController subscriptionController =
      Get.find<SubscriptionController>();

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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final barData = chartController;

      final maxBarValue = max(
        max(barData.totalAmount.value, barData.nearlyDueAmount.value),
        max(barData.dueAmount.value, barData.overdueAmount.value),
      );

      final int magnitude =
          pow(10, maxBarValue.toInt().toString().length - 1).toInt();
      final int dynamicMaxY = ((maxBarValue / magnitude).ceil()) * magnitude;
      int maxDivisions = 10;
      int dynamicInterval = calculateNiceInterval(dynamicMaxY, maxDivisions);

       if (subscriptionController.appPendingPaymentList.value != "true") {
        return Center(
          child: UpgradePlanButton(),
        );
      }

      if (chartController.isLoadingPayment.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (chartController.orderDataList.isEmpty) {
        return const Center(child: NodataWidget());
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            maxY: dynamicMaxY.toDouble(),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    TextStyle style = const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    switch (value.toInt()) {
                      case 0:
                        return Text('All', style: style);
                      case 1:
                        return Text('Nearly Due', style: style);
                      case 2:
                        return Text('Due', style: style);
                      case 3:
                        return Text('Overdue', style: style);
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: formatAmount(dynamicMaxY).length * 5 + 10,
                  interval: dynamicInterval.toDouble(),
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      formatAmount(value),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              horizontalInterval: dynamicInterval.toDouble(),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300.withOpacity(0.5),
                  strokeWidth: 0.8,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300.withOpacity(0.5),
                  strokeWidth: 0.8,
                );
              },
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: Colors.grey.shade200,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
              ),
              touchCallback: (event, response) {
                if (response != null && response.spot != null) {
                  final touchedIndex = response.spot!.touchedBarGroupIndex;
                  final tappedValue = touchedIndex == 0
                      ? barData.totalAmount.value
                      : touchedIndex == 1
                          ? barData.nearlyDueAmount.value
                          : touchedIndex == 2
                              ? barData.dueAmount.value
                              : barData.overdueAmount.value;

                  if (tappedValue > 0) {
                    onBarTapped(touchedIndex);
                  }
                }
              },
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: barData.totalAmount.value,
                    color: Colors.purple.shade900,
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                ],
                barsSpace: 12,
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: barData.nearlyDueAmount.value,
                    color: Colors.blue.shade900,
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                ],
                barsSpace: 12,
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: barData.dueAmount.value,
                    color: Colors.yellow.shade800,
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                ],
                barsSpace: 12,
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(
                    toY: barData.overdueAmount.value,
                    color: Colors.red.shade900,
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                ],
                barsSpace: 12,
              ),
            ],
          ),
        ),
      );
    });
  }
}
