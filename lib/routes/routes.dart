import 'package:busskit_salesexecutive/common/common_binding.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/map/nk_google_map.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_binding.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_binding.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_ui/home_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/performance.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/products_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/sales_return.dart';
import 'package:busskit_salesexecutive/ui/view/ui/settings/settings.dart';
import 'package:get/get.dart';

import '../ui/view/ui/customer_and_orders/customer_order_details/customer_order_details_screen.dart';

class AppRoutes {
  static const String initialRoutes = login;
  static const String splash = "/splash";
  static const String home = "/home";
  static const String orderTaking = "/order_taking";
  static const String login = "/login";
  static const String product = "/product";
  static const String dashboard = "/dashboard";
  static const String customersAndOrders = "/customersAndOrders";
  static const String customerOrderDetails = "/customerOrderDetails";
  static const String customerDashbord = "/customerDashbord";
  static const String pendingPayment = "/pendingPayment";
  static const String leads = "/leads";
  static const String calender = "/calender";

  static const String ordersScreen = "/ordersScreen";
  static const String mapScreen = "/mapScreen";
  static const String performance = "/performance";

  static const String unknown = "/unknown";
  static const String settings = "/settings";
  static const String salesReturn = "/salesReturn";
  static List<GetPage<dynamic>> get genratedRoutes => [
        GetPage(
            name: home, page: () => const HomeScreen(), binding: HomeBinding()),
        GetPage(
            name: login,
            page: () => const LoginScreen(),
            binding: LoginBinding()),
        GetPage(
            name: orderTaking,
            page: () => OrderTaking(
                  productsController: ProductsController(),
                ),
            binding: LoginBinding()),
        GetPage(
            name: product,
            page: () => const ProductScreen(),
            binding: CommonBinding()),
        GetPage(
            name: dashboard,
            page: () => DashBoardScreen(
                  homeController: Get.arguments ?? HomeController(),
                ),
            binding: CommonBinding()),
        GetPage(
          name: customersAndOrders,
          page: () => const Tableee(),
          binding: CommonBinding(),
        ),
        GetPage(
          name: customerOrderDetails,
          arguments: Get.arguments,
          transitionDuration: NkCommonFunction.longDuration(),
          transition: Transition.rightToLeft,
          page: () =>
              CustomerOrderDetailsScreen(customerAndOrderData: Get.arguments),
          binding: CommonBinding(),
        ),

        GetPage(
          name: pendingPayment,
          page: () => const PendingPaymentScreen(),
          binding: CommonBinding(),
        ),
        GetPage(
          name: performance,
          page: () => const PerformanceScreen(),
          binding: CommonBinding(),
        ),
        GetPage(
          name: leads,
          page: () => const LeadsScreen(),
          binding: CommonBinding(),
        ),
        GetPage(
            name: calender,
            page: () => const CalenderScreen(),
            binding: CommonBinding()),
        GetPage(
          name: ordersScreen,
          page: () => const OrderScreen(),
          binding: CommonBinding(),
        ),
        GetPage(
          name: mapScreen,
          page: () => const MapScreen(),
          binding: CommonBinding(),
        ),
        GetPage(
          name: settings,
          page: () => const SettingsScreen(),
          binding: CommonBinding(),
        ),
        GetPage(
          name: salesReturn,
          page: () => const SalesReturn(),
          binding: CommonBinding(),
        ),
      ];
}
