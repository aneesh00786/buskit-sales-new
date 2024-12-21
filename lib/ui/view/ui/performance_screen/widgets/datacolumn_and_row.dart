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