import 'package:busskit_salesexecutive/ui/components/option/widgets/nodata_table_widget.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/option_dialogues/other_main_dialogue.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';

void showMainDashDialog({
  required BuildContext context,
  required DashboardProvider provider,
  required OrderStatus selectedOrderStatus,
  required String option,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FutureBuilder<OrderResponse>(
                    future: provider.orderResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ));
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return nodataDialogueTable(
                          option: option
                        );
                      } else {
                        final orders = snapshot.data?.data ?? [];
                        final filteredOrders = orders.where((order) {
                          return order.orderStatus == selectedOrderStatus.type;
                        }).toList();

                        if (filteredOrders.isEmpty) {
                          return nodataDialogueTable(
                            option: option
                          );
                        } else {
                          return Material(
                            child: buildDialogueMainDash(
                              context: context,
                              filteredOrders: filteredOrders,
                              option: option

                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      });
    },
  );
}
