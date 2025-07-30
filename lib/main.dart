import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/connectivity/connectivity_cheker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/draft_model.dart';
import 'package:busskit_salesexecutive/ui/theme/get_theme.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_f5u40cbDttJ0TfoPDP7ynfNM00XLdPmGKM';
  await Stripe.instance.applySettings();
  await Hive.initFlutter();
  Hive.registerAdapter(DetailAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(CategoryTaxAdapter());
  Hive.registerAdapter(DraftAdapter());
  Hive.registerAdapter(CategoryDataAdapter());
  Hive.registerAdapter(SubCategoryItemAdapter());
  Hive.registerAdapter(CustomerDiscountModelAdapter());
  Hive.registerAdapter(DiscountModelAdapter());
  Hive.registerAdapter(AddToCartModelAdapter());
  Hive.registerAdapter(SendCartDataAdapter());
  Hive.registerAdapter(ProductApiResponseAdapter());
  Hive.registerAdapter(ScidProductGroupAdapter());
  await Hive.openBox<CustomerDiscountModel>('discounts');
  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<CartItem>('cartPreorderBox');
  await Hive.openBox<CartItem>('draftBox');
  await Hive.openBox('dashboardBox');
  await Hive.openBox('customerdashboardBox');
  await Hive.openBox('customerRevenueBox');
  await Hive.openBox('customerTotalSaleBox');
  await Hive.openBox('weeklyTypeBox');
  await Hive.openBox('customerBox');
  await Hive.openBox('chatBox');
  await Hive.openBox('pendingPaymentBox');
  await Hive.openBox('performanceBox');
  await Hive.openBox('leadsBox');
  await Hive.openBox('leadsRejectBox');
  await Hive.openBox('ordersBox');
  await Hive.openBox('fetchAllOrdersBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox('calendarEventsBox');
  await Hive.openBox('salesmanTargetBox');
  await Hive.openBox('salesmanValueTargetBox');
  await Hive.openBox('subscribtionBox');
  await Hive.openBox('subscribtionPlanDetailsBox');
  await Hive.openBox('fetchOnlyCustomerDataInWholeBox');
  await Hive.openBox('topBarDataBox');
  await Hive.openBox('timesheetBox');
  await Hive.openBox('scheduleBox');
  await Hive.openBox('draftAndCartIdsBox');
  await Hive.openBox('draftItemsBox');
  await Hive.openBox<ProductModel>('products');
  await Hive.openBox<ScidProductGroup>('scidProductGroups');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  bool isSyncing = false;
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: backgroundColor,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: backgroundColor,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  Get.lazyPut<HomeController>(() => HomeController());
  SessionHelper.loginSavedData = await SessionHelper().getLoginData();
  SessionHelper.settingsData = await SessionHelper().getSettingsData();
  Get.put(DashBoardController());
  final subscriptionController = Get.put(SubscriptionController());
  final orderController = Get.put(OrderController());

  Get.put(CalenderMapController());
  final customersAndOrdersController = Get.put(CustomerAndOrderController());
  final productsController = Get.put(ProductsController());

  await subscriptionController
      .loadSubscriptionFeatures(SessionHelper.loginSavedData?.company_id ?? 0);

  final cusProvider =
      Get.put(CustomersProvider(apiService: ApiService(), logger: Logger()));

  final connectivityService = ConnectivityService();
  connectivityService.startListening((connectivityResult) async {
    if (connectivityResult != ConnectivityResult.none) {
      bool isOnline = await connectivityService.isOnline();
      if (isOnline && !isSyncing) {
        isSyncing = true;

        try {
          await connectivityService.syncOfflineOrders(
            onOrderSynced: orderController.loadOfflineOrders,
          );
          await connectivityService.syncOfflineDrafts(onDraftsSynced: () async {
            await cusProvider.fetchCustomerDashboardCountData(
                customersAndOrdersController.customerId.value);
          });
          await connectivityService.retryOfflineRequests();
        } catch (e) {
          log('Error during sync: $e');
        } finally {
          isSyncing = false;
        }
      }
    }
  });

  // Handle cart persistence on app restart
  await _handleCartPersistenceOnRestart();

  runApp(MyApp(
      initialRout: SessionHelper.loginSavedData != null
          ? AppRoutes.home
          : AppRoutes.login));
}

/// Handles cart persistence when the app is restarted
Future<void> _handleCartPersistenceOnRestart() async {
  try {
    // Only handle cart persistence if user is logged in
    if (SessionHelper.loginSavedData != null) {
      log('Handling cart persistence on app restart...');

      // Get the ProductsController to access selectedCustomerId
      if (Get.isRegistered<ProductsController>()) {
        final productsController = Get.find<ProductsController>();
        final selectedCustomerId = productsController.selectedCustomerId.value;

        log('Selected customer ID on restart: $selectedCustomerId');

        // Call the cart persistence method
        await CartDatabaseManager()
            .handleCartPersistenceOnRestart(selectedCustomerId);
      } else {
        log('ProductsController not available, clearing cart items as safety measure');
        await CartDatabaseManager().handleCartPersistenceOnRestart(null);
      }
    } else {
      log('User not logged in, skipping cart persistence check');
    }
  } catch (e) {
    log('Error in _handleCartPersistenceOnRestart: $e');
    // As a fallback, clear cart items if there's an error
    try {
      await CartDatabaseManager().handleCartPersistenceOnRestart(null);
    } catch (fallbackError) {
      log('Error in fallback cart persistence: $fallbackError');
    }
  }
}

class MyApp extends StatefulWidget {
  final String? initialRout;
  const MyApp({super.key, this.initialRout});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final connectivityChecker = ConnectivityChecker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchAndSaveSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchAndSaveSettings();
    }
  }

  Future<void> _fetchAndSaveSettings() async {
    if (SessionHelper.loginSavedData != null) {
      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      if (companyId != 0) {
        log("Fetching settings...");
        List<AllCompanySettingsData>? settings =
            await ApiWorker().fetchAllSettings(companyId);
        if (settings != null) {
          await SessionHelper().setSettingsData(settings);
          await SessionHelper().getSettingsData();
          log('Settings data fetched and saved: ${settings.length}');
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivityChecker.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, sizingConstraints) {
        AppDimensions.createInstance(context, sizingConstraints);
        connectivityChecker.startMonitoring();
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) =>
                  CustomersProvider(apiService: ApiService(), logger: Logger()),
            ),
            ChangeNotifierProvider(
              create: (context) =>
                  DashboardProvider(apiService: ApiService(), logger: Logger()),
            ),
          ],
          child: GetMaterialApp(
            navigatorKey: Get.key,
            theme: NkGetXTheme.lightTheme,
            darkTheme: NkGetXTheme.lightTheme,
            highContrastTheme: NkGetXTheme.lightTheme,
            highContrastDarkTheme: NkGetXTheme.lightTheme,
            showPerformanceOverlay: false,
            initialBinding: CommonBinding(),
            getPages: AppRoutes.genratedRoutes,
            initialRoute: widget.initialRout,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
