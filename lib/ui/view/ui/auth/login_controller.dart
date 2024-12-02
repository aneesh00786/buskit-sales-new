import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class LoginController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

Future<bool> performLogin() async {
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
      await SessionHelper().setLoginData(loginResponce!.data!).then((value) {
        SessionHelper.loginSavedData = loginResponce!.data;
        Get.offAllNamed(AppRoutes.home);
      });
      return true;
    } else if (loginResponce?.statusCode == 422||loginResponce?.statusCode == 409) {
      showErrorDialog('Login Failed', loginResponce?.message ?? 'Email is not registered.');
    } else if (loginResponce?.statusCode == 401) {
      showErrorDialog('Login Failed', loginResponce?.message ?? 'Password is wrong.');
    } else {
      showErrorDialog('Login Error', 'An unexpected error occurred. Please try again.');
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
