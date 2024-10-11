import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCustomerDiloag extends StatefulWidget {
  final DateTime dateTime;
  final List<Customer> customerlist;
  final CalenderMapController calenderMapController;

  const SelectCustomerDiloag(
      {super.key,
      required this.customerlist,
      required this.dateTime,
      required this.calenderMapController});

  @override
  State<SelectCustomerDiloag> createState() => _SelectCustomerDiloagState();
}

class _SelectCustomerDiloagState extends State<SelectCustomerDiloag> {
  late List<bool> _checkedList;

  @override
  void initState() {
    super.initState();
    _checkedList = List<bool>.filled(widget.customerlist.length, false);
  }

  @override
  Widget build(BuildContext context) {
    log('CustomerList Length : ${widget.customerlist.length}');
    return OrientationBuilder(builder: (context, ore) {
      return MyCommnonContainer(
        color: white,
        margin: AppDimensions.instance.orientation == Orientation.landscape
            ? nkExtraLargePadding(
                right: AppDimensions.instance.width * .20,
                left: AppDimensions.instance.width * .20)
            : nkExtraLargePadding(),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              DiloagAppBar(
                title: "Customer Visit For Today",
              ),
              widget.customerlist.isNotEmpty
                  ? Flexible(
                      child: ListView.builder(
                          padding: nkRegularPadding(),
                          itemBuilder: (context, index) {
                            Customer customer = widget.customerlist[index];
                            return Padding(
                              padding: nkSmallPadding(left: 0, right: 0),
                              child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  child: Card(
                                    elevation: 10,
                                    shadowColor: black.withOpacity(0.2),
                                    color: white,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            customer.imageUrl ?? ''),
                                      ),
                                      title: CustomText(
                                        content: customer.fullname ?? '',
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            content: customer.mobileno ?? '',
                                          ),
                                          CustomText(
                                            content: customer.email ?? '',
                                          ),
                                        ],
                                      ),
                                      trailing: Checkbox(
                                        value: _checkedList[index],
                                        onChanged: (value) {
                                          setState(() {
                                            _checkedList[index] =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                            );
                          },
                          itemCount: widget.customerlist.length),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  label: CustomText(
                    content: 'Show Route',
                    color: white,
                  ),
                  onPressed: () {
                    showSelectedCustomerRoute();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primaryColor),
                  ),
                  icon: Icon(
                    EneftyIcons.location_outline,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void showSelectedCustomerRoute() {
    List<Customer> selectedCustomers = [];
    for (int i = 0; i < _checkedList.length; i++) {
      if (_checkedList[i]) {
        selectedCustomers.add(widget.customerlist[i]);
      }
    }

    if (selectedCustomers.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerMapScreen(),
        ),
      );
    } else {
      log('No customers selected');
    }
  }

  static void navigateTo(
      double startLat, double startLng, double endLat, double endLng) async {
    String googleMapsLocationUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving";
    final String encodedURL = Uri.encodeFull(googleMapsLocationUrl);
    var uri = Uri.parse(encodedURL);
    await launchUrl(uri);
  }
}

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
            width: 250,
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
                log('Customer List Length: ${_mapController.customerList.length}');
                return ListView.builder(
                  itemCount: _mapController.customerList.length,
                  itemBuilder: (context, index) {
                    Customer customer = _mapController.customerList[index];
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(customer.fullname ?? '', style: TextStyle(fontSize: 17)),
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
                                    //_mapController.navigateToCustomer(customer);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.blue),
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
          Expanded(child: Obx(() => _mapController.buildGoogleMap())),
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

