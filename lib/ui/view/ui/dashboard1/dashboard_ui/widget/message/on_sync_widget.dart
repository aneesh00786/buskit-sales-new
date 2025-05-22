// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncButtonWidget extends StatefulWidget {
  final Function onSync;

  const SyncButtonWidget({super.key, required this.onSync});

  @override
  // ignore: library_private_types_in_public_api
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
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    setState(() {
      _isSyncing = true;
    });
    widget.onSync();
    await Future.delayed(const Duration(seconds: 2));
    await CartDatabaseManager().getDraftItems();
    await ApiWorker().fetchDiscounts(companyId, salesmanId);
    log('This Works Now');
    await _updateLastSyncTime();
    setState(() {
      _isSyncing = false;
    });
  }

  String _formatLastSyncTime() {
    if (_lastSyncTime == null) {
      return "";
    }
    return DateFormat('dd/MM/yyyy : hh:mm a').format(_lastSyncTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 40,
          width: fullScreenWidth(context) > 600 ? 100 : 70,
          decoration: BoxDecoration(
            color: !_isOnline
                ? const Color.fromARGB(255, 201, 199, 199)
                : const Color.fromARGB(255, 74, 176, 248).withOpacity(0.7),
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
                         Text(
                          'Sync',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins_Regular",
                            fontSize:
                                fullScreenWidth(context) > 600 ? null : 10,
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
            color: Colors.white,
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
    const SnackBar(
      content: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red),
          SizedBox(width: 10),
          Text(
            'You are offline. Please check your connection.',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    ),
  );
}
