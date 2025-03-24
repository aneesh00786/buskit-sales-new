// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/splash_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../../common/search_model.dart';

class LoginController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  TabController? _tabController;
  TabController? get tabController => _tabController;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ProductsController productsController = Get.put(ProductsController());
  PendingPaymentController pendingPaymentController =
      Get.put(PendingPaymentController());
  StaffController staffController = Get.put(StaffController());
  LeadsController leadsController = Get.put(LeadsController());
  CustomersController leadsCustomerController = Get.put(CustomersController());
  OrderController orderController = Get.put(OrderController());
  CalenderMapController calenderMapController =
      Get.put(CalenderMapController());
  RejectedLeadsController leadsRejectedController =
      Get.put(RejectedLeadsController());
  LoginResponce? loginResponce;
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  RoundedLoadingButtonController loginButtonController =
      RoundedLoadingButtonController();
  RxBool isPasswordVisible = true.obs;
  PaginationModel paginationModel = PaginationModel();
  final int currentYear = DateTime.now().year;
  int selectedTabIndex = 0;
  SearchModel searchData = SearchModel();

  Widget get getIsPasswordVisible {
    if (isPasswordVisible.value) {
      return IconButton(
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
        },
        icon: const Icon(Icons.visibility),
      );
    } else {
      return IconButton(
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
        },
        icon: const Icon(Icons.visibility_off),
      );
    }
  }

  void initializeTabController(TickerProvider vsync, {required int length}) {
    _tabController = TabController(length: length, vsync: vsync);
  }

  Future<bool> performLogin(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    String firstDayString = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String lastDayString = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
    DateTime? initialDay;
    try {
      final requestBody = {
        "email": emailController.text.removeAllWhitespace,
        "password": passwordController.text,
      };
      log("Request Body: $requestBody");
      loginResponce = await _apiWorker.loginApi(
        emailController.text.removeAllWhitespace,
        passwordController.text,
      );
      log("Response Body: ${loginResponce?.toJson()}");
      log("StatusCode: ${loginResponce?.statusCode}");

      if (loginResponce?.statusCode == 200) {
        loginButtonController.success();
        Get.to(() => SplashScreen(message: "Logging in..."),
            transition: Transition.fade);
        await SessionHelper().setLoginData(loginResponce!.data!);
        final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
        final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
        log("Fetching settings after login...");
        await Future.delayed(const Duration(milliseconds: 500));
        final settings = await _apiWorker.fetchAllSettings(companyId);
        await Future.wait([
          Provider.of<CustomersProvider>(context, listen: false)
              .fetchCustomerData(),
          customerAndOrderController.loadCustomer(),
          productsController.fetchCategoryData(),
          pendingPaymentController.loadOrderData(
              chartIndex: 0, compId: companyId, isLogin: true),
          staffController.loadSalesmanTargetForSelectedTab(
              currentYear: currentYear.toString(),
              selectedTabIndex: _tabController!.index + 1,
              staffId: salesmanId,
              isFromLogin: true
              ),
          leadsController.loadLeadsCustomerData,
          leadsCustomerController.loadLeadsCustomerData,
          leadsRejectedController.loadRejectedLeadsData,
          calenderMapController
              .fetchCalenderEvents(initialDay ?? DateTime.now()),
          ApiWorker().fetchDiscounts(companyId, salesmanId),
          CartDatabaseManager().getDraftItems(),
        ]);
        await ApiWorker()
            .getRecentOrdersData(
              searchModel: searchData,
              orderStatus: 11,
              isLogin: true,
              startDate: firstDayString,
              endDate: lastDayString,
            )
            .then((data) =>
                log("Recent orders fetched successfully. Data: ${data}"))
            .catchError((e) => log("Error while fetching recent orders: $e"));

        if (settings != null) {
          await SessionHelper().setSettingsData(settings);
        }

        SubCategoryItem? subCategoryItem =
            productsController.getInitialSubCategoryIdAndName();
        if (subCategoryItem != null && (subCategoryItem.id ?? '').isNotEmpty) {
          await productsController.fetchProducts(subCategoryItem.id!);
        } else {
          log("No subcategory found. Products not fetched.");
        }

        // Navigate to Home Screen
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        return _handleLoginError(loginResponce);
      }
    } catch (e) {
      _handleException(e);
      return false;
    }
  }

  void _handleException(Object e) {
    log("Login Error: $e");
    loginButtonController.error();
    loginButtonController.reset();

    if (e is DioException) {
      Get.snackbar(
        'Login Error',
        e.response?.data['message'] ?? e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool _handleLoginError(LoginResponce? response) {
    if (response?.statusCode == 422 || response?.statusCode == 409) {
      // Client-side errors like validation or duplicate conflict
      return false;
    } else if (response?.statusCode == 401) {
      // Unauthorized (e.g., incorrect credentials)
      return false;
    } else {
      // Unexpected errors
      showErrorDialog(
        'Login Error',
        'An unexpected error occurred. Please try again.',
      );
    }
    return false; // Default to false in case of error
  }

  void showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void handleTokenExpiration() async {
    if (!Get.isDialogOpen!) {
      await Get.dialog(
        AlertDialog(
          title: Text("Session Expired"),
          content: Text("Your session has expired. Please log in again."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                await SessionHelper().clearAll();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
  // // Future<bool> performLogin(BuildContext context) async {
  // //   DateTime now = DateTime.now();
  // //   DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
  // //   DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
  // //   String firstDayString = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
  // //   String lastDayString = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
  // //   DateTime? initialDay;
  // //   try {
  // //     final requestBody = {
  // //       "email": emailController.text.removeAllWhitespace,
  // //       "password": passwordController.text,
  // //     };
  // //     log("Request Body: $requestBody");
  // //     loginResponce = await _apiWorker.loginApi(
  // //       emailController.text.removeAllWhitespace,
  // //       passwordController.text,
  // //     );
  // //     log("Response Body: ${loginResponce?.toJson()}");
  // //     log("StatusCode: ${loginResponce?.statusCode}");
  // //     if (loginResponce?.statusCode == 200) {
  // //       loginButtonController.success();
  // //       await SessionHelper().setLoginData(loginResponce!.data!);
  // //       final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  // //       final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  // //       log("Fetching settings after login...");
  // //       await Future.delayed(const Duration(seconds: 2));
  // //       final settings = await _apiWorker.fetchAllSettings(companyId);
  // //       await Future.delayed(const Duration(microseconds: 500));
  // //       await Provider.of<CustomersProvider>(context, listen: false)
  // //           .fetchCustomerData();
  // //       await customerAndOrderController.loadCustomer();
  // //       await Future.delayed(const Duration(microseconds: 500));
  // //       await productsController.fetchCategoryData();
  // //       await Future.delayed(const Duration(microseconds: 500));
  // //       await pendingPaymentController.loadOrderData(
  // //           chartIndex: 0, compId: companyId, isLogin: true);
  // //       await Future.delayed(const Duration(microseconds: 500));
  // //       await staffController.loadSalesmanTargetForSelectedTab(
  // //           currentYear: currentYear.toString(),
  // //           selectedTabIndex: _tabController!.index + 1,
  // //           staffId: salesmanId);
  // //       log('First Date $firstDayString LastDay String $lastDayString Salesman ID $salesmanId CompanyId $companyId');
  // //       await ApiWorker().fetchRecentOrderCount(startDate: '', endDate: '');
  // //       if (settings != null) {
  // //         await SessionHelper().setSettingsData(settings);
  // //       }
  // //       SubCategoryItem? subCategoryItem =
  // //           productsController.getInitialSubCategoryIdAndName();
  // //       if (subCategoryItem != null && (subCategoryItem.id ?? '').isNotEmpty) {
  // //         await productsController.fetchProducts(subCategoryItem.id!);
  // //       } else {
  // //         log("No subcategory found. Products not fetched.");
  // //       }
  // //       await Future.delayed(const Duration(microseconds: 500));
  // //       await leadsController.loadLeadsCustomerData;
  // //       await leadsCustomerController.loadLeadsCustomerData;
  // //       await leadsRejectedController.loadRejectedLeadsData;
  // //       await Future.delayed(const Duration(microseconds: 500));
  // //       ApiWorker()
  // //           .getRecentOrdersData(
  // //         searchModel: searchData,
  // //         orderStatus: 11,
  // //         isLogin: true,
  // //         startDate: firstDayString,
  // //         endDate: lastDayString,
  // //       )
  // //           .then((data) {
  // //         log("Recent orders fetched successfully. Data: $data");
  // //         if (data.pagination != null && data.pagination!.totalPages != null) {
  // //           orderController.totalPages.value =
  // //               data.pagination!.totalPages!.toInt();
  // //         } else {
  // //           log("Pagination details are missing.");
  // //           orderController.totalPages.value = 1;
  // //         }
  // //       }).catchError((e) {
  // //         log("Error while fetching recent orders: $e");
  // //       });
  // //       await calenderMapController
  // //           .fetchCalenderEvents(initialDay ?? DateTime.now());
  // //       Get.offAllNamed(AppRoutes.home);
  // //       return true;
  // //     } else if (loginResponce?.statusCode == 422 ||
  // //         loginResponce?.statusCode == 409) {
  // //       return false;
  // //     } else if (loginResponce?.statusCode == 401) {
  // //       return false;
  // //     } else {
  // //       showErrorDialog(
  // //         'Login Error',
  // //         'An unexpected error occurred. Please try again.',
  // //       );
  // //     }

  // //     return false;
  // //   } catch (e) {
  // //     loginButtonController.error();
  // //     loginButtonController.reset();

  // //     if (e is DioException) {
  // //       log("DioException: ${e.response?.data}");
  // //       Get.snackbar(
  // //         'Login Error',
  // //         e.response?.data['message'] ?? e.message,
  // //         snackPosition: SnackPosition.BOTTOM,
  // //       );
  // //     } else {
  // //       log("Login Error: $e");
  // //       Get.snackbar(
  // //         'Login Error',
  // //         e.toString(),
  // //         snackPosition: SnackPosition.BOTTOM,
  // //       );
  // //     }

  // //     return false;
  // //   }
  // // }

  // void _handleException(Object e) {
  //   log("Login Error: $e");
  //   loginButtonController.error();
  //   loginButtonController.reset();

  //   if (e is DioException) {
  //     Get.snackbar(
  //       'Login Error',
  //       e.response?.data['message'] ?? e.message,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } else {
  //     Get.snackbar(
  //       'Login Error',
  //       e.toString(),
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }

  // bool _handleLoginError(LoginResponce? response) {
  //   if (response?.statusCode == 422 || response?.statusCode == 409) {
  //     // Client-side errors like validation or duplicate conflict
  //     return false;
  //   } else if (response?.statusCode == 401) {
  //     // Unauthorized (e.g., incorrect credentials)
  //     return false;
  //   } else {
  //     // Unexpected errors
  //     showErrorDialog(
  //       'Login Error',
  //       'An unexpected error occurred. Please try again.',
  //     );
  //   }
  //   return false; // Default to false in case of error
  // }

  // void showErrorDialog(String title, String message) {
  //   Get.dialog(
  //     AlertDialog(
  //       title: Text(title),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Get.back();
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void handleTokenExpiration() async {
  //   if (!Get.isDialogOpen!) {
  //     await Get.dialog(
  //       AlertDialog(
  //         title: const Text("Session Expired"),
  //         content: const Text("Your session has expired. Please log in again."),
  //         actions: [
  //           TextButton(
  //             child: const Text("OK"),
  //             onPressed: () async {
  //               await SessionHelper().clearAll();
  //               Get.offAllNamed(AppRoutes.login);
  //             },
  //           ),
  //         ],
  //       ),
  //       barrierDismissible: false,
  //     );
  //   }
  // }
}
