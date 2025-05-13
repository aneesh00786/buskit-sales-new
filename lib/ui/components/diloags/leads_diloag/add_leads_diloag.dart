

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/widgets/custom_button_leads.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/widgets/input_field_widget.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddLeadsScreen extends StatefulWidget {
  final LeadsController leadsController;

  const AddLeadsScreen({super.key, required this.leadsController});

  @override
  // ignore: library_private_types_in_public_api
  _AddLeadsScreenState createState() => _AddLeadsScreenState();
}

class _AddLeadsScreenState extends State<AddLeadsScreen> {
  File? leadsImage;
  bool sameAsAbove = false;

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
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Dialog(
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
                            padding: const EdgeInsets.all(4.8),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Add Leads',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17.5),
                                ),
                                dialogCloseButton1(context, Colors.red),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                buildInputField(
                                    widget
                                        .leadsController.businessNameController,
                                    'Business Name',
                                    Icons.business),
                                buildInputField(
                                    widget.leadsController.addressController,
                                    'Address',
                                    Icons.home),

                                // Town, State, Zipcode Row
                                Row(
                                  children: [
                                    Expanded(
                                        child: buildInputField(
                                            widget
                                                .leadsController.townController,
                                            'Town',
                                            Icons.location_city)),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .stateController,
                                            'State',
                                            Icons.map)),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .zipcodeController,
                                            'Zip Code',
                                            Icons.pin_drop)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildInputField(
                                          widget.leadsController
                                              .mobileNoController,
                                          'Mobile Number',
                                          Icons.phone),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: buildInputField(
                                          widget
                                              .leadsController.emailController,
                                          'Email',
                                          Icons.email),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: buildInputField(
                                          widget.leadsController
                                              .telephoneController,
                                          'Telephone',
                                          Icons.phone_in_talk),
                                    ),
                                  ],
                                ),

                                // Contact Details Section
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.0),
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
                                            Icons.person)),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                        child: buildInputField(
                                            widget.leadsController
                                                .businessContactController,
                                            'Contact Number',
                                            Icons.phone)),
                                  ],
                                ),

                                // Delivery Address Checkbox
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
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
                                    'Delivery Address',
                                    Icons.location_on),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildInputField(
                                          widget.leadsController
                                              .deliveryTownController,
                                          'Delivery Town',
                                          Icons.location_city),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: buildInputField(
                                          widget.leadsController
                                              .deliveryStateController,
                                          'Delivery State',
                                          Icons.map),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: buildInputField(
                                          widget.leadsController
                                              .deliveryZipcodeController,
                                          'Delivery Zip Code',
                                          Icons.pin_drop),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          controller: widget
                                              .leadsController.remarkController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 18.0),
                                            labelText: 'Remark',
                                            labelStyle: TextStyle(
                                                color: Colors.grey.shade600),
                                            prefixIcon: Icon(Icons.comment,
                                                color: Colors.grey.shade600),
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
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('Select Method'),
                                                  actions: [
                                                    IconButton(
                                                      onPressed: () {
                                                        pickImage(
                                                            ImageSource.camera);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: const Icon(EneftyIcons
                                                          .camera_outline),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        pickImage(
                                                            ImageSource.gallery);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: const Icon(EneftyIcons
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
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 18.0,
                                              ),
                                              child: Row(
                                                
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    color: Colors.grey.shade600,
                                                    size: 28.0,
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Expanded(
                                                    child: Text(
                                                      leadsImage == null
                                                          ? 'Pick an image from gallery'
                                                          : 'Image selected',
                                                      style: TextStyle(
                                                        color:
                                                            Colors.grey.shade700,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (leadsImage != null)
                                                    SizedBox(
                                                      height: 100,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(NkGeneralSize
                                                                .nkCommonBorderRadius()),
                                                        child: leadsImage != null
                                                            ? Image.file(
                                                                leadsImage!,
                                                                height: AppDimensions
                                                                        .instance
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (leadsImage != null) {
                                            widget.leadsController.addLeads(
                                              leadsImage: leadsImage!,
                                              context: context,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0)),
                                        ),
                                        child: const Text('Add Leads',
                                            style:
                                                TextStyle(color: Colors.white)),
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




