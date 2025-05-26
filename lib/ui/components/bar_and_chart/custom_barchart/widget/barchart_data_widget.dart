import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/custom_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/create_groups.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartDataWidget extends StatelessWidget {
  const BarChartDataWidget({
    super.key,
    required this.dynamicMaxY,
    required this.dynamicInterval,
    required this.widget,
  });

  final int dynamicMaxY;
  final int dynamicInterval;
  final CustomBarChart widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 0, top: 3),
        color: white,
        width: dynamicMaxY.toString().length * 7 + 10,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: dynamicMaxY.toDouble(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: dynamicInterval.toDouble(),
                  getTitlesWidget: getLeftTitles,
                  reservedSize: dynamicMaxY.toString().length * 7 + 10,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) =>
                      getBottomTitlesDummy(value, meta, widget.allCategory),
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.transparent,
                width: 0.9,
              ),
            ),
          ),
        ),
      ),
    );
  }
}