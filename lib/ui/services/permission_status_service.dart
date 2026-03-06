import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';

class PermissionStatusService {
  static final PermissionStatusService _instance = PermissionStatusService._internal();

  factory PermissionStatusService() {
    print("=== PermissionStatusService factory constructor called ===");
    print("=== Returning singleton instance: $_instance ===");
    return _instance;
  }

  PermissionStatusService._internal() {
    print("=== PermissionStatusService._internal() called ===");
  }

  bool _hasAlwaysPermission = false;
  List<VoidCallback> _listeners = [];

  // Get current permission status
  bool get hasAlwaysPermission => _hasAlwaysPermission;

  // Update permission status and notify listeners
  Future<void> updatePermissionStatus() async {
    var alwaysStatus = await Permission.locationAlways.status;
    bool newStatus = alwaysStatus.isGranted;
    
    print("=== PermissionStatusService.updatePermissionStatus called ===");
    print("=== Current permission status: $newStatus ===");
    print("=== Previous permission status: $_hasAlwaysPermission ===");
    print("=== Listeners count: ${_listeners.length} ===");
    
    if (newStatus != _hasAlwaysPermission) {
      _hasAlwaysPermission = newStatus;
      print("=== Permission status changed, notifying listeners ===");
      _notifyListeners();
    } else {
      print("=== Permission status unchanged, no notification needed ===");
    }
  }

  // Add listener to be notified when permission status changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Initialize permission status
  Future<void> initialize() async {
    await updatePermissionStatus();
  }
}