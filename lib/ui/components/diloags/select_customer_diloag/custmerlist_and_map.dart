import 'dart:developer';
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerMapScreen extends StatefulWidget {
  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();

  static void navigateTo(
      double startLat, double startLng, double endLat, double endLng) async {
    String googleMapsLocationUrl =
        "${ApiConstants.navmapBaseUrl}dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving";
    final String encodedURL = Uri.encodeFull(googleMapsLocationUrl);
    var uri = Uri.parse(encodedURL);
    await launchUrl(uri);
  }
}



void navigateToo(double startLat, double startLng, double endLat, double endLng) async {
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





void chooseMapApp(BuildContext context, double startLat, double startLng, double endLat, double endLng) async {
  bool googleMapsAvailable = await canLaunch("comgooglemaps://");
  bool appleMapsAvailable = await canLaunch("maps://");

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Choose Map App'),
        content: Text('Select the app you would like to use for navigation:'),
        actions: [
          if (googleMapsAvailable)
            TextButton(
              child: Text('Google Maps'),
              onPressed: () {
                String googleMapsUrl =
                    "comgooglemaps://?saddr=$startLat,$startLng&daddr=$endLat,$endLng&directionsmode=driving";
                launch(googleMapsUrl);
                Navigator.of(context).pop();
              },
            ),
          if (appleMapsAvailable)
            TextButton(
              child: Text('Apple Maps'),
              onPressed: () {
                String appleMapsUrl =
                    "https://maps.apple.com/?saddr=$startLat,$startLng&daddr=$endLat&dirflg=d";
                launch(appleMapsUrl);
                Navigator.of(context).pop();
              },
            ),
        ],
      );
    },
  );
}


class _CustomerMapScreenState extends State<CustomerMapScreen> {
@override
void initState() {
  super.initState();
  _mapController.suggestions.clear();
  _mapController.searchedLatLng.value=null;
  _mapController.getDirections();
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
                    Icon(EneftyIcons.location_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                       ()=>
                        TextFormField(
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
                                Row(
                                  children: [
                                    Icon(Icons.location_on,size: 13,color: Colors.red,),
                                    SizedBox(width: 5,),
                                    SizedBox(
                                      width: 240,
                                      child: Text(
                                        customer.address ?? '',
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.call,size: 13,),
                                    SizedBox(width: 5,),
                                    Text(
                                      customer.mobileno ?? '',
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.email_outlined,size: 13,),
                                    SizedBox(width: 5,),
                                    Text(customer.email ?? ''),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
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
                                    IconButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(Colors.blue
                                                  .withOpacity(0.1))),
                                      hoverColor: Colors.blue.withOpacity(0.4),
                                      onPressed: () {
                                        final currentLatLng =
                                            _mapController.currentLatLng.value;
                                        if (currentLatLng != null) {
                                         // chooseMapApp(context,currentLatLng.latitude,currentLatLng.longitude,double.parse(customer.latitude!),double.parse(customer.longitude!));
                                         navigateToo(
                                            currentLatLng.latitude,
                                            currentLatLng.longitude,
                                            double.parse(customer.latitude!),
                                            double.parse(customer.longitude!),
                                          );
                                        }
                                      },
                                      icon: Icon(
                                          EneftyIcons.route_square_outline,
                                          color: Colors.blue),
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
              child:
              // BasicMapDemo()
              Obx(
            () => _mapController.buildGoogleMap(),
          )
          ),
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