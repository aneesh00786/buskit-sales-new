import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncButtonWidget extends StatefulWidget {
  final Function onSync;

  const SyncButtonWidget({Key? key, required this.onSync}) : super(key: key);

  @override
  _SyncButtonWidgetState createState() => _SyncButtonWidgetState();
}

class _SyncButtonWidgetState extends State<SyncButtonWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;
  bool _isSyncing = false;
  Timer? _connectivityCheckTimer;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _loadLastSyncTime();
    checkInternetConnectivity();
    _connectivityCheckTimer = Timer.periodic(
        const Duration(seconds: 5), (_) => checkInternetConnectivity());
  }

  Future<void> _loadLastSyncTime() async {
    final lastSyncTime = await _getLastSyncTime();
    setState(() {
      _lastSyncTime = lastSyncTime;
    });
  }

  @override
  void dispose() {
    _connectivityCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> checkInternetConnectivity() async {
    bool isConnected = await _connectivityService.isOnline();
    if (isConnected && !_isOnline) {
      _startSyncing();
    }
    if (mounted) {
      setState(() {
        _isOnline = isConnected;
      });
    }
    
  }

  Future<void> _startSyncing() async {
    setState(() {
      _isSyncing = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    await _updateLastSyncTime();
    setState(() {
      _isSyncing = false;
    });
  }

  String _formatLastSyncTime() {
    if (_lastSyncTime == null) {
      return "";
    }
    return "${DateFormat('dd/MM/yyyy : hh:mm a').format(_lastSyncTime!)}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 40,
          width: 100,
          decoration: BoxDecoration(
            color: !_isOnline
                ? const Color.fromARGB(255, 201, 199, 199)
                : primaryColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: !_isOnline
                ? () {
                    showNoInternetSnackBar(context);
                  }
                : _startSyncing,
            child: Center(
              child: _isSyncing
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sync',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins_Regular",
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.replay_outlined,
                          size: 15,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _formatLastSyncTime(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _updateLastSyncTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastSyncTime', now.toIso8601String());
    setState(() {
      _lastSyncTime = now;
    });
  }

  Future<DateTime?> _getLastSyncTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastSyncTimeString = prefs.getString('lastSyncTime');
    if (lastSyncTimeString == null) {
      return null;
    }
    return DateTime.parse(lastSyncTimeString);
  }
}

void showNoInternetSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red),
          const SizedBox(width: 10),
          Text(
            'You are offline. Please check your connection.',
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    ),
  );
}
