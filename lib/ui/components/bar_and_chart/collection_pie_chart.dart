
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CollectionPieChart extends StatefulWidget {
  final Collection collectionData;
  const CollectionPieChart({super.key, required this.collectionData});

  @override
  State<StatefulWidget> createState() => CollectionPieChartState();
}

class CollectionPieChartState extends State<CollectionPieChart> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool hasValidData = (widget.collectionData.payment?.percentage ?? 0) > 0 &&
        (widget.collectionData.order?.percentage ?? 0) > 0;

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
            show: false,
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

      switch (i) {
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: double.parse(
                "${widget.collectionData.payment?.percentage?.toString() ?? '0.0'}"),
            title: "${widget.collectionData.payment?.percentage?.toString() ?? '0'}%",
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
                "${widget.collectionData.order?.percentage?.toString() ?? '0.0'}"),
            title: "${widget.collectionData.order?.percentage?.toString() ?? '0'}%",
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
          throw Exception('Unexpected index');
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
            value: 40.0,
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
          throw Exception('Unexpected index');
      }
    });
  }
}
