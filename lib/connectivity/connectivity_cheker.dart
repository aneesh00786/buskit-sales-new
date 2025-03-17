import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityChecker extends ChangeNotifier {
  static final ConnectivityChecker _singleton = ConnectivityChecker._internal();

  factory ConnectivityChecker() {
    return _singleton;
  }

  ConnectivityChecker._internal();

  final ConnectivityResult _connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityResult get connectivityResult => _connectivityResult;

  void startMonitoring() {}

  void stopMonitoring() {
    _connectivitySubscription.cancel();
  }
}
