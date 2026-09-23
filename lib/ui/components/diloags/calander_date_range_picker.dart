import 'package:flutter/material.dart';

class CalenderDateRangePicker extends DateRangePickerDialog {
  const CalenderDateRangePicker(
      {super.key,
      required super.firstDate,
      super.currentDate,
      required super.lastDate})
      : super(initialEntryMode: DatePickerEntryMode.input);
}
