import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/view/register_plan_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/address_search_widget.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';

Future<dynamic> registerDialog(BuildContext context,
    LoginController loginController, GlobalKey<FormState> formKey) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
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
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RegisterTextField(
                          hinttext: "Town",
                          textEditingController: loginController.townController,
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
                    textEditingController:
                        loginController.phoneNumberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RegisterTextField(
                    hinttext: "Business Email",
                    textEditingController:
                        loginController.businessEmailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  NkLoadingButton(
                    isRoundedCorner: true,
                    buttonText: "Register",
                    onPressed: () async {
                      //if (formKey.currentState?.validate() ?? false) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPlanScreen(),
                            ));
                        print('Form is valid');
                      //}
                    },
                    btnController: loginController.registerController,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
