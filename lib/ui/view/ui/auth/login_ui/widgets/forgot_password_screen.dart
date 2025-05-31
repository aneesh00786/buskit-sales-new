import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/forgot_password_dialog.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  void showEmailBottomSheet(BuildContext context) {
    final emailController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      content: "Enter your registered E-mail.",
                      fontSize: 20,
                    ),
                  ),
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
                        borderSide: const BorderSide(
                            color: primaryButtonColor, width: 1.5),
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
                  isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                          height: 60,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              String email =
                                  emailController.text.toLowerCase().trim();
                              if (email.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  final response =
                                      await ApiWorker().sendOtp(email);
                                  final data = response.data;
                                  showCustomToastDisplay(
                                    context,
                                    data['message'] ?? "OTP sent.",
                                    data['status'] == true ? Colors.green : red,
                                    data['status'] == true
                                        ? Icons.check
                                        : Icons.close,
                                  );
                                  if (data['status'] == true) {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          ForgotPasswordDialog(email: email),
                                    );
                                  }
                                } catch (e) {
                                  showCustomToastDisplay(
                                    context,
                                    "Error sending OTP: ${e.toString()}",
                                    red,
                                    Icons.close,
                                  );
                                } finally {
                                  if (context.mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              } else {
                                showCustomToastDisplay(
                                  context,
                                  "Please enter your email.",
                                  red,
                                  Icons.close,
                                );
                              }
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