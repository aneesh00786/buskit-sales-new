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
  required String headers1,
  required String headers2,
  required String headers3,
  required String headers4,
  required String headers5,
  required String headers6,
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
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FutureBuilder<OrderResponse>(
                    future: provider.orderResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                            height: 300,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ));
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return nodataDialogueTable(
                          head_1: headers1,
                          head_2: headers2,
                          head_3: headers3,
                          head_4: headers4,
                          head_5: headers5,
                          head_6: headers6,
                        );
                      } else {
                        final orders = snapshot.data?.data ?? [];
                        final filteredOrders = orders.where((order) {
                          return order.orderStatus == selectedOrderStatus.type;
                        }).toList();

                        if (filteredOrders.isEmpty) {
                          return nodataDialogueTable(
                            head_1: headers1,
                            head_2: headers2,
                            head_3: headers3,
                            head_4: headers4,
                            head_5: headers5,
                            head_6: headers6,
                          );
                        } else {
                          return buildDialogueMainDash(
                            context: context,
                            filteredOrders: filteredOrders,
                            headers1: headers1,
                            headers2: headers2,
                            headers3: headers3,
                            headers4: headers4,
                            headers5: headers5,
                            headers6: headers6,
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
