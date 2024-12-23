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
  }) {
    return groupedItems.map((groupedItem) {
      return DataRow(
        cells: [
          DataCell(
            TableContent(
              content:
                  '${groupedItem.detail.variationName} ${groupedItem.detail.unitType}',
              fontSize: fontSize,
            ),
          ),
          DataCell(TableContent(
              fontSize: fontSize,
              content:
                  '${groupedItem.detail.packtype}/ ${groupedItem.detail.pieces} Pcs')),
          DataCell(TableContent(
              fontSize: fontSize,
              content:
                  formatAmount(groupedItem.detail.price ?? '0'))),
          DataCell(TableContent(
              fontSize: fontSize,
              content:
                  '${double.parse(groupedItem.detail.tax ?? '0').toStringAsFixed(2)}')),
          DataCell(
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: productQuantityManager(
                  groupedItem,
                  groupedItem.totalPrice.toString(),
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
                  content: formatAmount(groupedItem.totalPrice.toStringAsFixed(2)),
                  textAlign: TextAlign.right,
                  fontSize: fontSize,
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
  TableContent({super.key, required this.fontSize, required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
        child: CustomText(
          content: content,
          textAlign: TextAlign.center,
          fontSize: fontSize,
        ),
      ),
    );
  }
}