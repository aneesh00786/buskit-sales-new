import 'package:flutter/material.dart';

Widget buildEmptyRow() {
  return Container(
    height: 60,
    child: Center(
      child: Text(
        "No Records Found",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}

Widget buildRowData(String data) {
  return Center(
    child: Text(
      data,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}