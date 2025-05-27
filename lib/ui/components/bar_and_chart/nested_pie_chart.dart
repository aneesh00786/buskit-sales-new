import 'package:busskit_salesexecutive/ui/components/bar_and_chart/collection_dialog_table.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/pending_payment_collection.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NestedPieChartj extends StatelessWidget {
  final int completedOrdersCount;
  final int pendingAmountCount;
  final int dueAmountCount;
  final int overdueAmountCount;
  final Collection collection;

  final bool isBig;

  const NestedPieChartj({
    super.key,
    required this.completedOrdersCount,
    required this.pendingAmountCount,
    required this.dueAmountCount,
    required this.overdueAmountCount,
    required this.collection,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: isBig ? 350 : 200,
        child: SfCircularChart(
          series: <CircularSeries>[
            DoughnutSeries<ChartData2, String>(
              dataSource: [
                ChartData2(
                    'Completed', completedOrdersCount, const Color(0xFF5A7725)),
                ChartData2(
                    'Pending', pendingAmountCount, const Color(0xFFA30C13)),
              ],
              xValueMapper: (ChartData2 data, _) => data.label,
              yValueMapper: (ChartData2 data, _) => data.value,
              pointColorMapper: (ChartData2 data, _) => data.color,
              radius: '90%',
              innerRadius: '65%',
              strokeColor: white,
              strokeWidth: 2,
              onPointTap: (ChartPointDetails details) {
                if (details.pointIndex == 0) {
                  showValueCollectionDialog(
                      context, collection, 'Recieved Payment');
                } else if (details.pointIndex == 1) {
                  pendingPaymentCollectionDialog(
                      context, 'Pending Payment', collection);
                }
              },
            ),
            DoughnutSeries<ChartData2, String>(
              dataSource: [
                ChartData2('Due', dueAmountCount, const Color(0xFFFFADB5)),
                ChartData2(
                    'Overdue', overdueAmountCount, const Color(0xFFFF6584)),
              ],
              xValueMapper: (ChartData2 data, _) => data.label,
              yValueMapper: (ChartData2 data, _) => data.value,
              pointColorMapper: (ChartData2 data, _) => data.color,
              radius: '57%',
              innerRadius: '45%',
              strokeColor: white,
              strokeWidth: 0.5,
              onPointTap: (ChartPointDetails details) {
                if (details.pointIndex == 0) {
                  pendingPaymentCollectionDialog(
                      context, 'Due Payment', collection);
                } else if (details.pointIndex == 1) {
                  pendingPaymentCollectionDialog(
                      context, 'Over Due Payment', collection);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
