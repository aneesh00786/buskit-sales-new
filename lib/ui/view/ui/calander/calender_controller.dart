import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/custmerlist_and_map.dart';
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
  bool hasFetchedData = false;
  Rx<StaffData> selectedStaff = StaffData().obs;
  EventController<SalesManVisitEvents> eventController =
  EventController<SalesManVisitEvents>();
  EventController<EventData> eventControllerv1 = EventController<EventData>();
  final RxBool locationPermissionGranted = false.obs;
  final Rx<LatLng?> currentLatLng = Rxn<LatLng>();
  final Rx<LatLng?> searchedLatLng = Rxn<LatLng>();
  final RxString currentLocationText = 'Current location'.obs;
  GoogleMapController? mapController = null;
  final customerList = <Customer>[].obs;
  RxList<Customer> selectedCustomers = <Customer>[].obs;
  var sortedCustomer = ''.obs;
  final RxList<CalendarEventData<EventData>> eventData =
      <CalendarEventData<EventData>>[].obs;
  final double defaultLat = 25.022702;
  final double defaultLng = 45.052659;
  late final DateTime dateTime;
  RxList<bool> checkedList = <bool>[].obs;
  var suggestions = <Map<String, dynamic>>[].obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;

  @override
  void onInit() {
    super.onInit();
    requestLocationPermission();
  }

  void initializeCheckedList(
      int length, List<CalendarEventData<EventData>> eventData) {
    checkedList.value = List<bool>.filled(length, true).toList();
    for (int i = 0; i < eventData.length; i++) {
      if (checkedList[i]) {
        final event = eventData[i];
        Customer customer = Customer(
          businessName: event.event?.businessName ?? '',
          address: event.event?.address ?? '',
          email: event.event?.email ?? '',
          imageUrl: event.event?.imageUrl ?? '',
          latitude: event.event?.latitude ?? '',
          longitude: event.event?.longitude ?? '',
          mobileno: event.event?.mobileNo ?? '',
        );
        selectedCustomers.addIf(
            !selectedCustomers.contains(customer), customer);
      }
    }
  }

  void clearSelections() {
    selectedCustomers.clear();
    checkedList.clear();
  }

  void toggleCustomerSelection(
      int index, bool value, List<CalendarEventData<EventData>> eventData) {
    checkedList[index] = value;
    final CalendarEventData<EventData> event = eventData[index];
    Customer customer = Customer(
        businessName: event.event?.businessName ?? '',
        address: event.event?.address ?? '',
        email: event.event?.email ?? '',
        imageUrl: event.event?.imageUrl ?? '',
        latitude: event.event?.latitude ?? '',
        longitude: event.event?.longitude ?? '',
        mobileno: event.event?.mobileNo ?? '');
    if (value) {
      selectedCustomers.addIf(!selectedCustomers.contains(customer), customer);
      log('Customer Added: ${customer.businessName}');
    } else {
      selectedCustomers.remove(customer);
      log('Customer Removed: ${customer.businessName}');
    }
  }

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

  // Future<void> getCurrentLocation() async {
  //   try {
  //     double latitude = -37.81422900;
  //     double longitude = 144.94280200;
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       String address =
  //           "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //       currentLatLng.value = LatLng(latitude, longitude);
  //       currentLocationText.value = address;
  //       if (mapController != null) {
  //         mapController!.animateCamera(
  //           CameraUpdate.newLatLng(currentLatLng.value!),
  //         );
  //       }
  //       print('Address: $address');
  //     } else {
  //       print('No address found for the provided coordinates.');
  //     }
  //   } catch (e) {
  //     print('Error getting location: $e');
  //   }
  // }
