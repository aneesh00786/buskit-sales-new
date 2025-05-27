// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample2 extends StatefulWidget {
  const BarChartSample2({super.key});
  final Color leftBarColor = primaryColor;
  final Color rightBarColor = secondaryColor;
  final Color avgColor = Colors.orange;
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 60, 150);
    final barGroup2 = makeGroupData(1, 55, 90);
    final barGroup3 = makeGroupData(2, 70, 110);
    final barGroup4 = makeGroupData(3, 70, 130);
    final barGroup5 = makeGroupData(4, 50, 115);
    final barGroup6 = makeGroupData(5, 85, 108);
    final barGroup7 = makeGroupData(6, 30, 175);
    final barGroup8 = makeGroupData(7, 20, 120);
    final barGroup9 = makeGroupData(8, 50, 100);
    final barGroup10 = makeGroupData(9, 60, 155);
    final barGroup11 = makeGroupData(10, 70, 155);
    final barGroup12 = makeGroupData(11, 90, 100);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
      barGroup8,
      barGroup9,
      barGroup10,
      barGroup11,
      barGroup12,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: BarChart(
        BarChartData(
          maxY: 200,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (a, b, c, d) => null,
            ),
            touchCallback: (FlTouchEvent event, response) {
              if (response == null || response.spot == null) {
                setState(() {
                  touchedGroupIndex = -1;
                  showingBarGroups = List.of(rawBarGroups);
                });
                return;
              }

              touchedGroupIndex = response.spot!.touchedBarGroupIndex;

              setState(() {
                if (!event.isInterestedForInteractions) {
                  touchedGroupIndex = -1;
                  showingBarGroups = List.of(rawBarGroups);
                  return;
                }
                showingBarGroups = List.of(rawBarGroups);
                if (touchedGroupIndex != -1) {
                  var sum = 0.0;
                  for (final rod
                      in showingBarGroups[touchedGroupIndex].barRods) {
                    sum += rod.toY;
                  }
                  final avg =
                      sum / showingBarGroups[touchedGroupIndex].barRods.length;

                  showingBarGroups[touchedGroupIndex] =
                      showingBarGroups[touchedGroupIndex].copyWith(
                    barRods:
                        showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                      return rod.copyWith(toY: avg, color: widget.avgColor);
                    }).toList(),
                  );
                }
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 40,
                getTitlesWidget: leftTitles,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: rawBarGroups,
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Color(0x6E9C9EA4),
                );
              },
              horizontalInterval: 40),
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '0K';
    } else if (value == 40) {
      text = '40K';
    } else if (value == 80) {
      text = '80K';
    } else if (value == 120) {
      text = '120K';
    } else if (value == 160) {
      text = '160K';
    } else if (value == 200) {
      text = '200K';
    } else {
      text = '0';
    }
    return SideTitleWidget(
      meta: TitleMeta(
        min: 0, 
        max: 100, 
        parentAxisSize: 50,
        axisPosition: 0,
        appliedInterval: 10,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30, 
          interval: 10, 
        ),
        formattedValue: 'YourFormattedValue', 
        axisSide: AxisSide
            .left, 
        rotationQuarterTurns: 0, 
      ),
      child: MyRegularText(label: text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      meta: TitleMeta(
        min: 0, 
        max: 100,
        parentAxisSize: 50, 
        axisPosition: 0, 
        appliedInterval: 10, 
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30, 
          interval: 10, 
        ),
        formattedValue: 'YourFormattedValue', 
        axisSide: AxisSide
            .left,
        rotationQuarterTurns: 0,
      ),
      space: 16, 
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 10,
      x: x,
      barRods: [
        BarChartRodData(
            toY: y2,
            color: widget.leftBarColor,
            width: width,
            fromY: 0,
            rodStackItems: [
              BarChartRodStackItem(y1, y2, widget.rightBarColor)
            ]),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
