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
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SelectCustomerDiloag extends StatefulWidget {
  final DateTime dateTime;
  final List<Customer> customerlist;

  const SelectCustomerDiloag(
      {super.key, required this.customerlist, required this.dateTime});

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
          builder: (context) =>
              CustomerMapScreen(customerList: selectedCustomers),
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

class CustomerMapScreen extends StatefulWidget {
  final List<Customer> customerList;
  const CustomerMapScreen({super.key, required this.customerList});

  @override
  _CustomerMapScreenState createState() => _CustomerMapScreenState();
}

const String kGoogleApiKey = "AIzaSyBDMyqvhFf6YedhHo2wF8VKqruS_eOx4cI";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  late GoogleMapController mapController;
  final double defaultLat = 25.022702;
  final double defaultLng = 45.052659;
  bool _locationPermissionGranted = false;
  String currentLocationText = 'Current location';
  LatLng? _currentLatLng;
  LatLng? _searchedLatLng;
  Set<Polyline> _polylines = {};
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation();
    } else if (status.isDenied) {
      log("Location permission denied. Requesting again.");
      _requestLocationPermission();
    } else if (status.isPermanentlyDenied) {
      log("Location permission permanently denied.");
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      String address =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        currentLocationText = address;
      });
      mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLatLng!),
      );
      _setMapMarkers();
    } catch (e) {
      log('Error getting current location: $e');
    }
  }

  Future<void> _handleSearchLocation(String query) async {
    final response = await http.get(
      Uri.parse(
          "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$kGoogleApiKey"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final firstResult = data['results'][0];
        final lat = firstResult['geometry']['location']['lat'];
        final lng = firstResult['geometry']['location']['lng'];

        setState(() {
          _searchedLatLng = LatLng(lat, lng);
        });
        print('Found location: ${firstResult['name']} at ($lat, $lng)');
      } else {
        print('No results found');
      }
    } else {
      print('Failed to load places: ${response.statusCode}');
    }
  }

  Future<void> _displaySearchedLocation(Prediction p) async {
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(p.placeId!);
    final double lat = detail.result.geometry!.location.lat;
    final double lng = detail.result.geometry!.location.lng;

    setState(() {
      _searchedLatLng = LatLng(lat, lng);
    });
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14),
    );
    _showRouteBetweenLocations();
  }

  Future<void> _showRouteBetweenLocations() async {
    if (_currentLatLng == null || _searchedLatLng == null) return;

    String origin = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    String destination =
        '${_searchedLatLng!.latitude},${_searchedLatLng!.longitude}';

    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$origin&destination=$destination&key=$kGoogleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String encodedPoints = data['routes'][0]['overview_polyline']['points'];
      _createRoutePolyline(encodedPoints);
    } else {
      log('Error fetching route from Google Directions API');
    }
  }

  void _createRoutePolyline(String encodedPoints) {
    List<PointLatLng> points = PolylinePoints().decodePolyline(encodedPoints);
    List<LatLng> polylineCoordinates =
        points.map((point) => LatLng(point.latitude, point.longitude)).toList();

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ),
      );
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text("Location permission is required to access the map."),
        actions: [
          TextButton(
            child: Text("Go to Settings"),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
      ),
      body: Row(
        children: [
          Container(
            width: 150,
            color: Colors.white.withOpacity(0.8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(EneftyIcons.stop_circle_outline),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: currentLocationText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        EneftyIcons.location_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Last Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            _handleSearchLocation(
                                value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Customer List',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.customerList.length,
                    itemBuilder: (context, index) {
                      Customer customer = widget.customerList[index];
                      return Card(
                        color: white,
                        elevation: 10,
                        shadowColor: black.withOpacity(0.2),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(customer.imageUrl ?? ''),
                          ),
                          title: Text(customer.fullname ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${customer.mobileno ?? ''}'),
                              Text('${customer.email ?? ''}'),
                            ],
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildGoogleMap()),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};
    if (_currentLatLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('Current Location'),
          position: _currentLatLng!,
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
    }
    for (var customer in widget.customerList) {
      double lat = defaultLat;
      double lng = defaultLng;
      markers.add(
        Marker(
          markerId: MarkerId(customer.fullname ?? ''),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: customer.fullname,
            snippet: '${customer.mobileno}\n${customer.email}',
          ),
        ),
      );
    }
    return markers;
  }

  void _setMapMarkers() {
    mapController.animateCamera(CameraUpdate.newLatLng(
        _currentLatLng ?? LatLng(defaultLat, defaultLng)));
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _currentLatLng ?? LatLng(defaultLat, defaultLng),
        zoom: 10,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        if (_locationPermissionGranted) {
          _setMapMarkers();
        }
      },
      markers: _createMarkers(),
      polylines: _polylines,
    );
  }
}
