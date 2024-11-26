import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';

class PendingPaymentChart extends StatelessWidget {
  final PendingPaymentController chartController;
  final Function(int) onBarTapped; // Callback for when a bar is tapped

  const PendingPaymentChart({
    Key? key,
    required this.chartController,
    required this.onBarTapped, // Accept the callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BarChart(
        BarChartData(
          maxY: 25,
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade300, width: 1),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('All');
                    case 1:
                      return Text('Nearly Due');
                    case 2:
                      return Text('Due');
                    case 3:
                      return Text('Overdue');
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            verticalInterval: 1,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[300],
                strokeWidth: 1,
              );
            },
          ),
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              if (response != null && response.spot != null) {
                final touchedIndex = response.spot!.touchedBarGroupIndex;
                final barData = chartController.chartData.value;

                // Get the corresponding bar's value based on the index
                final tappedValue = touchedIndex == 0
                    ? barData.all
                    : touchedIndex == 1
                        ? barData.nearlyDue
                        : touchedIndex == 2
                            ? barData.due
                            : barData.overdue;

                // Trigger callback only if the tapped bar value is greater than 0
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
                  toY: chartController.chartData.value.all.toDouble(),
                  color: Colors.purple.shade900,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              barsSpace: 10,
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: chartController.chartData.value.nearlyDue.toDouble(),
                  color: Colors.blue.shade900,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              barsSpace: 10,
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: chartController.chartData.value.due.toDouble(),
                  color: Colors.yellow.shade800,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              barsSpace: 10,
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: chartController.chartData.value.overdue.toDouble(),
                  color: Colors.red.shade900,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                ),
              ],
              barsSpace: 10,
            ),
          ],
        ),
      ),
    );
  }
}
