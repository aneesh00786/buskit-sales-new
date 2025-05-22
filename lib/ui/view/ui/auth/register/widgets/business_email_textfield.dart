// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/email_verify_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

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
  bool isEmailVerified = false;
  String successMessage = "";

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(() {
      setState(() {
        showVerifyButton = widget.textEditingController.text.isNotEmpty;
        successMessage = "";
        isEmailVerified = false;
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
          if (widget.loginController.successMessage ==
              "Your email verification is successful, and an OTP has been sent to your email.") {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Text(
                    widget.loginController.successMessage.value,
                    style: TextStyle(
                      color: widget.loginController.successMessage.value ==
                              "Your email verification is successful, and an OTP has been sent to your email."
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RegisterTextField(
                    hinttext: "OTP",
                    textEditingController: widget.loginController.otpController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      return null;
                    },
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