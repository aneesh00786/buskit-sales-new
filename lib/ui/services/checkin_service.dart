import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/location_services/location_services.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/services/permission_status_service.dart';

class CheckInService {
  static final CheckInService _instance = CheckInService._internal();

  factory CheckInService() => _instance;

  CheckInService._internal();

  // Shared check-in function that can be called from anywhere
  Future<void> performCheckIn(BuildContext context) async {
    bool newState = true; // Always check-in from popup

    // Skip confirmation dialog - proceed directly to check-in

    try {
      // Basic Check
      if (!await _handleLocationPermission()) {
        return;
      }

      // Get Position for API
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Check current permission status
      var alwaysStatus = await Permission.locationAlways.status;

      // If NOT granted, show explanation dialog FIRST, then request
      if (!alwaysStatus.isGranted) {
        
        // Use root navigator context to show dialog
        bool proceed = await _showAlwaysPermissionDialog(context);
        
        if (!proceed) {
          // User chose "Use Foreground Only" - proceed with fallback
          _startForegroundTracking();
        } else {
          // User clicked "Request Always" - Try popup first
          await Permission.locationAlways.request();
          
          // Wait a moment for iOS to update the permission status
          await Future.delayed(const Duration(milliseconds: 1500));
          
          // Check if permission was granted
          var newStatus = await Permission.locationAlways.status;
          
          if (newStatus.isGranted) {
            // Permission granted! Complete check-in
            await initializeService();
            final service = FlutterBackgroundService();
            if (!await service.isRunning()) service.startService();
            
            // Update permission status service
            final permissionService = PermissionStatusService();
            await permissionService.updatePermissionStatus();
          } else {
            // Popup didn't grant Always - Open Settings instead
            // Show message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enable "Always" in Settings to enable background tracking'),
                  duration: Duration(seconds: 4),
                ),
              );
            }
            
            // Open settings
            await openAppSettings();
            return;
          }
        }
      } else {
        // Already has Always permission - start background service
        await initializeService();
        final service = FlutterBackgroundService();
        if (!await service.isRunning()) service.startService();
        
        // Update permission status service
        final permissionService = PermissionStatusService();
        await permissionService.updatePermissionStatus();
      }

      // Send API
      final response = await ApiWorker().updateAdminCheckInOut(
        date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        direction: "in",
        lat: position.latitude.toString(),
        long: position.longitude.toString(),
      );

      if (response.statusCode == 200) {
        await ApiWorker().saveSwitchState(true);
      }

      // Update permission status service to notify listeners
      final permissionService = PermissionStatusService();
      await permissionService.updatePermissionStatus();
    } catch (e) {
      if (context.mounted) {
        NkCommonFunction.showErrorSnakBar("Error: $e");
      }
    }
  }

Future<bool> _showAlwaysPermissionDialog(BuildContext context) async {
  
  // Get the context from Get.key
  final globalContext = Get.key.currentContext;

  if (globalContext == null || !globalContext.mounted) {
    return false;
  }

  
  return await showDialog<bool>(
    context: globalContext,
    barrierDismissible: false,
    builder: (builderContext) {
      return AlertDialog(
        title: CustomText(content: 'Enable Background Tracking'),
        content: CustomText(content: 'To track your location even when the app is closed (for accurate attendance), please allow "Always" permission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(builderContext, false),
            child: CustomText(content: 'Only while using the app'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(builderContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: CustomText(
              content: 'Request Always',
              color: white,
            ),
          ),
        ],
      );
    },
  ) ?? false;
}

  Future<bool> _handleLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
         NkCommonFunction.showErrorSnakBar('Location permission denied');
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return true;
  }

  void _startForegroundTracking() {
    _performForegroundUpdate();
  }

  Future<void> _performForegroundUpdate() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      initializeService();
      print("Foreground Location Update: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error in foreground update: $e");
    }
  }
}