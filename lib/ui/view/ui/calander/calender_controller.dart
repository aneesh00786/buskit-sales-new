// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/model/staff_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/custmerlist_and_map.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/model/calendar_salesman_model.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class CalenderMapController extends GetxController {
  bool hasFetchedData = false;
  Rx<StaffData> selectedStaff = StaffData().obs;
  EventController<SalesManVisitEvents> eventController =
      EventController<SalesManVisitEvents>();
  EventController<EventData> eventControllerv1 = EventController<EventData>();
  final RxBool locationPermissionGranted = false.obs;
  final Rx<LatLng?> currentLatLng = Rxn<LatLng>();
  final Rx<LatLng?> searchedLatLng = Rxn<LatLng>();
  final RxString currentLocationText = 'Current location'.obs;
  GoogleMapController? mapController;
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
  RxList<String> salesmanIdList = <String>[].obs;
  RxList<FetchOnlyCustomerData> customerOnlyList =
      <FetchOnlyCustomerData>[].obs;
RxBool isLoading = false.obs;
  RxString routeCredit = ''.obs;
   RxSet<Marker> mapMarkers = <Marker>{}.obs;
    // RxList<CalendarSalesmanData> salesmanList = <CalendarSalesmanData>[].obs;
  RxList<CalendarSalesmanData> salesmanList = <CalendarSalesmanData>[].obs;
  RxBool initChecklistLoading = false.obs;
    RxBool isSalesmanLoading = false.obs;

  Future<void> initializeCheckedList(
    int length,
    List<CalendarEventData<EventData>> eventData,
    List<String> customerIds,
  ) async {
    checkedList.value = List<bool>.filled(length, true).toList();

    for (int i = 0; i < eventData.length; i++) {
      if (checkedList[i]) {
        final event = eventData[i];

        final customerId = event.event?.customerId ?? '';
        if (!customerIds.contains(customerId)) continue;

        Customer customer = Customer(
          customerId: customerId,
          businessName: event.event?.businessName ?? '',
          address: event.event?.address ?? '',
          email: event.event?.email ?? '',
          imageUrl: event.event?.imageUrl ?? '',
          latitude: event.event?.latitude ?? '',
          longitude: event.event?.longitude ?? '',
          mobileno: event.event?.mobileNo ?? '',
        );

        selectedCustomers.addIf(
          !selectedCustomers.any((c) => c.customerId == customer.customerId),
          customer,
        );
      }
    }
  }


  // void initializeCheckedList(
  //     int length, List<CalendarEventData<EventData>> eventData) {
  //   initChecklistLoading.value = true;
  //   checkedList.value = List<bool>.filled(length, true).toList();
  //   for (int i = 0; i < eventData.length; i++) {
  //     if (checkedList[i]) {
  //       final event = eventData[i];
  //       Customer customer = Customer(
  //         customerId: event.event?.customerId ?? '',
  //         businessName: event.event?.businessName ?? '',
  //         address: event.event?.address ?? '',
  //         email: event.event?.email ?? '',
  //         imageUrl: event.event?.imageUrl ?? '',
  //         latitude: event.event?.latitude ?? '',
  //         longitude: event.event?.longitude ?? '',
  //         mobileno: event.event?.mobileNo ?? '',
  //       );
  //       selectedCustomers.addIf(
  //           !selectedCustomers.contains(customer), customer);
  //     }
  //   }
  //   initChecklistLoading.value = false;
  // }

  void clearSelections() {
    selectedCustomers.clear();
    checkedList.clear();
  }


  void toggleCustomerSelection(
      int index, bool value, CalendarEventData<EventData> event) {
    checkedList[index] = value;

    final customerId = event.event?.customerId ?? '';
    final customer = Customer(
      customerId: customerId,
      businessName: event.event?.businessName ?? '',
      address: event.event?.address ?? '',
      email: event.event?.email ?? '',
      imageUrl: event.event?.imageUrl ?? '',
      latitude: event.event?.latitude ?? '',
      longitude: event.event?.longitude ?? '',
      mobileno: event.event?.mobileNo ?? '',
    );

    if (value) {
      selectedCustomers.addIf(
        !selectedCustomers.any((c) => c.customerId == customerId),
        customer,
      );
    } else {
      selectedCustomers.removeWhere((c) => c.customerId == customerId);
    }
  }

  // void toggleCustomerSelection(
  //     int index, bool value, List<CalendarEventData<EventData>> eventData) {
  //   checkedList[index] = value;
  //   final CalendarEventData<EventData> event = eventData[index];
  //   Customer customer = Customer(
  //       customerId: event.event?.customerId ?? '',
  //       businessName: event.event?.businessName ?? '',
  //       address: event.event?.address ?? '',
  //       email: event.event?.email ?? '',
  //       imageUrl: event.event?.imageUrl ?? '',
  //       latitude: event.event?.latitude ?? '',
  //       longitude: event.event?.longitude ?? '',
  //       mobileno: event.event?.mobileNo ?? '');
  //   if (value) {
  //     selectedCustomers.addIf(!selectedCustomers.contains(customer), customer);
  //   } else {
  //     selectedCustomers.remove(customer);
  //   }
  // }

  // void showSelectedCustomerRoute(BuildContext context) {
  //   if (selectedCustomers.isNotEmpty) {
  //     log('$selectedCustomers');
  //     Get.to(() => const CustomerMapScreen());
  //   } else {
  //     log('No customers selected');
  //     Get.snackbar(
  //         'No Route Available', 'Please select at least one customer.');
  //   }
  // }

 void showSelectedCustomerRoute(
    BuildContext context,
    List<String> customerIds,
    List<String> eventIds, {
    String? startAddress, // 1. Add optional parameter for Start Address
    String? endAddress,   // 2. Add optional parameter for End Address
  }) async {
    if (selectedCustomers.isNotEmpty) {
      isShowRouteLoading.value = true;

      await loadShowRoute(eventIds);
      
      Get.to(
        () => CustomerMapScreen(
          customerIds: customerIds,
          eventIds: eventIds,
          // 3. Pass the values to the screen
          initialStartAddress: startAddress, 
          initialEndAddress: endAddress,     
        ),
        id: 2,
      );

      print('on tapped');
    } else {
      // Handle empty state
    }
  }

  // void showSelectedCustomerRoute(
  //   BuildContext context,
  //   List<String> customerIds,
  //   List<String> eventIds,
  // ) {
  //   if (selectedCustomers.isNotEmpty) {
  //     Get.to(() => CustomerMapScreen(
  //           customerIds: customerIds,
  //           eventIds: eventIds,
  //         ));
  //   } else {
  //   }
  // }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      return;
    } else if (status.isPermanentlyDenied) {
    } else {
      showPermissionDeniedDialog();
    }
  }

  // Future<void> getCurrentLocation() async {
  //   try {
  //     double latitude = -37.81996700;
  //     double longitude = 144.98344900;
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
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
        currentLatLng.value = LatLng(latitude, longitude);
        currentLocationText.value = address;
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(currentLatLng.value!),
          );
        }
      } else {
      }
    } catch (e) {
      //
    }
  }

    Future<LatLng?> getLatLngFromAddress(String fullAddress) async {
    try {
      List<Location> locations = await locationFromAddress(fullAddress);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (e) {}
    return null;
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

        if (data['rows'].isNotEmpty) {
          final elements = data['rows'][0]['elements'];

          for (int i = 0; i < elements.length; i++) {
            if (i >= selectedCustomers.length) break;

            final element = elements[i];
            if (element['status'] == 'OK') {
              final distance = element['distance']['text'];
              final duration = element['duration']['text'];
              selectedCustomers[i].distance = distance;
              selectedCustomers[i].duration = duration;
            } else {
            }
          }
          sortCustomersByDistance();
          selectedCustomers.refresh();
        } else {
        }
      } else {
      }
    } catch (e) {
      //
    }
  }

    void zoomToLocation(double lat, double lng) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 16.0,
            tilt: 45.0,
          ),
        ),
      );
    } else {
      print("Map controller not initialized yet");
    }
  }

  void sortCustomersByDistance() {
    selectedCustomers.sort((a, b) {
      final distanceA = _parseDistance(a.distance);
      final distanceB = _parseDistance(b.distance);
      return distanceA.compareTo(distanceB);
    });
    sortedCustomer.value = selectedCustomers.last.address ?? '';
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
        } else {
        }
      } else {
      }
    } catch (e) {
      //
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
        if (data['result'] != null && data['result']['geometry'] != null) {
          final place = data['result'];
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          searchedLatLng.value = LatLng(lat, lng);
          updateMarkers();
        } else {
        }
      } else {
      }
    } catch (e) {
      //
    }
  }

  void selectSuggestion(Map<String, dynamic> suggestion) async {
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
       await updateMarkers();
        getDirections();
      } else {
      }
    } catch (e) {
      //
    }
  }


