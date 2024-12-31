import 'dart:io';

import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_select_status.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadBottomScreen extends StatefulWidget {
  final LeadsController leadsController;
  const LeadBottomScreen({super.key, required this.leadsController});

  @override
  State<LeadBottomScreen> createState() => _LeadBottomScreenState();
}

class _LeadBottomScreenState extends State<LeadBottomScreen> {
  final ScrollController vertical = ScrollController();
  final ScrollController vertical1 = ScrollController();

  @override
  void initState() {
    super.initState();
    vertical.addListener(() {
      if (vertical1.hasClients &&
          vertical.position.pixels != vertical1.position.pixels) {
        vertical1.jumpTo(vertical.position.pixels);
      }
    });

    vertical1.addListener(() {
      if (vertical.hasClients &&
          vertical1.position.pixels != vertical.position.pixels) {
        vertical.jumpTo(vertical1.position.pixels);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double fixedRowHeight = isLandscape
        ? MediaQuery.of(context).size.height / 9.09
        : MediaQuery.of(context).size.height / 9 -
            MediaQuery.of(context).size.height * 0.032;

    return MyCommnonContainer(
      padding: EdgeInsets.zero,
      child: Obx(() {
        return _buildTableLayout(context, fixedRowHeight);
      }),
    );
  }

  Widget _buildTableLayout(BuildContext context, double fixedRowHeight) {
    double totalTableWidth = 130 + 360 + 150 + 150 + 150 + 150 + 150 + 110;
    return Container(
      child: Row(
        children: [
          SizedBox(
            width: 270,
            child: Column(
              children: [
                _buildTableHeader1(
                  Center(
                    child: CustomText(
                      content: "Leads",
                      textAlign: TextAlign.center,
                      fontSize: 12.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  270,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: vertical,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: widget.leadsController.leadsCustomerDataList
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        LeadCustomerData leadCustomerData = entry.value;

                        return Container(
                          height: fixedRowHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey, width: 0.3),
                            ),
                            color:
                                index.isEven ? Colors.grey[50] : Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          color: Colors.grey[200],
                                          child: Image.network(
                                            'http://16.50.232.153:3000/uploads/${leadCustomerData.imageUrl ?? ''}',
                                            fit: BoxFit.cover,
                                            width: 25,
                                            height: 25,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Colors.blue,
                                                  size: 34,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      CustomText(
                                        content:
                                            leadCustomerData.businessName ?? '',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalTableWidth,
                child: Column(
                  children: [
                    SizedBox(child: _buildTableHeader()),
                    widget.leadsController.leadsCustomerDataList.isEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4)
                        : Container(),
                    widget.leadsController.leadsCustomerDataList.isEmpty
                        ? Center(child: NodataWidget())
                        : Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const ClampingScrollPhysics(),
                              controller: vertical1,
                              child: Column(
                                children: widget
                                    .leadsController.leadsCustomerDataList
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  LeadCustomerData leadCustomerData =
                                      entry.value;
                                  return _buildTableRow(leadCustomerData,
                                      context, index, fixedRowHeight);
                                }).toList(),
                              ),
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

  Widget _buildTableHeader1(Widget child, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: child,
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildHeaderText('Address', 12)),
          Expanded(child: _buildHeaderText('Town', 12)),
          Expanded(child: _buildHeaderText('State', 12)),
          Expanded(child: _buildHeaderText('Zip Code', 12)),
          Expanded(child: _buildHeaderText('Mobile', 12)),
          Expanded(child: _buildHeaderText('Email', 12)),
          Expanded(child: _buildHeaderText('Contact Person', 12)),
          Expanded(child: _buildHeaderText('Contact Number', 12)),
          Expanded(child: _buildHeaderText('Status', 12)),
          const Expanded(child: Text('')),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, double fontSize) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }

  Widget _buildTableRow(LeadCustomerData leadCustomerData, BuildContext context,
      int index, double fixedRowHeight) {
    return Container(
      color: index.isEven ? Colors.grey[50] : Colors.white,
      height: fixedRowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.address ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.town ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.state ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.zipcode.toString() ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.businessNo ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.email ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.fullname ?? '',
          ),
          LeadTableText(
            leadCustomerData: leadCustomerData,
            content: leadCustomerData.mobileno ?? '',
          ),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey, width: 0.3),
                    ),
                  ),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 9, right: 9),
                    child:
                        LeadsStatusSelect(customerId: leadCustomerData.id ?? 0),
                  )))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: fixedRowHeight - 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 20,
                      child: IconButton(
                        onPressed: () {
                          EditLeadsDialog.showEditLeadsDialog(
                              context, leadCustomerData);
                        },
                        padding: EdgeInsets.all(2),
                        constraints: const BoxConstraints(),
                        icon: const Icon(EneftyIcons.edit_outline, size: 20),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      child: IconButton(
                        onPressed: () {},
                        padding: EdgeInsets.all(2),
                        constraints: const BoxConstraints(),
                        icon: const Icon(EneftyIcons.trash_outline,
                            color: Colors.red, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LeadTableText extends StatelessWidget {
  LeadCustomerData leadCustomerData;
  String content;

  LeadTableText({
    super.key,
    required this.leadCustomerData,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 9, right: 9),
          child: CustomText(
            textAlign: TextAlign.center,
            content: content,
            fontSize: 12,
          ),
        ),
      ),
    ));
  }
}

class EditLeadsDialog extends StatelessWidget {
  final LeadCustomerData leadCustomerData;
  EditLeadsDialog({
    required this.leadCustomerData,
  });
  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: leadCustomerData.fullname);

    // TextEditingController nameController = TextEditingController();
    TextEditingController phoneController =
        TextEditingController(text: leadCustomerData.mobileno);
    TextEditingController emailController =
        TextEditingController(text: leadCustomerData.email);
    TextEditingController townController =
        TextEditingController(text: leadCustomerData.town);
    TextEditingController stateController =
        TextEditingController(text: leadCustomerData.state);
    TextEditingController zipcodeController =
        TextEditingController(text: leadCustomerData.zipcode.toString());
    TextEditingController addressController =
        TextEditingController(text: leadCustomerData.address);
    TextEditingController bsNameController =
        TextEditingController(text: leadCustomerData.businessName);
    TextEditingController bsNumController =
        TextEditingController(text: leadCustomerData.businessNo);
    TextEditingController remarkController =
        TextEditingController(text: leadCustomerData.remark);
    String imageFile =
        'http://16.50.232.153:3000/uploads/${leadCustomerData.imageUrl}' ?? '';

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
              color: Color.fromRGBO(238, 205, 110, 1),
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
                    color: Colors.black,
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
            padding: EdgeInsets.all(15),
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
                            controller: phoneController,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Mobile Number',
                              prefixIcon: Icon(Icons.phone),
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
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
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
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 16.0,
                                ),
                                labelText: 'Town',
                                prefixIcon: Icon(Icons.location_city),
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
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'State',
                              prefixIcon: Icon(Icons.location_city),
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
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Zip Code',
                              prefixIcon: Icon(Icons.map),
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
                      controller: addressController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
                            controller: bsNameController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Busniness Name',
                              prefixIcon: Icon(Icons.phone),
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
                            controller: bsNumController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              labelText: 'Business Contact',
                              prefixIcon: Icon(Icons.phone_callback),
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
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 16.0,
                                ),
                                labelText: 'Remark',
                                prefixIcon: Icon(Icons.phone),
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
                          // onTap: provider.pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.image,
                                          color: Colors.grey),
                                      const SizedBox(height: 12.0),
                                      Text(
                                        imageFile == null
                                            ? 'Pick an image from gallery'
                                            : 'Image selected',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (imageFile != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 100.0,
                                        width: 100.0, // Set a fixed width here
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: kIsWeb
                                            ? Image.network(
                                                imageFile,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(imageFile),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ],
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
                          // final updatedAdmin = CustomerDashMo(
                          //   fullname: nameController.text,
                          //   mobileno: phoneController.text,
                          //   email: emailController.text,
                          //   town: townController.text,
                          //   state: stateController.text,
                          //   zipcode: int.parse(
                          //       zipcodeController.text),
                          //   address: addressController.text,
                          //   businessName:
                          //       bsNameController.text,
                          //   businessNo: bsNumController
                          //       .text,
                          // );

                          // try {
                          //   await provider.addLead(
                          //       admin: updatedAdmin,
                          //       salsmanId: customer!
                          //           .salesmanId
                          //           .toString());
                          //   Navigator.of(context)
                          //       .pop(); // Close the dialog
                          // } catch (error) {
                          //   // Handle error (e.g., show a message to the user)
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(238, 205, 110, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(4.0), // Border radius
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

  static Future<void> showEditLeadsDialog(
      BuildContext context, LeadCustomerData leadCustomerData
      // , String leadName, String leadDetails, Function(String, String) onSave
      ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EditLeadsDialog(
          leadCustomerData: leadCustomerData,
          // leadName: leadName,
          // leadDetails: leadDetails,
          // onSave: onSave,
        );
      },
    );
  }
}
