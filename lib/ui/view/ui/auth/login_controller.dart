import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
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
    print("Request Body: $requestBody");
    loginResponce = (await Future.wait([
      _apiWorker.loginApi(
        emailController.text.removeAllWhitespace,
        passwordController.text,
      )
    ])).first;
    print("Response Body: ${loginResponce?.toJson()}");

    if (loginResponce != null) {
      // Handle status check
      if (loginResponce?.status == false) {
        // Show dialog for login failure
        Get.dialog(
          AlertDialog(
            title: const Text('Login Failed'),
            content: const Text(
              'Login unsuccessful. Please check your credentials and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return false;
      }

      // Handle successful login
      loginButtonController.success();
      await SessionHelper().setLoginData(loginResponce!.data!).then((value) {
        SessionHelper.loginSavedData = loginResponce!.data;
        Get.offAllNamed(AppRoutes.home);
      });
      return true;
    }

    // Default return for null response
    return false;
  } catch (e) {
    // Handle errors
    loginButtonController.error();
    loginButtonController.reset();

    if (e.toString().contains("401")) {
      handleTokenExpiration();
    } else if (e.toString().contains("422")) {
      print("Error 422: Invalid credentials");
      return false;
    } else {
      print("Login Error: $e");
      Get.snackbar(
        'Login Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return false;
  }
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
              Get.offAllNamed(AppRoutes.login); // Navigate to login page
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

}
