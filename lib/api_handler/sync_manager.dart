import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SyncManager extends StatefulWidget {
  final Widget child;
  const SyncManager({required this.child, super.key});

  @override
  State<SyncManager> createState() => _SyncManagerState();
}

class _SyncManagerState extends State<SyncManager> {
  final connectivityService = ConnectivityService();
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  void _startSync() {
    connectivityService.startListening((connectivityResult) async {
      if (connectivityResult != ConnectivityResult.none && !isSyncing) {
        isSyncing = true;
        try {
          final orderController = Get.find<OrderController>();
          final customersAndOrdersController = Get.find<CustomerAndOrderController>();

          await connectivityService.syncOfflineOrders(
            onOrderSynced: orderController.loadOfflineOrders,
          );

          await connectivityService.syncOfflineDrafts(onDraftsSynced: () async {
            final cusProvider = Provider.of<CustomersProvider>(context, listen: false);
            final dashProvider = Provider.of<DashboardProvider>(context, listen: false);

            await dashProvider.fetchData();
            await dashProvider.fetchOrdersData(OrderStatus.draft);
            await CartDatabaseManager().getDraftItems();
            await cusProvider.fetchCustomerDashboardCountData(
                customersAndOrdersController.customerId.value);
            await cusProvider.fetchOrdersForCustomDash(
              OrderStatus.draft,
              customersAndOrdersController.customerId.value,
            );
          });

          await connectivityService.retryOfflineRequests();
        } catch (e) {
          log('Error during sync: $e');
        } finally {
          isSyncing = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
