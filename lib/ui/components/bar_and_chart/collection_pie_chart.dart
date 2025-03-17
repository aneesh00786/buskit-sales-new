
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
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 40.0 : 40.0;
      //final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 1:
          return PieChartSectionData(
            color: const Color(0xff5581e7),
            value:23.3,
            //widget.collectionData.payment?.percentage?.toString() ?? 0,
            title:
                "${widget.collectionData.payment?.percentage.toString() ?? 0}%",
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
            color: const Color(0xff44afd9),
            value:12.34,
            title:
                "${widget.collectionData.order?.percentage.toString() ?? 0}%",
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
