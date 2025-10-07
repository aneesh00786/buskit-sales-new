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
      final taxDiscountAmount = ((groupedItem.detail.tax ?? 0.0) *
          ((groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
              ? (groupedItem.detail.pieces?.toDouble() ?? 1) *
                  groupedItem.detail.count.toDouble()
              : groupedItem.detail.count.toDouble()) *
          ((double.tryParse(groupedItem.detail.discount?.toString() ?? '0') ??
                  0.0) /
              100));
      final discountPrice =
          (((double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '0') ??
                      0.0) *
                  ((double.tryParse(
                              groupedItem.detail.discount?.toString() ?? '0') ??
                          0.0) /
                      100)) *
              ((groupedItem.isPack == true ||
                      groupedItem.detail.packtype == 'Pack')
                  ? (groupedItem.detail.pieces?.toDouble() ?? 1) *
                      groupedItem.detail.count.toDouble()
                  : groupedItem.detail.count.toDouble()));
      final tax = (groupedItem.detail.tax ?? 0) *
          (groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack'
              ? (groupedItem.detail.pieces ?? 0) * groupedItem.detail.count
              : 1);
      // log('Tax Discount Row Item : $discountPrice');
      // log('Tax Discount Row Item : $taxDiscountAmount');
      // log('Draft id is Contains or not? == ${groupedItem.draftId}');
      // log('Incl Tax  == ${groupedItem.detail.inclTax}');
      // log('Discount Amount on Get Rows : ${groupedItem.detail.discount}');
      log('[PROMO CODE] : ${groupedItem.promoCode}');
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 30,
              child: StatefulBuilder(
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
          ),
          DataCell(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableContent(
                  content:
                      '${groupedItem.detail.variationName} ${groupedItem.detail.unitType}',
                  fontSize: fontSize,
                  maxLines: groupedItem.promoCode == null ? 2 : 1,
                ),
                if (groupedItem.promoCode != null &&
                    groupedItem.promoMsg != null) ...[
                  InkWell(
                    onTap: () {
                      if (groupedItem.promoMsg!.startsWith("Bundle")) {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            // Parse the bundle message to extract bundle items
                            final String bundleMsg = groupedItem.promoMsg ?? '';
                            final List<Map<String, String>> bundleItems = [];

                            // Extract bundle title
                            String bundleTitle = '';
                            if (bundleMsg.startsWith('Bundle:')) {
                              final titleEndIndex = bundleMsg.indexOf('\n\n');
                              if (titleEndIndex > 0) {
                                bundleTitle = bundleMsg
                                    .substring(7, titleEndIndex)
                                    .trim();
                              }
                            }

                            // Extract items from the message
                            if (bundleMsg.contains('Items included:')) {
                              final itemsStartIndex =
                                  bundleMsg.indexOf('Items included:') +
                                      'Items included:'.length;
                              final itemsEndIndex =
                                  bundleMsg.lastIndexOf('Bundle Price:');

                              if (itemsStartIndex > 0 &&
                                  itemsEndIndex > itemsStartIndex) {
                                final itemsSection = bundleMsg
                                    .substring(itemsStartIndex, itemsEndIndex)
                                    .trim();
                                final itemBlocks = itemsSection.split('\n\n');

                                for (final block in itemBlocks) {
                                  if (block.trim().isEmpty) continue;

                                  final lines = block.split('\n');
                                  if (lines.length >= 4) {
                                    // Extract product name and variant
                                    String productName = '';
                                    String variantName = '';
                                    if (lines[0].startsWith('• ')) {
                                      final fullProductText =
                                          lines[0].substring(2);
                                      // Split product name and variant if it contains a comma
                                      if (fullProductText.contains(',')) {
                                        final parts =
                                            fullProductText.split(',');
                                        productName = parts[0].trim();
                                        variantName = parts.length > 1
                                            ? parts[1].trim()
                                            : '';
                                      } else {
                                        productName = fullProductText;
                                      }
                                    }

                                    // Extract quantity
                                    String quantity = '';
                                    if (lines[1].trim().startsWith('Qty:')) {
                                      quantity =
                                          lines[1].trim().substring(4).trim();
                                    }

                                    // Extract price
                                    String price = '';
                                    if (lines[2].trim().startsWith('Price:')) {
                                      price =
                                          lines[2].trim().substring(6).trim();
                                    }

                                    // Extract total
                                    String total = '';
                                    if (lines[3].trim().startsWith('Total:')) {
                                      total =
                                          lines[3].trim().substring(6).trim();
                                    }

                                    bundleItems.add({
                                      'product': productName,
                                      'variant': variantName,
                                      'quantity': quantity,
                                      'price': price,
                                      'total': total,
                                    });
                                  }
                                }
                              }
                            }

                            // Extract bundle price
                            String bundlePrice = '';
                            if (bundleMsg.contains('Bundle Price:')) {
                              final priceStartIndex =
                                  bundleMsg.lastIndexOf('Bundle Price:') +
                                      'Bundle Price:'.length;
                              bundlePrice =
                                  bundleMsg.substring(priceStartIndex).trim();
                            }

                            return AlertDialog(
                              title: Text('Bundle Details: ${bundleTitle}'),
                              content: Container(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(groupedItem.promoCode ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade800,
                                            fontSize: 18)),
                                    const SizedBox(height: 16),

                                    // Table header
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade400),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Product',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Quantity',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Price',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Total',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Table rows
                                    Container(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            200, // Set a max height for scrolling
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: bundleItems.map((item) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item['product'] ??
                                                                '',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          if ((item['variant'] ??
                                                                  '')
                                                              .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4.0,
                                                                      left:
                                                                          8.0),
                                                              child: Text(
                                                                item['variant'] ??
                                                                    '',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        item['quantity'] ?? '',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        item['price'] ?? '',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        item['total'] ?? '',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),

                                    // Bundle total
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade400),
                                          top: BorderSide(
                                              color: Colors.grey.shade400),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 7,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Bundle Price:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                bundlePrice,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.green.shade800,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('OK'),
                                )
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Applied Offer'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(groupedItem.promoCode ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade800,
                                          fontSize: 20)),
                                  const SizedBox(height: 8),
                                  Text(groupedItem.promoMsg ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('OK'),
                                )
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.green.shade400,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 8),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color.fromARGB(255, 222, 255, 223),
                                Color.fromARGB(255, 185, 255, 187),
                              ],
                            ),
                          ),
                          child: Text(
                            "${groupedItem.promoCode}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
          DataCell(TableContent(
              fontSize: fontSize,
              maxLines: 1,
              content: formatAmount(groupedItem.detail.sellPrice ?? '0'))),
          DataCell(TableContent(
              fontSize: fontSize,
              maxLines: 2,
              content: (groupedItem.detail.packtype == 'Pack' ||
                      groupedItem.isPack == true)
                  ? '${groupedItem.detail.packtype} \n(${groupedItem.detail.pieces} Pcs)'
                  : 'Pcs')),
          DataCell(
            TableContent(
                fontSize: fontSize,
                maxLines: 1,
                content: formatAmount(
                  (double.tryParse(groupedItem.detail.sellPrice?.toString() ??
                              '0') ??
                          0.0) *
                      ((groupedItem.detail.packtype == 'Pack' ||
                              groupedItem.isPack == true)
                          ? (groupedItem.detail.pieces ?? 1)
                          : 1),
                )),
          ),
          DataCell(
            TableContent(
              maxLines: 1,
              fontSize: fontSize,
              content: formatAmount(
                discountPrice,
              ),
            ),
          ),
          DataCell(
            TableContent(
                maxLines: 1,
                fontSize: fontSize,
                content: formatAmount(tax - taxDiscountAmount)),
          ),
          DataCell(
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: productQuantityManager(
                  groupedItem,
                  (groupedItem.detail.inclTax == 'incl_tax'
                      ? groupedItem.totalPrice.toString()
                      : (groupedItem.totalPrice + (groupedItem.detail.tax ?? 0))
                          .toString()),
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
                // child: CustomText(
                //   content: formatAmount(groupedItem.totalPrice),
                //   textAlign: TextAlign.right,
                //   fontSize: fontSize,
                //   maxLine: 1,
                // ),
                child: Builder(builder: (context) {
                  // Recalculate total price for promo items to ensure it's always up-to-date
                  double displayTotal = groupedItem.totalPrice;

                  if (groupedItem.isPromo ?? false) {
                    double effectiveSellingPrice =
                        double.tryParse(groupedItem.detail.sellPrice ?? '0') ??
                            0;
                    int pieces = groupedItem.detail.pieces?.toInt() ?? 1;
                    num count = groupedItem.detail.count;
                    num tax = groupedItem.detail.tax ?? 0;
                    double appliedDiscountPercentage =
                        groupedItem.detail.discount?.toDouble() ?? 0;

                    if (appliedDiscountPercentage > 0) {
                      effectiveSellingPrice -= (effectiveSellingPrice *
                          appliedDiscountPercentage /
                          100);
                      tax -= (tax * appliedDiscountPercentage / 100);
                    }

                    num totalCount =
                        groupedItem.isPack == true ? count * pieces : count;
                    double priceWithTax =
                        groupedItem.detail.inclTax == "incl_tax"
                            ? effectiveSellingPrice
                            : effectiveSellingPrice + tax;

                    displayTotal = priceWithTax * totalCount;
                  }

                  return CustomText(
                    content: formatAmount(displayTotal),
                    textAlign: TextAlign.right,
                    fontSize: fontSize,
                    maxLine: 1,
                  );
                }),
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

// ignore: must_be_immutable
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
