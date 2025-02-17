import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
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
Widget buildRowData(String data, {Color? textColor = black}) {
  return Center(
    child: Text(
      data,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    ),
  );
}