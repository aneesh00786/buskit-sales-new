import 'dart:async';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncController extends GetxController {
  var isSyncing = false.obs;
  var lastSyncTime = Rxn<DateTime>();

  /// Load last sync time from storage
  Future<void> loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('lastSyncTime');
    if (str != null) {
      lastSyncTime.value = DateTime.tryParse(str);
    }
  }

  /// Save sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastSyncTime', now.toIso8601String());
    lastSyncTime.value = now;
  }

  /// Start syncing process
  Future<void> startSyncing(BuildContext context) async {
    if (isSyncing.value) return; // already syncing
    isSyncing.value = true;

    const salesmanId = '';
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;

    try {
      await loadAllInitialData(context, companyId);
      await Future.delayed(const Duration(seconds: 2));
      await CartDatabaseManager().getDraftItems();
      await ApiWorker().fetchDiscounts(companyId, salesmanId);

      await _updateLastSyncTime();
    } catch (e) {
      //
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> loadAllInitialData(BuildContext context, int companyId) async {
    final loginController = Get.find<LoginController>();
    final calenderMapController = Get.find<CalenderMapController>();
    final customerAndOrderController = Get.find<CustomerAndOrderController>();
    final leadsController = Get.find<LeadsController>();
    final leadsCustomerController = Get.find<CustomersController>();
    final leadsRejectedController = Get.find<RejectedLeadsController>();
    final orderController = Get.find<OrderController>();
    final pendingPaymentController = Get.find<PendingPaymentController>();
    final productsController = Get.find<ProductsController>();
    final subscriptionController = Get.find<SubscriptionController>();

    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final startDate = formatter.format(firstDayOfMonth);
    final endDate = formatter.format(lastDayOfMonth);

    final connectivityService = ConnectivityService();

    final String currentMonth = DateFormat.MMMM().format(DateTime.now());

    try {

      await Future.wait([
        connectivityService.syncOfflineOrders(
          onOrderSynced: orderController.loadOfflineOrders,
        ),
        connectivityService.syncOfflineDrafts(),
        connectivityService.retryOfflineRequests(),
        subscriptionController.loadSubscriptionFeatures(companyId),
        Provider.of<DashboardProvider>(context, listen: false).fetchData(),
        customerAndOrderController.loadCustomer(),
        productsController.loadCategoriesAndDefaultProducts(),
        productsController.loadProductFrequency(),
        pendingPaymentController.loadOrderData(
            chartIndex: 0, compId: companyId, isLogin: true),
        pendingPaymentController.loadOrderData(
            chartIndex: 1, compId: companyId, isLogin: true),
        pendingPaymentController.loadOrderData(
            chartIndex: 2, compId: companyId, isLogin: true),
        pendingPaymentController.loadOrderData(
            chartIndex: 3, compId: companyId, isLogin: true),
        ApiWorker().fetchDiscounts(companyId, ""),
        leadsController.loadLeadsCustomerData,
        leadsCustomerController.loadLeadsCustomerData,
        leadsRejectedController.loadRejectedLeadsData,
        orderController.loadOrderCountData(),

        ApiWorker().getRecentOrdersReturns(startDate: startDate, endDate: endDate ),

        ApiWorker().getAllProducts(),
        calenderMapController.getRouteCredit(),
        ApiWorker().getCalendarEvents({
          'companyId': companyId,
          'initialDay': DateTime(DateTime.now().year, DateTime.now().month, 1)
              .toIso8601String(),
        }),
        ApiWorker().fetchOnlyCustomerDataInWhole(startDate, endDate),
        connectivityService.syncOfflineDrafts(),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: '',
            orderStatus: OrderStatus.delivered,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            checkDate: true,
            orderType: 7,
            orderStatus: OrderStatus.estimates,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            checkDate: true,
            orderType: 0,
            orderStatus: OrderStatus.preOrder,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 7,
            orderStatus: OrderStatus.estimates,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 0,
            orderStatus: OrderStatus.preOrder,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 4,
            orderStatus: OrderStatus.draft,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 3,
            orderStatus: OrderStatus.cancelled,
            fetchType: "Month"),
        ApiWorker().getWeeklyType(),
        ApiWorker().fetchSalesmanPerformanceData(
          monthName: DateFormat.MMMM().format(DateTime.now()),
          year: DateTime.now().year,
          compId: companyId,
          salesId: SessionHelper.loginSavedData?.salesmanId ?? '',
          isfromLogin: true,
        ),
        ApiWorker().fetchSalesmanTopBarData(
            DateFormat.MMMM().format(DateTime.now()), 1),
        ApiWorker().fetchSalesmanTopBarData(
            DateFormat.MMMM().format(DateTime.now()), 2),
        ApiWorker().fetchSalesmanTopBarData(
            DateFormat.MMMM().format(DateTime.now()), 3),
        ApiWorker().fetchSalesmanTopBarData(
            DateFormat.MMMM().format(DateTime.now()), 4),
        ApiWorker().fetchSalesmanValueTarget(
          SessionHelper.loginSavedData?.salesmanId ?? '',
          DateTime.now().year.toString(), null,
        ),
        ApiWorker().fetchSalesmanTarget(
          SessionHelper.loginSavedData?.salesmanId ?? '',
          currentMonth,
          DateTime.now().year.toString(),
        ),
        ApiWorker().getTimeSheetData(
      year: now.year.toString(), 
    ),
        // ApiWorker().getTimeSheetData(
        //   startDate: startDate,
        //   endDate: endDate,
        // ),
        ApiWorker().fetchSchedule(
          endDate,
          startDate,
        ),
        loginController.fetchAllCustomerPages(context),
      ]);

      // Check cache status after loading all data
      await productsController.checkCacheStatus();
    } catch (e) {
      // Optionally: Show a user-friendly error message here
      // Do NOT rethrow, so the future always completes
    }
  }
}
