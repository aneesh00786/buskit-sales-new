

import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';

class GroupedItemDataRows {
  static List<DataRow> getRows({
    required List<CartItem> groupedItems,
    required double fontSize,
    required double availableWidth,
    required BuildContext context,
    required Function(CartItem groupedItem, String totalPrice, double fontSize,
            double availableWidth)
        productQuantityManager,
    required Function(BuildContext context, CartItem groupedItem,
            List<CartItem> groupedItems)
        deleteConfirmationDialogue,
    required Function calculateAmount,
  }) {
    return groupedItems.map((groupedItem) {
      log('Draft id is Contains or not? == ${groupedItem.draftId}');
      log('Incl Tax  == ${groupedItem.detail.inclTax}');
      return DataRow(
        cells: [
          DataCell(
            StatefulBuilder(
              builder: (context, setState) {
                return Checkbox(
                  value: groupedItem.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      groupedItem.isChecked = value ?? false;
                      log("Checkbox for ${groupedItem.detail.variationName} is ${groupedItem.isChecked ?? true ? 'checked' : 'unchecked'}");
                    });
                    calculateAmount();
                  },
                );
              },
            ),
          ),
          DataCell(
            TableContent(
              content:
                  '${groupedItem.detail.variationName} ${groupedItem.detail.unitType}',
              fontSize: fontSize,
            ),
          ),
          DataCell(TableContent(
              fontSize: fontSize,
              maxLines: 1,
              content: formatAmount(groupedItem.detail.sellPrice ?? '0'))),
          DataCell(TableContent(
              fontSize: fontSize,
              maxLines: 2,
              content: groupedItem.isPack == true
                  ? '${groupedItem.detail.packtype} \n(${groupedItem.detail.pieces} Pcs)'
                  : 'Pcs')),
          DataCell(TableContent(
              fontSize: fontSize,
              maxLines: 1,
              content: formatAmount(
                  double.parse(groupedItem.detail.sellPrice.toString()) *
                      (groupedItem.isPack == true
                          ? groupedItem.detail.pieces!
                          : 1)))),
          DataCell(
            TableContent(
              maxLines: 1,
              fontSize: fontSize,
              content: (groupedItem.draftId?.isEmpty ?? true)
                  ? formatAmount(groupedItem.detail.tax! *
                      (groupedItem.isPack == true
                          ? groupedItem.detail.pieces!
                          : 1))
                  : formatAmount((groupedItem.draftId?.isEmpty ?? true)?groupedItem.detail.tax!*groupedItem.detail.count:groupedItem.detail.tax!),
            ),
          ),
          DataCell(
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: productQuantityManager(
                  groupedItem,
                  groupedItem.detail.inclTax?.isEmpty ?? true
                      ? (groupedItem.totalPrice + groupedItem.detail.tax!)
                          .toString()
                      : groupedItem.totalPrice.toString(),
                  fontSize,
                  availableWidth,
                ),
              ),
            ),
          ),
          DataCell(
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: CustomText(
                  content: (groupedItem.draftId?.isEmpty ?? true)
                      ? formatAmount(groupedItem.totalPrice)
                      :groupedItem.detail.inclTax==''? formatAmount(
                          groupedItem.totalPrice + groupedItem.detail.tax!):formatAmount(groupedItem.totalPrice),
                  textAlign: TextAlign.right,
                  fontSize: fontSize,
                  maxLine: 1,
                ),
              ),
            ),
          ),
          DataCell(
            Center(
              child: SizedBox(
                width: 30,
                child: IconButton(
                  icon: const Icon(
                    EneftyIcons.trash_outline,
                    color: Colors.red,
                    size: 25,
                  ),
                  onPressed: () {
                    deleteConfirmationDialogue(
                        context, groupedItem, groupedItems);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}

class TableContent extends StatelessWidget {
  double fontSize;
  String content;
  int maxLines;
  TableContent(
      {super.key,
      required this.fontSize,
      required this.content,
      this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
        child: CustomText(
          content: content,
          textAlign: TextAlign.center,
          fontSize: fontSize,
          maxLine: maxLines,
        ),
      ),
    );
  }
}


