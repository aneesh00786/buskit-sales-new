import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/view/register_plan_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/address_search_widget.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> registerDialog(BuildContext context,
    LoginController loginController, GlobalKey<FormState> formKey) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: StatefulBuilder(builder: (context, setState) {
          bool isPhoneNumberValid =
              loginController.phoneNumberController.text.length == 10;

          loginController.phoneNumberController.addListener(() {
            setState(() {
              isPhoneNumberValid =
                  loginController.phoneNumberController.text.length == 10;
            });
          });
          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 10,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: const BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50))),
                    ),
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
                    RegisterTextField(
                      hinttext: "Business Name",
                      focusNode: loginController.businessEmailFocusNode,
                      icon: const Icon(EneftyIcons.buildings_outline),
                      textEditingController:
                          loginController.businessNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Business name';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    AddressSearchField(
                      hinttext: 'Address',
                      textEditingController: loginController.addressController,
                      townController: loginController.townController,
                      stateController: loginController.stateController,
                      countryController: loginController.countryController,
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
                      textEditingController: loginController.countryController,
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
                    RegisterTextField(
                      hinttext: "Phone Number",
                      focusNode: loginController.phoneNumberFocusNode,
                      textEditingController:
                          loginController.phoneNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (value.length < 10) {
                          return 'Please enter your 10 didgit phone number';
                        }
                        return null;
                      },
                      showSuffixIcon: isPhoneNumberValid,
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
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      loginController: loginController,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    NkLoadingButton(
                      isRoundedCorner: true,
                      buttonText: "Register",
                      onPressed: () async {
                        // final otp = loginController.otpController.text;
                        // if (formKey.currentState?.validate() ?? false) {
                        //   if (loginController.validateOtp(otp)) {
                        //     await ApiWorker().insertAdmin(
                        //       address: loginController.addressController.text,
                        //       country: loginController.countryController.text,
                        //       email:
                        //           loginController.businessEmailController.text,
                        //       name: loginController.businessNameController.text,
                        //       fullPhoneNo:
                        //           loginController.phoneNumberController.text,
                        //       password: '1234',
                        //       state: loginController.stateController.text,
                        //       town: loginController.townController.text,
                        //       zipcode: loginController.postCodeController.text,
                        //     );
                        //     final prefs = await SharedPreferences.getInstance();
                        //     await prefs.setString('selectedCountry',
                        //         loginController.countryController.text);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterPlanScreen(),
                              ),
                            );
                            log('Form is valid, email verified, and OTP is correct.');
                        //   }
                        // } else {
                        //   log("Form validation failed.");
                        // }
                      },
                      btnController: loginController.registerController,
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

class BusinessEmailField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hinttext;
  final String? Function(String?) validator;
  final LoginController loginController;

  const BusinessEmailField({
    Key? key,
    required this.textEditingController,
    required this.hinttext,
    required this.validator,
    required this.loginController,
  }) : super(key: key);

  @override
  _BusinessEmailFieldState createState() => _BusinessEmailFieldState();
}

class _BusinessEmailFieldState extends State<BusinessEmailField> {
  bool showVerifyButton = false;
  bool isEmailVerified = false;
  String successMessage = "";
  RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

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
                  child: SizedBox(
                    width: 50,
                    child: Expanded(
                      child: NkLoadingButton(
                        btnController: _btnController,
                        buttonText: 'verify',
                        color: primaryColor,
                        isRoundedCorner: true,
                        fontColor: white,
                        onPressed: () async {
                          await widget.loginController
                              .verifyEmail(widget.textEditingController.text);
                          print('Verify button clicked!');
                        },
                      ),
                    ),
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
