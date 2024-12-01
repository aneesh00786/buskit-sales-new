import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final appDimensions = AppDimensions.instance;
    return Form(
      key: loginController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.iconsIcLoginLogo,
                width: appDimensions.width,
                height: appDimensions.width / 7.5,
                fit: BoxFit.contain,
              ),
            ],
          ),
          nkMediumSizeBox(),
          TextFormField(
            controller: loginController.emailController,
            decoration: InputDecoration(
              focusColor: Colors.blue,
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.alternate_email_outlined,
                color: primaryColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryButtonColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            autocorrect: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!NkCommonFunction.chckEmailValidation(value)) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
          nkMediumSizeBox(),
          nkMediumSizeBox(),
          TextFormField(
            controller: loginController.passwordController,
            obscureText: loginController.isPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(
                EneftyIcons.lock_2_outline,
                color: primaryColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: secondaryColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              suffixIcon: loginController.getIsPasswordVisible,
            ),
          ),
          nkMediumSizeBox(),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () async {
                final Uri url =
                    Uri.parse('https://your-forgot-password-link.com');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch $url';
                }
              },
              child: CustomText(
                content: 'Forgot Password..?',
                color: Colors.blue,
              ),
            ),
          ),
          nkMediumSizeBox(),
          nkMediumSizeBox(),
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
          width: AppDimensions.instance.width * 0.32,
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
