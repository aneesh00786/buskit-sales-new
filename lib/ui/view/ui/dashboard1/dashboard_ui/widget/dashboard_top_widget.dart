import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../utills/nk_common_function.dart';
import '../../../../../utills/nk_date_utils.dart';
import '../../dashboard_controller.dart';

class DashboardTopWidget extends StatelessWidget {
  final DashBoardController dashBoardController;
  final HomeController homeController;

  const DashboardTopWidget({
    Key? key,
    required this.dashBoardController,
    required this.homeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        calender(),
        SizedBox(height: 10),
        Obx(() {
          if (dashBoardController.isLoading.value) {
            return Center(
        child: SpinKitFadingCube(
          color: primaryColor,
          size: 20.0,
        ),
      );;
          }
          if (dashBoardController.errorMessage.value.isNotEmpty) {
            log('Error: ${dashBoardController.errorMessage.value}');
            return Center(
                child:
                    Text('Error: ${dashBoardController.errorMessage.value}'));
          }
          final data = dashBoardController.dashbordData.value;
          log('DashBoard data Value ===========${data.orderCountList}');
          return OptionWidget(
            customType: "",
            customOrderStatusType: OrderStatus.preOrder,
            draftCount: data.orderCountList?.draftOrder ?? 0,
            orderCount: data.orderCountList?.totalOrder ?? 40,
            preOrderCount: data.orderCountList?.preorderOrder ?? 60,
            eastimatesCount: data.orderCountList?.estimateOrder ?? 80,
            userType: UserType.customer,
            userId: "",
            startDate: dashBoardController.selectedStartDate.value,
            endDate: dashBoardController.selectedEndDate.value,
          );
        }),
      ],
    );
  }

  Widget calender() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);

            Widget rowContent = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      SizedBox(
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
                      if (provider.selectedFilter == FilterDateEnum.range)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
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
                                                fontSize:
                                                    isSmallScreen ? 7.7 : 10.5,
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
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
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
                                                fontSize:
                                                    isSmallScreen ? 7.7 : 10.5,
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
                                        provider.fetchData();
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
                          ),
                        ),
                    ],
                  ),
                ),
                nkSmallSizeBox(),
                profiloe(),
              ],
            );

            return rowContent;
          },
        );
      },
    );
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
                            MyRegularText(label: homeController.userDetails?.fullname??'', fontSize: 10.5),
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

  Widget get orderTrakingButton => MyThemeButton(
        buttonText: orderTaking,
        fontSize: NkFontSize.smallFont() + 4,
        padding: nkSymmetricPadding(vertical: 0),
        //width: AppDimensions.instance!.width * 0.12,
        onPressed: () => {homeController.sidebarXController.selectIndex(1)},
      );

  Widget options() {
    return Row(
      children: [
        orderOptions(
            title: orders,
            count: '109',
            svg: Assets.iconsIcDashboardShoppingCart,
            svgBgColor: const Color(0xFFFCDABD),
            onTap: () {}),
        nkSmallSizeBox(),
        orderOptions(
          title: estimates,
          count: '34',
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color(0xFFC3DDFD),
        ),
        nkSmallSizeBox(),
        orderOptions(
            title: preOrder,
            count: '59',
            svg: Assets.iconsIcDashboardPreOrder,
            svgBgColor: const Color(0xFFAFECEF),
            onTap: () {}),
        nkSmallSizeBox(),
        orderOptions(
          title: draft,
          count: '10',
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color(0xFFBCF0DA),
        ),
      ],
    );
  }

  Widget orderOptions(
      {required String title,
      required String count,
      required String svg,
      required Color svgBgColor,
      VoidCallback? onTap}) {
    SvgPicture svgComponet = SvgPicture.asset(
      svg,
      height: AppDimensions.instance!.height * 0.03,
      fit: BoxFit.contain,
    );
    return MyCommnonContainer(
      onTap: onTap,
      //margin: nkSymmetricPadding(vertical: 0),

      isCommonBorder: true,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ClipOval(
                child: ColoredBox(
                    color: svgBgColor,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: svgComponet,
                    )),
              ),
            ),
            //nkExtraSmallSizeBox(),

            Expanded(
              flex: 4,
              child: Column(
                //spacing: 0.2,
                children: [
                  MyRegularText(
                    label: title,
                  ),
                  MyRegularText(
                    label: count,
                  )
                ],
              ),
            )
          ]),
    );
  }
}
