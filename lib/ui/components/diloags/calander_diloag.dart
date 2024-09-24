import 'package:flutter/material.dart';

class CalanderDiloag extends DatePickerDialog {
  CalanderDiloag({Key? key})
      : super(
            key: key,
            initialDate: DateTime.now(),
            firstDate: DateTime(1975),
            lastDate: DateTime.now());
}
