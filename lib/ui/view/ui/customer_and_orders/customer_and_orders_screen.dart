// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, use_build_context_synchronously, empty_catches

import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/event_type_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../components/color/colors.dart';
import '../../../theme/custom_fonts.dart';
import '../../../utills/enum/filter_date_enum.dart';
import '../dashboard1/provider/dash_models.dart';
import '../products/staff_controller.dart';
import 'csord_model/customers_orders_model.dart';
import 'cus_provider/cus_provider.dart';
import 'customer_dashbord/customer_dashbord_screen.dart';

class Tableee extends StatefulWidget {
  const Tableee({super.key});

  @override
  State<Tableee> createState() => _TableeeState();
}

class _TableeeState extends State<Tableee> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<CustomersProvider>(context, listen: false).currentPage = 1;

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
      if (_scrollController3.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController3.position.pixels) {
        _scrollController3.jumpTo(_scrollController1.position.pixels);
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
      if (_scrollController3.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController3.position.pixels) {
        _scrollController3.jumpTo(_scrollController2.position.pixels);
      }
    });

    _scrollController3.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController3.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController3.position.pixels);
      }
      if (_scrollController2.hasClients &&
          _scrollController3.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController3.position.pixels);
      }
    });

    Provider.of<CustomersProvider>(context, listen: false).fetchCustomerData();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomersProvider>(context);
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        actions: [
          Expanded(child: calender()),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: TopTotalWidget(
                scrollController: _scrollController3, provider: provider),
          ),
          Column(
            children: [
              const SizedBox(height: 58),
              Expanded(
                  child: FrozenHeaderTable(
                scrollController: _scrollController1,
              )),
              // const SizedBox(height: 58),
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
                    const SizedBox(width: 5),
                    SizedBox(
                      height: isSmallScreen ? 35 : 45,
                      width: isSmallScreen ? 90 : 120,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade50,
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 4.0, top: 4.0, bottom: 1.0),
                          child: DropdownButton<FilterDateEnum>(
                            value: provider.selectedFilter,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                provider.onFilterChanged(newValue);
                              }
                            },
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
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                                  : DateFormat('dd-MM-yyyy')
                                                      .format(DateTime.parse(
                                                          provider
                                                              .selectedStartDate)),
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
                                                  : DateFormat('dd-MM-yyyy')
                                                      .format(DateTime.parse(
                                                          provider
                                                              .selectedEndDate)),
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
                            const SizedBox(width: 15),
                            addCustomer(context),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          NotificationWidget(
            startDate: provider.selectedStartDate,
            endDate: provider.selectedEndDate,
          ),
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
          TextEditingController deliveryTownController =
              TextEditingController();
          TextEditingController deliveryStateController =
              TextEditingController();
          TextEditingController deliveryZipcodeController =
              TextEditingController();

          TextEditingController remarkController = TextEditingController();

          bool sameAsAbove = false;

          return SizedBox(
            height: isSmallScreen ? 29 : 38,
            width: isSmallScreen ? 87 : 100,
            child: CustomButton(
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
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
                                        'Add Customer',
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
                                          'Business Name', Assets.icBusiness),
                                      buildInputField(addressController,
                                          'Address', Assets.icLocation),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildInputField(
                                                townController,
                                                'City or Suburb',
                                                Assets.icCity),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                stateController,
                                                'State',
                                                Assets.icState),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                zipcodeController,
                                                'Zip/Post/Pin Code',
                                                Assets.icZipcode),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildInputField(
                                                phoneController,
                                                'Mobile Number',
                                                Assets.icMobile),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                emailController,
                                                'Email',
                                                Assets.icEmail),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                telephoneController,
                                                'Business Reg.No',
                                                Assets.icBusinessReg),
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
                                                Assets.icUser),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                contactNumController,
                                                'Contact Number',
                                                Assets.icPhone),
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
                                                    deliveryTownController
                                                            .text =
                                                        townController.text;
                                                    deliveryStateController
                                                            .text =
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
                                      buildInputField(
                                          deliveryAddressController,
                                          'Delivery Address',
                                          Assets.icLocation),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildInputField(
                                                deliveryTownController,
                                                'City or Suburb',
                                                Assets.icCity),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                deliveryStateController,
                                                'State',
                                                Assets.icState),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: buildInputField(
                                                deliveryZipcodeController,
                                                'Zip/Post/Pin Code',
                                                Assets.icZipcode),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 30,
                                        child: Row(
                                          children: [
                                            Spacer(),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                                child: Text("Company logo"))
                                          ],
                                        ),
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
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 18.0),
                                                  labelText: 'Remark',
                                                  labelStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade600),
                                                  prefixIcon: filledIcon(
                                                      Assets.icRemark),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.blue,
                                                            width: 1.5),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade400,
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      blurRadius: 6.0,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 18.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.image,
                                                        color: Colors
                                                            .grey.shade600,
                                                        size: 28.0,
                                                      ),
                                                      const SizedBox(
                                                          width: 12.0),
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
                                          final updatedAdmin = CustomerDashMo(
                                            fullname: nameController.text,
                                            mobileno: phoneController.text,
                                            email: emailController.text,
                                            town: townController.text,
                                            state: stateController.text,
                                            zipcode: int.parse(
                                                zipcodeController.text),
                                            address: addressController.text,
                                            businessName: bsNameController.text,
                                            businessNo: bsNumController.text,
                                          );

                                          try {
                                            await provider.addCustomer(
                                                admin: updatedAdmin,
                                                salsmanId: customer!.salesmanId
                                                    .toString(),
                                                image: provider.imageFile);
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
                        );
                      },
                    );
                  },
                );
              },
              text: 'Customer',
            ),
          );
        },
      );
    });
  }

  Widget buildInputField(
      TextEditingController controller, String labelText, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            prefixIcon: filledIcon(icon),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                  color: Colors.grey.shade400, width: 1.0), // Neutral border
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TopTotalWidget extends StatelessWidget {
  const TopTotalWidget({
    super.key,
    required ScrollController scrollController,
    required this.provider,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final CustomersProvider provider;

  @override
  Widget build(BuildContext context) {
    final searchController = provider.searchController;
    final CustomerAndOrderController customerAndOrderController =
        CustomerAndOrderController();
    SubscriptionController subscriptionController =
        Get.find<SubscriptionController>();
    double totalTableWidth =
        120 + 140 + 140 + 140 + 140 + 140 + 140 + 140 + 160;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: _buildTableHeader(
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (query) {
                  provider.updateSearchQuery(query);
                  log("Entered query : $query");
                },
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.2),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 9.5,
                    vertical: 9.5,
                  ),
                ),
              ),
            ),
            260,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: SizedBox(
              width: totalTableWidth,
              child: Container(
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
                            if (provider.yearsListOfAllList.isNotEmpty) {
                              customerAndOrderController.selectedYear.value =
                                  provider.yearsListOfAllList.first.orderYears
                                          ?.toString() ??
                                      '';
                            } else {
                              customerAndOrderController.selectedYear.value =
                                  '';
                            }

                            customerAndOrderController.years.value = provider
                                .yearsListOfAllList
                                .map((yearItem) =>
                                    yearItem.orderYears?.toString() ?? '')
                                .toList();

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20, top: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (subscriptionController
                                            .customerYearComparison.value !=
                                        'true') {
                                      showUpgradePlanDialog(context);
                                    }
                                  },
                                  child: AbsorbPointer(
                                    absorbing: subscriptionController
                                            .customerYearComparison.value !=
                                        'true',
                                    child: DropdownButton<String>(
                                      iconSize: 14,
                                      value: customerAndOrderController
                                              .selectedYear.value.isNotEmpty
                                          ? customerAndOrderController
                                              .selectedYear.value
                                          : null,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          customerAndOrderController
                                              .updateSelectedYear(newValue);
                                        }
                                      },
                                      items: customerAndOrderController.years
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: value.length > 4
                                                    ? 8.0
                                                    : 12.0,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: myFont,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      dropdownColor: Colors.white,
                                      isExpanded: false,
                                      underline: Container(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                      120,
                    ),
                    _buildTableHeader(
                      const Text(
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
                      120,
                    ),
                    _buildTableHeader(
                      const Text(
                        'Deliveries',
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
                      const Text(
                        'Payments',
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
                      const Text(
                        'Bookings',
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
                      140,
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
                      140,
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
                      140,
                    ),
                    _buildTableHeader(
                      const Text(
                        'Visit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins_Regular',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      180,
                    ),
                    // _buildTableHeader(
                    //   const Center(
                    //     child: Text(
                    //       'Staff',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontFamily: 'Poppins_Regular',
                    //       ),
                    //     ),
                    //   ),
                    //   120,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 3 * 62.0,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: provider.totalPages > 1
                                ? List.generate(3, (index) {
                                    int firstPage;

                                    if (provider.totalPages == 2) {
                                      firstPage = 1;
                                    } else if (provider.currentPage == 1) {
                                      firstPage = 1;
                                    } else if (provider.currentPage ==
                                        provider.totalPages) {
                                      firstPage = provider.totalPages - 2;
                                    } else {
                                      firstPage = provider.currentPage - 1;
                                    }

                                    int visiblePage = firstPage + index;
                                    if (visiblePage < 1 ||
                                        visiblePage > provider.totalPages) {
                                      return Container();
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        provider.currentPage = visiblePage;
                                        provider.refreshCurrentPage();
                                      },
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
                                                color: provider.currentPage ==
                                                        visiblePage
                                                    ? primaryColor
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                : [],
                          ),
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
                  ),
                ),
                const Spacer(),
                Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          fontFamily: "BarlowCondensed",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5)
              ],
            ),
          ),
          260,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  _buildTableCell(
                    Center(
                      child: Text(
                          formatAmount(
                              provider.orderTotalList[7].previousYearSale),
                          style: const TextStyle(
                              fontFamily: "BarlowCondensed",
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                    ),
                    120,
                  ),
                  _buildTableCell(
                    const SizedBox.shrink(),
                    20,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[0].sales),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[1].delivery),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[2].payment),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[4].preOrder),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[3].estimate),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[5].draft),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatAmount(provider.orderTotalList[6].cancelled),
                            style: const TextStyle(
                                fontFamily: "BarlowCondensed",
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    140,
                  ),
                  _buildTableCell(
                    const Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    160,
                  ),
                  // _buildTableCell(
                  //   const Text(
                  //     '',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 16,
                  //     ),
                  //   ),
                  //   120,
                  // ),
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
                                                  labelText: 'City or Suburb',
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
                                                                    .imageFile
                                                                    .path,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.file(
                                                                File(provider
                                                                    .imageFile
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
                                              businessNo: bsNumController.text,
                                            );

                                            try {
                                              await provider.addLead(
                                                  admin: updatedAdmin,
                                                  salsmanId: customer!
                                                      .salesmanId
                                                      .toString());
                                              Navigator.of(context).pop();
                                            } catch (error) {}
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
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

// enum EventType {
//   select,
//   weekly,
//   fortnightly,
//   monthly,
//   daily,
// }

// extension EventTypeExtension on EventType {
//   String get displayName {
//     switch (this) {
//       case EventType.select:
//         return "-Select-";
//       case EventType.weekly:
//         return "Weekly";
//       case EventType.fortnightly:
//         return "Fortnightly";
//       case EventType.monthly:
//         return "Monthly";
//       case EventType.daily:
//         return "Daily";
//     }
//   }

//   int get value {
//     switch (this) {
//       case EventType.select:
//         return 0;
//       case EventType.weekly:
//         return 2;
//       case EventType.fortnightly:
//         return 3;
//       case EventType.monthly:
//         return 4;
//       case EventType.daily:
//         return 5;
//     }
//   }

//   static EventType fromValue(int value) {
//     switch (value) {
//       case 0:
//         return EventType.select;
//       case 2:
//         return EventType.weekly;
//       case 3:
//         return EventType.fortnightly;
//       case 4:
//         return EventType.monthly;
//       case 5:
//         return EventType.daily;
//       default:
//         return EventType.weekly;
//     }
//   }
// }

// class EventTypeDropdown extends StatefulWidget {
//   final EventType initialValue;
//   final Function(EventType) onChanged;
//   final List<String> defaultEventDays;
//   final String customerId;
//   final int eventStatus;
//   final CustomersProvider provider;

//   const EventTypeDropdown({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     required this.defaultEventDays,
//     required this.customerId,
//     required this.eventStatus,
//     required this.provider,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _EventTypeDropdownState createState() => _EventTypeDropdownState();
// }

// class _EventTypeDropdownState extends State<EventTypeDropdown> {
//   SubscriptionController subscriptionController =
//       Get.find<SubscriptionController>();

//   late EventType selectedValue;

//   @override
//   void initState() {
//     super.initState();
//     selectedValue = widget.initialValue;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       physics: const ClampingScrollPhysics(),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//                 color: Color(0xffdddefc),
//                 borderRadius: BorderRadius.all(Radius.circular(5))),
//             height: 38,
//             width: 90,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8, right: 2),
//               child: GestureDetector(
//                 onTap: () {
//                   if (subscriptionController.visitSetting.value != 'true') {
//                     showUpgradePlanDialog(context);
//                   }
//                 },
//                 child: AbsorbPointer(
//                   absorbing:
//                       subscriptionController.visitSetting.value != 'true',
//                   child: DropdownButton<EventType>(
//                     iconSize: 17.5,
//                     value: selectedValue,
//                     onChanged: (EventType? newValue) {
//                       if (newValue != null) {
//                         setState(() {
//                           selectedValue = newValue;
//                           widget.onChanged(newValue);

//                           if (newValue == EventType.fortnightly) {
//                             _selectDate(context, 3);
//                           } else if (newValue == EventType.daily) {
//                             widget.provider.addEvent(
//                               widget.customerId,
//                               // widget.eventStatus,
//                               5,
//                               [DateTime.now().toIso8601String()],
//                             );
//                             widget.provider.fetchCustomerData();
//                           } else if (newValue == EventType.monthly) {
//                             widget.provider.addEvent(
//                               widget.customerId,
//                               // widget.eventStatus,
//                               4,
//                               [DateTime.now().toIso8601String()],
//                             );
//                             widget.provider.fetchCustomerData();
//                           } else if (newValue == EventType.weekly) {
//                             showDaysOfWeekPopup(
//                               context,
//                               widget.defaultEventDays,
//                               widget.customerId,
//                               newValue.value,
//                               widget.provider,
//                             );
//                           } else {
//                             showDaysOfWeekPopup(
//                               context,
//                               widget.defaultEventDays,
//                               widget.customerId,
//                               newValue.value,
//                               widget.provider,
//                             );
//                           }
//                         });
//                       }
//                     },
//                     items: EventType.values
//                         .map<DropdownMenuItem<EventType>>((EventType value) {
//                       return DropdownMenuItem<EventType>(
//                         value: value,
//                         child: Text(
//                           value.displayName,
//                           style: const TextStyle(
//                             fontSize: 11.5,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.bold,
//                             //fontFamily: 'Poppins_Regular',
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                     underline: Container(),
//                     isExpanded: true,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 5.0,
//           ),
//           if (widget.defaultEventDays.isNotEmpty)
//             SizedBox(
//               width: 24,
//               height: 24,
//               child: GestureDetector(
//                   onTap: () {
//                     showDaysOfWeekPopup(context, widget.defaultEventDays,
//                         widget.customerId, widget.eventStatus, widget.provider);
//                   },
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'i',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   )),
//             ),
//         ],
//       ),
//     );
//   }

