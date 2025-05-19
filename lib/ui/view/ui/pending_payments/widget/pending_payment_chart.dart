import 'dart:math';

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';

// class PendingPaymentChart extends StatelessWidget {
//   final PendingPaymentController chartController;
//   final Function(int) onBarTapped;

//   const PendingPaymentChart({
//     Key? key,
//     required this.chartController,
//     required this.onBarTapped,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => BarChart(
//         BarChartData(
//           maxY: 25,
//           borderData: FlBorderData(
//             show: true,
//             border: Border(
//               left: BorderSide(color: Colors.grey.shade300, width: 1),
//               bottom: BorderSide(color: Colors.grey.shade300, width: 1),
//               top: BorderSide(color: Colors.grey.shade300, width: 1),
//             ),
//           ),
//           titlesData: FlTitlesData(
//             show: true,
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (double value, TitleMeta meta) {
//                   switch (value.toInt()) {
//                     case 0:
//                       return Text('All');
//                     case 1:
//                       return Text('Nearly Due');
//                     case 2:
//                       return Text('Due');
//                     case 3:
//                       return Text('Overdue');
//                     default:
//                       return Text('');
//                   }
//                 },
//               ),
//             ),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 interval: 5,
//                 getTitlesWidget: (double value, TitleMeta meta) {
//                   return Text(
//                     value.toInt().toString(),
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           gridData: FlGridData(
//             show: true,
//             drawVerticalLine: true,
//             verticalInterval: 1,
//             horizontalInterval: 5,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: Colors.grey[300],
//                 strokeWidth: 1,
//               );
//             },
//             getDrawingVerticalLine: (value) {
//               return FlLine(
//                 color: Colors.grey[300],
//                 strokeWidth: 1,
//               );
//             },
//           ),
//           barTouchData: BarTouchData(
//             touchCallback: (event, response) {
//               if (response != null && response.spot != null) {
//                 final touchedIndex = response.spot!.touchedBarGroupIndex;
//                 final barData = chartController.chartData.value;
//                 final tappedValue = touchedIndex == 0
//                     ? barData.all
//                     : touchedIndex == 1
//                         ? barData.nearlyDue
//                         : touchedIndex == 2
//                             ? barData.due
//                             : barData.overdue;
//                 if (tappedValue > 0) {
//                   onBarTapped(touchedIndex);
//                 }
//               }
//             },
//           ),
//           barGroups: [
//             BarChartGroupData(
//               x: 0,
//               barRods: [
//                 BarChartRodData(
//                   toY: chartController.chartData.value.all.toDouble(),
//                   color: Colors.purple.shade900,
//                   width: 20,
//                   borderRadius: BorderRadius.zero,
//                 ),
//               ],
//               barsSpace: 10,
//             ),
//             BarChartGroupData(
//               x: 1,
//               barRods: [
//                 BarChartRodData(
//                   toY: chartController.chartData.value.nearlyDue.toDouble(),
//                   color: Colors.blue.shade900,
//                   width: 20,
//                   borderRadius: BorderRadius.zero,
//                 ),
//               ],
//               barsSpace: 10,
//             ),
//             BarChartGroupData(
//               x: 2,
//               barRods: [
//                 BarChartRodData(
//                   toY: chartController.chartData.value.due.toDouble(),
//                   color: Colors.yellow.shade800,
//                   width: 20,
//                   borderRadius: BorderRadius.zero,
//                 ),
//               ],
//               barsSpace: 10,
//             ),
//             BarChartGroupData(
//               x: 3,
//               barRods: [
//                 BarChartRodData(
//                   toY: chartController.chartData.value.overdue.toDouble(),
//                   color: Colors.red.shade900,
//                   width: 20,
//                   borderRadius: BorderRadius.zero,
//                 ),
//               ],
//               barsSpace: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

    // Round to a "nice" number
    int exponent = (log(roughInterval) / ln10).floor();
    double base = pow(10, exponent).toDouble();

    // Choose a rounded value from common steps
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

      // final int dynamicInterval;
      // if (dynamicMaxY >= 1000000000) {
      //   dynamicInterval = 1000000000;
      // } else if (dynamicMaxY >= 100000000) {
      //   dynamicInterval = 100000000;
      // } else if (dynamicMaxY >= 10000000) {
      //   dynamicInterval = 10000000;
      // } else if (dynamicMaxY >= 1000000) {
      //   dynamicInterval = 1000000;
      // } else if (dynamicMaxY >= 1000000) {
      //   dynamicInterval = 100000;
      // } else if (dynamicMaxY >= 500000) {
      //   dynamicInterval = 50000;
      // } else if (dynamicMaxY >= 200000) {
      //   dynamicInterval = 20000;
      // } else if (dynamicMaxY >= 100000) {
      //   dynamicInterval = 10000;
      // } else if (dynamicMaxY >= 50000) {
      //   dynamicInterval = 5000;
      // } else if (dynamicMaxY >= 10000) {
      //   dynamicInterval = 1000;
      // } else if (dynamicMaxY >= 1000) {
      //   dynamicInterval = 100;
      // } else {
      //   dynamicInterval = 10;
      // }

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
