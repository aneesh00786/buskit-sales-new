import 'dart:developer';

import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrderDeleveryPieChart extends StatefulWidget {
  final Delivery deleveryData;
  const OrderDeleveryPieChart({super.key, required this.deleveryData});

  @override
  State<StatefulWidget> createState() => OrderDeleveryPieChartState();
}

class OrderDeleveryPieChartState extends State<OrderDeleveryPieChart> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool hasValidData = (widget.deleveryData.deliveryOrder?.percentage ?? 0) > 0 &&
        (widget.deleveryData.order?.percentage ?? 0) > 0;

    return AspectRatio(
      aspectRatio: 3.5,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(
            show: true,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: hasValidData ? showingSections() : dummySections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 60.0 : 60.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      log("${widget.deleveryData.order?.percentage.toString()}");
      switch (i) {
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: double.parse(
                "${widget.deleveryData.order?.percentage.toString() ?? '0'}0.0"),
            title: "${widget.deleveryData.order?.percentage.toString() ?? 0}%",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 0:
          return PieChartSectionData(
            color: Colors.yellow,
            value: double.parse(
                "${widget.deleveryData.deliveryOrder?.percentage.toString() ?? '0'}0.0"),
            title:
                "${widget.deleveryData.deliveryOrder?.percentage.toString() ?? 0}%",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgePositionPercentageOffset: .98,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }
  List<PieChartSectionData> dummySections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 60.0 : 60.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: 50.0,
            title: "50%",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 0:
          return PieChartSectionData(
            color: Colors.yellow,
            value: 30.0,
            title: "50%",
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgePositionPercentageOffset: .98,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }
}
