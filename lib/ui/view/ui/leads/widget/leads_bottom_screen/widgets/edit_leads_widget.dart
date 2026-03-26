// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/file_size_checker.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditLeadsDialog extends StatefulWidget {
  final String customerId;
  final LeadsController leadsController;

  const EditLeadsDialog({
    super.key,
    required this.customerId,
    required this.leadsController,
  });

  @override
  State<EditLeadsDialog> createState() => _EditLeadsDialogState();
}

class _EditLeadsDialogState extends State<EditLeadsDialog> {
  bool sameAsAbove = false;
  bool isUpdatingLeads = false;

  late TextEditingController businessNameController;
  late TextEditingController mobilenoController;
  late TextEditingController emailController;
  late TextEditingController businessRegNoController;
  late TextEditingController townController;
  late TextEditingController stateController;
  late TextEditingController zipcodeController;
  late TextEditingController addressController;

  late TextEditingController deliveryTownController;
  late TextEditingController deliveryStateController;
  late TextEditingController deliveryZipcodeController;
  late TextEditingController deliveryAddressController;
  late TextEditingController fullnameController;
  late TextEditingController businesscontactController;
  late TextEditingController remarkController;
  late TextEditingController deliveryContactNumController;
  late String imageFile;
  File? leadsImage;

