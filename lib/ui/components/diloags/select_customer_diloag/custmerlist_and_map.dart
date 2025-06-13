// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerMapScreen extends StatefulWidget {
  final bool istoGoogleMap;
  const CustomerMapScreen({this.istoGoogleMap = false, super.key});

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

void navigateToo(
    double startLat, double startLng, double endLat, double endLng) async {
  if (Platform.isAndroid) {
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps on Android';
      }
    } else {
      NkCommonFunction.showErrorSnakBar(
          'No internet Connection. Please check your network');
    }
  } else if (Platform.isIOS) {
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      final Uri googleMapsUrl = Uri.parse(
          'comgooglemaps://?saddr=$startLat,$startLng&daddr=$endLat,$endLng&directionsmode=driving');
      final Uri appleMapsUrl = Uri.parse(
          'https://maps.apple.com/?saddr=$startLat,$startLng&daddr=$endLat,$endLng&dirflg=d');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch any map application on iOS';
      }
    } else {
      NkCommonFunction.showErrorSnakBar(
          'No internet Connection. Please check your network');
    }
  }
}

class _CustomerMapScreenState extends State<CustomerMapScreen>
    with WidgetsBindingObserver {
  final CalenderMapController _mapController = Get.put(CalenderMapController());
  final HomeController homeController = Get.put(HomeController());
  final ProductsController productsController = Get.put(ProductsController());
  final subscriptionController = Get.find<SubscriptionController>();

  bool navigatedToMap = false;
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.suggestions.clear();
      _mapController.searchedLatLng.value = null;
      _mapController.getDirections();
      _mapController.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && navigatedToMap) {
      navigatedToMap = false;
      if (selectedCustomer != null) {
        _showReturnDialog(selectedCustomer!);
      }
    }
  }

  void _showReturnDialog(Customer customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}'),
              ),
              const SizedBox(width: 8),
              Text(customer.businessName ?? ''),
            ],
          ),
          content: CustomText(
            content: 'Reached customer Location ?',
            fontSize: 17,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!widget.istoGoogleMap) {
                    Navigator.pop(context);
                  }
                  homeController.sidebarXController.selectIndex(1);
                  homeController.selectedIndex.value = 1;
                  final now = DateTime.now();
                  final startDate = DateTime(now.year, 1, 1);
                  final endDate = DateTime(now.year, 12, 31);

                  final formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                  final formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);
                  Get.to(
                    () => CustomerDachScreen(
                      isFromGoogle: true,
                      startDate: formattedStartDate,
                      endDate: formattedEndDate,
                      cusId: customer.customerId,
                      cusName: customer.businessName,
                      cusImage: customer.imageUrl,
                    ),
                    id: 2,
                  );
                  final customerId = customer.customerId.toString();
                  final customersProvider =
                      Provider.of<CustomersProvider>(context, listen: false);

                  await Future.wait([
                    customersProvider.fetchCustomerDashboardData(
                      customerId,
                    ),
                    customersProvider.fetchCustomerDashboardRevenueData(
                      customerId,
                    ),
                    customersProvider
                        .fetchCustomerDashboardDataSalseData(customerId),
                    customersProvider.fetchCustomersDataDash(customerId),
                    customersProvider
                        .fetchCustomerDashboardCountData(customerId),
                  ]);
                });
              },
              child: const Text("Go to Customer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
              homeController.sidebarXController.selectIndex(6);
              homeController.selectedIndex.value = 6;
              Get.toNamed(AppRoutes.calender, id: 2);
            },
            child: const Icon(
              Icons.arrow_back_ios,
            )),
      ),
      body: Row(
        children: [
          Container(
            width: 400,
            color: Colors.white.withOpacity(0.8),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Current location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _mapController.currentLocationText.value,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(
                      EneftyIcons.location_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          controller: TextEditingController(
                              text: _mapController.sortedCustomer.value),
                          onFieldSubmitted: (value) {
                            _mapController.handleSearchLocation(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildSuggestionsList(),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Customer List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(child: Obx(() {
                log('Customer List Length: ${_mapController.selectedCustomers.length}');
                return ListView.builder(
                  itemCount: _mapController.selectedCustomers.length,
                  itemBuilder: (context, index) {
                    Customer customer = _mapController.selectedCustomers[index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Card(
                          color: white,
                          elevation: 10,
                          shadowColor: black.withOpacity(0.2),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}'),
                            ),
                            title: CustomText(
                              content: customer.businessName ?? '',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 13,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      customer.address ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.call,
                                      size: 13,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      customer.mobileno ?? '',
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 13,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(customer.email ?? ''),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          EneftyIcons.routing_outline,
                                          color: primaryColor,
                                          size: 25,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        CustomText(
                                          content: customer.distance ?? '...',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          EneftyIcons.clock_2_outline,
                                          color: Colors.red,
                                          size: 25,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        CustomText(
                                            content: customer.duration ?? '...',
                                            fontWeight: FontWeight.w500),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(() {
                                          if (_mapController
                                                  .currentLatLng.value ==
                                              null) {
                                            return const CircularProgressIndicator();
                                          }
                                          double currentLatitude =
                                              _mapController.currentLatLng
                                                  .value!.latitude;
                                          double currentLongitude =
                                              _mapController.currentLatLng
                                                  .value!.longitude;
                                          return IconButton(
                                            highlightColor:
                                                Colors.blue.withOpacity(0.2),
                                            icon: const Icon(
                                              Icons.near_me_outlined,
                                              size: 25,
                                            ),
                                            onPressed: () {
                                              if (subscriptionController
                                                      .visitNavigation.value ==
                                                  "true") {
                                                selectedCustomer = customer;
                                                navigatedToMap = true;
                                                navigateToo(
                                                  currentLatitude,
                                                  currentLongitude,
                                                  double.parse(
                                                      customer.latitude!),
                                                  double.parse(
                                                      customer.longitude!),
                                                );
                                              } else {
                                                showUpgradePlanDialog(context);
                                              }
                                            },
                                          );
                                        })
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }))
            ]),
          ),
          Expanded(
              child: Obx(
            () => _mapController.buildGoogleMap(),
          )),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Obx(() {
      if (_mapController.suggestions.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: _mapController.suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _mapController.suggestions[index];
            return ListTile(
              title: Text(suggestion['description']),
              onTap: () {
                _mapController.selectSuggestion(suggestion);
              },
            );
          },
        ),
      );
    });
  }
}
