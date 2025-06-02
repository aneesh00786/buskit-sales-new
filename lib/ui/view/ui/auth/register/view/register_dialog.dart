// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/view/register_plan_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/address_search_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/business_email_textfield.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/register_phone_number_field.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/register_textfield.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/warning_message.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<dynamic> registerDialog(BuildContext context,
    LoginController loginController, GlobalKey<FormState> formKey) {
  String privacyAgreement = "false";
  String refundAgreement = "false";
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: StatefulBuilder(builder: (context, setState) {
          bool isAgreed =
              privacyAgreement == "true" && refundAgreement == "true";
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: const BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(50))),
                            ),
                          ),
                          InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomText(
                              content: "Register",
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "Business Name",
                                  focusNode:
                                      loginController.businessEmailFocusNode,
                                  icon:
                                      const Icon(EneftyIcons.buildings_outline),
                                  textEditingController:
                                      loginController.businessNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Business name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "Company Reg No :",
                                  icon:
                                      const Icon(EneftyIcons.buildings_outline),
                                  textEditingController:
                                      loginController.companyRegController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Company registration number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          AddressSearchField(
                            hinttext: 'Address',
                            textEditingController:
                                loginController.addressController,
                            townController: loginController.townController,
                            stateController: loginController.stateController,
                            postCodeController:
                                loginController.postCodeController,
                            countryController:
                                loginController.countryController,
                            currentFocusNode: loginController.addressFocusNode,
                            nextFocusNode: loginController.townFocusNode,
                            loginController: loginController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "Town",
                                  focusNode: loginController.townFocusNode,
                                  textEditingController:
                                      loginController.townController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Town';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "State",
                                  focusNode: loginController.stateFocusNode,
                                  textEditingController:
                                      loginController.stateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your state';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "Post Code",
                                  focusNode: loginController.postCodeFocusNode,
                                  textEditingController:
                                      loginController.postCodeController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Post code';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RegisterTextField(
                            hinttext: "Country",
                            focusNode: loginController.countryFocusNode,
                            textEditingController:
                                loginController.countryController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your country name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "Admin First Name",
                                  textEditingController:
                                      loginController.adminFirstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RegisterTextField(
                                  hinttext: "Admin Last Name",
                                  textEditingController:
                                      loginController.adminLastnameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RegisterPhoneNumberField(
                            textEditingController:
                                loginController.phoneNumberController,
                            focusNode: loginController.phoneNumberFocusNode,
                            loginController: loginController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          BusinessEmailField(
                            textEditingController:
                                loginController.businessEmailController,
                            hinttext: "Business Email",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              if (!value.contains('@gmail.com')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                            loginController: loginController,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          warningMessage(),
                          const SizedBox(
                            height: 30,
                          ),
                          PolicyAgreementWidget(
                            onPrivacyChanged: (agreed) {
                              setState(() {
                                privacyAgreement = agreed.toString();
                              });
                            },
                            onRefundChanged: (agreed) {
                              setState(() {
                                refundAgreement = agreed.toString();
                              });
                            },
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          NkLoadingButton(
                            isRoundedCorner: false,
                            buttonText: "Register",
                            onPressed: isAgreed
                                ? () async {
                                    final otp =
                                        loginController.otpController.text;
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      final fullPhoneNo =
                                          '${loginController.phoneCode}${loginController.phoneNumberController.text}';
                                      log('Full Phone Number $fullPhoneNo');
                                      if (loginController.validateOtp(otp)) {
                                        await ApiWorker().insertAdmin(
                                            address: loginController
                                                .addressController.text,
                                            country: loginController
                                                .countryController.text,
                                            email: loginController
                                                .businessEmailController.text,
                                            name: loginController
                                                .businessNameController.text,
                                            fullPhoneNo: fullPhoneNo,
                                            password: '1234',
                                            state: loginController
                                                .stateController.text,
                                            town: loginController
                                                .townController.text,
                                            zipcode: loginController
                                                .postCodeController.text,
                                            adminFname: loginController
                                                .adminFirstNameController.text,
                                            adminLname: loginController
                                                .adminLastnameController.text,
                                            regNo: loginController
                                                .companyRegController.text,
                                            privacy: privacyAgreement,
                                            refund: refundAgreement);
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setString(
                                            'selectedCountry',
                                            loginController
                                                .countryController.text);
                                        loginController.clearAllFields();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPlanScreen(),
                                          ),
                                        );
                                        log('Form is valid, email verified, and OTP is correct.');
                                      } else {
                                        errorSnackbar(
                                            "Please verify the email.");
                                      }
                                    
                                    } else {
                                      log("Form validation failed.");
                                    }
                                    
                                  }
                                : null,
                            btnController: loginController.registerController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    },
  );
}

class PolicyAgreementWidget extends StatefulWidget {
  final void Function(bool agreed) onPrivacyChanged;
  final void Function(bool agreed) onRefundChanged;

  const PolicyAgreementWidget({
    super.key,
    required this.onPrivacyChanged,
    required this.onRefundChanged,
  });

  @override
  _PolicyAgreementWidgetState createState() => _PolicyAgreementWidgetState();
}

class _PolicyAgreementWidgetState extends State<PolicyAgreementWidget> {
  bool _agreePrivacy = false;
  bool _agreeRefund = false;

  void _launchURLInDialog(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    final ValueNotifier<bool> isLoading = ValueNotifier(true);

    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => isLoading.value = true,
          onPageFinished: (_) => isLoading.value = false,
        ),
      )
      ..loadRequest(Uri.parse(url));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, loading, child) {
                    if (loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _updateAgreement(bool? newValue, bool isPrivacy) {
    setState(() {
      if (isPrivacy) {
        _agreePrivacy = newValue ?? false;
        widget.onPrivacyChanged(_agreePrivacy);
      } else {
        _agreeRefund = newValue ?? false;
        widget.onRefundChanged(_agreeRefund);
      }
    });
  }

  Widget _buildPolicyRow({
    required bool value,
    required Function(bool?) onChanged,
    required String policyText,
    required String url,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Agree to our '),
              GestureDetector(
                onTap: () => _launchURLInDialog(url),
                child: Text(
                  policyText,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
              const Text('.'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPolicyRow(
          value: _agreePrivacy,
          onChanged: (val) => _updateAgreement(val, true),
          policyText: 'Privacy Policy',
          url: 'https://thrivewoo.com/Privacy_policy',
        ),
        _buildPolicyRow(
          value: _agreeRefund,
          onChanged: (val) => _updateAgreement(val, false),
          policyText: 'Refund Policy',
          url: 'https://thrivewoo.com/Cancellation_policy',
        ),
      ],
    );
  }
}
