import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  late final TabController _tabController;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ProductsController productsController = Get.put(ProductsController());
  PendingPaymentController pendingPaymentController =
      Get.put(PendingPaymentController());
  StaffController staffController = Get.put(StaffController());

  LoginResponce? loginResponce;

  RoundedLoadingButtonController loginButtonController =
      RoundedLoadingButtonController();

  RxBool isPasswordVisible = true.obs;

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

  Future<bool> performLogin(BuildContext context) async {
    final int currentYear = DateTime.now().year;
    final int currentMonth = DateTime.now().month;

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
        await SessionHelper().setLoginData(loginResponce!.data!);
        final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
        final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
        final targetType = SessionHelper.settingsData
                ?.firstWhere(
                  (setting) => setting.key == 'targetType',
                  orElse: () => AllCompanySettingsData(
                    key: 'targetType',
                    value: '',
                  ),
                )
                .value ??
            '';
        log("Fetching settings after login...");
        await Future.delayed(Duration(seconds: 2));
        final settings = await _apiWorker.fetchAllSettings(companyId);
        await Provider.of<CustomersProvider>(context, listen: false)
            .fetchCustomerData();
        await productsController.fetchCategoryData();
        await _apiWorker.getTempProduct('C49SC7');
        await pendingPaymentController.loadOrderData(
            chartIndex: 0, compId: companyId);
        await staffController.loadSalesmanTargetForSelectedTab(
            currentYear: currentYear.toString(),
            selectedTabIndex: _tabController.index + 1,
            staffId: salesmanId);
        if (settings != null) {
          await SessionHelper().setSettingsData(settings);
        }
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else if (loginResponce?.statusCode == 422 ||
          loginResponce?.statusCode == 409) {
        return false;
      } else if (loginResponce?.statusCode == 401) {
        return false;
      } else {
        showErrorDialog(
          'Login Error',
          'An unexpected error occurred. Please try again.',
        );
      }

      return false;
    } catch (e) {
      loginButtonController.error();
      loginButtonController.reset();

      if (e is DioException) {
        log("DioException: ${e.response?.data}");
        Get.snackbar(
          'Login Error',
          e.response?.data['message'] ?? e.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        log("Login Error: $e");
        Get.snackbar(
          'Login Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return false;
    }
  }

  /// Utility function to show error dialog
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
}
