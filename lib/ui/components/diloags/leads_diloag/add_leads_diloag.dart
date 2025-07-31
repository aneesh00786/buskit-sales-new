// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:busskit_salesexecutive/common/file_size_checker.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/widgets/custom_button_leads.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/widgets/input_field_widget.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddLeadsScreen extends StatefulWidget {
  final LeadsController leadsController;

  const AddLeadsScreen({Key? key, required this.leadsController})
      : super(key: key);

  @override
  _AddLeadsScreenState createState() => _AddLeadsScreenState();
}

class _AddLeadsScreenState extends State<AddLeadsScreen> {
  File? leadsImage;
  bool sameAsAbove = false;
  bool isAddingLeads = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        leadsImage = imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);

    return SizedBox(
      height: isSmallScreen ? 29 : 38,
      width: isSmallScreen ? 87 : 100,
      child: CustomButtonLeads(
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Dialog(
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: const Color.fromARGB(255, 237, 238, 243),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        side: BorderSide.none,
                      ),
                      elevation: 24.0,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                color: Color(0xFF7578EA),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Add Leads',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  dialogCloseButton1(context, red),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  buildInputField(
                                      widget.leadsController
                                          .businessNameController,
                                      'Business Name',
                                      Assets.icBusiness),
                                  buildInputField(
                                      widget.leadsController.addressController,
                                      'Address',
                                      Assets.icLocation),

                                  // Town, State, Zipcode Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildInputField(
                                            widget
                                                .leadsController.townController,
                                            'City or Suburb',
                                            Assets.icCity),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .stateController,
                                            'State',
                                            Assets.icState),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .zipcodeController,
                                            'Zip/Post/Pin Code',
                                            Assets.icZipcode),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .mobileNoController,
                                            'Mobile Number',
                                            Assets.icMobile),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .emailController,
                                            'Email',
                                            Assets.icEmail),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .telephoneController,
                                            'Business Reg.No',
                                            Assets.icBusinessReg),
                                      ),
                                    ],
                                  ),

                                  // Contact Details Section
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 6.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Contact Details',
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .fullnameController,
                                            'Contact Person',
                                            Assets.icUser),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .businessContactController,
                                            'Contact Number',
                                            Assets.icPhone),
                                      ),
                                    ],
                                  ),

                                  // Delivery Address Checkbox
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: Row(
                                      children: [
                                        const Text('Delivery Address    ',
                                            style: TextStyle(fontSize: 18)),
                                        Checkbox(
                                          value: sameAsAbove,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              sameAsAbove = value ?? false;
                                              if (sameAsAbove) {
                                                widget
                                                        .leadsController
                                                        .deliveryAddressController
                                                        .text =
                                                    widget.leadsController
                                                        .addressController.text;
                                                widget
                                                        .leadsController
                                                        .deliveryTownController
                                                        .text =
                                                    widget.leadsController
                                                        .townController.text;
                                                widget
                                                        .leadsController
                                                        .deliveryStateController
                                                        .text =
                                                    widget.leadsController
                                                        .stateController.text;
                                                widget
                                                        .leadsController
                                                        .deliveryZipcodeController
                                                        .text =
                                                    widget.leadsController
                                                        .zipcodeController.text;
                                              } else {
                                                widget.leadsController
                                                    .deliveryAddressController
                                                    .clear();
                                                widget.leadsController
                                                    .deliveryTownController
                                                    .clear();
                                                widget.leadsController
                                                    .deliveryStateController
                                                    .clear();
                                                widget.leadsController
                                                    .deliveryZipcodeController
                                                    .clear();
                                              }
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 5),
                                        const Text('Same as Above'),
                                      ],
                                    ),
                                  ),

                                  buildInputField(
                                      widget.leadsController
                                          .deliveryAddressController,
                                      'Address',
                                      Assets.icLocation),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .deliveryTownController,
                                            'City or Suburb',
                                            Assets.icCity),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .deliveryStateController,
                                            'State',
                                            Assets.icState),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .deliveryZipcodeController,
                                            'Zip/Post/Pin Code',
                                            Assets.icZipcode),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        SizedBox(width: 16.0),
                                        Expanded(child: Text("Company logo"))
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade300,
                                                blurRadius: 6.0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: widget.leadsController
                                                .remarkController,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 18.0),
                                              labelText: 'Remark',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey.shade600),
                                              prefixIcon:
                                                  filledIcon(Assets.icRemark),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: const BorderSide(
                                                    color: Colors.blue,
                                                    width: 1.5),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade400,
                                                    width: 1.0),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Select Method'),
                                                    actions: [
                                                      IconButton(
                                                        onPressed: () async {
                                                          await pickImage(
                                                              ImageSource
                                                                  .camera);
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        icon: const Icon(
                                                            EneftyIcons
                                                                .camera_outline),
                                                      ),
                                                      IconButton(
                                                        onPressed: () async {
                                                          await pickImage(
                                                              ImageSource
                                                                  .gallery);
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        icon: const Icon(
                                                            EneftyIcons
                                                                .gallery_bold),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    blurRadius: 6.0,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 18.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      color:
                                                          Colors.grey.shade600,
                                                      size: 28.0,
                                                    ),
                                                    const SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: Text(
                                                        leadsImage == null
                                                            ? 'Pick an image from gallery'
                                                            : 'Image selected',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade700,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (leadsImage != null)
                                                      SizedBox(
                                                        height: 100,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  NkGeneralSize
                                                                      .nkCommonBorderRadius()),
                                                          child: leadsImage !=
                                                                  null
                                                              ? Image.file(
                                                                  leadsImage!,
                                                                  height: AppDimensions
                                                                          .instance!
                                                                          .height *
                                                                      0.2,
                                                                )
                                                              : nkSmallSizeBox(),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Submit Button
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: isAddingLeads
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    isAddingLeads = true;
                                                  });

                                                  bool isOnline =
                                                      await ConnectivityService()
                                                          .isOnline();
                                                  if (!isOnline) {
                                                    setState(() {
                                                      isAddingLeads = false;
                                                    });
                                                    showCustomToastDisplay(
                                                        context,
                                                        "You are Offline!",
                                                        red,
                                                        Icons.close);
                                                    return;
                                                  }

                                                  final fields = {
                                                    'Business Name': widget
                                                        .leadsController
                                                        .businessNameController,
                                                    'Address': widget
                                                        .leadsController
                                                        .addressController,
                                                    'Town': widget
                                                        .leadsController
                                                        .townController,
                                                    'State': widget
                                                        .leadsController
                                                        .stateController,
                                                    'Zip Code': widget
                                                        .leadsController
                                                        .zipcodeController,
                                                    'Mobile Number': widget
                                                        .leadsController
                                                        .mobileNoController,
                                                    'Email': widget
                                                        .leadsController
                                                        .emailController,
                                                    'Telephone': widget
                                                        .leadsController
                                                        .telephoneController,
                                                    'Contact Person': widget
                                                        .leadsController
                                                        .fullnameController,
                                                    'Contact Number': widget
                                                        .leadsController
                                                        .businessContactController,
                                                    'Delivery Address': widget
                                                        .leadsController
                                                        .deliveryAddressController,
                                                    'Delivery Town': widget
                                                        .leadsController
                                                        .deliveryTownController,
                                                    'Delivery State': widget
                                                        .leadsController
                                                        .deliveryStateController,
                                                    'Delivery Zip Code': widget
                                                        .leadsController
                                                        .deliveryZipcodeController,
                                                    'Remark': widget
                                                        .leadsController
                                                        .remarkController,
                                                  };

                                                  // Check for missing field
                                                  for (var entry
                                                      in fields.entries) {
                                                    if (entry.value.text
                                                        .trim()
                                                        .isEmpty) {
                                                      setState(() {
                                                        isAddingLeads = false;
                                                      });
                                                      showCustomToastDisplay(
                                                        context,
                                                        '${entry.key} is required',
                                                        red,
                                                        Icons.close,
                                                      );
                                                      return;
                                                    }
                                                  }

                                                  // Validate phone numbers
                                                  final phoneFields = {
                                                    'Mobile Number': widget
                                                        .leadsController
                                                        .mobileNoController,
                                                    'Contact Number': widget
                                                        .leadsController
                                                        .businessContactController,
                                                  };

                                                  for (var entry
                                                      in phoneFields.entries) {
                                                    final phone =
                                                        entry.value.text.trim();
                                                    if (!RegExp(r'^\d{10}$')
                                                        .hasMatch(phone)) {
                                                      setState(() {
                                                        isAddingLeads = false;
                                                      });
                                                      showCustomToastDisplay(
                                                        context,
                                                        '${entry.key} must be 10 digits',
                                                        red,
                                                        Icons.close,
                                                      );
                                                      return;
                                                    }
                                                  }

                                                  // Validate email
                                                  final email = widget
                                                      .leadsController
                                                      .emailController
                                                      .text
                                                      .trim();
                                                  final emailRegex = RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                                  if (!emailRegex
                                                      .hasMatch(email)) {
                                                    setState(() {
                                                      isAddingLeads = false;
                                                    });
                                                    showCustomToastDisplay(
                                                      context,
                                                      'Invalid Email format',
                                                      red,
                                                      Icons.close,
                                                    );
                                                    return;
                                                  }

                                                  // Check image
                                                  if (leadsImage == null) {
                                                    setState(() {
                                                      isAddingLeads = false;
                                                    });
                                                    showCustomToastDisplay(
                                                      context,
                                                      'Image is required',
                                                      red,
                                                      Icons.close,
                                                    );
                                                    return;
                                                  }

                                                  if (leadsImage != null) {
                                                    bool isValid =
                                                        await isFileSizeWithinLimit(
                                                            leadsImage!);
                                                    if (!isValid) {
                                                      setState(() {
                                                        isAddingLeads = false;
                                                      });
                                                      showCustomToastDisplay(
                                                          context,
                                                          'File exceeds 1MB.',
                                                          red,
                                                          Icons.close);
                                                      return;
                                                    }
                                                  }

                                                  // All validations passed
                                                  try {
                                                    await widget.leadsController
                                                        .addLeads(
                                                      leadsImage: leadsImage!,
                                                      context: context,
                                                    );
                                                  } catch (error) {
                                                    setState(() {
                                                      isAddingLeads = false;
                                                    });
                                                    // Error handling is done in the controller
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.0)),
                                          ),
                                          child: isAddingLeads
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const Text('Add Leads',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        text: 'Leads',
      ),
    );
  }
}

Widget buildInputField(
    TextEditingController controller, String labelText, String icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Subtle background color
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, // Light shadow
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 18.0), // Modern padding
          labelText: labelText,
          labelStyle:
              TextStyle(color: Colors.grey.shade600), // Modern label color
          prefixIcon: filledIcon(icon),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.blue, width: 1.5), // Highlight color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
                color: Colors.grey.shade400, width: 1.0), // Neutral border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(
                color: Colors.red, width: 1.5), // Error styling
          ),
          filled: true,
          fillColor: Colors.white, // Background inside the text field
        ),
      ),
    ),
  );
}

class CustomButtonLeads extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  const CustomButtonLeads({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: primaryColor,
                fontSize: isSmallScreen ? 7 : 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: isSmallScreen ? 10 : 14,
            ),
          ],
        ),
      ),
    );
  }
}
