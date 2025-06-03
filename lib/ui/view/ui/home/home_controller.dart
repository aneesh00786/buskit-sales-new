// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/icons/slide_bar_icons.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/performance.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/products_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/settings/settings.dart';
import 'package:dio/dio.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final ApiService _apiService = ApiService();
  bool _isDisposed = false;
  final Dio dio = Dio();
  @override
  void onInit() {
    super.onInit();
    ApiWorker()
        .fetchSubscribtionPlan(SessionHelper.loginSavedData?.company_id ?? 0);
    SessionHelper().getLoginData().then((value) {
      userDetails = value;
      log('User details assigned in onInit: $value');
    }).catchError((error) {
      log('Error fetching user details in onInit: $error');
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }

  Future<void> fetchDashboardData() async {
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    try {
      await _apiService.fetchDashboardData();
      await _apiService.fetchIndividualChatApi(salesmanId, 1);
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        await SessionHelper().clearAll();
        if (!_isDisposed) {
          Get.offAllNamed(AppRoutes.login);
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _handleTokenExpiration();
      }
      log('Error fetching dashboard data: $e');
    }
  }

  void _handleTokenExpiration() async {
    if (!_isDisposed && !Get.isDialogOpen!) {
      await Get.dialog(
        AlertDialog(
          title: const Text("Session Expired"),
          content: const Text("Your session has expired. Please log in again."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Get.back(),
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
          page: () => const Tableee(),
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
        page: () => const SettingsScreen(),
        binding: CommonBinding(),
      );
    }
    return null;
  }

  changePageRouting() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;

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
      sideBarComponent(sidebarName[0], Icons.dashboard),
      sideBarComponent(sidebarName[1], EneftyIcons.profile_2user_bold),
      sideBarComponent(sidebarName[2], EneftyIcons.a_3d_cube_bold),
      sideBarComponent(sidebarName[3], EneftyIcons.moneys_bold),
      sideBarComponent(sidebarName[4], SIdeBarIcon.ic_leads),
      sideBarComponent(sidebarName[5], EneftyIcons.chart_square_bold),
      sideBarComponent(sidebarName[6], EneftyIcons.calendar_bold),
      sideBarComponent(sidebarName[7], EneftyIcons.shopping_cart_bold),
      sideBarComponent(sidebarName[8], EneftyIcons.setting_2_bold),
      sideBarComponent(sidebarName[9], SIdeBarIcon.ic_log_out,
          context: context),
    ];
  }

  SidebarXItem sideBarComponent(
    String barTitle,
    IconData iconData, {
    BuildContext? context,
  }) {
    final NotificationController notificationController =
        Get.put(NotificationController());

    bool isLogout = (barTitle == logOut);
    bool isRecentOrders = (barTitle == todayOrders);
    bool isLeads = (barTitle == leads);

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
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: CustomText(content: 'Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_isDisposed) {
                        Navigator.pop(context);
                        await handleLogout(context);
                        dio.interceptors.clear();
                        if (!_isDisposed) {
                          Get.offAllNamed(AppRoutes.login);
                        }
                        if (!_isDisposed) {
                          Provider.of<DashboardProvider>(context, listen: false)
                              .resetProvider();
                          Provider.of<DashboardProvider>(context, listen: false)
                              .resetFilter();
                        }
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
                  ),
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
          padding: const EdgeInsets.symmetric(
            vertical: 3.0,
          ),
          child: Row(
            children: [
              Icon(
                iconData,
                size: 20,
                color: Colors.black.withOpacity(0.7),
                weight: 700,
              ),
              const SizedBox(width: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CustomText(
                      content: barTitle,
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isRecentOrders)
                    Positioned(
                      top: -15,
                      left: 200,
                      child: notificationController.isNotificationLoading.value
                          ? const SizedBox.shrink()
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
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  if (isLeads)
                    Positioned(
                        top: 0,
                        left: 200,
                        child: notificationController.isLeadsCountLoading.value
                            ? const SizedBox.shrink()
                            : CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  notificationController.leadsCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              )),
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
          EneftyIcons.menu_outline,
          size: 30,
        ),
      )),
    );
  }
}

Future<void> handleLogout(BuildContext context) async {
  showCustomToastDisplay(context, "LOGGING OUT", red, Icons.close,
        duration: 5);
  await SessionManager.clearData();
  await SessionHelper().clearSettingsData();
  await SessionHelper().clearAll();
  await CartDatabaseManager().clearCompleteCart();
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
    'customerdashboardBox',
    'customerRevenueBox',
    'customerTotalSaleBox',
    'weeklyTypeBox',
    'customerBox',
    'productBox',
    'chatBox',
    'pendingPaymentBox',
    'performanceBox',
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
      log("Error clearing box $boxName: $e");
    }
  }

  Get.offAllNamed(AppRoutes.login);
}
