import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityChecker extends ChangeNotifier {
  static final ConnectivityChecker _singleton = ConnectivityChecker._internal();

  factory ConnectivityChecker() {
    return _singleton;
  }

  ConnectivityChecker._internal();

  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityResult get connectivityResult => _connectivityResult;

  void startMonitoring() {
    // _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
    //   log("Connection Status :: $result");
    //   _connectivityResult = result;
    //   notifyListeners();
    // });
  }

  void stopMonitoring() {
    _connectivitySubscription.cancel();
  }
}
