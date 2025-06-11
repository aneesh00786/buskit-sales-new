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
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/policy_aggrement.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/register_phone_number_field.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/register_textfield.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/warning_message.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> registerDialog(
  BuildContext context,
  LoginController loginController,
) {
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
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
              key: registerFormKey,
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 2, top: 8),
                                child: Icon(
                                  EneftyIcons.close_circle_outline,
                                  size: 25,
                                ),
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
                                    if (registerFormKey.currentState
                                            ?.validate() ??
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
                                        Navigator.pop(context);
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
