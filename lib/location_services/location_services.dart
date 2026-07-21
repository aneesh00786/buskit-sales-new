import 'dart:async';
import 'dart:convert'; // For jsonEncode
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:dio/dio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Define and create the channel explicitly
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // Must match your notificationChannelId below
    'Salesman Tracker', // Title shown in settings
    description: 'This channel is used for location tracking notifications.',
    importance: Importance
        .low, // Must be Importance.low or higher; low is fine for non-intrusive
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Create the channel on the device
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground', // Matches the channel ID above
      initialNotificationTitle: 'Salesman Tracker',
      initialNotificationContent: 'Updating location to server...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // 1. Initialize plugins
  DartPluginRegistrant.ensureInitialized();

  // 2. Define the Timer variable so we can cancel it later
  Timer? locationTimer;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // 3. Handle Stop Service
  service.on('stopService').listen((event) {
    // Cancel the timer to stop API calls
    locationTimer?.cancel();
    service.stopSelf();
  });

  const Duration timeInterval = Duration(seconds: 10);
  // ---------------------------------------------------------

  // 4. Define the logic to fetch location and send to server
  Future<void> fetchAndSendLocation() async {
    try {
      // Check if user is checked in
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs
          .reload(); // IMPORTANT: Reload SharedPreferences to get latest state from main isolate

      final bool isCheckedIn = prefs.getBool('switch_state') ?? false;
      if (!isCheckedIn) {
        // print("Background service running but switch_state is false. Stopping service.");
        locationTimer?.cancel();
        service.stopSelf();
        return;
      }

      final DateTime now = DateTime.now();
      bool isExpired = false;

      // 1. Check if current time is past 'to_time' from settings
      final String settingsJson = prefs.getString(SpString.settingsKey) ?? "";
      String toTimeStr = "";
      if (settingsJson.isNotEmpty) {
        try {
          final List<dynamic> jsonList = jsonDecode(settingsJson);
          for (var item in jsonList) {
            if (item['key'] == 'to_time') {
              toTimeStr = item['value'] ?? "";
              break;
            }
          }
        } catch (e) {
          print("Error parsing settings data for to_time in background: $e");
        }
      }
      if (toTimeStr.isEmpty) {
        toTimeStr = "18:00"; // fallback default
      }

      final parts = toTimeStr.split(":");
      if (parts.length >= 2) {
        final int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);
        final DateTime endDt = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (now.isAfter(endDt)) {
          isExpired = true;
        }
      }

      // 2. Check check-in time day change if present
      final String checkInTimeStr = prefs.getString('check_in_time') ?? "";
      if (checkInTimeStr.isNotEmpty) {
        final DateTime checkInTime = DateTime.parse(checkInTimeStr);
        if (checkInTime.year != now.year ||
            checkInTime.month != now.month ||
            checkInTime.day != now.day) {
          isExpired = true;
        }
      }

      if (isExpired) {
        print(
          "Check-in expired (end time reached or day changed) in background service. Stopping background service.",
        );

        // Send automatic check-out API request
        try {
          final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
          final String time = DateFormat('HH:mm').format(DateTime.now());

          final String loginJsonString =
              prefs.getString(SpString.spLogin) ?? "";
          if (loginJsonString.isNotEmpty) {
            final Map<String, dynamic> loginMap = jsonDecode(loginJsonString);
            final LoginData loginData = LoginData.fromJson(loginMap);

            final connectivityService = ConnectivityService();
            final isOnline = await connectivityService.isOnline();

            if (isOnline) {
              final Dio dio = Dio();
              dio.options.connectTimeout = const Duration(seconds: 10);
              dio.options.receiveTimeout = const Duration(seconds: 10);

              final url =
                  '${ApiConstants.baseUrl}${ApiConstants.updateCheckinOut}';
              final FormData formData = FormData.fromMap({
                "companyId": loginData.company_id ?? 0,
                "date": date,
                "sales_id": loginData.id,
                "time": time,
                "direction": "out",
                "latitude": "0.0",
                "longitude": "0.0",
              });

              final Response response = await dio.post(url, data: formData);
              print(
                "Automatic background checkout response: ${response.statusCode}",
              );
            } else {
              print("Offline in background: Skipping checkout API call.");
            }
          }
        } catch (e) {
          print("Error during auto checkout API in background service: $e");
        }

        locationTimer?.cancel();
        service.stopSelf();

        await prefs.setBool('switch_state', false);
        await prefs.remove('check_in_time');
        return;
      }

      // Get the current position explicitly
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // print("Time-based background update: ${DateTime.now()}");

      // Call your existing server update function
      await updateServer(position);

      // Optional: Update the notification to show "Last synced: 10:30 AM"
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Salesman Tracker',
          content:
              'Last updated: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
        );
      }
    } catch (e) {
      print("Error fetching location in background: $e");
    }
  }

  // 5. Run immediately once when service starts (so user doesn't wait for first interval)
  await fetchAndSendLocation();

  // 6. Start the periodic timer
  locationTimer = Timer.periodic(timeInterval, (timer) async {
    await fetchAndSendLocation();
  });
}

