import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/registration_webview.dart';
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
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginRightSideWidget extends StatefulWidget {
  final LoginController loginController;

  const LoginRightSideWidget({super.key, required this.loginController});

  @override
  State<LoginRightSideWidget> createState() => _LoginRightSideWidgetState();
}

class _LoginRightSideWidgetState extends State<LoginRightSideWidget> {
  @override
  Widget build(BuildContext context) {
    final appDimensions = AppDimensions.instance;

    final statusCode = widget.loginController.loginResponce?.statusCode;

    return Container(
      padding: nkSymmetricPadding(vertical: 0),
      color: Colors.white,
      child: Center(
        child: Form(
          key: widget.loginController.formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      Assets.pngThriveWoo,
                      height: appDimensions.width / 5.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: widget.loginController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.alternate_email_outlined,
                          color: primaryColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: (statusCode == 422 || statusCode == 409)
                              ? Colors.red
                              : Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: (statusCode == 422 || statusCode == 409)
                              ? Colors.red
                              : primaryButtonColor,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!NkCommonFunction.chckEmailValidation(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  if (statusCode == 422 || statusCode == 409)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text('Incorrect E-mail',
                          style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
                    Obx(() => TextFormField(
            controller: widget.loginController.passwordController,
            obscureText: widget.loginController.isPasswordVisible.value, // This is now reactive!
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(
                EneftyIcons.lock_2_outline,
                color: primaryColor,
              ),
           
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: widget.loginController.loginResponce?.statusCode == 401
                            ? Colors.red
                            : Colors.grey,
                    width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: widget.loginController.loginResponce?.statusCode == 401
                            ? Colors.red
                            : primaryButtonColor,
                    width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              // Moved the icon logic directly here (Best Practice)
              suffixIcon: IconButton(
                onPressed: () {
                  widget.loginController.isPasswordVisible.value = 
                      !widget.loginController.isPasswordVisible.value;
                },
                icon: Icon(
                  widget.loginController.isPasswordVisible.value
                      ? EneftyIcons.eye_slash_outline
                      : EneftyIcons.eye_outline,
                  color: primaryColor,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Password';
              }
              return null;
            },
          )),
                  // TextFormField(
                  //   controller: widget.loginController.passwordController,
                  //   obscureText: widget.loginController.isPasswordVisible.value,
                  //   decoration: InputDecoration(
                  //     labelText: 'Password',
                  //     prefixIcon: const Icon(EneftyIcons.lock_2_outline,
                  //         color: primaryColor),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //       borderSide: BorderSide(
                  //         color: (statusCode == 401) ? Colors.red : Colors.grey,
                  //         width: 1.5,
                  //       ),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //       borderSide: BorderSide(
                  //         color: (statusCode == 401)
                  //             ? Colors.red
                  //             : primaryButtonColor,
                  //         width: 1.5,
                  //       ),
                  //     ),
                  //     errorBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //       borderSide:
                  //           const BorderSide(color: Colors.red, width: 1.5),
                  //     ),
                  //     suffixIcon: widget.loginController.getIsPasswordVisible,
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your password';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  if (statusCode == 401)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text('Incorrect Password',
                          style: TextStyle(color: Colors.red)),
                    ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: ForgotPasswordScreen(),
                  ),
                  nkMediumSizeBox(),
                  Row(
                    children: [
                      Expanded(child: _buildLoginButton(context)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildRegisterButton(context)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return NkLoadingButton(
      isRoundedCorner: true,
      buttonText: singIn,
      onPressed: () async {
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
    );
  }
// Ensure you import the new screen
// import 'registration_webview.dart'; 

Widget _buildRegisterButton(BuildContext context) {
  return NkLoadingButton(
    isRoundedCorner: true,
    buttonText: "Register",
    onPressed: () async {
      // 1. Define the URL
      final String fullUrlString = '${ApiConstants.baseUrl1}/register_admin';

      // 2. Navigate to the WebView screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RegistrationWebView(url: fullUrlString),
        ),
      );
    },
    btnController: widget.loginController.registerButtonController,
  );
}
  // Widget _buildRegisterButton(BuildContext context) {
  //   return NkLoadingButton(
  //     isRoundedCorner: true,
  //     buttonText: "Register",
  //     onPressed: () async {
  //       final String fullUrlString = '${ApiConstants.baseUrl1}/register_admin';
  //       final Uri url = Uri.parse(fullUrlString);

  //       if (!await launchUrl(
  //         url,
  //         mode: LaunchMode.inAppWebView,
  //       )) {
  //         debugPrint('Could not launch $url');

  //         if (context.mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //                 content: Text('Could not open the registration page.')),
  //           );
  //         }
  //       }
  //     },
  //     btnController: widget.loginController.registerButtonController,
  //   );
  // }
  // Widget _buildRegisterButton(BuildContext context) {
  //   return NkLoadingButton(
  //     isRoundedCorner: true,
  //     buttonText: "Register",
  //     onPressed: () async {
  //       registerDialog(context, widget.loginController);
  //     },
  //     btnController: widget.loginController.registerButtonController,
  //   );
  // }
}
