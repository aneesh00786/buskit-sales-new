// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CustomerMapScreen extends StatefulWidget {
  List<String> customerIds;
  List<String> eventIds;

  final bool istoGoogleMap;

  CustomerMapScreen({
    super.key,
    required this.customerIds,
    required this.eventIds,
    this.istoGoogleMap = false,
  });

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

void navigateToo(
    double startLat, double startLng, double endLat, double endLng) async {
  if (Platform.isAndroid) {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps on Android';
    }
  } else if (Platform.isIOS) {
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
  }
}

class _CustomerMapScreenState extends State<CustomerMapScreen>
    with WidgetsBindingObserver {
  final CalenderMapController _mapController = Get.put(CalenderMapController());
  final HomeController homeController = Get.put(HomeController());
  final ProductsController productsController = Get.find<ProductsController>();
  final CustomerAndOrderController customerAndOrderController =
      Get.find<CustomerAndOrderController>();
  final subscriptionController = Get.find<SubscriptionController>();
  bool navigatedToMap = false;
  Result? selectedResult;

  // Cache for distance/duration per customerId
  final Map<String, Map<String, String>> _distanceDurationCache = {};
  final Map<String, bool> _isLoadingDistance = {};

  Future<void> fetchDistanceAndDuration(Result result) async {
    if (_distanceDurationCache.containsKey(result.customerId) ||
        _isLoadingDistance[result.customerId] == true) {
      return;
    }
    if (_mapController.currentLatLng.value == null) return;
    _isLoadingDistance[result.customerId] = true;
    final origin =
        "${_mapController.currentLatLng.value!.latitude},${_mapController.currentLatLng.value!.longitude}";
    final destination = "${result.latitude},${result.longitude}";
    try {
      final response = await http.get(
        Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$destination&key=${ApiConstants.kGoogleApiKey}",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          final distance = element['distance']['text'];
          final duration = element['duration']['text'];
          _distanceDurationCache[result.customerId] = {
            'distance': distance,
            'duration': duration,
          };
        } else {
          _distanceDurationCache[result.customerId] = {
            'distance': '-',
            'duration': '-',
          };
        }
      } else {
        _distanceDurationCache[result.customerId] = {
          'distance': '-',
          'duration': '-',
        };
      }
    } catch (e) {
      _distanceDurationCache[result.customerId] = {
        'distance': '-',
        'duration': '-',
      };
    } finally {
      _isLoadingDistance[result.customerId] = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController.suggestions.clear();
    _mapController.searchedLatLng.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.getDirections();
    });

    _mapController.getCurrentLocation();

    // Call loadShowRoute and log the result
    _mapController.loadShowRoute(widget.eventIds).then((_) {
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
      if (selectedResult != null) {
        _showReturnDialog(selectedResult!);
      }
    }
  }

  void _showReturnDialog(Result result) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    '${ApiConstants.imageBaseUrl}${result.imageUrl}'),
              ),
              const SizedBox(width: 8),
              Text(result.businessName),
            ],
          ),
          content: CustomText(
            content: 'Reached Customer',
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
                  customerAndOrderController
                      .setCustomerId(result.customerId);
                  productsController.selectedCustomerName.value =
                      result.businessName;
                  productsController.selectedCustomerId.value =
                      result.customerId;
                  productsController.selectedCustomerImageUrl.value =
                      result.imageUrl;
                  Get.to(
                    () => CustomerDachScreen(
                      isFromGoogle: true,
                      startDate: formattedStartDate,
                      endDate: formattedEndDate,
                      cusId: result.customerId,
                      cusName: result.businessName,
                      cusImage: result.imageUrl,
                      cusEmail: result.email,
                      cusMobile: result.mobileno,
                    ),
                    id: 2,
                  );
                  final customerId = result.customerId.toString();
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
      ),
      body: Obx(() {
        if (_mapController.isShowRouteLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Row(
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
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black, width: 2),
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
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black, width: 2),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(child: Obx(() {
                  // Sort by scheduleTime ascending (hh:mm:ss)
                  final sortedList =
                      List<Result>.from(_mapController.showRouteResultList);
                  int parseTime(String t) {
                    final parts = t.split(":");
                    if (parts.length != 3) return 0;
                    final h = int.tryParse(parts[0]) ?? 0;
                    final m = int.tryParse(parts[1]) ?? 0;
                    final s = int.tryParse(parts[2]) ?? 0;
                    return h * 3600 + m * 60 + s;
                  }

                  sortedList.sort((a, b) => parseTime(a.scheduleTime)
                      .compareTo(parseTime(b.scheduleTime)));
                  return ListView.builder(
                    itemCount: sortedList.length,
                    itemBuilder: (context, index) {
                      final result = sortedList[index];
                      // Trigger distance/duration fetch if not cached
                      if (!_distanceDurationCache
                              .containsKey(result.customerId) &&
                          _mapController.currentLatLng.value != null) {
                        fetchDistanceAndDuration(result);
                      }
                      final distance = _distanceDurationCache[result.customerId]
                              ?['distance'] ??
                          '...';
                      final duration = _distanceDurationCache[result.customerId]
                              ?['duration'] ??
                          '...';
                      final isLoading =
                          _isLoadingDistance[result.customerId] == true;
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.2),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    '${ApiConstants.imageBaseUrl}${result.imageUrl}'),
                              ),
                              title: CustomText(
                                content: result.businessName,
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
                                      Expanded(
                                        child: Text(
                                          result.address,
                                          overflow: TextOverflow.fade,
                                        ),
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
                                      Expanded(child: Text(result.mobileno)),
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
                                      Expanded(child: Text(result.email)),
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
                                          isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2))
                                              : Text(distance,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
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
                                          isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2))
                                              : Text(duration,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
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
                                                        .value?.latitude ??
                                                    0.0;
                                            double currentLongitude =
                                                _mapController.currentLatLng
                                                        .value?.longitude ??
                                                    0.0;

                                            return IconButton(
                                              highlightColor:
                                                  Colors.blue.withOpacity(0.2),
                                              icon: const Icon(
                                                Icons.near_me_outlined,
                                                size: 25,
                                              ),
                                              onPressed: () {
                                                if (subscriptionController
                                                        .visitNavigation
                                                        .value ==
                                                    "true") {
                                                  selectedResult = result;
                                                  navigatedToMap = true;
                                                  navigateToo(
                                                    currentLatitude,
                                                    currentLongitude,
                                                    result.latitude,
                                                    result.longitude,
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
                })),
              ]),
            ),
            Expanded(
                child: Obx(
              () => _mapController.buildGoogleMap(),
            )),
          ],
        );
      }),
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
