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
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCustomerDiloag extends StatelessWidget {
  final DateTime dateTime;
  final List<Customer> customerList;
  final CalenderMapController calenderMapController;

  SelectCustomerDiloag({
    super.key,
    required this.customerList,
    required this.dateTime,
    required this.calenderMapController,
  });

  @override
  Widget build(BuildContext context) {
    calenderMapController.initializeCheckedList(customerList.length);
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
              DiloagAppBar(title: "Customer Visit For Today"),
              customerList.isNotEmpty
                  ? Flexible(
                      child: ListView.builder(
                        padding: nkRegularPadding(),
                        itemCount: customerList.length,
                        itemBuilder: (context, index) {
                          Customer customer = customerList[index];
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
                                    backgroundImage:
                                        NetworkImage(customer.imageUrl ?? ''),
                                  ),
                                  title: CustomText(
                                      content: customer.fullname ?? ''),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                          content: customer.mobileno ?? ''),
                                      CustomText(content: customer.email ?? ''),
                                    ],
                                  ),
                                  trailing: Obx(() {
                                    return Checkbox(
                                      value: calenderMapController
                                          .checkedList[index],
                                      onChanged: (value) {
                                        calenderMapController
                                            .toggleCustomerSelection(
                                                index, value ?? false);
                                      },
                                    );
                                  }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  label: CustomText(content: 'Show Route', color: white),
                  onPressed: () {
                    calenderMapController.showSelectedCustomerRoute(context);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryColor)),
                  icon: Icon(EneftyIcons.location_outline, color: white),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
                                      Text(customer.fullname ?? '',
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
          Expanded(child: Obx(() => _mapController.buildGoogleMap())),
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
