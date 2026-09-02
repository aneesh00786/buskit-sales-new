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

  Widget _buildSummaryPill({
    required String label,
    required double amount,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradientColors),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                formatAmount(amount),
                style: TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Legend / KPI Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSummaryPill(
                  label: 'All'.tr,
                  amount: barData.totalAmount.value,
                  color: const Color(0xFF1E3A8A),
                  gradientColors: [const Color(0xFF2563EB), const Color(0xFF1E3A8A)],
                  onTap: () {
                    if (barData.totalAmount.value > 0) widget.onBarTapped(0);
                  },
                ),
                _buildSummaryPill(
                  label: 'Nearly Due'.tr,
                  amount: barData.nearlyDueAmount.value,
                  color: const Color(0xFFD97706),
                  gradientColors: [const Color(0xFFFBBF24), const Color(0xFFD97706)],
                  onTap: () {
                    if (barData.nearlyDueAmount.value > 0) widget.onBarTapped(1);
                  },
                ),
                _buildSummaryPill(
                  label: 'Due'.tr,
                  amount: barData.dueAmount.value,
                  color: const Color(0xFFEA580C),
                  gradientColors: [const Color(0xFFFB923C), const Color(0xFFEA580C)],
                  onTap: () {
                    if (barData.dueAmount.value > 0) widget.onBarTapped(2);
                  },
                ),
                _buildSummaryPill(
                  label: 'Overdue'.tr,
                  amount: barData.overdueAmount.value,
                  color: const Color(0xFFDC2626),
                  gradientColors: [const Color(0xFFF87171), const Color(0xFFDC2626)],
                  onTap: () {
                    if (barData.overdueAmount.value > 0) widget.onBarTapped(3);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 4.0, bottom: 4.0),
              child: BarChart(
                BarChartData(
                  maxY: dynamicMaxY.toDouble(),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      left: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text('All'.tr, style: style),
                                  ));
                            case 1:
                              return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if (barData.nearlyDueAmount.value > 0) {
                                      widget.onBarTapped(1);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text('Nearly Due'.tr, style: style),
                                  ));
                            case 2:
                              return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if (barData.dueAmount.value > 0) {
                                      widget.onBarTapped(2);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text('Due'.tr, style: style),
                                  ));
                            case 3:
                              return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if (barData.overdueAmount.value > 0) {
                                      widget.onBarTapped(3);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text('Overdue'.tr, style: style),
                                  ));
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
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: dynamicInterval.toDouble(),
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFF1F5F9),
                        strokeWidth: 1.0,
                      );
                    },
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final titles = ['All', 'Nearly Due', 'Due', 'Overdue'];
                        final title = groupIndex < titles.length
                            ? titles[groupIndex].tr
                            : '';
                        return BarTooltipItem(
                          '$title\n',
                          const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          children: [
                            TextSpan(
                              text: formatAmount(rod.toY),
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response != null && response.spot != null) {
                        final touchedIndex =
                            response.spot!.touchedBarGroupIndex;
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
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                          ),
                          width: 26,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: dynamicMaxY.toDouble(),
                            color: const Color(0xFFF8FAFC),
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
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                          ),
                          width: 26,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: dynamicMaxY.toDouble(),
                            color: const Color(0xFFF8FAFC),
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
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                          ),
                          width: 26,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: dynamicMaxY.toDouble(),
                            color: const Color(0xFFF8FAFC),
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
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF87171), Color(0xFFDC2626)],
                          ),
                          width: 26,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: dynamicMaxY.toDouble(),
                            color: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ],
                      barsSpace: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
