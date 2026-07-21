import 'dart:async';

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
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
  StreamSubscription<bool>? _subscription;
  bool _isFirstCheck = true;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startSync() {
    _subscription = connectivityService.onOnlineStatusChanged.listen((isOnline) async {
      if (isOnline) {
        if (!_isFirstCheck) {
          Get.closeAllSnackbars();
          Get.snackbar(
            "Online".tr,
            "You are back online. Synchronizing data...".tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
        _isFirstCheck = false;

        if (!isSyncing) {
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
            //
          } finally {
            isSyncing = false;
          }
        }
      } else {
        _isFirstCheck = false;
        Get.closeAllSnackbars();
        Get.snackbar(
          "Offline".tr,
          "Connection lost. App is now in offline mode.".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
