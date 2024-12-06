import 'dart:developer';
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
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
      HomeController homeController = Get.put(HomeController());
      log('Profile pic Path :${ApiConstants.imageBaseUrl}${homeController.userDetails?.imagePath}');
      return FutureBuilder<AdminResponse>(
        future: provider.adminResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitFadingCube(
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

            return SizedBox(
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
                                    '${ApiConstants.imageBaseUrl}${homeController.userDetails?.imagePath}',
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
            );
          } else {
            return NodataWidget();
          }
        },
      );
    });
  }
 