Future<void> getDirections() async {
  if (selectedCustomers.isEmpty || currentLatLng.value == null) return;

  // 1. SETUP START & POOL
  LatLng currentPoint = currentLatLng.value!;
  final String origin = "${currentPoint.latitude},${currentPoint.longitude}";
  
  String destination;
  Customer? destinationCustomer;
  
  // Create a pool of customers
  List<Customer> pool = List.from(selectedCustomers);

  // 2. DETERMINE DESTINATION (Fixed Point)
  if (searchedLatLng.value != null) {
    // --- MANUAL DESTINATION (From Dialog) ---
    final LatLng end = searchedLatLng.value!;
    destination = "${end.latitude},${end.longitude}";
    
    destinationCustomer = Customer(
      customerId: "manual_destination", 
      businessName: "End Location",
      address: "Destination",
      latitude: end.latitude.toString(),
      longitude: end.longitude.toString(),
      email: "", imageUrl: "", mobileno: ""
    );
  } else {
    // --- DEFAULT LOGIC (Furthest is End) ---
    Customer? furthest;
    double maxDist = -1;
    for (var c in pool) {
      double d = Geolocator.distanceBetween(
        currentPoint.latitude, currentPoint.longitude, 
        double.parse(c.latitude!), double.parse(c.longitude!)
      );
      if (d > maxDist) {
        maxDist = d;
        furthest = c;
      }
    }
    destinationCustomer = furthest ?? pool.last;
    destination = "${destinationCustomer.latitude},${destinationCustomer.longitude}";
    
    // Remove destination from pool so we don't visit it twice
    pool.remove(destinationCustomer);
  }

  
  pool.removeWhere((c) {
    double dist = Geolocator.distanceBetween(
      currentLatLng.value!.latitude, currentLatLng.value!.longitude, 
      double.parse(c.latitude!), double.parse(c.longitude!)
    );
    return dist < 50; 
  });

  // 4. SORT WAYPOINTS BY "NEAREST NEIGHBOR"
  List<Customer> sortedWaypoints = [];
  
  // Reset currentPoint to start for the sorting loop
  currentPoint = currentLatLng.value!; 

  while (pool.isNotEmpty) {
    // Find the single customer closest to the 'currentPoint'
    pool.sort((a, b) {
      double distA = Geolocator.distanceBetween(
          currentPoint.latitude, currentPoint.longitude, 
          double.parse(a.latitude!), double.parse(a.longitude!));
      double distB = Geolocator.distanceBetween(
          currentPoint.latitude, currentPoint.longitude, 
          double.parse(b.latitude!), double.parse(b.longitude!));
      return distA.compareTo(distB);
    });

    // The first item is now the closest
    Customer nearest = pool.removeAt(0);
    sortedWaypoints.add(nearest);
    
    // Update 'currentPoint' to this customer
    currentPoint = LatLng(double.parse(nearest.latitude!), double.parse(nearest.longitude!));
  }

  // 5. PREPARE API STRING
  // If we filtered out everyone (e.g., only had 1 customer at start), stop here.
  if (sortedWaypoints.isEmpty && destinationCustomer == null) return;

  String waypoints = sortedWaypoints
      .map((c) => "${c.latitude},${c.longitude}")
      .join('|');

  try {
    // 6. CALL API (No 'optimize:true')
    String url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$origin&destination=$destination"
        "&waypoints=$waypoints" 
        "&mode=driving"
        "&key=${ApiConstants.kGoogleApiKey}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0];

        // 7. UPDATE APP STATE
        List<Customer> finalRouteList = List.from(sortedWaypoints);
        if (destinationCustomer != null) {
          finalRouteList.add(destinationCustomer);
        }

        selectedCustomers.assignAll(finalRouteList);

        final points = route['overview_polyline']['points'];
        addPolyline(decodePolyline(points));
        await updateMarkers();
      }
    }
  } catch (e) {
    print("Routing error: $e");
  }
}

  // Future<void> getDirections() async {
  //   var lastCustomer = selectedCustomers.last;
  //   if (currentLatLng.value == null) return;
  //   final origin =
  //       "${currentLatLng.value!.latitude},${currentLatLng.value!.longitude}";
  //   final destination = searchedLatLng.value != null
  //       ? "${searchedLatLng.value!.latitude},${searchedLatLng.value!.longitude}"
  //       : "${lastCustomer.latitude},${lastCustomer.longitude}";
  //   String waypoints = selectedCustomers
  //       .where((customer) =>
  //           customer.latitude != null && customer.longitude != null)
  //       .map((customer) => "${customer.latitude},${customer.longitude}")
  //       .join('|');

  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=$waypoints&key=${ApiConstants.kGoogleApiKey}"),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['routes'].isNotEmpty) {
  //         final points = data['routes'][0]['overview_polyline']['points'];
  //         List<LatLng> polylineCoordinates = decodePolyline(points);
  //         addPolyline(polylineCoordinates);
  //         createMarkers();
  //       } else {
  //       }
  //     } else {
  //     }
  //   } catch (e) {
  //     if (e is http.ClientException) {
  //     } else if (e is http.Response) {
  //     } else {
  //     }
  //   }
  // }




  Future<void> updateMarkers() async {
  Set<Marker> markers = {};

  // 1. START MARKER
  if (currentLatLng.value != null) {
    // Generate custom icon for Start (No index number, just text)
    final BitmapDescriptor startIcon = await createCustomMarkerBitmap(
      "Start", 
      null, // No index for start
      Colors.blue
    );

    markers.add(Marker(
      markerId: const MarkerId('Current Location'),
      position: currentLatLng.value!,
      icon: startIcon,
    ));
  }

  // 2. CUSTOMER MARKERS
  for (int i = 0; i < selectedCustomers.length; i++) {
    var customer = selectedCustomers[i];

    if (customer.latitude != null && customer.longitude != null) {
      bool isLast = (i == selectedCustomers.length - 1);
      
      String businessName = isLast 
          ? "${customer.businessName} (End)" 
          : (customer.businessName ?? 'Unknown');
      
      Color color = isLast ? Colors.green : Colors.black;
      
      // Pass the index string ("1", "2", etc.)
      String indexString = (i + 1).toString(); 

      // Generate custom icon with Index
      final BitmapDescriptor customIcon = await createCustomMarkerBitmap(
        businessName, 
        indexString, 
        color
      );

      markers.add(Marker(
        markerId: MarkerId(customer.customerId!),
        position: LatLng(
          double.parse(customer.latitude!),
          double.parse(customer.longitude!),
        ),
        icon: customIcon,
      ));
    }
  }

  mapMarkers.value = markers;
}



