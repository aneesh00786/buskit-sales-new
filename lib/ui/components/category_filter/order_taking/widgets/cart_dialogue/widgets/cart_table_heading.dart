import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';

class DataTableColumns {
  static List<DataColumn> getColumns(double fontSize) {
    return [
      DataColumn(
        label: DialogTableHeaderText(
          text: '',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Variant',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Unit Price',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Pack',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Price',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Tax',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Quantity',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Total',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: '',
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
    ];
  }
}


