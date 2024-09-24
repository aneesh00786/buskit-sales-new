import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_total_sale_response.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomerOrderDeleveryPieChart extends StatefulWidget {
  final TotalSale deleveryData;
  const CustomerOrderDeleveryPieChart({super.key, required this.deleveryData});

  @override
  State<StatefulWidget> createState() => CustomerOrderDeleveryPieChartState();
}

class CustomerOrderDeleveryPieChartState
    extends State<CustomerOrderDeleveryPieChart> {
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
      final radius = isTouched ? 60.0 : 60.0;
      //final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value:
                widget.deleveryData.paymentRemaning?.percentage?.toDouble() ??
                    0.0,
            title:
                "${widget.deleveryData.paymentRemaning?.percentage.toString() ?? 0}%",
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
            value:
                widget.deleveryData.paymentCompleted?.percentage?.toDouble() ??
                    0.0,
            title:
                "${widget.deleveryData.paymentCompleted?.percentage.toString() ?? 0}%",
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
