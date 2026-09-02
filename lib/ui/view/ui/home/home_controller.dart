// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/app_update_service.dart';
import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/icons/slide_bar_icons.dart';
import 'package:busskit_salesexecutive/ui/services/checkin_service.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart'
    hide SalesReturn;
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/performance.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/products_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/sales_return.dart';
import 'package:busskit_salesexecutive/ui/view/ui/settings/settings.dart';
import 'package:dio/dio.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    }).catchError((error) {});
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
    }
  }

  // Shared check-in function that can be called from anywhere
  Future<void> performCheckIn(BuildContext context) async {
    // This will be implemented to call the same logic as the sidebar
    // For now, we'll trigger the sidebar's check-in logic
    // The actual implementation will be in the sidebar component
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
    } else if (settings.name == AppRoutes.ordersScreen &&
        sidebarXController.selectedIndex == 3) {
      return GetPageRoute(
        transition: Transition.leftToRightWithFade,
        settings: settings,
        page: () => const OrderScreen(),
        binding: CommonBinding(),
      );
    } else if (settings.name == AppRoutes.salesReturn &&
        sidebarXController.selectedIndex == 4) {
      return GetPageRoute(
        transition: Transition.leftToRightWithFade,
        settings: settings,
        page: () => const SalesReturn(),
        binding: CommonBinding(),
      );
    } else if (settings.name == AppRoutes.pendingPayment &&
        sidebarXController.selectedIndex == 5) {
      return GetPageRoute(
        settings: settings,
        transition: Transition.leftToRightWithFade,
        page: () => const PendingPaymentScreen(),
      );
    } else if (settings.name == AppRoutes.leads &&
        sidebarXController.selectedIndex == 6) {
      return GetPageRoute(
          settings: settings,
          transition: Transition.leftToRightWithFade,
          page: () => const LeadsScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.calender &&
        sidebarXController.selectedIndex == 7) {
      return GetPageRoute(
          transition: Transition.leftToRightWithFade,
          settings: settings,
          page: () => const CalenderScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.performance &&
        sidebarXController.selectedIndex == 8) {
      return GetPageRoute(
          settings: settings,
          transition: Transition.leftToRightWithFade,
          page: () => const PerformanceScreen(),
          binding: CommonBinding());
    } else if (settings.name == AppRoutes.settings &&
        sidebarXController.selectedIndex == 9) {
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
      // if (_isDisposed) return;

      if (sidebarXController.selectedIndex == 0 &&
          selectedIndex.value != 0 &&
          selectedIndex.value != -2) {
        Get.offAllNamed(AppRoutes.dashboard, id: 2, arguments: this);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 1 &&
          selectedIndex.value != 1) {
        Get.offNamed(AppRoutes.customersAndOrders, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 2 &&
          selectedIndex.value != 2) {
        Get.offNamed(AppRoutes.product, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 3 &&
          selectedIndex.value != 3) {
        Get.offNamed(AppRoutes.ordersScreen, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 4 &&
          selectedIndex.value != 4) {
        Get.offNamed(AppRoutes.salesReturn, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 5 &&
          selectedIndex.value != 5) {
        Get.offNamed(AppRoutes.pendingPayment, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 6 &&
          selectedIndex.value != 6) {
        Get.offNamed(AppRoutes.leads, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 7 &&
          selectedIndex.value != 7) {
        Get.offNamed(AppRoutes.calender, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 8 &&
          selectedIndex.value != 8) {
        Get.offNamed(AppRoutes.performance, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      } else if (sidebarXController.selectedIndex == 9 &&
          selectedIndex.value != 9) {
        Get.offNamed(AppRoutes.settings, id: 2);
        selectedIndex.value = sidebarXController.selectedIndex;
      }
      if (selectedIndex.value == -2) {
        selectedIndex.value = -1;
      }
      selectedIndex.value = sidebarXController.selectedIndex;
    });
  }

  // Order matches the "Sales" / "Growth" grouped nav design: Dashboard, then
  // the Sales group (Customers & Orders, Products, Recent Orders, Sales
  // Return, Pending Payments), then the Growth group (Leads, Calendar,
  // Performance), then Settings/Logout. Every index-keyed switch in this
  // file (onGenerateRoute, changePageRouting, getSidebarIconData) and in
  // nk_sidebar_only_icon.dart's isRecentOrders/isLeads booleans was updated
  // to match this same order — keep them all in sync if this list changes.
  RxList<String> sidebarName = [
    dashBoard,
    customersAndOrders,
    products,
    todayOrders,
    salesReturn,
    pendingPayments,
    leads,
    calendar,
    performance,
    settings,
    logOut,
  ].obs;

  List<SidebarXItem> drawSidebarItems(BuildContext context) {
    return [
      sideBarComponent(sidebarName[0], index: 0, Icons.dashboard),
      sideBarComponent(
          sidebarName[1], index: 1, EneftyIcons.profile_2user_bold,
          sectionLabel: 'Sales'),
      sideBarComponent(sidebarName[2], index: 2, EneftyIcons.a_3d_cube_bold),
      sideBarComponent(sidebarName[3], index: 3, EneftyIcons.receipt_bold),
      sideBarComponent(
          sidebarName[4], index: 4, EneftyIcons.arrow_swap_horizontal_bold),
      sideBarComponent(sidebarName[5], index: 5, Icons.payments_outlined),
      sideBarComponent(sidebarName[6], index: 6, SIdeBarIcon.ic_leads,
          sectionLabel: 'Growth'),
      sideBarComponent(sidebarName[7], index: 7, EneftyIcons.calendar_bold),
      sideBarComponent(
          sidebarName[8], index: 8, EneftyIcons.chart_square_bold),
      sideBarComponent(sidebarName[9], index: 9, EneftyIcons.setting_2_bold,
          showDividerAbove: true),
      sideBarComponent(
          sidebarName[10], index: 10, SIdeBarIcon.ic_log_out, context: context),
    ];
  }

  SidebarXItem sideBarComponent(
    String barTitle,
    IconData iconData, {
    BuildContext? context,
    int? index,
    String? sectionLabel,
    bool showDividerAbove = false,
  }) {
    final NotificationController notificationController =
        Get.put(NotificationController());

    int previousIndex = 0;

    bool isLogout = (barTitle == logOut);
    bool isRecentOrders = (barTitle == todayOrders);
    bool isLeads = (barTitle == leads);

    if (!isLogout) {
      previousIndex = sidebarXController.selectedIndex;
    }

    return SidebarXItem(
      label: barTitle,
      icon: iconData,
      onTap: () async {
        print("====== SIDEBAR TAPPED! Index: $index | Title: $barTitle ======");
        homeScaffoldKey.currentState?.closeDrawer();
        if (isLogout) {
          showDialog(
            context: context!,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.logout, size: 25.0, color: primaryColor),
                    const SizedBox(width: 8.0),
                    Text(
                      "Logout ?".tr,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Are you sure you want to log out ?.".tr,
                    style: TextStyle(
                      fontSize: 19.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                actions: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      side: BorderSide(color: primaryColor, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 3,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      sidebarXController.selectIndex(previousIndex);
                    },
                    child: Text(
                      "Cancel".tr,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await handleLogoutOnConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                    ),
                    child: CustomText(
                        content: 'Confirm'.tr,
                        color: white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
          );
        } else {
//          // --- OUR PREVIOUS CLEARING LOGIC ---
//          if (index == 2) {
//   try {
//     final productsController = Get.find<ProductsController>();
//     productsController.selectedCustomerId.value = '';
//     productsController.selectedCustomerName.value = '';
//     productsController.customerAndOrderData.update((val) {
//       if (val != null) val.customerId = '';
//     });

//     final customerOrderController = Get.find<CustomerAndOrderController>();
//     customerOrderController.setCustomerId('');
//     customerOrderController.isActive.value = false;
//   } catch (e) {
//     print("-> Error clearing controllers: $e");
//   }
// }

// // ✅ Add a frame delay so Obx sees the cleared value BEFORE ProductScreen rebuilds
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   changePageRouting();
// });
//           // -----------------------------------
          changePageRouting();
        }
      },
      iconBuilder: (context, extended) {
        final bool isSelected = sidebarXController.selectedIndex == index;
        final bool isLogout = index == 10;
        
        final Widget row = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            children: [
              // Left selection indicator bar
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      if (index == 9)
                        Obx(() {
                          final hasUpdate =
                              Get.find<AppUpdateService>().isUpdateAvailable.value;
                          Widget icon = Icon(
                            getSidebarIconData(index ?? 0, selected: isSelected),
                            size: 25,
                            color: isSelected
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF64748B),
                          );
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              icon,
                              if (hasUpdate)
                                Positioned(
                                  top: -4,
                                  left: -4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: white, width: 2),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        '1',
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        })
                      else
                        Icon(
                          getSidebarIconData(index ?? 0, selected: isSelected),
                          size: 25,
                          color: isLogout
                              ? const Color(0xFFE15241)
                              : isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF64748B),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          barTitle.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isLogout
                                ? const Color(0xFFE15241)
                                : isSelected
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (isRecentOrders)
                        Obx(() {
                          if (notificationController.isNotificationLoading.value) {
                            return const SizedBox.shrink();
                          }
                          final recentOrders = notificationController
                              .recentOrderCountData.mainNotification?.recentOrders;
                          if (recentOrders == null || recentOrders == 0) {
                            return const SizedBox.shrink();
                          }
                          return _sidebarCountPill(
                            recentOrders.toString(),
                            isOrange: true,
                          );
                        }),
                      if (isLeads)
                        Obx(() {
                          if (notificationController.isLeadsCountLoading.value) {
                            return const SizedBox.shrink();
                          }
                          final count = notificationController.leadsCount.value;
                          if (count == 0) return const SizedBox.shrink();
                          return _sidebarCountPill(
                            count.toString(),
                            isOrange: false,
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        if (sectionLabel == null && !showDividerAbove) return row;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDividerAbove)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
            if (sectionLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 6),
                child: Text(
                  sectionLabel.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            row,
          ],
        );
      },
    );
  }

  /// Rounded count badge shown after Recent Orders (orange with white text)
  /// and Leads (light grey with slate text).
  Widget _sidebarCountPill(String count, {bool isOrange = false}) {
    final bool isZero = count == '0';
    final Color bgColor = isOrange
        ? const Color(0xFFD97706)
        : (isZero ? const Color(0xFFE2E8F0) : const Color(0xFFD97706));
    final Color textColor = isOrange
        ? Colors.white
        : (isZero ? const Color(0xFF64748B) : Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        count,
        style: TextStyle(
          fontFamily: 'Poppins_Regular',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget upperSideBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            homeScaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_rounded,
              size: 22,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleLogoutOnConfirmation(BuildContext context) async {
    // Stop location tracking (both background service and foreground timer)
    try {
      CheckInService().stopTracking();
      ConnectivityService().reset();
    } catch (e) {
      print(
          "Error stopping location tracking or resetting connectivity on logout: $e");
    }

    // Create backup of current login data before clearing
    SessionHelper().createLoginDataBackup();

    // Clear settings data and original login data
    await SessionHelper().clearLoginDataKeepBackup();

    Get.offAllNamed(AppRoutes.login);
  }
}

String getSidebarIcon(int index) {
  switch (index) {
    case 0:
      return "assets/sidebar_icons/homeicon.svg";
    case 1:
      return "assets/sidebar_icons/customer.svg";
    case 2:
      return "assets/sidebar_icons/product.svg";
    case 3:
      return "assets/sidebar_icons/paymenticon.svg";
    case 4:
      return "assets/sidebar_icons/leadicon.svg";
    case 5:
      return "assets/sidebar_icons/calendaricon.svg";
    case 6:
      return "assets/sidebar_icons/salesreturn.svg";
    case 7:
      return "assets/sidebar_icons/ordericon.svg";
    case 8:
      return "assets/sidebar_icons/perfomanceImage.svg";
    case 9:
      return "assets/sidebar_icons/settingsicon.svg";
    case 10:
      return "assets/sidebar_icons/logouticon.svg";
    default:
      return "assets/sidebar_icons/ic_user.svg";
  }
}

/// Modern icon set for the sidebar navigation matching the reference design.
IconData getSidebarIconData(int index, {required bool selected}) {
  switch (index) {
    case 0:
      return Icons.grid_view_rounded;
    case 1:
      return Icons.people_outline_rounded;
    case 2:
      return Icons.inventory_2_outlined;
    case 3:
      return Icons.shopping_cart_outlined;
    case 4:
      return Icons.restart_alt_rounded;
    case 5:
      return Icons.payments_outlined;
    case 6:
      return Icons.person_add_alt_1_outlined;
    case 7:
      return Icons.calendar_today_outlined;
    case 8:
      return Icons.bar_chart_rounded;
    case 9:
      return Icons.settings_outlined;
    case 10:
      return Icons.logout_rounded;
    default:
      return Icons.circle_outlined;
  }
}
