import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../../../../theme/custom_fonts.dart';
import '../widgets/notification_widget.dart';



class tableee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            calender(),
            FrozenHeaderTable(),
          ],
        ),
      ),
    );
  }

  Widget calender() {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Consumer<CustomersProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        height: isSmallScreen ? 29 : 38,
                        width: isSmallScreen ? 84 : 104,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 4.0, right: 4.0, top: 4.0, bottom: 1.0),
                            child: DropdownButton<FilterDateEnum>(
                              value: provider.selectedFilter,
                              onChanged: provider.onFilterChanged,
                              items: [
                                DropdownMenuItem(
                                  value: FilterDateEnum.thisMonth,
                                  child: Text(
                                    'This Month',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: isSmallScreen ? 7.7 : 9.8,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: FilterDateEnum.today,
                                  child: Text(
                                    'Today',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: isSmallScreen ? 7.7 : 10.5,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: FilterDateEnum.thisWeek,
                                  child: Text(
                                    'This Week',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: isSmallScreen ? 7.7 : 10.5,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: FilterDateEnum.thisYear,
                                  child: Text(
                                    'This Year',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: isSmallScreen ? 7.7 : 10.5,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: FilterDateEnum.range,
                                  child: Text(
                                    'Range',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: isSmallScreen ? 7.7 : 10.5,
                                    ),
                                  ),
                                ),
                              ],
                              isExpanded: true,
                              underline: Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (provider.selectedFilter == FilterDateEnum.range)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          provider.selectDate(context, true),
                                      child: Container(
                                        height: isSmallScreen ? 29 : 38,
                                        width: isSmallScreen ? 62 : 90,
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff9f9fb),
                                          border: Border.all(
                                              color: const Color(0xffd1d1d1),
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              provider.selectedStartDate.isEmpty
                                                  ? 'DD-MM-YYYY'
                                                  : provider.selectedStartDate,
                                              style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 7.7
                                                      : 10.5,
                                                  color: Colors.grey[800]),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: isSmallScreen ? 10 : 14,
                                              color: Colors.grey[700],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          provider.selectDate(context, false),
                                      child: Container(
                                        height: isSmallScreen ? 29 : 38,
                                        width: isSmallScreen ? 62 : 90,
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff9f9fb),
                                          border: Border.all(
                                              color: const Color(0xffd1d1d1),
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              provider.selectedEndDate.isEmpty
                                                  ? 'DD-MM-YYYY'
                                                  : provider.selectedEndDate,
                                              style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 7.7
                                                      : 10.5,
                                                  color: Colors.grey[800]),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: isSmallScreen ? 10 : 14,
                                              color: Colors.grey[700],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: SizedBox(
                                      height: isSmallScreen ? 29 : 36.4,
                                      width: isSmallScreen ? 65 : 68,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          provider.fetchCustomerData();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                        ),
                                        child: const Text(
                                          'Go',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            addCustomer(context),
                            const SizedBox(width: 5),
                            // addLeads(context),
                            // const AddLeadsBt(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          NotificationWidget(),
          const UpdateAminBt(),
        ],
      );
    });
  }

  Consumer<CustomersProvider> addCustomer(BuildContext context) {
    bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
    return Consumer<CustomersProvider>(builder: (context, provider, child) {
      return FutureBuilder<CustomerResponse>(
          future: provider.customerResponse,
          builder: (context, snapshot) {
            final customer = snapshot.data?.data.first;

            TextEditingController nameController = TextEditingController();
            TextEditingController phoneController = TextEditingController();
            TextEditingController emailController = TextEditingController();
            TextEditingController townController = TextEditingController();
            TextEditingController stateController = TextEditingController();
            TextEditingController zipcodeController = TextEditingController();
            TextEditingController addressController = TextEditingController();

            TextEditingController bsNameController = TextEditingController();
            TextEditingController bsNumController = TextEditingController();

            TextEditingController remarkController = TextEditingController();

            return SizedBox(
              height: isSmallScreen ? 29 : 38,
              width: isSmallScreen ? 87 : 100,
              child: CustomButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Dialog(
                              insetPadding: EdgeInsets.zero,
                              backgroundColor:
                                  Colors.grey[200], // Grey background color
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                side: BorderSide.none, // Remove outline
                              ),
                              elevation: 24.0, // Shadow elevation
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Add Customer',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.5,
                                          ),
                                        ),
                                        dialogCloseButton(context, red)
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  // First row - Full Name
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
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
                                  const SizedBox(height: 12.0),
                                  // Second row - Mobile Number and Email
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: phoneController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: emailController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                  const SizedBox(height: 12.0),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: townController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Town',
                                                prefixIcon:
                                                    Icon(Icons.location_city),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: stateController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'State',
                                                prefixIcon:
                                                    Icon(Icons.location_city),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: zipcodeController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                  const SizedBox(height: 12.0),
                                  // Fourth row - Address
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
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
                                  const SizedBox(height: 12.0),
                                  // Second row - Mobile Number and Email
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: bsNameController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: bsNumController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Business Contact',
                                                prefixIcon:
                                                    Icon(Icons.phone_callback),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Fifth row - Image Picker
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: remarkController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: GestureDetector(
                                            onTap: provider.pickImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const Icon(Icons.image,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            height: 12.0),
                                                        Text(
                                                          provider.imageFile ==
                                                                  null
                                                              ? 'Pick an image from gallery'
                                                              : 'Image selected',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700]),
                                                        ),
                                                      ],
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
                                  const SizedBox(height: 12.0),
                                  if (provider.imageFile != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 100.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: kIsWeb
                                            ? Image.network(
                                                provider.imageFile!.path,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(provider.imageFile!.path),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16.0),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final updatedAdmin = CustomerDashMo(
                                              // cartId:
                                              //     widget.cusId, // Provide default or empty values if not applicable
                                              fullname: nameController.text,
                                              mobileno: phoneController.text,
                                              email: emailController.text,
                                              town: townController.text,
                                              state: stateController.text,
                                              zipcode: int.parse(
                                                  zipcodeController.text),
                                              address: addressController.text,
                                              businessName:
                                                  bsNameController.text,
                                              businessNo: bsNumController
                                                  .text, // Provide default or empty values if not applicable
                                            );

                                            try {
                                              await provider.addCustomer(
                                                  admin: updatedAdmin,
                                                  salsmanId: customer!
                                                      .salesmanId
                                                      .toString());
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            } catch (error) {
                                              // Handle error (e.g., show a message to the user)
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                primaryColor, // Background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4.0), // Border radius
                                            ),
                                          ),
                                          child: const Text(
                                            'Add Customer',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                text: 'Customer',
              ),
            );
          });
    });
  }
}

