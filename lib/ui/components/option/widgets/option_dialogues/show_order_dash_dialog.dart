import 'package:busskit_salesexecutive/ui/components/option/widgets/option_dialogues/orders_dialogue.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';

void showOrderStatusDialog(BuildContext context, DashboardProvider provider,
    OrderStatus selectedOrderStatus) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: FutureBuilder<OrderResponse>(
                    future: provider.orderResponse,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        final orders = snapshot.data?.data ?? [];
                        final filteredOrders = orders.toList();
                        return buildOrdersDialogueMainDash(
                          context: context,
                          filteredOrders: filteredOrders,
                          isCustomer: true,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