//   void showDaysOfWeekPopup(BuildContext context, List<String> selectedDays,
//       String cusID, int eventSt, CustomersProvider provider) {
//     final List<String> daysOfWeek = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//     ];
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               content: SingleChildScrollView(
//                 physics: const ClampingScrollPhysics(),
//                 child: ListBody(
//                   children: daysOfWeek.map((day) {
//                     return CheckboxListTile(
//                       title: Text(day),
//                       value: selectedDays.contains(day.toLowerCase()),
//                       onChanged: (bool? value) {
//                         setState(() {
//                           if (value == true) {
//                             selectedDays.add(day.toLowerCase());
//                           } else {
//                             selectedDays.remove(day.toLowerCase());
//                           }
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xffdcdefc),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4.0),
//                         ),
//                       ),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(color: primaryColor),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4.0),
//                         ),
//                       ),
//                       child: const Text(
//                         'Add To Calender',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed: () async {
//                         await provider.addEvent(
//                           cusID,
//                           eventSt,
//                           selectedDays,
//                         );
//                         provider.fetchCustomerData();
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _selectDate(BuildContext context, int eventStatus) async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (selectedDate != null) {
//       widget.provider.addEvent(
//         widget.customerId,
//         eventStatus,
//         // widget.eventStatus,
//         [selectedDate.toIso8601String()],
//       );
//       widget.provider.fetchCustomerData();
//     }
//   }
// }

class FrozenHeaderTable extends StatefulWidget {
  final ScrollController scrollController;

  const FrozenHeaderTable({required this.scrollController, super.key});

  @override
  State<FrozenHeaderTable> createState() => _FrozenHeaderTableState();
}

class _FrozenHeaderTableState extends State<FrozenHeaderTable> {
  final CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  final StaffController staffController = Get.put(StaffController());
  final LeadsController leadsController = Get.put(LeadsController());
  final ProductsController prodController = Get.find<ProductsController>();
  final subscriptionController = Get.find<SubscriptionController>();

  String? startDate;
  String? endDate;
  String dropdownValue = 'Today';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomersProvider>();
      customerAndOrderController.initializeYears(provider.yearsListOfAllList);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double totalTableWidth =
        120 + 140 + 140 + 140 + 140 + 140 + 140 + 140 + 160;

    double fixedRowHeight = isLandscape
        ? fullScreenHeight(context) / 9.05
        : (fullScreenHeight(context) - (66 * 3)) / 10;

    return Consumer<CustomersProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (provider.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            provider.errorMessage.endsWith("Failed to load data")
                ? "NO CUSTOMERS FOUND"
                : provider.errorMessage.contains("No element")
                    ? "NO CUSTOMERS FOUND"
                    : provider.errorMessage,
          ),
        );
      } else if (provider.filteredCustomers.isEmpty) {
        return const Center(child: Text('No customers found'));
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: vertical,
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 58.0),
                        child: Column(
                          children: List.generate(
                            provider.filteredCustomers.length,
                            (index) {
                              var customer = provider.filteredCustomers[index];
                              return Container(
                                height: fixedRowHeight,
                                color: index.isEven
                                    ? Colors.grey[50]
                                    : Colors.white,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                color: Colors.grey[200],
                                                child: Image.network(
                                                  '${ApiConstants.baseUrl}uploads/${customer.imageUrl}',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
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
                                            Expanded(
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () async {
                                                  if (subscriptionController
                                                          .customerDashboardView
                                                          .value ==
                                                      'true') {
                                                    provider
                                                        .setCurrentMonthDates();
                                                    provider
                                                        .fetchCustomerDashboardData(
                                                      customer.customerId,
                                                    );
                                                    provider
                                                        .fetchCustomerDashboardRevenueData(
                                                      customer.customerId,
                                                    );
                                                    provider
                                                        .fetchCustomerDashboardCountData(
                                                            customer
                                                                .customerId);
                                                    prodController
                                                            .selectedCustomerName
                                                            .value =
                                                        customer.businessName;
                                                    prodController
                                                            .selectedCustomerId
                                                            .value =
                                                        customer.customerId;
                                                    prodController
                                                        .selectedCustomerImageUrl
                                                        .value = customer.imageUrl;
                                                    customerAndOrderController
                                                        .setCustomerId(customer
                                                            .customerId);
                                                    log('Customer ID == : ${customer.customerId}, Controller Cus ID: ${prodController.selectedCustomerId.value}');
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100));

                                                    final now = DateTime.now();
                                                    final dateFormat =
                                                        DateFormat(
                                                            'yyyy-MM-dd');

                                                    final firstDayOfYear =
                                                        DateTime(
                                                            now.year, 1, 1);
                                                    final lastDayOfYear =
                                                        DateTime(
                                                            now.year, 12, 31);

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CustomerDachScreen(
                                                          year: 2024,
                                                          startDate:
                                                              dateFormat.format(
                                                                  firstDayOfYear),
                                                          endDate:
                                                              dateFormat.format(
                                                                  lastDayOfYear),
                                                          isFromOrder: true,
                                                          cusId: customer
                                                              .customerId,
                                                          cusName: customer
                                                              .businessName,
                                                          cusImage:
                                                              customer.imageUrl,
                                                          productsController:
                                                              prodController,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    showUpgradePlanDialog(
                                                        context);
                                                  }
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      customer.businessName,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      customer.town,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      customer.email,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: widget.scrollController,
                child: SizedBox(
                  width: totalTableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          controller: vertical1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 58),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildTableCell(
                                        Center(
                                          child: InkWell(
                                            onTap: () {
                                              _showOrderDataDialog(
                                                  context,
                                                  customer,
                                                  customer.orderData
                                                      .previousYearSales);
                                            },
                                            child: CustomText(
                                              content: formatAmount(
                                                  customer.previousYearSales),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        120,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.sales == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                    context,
                                                    customer,
                                                    customer
                                                        .orderData.totalSales,
                                                  );
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.sales.toString(),
                                                  customer.totalSales
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.blue,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.delivery == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer.orderData
                                                          .outOfDiviery);
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.delivery.toString(),
                                                  customer.deliveryPrice
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.green.shade700,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.payment == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.payment);
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.payment.toString(),
                                                  customer.paymentPrice
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.orange,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.preOrder == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.preOrder);
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.preOrder.toString(),
                                                  customer.orderData.preOrder
                                                      .takeLast(customer
                                                          .preOrder
                                                          .toInt())
                                                      .fold(
                                                          0.0,
                                                          (a, b) =>
                                                              a + b.orderTotal)
                                                      .toString(),
                                                  Colors.cyan,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                        padding: EdgeInsets.zero,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.estimates == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.estimate);
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.estimates.toString(),
                                                  customer.estimatesPrice
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.purple,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.drafts == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer.orderData.draft);
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.drafts.toString(),
                                                  customer.orderData.draft
                                                      .takeLast(customer.drafts
                                                          .toInt())
                                                      .fold(
                                                          0.0,
                                                          (a, b) =>
                                                              a + b.orderTotal)
                                                      .toString(),
                                                  Colors.grey.shade700,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.cancelled == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found',
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.cancel);
                                                }
                                              },
                                              child: _buildDataCell(
                                                customer.cancelled.toString(),
                                                customer.orderData.cancel
                                                    .takeLast(customer.cancelled
                                                        .toInt())
                                                    .fold(
                                                        0.0,
                                                        (a, b) =>
                                                            a + b.orderTotal)
                                                    .toString(),
                                                Colors.red.shade600,
                                                false,
                                              ),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          child: EventTypeDropdown(
                                            initialValue:
                                                EventTypeExtension.fromValue(
                                                    customer.eventType),
                                            onChanged: (EventType newType) {},
                                            defaultEventDays:
                                                customer.eventDays,
                                            customerId: customer.customerId,
                                            eventStatus: customer.eventType,
                                            eventPeriod: customer.eventPeriod,
                                            provider: provider,
                                          ),
                                        ),
                                        160,
                                      ),
                                      // _buildTableCell(
                                      //   Padding(
                                      //     padding:
                                      //         const EdgeInsets.all(4.0),
                                      //     child: Center(
                                      //       child: CustomText(
                                      //         content:
                                      //             customer.salesmanName,
                                      //         fontSize: 12,
                                      //       ),
                                      //     ),
                                      //   ),
                                      //   120,
                                      // ),
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
              ),
            ),
          ],
        );
      }
    });
  }

  void _showOrderDataDialog(BuildContext context, CustomerModelxx customer,
      List<Order> filteredOrders) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double availableWidth = constraints.maxWidth;
                      double fontSize = availableWidth * 0.017;
                      double padding = availableWidth / 100;
                      double fixedIconSize = fontSize;
                      double flexWidth = availableWidth / 10;

                      return Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: filteredOrders.length < 11
                                    ? null
                                    : fullScreenHeight(context) * 0.7,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    dataRowHeight: fontSize * 5.5,
                                    headingRowHeight:
                                        fullScreenWidth(context) > 740
                                            ? 45
                                            : 75,
                                    headingRowColor:
                                        const WidgetStatePropertyAll(
                                            primaryColor),
                                    columnSpacing: 10,
                                    headingTextStyle: TextStyle(
                                        fontSize: fontSize + 1,
                                        color: white,
                                        fontWeight: FontWeight.w700),
                                    columns: const [
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                      DataColumn(label: SizedBox()),
                                    ],
                                    rows: filteredOrders.isEmpty
                                        ? [
                                            const DataRow(cells: [
                                              DataCell(
                                                  Text('Record Not Found')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                            ])
                                          ]
                                        : filteredOrders.map((order) {
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 1.5,
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius:
                                                              (fixedIconSize /
                                                                      2) +
                                                                  2,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xffe6ecff),
                                                          child: Icon(
                                                              Icons.person,
                                                              size:
                                                                  fixedIconSize,
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                        SizedBox(
                                                            width: padding),
                                                        Flexible(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                customer != null
                                                                    ? customer
                                                                        .businessName
                                                                    : 'N/A',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                customer != null
                                                                    ? customer
                                                                        .fullname
                                                                    : 'N/A',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                customer != null
                                                                    ? customer
                                                                        .mobileno
                                                                    : 'N/A',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                customer != null
                                                                    ? customer
                                                                        .email
                                                                    : 'N/A',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 0.9,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDetailedOrderInvoiceDialog(
                                                            context,
                                                            order.orderId,
                                                            false);
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          order.orderId,
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize:
                                                                  fontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 1,
                                                    child: Center(
                                                      child: Text(
                                                        order.orderCreatAt !=
                                                                null
                                                            ? getFormattedOrderCreatAt(
                                                                order
                                                                    .orderCreatAt
                                                                    .toString())
                                                            : 'N/A',
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 1,
                                                    child: Center(
                                                      child: Text(
                                                        '${order.fullname} ${order.lastname}',
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 1,
                                                    child: Center(
                                                      child: Text(
                                                        formatAmount(
                                                            order.orderTotal),
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 0.9,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // showDetailedOrderInvoiceDialog(
                                                        //     context,
                                                        //     order.orderId,
                                                        //     true);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return InvoicePreview(
                                                              orderId:
                                                                  order.orderId,
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          order.invoiceId
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize:
                                                                  fontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 1.1,
                                                    child: Center(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              order.paymentStatus ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: order.paymentStatus ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Icon(
                                                              order.paymentStatus ==
                                                                      0
                                                                  ? Icons.close
                                                                  : Icons.done,
                                                              color: white,
                                                              size: 14.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: flexWidth * 1.1,
                                                    child: Center(
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color:
                                                              Color(0xffffdbb8),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15.0)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                  vertical:
                                                                      4.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                getStatusName(order
                                                                    .orderStatus),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              if (order.orderStatus ==
                                                                      2 &&
                                                                  order.deliveryDate !=
                                                                      null) ...[
                                                                Text(
                                                                  NKDateUtils.commonFullDateTimeFormat(
                                                                      NKDateUtils.formatStringUTCDateTime(order
                                                                          .deliveryDate!
                                                                          .toIso8601String())),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ]
                                                            ],
                                                          ),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: DataTable(
                                        dataRowHeight: 0,
                                        headingRowHeight: 30,
                                        headingRowColor:
                                            const WidgetStatePropertyAll(
                                                primaryColor),
                                        columnSpacing: 10,
                                        headingTextStyle: TextStyle(
                                            fontSize: fontSize + 2,
                                            color: white,
                                            fontWeight: FontWeight.w700),
                                        columns: [
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1.5,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 0.9,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1,
                                            child: const Center(
                                              child: Text(
                                                'Total',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1,
                                            child: Center(
                                              child: Text(
                                                formatAmount(
                                                    filteredOrders.fold<double>(
                                                  0.0,
                                                  (sum, order) =>
                                                      sum + (order.orderTotal),
                                                )),
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 0.9,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1.1,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1.2,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          const DataColumn(
                                              label: Expanded(
                                            child: Center(
                                              child: Text(
                                                '',
                                              ),
                                            ),
                                          )),
                                        ],
                                        rows: [
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                    width: flexWidth * 1.5),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                    width: flexWidth * 0.9),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                    width: flexWidth * 0.9),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                    width: flexWidth * 1.1),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                    width: flexWidth * 1.1),
                                              ),
                                              const DataCell(Text('')),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DataTable(
                                    dataRowHeight: fontSize * 5.5,
                                    headingRowHeight: 45,
                                    headingRowColor:
                                        const WidgetStatePropertyAll(
                                            primaryColor),
                                    columnSpacing: 10,
                                    headingTextStyle: TextStyle(
                                        fontSize: fontSize + 1,
                                        color: white,
                                        fontWeight: FontWeight.w700),
                                    columns: const [
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Customer List',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Order No.',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Created',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Created By',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Amount',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Invoice',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Payment Status',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            'Status',
                                            maxLines: 2,
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            '',
                                          ),
                                        ),
                                      )),
                                    ],
                                    rows: [
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(width: flexWidth * 1.5),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 0.9),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 0.9),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1.1),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1.1),
                                          ),
                                          const DataCell(Text('')),
                                        ],
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: SizedBox(
                              height: 45,
                              width: 45,
                              child: Center(
                                  child: dialogCloseButton1(context, red)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
    {EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    Color bgColor = Colors.transparent,
    double height = 58}) {
  return Container(
    color: bgColor,
    height: height,
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

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) => skip(length - n).toList();
}
