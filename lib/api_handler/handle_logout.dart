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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

Future<void> handleLogout(BuildContext context) async {
  showCustomToastDisplay(
      context, "Clearing Cache", primaryColor, Icons.clear_all);
  await SessionManager.clearData();
  await SessionHelper().clearSettingsData();
  Provider.of<DashboardProvider>(context, listen: false).resetProvider();
  Provider.of<CustomersProvider>(context, listen: false).resetProvider();

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
    'dashboardBox',
    'customerdashboardBox',
    'customerRevenueBox',
    'customerTotalSaleBox',
    'weeklyTypeBox',
    'customerBox',
    'chatBox',
    'pendingPaymentBox',
    'performanceBox',
    'leadsCountBox',
    'leadsBox',
    'leadsRejectBox',
    'ordersBox',
    'fetchAllOrdersBox',
    'settingsBox',
    'calendarEventsBox',
    'salesmanTargetBox',
    'salesmanValueTargetBox',
    'subscribtionBox',
    'subscribtionPlanDetailsBox',
    'fetchOnlyCustomerDataInWholeBox',
    'topBarDataBox',
    'timesheetBox',
    'scheduleBox',
    'draftAndCartIdsBox',
    'draftItemsBox',
    'offlineOrders',
    'offlineDrafts',
    'offlineRequests',
  ];

  for (final boxName in untypedBoxNames) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else {
        final box = await Hive.openBox(boxName);
        await box.clear();
      }
    } catch (e) {
      //
    }
  }
}
