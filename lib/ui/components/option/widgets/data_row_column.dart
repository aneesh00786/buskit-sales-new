import 'package:flutter/material.dart';

DataRow dataRowOrderstatus(double flexWidth) {
  return DataRow(
    cells: [
      DataCell(
        SizedBox(width: flexWidth * 1.5),
      ),
      DataCell(
        SizedBox(width: flexWidth * 0.9),
      ),
      DataCell(
        SizedBox(width: flexWidth * 1),
      ),
      DataCell(
        SizedBox(width: flexWidth * 1),
      ),
      DataCell(
        SizedBox(width: flexWidth * 1),
      ),
      DataCell(
        SizedBox(width: flexWidth * 0.9),
      ),
      DataCell(
        SizedBox(width: flexWidth * 1.1),
      ),
      DataCell(
        SizedBox(width: flexWidth * 1.1),
      ),
      const DataCell(Text('')),
    ],
  );
}