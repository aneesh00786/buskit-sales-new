import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
    Timer.periodic(Duration(seconds: 5), (_) => _checkInternetConnectivity());
  }

  Future<void> _checkInternetConnectivity() async {
    bool isConnected = await _connectivityService.isOnline();
    if (isConnected && !_isOnline) {
      _startSyncing();
    }
    setState(() {
      _isOnline = isConnected;
    });
  }

  Future<void> _startSyncing() async {
    setState(() {
      _isSyncing = true;
    });
    await Future.delayed(Duration(seconds: 3)); 
    widget.onSync(); 
    setState(() {
      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 100,
      decoration: BoxDecoration(
        color: !_isOnline ? const Color.fromARGB(255, 137, 198, 248) : const Color.fromARGB(255, 178, 187, 226),
        borderRadius: BorderRadius.circular(10),
      ),
child: InkWell(
  onTap: !_isOnline
      ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber,color: red,),
                  SizedBox(width: 10,),
                  Text('You are offline. Please check your connection.',style: TextStyle(color: black),),
                ],
              ),
              backgroundColor: white,
            ),
          );
        }
      : () {
          _startSyncing();
        },
  child: Center(
    child: _isSyncing
        ? SizedBox(
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
                style: TextStyle(color: Colors.white,fontFamily: "Poppins_Regular"),
                
              ),
              SizedBox(width: 5),
              Icon(Icons.replay_outlined, size: 15, color: Colors.white),
            ],
          ),
  ),
),

    );
  }
}

