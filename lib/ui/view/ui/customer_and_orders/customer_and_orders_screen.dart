import 'dart:io';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/theme/get_theme.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../components/color/colors.dart';
import '../../../components/widgets/my_regular_text.dart';
import '../../../theme/custom_fonts.dart';
import '../../../utills/enum/filter_date_enum.dart';
import '../dashboard1/provider/dash_models.dart';
import '../products/staff_controller.dart';
import 'csord_model/customers_orders_model.dart';
import 'cus_provider/cus_provider.dart';
import 'customer_dashbord/customer_dashbord_screen.dart';
import 'widgets/notification_widget.dart';

class tableee extends StatefulWidget {
  @override
  State<tableee> createState() => _tableeeState();
}

class _tableeeState extends State<tableee> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
    });

    Provider.of<CustomersProvider>(context, listen: false).fetchCustomerData();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: calender()),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: FrozenHeaderTable(
                scrollController: _scrollController1,
              )),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomTotalWidget(
                scrollController: _scrollController2, provider: provider),
          ),
        ],
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
                        height: isSmallScreen
                            ? 29
                            : MediaQuery.of(context).size.height * 0.03,
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
                        physics: const ClampingScrollPhysics(),
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
          profiloe(),
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

            return CustomButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dialog(
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: Colors.grey[200],
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              side: BorderSide.none,
                            ),
                            elevation: 24.0,
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
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
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
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
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
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
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
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12.0),
                                // Fourth row - Address
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
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
                                            border:
                                                Border.all(color: Colors.grey),
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
                                            border:
                                                Border.all(color: Colors.grey),
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
                                            border:
                                                Border.all(color: Colors.grey),
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
                                        border: Border.all(color: Colors.grey),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            businessName: bsNameController.text,
                                            businessNo: bsNumController
                                                .text, // Provide default or empty values if not applicable
                                          );

                                          try {
                                            await provider.addCustomer(
                                                admin: updatedAdmin,
                                                salsmanId: customer!.salesmanId
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
                                            borderRadius: BorderRadius.circular(
                                                4.0), // Border radius
                                          ),
                                        ),
                                        child: const Text(
                                          'Add Customer',
                                          style: TextStyle(color: Colors.white),
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
            );
          });
    });
  }
}

