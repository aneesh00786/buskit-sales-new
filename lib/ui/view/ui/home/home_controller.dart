import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/icons/slide_bar_icons.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../routes/routes.dart';
import '../orders/order_screen.dart';
import 'home_ui/temp_heading_ui.dart';

class HomeController extends GetxController {
  final sidebarXController =
      SidebarXController(selectedIndex: 0, extended: true);

  RxInt selectedIndex = (-1).obs;

  LoginData? userDetails;

  static final GlobalKey<ScaffoldState> homeScaffoldKey =
      GlobalKey<ScaffoldState>();
  final ApiWorker _apiWorker = ApiWorker();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

Future<void> fetchDashboardData() async {
  try {
    await _apiWorker.dashboardData();
  } catch (e) {
    if (e.toString().contains('Session expired')) {
      await SessionHelper().clearAll();
      Get.offAllNamed(AppRoutes.login); 
      await Future.delayed(Duration(milliseconds: 500));
      _handleTokenExpiration();
    }
    log('Error fetching dashboard data: $e');
  }
}

void _handleTokenExpiration() async {
  if (!Get.isDialogOpen!) {
    await Get.dialog(
      AlertDialog(
        title: Text("Session Expired"),
        content: Text("Your session has expired. Please log in again."),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () async {
              Get.back(); 
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}


  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.dashboard &&
        sidebarXController.selectedIndex == 0) {
      return GetPageRoute(
        settings: settings,
        transition: Transition.leftToRightWithFade,
        page: () => DashBoardScreen(
          homeController: this,
        ),
      );
    } else if (settings.name == AppRoutes.customersAndOrders &&
        sidebarXController.selectedIndex == 1) {
      return GetPageRoute(
          settings: settings,
          transition: Transition.leftToRightWithFade,
          page: () => const CustomerAndOrdersScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.product &&
        sidebarXController.selectedIndex == 2) {
      return GetPageRoute(
          settings: settings,
          transition: Transition.leftToRightWithFade,
          page: () => const ProductScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.pendingPayment &&
        sidebarXController.selectedIndex == 3) {
      return GetPageRoute(
        settings: settings,
        transition: Transition.leftToRightWithFade,
        page: () => const PendingPaymentScreen(),
      );
    } else if (settings.name == AppRoutes.leads &&
        sidebarXController.selectedIndex == 4) {
      return GetPageRoute(
          settings: settings,
          transition: Transition.leftToRightWithFade,
          page: () => const LeadsScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.calender &&
        sidebarXController.selectedIndex == 5) {
      return GetPageRoute(
          transition: Transition.leftToRightWithFade,
          settings: settings,
          page: () => const CalenderScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.ordersScreen &&
        sidebarXController.selectedIndex == 6) {
      return GetPageRoute(
        transition: Transition.leftToRightWithFade,
        settings: settings,
        page: () => const OrderScreen(),
        binding: CommonBinding(),
      );
    } 
    return GetPageRoute(
      settings: settings,
      transition: Transition.leftToRightWithFade,
      page: () => TempHeadingUi(
        tabName: sidebarName[sidebarXController.selectedIndex],
      ),
    );
  }

  changePageRouting() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sidebarXController.selectedIndex == 0 && selectedIndex.value != 0) {
        Get.offAllNamed(AppRoutes.dashboard, id: 2, arguments: this);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 2 &&
          selectedIndex.value != 2) {
        Get.offNamed(AppRoutes.product, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 6 &&
          selectedIndex.value != 6) {
        Get.offNamed(AppRoutes.ordersScreen, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 1 &&
          selectedIndex.value != 1) {
        Get.offNamed(AppRoutes.customersAndOrders, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 3 &&
          selectedIndex.value != 3) {
        Get.offNamed(AppRoutes.pendingPayment, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 4 &&
          selectedIndex.value != 4) {
        Get.offNamed(AppRoutes.leads, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 5 &&
          selectedIndex.value != 5) {
        Get.offNamed(AppRoutes.calender, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      }
      if (selectedIndex.value == -2) {
        selectedIndex.value = -1;
      }
    });
  }

  RxList<String> sidebarName = [
    dashBoard,
    customersAndOrders,
    products,
    pendingPayments,
    leads,
    calendar,
    todayOrders,
    settings,
    logout
  ].obs;
  List<SidebarXItem> drawSidebarItems() {
    return [
      sideBarComponent(sidebarName[0], SIdeBarIcon.ic_dashboard),
      sideBarComponent(sidebarName[1], SIdeBarIcon.ic_customer_and_orders),
      sideBarComponent(sidebarName[2], SIdeBarIcon.ic_products),
      sideBarComponent(sidebarName[3], SIdeBarIcon.ic_pending_payment),
      sideBarComponent(sidebarName[4], SIdeBarIcon.ic_leads),
      sideBarComponent(sidebarName[5], SIdeBarIcon.ic_calender),
      sideBarComponent(sidebarName[6], SIdeBarIcon.ic_today_order),
      sideBarComponent(sidebarName[7], SIdeBarIcon.ic_setting),
      sideBarComponent(sidebarName[8], SIdeBarIcon.ic_log_out),
    ];
  }

  SidebarXItem sideBarComponent(String barTitle, IconData iconData) {
    return SidebarXItem(
      icon: iconData,
      label: barTitle,
      onTap: () {
        homeScaffoldKey.currentState?.closeDrawer();
        //changePageRouting();
      },
    );
  }

  Widget upperSideBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: InkResponse(
            onTap: () => {
                  homeScaffoldKey.currentState?.openDrawer(),
                },
            child: const Icon(
              Icons.menu_outlined,
              size: 30,
            )),
      ),
    );
  }
}
