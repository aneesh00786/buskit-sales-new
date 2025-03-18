// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/map/location_permission.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_progress_indicator.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      log("onMapCreated ${controller.mapId}");
    });
  }

  Future<void> _getCurrentLocation() async {
    if (await AccesLocation.locationPermission == false) {
      NkCommonFunction.showErrorSnakBar(locationPermissionDenied);
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      NkCommonFunction.showErrorSnakBar(locationPermissionDenied);
      log("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: topHeadingRow(),
        automaticallyImplyLeading: false,
      ),
      body: currentLocation != null
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: MapType.satellite,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: currentLocation!,
                  infoWindow: const InfoWindow(title: 'Your Location'),
                ),
              },
            )
          : const Center(
              child: MyProgressIndicator(),
            ),
    );
  }

  Widget topHeadingRow() {
    return InkResponse(
        onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios));
  }
}