class BottomTotalWidget extends StatelessWidget {
  const BottomTotalWidget({
    super.key,
    required ScrollController scrollController,
    required this.provider,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final CustomersProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.orderTotalList.isEmpty || provider.orderTotalList.length < 7) {
      return const LoadingToNoDataWidget();
    }
    return Row(
      children: [
        _buildTableCell(
          padding: EdgeInsets.zero,
          Container(
            width: 200,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: provider.filteredCustomers.length >= 10
                      ? Container(
                          width: 3 * 62.0,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_double_arrow_left,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed: provider.currentPage > 1
                                      ? () {
                                          provider.goToPreviousPage();
                                        }
                                      : null,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: List.generate(
                                      provider.totalPages > 0 ? 3 : 0,
                                      (index) {
                                        if (provider.totalPages <= 0) {
                                          return Container();
                                        }
                                        int firstPage = (provider.currentPage -
                                                1)
                                            .clamp(1, provider.totalPages - 2);
                                        int visiblePage = firstPage + index;
                                        visiblePage = visiblePage.clamp(
                                            1, provider.totalPages);

                                        return GestureDetector(
                                          onTap: visiblePage <=
                                                  provider.totalPages
                                              ? () {
                                                  provider.currentPage =
                                                      visiblePage;
                                                  provider.refreshCurrentPage();
                                                }
                                              : null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              height: 40,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                color: provider.currentPage ==
                                                        visiblePage
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$visiblePage',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        provider.currentPage ==
                                                                visiblePage
                                                            ? primaryColor
                                                            : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                              ),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_double_arrow_right,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed:
                                      provider.currentPage < provider.totalPages
                                          ? () {
                                              provider.goToNextPage();
                                            }
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ),
                Container(
                  color: Colors.grey[200],
                  // height: 58,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              ],
            ),
          ),
          270,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            child: Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  _buildTableCell(
                    Center(
                      child: CustomText(
                          content: formatAmount(0),
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    120,
                  ),
                  _buildTableCell(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomText(
                            content:
                                formatAmount(provider.orderTotalList[0].sales),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          flex: 2,
                          child: CustomText(
                            content: formatAmount(
                                provider.orderTotalList[1].delivery),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          flex: 2,
                          child: CustomText(
                            content: formatAmount(
                                provider.orderTotalList[2].payment),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    350,
                  ),
                  _buildTableCell(
                    Center(
                      child: CustomText(
                        content:
                            formatAmount(provider.orderTotalList[3].estimate),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Center(
                      child: CustomText(
                        content:
                            formatAmount(provider.orderTotalList[4].preOrder),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Center(
                      child: CustomText(
                        content: formatAmount(provider.orderTotalList[5].draft),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Center(
                      child: CustomText(
                        content:
                            formatAmount(provider.orderTotalList[6].cancelled),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
        return EventType.weekly;
    }
  }
}

class EventTypeDropdown extends StatefulWidget {
  final EventType initialValue;
  final Function(EventType) onChanged;
  final List<String> defaultEventDays;
  final String customerId;
  final int eventStatus;
  final CustomersProvider provider;

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
      physics: const ClampingScrollPhysics(),
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
            width: 90,
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
                        _selectDate(context);
                      } else {
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
                physics: const ClampingScrollPhysics(),
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
  final ScrollController scrollController;

  const FrozenHeaderTable({required this.scrollController, Key? key})
      : super(key: key);

  @override
  State<FrozenHeaderTable> createState() => _FrozenHeaderTableState();
}

class _FrozenHeaderTableState extends State<FrozenHeaderTable> {
  final CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  final StaffController staffController = Get.put(StaffController());
  final LeadsController leadsController = Get.put(LeadsController());
  final ProductsController prodController = Get.put(ProductsController());
  final CustomerAndOrderController customerController =
      Get.put(CustomerAndOrderController());
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

  String? startDate;
  String? endDate;
  String dropdownValue = 'Today';

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double totalTableWidth = 120 + 350 + 140 + 140 + 140 + 140 + 140 + 100;
    double fixedRowHeight = isLandscape
        ? MediaQuery.of(context).size.height / 9.05
        : MediaQuery.of(context).size.height / 9 -
            MediaQuery.of(context).size.height * 0.032;
    return Consumer<CustomersProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (provider.errorMessage.isNotEmpty) {
        return Expanded(
          child: Column(children: [
            Container(
              color: primaryColor,
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                  5: FlexColumnWidth(2),
                  6: FlexColumnWidth(2),
                  7: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      _buildTableHeader1('Sales'),
                      _buildTableHeader1('Sales / Delivery / Payments'),
                      _buildTableHeader1('Estimates'),
                      _buildTableHeader1('Pre-Order'),
                      _buildTableHeader1('Drafts'),
                      _buildTableHeader1('Cancelled'),
                      _buildTableHeader1('Visits'),
                      _buildTableHeader1('SE'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
            ),
            Center(child: NodataWidget()),
          ]),
        );
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
              return Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 270,
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
                            270,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              controller: vertical,
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: List.generate(
                                  provider.filteredCustomers.length,
                                  (index) {
                                    var customer =
                                        provider.filteredCustomers[index];
                                    return Container(
                                      height:
                                          fixedRowHeight,
                                      color: index.isEven
                                          ? Colors.grey[50]
                                          : Colors.white,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 220,
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              children: [
                                                ClipOval(
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    color: Colors.grey[200],
                                                    child: Image.network(
                                                      'http://16.50.232.153:3000/uploads/${customer.imageUrl}',
                                                      fit: BoxFit.cover,
                                                      width: 34,
                                                      height: 34,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Icon(
                                                            Icons.person,
                                                            color: Colors.grey,
                                                            size: 30,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onTap: () {
                                                    // Your existing onTap logic
                                                    customerAndOrderController
                                                        .setCustomerId(customer
                                                                .customerId ??
                                                            '');
                                                    provider
                                                        .setCurrentMonthDates();
                                                    prodController
                                                        .selectedCustomerName
                                                        .value = customer
                                                            .businessName ??
                                                        '';
                                                    prodController
                                                            .selectedCustomerId
                                                            .value =
                                                        customer.customerId ??
                                                            '';
                                                    prodController
                                                        .selectedCustomerImageUrl
                                                        .value = customer
                                                            .imageUrl ??
                                                        '';
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomerDachScreen(
                                                          year: 2024,
                                                          startDate: provider
                                                              .selectedStartDate,
                                                          endDate: provider
                                                              .selectedEndDate,
                                                          isFromOrder: true,
                                                        ),
                                                      ),
                                                    );

                                                    provider
                                                        .fetchCustomerDashboardData(
                                                      customer.customerId ?? '',
                                                      2024,
                                                      provider
                                                          .selectedStartDate,
                                                      provider.selectedEndDate,
                                                    );
                                                    provider
                                                        .fetchCustomerDashboardRevenueData(
                                                      customer.customerId ?? '',
                                                      2024,
                                                      provider
                                                          .selectedStartDate,
                                                      provider.selectedEndDate,
                                                    );
                                                    provider
                                                        .fetchCustomerDashboardCountData(
                                                      customer.customerId ?? '',
                                                    );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        customer.businessName ??
                                                            'Business Name',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        customer.town ?? 'Town',
                                                        style: TextStyle(
                                                            fontSize: 11.5),
                                                      ),
                                                      Text(
                                                        customer.email ??
                                                            'email@example.com',
                                                        style: TextStyle(
                                                            fontSize: 11.5),
                                                      ),
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
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable columns
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: widget.scrollController,
                        physics: ClampingScrollPhysics(),
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
                                      120,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'Sales / Delivery / Payments',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      350,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'Estimates',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      140,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'Pre-Order',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins_Regular',
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      140,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'Drafts',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins_Regular',
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      140,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'Cancelled',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins_Regular',
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      140,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'Visits',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins_Regular',
                                        maxLine: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      140,
                                    ),
                                    _buildTableHeader(
                                      CustomText(
                                        content: 'SE',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins_Regular',
                                      ),
                                      100,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  controller: vertical1,
                                  physics: const ClampingScrollPhysics(),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        provider.filteredCustomers.length,
                                    itemBuilder: (context, index) {
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
                                            _buildTableCell(
                                              Center(
                                                child: CustomText(
                                                  content: formatAmount('0'),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              120,
                                            ),
                                            _buildTableCell(
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (customer.totalSales ==
                                                                0 ||
                                                            customer.totalSales ==
                                                                null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
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
                                                          false),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (customer.delivery ==
                                                                0 ||
                                                            customer.delivery ==
                                                                null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
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
                                                          false),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    flex: 2,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (customer.payment ==
                                                                0 ||
                                                            customer.payment ==
                                                                null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
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
                                                          false),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              350,
                                            ),
                                            _buildTableCell(
                                              _buildDataCell(
                                                  customer.estimates
                                                          ?.toString() ??
                                                      '0',
                                                  '\$${customer.estimatesPrice?.toString() ?? '0'}',
                                                  Colors.purple,
                                                  true),
                                              140,
                                            ),
                                            _buildTableCell(
                                              _buildDataCell(
                                                  customer.preOrder.toString(),
                                                  '\$${customer.preOrderPrice?.toString() ?? '0'}',
                                                  Colors.grey,
                                                  true),
                                              140,
                                            ),
                                            _buildTableCell(
                                              _buildDataCell(
                                                  customer.drafts.toString(),
                                                  customer.orderData.draft
                                                      .takeLast(customer.drafts)
                                                      .fold(
                                                          0.0,
                                                          (a, b) =>
                                                              a + b.orderTotal)
                                                      .toString(),
                                                  Colors.red,
                                                  true),
                                              140,
                                            ),
                                            _buildTableCell(
                                              _buildDataCell(
                                                  customer.cancelled
                                                          ?.toString() ??
                                                      '0',
                                                  '\$${customer.cancelled?.toString() ?? '0'}',
                                                  Colors.purple,
                                                  true),
                                              140,
                                            ),
                                            _buildTableCell(
                                              EventTypeDropdown(
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
                                              140,
                                            ),
                                            _buildTableCell(
                                              Center(
                                                  child: CustomText(
                                                      content: customer
                                                          .salesmanName)),
                                              100,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      }
    });
  }

  Widget _buildTableHeader1(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
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
  return Container(
    height: 58,
    width: width,
    padding: padding,
    child: child,
  );
}

Widget _buildDataCell(String count, String amount, Color color, bool isCenter) {
  return Row(
    mainAxisAlignment:
        isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
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
          child: CustomText(
            content: count,
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: 4),
      CustomText(
        content: formatAmount(amount),
        fontSize: 12,
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
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: availableWidth),
                child: Theme(
                  data: NkGetXTheme.lightTheme,
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
                                          ? customer.businessName
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
              ),
            );
          }),
        ),
      );
    },
  );
}

String formatAmount(dynamic value) {
    final currencySymbol = SessionHelper.settingsData
          ?.firstWhere(
            (setting) => setting.key == 'currency_symbol',
            orElse: () => AllCompanySettingsData(
              key: 'currency_symbol',
              value: '',
            ),
          )
          .value ??
      '';
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
  String formattedAmount = amount.toStringAsFixed(2);
  return currencySymbol + formattedAmount;
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) => skip(length - n).toList();
}
