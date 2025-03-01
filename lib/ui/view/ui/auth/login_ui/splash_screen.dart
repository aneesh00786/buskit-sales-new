import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final String message;

  const SplashScreen({Key? key, this.message = "Loading..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: white,),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: white),
            ),
          ],
        ),
      ),
    );
  }
}

