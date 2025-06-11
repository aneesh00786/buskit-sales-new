// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/email_verify_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/register_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessEmailField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hinttext;
  final String? Function(String?) validator;
  final LoginController loginController;

  const BusinessEmailField({
    super.key,
    required this.textEditingController,
    required this.hinttext,
    required this.validator,
    required this.loginController,
  });

  @override
  _BusinessEmailFieldState createState() => _BusinessEmailFieldState();
}

class _BusinessEmailFieldState extends State<BusinessEmailField> {
  bool showVerifyButton = false;
  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      setState(() {
        showVerifyButton = widget.textEditingController.text.isNotEmpty;
        widget.loginController.successMessage.value = "";
        widget.loginController.isEmailVerified.value = false;
      });
    });
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RegisterTextField(
                hinttext: widget.hinttext,
                textEditingController: widget.textEditingController,
                validator: widget.validator,
              ),
            ),
            if (showVerifyButton)
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: VerifyButton(
                    loginController: widget.loginController,
                    textEditingController: widget.textEditingController,
                  )),
          ],
        ),
        Obx(() {
          final isOtpSent = widget.loginController.isOtpSent.value;
          final isVerified = widget.loginController.isEmailVerified.value;
          final message = widget.loginController.successMessage.value;
          if (isOtpSent) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!isVerified)
                    Row(
                      children: [
                        Expanded(
                          child: RegisterTextField(
                            hinttext: "OTP",
                            textEditingController:
                                widget.loginController.otpController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter OTP';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            final otp =
                                widget.loginController.otpController.text;
                            final isValid =
                                widget.loginController.validateOtp(otp);
                            if (isValid) {
                              Get.showSnackbar(
                                GetSnackBar(
                                  message: widget
                                      .loginController.successMessage.value,
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              errorSnackbar(
                                  widget.loginController.successMessage.value);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
