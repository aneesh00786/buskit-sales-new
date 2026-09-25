<<<<<<< HEAD
import 'package:flutter/material.dart';

class CalenderDateRangePicker extends DateRangePickerDialog {
  const CalenderDateRangePicker(
      {super.key,
      required super.firstDate,
      super.currentDate,
      required super.lastDate})
      : super(initialEntryMode: DatePickerEntryMode.input);
=======
// ignore_for_file: overridden_fields

import 'package:flutter/material.dart';
class CalenderDateRangePicker extends DateRangePickerDialog {
  @override
  final DateTime firstDate;
  @override
  final DateTime lastDate;
  @override
  final DateTime? currentDate;
  const CalenderDateRangePicker(
      {super.key,
      required this.firstDate,
      this.currentDate,
      required this.lastDate})
      : super(
            firstDate: firstDate,
            lastDate: lastDate,
            currentDate: currentDate,
            initialEntryMode: DatePickerEntryMode.input);
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
}
