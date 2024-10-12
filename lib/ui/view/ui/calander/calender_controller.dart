import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/select_customer_diloag.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class CalenderMapController extends GetxController {
  final ApiWorker _apiWorker = Get.find();
  Rx<StaffData> selectedStaff = StaffData().obs;
  EventController<SalesManVisitEvents> eventController =
      EventController<SalesManVisitEvents>();
  EventController<SalesmanEvents> eventControllerv1 =
      EventController<SalesmanEvents>();
  final RxBool locationPermissionGranted = false.obs;
  final Rx<LatLng?> currentLatLng = Rxn<LatLng>();
  final Rx<LatLng?> searchedLatLng = Rxn<LatLng>();
  final RxString currentLocationText = 'Current location'.obs;
  final Set<Polyline> polylines = <Polyline>{}.obs;
  GoogleMapController? mapController = null;
  final customerList = <Customer>[].obs;
  RxList<Customer> selectedCustomers = <Customer>[].obs;
  final String kGoogleApiKey = "AlzaSynLUFjx_AH5TJxhbt6SLjsak2qKBUTWqdl";
  final double defaultLat = 25.022702;
  final double defaultLng = 45.052659;
  late final DateTime dateTime;
  RxList<bool> checkedList = <bool>[].obs;
  var suggestions = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    requestLocationPermission();
    
  }
  void initializeCheckedList(int length) {
    checkedList.value = List<bool>.filled(length, false);
  }
    void toggleCustomerSelection(int index, bool value) {
    checkedList[index] = value;
    if (value) {
      selectedCustomers.addIf(!selectedCustomers.contains(customerList[index]), customerList[index]);
    } else {
      selectedCustomers.remove(customerList[index]);
    }
  }

  // To handle the selection and transition to the map screen
  void showSelectedCustomerRoute(BuildContext context) {
    if (selectedCustomers.isNotEmpty) {
      Get.to(() => CustomerMapScreen());
    } else {
      log('No customers selected');
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      locationPermissionGranted.value = true;
      getCurrentLocation();
    } else if (status.isPermanentlyDenied) {
      showPermissionDeniedDialog();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      String address =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

      currentLatLng.value = LatLng(position.latitude, position.longitude);
      currentLocationText.value = address;

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng.value!),
        );
      }
    } catch (e) {
      log('Error getting current location: $e');
    }
  }

  Future<void> handleSearchLocation(String query) async {
    if (query.isEmpty) {
      suggestions.clear();
      return;
    }
    log('Search Query: $query');
    try {
      final response = await http.get(
        Uri.parse(
          "https://maps.gomaps.pro/maps/api/place/queryautocomplete/json?input=$query&key=$kGoogleApiKey",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['predictions'] is List) {
          suggestions.value =
              List<Map<String, dynamic>>.from(data['predictions']);
          log('Suggestions fetched: ${suggestions.length}');
        } else {
          log('Unexpected format for predictions: ${data['predictions']}');
        }
      } else {
        log('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      log('Error occurred: $e');
    }
  }

Future<void> fetchPlaceDetails(String placeId) async {
  try {
    final response = await http.get(
      Uri.parse(
        "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey"
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Fetched Place Details: $data');

      if (data['result'] != null && data['result']['geometry'] != null) {
        final place = data['result'];
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        final String name = place['name'];
        searchedLatLng.value = LatLng(lat, lng);
        log('Lat $lat Long $lng');
        createMarkers();
        log('Place details fetched: $name at ($lat, $lng)');
      } else {
        log('No result or geometry found in response: $data');
      }
    } else {
      log('Failed to fetch place details: ${response.statusCode}');
    }
  } catch (e) {
    log('Error fetching place details: $e');
  }
}
  void selectSuggestion(Map<String, dynamic> suggestion) async {
    log('Selected suggestion: ${suggestion['description']}');
    final placeId = suggestion['place_id'];
    try {
      final response = await http.get(
        Uri.parse(
            "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        searchedLatLng.value = LatLng(lat, lng);
        suggestions.clear();
        createMarkers();
        getDirections();
        log('Location marked: $lat, $lng');
      } else {
        log('Failed to load place details: ${response.statusCode}');
      }
    } catch (e) {
      log('Error occurred while fetching place details: $e');
    }
  }
  Future<void> getDirections() async {
  if (currentLatLng.value == null || searchedLatLng.value == null) return;
  final origin = "${currentLatLng.value!.latitude},${currentLatLng.value!.longitude}";
  final destination = "${searchedLatLng.value!.latitude},${searchedLatLng.value!.longitude}";
  try {
    final response = await http.get(
      Uri.parse(
        "https://maps.gomaps.pro/maps/api/directions/json?destination=$destination&origin=$origin&key=$kGoogleApiKey"
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylineCoordinates = decodePolyline(points);
        addPolyline(polylineCoordinates);
      } else {
        log('No routes found');
      }
    } else {
      log('Failed to load directions: ${response.statusCode}');
    }
  } catch (e) {
    log('Error occurred while fetching directions: $e');
  }
}
List<LatLng> decodePolyline(String poly) {
  List<LatLng> polyline = [];
  var index = 0, len = poly.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = poly.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = poly.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    LatLng p = LatLng((lat / 1E5), (lng / 1E5));
    polyline.add(p);
  }
  return polyline;
}


void addPolyline(List<LatLng> coordinates) {
  polylines.add(Polyline(
    polylineId: PolylineId('route'),
    points: coordinates,
    color: Colors.blue,
    width: 5,
  ));
}

  Set<Marker> createMarkers() {
    Set<Marker> markers = {};
    if (currentLatLng.value != null) {
      markers.add(
        Marker(
          markerId: MarkerId('Current Location'),
          position: currentLatLng.value!,
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
    }
    if (searchedLatLng.value != null) {
      markers.add(
        Marker(
          markerId: MarkerId('Searched Location'),
          position: searchedLatLng.value!,
          infoWindow: InfoWindow(title: 'Searched Location'),
        ),
      );
    }
    // // Add markers for customers
    // for (var customer in customerList) {
    //   // Assuming each customer has latitude and longitude properties
    //   if (customer.latitude != null && customer.longitude != null) {
    //     markers.add(
    //       Marker(
    //         markerId: MarkerId(customer.fullname ?? ''), // Unique marker ID for each customer
    //         position: LatLng(customer.latitude!, customer.longitude!), // Use customer's lat and lng
    //         infoWindow: InfoWindow(
    //           title: customer.fullname,
    //           snippet: '${customer.mobileno}\n${customer.email}',
    //         ),
    //       ),
    //     );
    //   }
    // }
    return markers;
  }

  Widget buildGoogleMap() {
     return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: currentLatLng.value ?? LatLng(defaultLat, defaultLng),
        zoom: 10,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        if (locationPermissionGranted.value) {
          getCurrentLocation();
        }
      },
      markers: createMarkers(),
      polylines: polylines,
    );
  }

  void showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: Text("Permission Denied"),
        content: Text("Location permission is required to access the map."),
        actions: [
          TextButton(
            child: Text("Go to Settings"),
            onPressed: () {
              openAppSettings();
              Get.back();
            },
          ),
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  loadCalenderEvent_v1(List<SalesmanEvents> events) {
    if (eventControllerv1.events.isNotEmpty) {
      for (var element in eventControllerv1.events) {
        eventControllerv1.remove(element);
      }
    }
    print("eventlength ${events.length}");

    var eventData = List<CalendarEventData<SalesmanEvents>>.generate(
        events.length,
        (index) => CalendarEventData<SalesmanEvents>(
              title: events[index].totalEvent.toString(),
              date: NKDateUtils.formatStringUTCDateTime(
                  events[index].start ?? DateTime.now().toString()),
              endDate: NKDateUtils.formatStringUTCDateTime(events[index].end!),
              event: events[index],
              description: events[index].totalEvent!.toString(),
              // color: getColor(events[index].type!).$1,
              color: Colors.grey,
              descriptionStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                // color: getColor(events[index].type!).$2,
                color: getColor(3).$2,
              ),
              startTime: DateTime.now().copyWith(hour: 10, minute: 0),
              endTime: DateTime.now().copyWith(hour: 24, minute: 0),
            ));
    log("Events+++${events.length}");
    //log("EVENT DATEEEEEE ${eventData.map((e) => e.event?.toJson()).toList()}");
    eventControllerv1.addAll(eventData);
    log("Events+++ 123+++  ${eventControllerv1.events.length}");
    refresh();
  }

  (Color componetColor, Color textColor) getColor(int type) {
    switch (type) {
      case 2:
        return (revenueProgressBarColor, buttonTextColor);
      case 3:
        return (revenueProgressBarColor, buttonTextColor);
      case 4:
        return (primaryColor, buttonTextColor);
      case 5:
        return (primaryTextColor, buttonTextColor);
      default:
        return (revenueProgressBarFilledColor, primaryTextColor);
    }
  }

  List<SalesmanEvents> DataList = [];

  Future<void> calenderAllEvents() async {
    var salesmanId = await SessionHelper.loginSavedData?.salesmanId;
    var sendData = {
      "salesman_id": salesmanId,
      "start_date": "",
      "end_date": ""
    };
    _apiWorker.getCalendarEvents(sendData).then((value) {
      DataList = value.data!.first.events!;
      log("calenderAllEvents ${DataList.length}");
      loadCalenderEvent_v1(DataList);
      // loadCalenderEvent_v1(value);
    });
    log("salesManId ${salesmanId.toString()}");
  }

  List<CustomerDetails> splitEventToCustomerData(
      List<SalesManVisitEvents> events) {
    List<CustomerDetails> customerDataList = [];
    for (var element in events) {
      if (element.customer != null) {
        customerDataList.add(CustomerDetails.fromJson(
            element.customer!.toJson()..addAll({"event_id": element.eventId})));
      }
    }
    return customerDataList;
  }
}