class AddLeadsBt extends StatelessWidget {
  const AddLeadsBt({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
        return FutureBuilder<CustomerResponse>(
          future: provider.customerResponse,
          builder: (context, snapshot) {
            final customer = snapshot.data?.data.first;

            TextEditingController nameController = TextEditingController();
            TextEditingController phoneController = TextEditingController();
            TextEditingController emailController = TextEditingController();
            TextEditingController townController = TextEditingController();
            TextEditingController stateController = TextEditingController();
            TextEditingController zipcodeController = TextEditingController();
            TextEditingController addressController = TextEditingController();

            TextEditingController bsNameController = TextEditingController();
            TextEditingController bsNumController = TextEditingController();

            TextEditingController remarkController = TextEditingController();

            return SizedBox(
              height: isSmallScreen ? 29 : 38,
              width: isSmallScreen ? 87 : 100,
              child: CustomButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Add Lead',
                                    style: TextStyle(
                                      color: Colors.white,
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
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: phoneController,
                                              decoration: const InputDecoration(
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: emailController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: TextField(
                                                controller: townController,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 16.0,
                                                  ),
                                                  labelText: 'Town',
                                                  prefixIcon:
                                                      Icon(Icons.location_city),
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: stateController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'State',
                                                prefixIcon:
                                                    Icon(Icons.location_city),
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: zipcodeController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: bsNameController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: bsNumController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Business Contact',
                                                prefixIcon:
                                                    Icon(Icons.phone_callback),
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
                                          // Removed unnecessary Expanded here
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: remarkController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
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
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: provider.pickImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const Icon(Icons.image,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            height: 12.0),
                                                        Text(
                                                          provider.imageFile ==
                                                                  null
                                                              ? 'Pick an image from gallery'
                                                              : 'Image selected',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (provider.imageFile !=
                                                        null) ...[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: kIsWeb
                                                            ? Image.network(
                                                                provider
                                                                    .imageFile!
                                                                    .path,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.file(
                                                                File(provider
                                                                    .imageFile!
                                                                    .path),
                                                                fit: BoxFit
                                                                    .cover,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final updatedAdmin = CustomerDashMo(
                                              fullname: nameController.text,
                                              mobileno: phoneController.text,
                                              email: emailController.text,
                                              town: townController.text,
                                              state: stateController.text,
                                              zipcode: int.parse(
                                                  zipcodeController.text),
                                              address: addressController.text,
                                              businessName:
                                                  bsNameController.text,
                                              businessNo: bsNumController
                                                  .text, // Provide default or empty values if not applicable
                                            );

                                            try {
                                              await provider.addLead(
                                                  admin: updatedAdmin,
                                                  salsmanId: customer!
                                                      .salesmanId
                                                      .toString());
                                              Navigator.of(context).pop();
                                            } catch (error) {
                                              // Handle error (e.g., show a message to the user)
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                primaryColor, // Background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4.0), // Border radius
                                            ),
                                          ),
                                          child: const Text(
                                            'Add Lead',
                                            style:
                                                TextStyle(color: Colors.white),
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
                    },
                  );
                },
                text: "Lead",
              ),
            );
          },
        );
      },
    );
  }
}

class UpdateAminBt extends StatelessWidget {
  const UpdateAminBt({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      return FutureBuilder<AdminResponse>(
        future: provider.adminResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitFadingCube(
                //    type: SpinKitWaveType.center,
                color: primaryColor, // Customize color if needed
                size: 20.0, // Adjust size as needed
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final admin = snapshot.data!.data.first;

            TextEditingController nameController =
                TextEditingController(text: admin.name);
            TextEditingController phoneController =
                TextEditingController(text: admin.phoneNo);
            TextEditingController emailController =
                TextEditingController(text: admin.email);
            TextEditingController townController =
                TextEditingController(text: admin.town);
            TextEditingController stateController =
                TextEditingController(text: admin.state);
            TextEditingController zipcodeController =
                TextEditingController(text: admin.zipcode.toString());
            TextEditingController addressController =
                TextEditingController(text: admin.address);

            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dialog(
                            insetPadding: EdgeInsets.zero,
                            backgroundColor:
                                Colors.grey[200], // Grey background color
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              side: BorderSide.none, // Remove outline
                            ),
                            elevation: 24.0, // Shadow elevation
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Update Admin',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.5,
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
                                              padding:
                                                  const EdgeInsets.all(3.5),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                // First row - Full Name
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
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
                                const SizedBox(height: 12.0),
                                // Second row - Mobile Number and Email
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: TextField(
                                          controller: phoneController,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: TextField(
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                // Third row - State and Zip Code
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: TextField(
                                          controller: townController,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 16.0,
                                            ),
                                            labelText: 'Town',
                                            prefixIcon:
                                                Icon(Icons.location_city),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: TextField(
                                          controller: stateController,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 16.0,
                                            ),
                                            labelText: 'State',
                                            prefixIcon:
                                                Icon(Icons.location_city),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: TextField(
                                          controller: zipcodeController,
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
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
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                // Fourth row - Address
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
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
                                const SizedBox(height: 12.0),
                                // Fifth row - Image Picker
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: provider.pickImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const Icon(Icons.image,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            height: 12.0),
                                                        Text(
                                                          provider.imageFile ==
                                                                  null
                                                              ? 'Pick an image from gallery'
                                                              : 'Image selected',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700]),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: provider.pickImage,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          height:
                                                              100.0, // Adjust height as needed
                                                          width:
                                                              120.0, // Adjust width as needed
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          child: Image.network(
                                                            'http://16.50.232.153:3000/uploads/${admin.imagePath}',
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  value: loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Center(
                                                                    child: Text(
                                                                        'Failed to load image: $error')),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: provider.pickImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const Icon(Icons.image,
                                                            color: Colors.grey),
                                                        const SizedBox(
                                                            height: 12.0),
                                                        Text(
                                                          provider.imageFile ==
                                                                  null
                                                              ? 'Pick an image from gallery'
                                                              : 'Image selected',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[700]),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    InkWell(
                                                      onTap: provider.pickImage,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          height:
                                                              100.0, // Adjust height as needed
                                                          width:
                                                              120.0, // Adjust width as needed
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          child: Image.network(
                                                            'http://16.50.232.153:3000/uploads/${admin.idImagePath}',
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  value: loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Center(
                                                                    child: Text(
                                                                        'Failed to load image: $error')),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12.0),
                                    if (provider.imageFile != null) ...[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 100.0,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: kIsWeb
                                              ? Image.network(
                                                  provider.imageFile!.path,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(
                                                      provider.imageFile!.path),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 16.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          final updatedAdmin = AdminData(
                                            name: nameController.text,
                                            phoneNo: phoneController.text,
                                            email: emailController.text,
                                            town: townController.text,
                                            state: stateController.text,
                                            zipcode: int.parse(
                                                zipcodeController.text),
                                            address: addressController.text,
                                            // Add other necessary fields
                                            token: admin.token,
                                            idAdmin: null,
                                            companyId: null,
                                            idImagePath: null,
                                            imagePath: null,
                                            password: null,
                                            createAt: null,
                                          );

                                          try {
                                            await provider.updateAdmin(
                                              admin: updatedAdmin,
                                            );
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          } catch (error) {
                                            // Handle error (e.g., show a message to the user)
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              primaryColor, // Background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4.0), // Border radius
                                          ),
                                        ),
                                        child: const Text(
                                          'Update',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: SizedBox(
                width: 110,
                child: Container(
                  height: 44,
                  width: double.infinity,
                  //  color: const Color(0xffffffff),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        CircleAvatar(
                          backgroundColor: const Color(0xffe6ecff),
                          radius: 15,
                          child: admin.imagePath != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'http://16.50.232.153:3000/uploads/${admin.imagePath}',
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 30),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : const Icon(Icons
                                  .person), // Placeholder if imagePath is null
                        ),
                        const SizedBox(
                          width: 4.5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyRegularText(label: admin.name, fontSize: 10.5),
                            // SizedBox(
                            //   height: 2.5,
                            // ),
                            const MyRegularText(
                              label: "Admin",
                              fontSize: 8.5,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      );
    });
  }
}

class CustomButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  const CustomButton({
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
          borderRadius: BorderRadius.circular(4.0), // Border radius
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // mainAxisSize: MainAxisSize.min,
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

enum EventType {
  weekly,
  fortnightly,
  monthly,
  daily,
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.weekly:
        return "Weekly";
      case EventType.fortnightly:
        return "Fortnightly";
      case EventType.monthly:
        return "Monthly";
      case EventType.daily:
        return "Daily";
      default:
        return "";
    }
  }

  int get value {
    switch (this) {
      case EventType.weekly:
        return 2;
      case EventType.fortnightly:
        return 3;
      case EventType.monthly:
        return 4;
      case EventType.daily:
        return 5;
      default:
        return 0;
    }
  }

  static EventType fromValue(int value) {
    switch (value) {
      case 2:
        return EventType.weekly;
      case 3:
        return EventType.fortnightly;
      case 4:
        return EventType.monthly;
      case 5:
        return EventType.daily;
      default:
        return EventType.weekly; // Default to weekly if unknown
    }
  }
}

class EventTypeDropdown extends StatefulWidget {
  final EventType initialValue;
  final Function(EventType) onChanged;
  final List<String> defaultEventDays;
  final String customerId; // Add customer ID parameter
  final int eventStatus; // Add event status parameter
  final CustomersProvider provider; // Add provider parameter

  const EventTypeDropdown({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.defaultEventDays,
    required this.customerId,
    required this.eventStatus,
    required this.provider,
  });

  @override
  _EventTypeDropdownState createState() => _EventTypeDropdownState();
}

class _EventTypeDropdownState extends State<EventTypeDropdown> {
  late EventType selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xffdddefc),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            //  width: (MediaQuery.of(context).orientation == Orientation.portrait)
            // ? (ResponsiveInfo.isMobileDimension(context) ? 55 : 55)
            // : (ResponsiveInfo.isMobileDimension(context) ? 55 : 55),
            height: 38,
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 2),
              child: DropdownButton<EventType>(
                iconSize: 17.5,
                value: selectedValue,
                onChanged: (EventType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedValue = newValue;
                      widget.onChanged(newValue);

                      if (newValue == EventType.monthly) {
                        // Show date picker for monthly
                        _selectDate(context);
                      } else {
                        // Show days of week popup for other even t - type
                        showDaysOfWeekPopup(context, widget.defaultEventDays,
                            widget.customerId, newValue.value, widget.provider);
                      }
                    });
                  }
                },
                items: EventType.values
                    .map<DropdownMenuItem<EventType>>((EventType value) {
                  return DropdownMenuItem<EventType>(
                    value: value,
                    child: Text(
                      value.displayName,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        //fontFamily: 'Poppins_Regular',
                      ),
                    ),
                  );
                }).toList(),
                underline: Container(),
                isExpanded: true,
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          if (widget.defaultEventDays.isNotEmpty)
            SizedBox(
              width: 24,
              height: 24,
              child: GestureDetector(
                  onTap: () {
                    showDaysOfWeekPopup(context, widget.defaultEventDays,
                        widget.customerId, widget.eventStatus, widget.provider);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'i',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
            ),
        ],
      ),
    );
  }

  void showDaysOfWeekPopup(BuildContext context, List<String> selectedDays,
      String cusID, int eventSt, CustomersProvider provider) {
    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: daysOfWeek.map((day) {
                    return CheckboxListTile(
                      title: Text(day),
                      value: selectedDays.contains(day.toLowerCase()),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedDays.add(day.toLowerCase());
                          } else {
                            selectedDays.remove(day.toLowerCase());
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xffdcdefc), // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4.0), // Curved border radius
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: primaryColor), // Text color
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4.0), // Curved border radius
                        ),
                      ),
                      child: const Text(
                        'Add To Calender',
                        style: TextStyle(color: Colors.white), // Text color
                      ),
                      onPressed: () {
                        // Call the provider method to add the event
                        provider.addEvent(
                          cusID,
                          eventSt,
                          selectedDays,
                        );
                        provider.fetchCustomerData();
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // Handle the selected date here
      widget.provider.addEvent(
        widget.customerId,
        widget.eventStatus,
        [selectedDate.toIso8601String()],
      );
      widget.provider.fetchCustomerData();
    }
  }
}

