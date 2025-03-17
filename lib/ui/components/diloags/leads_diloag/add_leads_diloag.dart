import 'dart:developer';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';

import 'package:busskit_salesexecutive/ui/theme/close_button.dart';

import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
Consumer<CustomersProvider> addLeads(BuildContext context) {
  bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
  return Consumer<CustomersProvider>(builder: (context, provider, child) {
    return FutureBuilder<CustomerResponse>(
      future: provider.customerResponse,
      builder: (context, snapshot) {
        final customer = snapshot.data?.data.first;

        TextEditingController nameController = TextEditingController();
        TextEditingController phoneController = TextEditingController();
        TextEditingController emailController = TextEditingController();
        TextEditingController telephoneController = TextEditingController();
        TextEditingController townController = TextEditingController();
        TextEditingController stateController = TextEditingController();
        TextEditingController zipcodeController = TextEditingController();
        TextEditingController addressController = TextEditingController();

        TextEditingController bsNameController = TextEditingController();
        TextEditingController bsNumController = TextEditingController();

        TextEditingController contactPersonNameController =
            TextEditingController();
        TextEditingController contactNumController = TextEditingController();

        TextEditingController deliveryAddressController =
            TextEditingController();
        TextEditingController deliveryTownController = TextEditingController();
        TextEditingController deliveryStateController = TextEditingController();
        TextEditingController deliveryZipcodeController =
            TextEditingController();

        TextEditingController remarkController = TextEditingController();

        bool sameAsAbove = false;

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
                        backgroundColor:
                            const Color.fromARGB(255, 237, 238, 243),
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
                                      'Add Leads',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5,
                                      ),
                                    ),
                                    dialogCloseButton1(context, Colors.red),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    buildInputField(bsNameController,
                                        'Business Name', Icons.business),
                                    buildInputField(addressController,
                                        'Address', Icons.home),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(townController,
                                              'Town', Icons.location_city),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              stateController,
                                              'State',
                                              Icons.map),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              zipcodeController,
                                              'Zip Code',
                                              Icons.pin_drop),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(
                                              phoneController,
                                              'Mobile Number',
                                              Icons.phone),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              emailController,
                                              'Email',
                                              Icons.email),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              telephoneController,
                                              'Telephone',
                                              Icons.phone_in_talk),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 6.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Contact Details',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(
                                              contactPersonNameController,
                                              'Contact Person',
                                              Icons.person),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              contactNumController,
                                              'Contact Number',
                                              Icons.phone),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Delivery Address    ',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Checkbox(
                                            value: sameAsAbove,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                sameAsAbove = value ?? false;
                                                if (sameAsAbove) {
                                                  deliveryAddressController
                                                          .text =
                                                      addressController.text;
                                                  deliveryTownController.text =
                                                      townController.text;
                                                  deliveryStateController.text =
                                                      stateController.text;
                                                  deliveryZipcodeController
                                                          .text =
                                                      zipcodeController.text;
                                                } else {
                                                  deliveryAddressController
                                                      .clear();
                                                  deliveryTownController
                                                      .clear();
                                                  deliveryStateController
                                                      .clear();
                                                  deliveryZipcodeController
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
                                    buildInputField(deliveryAddressController,
                                        'Delivery Address', Icons.location_on),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildInputField(
                                              deliveryTownController,
                                              'Delivery Town',
                                              Icons.location_city),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              deliveryStateController,
                                              'Delivery State',
                                              Icons.map),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: buildInputField(
                                              deliveryZipcodeController,
                                              'Delivery Zip Code',
                                              Icons.pin_drop),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Remark Input Field
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey
                                                  .shade100, // Subtle background color
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .shade300, // Light shadow
                                                  blurRadius: 6.0,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TextField(
                                              controller: remarkController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 18.0),
                                                labelText: 'Remark',
                                                labelStyle: TextStyle(
                                                    color:
                                                        Colors.grey.shade600),
                                                prefixIcon: Icon(Icons.comment,
                                                    color:
                                                        Colors.grey.shade600),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: const BorderSide(
                                                      color: Colors.blue,
                                                      width: 1.5),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width: 1.0),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),

                                        // Image Picker
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: provider.pickImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .shade100, // Subtle background color
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
                                                        provider.imageFile ==
                                                                null
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final updatedAdmin =
                                            // {
                                            //   "userid": "ADMIN",
                                            //   "businessname": bsNameController.text,
                                            //   "address": addressController.text,
                                            //   "town": townController.text,
                                            //   "state": stateController.text,
                                            //   "zipcode": zipcodeController.text,
                                            //   "mobileno": phoneController.text,
                                            //   "email": emailController.text,
                                            //   "tfn": telephoneController.text,
                                            //   "fullname": contactPersonNameController.text,
                                            //   "businesscontact": contactNumController.text,
                                            //   "addressCheckbox": "ON",
                                            //   "delivery_address": deliveryAddressController.text,
                                            //   "delivery_town": deliveryTownController.text,
                                            //   "delivery_state": deliveryStateController.text,
                                            //   "delivery_zipcode": deliveryZipcodeController.text,
                                            //   "remark": remarkController.text,
                                            //   "customerpicture": '',
                                            //   "company_id": SessionHelper.loginSavedData?.companyId ?? 0,
                                            //   "salesman_id": null,
                                            //   "salesman_name": null,
                                            //   "status_type": 1
                                            // };

                                            CustomerDashMo(
                                          fullname: nameController.text,
                                          mobileno: phoneController.text,
                                          email: emailController.text,
                                          town: townController.text,
                                          state: stateController.text,
                                          zipcode:
                                              int.parse(zipcodeController.text),
                                          address: addressController.text,
                                          businessName: bsNameController.text,
                                          businessNo: bsNumController.text,
                                        );

                                        try {
                                          await provider.addCustomer(
                                              admin: updatedAdmin,
                                              salsmanId: customer!.salesmanId
                                                  .toString());
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                        } catch (error) {
                                          log(error.toString());
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Add Leads',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
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
      },
    );
  });
}

Widget buildInputField(
    TextEditingController controller, String labelText, IconData icon) {
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
          prefixIcon: Icon(icon, color: Colors.grey.shade600), // Icon styling
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
    super.key,
    required this.text,
    required this.onPressed,
  });

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
