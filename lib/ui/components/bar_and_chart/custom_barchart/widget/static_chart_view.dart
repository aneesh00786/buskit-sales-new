import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/custom_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/barchart_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/helpers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StaticChartView extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final int dynamicMaxY;
  final int dynamicInterval;
  final CustomBarChart widget;

  const StaticChartView({
    super.key,
    required this.barGroups,
    required this.dynamicMaxY,
    required this.dynamicInterval,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 3.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dynamicMaxY.toDouble(),
                barGroups: barGroups,
                titlesData: getTitlesData(
                  dynamicMaxY,
                  dynamicInterval,
                  widget.allCategory,
                ),
                borderData: FlBorderData(
                  show: true,
                  border:
                      Border.all(color: const Color(0xffe0e0e0), width: 0.9),
                ),
                barTouchData: getBarTouchData(
                  context,
                  barGroups,
                  widget.allCategory,
                  widget.categoryPerformance,
                  widget.monthlyPerformance,
                  widget.isDayOrRange,
                  widget.staffProjection,
                  widget.targetType,
                ),
              ),
            ),
          ),
          BarChartDataWidget(
            dynamicMaxY: dynamicMaxY,
            dynamicInterval: dynamicInterval,
            widget: widget,
          ),
        ],
      ),
    );
  }
}