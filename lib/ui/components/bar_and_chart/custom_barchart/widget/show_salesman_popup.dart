// ignore_for_file: use_build_context_synchronously

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/barchart_table_dialog/bar_chart_table_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import '../../../../view/ui/dashboard1/provider/dash_models.dart';
import '../../../../view/ui/dashboard1/provider/dash_provider.dart';
import '../../../category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';

void showSalesmanPopup({
  required int cid,
  required String category,
  required BuildContext context,
  required String staffProjection,
  required String targetType,
  required bool isDayOrRange,
}) async {
  bool isConnected = await ConnectivityService().isOnline();
  isConnected
      ? showDialog(
          context: context,
          builder: (context) {
            return Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                provider.fetchchartCategoryPerformmenc(cid);
                dev.log('CID :$cid');
                return FutureBuilder<ResponseModelCp>(
                  future: provider.responseModelCp,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        content: Center(
                          child: NodataWidget(),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final categories = snapshot.data?.data;
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showBarchartDialog(
                            context,
                            category,
                            categories ?? [],
                            targetType,
                            staffProjection,
                            provider,
                            cid,
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
        )
      : null;
}
