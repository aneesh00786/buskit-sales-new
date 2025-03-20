import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:flutter/material.dart';

Widget buildEmptyRow() {
  return const SizedBox(
    height: 60,
    child: Center(
      child: Text(
        "No Records Found",
        style: TextStyle(
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