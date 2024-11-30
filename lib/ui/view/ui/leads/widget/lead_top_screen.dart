import 'dart:io';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/notification_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LeadTopScreen extends StatelessWidget {
  final LeadsController leadsController;
  const LeadTopScreen({super.key, required this.leadsController});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AddLeadsBt(),
            Spacer(),
            NotificationWidget(),
            profiloe(),
          ],
        ),
      ],
    );
  }

  Widget get leadTopLeadsWidget {
    return GestureDetector(
      onTap: () => Get.dialog(AddLeadsDiloag(
        leadsController: leadsController,
      )),
      child: Container(
        width: 90,
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4.0), // Border radius
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leads,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
  Widget profiloe() {
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
            HomeController homeController = Get.put(HomeController());
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
                            shape: RoundedRectangleBorder(
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
                                SizedBox(height: 16.0),
                                // First row - Full Name
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
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
                                SizedBox(height: 12.0),
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
                                          decoration: InputDecoration(
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
                                    SizedBox(width: 8.0),
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
                                          decoration: InputDecoration(
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
                                SizedBox(height: 12.0),
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
                                          decoration: InputDecoration(
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
                                    SizedBox(width: 8.0),
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
                                          decoration: InputDecoration(
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
                                    SizedBox(width: 8.0),
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
                                          decoration: InputDecoration(
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
                                SizedBox(height: 12.0),
                                // Fourth row - Address
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
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
                                      prefixIcon: Icon(Icons.home),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.0),
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
                                                    Spacer(),
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

                                SizedBox(height: 16.0),
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

                                            print(
                                                "this is admin data from this mdoel $updatedAdmin");
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
                                      '${homeController.userDetails?.imagePath}',
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
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
                              : Icon(Icons
                                  .person), // Placeholder if imagePath is null
                        ),
                        const SizedBox(
                          width: 4.5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyRegularText(
                                label: homeController.userDetails?.fullname ??
                                    '',
                                fontSize: 10.5),
                            // SizedBox(
                            //   height: 2.5,
                            // ),
                            MyRegularText(
                              label: "Salesman",
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
            return Center(child: Text('No data available'));
          }
        },
      );
    });
  }