import 'dart:developer';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

Future<void> handleLogout(BuildContext context) async {
  showCustomToastDisplay(
      context, "Clearing Cache", primaryColor, Icons.clear_all);
  log("Clearing Cache");
  await SessionManager.clearData();
  await SessionHelper().clearSettingsData();
  Provider.of<DashboardProvider>(context, listen: false).resetProvider();

  // Clear subscription cache
  try {
    // final subscriptionController = Get.find<SubscriptionController>();
    // subscriptionController.clearSubscriptionCache();
  } catch (e) {
    log("Error clearing subscription cache: $e");
  }

  CalenderMapController calenderController = Get.put(CalenderMapController());
  calenderController.eventControllerv1
      .removeAll(calenderController.eventControllerv1.events);

  if (Hive.isBoxOpen('discounts')) {
    await Hive.box<CustomerDiscountModel>('discounts').clear();
  }

  if (Hive.isBoxOpen('cartBox')) {
    await Hive.box<CartItem>('cartBox').clear();
  }

  if (Hive.isBoxOpen('cartPreorderBox')) {
    await Hive.box<CartItem>('cartPreorderBox').clear();
  }

  if (Hive.isBoxOpen('draftBox')) {
    await Hive.box<CartItem>('draftBox').clear();
  }

  if (Hive.isBoxOpen('products')) {
    await Hive.box<ProductModel>('products').close();
  }
  await Hive.deleteBoxFromDisk('products');

  final untypedBoxNames = [
    'dashboardBox',
    'customerBox',
    'categoriesBox',
    'chatBox',
    'pendingPaymentBox',
    'staffBox',
    'leadsBox',
    'leadsCustomerBox',
    'leadsRejectBox',
    'ordersBox',
    'fetchAllOrdersBox',
    'orderCountBox',
    'calendarEventsBox',
    'settingsBox',
    'subscribtionBox',
    'subscribtionPlanDetailsBox',
    'offlineDrafts',
    'offlineRequests',
    'offlineOrders',
    'customerdashboardBox',
    'customerRevenueBox',
    'customerTotalSaleBox',
  ];

  for (final boxName in untypedBoxNames) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
        log("$boxName clearing box 1");
      } else {
        final box = await Hive.openBox(boxName);
        await box.clear();
        log("$boxName clearing box 2");
      }
    } catch (e) {
      log("Error clearing box $boxName: $e");
    }
  }

  // Clean up all user/session-specific GetX controllers to prevent async UI updates after logout
  // Get.find<CalenderMapController>().clear();
  // Get.find<ProductsController>().clear();
  // Get.find<PendingPaymentController>().clear();
  // Get.find<LeadsController>().clear();
  // Get.find<LeadsCustomerController>().clear();
  // Get.find<RejectedLeadsController>().clear();
  // Get.find<CustomerAndOrderController>().clear();
  // Get.find<StaffController>().clear();
  // Get.find<SettingsController>().clear();
  // Get.find<DashBoardController>().clear();
  // Get.find<NotificationController>().clear();
  // Get.find<LoginController>().clear();
  // Get.find<SubscriptionController>().clear();
  // Get.find<OrderController>().clear();

  // Get.offAllNamed(AppRoutes.login);
}
