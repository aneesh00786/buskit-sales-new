import 'dart:developer';

import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerMapScreen extends StatelessWidget {
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
            width: 350,
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
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 242, 242, 242),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        NetworkImage(customer.imageUrl ?? ''),
                                  ),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(customer.businessName ?? '',
                                          style: TextStyle(fontSize: 17)),
                                      Text(customer.mobileno ?? ''),
                                      Text(customer.email ?? ''),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  child: Text(
                                    'Navigate',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    navigateTo(25.022702, 45.052659, 24.774265,
                                        46.738586);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }))
            ]),
          ),
          Expanded(child: Obx(() => _mapController.buildGoogleMap(),)),
        ],
      ),
    );
  }

  static void navigateTo(
      double startLat, double startLng, double endLat, double endLng) async {
    String googleMapsLocationUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving";
    final String encodedURL = Uri.encodeFull(googleMapsLocationUrl);
    var uri = Uri.parse(encodedURL);
    await launchUrl(uri);
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