  @override
  void initState() {
    super.initState();
    widget.leadsController.isUpdating.value = false;
    businessNameController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.businessName);
    mobilenoController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.mobileno);
    emailController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.email);
    businessRegNoController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.tfn);
    townController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.town);
    stateController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.state);
    zipcodeController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.zipcode.toString());
    addressController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.address);

    deliveryTownController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.deliveryTown);
    deliveryStateController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.deliveryState);
    deliveryZipcodeController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.deliveryZipcode
            .toString());
    deliveryAddressController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.deliveryAddress);
    fullnameController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.fullname);
    businesscontactController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.businessNo);
    remarkController = TextEditingController(
        text: widget.leadsController.leadForUpdateData.remark);
    deliveryContactNumController = TextEditingController(
        text:
            widget.leadsController.leadForUpdateData.deliveryContact != null &&
                    widget.leadsController.leadForUpdateData.deliveryContact
                            .toString() !=
                        '0'
                ? widget.leadsController.leadForUpdateData.deliveryContact
                    .toString()
                : '');
    imageFile = widget.leadsController.leadForUpdateData.imageUrl ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    businessNameController.clear();
    mobilenoController.clear();
    emailController.clear();
    businessRegNoController.clear();
    townController.clear();
    stateController.clear();
    zipcodeController.clear();
    addressController.clear();
    deliveryTownController.clear();
    deliveryStateController.clear();
    deliveryZipcodeController.clear();
    deliveryAddressController.clear();
    fullnameController.clear();
    businesscontactController.clear();
    remarkController.clear();
    deliveryContactNumController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          leadsImage = File(pickedFile.path);
        });
      }
    }

    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
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
                dialogCloseButton1(context, red)
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Container(
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
                            contentPadding: const EdgeInsets.symmetric(
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
                            contentPadding: const EdgeInsets.symmetric(
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                                  contentPadding: const EdgeInsets.symmetric(
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
                                  contentPadding: const EdgeInsets.symmetric(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                maxLength: 10,
                                controller: mobilenoController,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
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
                                  contentPadding: const EdgeInsets.symmetric(
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TextField(
                                controller: businessRegNoController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 16.0,
                                  ),
                                  labelText: 'Business Reg.No',
                                  prefixIcon: filledIcon(Assets.icBusinessReg),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  contentPadding: const EdgeInsets.symmetric(
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
                                maxLength: 10,
                                controller: businesscontactController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                                  deliveryAddressController.text =
                                      addressController.text;
                                  deliveryTownController.text =
                                      townController.text;
                                  deliveryStateController.text =
                                      stateController.text;
                                  deliveryZipcodeController.text =
                                      zipcodeController.text;
                                  deliveryContactNumController.text =
                                      businesscontactController.text;
                                } else {
                                  deliveryAddressController.clear();
                                  deliveryTownController.clear();
                                  deliveryStateController.clear();
                                  deliveryZipcodeController.clear();
                                  deliveryContactNumController.clear();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          const Text('Same as Above'),
                        ],
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
                          controller: deliveryAddressController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
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
                                  controller: deliveryTownController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
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
                                controller: deliveryStateController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
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
                                controller: deliveryZipcodeController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextField(
                          controller: deliveryContactNumController,
                          maxLength: 10,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 16.0,
                            ),
                            labelText: 'Delivery Contact Number',
                            prefixIcon: filledIcon(Assets.icPhone),
                            border: InputBorder.none,
                            counterText: "",
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Select Method'),
                                      actions: [
                                        IconButton(
                                          onPressed: () async {
                                            await pickImage(ImageSource.camera);
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(
                                              EneftyIcons.camera_outline),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await pickImage(
                                                ImageSource.gallery);
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(
                                              EneftyIcons.gallery_bold),
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
                                          leadsImage == null &&
                                                  imageFile.isEmpty
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
                                              NkGeneralSize
                                                  .nkCommonBorderRadius()),
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
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return CircleAvatar(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.black26,
                                                      ),
                                                    );
                                                  },
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
                          if (!widget.leadsController.isUpdating.value)
                            ElevatedButton(
                              onPressed: isUpdatingLeads
                                  ? null
                                  : () async {
                                      setState(() {
                                        isUpdatingLeads = true;
                                      });

                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        if (mounted) {
                                          setState(() {
                                            isUpdatingLeads = false;
                                          });
                                        }
                                      });

                                      if (businessNameController.text.isEmpty ||
                                          addressController.text.isEmpty ||
                                          townController.text.isEmpty ||
                                          stateController.text.isEmpty ||
                                          zipcodeController.text.isEmpty ||
                                          mobilenoController.text.isEmpty ||
                                          emailController.text.isEmpty ||
                                          fullnameController.text.isEmpty ||
                                          businesscontactController
                                              .text.isEmpty) {
                                        setState(() {
                                          isUpdatingLeads = false;
                                        });
                                        showCustomToastDisplay(
                                            context,
                                            'All fields must be filled.',
                                            red,
                                            Icons.close);
                                        return;
                                      }

                                      if (mobilenoController.text.length !=
                                              10 ||
                                          businesscontactController
                                                  .text.length !=
                                              10) {
                                        setState(() {
                                          isUpdatingLeads = false;
                                        });
                                        showCustomToastDisplay(
                                            context,
                                            'Phone numbers must be exactly 10 digits.',
                                            red,
                                            Icons.close);
                                        return;
                                      }

                                      final email = emailController.text.trim();
                                      final emailRegex = RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                      if (!emailRegex.hasMatch(email)) {
                                        setState(() {
                                          isUpdatingLeads = false;
                                        });
                                        showCustomToastDisplay(
                                          context,
                                          'Invalid Email format',
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
                                            isUpdatingLeads = false;
                                          });
                                          showCustomToastDisplay(
                                              context,
                                              'File exceeds 1MB.',
                                              red,
                                              Icons.close);
                                          return;
                                        }
                                      }

                                      final sendData = {
                                        "businessname":
                                            businessNameController.text,
                                        "address": addressController.text,
                                        "town": townController.text,
                                        "state": stateController.text,
                                        "zipcode": int.tryParse(
                                            zipcodeController.text),
                                        "mobileno": int.tryParse(
                                            mobilenoController.text),
                                        "email": emailController.text,
                                        "tfn": businessRegNoController.text,
                                        "fullname": fullnameController.text,
                                        "businesscontact": int.tryParse(
                                            businesscontactController.text),
                                        "addressCheckbox":
                                            sameAsAbove ? "ON" : "OFF",
                                        "delivery_address":
                                            deliveryAddressController.text,
                                        "delivery_town":
                                            deliveryTownController.text,
                                        "delivery_state":
                                            deliveryStateController.text,
                                        "delivery_zipcode": int.tryParse(
                                            deliveryZipcodeController.text),
                                        "remark": remarkController.text,
                                        "delivery_contact": int.tryParse(
                                                deliveryContactNumController
                                                    .text
                                                    .trim()) ??
                                            0,
                                        "customer_id": widget.customerId,
                                        "oldimage_url": widget.leadsController
                                            .leadForUpdateData.imageUrl,
                                        "companyId": SessionHelper
                                                .loginSavedData?.company_id ??
                                            0,
                                      };

                                      try {
                                        var response = await ApiWorker()
                                            .updateCustomer(
                                                sendData, leadsImage);

                                        bool isSuccess = true;
                                        String errorMsg =
                                            "Failed to update lead";

                                        if (response != null) {
                                          String? serverMessage;
                                          try {
                                            if (response.data is Map) {
                                              serverMessage ??= response
                                                  .data['message']
                                                  ?.toString();
                                            }
                                          } catch (_) {}

                                          if (serverMessage != null &&
                                              serverMessage.trim().isEmpty) {
                                            serverMessage = null;
                                          }

                                          try {
                                            if (response.statusCode != null &&
                                                (response.statusCode! < 200 ||
                                                    response.statusCode! >=
                                                        300)) {
                                              isSuccess = false;
                                              errorMsg = serverMessage ??
                                                  "API Error: ${response.statusCode}";
                                              if (serverMessage == null) {
                                                try {
                                                  if (response.statusMessage !=
                                                          null &&
                                                      response.statusMessage
                                                          .toString()
                                                          .isNotEmpty) {
                                                    errorMsg = response
                                                        .statusMessage
                                                        .toString();
                                                  }
                                                } catch (_) {}
                                              }
                                            }
                                          } catch (_) {}

                                          try {
                                            if (response.data is Map) {
                                              var status =
                                                  response.data['status'];
                                              if (status == false ||
                                                  status == 0 ||
                                                  status == 'false') {
                                                isSuccess = false;
                                                errorMsg =
                                                    serverMessage ?? errorMsg;
                                              }
                                            }
                                          } catch (_) {}
                                        } else {
                                          isSuccess = false;
                                        }

                                        if (isSuccess) {
                                          widget.leadsController
                                              .loadLeadsCustomerData;
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          if (context.mounted) {
                                            showCustomToastDisplay(
                                                context,
                                                errorMsg,
                                                Colors.red,
                                                Icons.close);
                                          }
                                        }
                                      } catch (error) {
                                        if (context.mounted) {
                                          String errMsg = error.toString();
                                          final regex = RegExp(
                                              r'"message"\s*:\s*"([^"]+)"');
                                          final match =
                                              regex.firstMatch(errMsg);
                                          if (match != null &&
                                              match.groupCount >= 1) {
                                            errMsg = match.group(1)!;
                                          } else {
                                            errMsg = errMsg
                                                .replaceAll("Exception: ", "")
                                                .trim();
                                          }
                                          showCustomToastDisplay(context,
                                              errMsg, Colors.red, Icons.error);
                                        }
                                      } finally {
                                        setState(() {
                                          isUpdatingLeads = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              child: isUpdatingLeads
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Update',
                                      style: TextStyle(color: white),
                                    ),
                            ),
                          // ElevatedButton(
                          //   onPressed: isUpdatingLeads
                          //       ? null
                          //       : () async {
                          //           setState(() {
                          //             isUpdatingLeads = true;
                          //           });

                          //           if (businessNameController.text.isEmpty ||
                          //               addressController.text.isEmpty ||
                          //               townController.text.isEmpty ||
                          //               stateController.text.isEmpty ||
                          //               zipcodeController.text.isEmpty ||
                          //               mobilenoController.text.isEmpty ||
                          //               emailController.text.isEmpty ||
                          //               fullnameController.text.isEmpty ||
                          //               businesscontactController
                          //                   .text.isEmpty
                          //               ) {
                          //             setState(() {
                          //               isUpdatingLeads = false;
                          //             });
                          //             showCustomToastDisplay(
                          //                 context,
                          //                 'All fields must be filled.',
                          //                 red,
                          //                 Icons.close);
                          //             return;
                          //           }

                          //           if (mobilenoController.text.length !=
                          //                   10 ||
                          //               businesscontactController
                          //                       .text.length !=
                          //                   10) {
                          //             setState(() {
                          //               isUpdatingLeads = false;
                          //             });
                          //             showCustomToastDisplay(
                          //                 context,
                          //                 'Phone numbers must be exactly 10 digits.',
                          //                 red,
                          //                 Icons.close);
                          //             return;
                          //           }
                          //           final email = emailController.text.trim();
                          //   final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                          //   if (!emailRegex.hasMatch(email)) {
                          //     showCustomToastDisplay(
                          //       context,
                          //       'Invalid Email format',
                          //       red,
                          //       Icons.close,
                          //     );
                          //     return;
                          //   }

                          //           if (leadsImage != null) {
                          //             bool isValid =
                          //                 await isFileSizeWithinLimit(
                          //                     leadsImage!);
                          //             if (!isValid) {
                          //               setState(() {
                          //                 isUpdatingLeads = false;
                          //               });
                          //               showCustomToastDisplay(
                          //                   context,
                          //                   'File exceeds 1MB.',
                          //                   red,
                          //                   Icons.close);
                          //               return;
                          //             }
                          //           }

                          //           final sendData = {
                          //             "businessname":
                          //                 businessNameController.text,
                          //             "address": addressController.text,
                          //             "town": townController.text,
                          //             "state": stateController.text,
                          //             "zipcode": int.tryParse(
                          //                 zipcodeController.text),
                          //             "mobileno": int.tryParse(
                          //                 mobilenoController.text),
                          //             "email": emailController.text,
                          //             "tfn": businessRegNoController.text,
                          //             "fullname": fullnameController.text,
                          //             "businesscontact": int.tryParse(
                          //                 businesscontactController.text),
                          //             "addressCheckbox":
                          //                 sameAsAbove ? "ON" : "OFF",
                          //             "delivery_address":
                          //                 deliveryAddressController.text,
                          //             "delivery_town":
                          //                 deliveryTownController.text,
                          //             "delivery_state":
                          //                 deliveryStateController.text,
                          //             "delivery_zipcode": int.tryParse(
                          //                 deliveryZipcodeController.text),
                          //             "remark": remarkController.text,
                          //             "delivery_contact": int.tryParse(
                          //             deliveryContactNumController.text.trim()) ?? 0,
                          //             "customer_id": widget.customerId,
                          //             "oldimage_url": widget.leadsController
                          //                 .leadForUpdateData.imageUrl,
                          //             "companyId": SessionHelper
                          //                     .loginSavedData?.company_id ??
                          //                 0,
                          //           };
                          //           setState(() {
                          //     isUpdatingLeads = true;
                          //   });

                          //            try {
                          //     var response = await ApiWorker().updateCustomer(sendData, leadsImage);

                          //     bool isSuccess = true;
                          //     String errorMsg = "Failed to update lead";

                          //     if (response != null) {
                          //       String? serverMessage;
                          //       try {
                          //         if (response.data is Map) {
                          //           serverMessage ??= response.data['message']?.toString();
                          //         }
                          //       } catch (_) {}

                          //       if (serverMessage != null && serverMessage.trim().isEmpty) {
                          //         serverMessage = null;
                          //       }

                          //       try {
                          //         if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
                          //           isSuccess = false;
                          //           errorMsg = serverMessage ?? "API Error: ${response.statusCode}";
                          //           if (serverMessage == null) {
                          //             try {
                          //               if (response.statusMessage != null && response.statusMessage.toString().isNotEmpty) {
                          //                 errorMsg = response.statusMessage.toString();
                          //               }
                          //             } catch (_) {}
                          //           }
                          //         }
                          //       } catch (_) {}

                          //       try {
                          //         if (response.data is Map) {
                          //           var status = response.data['status'];
                          //           if (status == false || status == 0 || status == 'false') {
                          //             isSuccess = false;
                          //             errorMsg = serverMessage ?? errorMsg;
                          //           }
                          //         }
                          //       } catch (_) {}
                          //     } else {
                          //       isSuccess = false;
                          //     }

                          //     if (isSuccess) {
                          //       widget.leadsController.loadLeadsCustomerData;
                          //       if (context.mounted) {
                          //         Navigator.of(context).pop();
                          //       }
                          //     } else {
                          //       if (context.mounted) {
                          //         showCustomToastDisplay(context, errorMsg, Colors.red, Icons.close);
                          //       }
                          //     }
                          //   } catch (error) {
                          //     if (context.mounted) {
                          //       String errMsg = error.toString();
                          //       final regex = RegExp(r'"message"\s*:\s*"([^"]+)"');
                          //       final match = regex.firstMatch(errMsg);
                          //       if (match != null && match.groupCount >= 1) {
                          //         errMsg = match.group(1)!;
                          //       } else {
                          //         errMsg = errMsg.replaceAll("Exception: ", "").trim();
                          //       }
                          //       showCustomToastDisplay(context, errMsg, Colors.red, Icons.error);
                          //     }
                          //   } finally {
                          //     setState(() {
                          //       isUpdatingLeads = false;
                          //     });
                          //   }
                          //         },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: primaryColor,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(4.0),
                          //     ),
                          //   ),
                          //   child: isUpdatingLeads
                          //       ? const SizedBox(
                          //           width: 20,
                          //           height: 20,
                          //           child: CircularProgressIndicator(
                          //             strokeWidth: 2,
                          //             valueColor:
                          //                 AlwaysStoppedAnimation<Color>(
                          //                     Colors.white),
                          //           ),
                          //         )
                          //       : const Text(
                          //           'Update',
                          //           style: TextStyle(color: white),
                          //         ),
                          // ),
                          if (widget.leadsController.isUpdating.value)
                            CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
