import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginRightSideWidget extends StatelessWidget {
  final LoginController loginController;
  const LoginRightSideWidget({Key? key, required this.loginController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: nkSymmetricPadding(vertical: 0),
      decoration: const BoxDecoration(color: secondaryColor),
      child: Center(child: getFillWidget()),
    );
  }

  Widget getFillWidget() {
    return Form(
      key: loginController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          fillHeading(email),
          nkMediumSizeBox(),
          MyFormField(
              isAutoCurrect: true,
              isShowDefaultValidator: true,
              controller: loginController.emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!NkCommonFunction.chckEmailValidation(value)) {
                  return 'Please enter valid email';
                }
                return null;
              },
              labelText: enterEmail),
          nkMediumSizeBox(),
          nkMediumSizeBox(),
          fillHeading(password),
          Obx(
            () => MyFormField(
                isShowDefaultValidator: true,
                obscureText: loginController.isPasswordVisible.value,
                suffixIcon: loginController.getIsPasswordVisible,
                controller: loginController.passwordController,
                maxLines: 1,
                labelText: enterPassword),
          ),
          nkLargeSizeBox(),
          getLoginButton
        ],
      ),
    );
  }

  Widget fillHeading(String headingName) {
    return MyRegularText(
      fontSize: NkFontSize.largeFont() + 5,
      label: headingName,
    );
  }

  Widget get getLoginButton => Center(
        child: NkLoadingButton(
          width: AppDimensions.instance.width * 0.12,
          isRoundedCorner: true,
          buttonText: singIn,
          onPressed: () => {
            if (loginController.formKey.currentState!.validate())
              {loginController.loginCall}
            else
              {
                loginController.loginButtonController.stop(),
                loginController.loginButtonController.reset()
              }
          },
          btnController: loginController.loginButtonController,
        ),
      );
}
