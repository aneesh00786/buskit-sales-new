import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartColumnWidths {
  static const double checkbox = 30;
  static const double variant = 160;
  static const double unitPrice = 85;
  static const double packPrice = 85;
  static const double pack = 80;
  static const double quantity = 115;
  static const double price = 85;
  static const double disc = 90;
  static const double tax = 90;
  static const double total = 85;
  static const double delete = 45;
}


class _HeaderText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign align;

  const _HeaderText({
    required this.text,
    this.fontSize = 12.0,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        fontFamily: 'Poppins_Regular',
      ),
    );
  }
}

class DataTableColumns {
  static List<DataColumn> getColumns(double fontSize,
      {bool isBundle = false}) {
    final double headerFontSize = fontSize >= 15.0 ? fontSize : 15.0;
    return [
      const DataColumn(
        label: SizedBox(width: CartColumnWidths.checkbox),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.variant, child: _HeaderText(
          text: isBundle ? 'Bundle Name'.tr : 'Variant'.tr,
          fontSize: headerFontSize,
          align: TextAlign.start,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.unitPrice, child: _HeaderText(
          text: 'Unit Price'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.packPrice, child: _HeaderText(
          text: 'Pack Price'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.pack, child: _HeaderText(
          text: 'Pack'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.quantity, child: _HeaderText(
          text: 'Quantity'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.price, child: _HeaderText(
          text: 'Price'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.disc, child: _HeaderText(
          text: 'Disc'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.tax, child: _HeaderText(
          text: 'Tax'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.total, child: _HeaderText(
          text: 'Total'.tr,
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
      DataColumn(
        label: SizedBox(width: CartColumnWidths.delete, child: _HeaderText(
          text: '',
          fontSize: headerFontSize,
          align: TextAlign.center,
        ),),
      ),
    ];
  }
}
