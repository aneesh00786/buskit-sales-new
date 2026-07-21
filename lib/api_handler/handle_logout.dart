// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/services/checkin_service.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleLogout(BuildContext context) async {
  try {
    CheckInService().stopTracking();
    ConnectivityService().reset();
  } catch (e) {
    debugPrint("Error stopping tracking or resetting connectivity in handleLogout: $e");
  }

  showCustomToastDisplay(
      context, "Clearing Cache", primaryColor, Icons.clear_all);
final prefs = await SharedPreferences.getInstance();
String? savedLanguage = prefs.getString('selected_language');
Map<String, String> savedTranslations = {};
  for (String key in prefs.getKeys()) {
    if (key.startsWith('lang_')) {
      savedTranslations[key] = prefs.getString(key)!;
    }
  }

  await SessionManager.clearData();
  await SessionHelper().clearSettingsData();
  if (savedLanguage != null) {
    await prefs.setString('selected_language', savedLanguage);
  }
  for (var entry in savedTranslations.entries) {
    await prefs.setString(entry.key, entry.value);
  }
  Provider.of<DashboardProvider>(context, listen: false).resetProvider();

  // Clear subscription cache
  try {
    final subscriptionController = Get.find<SubscriptionController>();
    // subscriptionController.clearSubscriptionCache();
  } catch (e) {}

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

  if (Hive.isBoxOpen('scidProductGroups')) {
    await Hive.box<ScidProductGroup>('scidProductGroups').close();
  }
  await Hive.deleteBoxFromDisk('scidProductGroups');

  final untypedBoxNames = [
    'adminBox',
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
    'fetchOnlyCustomerDataInWholeBox',
  ];

  for (final boxName in untypedBoxNames) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else {
        final box = await Hive.openBox(boxName);
        await box.clear();
      }
    } catch (e) {}
  }

  
}

// Future<void> handleLogout(BuildContext context) async {
//   showCustomToastDisplay(
//       context, "Clearing Cache", primaryColor, Icons.clear_all);
//   await SessionManager.clearData();
//   await SessionHelper().clearSettingsData();
//   Provider.of<DashboardProvider>(context, listen: false).resetProvider();
//   Provider.of<CustomersProvider>(context, listen: false).resetProvider();

//   CalenderMapController calenderController = Get.put(CalenderMapController());
//   calenderController.eventControllerv1
//       .removeAll(calenderController.eventControllerv1.events);

//   if (Hive.isBoxOpen('discounts')) {
//     await Hive.box<CustomerDiscountModel>('discounts').clear();
//   }

//   if (Hive.isBoxOpen('cartBox')) {
//     await Hive.box<CartItem>('cartBox').clear();
//   }

//   if (Hive.isBoxOpen('cartPreorderBox')) {
//     await Hive.box<CartItem>('cartPreorderBox').clear();
//   }

//   if (Hive.isBoxOpen('draftBox')) {
//     await Hive.box<CartItem>('draftBox').clear();
//   }

//   if (Hive.isBoxOpen('products')) {
//     await Hive.box<ProductModel>('products').close();
//   }
//   await Hive.deleteBoxFromDisk('products');

//   if (Hive.isBoxOpen('scidProductGroups')) {
//     await Hive.box<ScidProductGroup>('scidProductGroups').close();
//   }
//   await Hive.deleteBoxFromDisk('scidProductGroups');

//   final untypedBoxNames = [
//     'dashboardBox',
//     'customerdashboardBox',
//     'customerRevenueBox',
//     'customerTotalSaleBox',
//     'weeklyTypeBox',
//     'customerBox',
//     'chatBox',
//     'pendingPaymentBox',
//     'performanceBox',
//     'leadsCountBox',
//     'leadsBox',
//     'leadsRejectBox',
//     'ordersBox',
//     'fetchAllOrdersBox',
//     'settingsBox',
//     'calendarEventsBox',
//     'salesmanTargetBox',
//     'salesmanValueTargetBox',
//     'subscribtionBox',
//     'subscribtionPlanDetailsBox',
//     'fetchOnlyCustomerDataInWholeBox',
//     'topBarDataBox',
//     'timesheetBox',
//     'scheduleBox',
//     'draftAndCartIdsBox',
//     'draftItemsBox',
//     'offlineOrders',
//     'offlineDrafts',
//     'offlineRequests',
//   ];

//   for (final boxName in untypedBoxNames) {
//     try {
//       if (Hive.isBoxOpen(boxName)) {
//         await Hive.box(boxName).clear();
//       } else {
//         final box = await Hive.openBox(boxName);
//         await box.clear();
//       }
//     } catch (e) {
//       //
//     }
//   }
// }
