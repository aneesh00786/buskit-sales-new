import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/connectivity/connectivity_cheker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/sqflite_database/database_helper.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  await Hive.openBox<CustomerDiscountModel>('discounts');
  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<CartItem>('cartPreorderBox');
  await Hive.openBox<CartItem>('draftBox');
  await Hive.openBox('dashboardBox');
  await Hive.openBox('customerBox');
  await Hive.openBox('productBox');
  await Hive.openBox('chatBox');
  await Hive.openBox('pendingPaymentBox');
  await Hive.openBox('performanceBox');
  await Hive.openBox('leadsBox');
  await Hive.openBox('leadsRejectBox');
  await Hive.openBox('ordersBox');
  await Hive.openBox('calendarEventsBox');
  DatabaseHelper.database;
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
  SessionHelper.loginSavedData = await SessionHelper().getLoginData();
  SessionHelper.settingsData = await SessionHelper().getSettingsData();
  Get.lazyPut<HomeController>(() => HomeController());
  final connectivityService = ConnectivityService();
  connectivityService.startListening((connectivityResult) async {
    if (connectivityResult != ConnectivityResult.none) {
      bool isOnline = await connectivityService.isOnline();
      if (isOnline && !isSyncing) {
        isSyncing = true;
        try {
          await connectivityService.syncOfflineOrders();
          await connectivityService.syncOfflineDrafts();
        } catch (e) {
          log('Error during sync: $e');
        } finally {
          isSyncing = false;
        }
      }
    }
  });
  runApp(MyApp(
      initialRout: SessionHelper.loginSavedData != null
          ? AppRoutes.home
          : AppRoutes.login));
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
              create: (context) => ProductProvider(),
            ),
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
