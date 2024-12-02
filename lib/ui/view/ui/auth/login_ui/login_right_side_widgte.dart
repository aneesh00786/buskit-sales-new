import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';

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
              suffixIcon: loginController.getIsPasswordVisible,
            ),
          ),
          nkMediumSizeBox(),
          Align(
              alignment: Alignment.centerRight, child: ForgotPasswordScreen()),
          nkMediumSizeBox(),
          nkMediumSizeBox(),
          getLoginButton(context),
        ],
      ),
    );
  }

  Widget getLoginButton(BuildContext context) => Center(
        child: NkLoadingButton(
          width: AppDimensions.instance.width * 0.32,
          isRoundedCorner: true,
          buttonText: singIn,
          onPressed: () async {
            if (loginController.formKey.currentState!.validate()) {
              bool success = await loginController.performLogin();
              if (!success) {
                loginController.loginButtonController.stop();
                loginController.loginButtonController.reset();
              }
            } else {
              loginController.loginButtonController.stop();
              loginController.loginButtonController.reset();
            }
          },
          btnController: loginController.loginButtonController,
        ),
      );
}

class ForgotPasswordScreen extends StatelessWidget {
  // Function to show the bottom sheet
  void showEmailBottomSheet(BuildContext context) {
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom, 
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              nkMediumSizeBox(),
              Icon(
                Icons.email_outlined,
                color: const Color.fromARGB(255, 249, 140, 132),
                size: 60,
              ),
              const SizedBox(height: 16.0),
              Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    content: "Please enter you'r E-mail correctly..",
                    fontSize: 20,
                  )),
              nkMediumSizeBox(),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: primaryButtonColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: red, width: 1.5),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              nkMediumSizeBox(),
              Container(
                height: 60,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blue, // Button color
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {
                    String email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      print("Email submitted: $email");
                      Navigator.pop(context); // Close the bottom sheet
                    } else {
                      print("Email is empty!");
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 20, // Optional font size
                    ),
                  ),
                ),
              ),
              nkMediumSizeBox(),
              nkMediumSizeBox(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showEmailBottomSheet(context); // Show the bottom sheet when tapped
      },
      child: const Text(
        'Forgot Password..?',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
