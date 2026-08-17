import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';

class PermissionStatusService {
  static final PermissionStatusService _instance =
      PermissionStatusService._internal();

  factory PermissionStatusService() {
    print("=== PermissionStatusService factory constructor called ===");
    print("=== Returning singleton instance: $_instance ===");
    return _instance;
  }

  PermissionStatusService._internal() {
    print("=== PermissionStatusService._internal() called ===");
  }

  // Track permission states (only always and whenInUse - these are available in permission_handler)
  PermissionStatus _alwaysStatus = PermissionStatus.denied;
  PermissionStatus _whenInUseStatus = PermissionStatus.denied;

  List<VoidCallback> _listeners = [];

  // Get current permission status values
  PermissionStatus get alwaysStatus => _alwaysStatus;
  PermissionStatus get whenInUseStatus => _whenInUseStatus;

  // BACKWARD COMPATIBILITY: Get hasAlwaysPermission as boolean
  bool get hasAlwaysPermission => _alwaysStatus == PermissionStatus.granted;

  // Check if always permission is granted
  bool get isAlwaysGranted => _alwaysStatus == PermissionStatus.granted;

  // Check if whileInUse permission is granted
  bool get isWhenInUseGranted => _whenInUseStatus == PermissionStatus.granted;

  // Check if permission is denied
  bool get isAlwaysDenied =>
      _alwaysStatus == PermissionStatus.denied ||
      _alwaysStatus == PermissionStatus.permanentlyDenied;

  bool get isWhenInUseDenied =>
      _whenInUseStatus == PermissionStatus.denied ||
      _whenInUseStatus == PermissionStatus.permanentlyDenied;

  // Map to backend-friendly values
  String get alwaysValue => _alwaysStatus == PermissionStatus.granted
      ? "always"
      : _alwaysStatus == PermissionStatus.denied
          ? "denied"
          : _alwaysStatus == PermissionStatus.permanentlyDenied
              ? "permanently_denied"
              : "unknown";

  String get whileUsingValue => _whenInUseStatus == PermissionStatus.granted
      ? "while_using"
      : _whenInUseStatus == PermissionStatus.denied
          ? "denied"
          : _whenInUseStatus == PermissionStatus.permanentlyDenied
              ? "permanently_denied"
              : "unknown";

  String get deniedValue => _alwaysStatus == PermissionStatus.denied ||
          _whenInUseStatus == PermissionStatus.denied
      ? "denied"
      : "unknown";

  String get permanentlyDeniedValue =>
      _alwaysStatus == PermissionStatus.permanentlyDenied ||
              _whenInUseStatus == PermissionStatus.permanentlyDenied
          ? "permanently_denied"
          : "unknown";

  String get restrictedValue => "unknown";

  // Listener management
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Update all permission statuses
  Future<void> updatePermissionStatus() async {
    _alwaysStatus = await Permission.locationAlways.status;
    _whenInUseStatus = await Permission.locationWhenInUse.status;

    print("=== PermissionStatusService.updatePermissionStatus called ===");
    print(
        "=== always: ${_alwaysStatus.isGranted}, whenInUse: ${_whenInUseStatus.isGranted} ===");
    print("=== Listeners count: ${_listeners.length} ===");

    if (_listeners.isNotEmpty) {
      print("=== Permission status changed, notifying listeners ===");
      _notifyListeners();
    }
  }

  // Initialize permission status
  Future<void> initialize() async {
    await updatePermissionStatus();
  }

  // Send current permission status to backend
  Future<void> sendPermissionToBackend({
    required Dio dio,
  }) async {
    // Determine the primary permission status
    String permission = "unknown";
    String platform = _determinePlatform();

    // Use the broader 'always' status if available, fall back to whenInUse
    final alwaysGranted = _alwaysStatus.isGranted;
    final whenInUseGranted = _whenInUseStatus.isGranted;

    print("=== SEND PERMISSION BACKEND ===");
    print("  _alwaysStatus: $_alwaysStatus (isGranted: $alwaysGranted)");
    print(
        "  _whenInUseStatus: $_whenInUseStatus (isGranted: $whenInUseGranted)");

    // Priority: always > while_using > denied/permanentlyDenied
    if (alwaysGranted) {
      permission = "always";
      print("  -> Mapped to: always");
    } else if (whenInUseGranted) {
      permission = "while_using";
      print("  -> Mapped to: while_using");
    } else if (_alwaysStatus == PermissionStatus.permanentlyDenied ||
        _whenInUseStatus == PermissionStatus.permanentlyDenied) {
      permission = "permanently_denied";
    } else if (_alwaysStatus == PermissionStatus.denied ||
        _whenInUseStatus == PermissionStatus.denied) {
      permission = "denied";
    } else {
      permission = "unknown";
      print("  -> Mapped to: unknown (no clear status)");
    }

    try {
      // Read login data from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final loginJsonString = prefs.getString('spLogin');

      if (loginJsonString != null && loginJsonString.isNotEmpty) {
        final Map<String, dynamic> loginMap = jsonDecode(loginJsonString);
        // Extract company_id and salesmanId from login data
        final companyId = loginMap['company_id'] ?? 0;
        final salesmanId = loginMap['id'] ?? '';

        final url = '${ApiConstants.baseUrl}users/location-permission';

        final formData = {
          "permission": permission,
          "platform": platform,
          "companyId": companyId,
          "salesmanId": salesmanId,
        };

        print(
            "  -> Payload: permission=$permission, platform=$platform, companyId=$companyId, salesmanId=$salesmanId");

        await dio.post(url, data: formData);
        print("Permission status sent to backend: $permission / $platform");
      } else {
        print(
            "=== No login data found in spLogin, skipping permission sync ===");
      }
    } catch (e) {
      print("Error sending permission to backend: $e");
      // Don't interrupt normal app usage - log and retry later
    }
  }

  // Determine platform from device
  String _determinePlatform() {
    // In a real implementation, check device.platform
    // For now, use the existing pattern from checkin_service
    return "android"; // Will be overridden by actual platform detection
  }

  // Map permission status to backend-friendly value
  String mapToBackendValue() {
    if (_alwaysStatus == PermissionStatus.granted) return "always";
    if (_whenInUseStatus == PermissionStatus.granted) return "while_using";
    if (_alwaysStatus == PermissionStatus.permanentlyDenied ||
        _whenInUseStatus == PermissionStatus.permanentlyDenied)
      return "permanently_denied";
    if (_alwaysStatus == PermissionStatus.denied ||
        _whenInUseStatus == PermissionStatus.denied) return "denied";
    return "unknown";
  }
}
