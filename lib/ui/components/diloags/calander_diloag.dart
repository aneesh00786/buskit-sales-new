import 'package:flutter/material.dart';

class CalanderDiloag extends DatePickerDialog {
  CalanderDiloag({super.key})
      : super(
            initialDate: DateTime.now(),
            firstDate: DateTime(1975),
            lastDate: DateTime.now());
}