Future<void> getCurrentLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String address = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      currentLatLng.value = LatLng(latitude, longitude);
      currentLocationText.value = address;
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng.value!),
        );
      }
      log('Address: $address');
    } else {
      log('No address found for the provided coordinates.');
    }
  } catch (e) {
    print('Error getting location: $e');
  }
}
  Future<void> fetchDistanceAndTime() async {
    if (currentLatLng.value == null || selectedCustomers.isEmpty) return;

    final origin =
        "${currentLatLng.value!.latitude},${currentLatLng.value!.longitude}";
    final destinations = selectedCustomers
        .where((customer) =>
            customer.latitude != null && customer.longitude != null)
        .map((customer) => "${customer.latitude},${customer.longitude}")
        .join('|');

    try {
      final response = await http.get(
        Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$destinations&key=${ApiConstants.kGoogleApiKey}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('API Response Distance: $data');

        if (data['rows'].isNotEmpty) {
          final elements = data['rows'][0]['elements'];
          log('Elements length for row 0: ${elements.length}');

          for (int i = 0; i < elements.length; i++) {
            if (i >= selectedCustomers.length) break;

            final element = elements[i];
            if (element['status'] == 'OK') {
              final distance = element['distance']['text'];
              final duration = element['duration']['text'];
              selectedCustomers[i].distance = distance;
              selectedCustomers[i].duration = duration;
              log('Customer: ${selectedCustomers[i].businessName}, Distance: $distance, Duration: $duration');
            } else {
              log('Distance data unavailable for Customer: ${selectedCustomers[i].businessName}');
            }
          }
          sortCustomersByDistance();
          selectedCustomers.refresh();
         
        } else {
          log('No distance data found');
        }
      } else {
        log('Failed to fetch distance: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching distance and time: $e');
    }
  }

void sortCustomersByDistance() {
  selectedCustomers.sort((a, b) {
    final distanceA = _parseDistance(a.distance);
    final distanceB = _parseDistance(b.distance);
    return distanceA.compareTo(distanceB);
  });
  sortedCustomer.value = selectedCustomers.last.address??'';
}

double _parseDistance(String? distance) {
  if (distance == null) return 0.0;
  final parts = distance.split(' ');
  final value = double.tryParse(parts[0]) ?? 0.0;
  return value; 
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
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${ApiConstants.kGoogleApiKey}",
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
            "${ApiConstants.gmapBaseUrl}${ApiConstants.mapPlaceDetailsUrl}$placeId&key=${ApiConstants.kGoogleApiKey}"),
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
            "${ApiConstants.gmapBaseUrl}${ApiConstants.mapPlaceDetailsUrl}$placeId&key=${ApiConstants.kGoogleApiKey}"),
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
        log('Failed to load place details: ${response.statusCode},${response.body}');
      }
    } catch (e) {
      log('Error occurred while fetching place details: $e');
    }
  }

Future<void> getDirections() async {
  var lastCustomer = selectedCustomers.last;
  if (currentLatLng.value == null) return;
  final origin = "${currentLatLng.value!.latitude},${currentLatLng.value!.longitude}";
  final destination = searchedLatLng.value != null
      ? "${searchedLatLng.value!.latitude},${searchedLatLng.value!.longitude}"
      : "${lastCustomer.latitude},${lastCustomer.longitude}";
  String waypoints = selectedCustomers
      .where((customer) =>
          customer.latitude != null && customer.longitude != null)
      .map((customer) => "${customer.latitude},${customer.longitude}")
      .join('|');

  try {
    final response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=$waypoints&key=${ApiConstants.kGoogleApiKey}"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylineCoordinates = decodePolyline(points);
        addPolyline(polylineCoordinates);
        createMarkers();  
        log('Points :${points}');
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
  polylines.clear();
  polylines.add(
    Polyline(
      polylineId: PolylineId('route'),
      points: coordinates,
      color: Colors.blue,
      width: 6,
    ),
  );
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
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
    }
    for (var customer in selectedCustomers) {
      log('Customer: ${customer.businessName}, Lat: ${customer.latitude}, Lng: ${customer.longitude}');
      if (customer.latitude != null && customer.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(customer.businessName ?? ''),
            position: LatLng(double.parse(customer.latitude!),
                double.parse(customer.longitude!)),
            infoWindow: InfoWindow(
              title: customer.businessName,
              snippet: '${customer.mobileno}\n${customer.email}',
            ),
          ),
        );
      } else {
        log('Customer lat and long :${customer.latitude}, ${customer.longitude}');
      }
    }

    return markers;
  }

  Widget buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: currentLatLng.value ?? LatLng(defaultLat, defaultLng),
        zoom: 13,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        if (locationPermissionGranted.value) {
          getCurrentLocation();
        }
      },
      markers: createMarkers(),
      polylines: Set<Polyline>.of(polylines),
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

  void loadCalenderEvent_v1(List<EventData> events) {
    if (eventControllerv1.events.isNotEmpty) {
      eventControllerv1.removeAll(eventControllerv1.events);
    }
    var eventData = List<CalendarEventData<EventData>>.generate(
      events.length,
      (index) => CalendarEventData<EventData>(
        title: events[index].title ?? "No Title",
        date: DateTime.parse(events[index].start ?? DateTime.now().toString()),
        endDate: DateTime.parse(events[index].end ?? DateTime.now().toString()),
        event: events[index],
        description: events[index].title ?? "No Description",
        color: getColor(events[index].type ?? 3).$1,
      ),
    );
    eventControllerv1.addAll(eventData);
    log("Events loaded: ${eventData.length}");
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

  Future<void> fetchCalenderEvents() async {
    var salesmanId = await SessionHelper.loginSavedData?.salesmanId;
    var sendData = {
      "salesman_id": salesmanId,
      "start_date": "",
      "end_date": ""
    };
    List<EventData> response = await _apiWorker.getCalendarEvents(sendData);
    if (response != null) {
      loadCalenderEvent_v1(response);
    } else {
      log('No data received from the API.');
    }
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
