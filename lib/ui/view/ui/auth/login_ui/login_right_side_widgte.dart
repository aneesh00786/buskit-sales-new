// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/widgets/forgot_password_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/view/register_dialog.dart';
import 'package:flutter/material.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';

class LoginRightSideWidget extends StatefulWidget {
  final LoginController loginController;
  const LoginRightSideWidget({super.key, required this.loginController});
  @override
  State<LoginRightSideWidget> createState() => _LoginRightSideWidgetState();
}

class _LoginRightSideWidgetState extends State<LoginRightSideWidget> {
  ValueNotifier<String> changeNotify = ValueNotifier(Assets.iconsIcLoginLogo);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    widget.loginController.loginResponce?.statusCode == null;
  }

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
      key: widget.loginController.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.pngThriveWoo,
                height: appDimensions.width / 5.5,
                fit: BoxFit.contain,
              ),
              
            ],
          ),
          TextFormField(
            controller: widget.loginController.emailController,
            decoration: InputDecoration(
              focusColor: Colors.blue,
              labelText: 'Email',
              prefixIcon: const Icon(
                Icons.alternate_email_outlined,
                color: primaryColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: widget.loginController.loginResponce?.statusCode ==
                                422 ||
                            widget.loginController.loginResponce?.statusCode ==
                                409
                        ? Colors.red
                        : Colors.grey,
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: widget.loginController.loginResponce?.statusCode ==
                                422 ||
                            widget.loginController.loginResponce?.statusCode ==
                                409
                        ? Colors.red
                        : primaryButtonColor,
                    width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
          widget.loginController.loginResponce?.statusCode == 422 ||
                  widget.loginController.loginResponce?.statusCode == 409
              ? const Text(
                  'Incorrect E-mail',
                  style: TextStyle(color: Colors.red),
                )
              : const Text(''),
          TextFormField(
            controller: widget.loginController.passwordController,
            obscureText: widget.loginController.isPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(
                EneftyIcons.lock_2_outline,
                color: primaryColor,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color:
                        widget.loginController.loginResponce?.statusCode == 401
                            ? Colors.red
                            : Colors.grey,
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color:
                        widget.loginController.loginResponce?.statusCode == 401
                            ? Colors.red
                            : primaryButtonColor,
                    width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              suffixIcon: widget.loginController.getIsPasswordVisible,
            ),
          ),
          widget.loginController.loginResponce?.statusCode == 401
              ? const Text(
                  'Incorrect Password',
                  style: TextStyle(color: Colors.red),
                )
              : const Text(''),
          const Align(
              alignment: Alignment.centerRight, child: ForgotPasswordScreen()),
          nkMediumSizeBox(),
          nkMediumSizeBox(),
          Row(
            children: [
              Expanded(child: getLoginButton(context)),
              const SizedBox(
                width: 10,
              ),
              Expanded(child: getRegisterButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget getLoginButton(BuildContext context) => Center(
        child: NkLoadingButton(
          isRoundedCorner: true,
          buttonText: singIn,
          onPressed: () async {
            widget.loginController.loginResponce == null;
            if (widget.loginController.formKey.currentState!.validate()) {
              bool success = await widget.loginController.performLogin(context);
              if (!success) {
                widget.loginController.loginButtonController.stop();
                widget.loginController.loginButtonController.reset();
              }
            } else {
              widget.loginController.loginButtonController.stop();
              widget.loginController.loginButtonController.reset();
            }
          },
          btnController: widget.loginController.loginButtonController,
        ),
      );
  Widget getRegisterButton(BuildContext context) => Center(
        child: NkLoadingButton(
          isRoundedCorner: true,
          buttonText: "Register",
          onPressed: () async {
            registerDialog(context, widget.loginController, _formKey);
          },
          btnController: widget.loginController.registerButtonController,
        ),
      );
}




