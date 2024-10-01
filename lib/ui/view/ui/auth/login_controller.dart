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

get loginCall async {
  try {
    loginResponce = (await Future.wait([_apiWorker.loginApi(
      emailController.text.removeAllWhitespace, 
      passwordController.text
    )])).first;

    if (loginResponce != null) {
      loginButtonController.success();
      await SessionHelper().setLoginData(loginResponce!.data!).then((value) {
        SessionHelper.loginSavedData = loginResponce!.data;
        Get.offAllNamed(AppRoutes.home); // Navigate to home after login
      });
    }
  } catch (e) {
    loginButtonController.error();
    loginButtonController.reset();

    if (e.toString().contains("401")) {
      handleTokenExpiration(); // Call the token expiration handler
    } else {
      Get.snackbar('Login Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
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
