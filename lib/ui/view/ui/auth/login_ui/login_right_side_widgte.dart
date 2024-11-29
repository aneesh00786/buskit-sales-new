import 'package:busskit_salesexecutive/generated/assets.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginRightSideWidget extends StatelessWidget {
  final LoginController loginController;
   LoginRightSideWidget({Key? key, required this.loginController})
      : super(key: key);
ValueNotifier<String> changeNotify = ValueNotifier(Assets.iconsIcLoginLogo);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: nkSymmetricPadding(vertical: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(child: getFillWidget(context)),
    );
  }

  Widget getFillWidget(BuildContext context) {
    return Form(
      key: loginController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            builder: (BuildContext context, String val, Widget? child) {
              return Center(
                child: CircleAvatar(
                  radius: 70, // Set the desired radius
                  backgroundColor:
                      Colors.transparent, // Optional: Set a background color
                  child: ClipOval(
                    child: SvgPicture.asset(
                      "assets/icons/ic_login_logo.svg",
                      fit: BoxFit.contain,
                      width: 100, // Ensure the size matches the circle
                      height: 100,
                    ),
                  ),
                ),
              );
            },
            valueListenable: changeNotify,
          ),
          fillHeading(email),
          nkMediumSizeBox(),
          MyFormField(
              isAutoCurrect: true,
              isShowDefaultValidator: true,
              controller: loginController.emailController,
              enableColor: Colors.grey,
              focusedColor: Colors.blue,
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
                enableColor: Colors.grey,
                focusedColor: Colors.blue,
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