Future<void> updateServer(Position position) async {
  try {
    // 1. ADD CONNECTIVITY CHECK HERE
    final connectivityService = ConnectivityService();
    final isOnline = await connectivityService.isOnline();

    if (!isOnline) {
      print(
        "Offline: Skipping live location update. (Consider saving to Hive for later sync)",
      );
      // Optional: Save coordinates to a local Hive box here to sync route history later
      return;
    }

    final Dio dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    final url = '${ApiConstants.baseUrl}update-salesman-location';

    String? loginJsonString = await SessionManager.getStringValue(
      SpString.spLogin,
    );
    int companyId = 0;
    String salesmanId = '0';

    if (loginJsonString != null && loginJsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> loginMap = jsonDecode(loginJsonString);
        final LoginData loginData = LoginData.fromJson(loginMap);
        companyId = loginData.company_id ?? 0;
        salesmanId = loginData.salesmanId ?? '0';
      } catch (e) {
        print("Error parsing login data in background service: $e");
      }
    } else {
      return;
    }

    final Map<String, dynamic> body = {
      "companyId": companyId,
      "salesmanId": salesmanId,
      "latitude": position.latitude,
      "longitude": position.longitude,
    };

    final Response response = await dio.post(url, data: body);
    // print("Sent Location: ${position.latitude}, ${position.longitude}");
  } on DioException catch (e) {
    print("Error sending location: ${e.message}");
  } catch (e) {
    print("Unexpected error sending location: $e");
  }
}
// Future<void> updateServer(Position position) async {
//   try {
//     // print('starting update to server');

//     // Create a Dio instance (you can make this a singleton elsewhere for reuse)
//     final Dio dio = Dio();

//     // Optional: Set default timeouts (in milliseconds)
//     dio.options.connectTimeout = const Duration(seconds: 10);
//     dio.options.receiveTimeout = const Duration(seconds: 10);
//       final url = '${ApiConstants.baseUrl1}/update-salesman-location';

//     // final url = 'https://test.thrivewoo.com/update-salesman-location';
    

//     String? loginJsonString = await SessionManager.getStringValue(SpString.spLogin);

//     int companyId = 0;
//     String salesmanId = '0';

//     if (loginJsonString != null && loginJsonString.isNotEmpty) {
//       try {
//         final Map<String, dynamic> loginMap = jsonDecode(loginJsonString);
//         final LoginData loginData = LoginData.fromJson(loginMap);

//         companyId = loginData.company_id ?? 0;
//         salesmanId = loginData.salesmanId ?? '0';
//       } catch (e) {
//         print("Error parsing login data in background service: $e");
//       }
//     } else {
//       print("No login data found in SharedPreferences - user probably logged out");
//       // Optionally stop the service or skip sending
//       return;
//     }
//   print('companyId: $companyId');
//   print('salesmanId: $salesmanId');
//     // Your specific payload (Dio will automatically jsonEncode Maps)
//     final Map<String, dynamic> body = {
//      "companyId": companyId,
//       "salesmanId": salesmanId,
//       "latitude": position.latitude,
//       "longitude": position.longitude,
//     };

//     // Make the POST requesttt
//     final Response response = await dio.post(
//       url,
//       data: body,  // Dio automatically sets Content-Type to application/json and encodes the body
//     );

//     print("Sent Location: ${position.latitude}, ${position.longitude}");
//     print("Response Status: ${response.statusCode}");
//     print("Response Body: ${response.data}");  // response.data is already parsed if JSON

//   } on DioException catch (e) {
//     // Better error handling with DioException
//     print("Error sending location: ${e.message}");
//     if (e.response != null) {
//       // Server responded with error status (e.g., 4xx, 5xx)
//       print("Error Response Status: ${e.response?.statusCode}");
//       print("Error Response Body: ${e.response?.data}");
//     } else {
//       // Something else happened (timeout, no connection, etc.)
//       print("Request failed: $e");
//     }
//   } catch (e) {
//     print("Unexpected error sending location: $e");
//   }
// }