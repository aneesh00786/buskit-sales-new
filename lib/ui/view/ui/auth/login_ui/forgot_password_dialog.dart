import 'dart:async';
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:flutter/material.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final String email;

  const ForgotPasswordDialog({super.key, required this.email});

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int _resendTimer = 30;
  late Timer _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    if (widget.email.isNotEmpty) {
      emailController.text = widget.email;
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text("Forgot Password",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Positioned(
                    top: -5, right: -5, child: dialogCloseButton1(context, red))
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField("Enter your email", emailController),
            const SizedBox(height: 12),
            _buildTextField("Enter the OTP sent to your email", otpController),
            const SizedBox(height: 12),
            _buildTextField("Enter new password", newPasswordController,
                obscure: true),
            const SizedBox(height: 12),
            _buildTextField("Confirm new password", confirmPasswordController,
                obscure: true),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () async {
            //     String email = emailController.text.trim();
            //     String newPass = confirmPasswordController.text.trim();
            //     String otp = otpController.text.trim();
            //     await ApiWorker().resetPassword(email, newPass, int.parse(otp));
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: primaryColor,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: const Text(
            //     "Reset Password",
            //     style: TextStyle(color: white),
            //   ),
            // ),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String newPass = newPasswordController.text.trim();
                    String confirmPass = confirmPasswordController.text.trim();
                    String otp = otpController.text.trim();

                    // Email format validation
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(email)) {
                      showCustomToastDisplay(
                          context,
                          "Please enter a valid email address.",
                          red,
                          Icons.close);
                      return;
                    }

                    // OTP validation
                    if (otp.isEmpty) {
                      showCustomToastDisplay(
                          context, "Please enter the OTP.", red, Icons.close);
                      return;
                    }

                    // Password match validation
                    if (newPass != confirmPass) {
                      showCustomToastDisplay(
                          context, "Passwords do not match.", red, Icons.close);
                      return;
                    }

                    try {
                      final response =
                          await ApiWorker().resetPassword(email, newPass, otp);
                      final data = response.data;

                      if (data['status'] == true) {
                        showCustomToastDisplay(context,
                            "Password reset successful!", Colors.green, Icons.check);
                        Navigator.of(context).pop();
                      } else {
                        showCustomToastDisplay(
                            context,
                            data['message'] ?? "Password reset failed.",
                            red,
                            Icons.close);
                      }
                    } catch (e) {
                      showCustomToastDisplay(
                          context, "Error: ${e.toString()}", red, Icons.close);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(color: white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: _canResend
                      ? () {
                          String email = emailController.text.trim();
                          if (email.isNotEmpty) {
                            ApiWorker().sendOtp(email);
                            log("Email submitted: $email");
                          }
                          _startResendTimer();
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor: _canResend
                        ? primaryColor.withOpacity(0.2)
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _canResend ? "Resend OTP" : "Resend OTP in $_resendTimer s",
                    style: TextStyle(
                      color: _canResend ? primaryColor : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 10),
            const Text("OTP sent successfully!",
                style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: hint,
        // hintText: hint,
        enabled: hint != "Enter your email",
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