String _getStatusName(int status) {
  switch (status) {
    case 5:
      return 'Order Processing';
    case 10:
      return 'Packed for Delivery';
    case 1:
      return 'Out for Delivery';
    case 2:
      return 'Delivered';
    default:
      return 'Unknown';
  }
}

class FrozenHeaderTable extends StatefulWidget {
  @override
  State<FrozenHeaderTable> createState() => _FrozenHeaderTableState();
}

class _FrozenHeaderTableState extends State<FrozenHeaderTable> {
  final CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  final StaffController staffController = Get.put(StaffController());
  final LeadsController leadsController = Get.put(LeadsController());
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  String? startDate;
  String? endDate;
  String dropdownValue = 'Today';
  

  @override
  void initState() {
    super.initState();

    _horizontalScrollController.addListener(() {
      // Disable scrolling at the end
      if (_horizontalScrollController.offset <=
          _horizontalScrollController.position.minScrollExtent) {
        _horizontalScrollController
            .jumpTo(_horizontalScrollController.position.minScrollExtent);
      } else if (_horizontalScrollController.offset >=
          _horizontalScrollController.position.maxScrollExtent) {
        _horizontalScrollController
            .jumpTo(_horizontalScrollController.position.maxScrollExtent);
      }
    });

    _verticalScrollController.addListener(() {
      // Disable scrolling at the end
      if (_verticalScrollController.offset <=
          _verticalScrollController.position.minScrollExtent) {
        _verticalScrollController
            .jumpTo(_verticalScrollController.position.minScrollExtent);
      } else if (_verticalScrollController.offset >=
          _verticalScrollController.position.maxScrollExtent) {
        _verticalScrollController
            .jumpTo(_verticalScrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalTableWidth = 100 + 260 + 100 + 100 + 100 + 100 + 140 + 100;
    double fixedRowHeight = 80.0;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Consumer<CustomersProvider>(builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provider.errorMessage.isNotEmpty) {
          return Center(child: Text(provider.errorMessage));
        } else if (provider.customersFuture == null) {
          return const Center(child: Text('No data available'));
        } else {
          return FutureBuilder<CustomerResponseModelxx>(
            future: provider.customersFuture!,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return const Center(child: Text('No customers found'));
              } else {
                double screenHeight = MediaQuery.of(context).size.height;
                double containerHeight = screenHeight * 0.85;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed first column
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: _verticalScrollController,
                      // controller: _horizontalScrollController,
                      child: SizedBox(
                        width: 260,
                        child: Column(
                          children: [
                            _buildTableHeader(
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  onChanged: (query) {
                                    provider.updateSearchQuery(query);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(3.2),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 9.5, vertical: 9.5),
                                  ),
                                ),
                              ),
                              260,
                            ),
                            ...List.generate(
                              provider.filteredCustomers.length,
                              (index) {
                                var customer =
                                    provider.filteredCustomers[index];
                                return Container(
                                  height: fixedRowHeight,
                                  color: index.isEven
                                      ? Colors.grey[50]
                                      : Colors.white,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Fixed column cell
                                      Container(
                                        width: 220,
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                color: Colors.grey[200],
                                                child: Image.network(
                                                  'http://16.50.232.153:3000/uploads/${customer.imageUrl}',
                                                  fit: BoxFit.cover,
                                                  width: 34,
                                                  height: 34,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                          Icons.person,
                                                          color: Colors.blue,
                                                          size: 34),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  provider
                                                      .setCurrentMonthDates();

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CustomerDachScreen(
                                                        cusId:
                                                            customer.customerId,
                                                        cusName:
                                                            customer.fullname,
                                                        cusImage: customer.imageUrl,
                                                        year: 2024,
                                                        startDate: provider
                                                            .selectedStartDate,
                                                        endDate: provider
                                                            .selectedEndDate,
                                                        isFromCalendar: false,
                                                      ),
                                                    ),
                                                  );

                                                  provider
                                                      .fetchCustomerDashboardData(
                                                          customer.customerId,
                                                          2024,
                                                          provider
                                                              .selectedStartDate,
                                                          provider
                                                              .selectedEndDate);
                                                  provider
                                                      .fetchCustomerDashboardRevenueData(
                                                          customer.customerId,
                                                          2024,
                                                          provider
                                                              .selectedStartDate,
                                                          provider
                                                              .selectedEndDate);
                                                  provider
                                                      .fetchCustomerDashboardCountData(
                                                          customer.customerId);
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        customer.businessName ??
                                                            'Business Name',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Text(
                                                        customer.town ?? 'Town',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Text(
                                                        customer.fullname ??
                                                            'Full Name',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Text(
                                                        customer.email ??
                                                            'email@example.com',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            _buildTableCell(
                              padding: EdgeInsets.zero,
                              Container(
                                color: Colors.grey[200],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        width: 3 * 62.0,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons
                                                      .keyboard_double_arrow_left,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                onPressed:
                                                    provider.currentPage > 1
                                                        ? () {
                                                            provider
                                                                .goToPreviousPage();
                                                          }
                                                        : null,
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children:
                                                    List.generate(3, (index) {
                                                  // Calculate the visible page range
                                                  int firstPage = (provider
                                                              .currentPage -
                                                          1)
                                                      .clamp(
                                                          1,
                                                          provider.totalPages -
                                                              2);
                                                  int visiblePage =
                                                      firstPage + index;

                                                  return GestureDetector(
                                                    onTap: visiblePage <=
                                                            provider.totalPages
                                                        ? () {
                                                            provider.currentPage =
                                                                visiblePage;
                                                            provider
                                                                .refreshCurrentPage();
                                                          }
                                                        : null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Container(
                                                        height: 40,
                                                        width: 25,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: provider
                                                                      .currentPage ==
                                                                  visiblePage
                                                              ? Colors.white
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '$visiblePage',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: provider
                                                                          .currentPage ==
                                                                      visiblePage
                                                                  ? primaryColor
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: 40,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons
                                                      .keyboard_double_arrow_right,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                                onPressed: provider
                                                            .currentPage <
                                                        provider.totalPages
                                                    ? () {
                                                        provider.goToNextPage();
                                                      }
                                                    : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.grey[200],
                                      // height: 58,
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('    Total  ',
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              260,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Scrollable columns
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalScrollController,
                        child: SizedBox(
                          width: totalTableWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: primaryColor,
                                child: Row(
                                  children: [
                                    _buildTableHeader(
                                      Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Sales',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins_Regular',
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Obx(() {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20, top: 20),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                child: DropdownButton<String>(
                                                  iconSize: 14,
                                                  value:
                                                      customerAndOrderController
                                                          .selectedYear.value,
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue != null) {
                                                      customerAndOrderController
                                                          .updateSelectedYear(
                                                              newValue);
                                                    }
                                                  },
                                                  items:
                                                      customerAndOrderController
                                                          .years
                                                          .map<
                                                              DropdownMenuItem<
                                                                  String>>((String
                                                              value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Poppins_Regular',
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  dropdownColor: Colors.white,
                                                  isExpanded: false,
                                                  underline: Container(),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      100,
                                    ),
                                    _buildTableHeader(
                                      const Text(
                                        'Sales / Delivery / Payments',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      260,
                                    ),
                                    _buildTableHeader(
                                      const Text(
                                        'Estimates',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      100,
                                    ),
                                    _buildTableHeader(
                                      const Text(
                                        'Pre-Order',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      100,
                                    ),
                                    _buildTableHeader(
                                      const Text(
                                        'Drafts',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      100,
                                    ),
                                    _buildTableHeader(
                                      const Text(
                                        'Cancelled',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      100,
                                    ),
                                    _buildTableHeader(
                                      const Text(
                                        'Visits',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      140,
                                    ),
                                    _buildTableHeader(
                                      const Center(
                                        child: Text(
                                          'SE',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins_Regular',
                                          ),
                                        ),
                                      ),
                                      100,
                                    ),
                                  ],
                                ),
                              ),
                              // Data rows generation
                              Container(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.filteredCustomers.length,
                                  itemBuilder: (context, index) {
                                    var customer =
                                        provider.filteredCustomers[index];

                                    return Container(
                                      height: fixedRowHeight,
                                      color: index.isEven
                                          ? Colors.grey[50]
                                          : Colors.white,
                                      child: Row(
                                        children: [
                                          _buildTableCell(
                                            Center(
                                              child: Text(
                                                formatAmount('0'),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            100,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (customer.totalSales ==
                                                                  0 ||
                                                              customer.totalSales ==
                                                                  null) {
                                                            // Show a SnackBar if sales is 0 or null
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'No Record Found.'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ),
                                                            );
                                                          } else {
                                                            // If sales are greater than 0, show the order data dialog
                                                            _showOrderDataDialog(
                                                                context,
                                                                customer
                                                                    .orderData,
                                                                customer);
                                                          }
                                                        },
                                                        child: _buildDataCell(
                                                          customer.sales
                                                                  ?.toString() ??
                                                              '0',
                                                          '${customer.totalSales?.toString() ?? '0'}',
                                                          Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (customer.delivery ==
                                                                  0 ||
                                                              customer.delivery ==
                                                                  null) {
                                                            // Show a SnackBar if delivery is 0 or null
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'No Record Found.'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ),
                                                            );
                                                          } else {
                                                            // Continue to show the order data dialog if delivery is valid
                                                            _showOrderDataDialog(
                                                                context,
                                                                customer
                                                                    .orderData,
                                                                customer);
                                                          }
                                                        },
                                                        child: _buildDataCell(
                                                          customer.delivery
                                                                  ?.toString() ??
                                                              '0',
                                                          '${customer.salesPrice?.toString() ?? '0'}',
                                                          Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (customer.payment ==
                                                                  0 ||
                                                              customer.payment ==
                                                                  null) {
                                                            // Show a SnackBar if payment is 0 or null
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'No Record Found.'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ),
                                                            );
                                                          } else {
                                                            // Continue to show the order data dialog if payment is valid
                                                            _showOrderDataDialog(
                                                                context,
                                                                customer
                                                                    .orderData,
                                                                customer);
                                                          }
                                                        },
                                                        child: _buildDataCell(
                                                          customer.payment
                                                                  ?.toString() ??
                                                              '0',
                                                          '${customer.paymentPrice?.toString() ?? '0'}',
                                                          Colors.orange,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            260,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Center(
                                                child: _buildDataCell(
                                                  customer.estimates
                                                          ?.toString() ??
                                                      '0',
                                                  '\$${customer.estimatesPrice?.toString() ?? '0'}',
                                                  Colors.purple,
                                                ),
                                              ),
                                            ),
                                            100,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Center(
                                                child: _buildDataCell(
                                                  customer.preOrder.toString(),
                                                  '\$${customer.preOrderPrice?.toString() ?? '0'}',
                                                  Colors.grey,
                                                ),
                                              ),
                                            ),
                                            100,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Center(
                                                child: _buildDataCell(
                                                  customer.drafts.toString(),
                                                  customer.orderData.draft
                                                      .takeLast(customer.drafts)
                                                      .fold(
                                                          0.0,
                                                          (a, b) =>
                                                              a + b.orderTotal)
                                                      .toString(),
                                                  Colors.red,
                                                ),
                                              ),
                                            ),
                                            100,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Center(
                                                child: _buildDataCell(
                                                  customer.cancelled
                                                          ?.toString() ??
                                                      '0',
                                                  '\$${customer.cancelled?.toString() ?? '0'}',
                                                  Colors.purple,
                                                ),
                                              ),
                                            ),
                                            100,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: EventTypeDropdown(
                                                initialValue: EventTypeExtension
                                                    .fromValue(
                                                        customer.eventType),
                                                onChanged:
                                                    (EventType newType) {},
                                                defaultEventDays:
                                                    customer.eventDays,
                                                customerId: customer.customerId,
                                                eventStatus: customer.eventType,
                                                provider: provider,
                                              ),
                                            ),
                                            140,
                                          ),
                                          _buildTableCell(
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Center(
                                                  child: Text(
                                                      customer.salesmanName)),
                                            ),
                                            100,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                height: 58,
                                color: Colors.grey[200],
                                child: Row(
                                  children: [
                                    // Uncomment sections as needed, ensuring proper layout
                                    _buildTableCell(
                                      Center(
                                        child: Text(
                                          formatAmount(0), // to be changed
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                        ),
                                      ),
                                      100,
                                    ),
                                    _buildTableCell(
                                      Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Text(
                                                  formatAmount(provider
                                                      .orderTotalList[0].sales),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Text(
                                                  formatAmount(provider
                                                      .orderTotalList[1]
                                                      .delivery),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Text(
                                                  formatAmount(provider
                                                      .orderTotalList[2]
                                                      .payment),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      260,
                                    ),
                                    _buildTableCell(
                                      Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            formatAmount(provider
                                                .orderTotalList[3].estimate),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      100,
                                    ),
                                    _buildTableCell(
                                      Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            formatAmount(provider
                                                .orderTotalList[4].preOrder),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      100,
                                    ),
                                    _buildTableCell(
                                      Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            formatAmount(provider
                                                .orderTotalList[5].draft),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      100,
                                    ),
                                    _buildTableCell(
                                      Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            formatAmount(provider
                                                .orderTotalList[6].cancelled),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      100,
                                    ),
                                    _buildTableCell(
                                      const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      140,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          );
        }
      }),
    );
  }

  Widget _buildTableHeader(Widget child, double width) {
    return Container(
      height: 58,
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      child: child,
    );
  }

  Widget _buildTableCell(Widget child, double width,
      {EdgeInsetsGeometry padding = const EdgeInsets.all(8.0)}) {
    // debugPrint("Building table cell with width: $width");
    return Container(
      height: 58,
      width: width,
      padding: padding,
      child: child,
    );
  }

  Widget _buildDataCell(String count, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              count,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          formatAmount(amount),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showOrderDataDialog(
      BuildContext context, OrderDataxx orderData, CustomerModelxx customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              double availableWidth = constraints.maxWidth;
              // double fontSize = availableWidth / 50.6;
              double fontSize = 14;
              double padding = availableWidth / 100;
              double fixedIconSize = 13.0; // Fixed icon size

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: availableWidth),
                  child: DataTable(
                    // ignore: deprecated_member_use
                    dataRowHeight: 64,
                    headingRowColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      return primaryColor; // Set the background color for the headers
                    }),
                    columnSpacing:
                        padding, // Adjust the spacing between columns
                    columns: [
                      DataColumn(
                        label: Text(
                          'Customer List',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: MyRegularText(
                          label: 'Order Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: MyRegularText(
                          label: 'Order Created',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: MyRegularText(
                          label: 'Created By',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: MyRegularText(
                          label: 'Order Price',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: MyRegularText(
                          label: 'Invoice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: MyRegularText(
                          label: 'Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: dialogCloseButton(context, red),
                      ),
                    ],
                    rows: orderData.totalSales.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: fixedIconSize * 2.6,
                                  width: fixedIconSize * 2.6,
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xffe6ecff),
                                    child: Icon(
                                      Icons.person,
                                      size: fixedIconSize,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(width: padding),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer != null
                                          ? customer.fullname
                                          : 'N/A',
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                    Text(
                                      customer != null
                                          ? customer.mobileno
                                          : 'N/A',
                                      style: TextStyle(
                                        fontSize: fontSize * 0.6,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      customer != null ? customer.email : 'N/A',
                                      style: TextStyle(
                                        fontSize: fontSize * 0.6,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              order.orderId,
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                          DataCell(
                            Text(
                              order.orderCreatAt != null
                                  ? getFormattedOrderCreatAt(
                                      order.orderCreatAt.toString())
                                  : 'N/A',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${order.fullname!.nkStringCapitalizeFirstCaracter} ${order.lastname!.nkStringCapitalizeFirstCaracter}',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                          DataCell(
                            Text(
                              formatAmount(order.orderTotal),
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                          DataCell(
                            Text(
                              '\$${order.orderId}',
                              style: TextStyle(
                                  fontSize: fontSize, color: primaryColor),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: EdgeInsets.all(padding),
                              child: SizedBox(
                                height: 31,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffdbb8),
                                    borderRadius: BorderRadius.circular(4.6),
                                  ),
                                  //                                         child:
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child:
                                        Text(_getStatusName(order.orderStatus)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const DataCell(Text('')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
  String formatAmount(dynamic value) {
  // Convert the dynamic value to double
  double amount;
  
  if (value is String) {
    amount = double.tryParse(value) ?? 0.0;
  } else if (value is int) {
    amount = value.toDouble();
  } else if (value is double) {
    amount = value;
  } else {
    throw ArgumentError('Unsupported value type');
  }

  // Format the amount to two decimal places
  String formattedAmount = amount.toStringAsFixed(2);

  // Return with the $ symbol
  return '\$ ' + formattedAmount;
}
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) => skip(length - n).toList();
}
