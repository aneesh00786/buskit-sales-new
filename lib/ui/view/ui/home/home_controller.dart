import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/icons/slide_bar_icons.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/performance.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/products_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/settings/settings.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../routes/routes.dart';
import '../orders/order_screen.dart';

class HomeController extends GetxController {
  final sidebarXController =
      SidebarXController(selectedIndex: 0, extended: true);

  RxInt selectedIndex = (-1).obs;

  LoginData? userDetails;

  static final GlobalKey<ScaffoldState> homeScaffoldKey =
      GlobalKey<ScaffoldState>();
  final ApiWorker _apiWorker = ApiWorker();
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      await _apiService.fetchDashboardData();
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
          page: () => tableee(),
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
    } else if (settings.name == AppRoutes.performance &&
        sidebarXController.selectedIndex == 5) {
      return GetPageRoute(
          settings: settings,
          transition: Transition.leftToRightWithFade,
          page: () => const PerformanceScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.calender &&
        sidebarXController.selectedIndex == 6) {
      return GetPageRoute(
          transition: Transition.leftToRightWithFade,
          settings: settings,
          page: () => const CalenderScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.ordersScreen &&
        sidebarXController.selectedIndex == 7) {
      return GetPageRoute(
        transition: Transition.leftToRightWithFade,
        settings: settings,
        page: () => const OrderScreen(),
        binding: CommonBinding(),
      );
    } else if (settings.name == AppRoutes.settings &&
        sidebarXController.selectedIndex == 8) {
      return GetPageRoute(
        transition: Transition.leftToRightWithFade,
        settings: settings,
        page: () => SettingsScreen(),
        binding: CommonBinding(),
      );
    }
  }

  changePageRouting() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sidebarXController.selectedIndex == 0 && selectedIndex.value != 0) {
        Get.offAllNamed(AppRoutes.dashboard, id: 2, arguments: this);
      } else if (sidebarXController.selectedIndex == 1 &&
          selectedIndex.value != 1) {
        Get.offNamed(AppRoutes.customersAndOrders, id: 2);
      } else if (sidebarXController.selectedIndex == 2 &&
          selectedIndex.value != 2) {
        Get.offNamed(AppRoutes.product, id: 2);
      } else if (sidebarXController.selectedIndex == 3 &&
          selectedIndex.value != 3) {
        Get.offNamed(AppRoutes.pendingPayment, id: 2);
      } else if (sidebarXController.selectedIndex == 4 &&
          selectedIndex.value != 4) {
        Get.offNamed(AppRoutes.leads, id: 2);
      } else if (sidebarXController.selectedIndex == 5 &&
          selectedIndex.value != 5) {
        Get.offNamed(AppRoutes.performance, id: 2);
      } else if (sidebarXController.selectedIndex == 6 &&
          selectedIndex.value != 6) {
        Get.offNamed(AppRoutes.calender, id: 2);
      } else if (sidebarXController.selectedIndex == 7 &&
          selectedIndex.value != 7) {
        Get.offNamed(AppRoutes.ordersScreen, id: 2);
      } else if (sidebarXController.selectedIndex == 8 &&
          selectedIndex.value != 8) {
        Get.offNamed(AppRoutes.settings, id: 2);
      }
      selectedIndex.value = sidebarXController.selectedIndex;
    });
  }

  RxList<String> sidebarName = [
    dashBoard,
    customersAndOrders,
    products,
    pendingPayments,
    leads,
    performance,
    calendar,
    todayOrders,
    settings,
    logOut
  ].obs;

  List<SidebarXItem> drawSidebarItems(BuildContext context) {
    return [
      sideBarComponent(sidebarName[0], Icons.dashboard_outlined),
      sideBarComponent(sidebarName[1], EneftyIcons.profile_2user_outline),
      sideBarComponent(sidebarName[2], EneftyIcons.a_3d_cube_outline),
      sideBarComponent(sidebarName[3], EneftyIcons.moneys_outline),
      sideBarComponent(sidebarName[4], EneftyIcons.arrow_circle_up_outline),
      sideBarComponent(sidebarName[5], EneftyIcons.chart_square_outline),
      sideBarComponent(sidebarName[6], EneftyIcons.calendar_outline),
      sideBarComponent(sidebarName[7], EneftyIcons.shopping_cart_outline),
      sideBarComponent(sidebarName[8], EneftyIcons.setting_2_outline),
      sideBarComponent(sidebarName[9], SIdeBarIcon.ic_log_out,
          context: context),
    ];
  }
  // List<SidebarXItem> drawSidebarItems(BuildContext context) {
  //   return [
  //     sideBarComponent(sidebarName[0], Icons.dashboard),
  //     sideBarComponent(sidebarName[1], SIdeBarIcon.ic_customer_and_orders),
  //     sideBarComponent(sidebarName[2], SIdeBarIcon.ic_products),
  //     sideBarComponent(sidebarName[3], SIdeBarIcon.ic_pending_payment),
  //     sideBarComponent(sidebarName[4], SIdeBarIcon.ic_leads),
  //     sideBarComponent(sidebarName[5], Icons.bar_chart),
  //     sideBarComponent(sidebarName[6], SIdeBarIcon.ic_calender),
  //     sideBarComponent(sidebarName[7], SIdeBarIcon.ic_today_order),
  //     sideBarComponent(sidebarName[8], SIdeBarIcon.ic_setting),
  //     sideBarComponent(sidebarName[9], SIdeBarIcon.ic_log_out,
  //         context: context),
  //   ];
  // }

  SidebarXItem sideBarComponent(
    String barTitle,
    IconData iconData, {
    BuildContext? context,
  }) {
    final NotificationController notificationController =
        Get.put(NotificationController());

    bool isLogout = (barTitle == logOut);
    bool isSettings = (barTitle == setting);
    bool isRecentOrders = (barTitle == orders);

    return SidebarXItem(
      icon: iconData,
      onTap: () async {
        homeScaffoldKey.currentState?.closeDrawer();
        if (isLogout) {
          showDialog(
            context: context!,
            builder: (context) {
              return AlertDialog(
                title: CustomText(content: 'Log out ?'),
                content:
                    CustomText(content: 'Are you sure you want to log out ?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: CustomText(content: 'cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await SessionManager.clearData();
                      Get.offAllNamed(AppRoutes.login);
                      if (context != null) {
                        Provider.of<DashboardProvider>(context, listen: false)
                            .resetProvider();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: CustomText(
                      content: 'Confirm',
                      color: white,
                    ),
                  )
                ],
              );
            },
          );
        } else {
          changePageRouting();
        }
      },
      iconBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
          child: Row(
            children: [
              Icon(
                iconData,
                size: 20,
                color: Colors.black.withOpacity(0.4),
              ),
              const SizedBox(width: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      barTitle,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isRecentOrders)
                    Positioned(
                      top: -15,
                      left: 200,
                      child: notificationController.isNotificationLoading.value
                          ? SizedBox.shrink() // Show nothing when loading
                          : notificationController
                                      .recentOrderCountData.mainNotification !=
                                  null
                              ? CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    notificationController.recentOrderCountData
                                            .mainNotification!.recentOrders
                                            ?.toString() ??
                                        '0',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                )
                              : SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget upperSideBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: InkResponse(
            onTap: () => {
                  homeScaffoldKey.currentState?.openDrawer(),
                },
            child: const Icon(
              EneftyIcons.menu_outline,size: 30,),
              
            )),
      );
    
  }
}