//   Future<void> updateMarkers() async {
//   Set<Marker> markers = {};

//   // 1. START MARKER
//   if (currentLatLng.value != null) {
//     // Generate custom icon for Start (No index number, just text)
//     final BitmapDescriptor startIcon = await createCustomMarkerBitmap(
//       "Start", 
//       null, // No index for start
//       Colors.blue
//     );

//     markers.add(Marker(
//       markerId: const MarkerId('Current Location'),
//       position: currentLatLng.value!,
//       icon: startIcon,
//     ));
//   }

//   // 2. CUSTOMER MARKERS
//   for (int i = 0; i < selectedCustomers.length; i++) {
//     var customer = selectedCustomers[i];

//     if (customer.latitude != null && customer.longitude != null) {
//       bool isLast = (i == selectedCustomers.length - 1);
      
//       String businessName = isLast 
//           ? "${customer.businessName} (End)" 
//           : (customer.businessName ?? 'Unknown');
      
//       Color color = isLast ? Colors.green : Colors.black;
      
//       // Pass the index string ("1", "2", etc.)
//       String indexString = (i + 1).toString(); 

//       // Generate custom icon with Index
//       final BitmapDescriptor customIcon = await createCustomMarkerBitmap(
//         businessName, 
//         indexString, 
//         color
//       );

