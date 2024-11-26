import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/connectivity/connectivity_cheker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/sqflite_database/database_helper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/theme/get_theme.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_provider.dart';
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
  Hive.registerAdapter(CategoryDataAdapter());
  Hive.registerAdapter(SubCategoryItemAdapter());
  await Hive.openBox<CartItem>('cartBox');
  DatabaseHelper.database;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: backgroundColor,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: backgroundColor,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  SessionHelper.loginSavedData = await SessionHelper().getLoginData();

  Get.lazyPut<HomeController>(() => HomeController());
  if (SessionHelper.loginSavedData != null) {
    runApp(MyApp(initialRout: AppRoutes.home));
  } else {
    runApp(MyApp(initialRout: AppRoutes.login));
  }
}

class MyApp extends StatefulWidget {
  final String? initialRout;
  MyApp({Key? key, this.initialRout}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final connectivityChecker = ConnectivityChecker();

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
