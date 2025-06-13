// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/file_size_checker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditLeadsDialog extends StatefulWidget {
  final LeadCustomerData leadCustomerData;
  final LeadsController leadsController;
  const EditLeadsDialog({
    super.key,
    required this.leadCustomerData,
    required this.leadsController,
  });
  @override
  State<EditLeadsDialog> createState() => _EditLeadsDialogState();

  static Future<void> showEditLeadsDialog(BuildContext context,
      LeadCustomerData leadCustomerData, LeadsController leadsController) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EditLeadsDialog(
          leadCustomerData: leadCustomerData,
          leadsController: leadsController,
        );
      },
    );
  }
}

class _EditLeadsDialogState extends State<EditLeadsDialog> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController businessNameController =
        TextEditingController(text: widget.leadCustomerData.businessName);

    TextEditingController mobilenoController =
        TextEditingController(text: widget.leadCustomerData.mobileno);
    TextEditingController emailController =
        TextEditingController(text: widget.leadCustomerData.email);
    TextEditingController townController =
        TextEditingController(text: widget.leadCustomerData.town);
    TextEditingController stateController =
        TextEditingController(text: widget.leadCustomerData.state);
    TextEditingController zipcodeController =
        TextEditingController(text: widget.leadCustomerData.zipcode.toString());
    TextEditingController addressController =
        TextEditingController(text: widget.leadCustomerData.address);
    TextEditingController fullnameController =
        TextEditingController(text: widget.leadCustomerData.fullname);
    TextEditingController businesscontactController =
        TextEditingController(text: widget.leadCustomerData.businessNo);
    TextEditingController remarkController =
        TextEditingController(text: widget.leadCustomerData.remark);
    String imageFile = '${widget.leadCustomerData.imageUrl}';

    File? leadsImage;

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          leadsImage = File(pickedFile.path); // Store selected image
        });
      }
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                  'Update Lead',
                  style: TextStyle(
                    color: white,
                    fontSize: 16,
                    fontFamily: 'Poppins_Regular',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: SizedBox(
                    width: 25.8,
                    height: 25.8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.5),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: businessNameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        labelText: 'Business Name',
                        prefixIcon: filledIcon(Assets.icBusiness),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        labelText: 'Address',
                        prefixIcon: filledIcon(Assets.icLocation),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextField(
                              controller: townController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 16.0,
                                ),
                                labelText: 'City or Suburb',
                                prefixIcon: filledIcon(Assets.icCity),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: stateController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'State',
                              prefixIcon: filledIcon(Assets.icState),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: zipcodeController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Zip/Post/Pin Code',
                              prefixIcon: filledIcon(Assets.icZipcode),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: mobilenoController,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Mobile Number',
                              prefixIcon: filledIcon(Assets.icMobile),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Email',
                              prefixIcon: filledIcon(Assets.icEmail),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: fullnameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Contact Person Name',
                              prefixIcon: filledIcon(Assets.icUser),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TextField(
                            controller: businesscontactController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Contact Number',
                              prefixIcon: filledIcon(Assets.icPhone),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        // Removed the nested Expanded here
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextField(
                              controller: remarkController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 16.0,
                                ),
                                labelText: 'Remark',
                                prefixIcon: filledIcon(Assets.icRemark),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Select Method'),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        pickImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(
                                          EneftyIcons.camera_outline),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        pickImage(ImageSource.gallery);
                                        Navigator.of(context).pop();
                                      },
                                      icon:
                                          const Icon(EneftyIcons.gallery_bold),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.0),
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
                                      leadsImage == null && imageFile.isEmpty
                                          ? 'Pick an image from gallery'
                                          : 'Image selected',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          NkGeneralSize.nkCommonBorderRadius()),
                                      child: leadsImage != null
                                          ? Image.file(
                                              leadsImage!,
                                              height: AppDimensions
                                                      .instance.height *
                                                  0.2,
                                              fit: BoxFit.cover,
                                            )
                                          : MyNetworkImage(
                                              imageUrl: imageFile,
                                              height: AppDimensions
                                                      .instance.height *
                                                  0.2,
                                                  errorWidget:(context, url, error) =>  CircularProgressIndicator(),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (businessNameController.text.isEmpty ||
                              addressController.text.isEmpty ||
                              townController.text.isEmpty ||
                              stateController.text.isEmpty ||
                              zipcodeController.text.isEmpty ||
                              mobilenoController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              fullnameController.text.isEmpty ||
                              businesscontactController.text.isEmpty ||
                              remarkController.text.isEmpty) {
                            showCustomToastDisplay(context,
                                'All fields must be filled.', red, Icons.close);
                            return;
                          }

                          if (mobilenoController.text.length != 10 ||
                              businesscontactController.text.length != 10) {
                            showCustomToastDisplay(
                                context,
                                'Phone numbers must be exactly 10 digits.',
                                red,
                                Icons.close);
                            return;
                          }

                          if (leadsImage != null) {
                            bool isValid =
                                await isFileSizeWithinLimit(leadsImage!);
                            if (!isValid) {
                              showCustomToastDisplay(context,
                                  'File exceeds 1MB.', red, Icons.close);
                              return;
                            }
                          }

                          final sendData = {
                            "businessname": businessNameController.text,
                            "address": addressController.text,
                            "town": townController.text,
                            "state": stateController.text,
                            "zipcode": int.tryParse(zipcodeController.text),
                            "mobileno": int.tryParse(mobilenoController.text),
                            "email": emailController.text,
                            "fullname": fullnameController.text,
                            "businesscontact":
                                int.tryParse(businesscontactController.text),
                            "remark": remarkController.text,
                            "customer_id": widget.leadCustomerData.customerId,
                            "oldimage_url": widget.leadCustomerData.imageUrl,
                            "companyId":
                                SessionHelper.loginSavedData?.company_id ?? 0,
                          };

                          await widget.leadsController
                              .updateLeads(sendData, leadsImage);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
