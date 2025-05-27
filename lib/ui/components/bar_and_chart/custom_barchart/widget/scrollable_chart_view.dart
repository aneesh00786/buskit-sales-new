import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/custom_bar_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/barchart_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/custombarchart_view.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollableChartView extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final int dynamicMaxY;
  final int dynamicInterval;
  final CustomBarChart widget;

  const ScrollableChartView({
    super.key,
    required this.barGroups,
    required this.dynamicMaxY,
    required this.dynamicInterval,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController =
        Provider.of<DashboardProvider>(context, listen: false).scrollController;

    double chartWidth = barGroups.length * 66.0;
    double finalWidth = chartWidth > MediaQuery.of(context).size.width
        ? chartWidth
        : MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.blueAccent.shade400),
          trackColor: WidgetStateProperty.all(Colors.blue.shade50),
          thickness: WidgetStateProperty.all(6),
          radius: const Radius.circular(10),
        ),
        child: Stack(
          children: [
            Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: CustomBarChartView(
                  finalWidth: finalWidth,
                  dynamicMaxY: dynamicMaxY.toDouble(),
                  dynamicInterval: dynamicInterval,
                  barGroups: barGroups,
                  targetType: widget.targetType,
                  isDayOrRange: widget.isDayOrRange,
                  staffProjection: widget.staffProjection,
                  allCategory: widget.allCategory,
                  monthlyPerformance: widget.monthlyPerformance,
                  categoryPerformance: widget.categoryPerformance,
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
      ),
    );
  }
}