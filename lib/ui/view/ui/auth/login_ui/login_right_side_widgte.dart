import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                // width: appDimensions!.width,
                height: appDimensions!.width / 5.5,
                fit: BoxFit.contain,
              ),
              // SvgPicture.asset(
              //   Assets.iconsIcLoginLogo,
              //   width: appDimensions.width,
              //   height: appDimensions.width / 7.5,
              //   fit: BoxFit.contain,
              // ),
            ],
          ),
          // nkMediumSizeBox(),
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
          // nkMediumSizeBox(),
          // nkMediumSizeBox(),
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
          // nkMediumSizeBox(),
          const Align(
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
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
              const Icon(
                Icons.email_outlined,
                color: Color.fromARGB(255, 249, 140, 132),
                size: 60,
              ),
              const SizedBox(height: 16.0),
              Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    content: "Enter you'r registered E-mail.",
                    fontSize: 20,
                  )),
              nkMediumSizeBox(),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: primaryButtonColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: red, width: 1.5),
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
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                    String email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      Navigator.pop(context);
                    } else {}
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
        showEmailBottomSheet(context);
      },
      child: const Text(
        'Forgot Password..?',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
