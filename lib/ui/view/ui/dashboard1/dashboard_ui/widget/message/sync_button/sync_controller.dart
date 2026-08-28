import 'dart:async';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncController extends GetxController {
  var isSyncing = false.obs;
  var syncStatusMessage = ''.obs;
  var lastSyncTime = Rxn<DateTime>();

  /// Load last sync time from storage
  Future<void> loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('lastSyncTime');
      if (str != null) {
        lastSyncTime.value = DateTime.tryParse(str);
      }
    } catch (e) {
      log('Error loading last sync time: $e');
    }
  }

  /// Save sync time
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString('lastSyncTime', now.toIso8601String());
      lastSyncTime.value = now;
    } catch (e) {
      log('Error saving last sync time: $e');
    }
  }

  /// Safe task wrapper that catches and logs errors without breaking the pipeline
  Future<void> _runSafe(String taskName, Future<dynamic> Function() task) async {
    try {
      syncStatusMessage.value = taskName;
      await task();
    } catch (e, stack) {
      log('[Sync Engine] Error during $taskName: $e');
      print("[Sync Engine] Task $taskName error: $e");
    }
  }

  /// Start syncing process
  Future<void> startSyncing(BuildContext context) async {
    if (isSyncing.value) return; // already syncing

    final isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      showCustomToastDisplay(
        context,
        "You are offline! Please check your internet connection.".tr,
        red,
        Icons.cloud_off_rounded,
      );
      return;
    }

    isSyncing.value = true;
    syncStatusMessage.value = 'Initializing sync...'.tr;

    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

    try {
      await loadAllInitialData(context, companyId);
      await Future.delayed(const Duration(milliseconds: 500));

      await _runSafe('Draft Items', () => CartDatabaseManager().getDraftItems());
      await _runSafe('Discounts', () => ApiWorker().fetchDiscounts(companyId, salesmanId));

      await _updateLastSyncTime();

      showCustomToastDisplay(
        context,
        "Data synchronized successfully!".tr,
        Colors.green,
        Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      log('[Sync Engine] Global sync error: $e');
      showCustomToastDisplay(
        context,
        "Sync completed with partial warnings.".tr,
        Colors.orange,
        Icons.warning_amber_rounded,
      );
    } finally {
      isSyncing.value = false;
      syncStatusMessage.value = '';
    }
  }

  /// 5-Phase Structured Synchronization Engine
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

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final formatter = DateFormat('yyyy-MM-dd');
    final startDate = formatter.format(firstDayOfMonth);
    final endDate = formatter.format(lastDayOfMonth);
    final String currentMonth = DateFormat.MMMM().format(now);
    final connectivityService = ConnectivityService();
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

    // =========================================================
    // PHASE 1: Upstream Sync (Push local offline changes first)
    // =========================================================
    await Future.wait([
      _runSafe('Pushing Offline Orders', () => connectivityService.syncOfflineOrders(onOrderSynced: orderController.loadOfflineOrders)),
      _runSafe('Pushing Offline Drafts', () => connectivityService.syncOfflineDrafts()),
      _runSafe('Retrying Queued Requests', () => connectivityService.retryOfflineRequests()),
    ]);

    // =========================================================
    // PHASE 2: Configuration & Master Settings
    // =========================================================
    await Future.wait([
      _runSafe('Subscription Features', () => subscriptionController.loadSubscriptionFeatures(companyId)),
      _runSafe('Weekly Type', () => ApiWorker().getWeeklyType()),
    ]);

    // =========================================================
    // PHASE 3: Product Catalog, Categories & Pricing
    // =========================================================
    await Future.wait([
      _runSafe('All Products (B2B)', () => ApiWorker().getAllProducts(companyId: companyId)),
      _runSafe('Categories & Default Products', () => productsController.loadCategoriesAndDefaultProducts(forceRefresh: true)),
      _runSafe('Product Frequency', () => productsController.loadProductFrequency()),
      _runSafe('Bulk Volumes', () => ApiWorker().getBulkVolumes()),
      _runSafe('Staff Discounts', () => ApiWorker().getStaffDiscount()),
      _runSafe('Promotions', () => ApiWorker().getPromotions()),
    ]);

    // =========================================================
    // PHASE 4: Customers, Orders & Analytics
    // =========================================================
    await Future.wait([
      _runSafe('Customers Data', () => customerAndOrderController.loadCustomer()),
      _runSafe('All Customer Pages', () => loginController.fetchAllCustomerPages(context)),
      _runSafe('Customer Analytics', () => ApiWorker().fetchOnlyCustomerDataInWhole(startDate, endDate)),
      _runSafe('Order Counts', () => orderController.loadOrderCountData()),
      _runSafe('Delivered Orders', () => ApiService().fetchAllOrders(isLogin: true, orderType: '', orderStatus: OrderStatus.delivered, fetchType: "Month")),
      _runSafe('Estimates (1)', () => ApiService().fetchAllOrders(isLogin: true, checkDate: true, orderType: 7, orderStatus: OrderStatus.estimates, fetchType: "Month")),
      _runSafe('Pre-Orders (1)', () => ApiService().fetchAllOrders(isLogin: true, checkDate: true, orderType: 0, orderStatus: OrderStatus.preOrder, fetchType: "Month")),
      _runSafe('Estimates (2)', () => ApiService().fetchAllOrders(isLogin: true, orderType: 7, orderStatus: OrderStatus.estimates, fetchType: "Month")),
      _runSafe('Pre-Orders (2)', () => ApiService().fetchAllOrders(isLogin: true, orderType: 0, orderStatus: OrderStatus.preOrder, fetchType: "Month")),
      _runSafe('Draft Orders', () => ApiService().fetchAllOrders(isLogin: true, orderType: 4, orderStatus: OrderStatus.draft, fetchType: "Month")),
      _runSafe('Cancelled Orders', () => ApiService().fetchAllOrders(isLogin: true, orderType: 3, orderStatus: OrderStatus.cancelled, fetchType: "Month")),
      _runSafe('Pending Payments (1)', () => pendingPaymentController.loadOrderData(chartIndex: 0, compId: companyId, isLogin: true)),
      _runSafe('Pending Payments (2)', () => pendingPaymentController.loadOrderData(chartIndex: 1, compId: companyId, isLogin: true)),
      _runSafe('Pending Payments (3)', () => pendingPaymentController.loadOrderData(chartIndex: 2, compId: companyId, isLogin: true)),
      _runSafe('Pending Payments (4)', () => pendingPaymentController.loadOrderData(chartIndex: 3, compId: companyId, isLogin: true)),
      _runSafe('Leads Customer Data', () => leadsController.loadLeadsCustomerData),
      _runSafe('Leads Secondary Data', () => leadsCustomerController.loadLeadsCustomerData),
      _runSafe('Rejected Leads', () => leadsRejectedController.loadRejectedLeadsData),
      _runSafe('Route Credit', () => calenderMapController.getRouteCredit()),
      _runSafe('Calendar Events', () => ApiWorker().getCalendarEvents({'companyId': companyId, 'initialDay': DateTime(now.year, now.month, 1).toIso8601String()})),
      _runSafe('Salesman Performance', () => ApiWorker().fetchSalesmanPerformanceData(monthName: DateFormat.MMMM().format(now), year: now.year, compId: companyId, salesId: salesmanId, isfromLogin: true)),
      _runSafe('TopBar Data (1)', () => ApiWorker().fetchSalesmanTopBarData(DateFormat.MMMM().format(now), 1)),
      _runSafe('TopBar Data (2)', () => ApiWorker().fetchSalesmanTopBarData(DateFormat.MMMM().format(now), 2)),
      _runSafe('TopBar Data (3)', () => ApiWorker().fetchSalesmanTopBarData(DateFormat.MMMM().format(now), 3)),
      _runSafe('TopBar Data (4)', () => ApiWorker().fetchSalesmanTopBarData(DateFormat.MMMM().format(now), 4)),
      _runSafe('Salesman Value Target', () => ApiWorker().fetchSalesmanValueTarget(salesmanId, now.year.toString(), null)),
      _runSafe('Salesman Target', () => ApiWorker().fetchSalesmanTarget(salesmanId, currentMonth, now.year.toString())),
      _runSafe('TimeSheet Data', () => ApiWorker().getTimeSheetData(filterValue: currentMonth, filterType: "Month")),
      _runSafe('Schedule', () => ApiWorker().fetchSchedule(endDate, startDate)),
    ]);

    // =========================================================
    // PHASE 5: Live UI Refresh & Background Media Caching
    // =========================================================
    await _runSafe('Dashboard Provider', () => Provider.of<DashboardProvider>(context, listen: false).fetchData());

    final currentSubCatId = productsController.selectedSubCategoryId.value;
    if (currentSubCatId.isNotEmpty) {
      await _runSafe('Active Subcategory Refresh', () => productsController.reloadProductsForSubCategory(currentSubCatId));
    }

    await productsController.checkCacheStatus();
    ApiWorker().cacheSyncImages(companyId);
  }
}
