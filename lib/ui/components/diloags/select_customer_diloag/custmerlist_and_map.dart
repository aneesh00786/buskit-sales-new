import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerMapScreen extends StatefulWidget {
  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();

  static void navigateTo(
      double startLat, double startLng, double endLat, double endLng) async {
    String googleMapsLocationUrl =
        "${ApiConstants.gmapBaseUrl}dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving";
    final String encodedURL = Uri.encodeFull(googleMapsLocationUrl);
    var uri = Uri.parse(encodedURL);
    await launchUrl(uri);
  }
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  @override
  void initState() {
    super.initState();
    _mapController.fetchDistanceAndTime();
  }

  final CalenderMapController _mapController = Get.put(CalenderMapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                    Icon(Icons.my_location),
                    SizedBox(width: 8),
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
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Search Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: TextEditingController(
                            text: _mapController.currentLocationText.value),
                        onFieldSubmitted: (value) {
                          _mapController.handleSearchLocation(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              _buildSuggestionsList(),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                                Text(
                                  customer.mobileno ?? '',
                                ),
                                Text(
                                  customer.address ?? '',
                                ),
                                Text(customer.email ?? ''),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          EneftyIcons.routing_outline,
                                          color: primaryColor,
                                        ),
                                        SizedBox(
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
                                        Icon(
                                          EneftyIcons.clock_2_outline,
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        CustomText(
                                            content: customer.duration ?? '...',
                                            fontWeight: FontWeight.w500),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            trailing: IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      Colors.blue.withOpacity(0.1))),
                              hoverColor: Colors.blue.withOpacity(0.4),
                              onPressed: () {
                                final currentLatLng =
                                    _mapController.currentLatLng.value;
                                if (currentLatLng != null) {
                                  CustomerMapScreen.navigateTo(
                                    currentLatLng.latitude,
                                    currentLatLng.longitude,
                                    double.parse(customer.latitude!),
                                    double.parse(customer.longitude!),
                                  );
                                }
                              },
                              icon: Icon(EneftyIcons.route_square_outline,
                                  color: Colors.blue),
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
        return SizedBox.shrink();
      }
      return Container(
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
