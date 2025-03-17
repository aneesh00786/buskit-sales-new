import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AccesLocation {

  LatLng? currentLocation;
  Future<void> _getCurrentLocation() async {
    if (await locationPermission) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        currentLocation = LatLng(position.latitude, position.longitude);
      } catch (e) {
        log("Error getting location: $e");
      }
    }
  }

  static Future<bool> get locationPermission async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await locationPermissionREQ;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<LocationPermission> get locationPermissionREQ async =>
      await Geolocator.requestPermission();
}
