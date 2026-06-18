import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/location_services/location_services.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
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

  Timer? _foregroundTimer;

  // ✅ Add this flag
  static bool isReturningFromSettings = false;
  static RxBool isCheckingIn = false.obs;

  Future<void> performCheckIn(BuildContext context) async {
    isCheckingIn.value = true;
    try {
      if (!await _handleLocationPermission()) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      var alwaysStatus = await Permission.locationAlways.status;

      if (!alwaysStatus.isGranted) {
        bool proceed = await _showAlwaysPermissionDialog(context, alwaysStatus.isPermanentlyDenied);

        if (!proceed) {
          _startForegroundTracking();
        } else {
          var requestStatus = await Permission.locationAlways.request();

          if (requestStatus.isGranted) {
            await _startBackgroundService();
          } else {
            // If the popup didn't come (or was permanently denied), redirect to settings
            if (requestStatus.isPermanentlyDenied) {
              isReturningFromSettings = true;
              await openAppSettings();
              await _waitForAppResume();
              isReturningFromSettings = false;
            }
            
            // Verify final permission statuses after potential settings change
            var finalAlwaysStatus = await Permission.locationAlways.status;
            var finalWhenInUseStatus = await Permission.locationWhenInUse.status;

            if (finalAlwaysStatus.isGranted) {
              await _startBackgroundService();
            } else if (finalWhenInUseStatus.isGranted) {
              _startForegroundTracking();
            } else {
              NkCommonFunction.showErrorSnakBar('Location permission is required to check in.');
              return; // Abort check-in entirely if they denied everything
            }
          }
        }
      } else {
        await _startBackgroundService();
      }

      await _completeCheckIn(context, position);

    } catch (e) {
      isReturningFromSettings = false; // ✅ Clear on error too
      if (context.mounted) {
        NkCommonFunction.showErrorSnakBar("Error: $e");
      }
    } finally {
      isCheckingIn.value = false;
    }
  }

  Future<void> _waitForAppResume() async {
    final completer = Completer<void>();
    late final AppLifecycleListener listener;
    listener = AppLifecycleListener(
      onResume: () {
        if (!completer.isCompleted) completer.complete();
        listener.dispose();
      },
    );
    await completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {},
    );
  }

  Future<void> _startBackgroundService() async {
    await initializeService();
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) service.startService();
    final permissionService = PermissionStatusService();
    await permissionService.updatePermissionStatus();
  }
  Future<void> _completeCheckIn(BuildContext context, Position position) async {
  final connectivityService = ConnectivityService();
  final isOnline = await connectivityService.isOnline();
  
  final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final time = DateFormat('HH:mm').format(DateTime.now());
  final lat = position.latitude.toString();
  final long = position.longitude.toString();

  if (!isOnline) {
    // 1. OFFLINE LOGIC: Save Admin Check-in to Hive
    final box = await Hive.openBox('offlineRequests');
    final payload = {
      // Add necessary fields for admin check-in based on your API requirements
      "date": date,
      "time": time,
      "direction": "in",
      "latitude": lat,
      "longitude": long,
    };
    
    await box.add({
      'url': ApiConstants.baseUrl + 'update-admin-check-in-endpoint', // Replace with exact endpoint
      'payload': payload,
    });
    
    // Treat as successfully checked in locally so the UI updates
    await ApiWorker().saveSwitchState(true);
    
  } else {
    // 2. ONLINE LOGIC: Hit API
    final response = await ApiWorker().updateAdminCheckInOut(
      date: date,
      time: time,
      direction: "in",
      lat: lat,
      long: long,
    );

    if (response.statusCode == 200) {
      await ApiWorker().saveSwitchState(true);
    }
  }

  final permissionService = PermissionStatusService();
  await permissionService.updatePermissionStatus();
}

  Future<bool> _showAlwaysPermissionDialog(BuildContext context, bool isPermanentlyDenied) async {
    final globalContext = Get.key.currentContext;

    if (globalContext == null || !globalContext.mounted) {
      return false;
    }

    return await showDialog<bool>(
      context: globalContext,
      barrierDismissible: false,
      builder: (builderContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
          actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          title: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 25.0,
                color: primaryColor,
              ),
              const SizedBox(width: 8.0),
               Expanded(
                child: Text(
                  'Background Tracking'.tr,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content:  Text(
            'To track your location even when the app is closed (for accurate attendance), please allow "Always" permission.'.tr,
            style: TextStyle(
              fontSize: 19.0,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                side: BorderSide(color: primaryColor, width: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.white,
                elevation: 3,
              ),
              onPressed: () => Navigator.pop(builderContext, false),
              child: Text(
                'Only while using'.tr,
                style: TextStyle(
                  fontSize: 14.0,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(builderContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              child: Text(
                isPermanentlyDenied ? 'Open Settings'.tr : 'Request Always'.tr,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
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
      bool? openSettings = await _showSettingsDialog();
      if (openSettings != true) return false;

      isReturningFromSettings = true;
      await openAppSettings();
      await _waitForAppResume();
      isReturningFromSettings = false;
      
      status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        NkCommonFunction.showErrorSnakBar('Location permission denied');
        return false;
      }
    }
    return true;
  }

  Future<bool?> _showSettingsDialog() async {
    final globalContext = Get.key.currentContext;
    if (globalContext == null || !globalContext.mounted) return false;

    return await showDialog<bool>(
      context: globalContext,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
        actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
              size: 25.0,
              color: primaryColor,
            ),
            const SizedBox(width: 8.0),
            const Expanded(
              child: Text(
                'Permission Required',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Location permission is permanently denied. Please open settings to enable it to check in.',
          style: TextStyle(
            fontSize: 19.0,
            color: Colors.black87,
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              side: BorderSide(color: primaryColor, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.white,
              elevation: 3,
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.0,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.4),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Open Settings',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void stopTracking() {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    _stopForegroundTracking();
  }

  void _startForegroundTracking() {
    print("Starting foreground tracking (Timer Mode)...");
    _stopForegroundTracking(); // Ensure no multiple timers
    _performForegroundUpdate();
    _foregroundTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _performForegroundUpdate();
    });
  }

  void _stopForegroundTracking() {
    if (_foregroundTimer != null) {
      _foregroundTimer!.cancel();
      _foregroundTimer = null;
      print("Stopped foreground tracking.");
    }
  }

  Future<void> _performForegroundUpdate() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await updateServer(position);
      print("Foreground Location Update: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error in foreground update: $e");
    }
  }
}