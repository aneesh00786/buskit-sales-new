import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataTableColumns {
  static List<DataColumn> getColumns(double fontSize,
      {bool isBundle = false}) {
    return [
      const DataColumn(
        label: SizedBox(width: 30),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: isBundle ? 'Bundle Name'.tr : 'Variant'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Unit Price'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Pack Price'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Pack'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Quantity'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Price'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Disc'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Tax'.tr,
          fontSize: fontSize,
          align: TextAlign.center,
        ),
      ),
      DataColumn(
        label: DialogTableHeaderText(
          text: 'Total'.tr,
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