//       markers.add(Marker(
//         markerId: MarkerId(customer.customerId!),
//         position: LatLng(
//           double.parse(customer.latitude!),
//           double.parse(customer.longitude!),
//         ),
//         icon: customIcon,
//       ));
//     }
//   }

//   mapMarkers.value = markers;
// }


Future<BitmapDescriptor> createCustomMarkerBitmap(String text, String? index, Color color) async {
  // 1. Configuration
  const double fontSize = 35.0;
  const double circleRadius = 25.0;
  const double padding = 10.0;
  
  // 2. Setup Text Painters
  // -- Business Name Text --
  final textSpan = TextSpan(
    style: const TextStyle(
      color: Colors.white,
      fontSize: fontSize, 
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.transparent, // We draw bg manually
    ),
    text: text,
  );
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: ui.TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  textPainter.layout();

  // -- Index Number Text --
  TextPainter? indexPainter;
  if (index != null) {
    final indexSpan = TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30, // Slightly smaller for the circle
        fontWeight: FontWeight.bold,
      ),
      text: index,
    );
    indexPainter = TextPainter(
      text: indexSpan,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    indexPainter.layout();
  }

  // 3. Calculate Canvas Size
  final double textWidth = textPainter.width + (padding * 4);
  final double textHeight = textPainter.height + (padding * 2);
  final double circleHeight = (index != null) ? (circleRadius * 2) + padding : 0;
  
  final double canvasWidth = (textWidth > circleRadius * 2) ? textWidth : circleRadius * 2;
  final double canvasHeight = textHeight + circleHeight;

  // 4. Start Drawing
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  
  final Paint paint = Paint()..color = color;
  final Paint bgPaint = Paint()..color = color.withOpacity(0.8); // Slightly transparent for text box

  // -- Draw Text Background (Rounded Rect) --
  final RRect backgroundRect = RRect.fromRectAndRadius(
    Rect.fromLTWH((canvasWidth - textWidth) / 2, 0, textWidth, textHeight),
    const Radius.circular(15.0),
  );
  canvas.drawRRect(backgroundRect, bgPaint);

  // -- Draw Business Name --
  textPainter.paint(
    canvas,
    Offset((canvasWidth - textPainter.width) / 2, padding),
  );

  // -- Draw Circle & Index (If index exists) --
  if (index != null && indexPainter != null) {
    final Offset circleCenter = Offset(canvasWidth / 2, textHeight + padding + circleRadius - 10);
    
    // Draw Circle
    canvas.drawCircle(circleCenter, circleRadius, paint);
    
    // Draw Index Number
    indexPainter.paint(
      canvas,
      Offset(circleCenter.dx - (indexPainter.width / 2), circleCenter.dy - (indexPainter.height / 2)),
    );
  }

  // 5. Convert to BitmapDescriptor
  final ui.Image image = await pictureRecorder.endRecording().toImage(
    canvasWidth.toInt(),
    canvasHeight.toInt(),
  );
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
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
        polylineId: const PolylineId('route'),
        points: coordinates,
        color: Colors.blue,
        width: 6,
      ),
    );
     polylines.refresh();
  }

  // Set<Marker> createMarkers() {
  //   Set<Marker> markers = {};
  //   if (currentLatLng.value != null) {
  //     markers.add(
  //       Marker(
  //         markerId: const MarkerId('Current Location'),
  //         position: currentLatLng.value!,
  //         infoWindow: const InfoWindow(title: 'Current Location'),
  //       ),
  //     );
  //   }
  //   if (searchedLatLng.value != null) {
  //     markers.add(
  //       Marker(
  //         markerId: const MarkerId('Searched Location'),
  //         position: searchedLatLng.value!,
  //         infoWindow: const InfoWindow(title: 'Destination'),
  //       ),
  //     );
  //   }
  //   for (var customer in selectedCustomers) {
  //     if (customer.latitude != null && customer.longitude != null) {
  //       markers.add(
  //         Marker(
  //           markerId: MarkerId(customer.businessName ?? ''),
  //           position: LatLng(double.parse(customer.latitude!),
  //               double.parse(customer.longitude!)),
  //           infoWindow: InfoWindow(
  //             title: customer.businessName,
  //             snippet: '${customer.mobileno}\n${customer.email}',
  //           ),
  //         ),
  //       );
  //     } else {
  //     }
  //   }

  //   return markers;
  // }
   Widget buildGoogleMap() {
    return Obx(() => GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: currentLatLng.value ?? LatLng(defaultLat, defaultLng),
            zoom: 13,
          ),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            updateMarkers();
          },
          markers: mapMarkers.value,
          polylines: Set<Polyline>.of(polylines.value),
        ));
  }

  // Widget buildGoogleMap() {
  //   return GoogleMap(
  //     mapType: MapType.normal,
  //     initialCameraPosition: CameraPosition(
  //       target: currentLatLng.value ?? LatLng(defaultLat, defaultLng),
  //       zoom: 13,
  //     ),
  //     onMapCreated: (GoogleMapController controller) {
  //       mapController = controller;
  //       if (locationPermissionGranted.value) {
  //         getCurrentLocation();
  //       }
  //     },
  //     markers: createMarkers(),
  //     polylines: Set<Polyline>.of(polylines),
  //   );
  // }

  void showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Permission Denied"),
        content:
            const Text("Location permission is required to access the map."),
        actions: [
          TextButton(
            child: const Text("Go to Settings"),
            onPressed: () {
              openAppSettings();
              Get.back();
            },
          ),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  void loadCalenderEventV1(List<EventData> events) {
    if (eventControllerv1.events.isNotEmpty) {
      eventControllerv1.removeAll(eventControllerv1.events);
    }
    var eventData = List<CalendarEventData<EventData>>.generate(
      events.length,
      (index) => CalendarEventData<EventData>(
        title: events[index].title ?? "No Title",
        date: DateTime.parse(events[index].start.toString())
            .copyWith(hour: 0, minute: 0, second: 0),
        endDate: DateTime.parse(events[index].end.toString())
            .copyWith(hour: 0, minute: 0, second: 0),
        event: events[index],
        description: events[index].title ?? "No Description",
        color: getColor(events[index].type ?? 3).$1,
      ),
    );
    eventControllerv1.addAll(eventData);
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
   Future<void> fetchCalenderEvents(DateTime initialDay) async {
    var sendData = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "initialDay": initialDay.toIso8601String(),
    };
    List<EventData> response = await ApiWorker().getCalendarEvents(sendData);
    Set<String> uniqueSalesmanIds = {};
    for (var event in response) {
      if (event.salesmanId != null) {
        uniqueSalesmanIds.add(event.salesmanId!);
      }
    }
    salesmanIdList.assignAll(uniqueSalesmanIds.toList());
    loadCalenderEventV1(response);
  }

  // Future<void> fetchCalenderEvents(
  //   DateTime initialDay,
  // ) async {
  //   var salesmanId = SessionHelper.loginSavedData?.salesmanId;
  //   final jsonString = await SessionManager.getStringValue(SpString.spLogin);
  //   Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  //   int companyId = jsonMap['company_id'];
  //   var sendData = {
  //     "salesman_id": salesmanId,
  //     "initialDay": initialDay,
  //     "companyId": companyId,
  //   };
  //   List<EventData> response = await ApiWorker().getCalendarEvents(sendData);
  //   loadCalenderEventV1(response);
  // }

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

  RxBool isRouteCreditLoading = false.obs;

  Future<void> getRouteCredit() async {
    isRouteCreditLoading.value = true;
    try {
      final data = await ApiWorker().getRouteCredit();
      routeCredit.value = data;
    } catch (e) {
      //
    } finally {
      isRouteCreditLoading.value = false;
    }
  }

  RxBool isOnlyCustomerLoading = false.obs;
  Future<void> loadOnlyCustomerData(
      String eventDate, List<String> customerIds) async {
    try {
      isOnlyCustomerLoading.value = true;

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final startDate = formatter.format(firstDayOfMonth);
      final endDate = formatter.format(lastDayOfMonth);

      var response = await ApiWorker().fetchOnlyCustomerData(
        eventDate,
        customerIds,
        startDate,
        endDate,
      );

      if (response.data.isNotEmpty) {
        customerOnlyList.value = response.data;
      } else {
        customerOnlyList.clear();
      }

    } catch (error) {
      customerOnlyList.clear();
    } finally {
      isOnlyCustomerLoading.value = false;
    }
  }

  Future<void> updateCredit(String credit) async {
    routeCredit.value = credit;
  }

  RxList<Result> showRouteResultList = <Result>[].obs;

  RxBool isShowRouteLoading = false.obs;

Future<void> loadShowRoute(List<String> eventIds) async {
    try {
      isShowRouteLoading.value = true;
      var response = await ApiWorker().showRoutes(eventList: eventIds);

      showRouteResultList.clear();
      selectedCustomers.clear();

      if (response.results.isNotEmpty) {
        showRouteResultList.addAll(response.results);

        for (var result in response.results) {
          if (result.latitude != null && result.longitude != null) {
            selectedCustomers.add(Customer(
              customerId: result.customerId,
              businessName: result.businessName,
              address: result.address,
              email: result.email,
              imageUrl: result.imageUrl,
              latitude: result.latitude.toString(),
              longitude: result.longitude.toString(),
              mobileno: result.mobileno,
            ));
          } else {
            print(
                "Skipping customer ${result.businessName} - No coordinates available.");
          }
        }

        selectedCustomers.refresh();
        await getDirections();
        await updateMarkers(); // Update markers after loading route
      }
    } catch (error) {
      print('Error loading show route: $error');
      showRouteResultList.clear();
      selectedCustomers.clear();
    } finally {
      isShowRouteLoading.value = false;
    }
  }

  // Future<void> loadShowRoute(List<String> eventIds) async {
  //   try {
  //     isShowRouteLoading.value = true;

  //     var response = await ApiWorker().showRoutes(eventList: eventIds);

  //     showRouteResultList.clear();
  //     if (response.results.isNotEmpty) {
  //       showRouteResultList.addAll(response.results);
  //     }

  //   } catch (error) {
  //     showRouteResultList.clear();
  //   } finally {
  //     isShowRouteLoading.value = false;
  //   }
  // }
  Future<List<Map<String, dynamic>>> fetchAutoCompletePlaces(String query) async {
    if (query.isEmpty) return [];
    try {
      // Added &components=country:au to restrict to Australia
      final response = await http.get(
        Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:au&key=${ApiConstants.kGoogleApiKey}",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['predictions'] is List) {
          return List<Map<String, dynamic>>.from(data['predictions']);
        }
      }
    } catch (e) {
      print("Error fetching autocomplete: $e");
    }
    return [];
  }

   Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
            "${ApiConstants.gmapBaseUrl}${ApiConstants.mapPlaceDetailsUrl}$placeId&key=${ApiConstants.kGoogleApiKey}"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['geometry'] != null) {
          final place = data['result'];
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
    return null;
  }
 Future<void> loadSalesmanOfCustomer(String salesmanId) async {
    try {
      isLoading.value = true;

      var response = await ApiWorker().fetchSalesmanOfCustomer(salesmanId);

      if (response.data != null && response.data!.isNotEmpty) {
        salesmanList.add(response.data!.first);
      } else {
        salesmanList.clear();
      }
    } catch (error) {
      salesmanList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
