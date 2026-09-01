// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:math';

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';

class PendingPaymentChart extends StatefulWidget {
  final PendingPaymentController chartController;
  final Function(int) onBarTapped;

  const PendingPaymentChart({
    super.key,
    required this.chartController,
    required this.onBarTapped,
  });

  @override
  State<PendingPaymentChart> createState() => _PendingPaymentChartState();
}

class _PendingPaymentChartState extends State<PendingPaymentChart> {
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
      final barData = widget.chartController;

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

      if (widget.chartController.isLoadingPayment.value) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }
      if (widget.chartController.orderDataList.isEmpty) {
        return const Center(child: NodataWidget());
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            maxY: dynamicMaxY.toDouble(),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    TextStyle style = const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    );
                    switch (value.toInt()) {
                      case 0:
                        return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              if (barData.totalAmount.value > 0) {
                                widget.onBarTapped(0);
                              }
                            },
                            child: Text('All'.tr, style: style));
                      case 1:
                        return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              if (barData.nearlyDueAmount.value > 0) {
                                widget.onBarTapped(1);
                              }
                            },
                            child: Text('Nearly Due'.tr, style: style));
                      case 2:
                        return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              if (barData.dueAmount.value > 0) {
                                widget.onBarTapped(2);
                              }
                            },
                            child: Text('Due'.tr, style: style));
                      case 3:
                        return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              if (barData.overdueAmount.value > 0) {
                                widget.onBarTapped(3);
                              }
                            },
                            child: Text('Overdue'.tr, style: style));
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: formatAmount(dynamicMaxY).length * 7.5 + 16,
                  interval: dynamicInterval.toDouble(),
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      formatAmount(value),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                  color: const Color(0xFFE2E8F0).withOpacity(0.7),
                  strokeWidth: 0.8,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: const Color(0xFFE2E8F0).withOpacity(0.7),
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
                      fontFamily: 'Poppins_Regular',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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
                    widget.onBarTapped(touchedIndex);
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
                    color: primaryColor,
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
                    color: const Color(0xFFF59E0B),
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
                    color: const Color(0xFFF97316),
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
                    color: const Color(0xFFDC2626),
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
