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
    loginResponce = (await Future.wait([
      _apiWorker.loginApi(
          emailController.text.removeAllWhitespace, passwordController.text)
    ]).onError((error, stackTrace) {
       loginButtonController.error();
       loginButtonController.reset();
      return Future.error(error.toString());
    })).first;
    
    if (loginResponce != null) {
      loginButtonController.success();
      await SessionHelper().setLoginData(loginResponce!.data!).then((value) {
        SessionHelper.loginSavedData = loginResponce!.data;
        Get.offAllNamed(AppRoutes.home);
      }
      );
    }
  }
/*
  get loginCall async {
    try {
      loginResponce = (await _apiWorker.loginApi(
          emailController.text, passwordController.text));

      log("AAAAAA ", error: loginResponce.toString());
      loginButtonController.success();
    } on DioError catch (e) {
      loginButtonController.error();
      loginButtonController.reset();
    }
  }
*/
}
