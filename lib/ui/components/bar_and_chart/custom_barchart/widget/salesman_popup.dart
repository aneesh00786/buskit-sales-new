import 'package:busskit_salesexecutive/ui/components/bar_and_chart/bar_chart_table_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/custom_barchart/widget/nodata_table.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../view/ui/dashboard1/provider/dash_provider.dart';

void showSalesmanPopupMonthly({
  required String cid,
  required String month,
  required BuildContext context,
  required String staffProjection,
  required String targetType,
  required bool isDayOrRange,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          provider.fetchchartValuePerformance(cid, "Month");
          return FutureBuilder<ResponseModelCp>(
            future: provider.responseModelNewCp,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: noDataTable(staffProjection));
              } else if (snapshot.hasData) {
                final categories = snapshot.data!.data;
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showBarchartDialog(context, cid, categories ?? [],
                      targetType, staffProjection, provider, 0,
                      isDayOrRange: isDayOrRange);
                });
                return const SizedBox.shrink();
              } else {
                return const AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  content: Center(
                    child: Text('No data available'),
                  ),
                );
              }
            },
          );
        },
      );
    },
  );
}
