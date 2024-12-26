import 'package:flutter/material.dart';

DataColumn dataColumn({required String label}) {
  return DataColumn(
      label: Center(
    child: Text(
      label,
      maxLines: 2,
    ),
  ));
}

DataColumn dataColumn1({required String label}) {
  return DataColumn(
      label: Expanded(
    child: Center(
      child: Text(
        label,
        maxLines: 2,
      ),
    ),
  ));
}
