import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red, int durationSeconds = 3}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: Text(message),
      duration: Duration(seconds: durationSeconds),
    ),
  );
}
