import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/model/staff_discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_details.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';



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
    final ProductsController productsController = Get.put(ProductsController());
    final String cid = productsController.selectedCustomerId.value;
    final double totalFlatDisc =
        productsController.flatDiscountByCustomer[cid] ?? 0.0;

    return groupedItems.map((groupedItem) {
      final taxDiscountAmount = ((groupedItem.detail.tax ?? 0.0) *
          ((groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
              ? (groupedItem.detail.pieces?.toDouble() ?? 1) *
                  groupedItem.detail.count.toDouble()
              : groupedItem.detail.count.toDouble()) *
          ((double.tryParse(groupedItem.detail.discount?.toString() ?? '0') ??
                  0.0) /
              100));

      final double sellingPrice =
          double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '0') ??
              0.0;

      final double quantity =
          (groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
              ? (groupedItem.detail.pieces?.toDouble() ?? 1.0) *
                  (groupedItem.detail.count.toDouble())
              : groupedItem.detail.count.toDouble();

      double sellPrice =
          double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '0') ??
              0.0;
      int qtyFactor =
          (groupedItem.detail.packtype == 'Pack' || groupedItem.isPack == true)
              ? (groupedItem.detail.pieces?.toInt() ?? 1)
              : 1;

      double baseSellAmount = sellPrice * qtyFactor;

      double productQuantity = groupedItem.detail.count.toDouble();

      double CustomerDiscount = (groupedItem.CustomerDiscount != null &&
              groupedItem.CustomerDiscount! > 0)
          ? groupedItem.CustomerDiscount!
          : 0.0;

      num tieredDiscount = (groupedItem.tieredDiscount != null &&
              groupedItem.tieredDiscount! > 0)
          ? groupedItem.tieredDiscount!
          : 0;
          print('toiered discount :$tieredDiscount');
      num flatDiscount = (groupedItem.flatDiscount != null &&
              groupedItem.flatDiscount! > 0)
          ? groupedItem.flatDiscount!
          : 0;
          print('flat discountser :$flatDiscount');
      double totalDiscountPercent = CustomerDiscount + tieredDiscount;
      double percentageDiscountAmount =
          (baseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);
    groupedItem.totalDiscountAmount = percentageDiscountAmount;
      double totalDiscountAmount = percentageDiscountAmount + flatDiscount;
      
  
      // groupedItem.totalDiscountAmount = totalDiscountAmount;

      double taxPercentage = (groupedItem.catTax ?? 0).toDouble();

      double priceAfterDiscount =
          (baseSellAmount * productQuantity) - totalDiscountAmount;

      double tax;
      if (groupedItem.taxAmount != null && groupedItem.taxAmount! > 0) {
        tax = groupedItem.taxAmount!;
      } else {
        tax = priceAfterDiscount * (taxPercentage / 100);
        groupedItem.taxAmount = tax;
      }

      double finalPrice;
      if (groupedItem.detail.inclTax == "incl_tax") {
        finalPrice = priceAfterDiscount;
      } else {
        finalPrice = priceAfterDiscount + tax;
      }
      groupedItem.finalPrice = finalPrice;

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
                                // Split by bullet points to ensure we capture all items
                                final itemBlocks = itemsSection.split('• ');
                                // Remove the first empty element if it exists
                                if (itemBlocks.isNotEmpty &&
                                    itemBlocks[0].trim().isEmpty) {
                                  itemBlocks.removeAt(0);
                                }

                                for (final block in itemBlocks) {
                                  if (block.trim().isEmpty) continue;

                                  final lines = block.split('\n');
                                  if (lines.length >= 3) {
                                    // Extract product name and variant
                                    String productName = '';
                                    String variantName = '';

                                    // First line now contains the product info without the bullet
                                    final fullProductText = lines[0].trim();

                                    // Check if the product name contains variant in parentheses
                                    final RegExp regExp =
                                        RegExp(r'(.*?)\s*\((.*?)\)');
                                    final match =
                                        regExp.firstMatch(fullProductText);

                                    if (match != null &&
                                        match.groupCount >= 2) {
                                      productName =
                                          match.group(1)?.trim() ?? '';
                                      variantName =
                                          match.group(2)?.trim() ?? '';
                                    } else if (fullProductText.contains(',')) {
                                      // Fallback to comma separation if no parentheses
                                      final parts = fullProductText.split(',');
                                      productName = parts[0].trim();
                                      variantName = parts.length > 1
                                          ? parts[1].trim()
                                          : '';
                                    } else {
                                      productName = fullProductText;
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
                              title: Text('Bundle Details: $bundleTitle'),
                              content: SizedBox(
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
                                      child: const Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
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
                                              padding: EdgeInsets.all(8.0),
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
                                              padding: EdgeInsets.all(8.0),
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
                                              padding: EdgeInsets.all(8.0),
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
                                      constraints: const BoxConstraints(
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
                                                            style:
                                                                const TextStyle(
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
                                                        style: const TextStyle(
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
                                                        style: const TextStyle(
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
                                                        style: const TextStyle(
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
                                          const Expanded(
                                            flex: 7,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
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
                    child: SizedBox(
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

          DataCell(
            InkWell(
              onTap: () {
                _showEditPriceDialog(
                  context,
                  groupedItem,
                );
              },
              child: Center(
                child: Text(
                  formatAmount(groupedItem.detail.sellPrice ?? '0'),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    decorationThickness: 1.2,
                    height: 1.4, // 👈 increases gap between text & underline
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          DataCell(
            TableContent(
              fontSize: fontSize,
              maxLines: 2,
              content: (groupedItem.detail.packtype == 'Pack' ||
                      groupedItem.isPack == true)
                  // If it is a pack, show Pack and Pcs.
                  // If packtype itself is null but isPack is true, it fallbacks to 'Bulk'
                  ? '${groupedItem.detail.packtype ?? 'Bulk'} \n(${groupedItem.detail.pieces ?? 0} Pcs)'
                  // If it's not a pack, check if packtype is null. If so, show 'Bulk', otherwise 'Pcs'
                  : (groupedItem.detail.packtype == null ? 'Bulk' : 'Pcs'),
            ),
          ),
          // DataCell(TableContent(
          //     fontSize: fontSize,
          //     maxLines: 2,
          //     content: (groupedItem.detail.packtype == 'Pack' ||
          //             groupedItem.isPack == true)
          //         ? '${groupedItem.detail.packtype} \n(${groupedItem.detail.pieces} Pcs)'
          //         : 'Pcs')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TableContent(
                    maxLines: 1,
                    fontSize: fontSize,
                    content: formatAmount(totalDiscountAmount),
                  ),
                ),
                if (totalDiscountAmount > 0)
                  InkWell(
                    child: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    onTap: () {
                      // Original selling price per unit
                      final double basePricePerUnit = double.tryParse(
                              groupedItem.detail.sellPrice?.toString() ??
                                  '0') ??
                          0.0;

                      // Price per sellable unit (pack = whole pack price, else per piece)
                      final double pricePerSellableUnit =
                          (groupedItem.isPack == true ||
                                  groupedItem.detail.packtype == 'Pack')
                              ? basePricePerUnit
                              : basePricePerUnit;

                      // Total original price before any discount
                      final double originalTotalPrice =
                          pricePerSellableUnit * quantity;

                      // Discounts
                      final double userFlatDiscountPerUnit =
                          CustomerDiscount; // flat amount per unit
                      final promoDiscountPercents = tieredDiscount;
                      final double promoDiscountAmountPerUnit =
                          (pricePerSellableUnit * tieredDiscount) / 100;

                      // Total discount per unit and overall
                      final double totalDiscountPerUnit =
                          userFlatDiscountPerUnit + promoDiscountAmountPerUnit;
                      final double totalDiscountApplied =
                          totalDiscountPercent; // already quantity × per unit discount

                      // Effective percentage calculations
                      final double userDiscountPercent = pricePerSellableUnit >
                              0
                          ? (userFlatDiscountPerUnit / pricePerSellableUnit) *
                              100
                          : 0.0;

                      final double totalEffectiveDiscountPercent =
                          originalTotalPrice > 0
                              ? (totalDiscountApplied / originalTotalPrice) *
                                  100
                              : 0.0;

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 12,
                          title: const Row(
                            children: [
                              Icon(Icons.discount_outlined,
                                  color: Colors.deepPurple, size: 28),
                              SizedBox(width: 12),
                              Text(
                                "Discount Details",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          content: Container(
                            width: 340,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF3E8FF), Color(0xFFE0E7FF)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Item name and quantity
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        groupedItem.detail.productName ??
                                            "Item",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${quantity.toInt()} × ${groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack' ? 'Pack' : 'Piece'}",
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Original Price
                                // _buildPriceRow(
                                //   label: "Original Price",
                                //   amount: originalTotalPrice,
                                //   isTotal: true,
                                // ),
                                const SizedBox(height: 16),

                                // User Discount (as %)
                                if (CustomerDiscount > 0) ...[
                                  _buildDiscountRow(
                                    icon: Icons.card_giftcard_rounded,
                                    label: "Customer Discount",
                                    percent: CustomerDiscount,
                                    amount: CustomerDiscount * quantity,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Promo Discount
                                if (tieredDiscount > 0) ...[
                                  _buildDiscountRow(
                                    icon: Icons.local_offer_outlined,
                                    label: "Promo Offer",
                                    percent: tieredDiscount,
                                    amount:
                                        promoDiscountAmountPerUnit * quantity,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                if (CustomerDiscount == 0 &&
                                    tieredDiscount == 0)
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      "No discount applied",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16),
                                    ),
                                  ),

                                const Divider(thickness: 1.5, height: 32),

                                // Total Savings Highlight
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade600,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "You Saved",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${totalDiscountPercent.toStringAsFixed(1)}%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),
                                // Center(
                                //   child: Text(
                                //     "₹${formatAmount(totalDiscountApplied)} off",
                                //     style: TextStyle(
                                //       fontSize: 17,
                                //       fontWeight: FontWeight.w700,
                                //       color: Colors.deepPurple.shade700,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.check, size: 20),
                                label: const Text("Got it",
                                    style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                            ),
                          ],
                          actionsPadding: const EdgeInsets.only(bottom: 16),
                        ),
                      );
                    },
//
                  ),
              ],
            ),
          ),
          DataCell(
            TableContent(
                maxLines: 1, fontSize: fontSize, content: formatAmount(tax)),
          ),

          //  DataCell(
          //   Center(
          //     child: ConstrainedBox(
          //       constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
          //       child: productQuantityManager(
          //         groupedItem,
          //         (groupedItem.detail.inclTax == 'incl_tax'
          //             ? groupedItem.totalPrice.toString()
          //             : (groupedItem.totalPrice + (groupedItem.detail.tax ?? 0))
          //                 .toString()),
          //         fontSize,
          //         availableWidth,
          //       ),
          //     ),
          //   ),
          // ),

          DataCell(
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: Builder(builder: (context) {
                  // Recalculate total price for promo items to ensure it's always up-to-date
                  double displayTotal = groupedItem.totalPrice;

                  if (groupedItem.isPromo ?? false) {
                    double basePrice =
                        double.tryParse(groupedItem.detail.sellPrice ?? '0') ??
                            0;
                    int pieces = groupedItem.detail.pieces?.toInt() ?? 1;
                    num count = groupedItem.detail.count;
                    num tax = groupedItem.detail.tax ?? 0;
                    double discountPercentage =
                        groupedItem.detail.discount?.toDouble() ?? 0;
                    double? maxDiscount =
                        groupedItem.detail.maxDiscount?.toDouble();

                    // Calculate total quantity and base price
                    num totalCount =
                        groupedItem.isPack == true ? count * pieces : count;
                    double totalBasePrice = basePrice * totalCount;

                    // Calculate discount with max discount cap
                    double uncappedDiscountAmount =
                        totalBasePrice * (discountPercentage / 100);
                    double actualDiscountAmount = uncappedDiscountAmount;

                    if (maxDiscount != null &&
                        maxDiscount > 0 &&
                        uncappedDiscountAmount > maxDiscount) {
                      actualDiscountAmount = maxDiscount;
                    }

                    // Calculate effective discount percentage and apply to price and tax
                    double effectiveDiscountPercentage = totalBasePrice > 0
                        ? (actualDiscountAmount / totalBasePrice) * 100
                        : 0;
                    double effectiveSellingPrice =
                        basePrice * (1 - effectiveDiscountPercentage / 100);
                    tax = tax * (1 - effectiveDiscountPercentage / 100);

                    double priceWithTax =
                        groupedItem.detail.inclTax == "incl_tax"
                            ? effectiveSellingPrice
                            : effectiveSellingPrice + tax;

                    displayTotal = priceWithTax * totalCount;
                  }

                  return CustomText(
                    content: formatAmount(finalPrice),
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
                    print('delete on tapped');
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

void _showEditPriceDialog(BuildContext context, CartItem groupedItem) {
  final TextEditingController priceController = TextEditingController(
    text: (double.tryParse(groupedItem.detail.sellPrice ?? '0')
            ?.toStringAsFixed(0)) ??
        '',
  );

  double? allowedDiscount;
  double? minAllowedPrice;
  bool isLoading = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // 🔹 Fetch discount only once
          if (isLoading) {
            isLoading = false;
            Future.microtask(() async {
              final staffDiscount = await ApiWorker().getStaffDiscount();

              final String? categoryId =
                  getCategoryIdFromProductId(groupedItem.detail.productId);

              if (categoryId == null || staffDiscount == null) return;

              final double originalPrice =
                  double.tryParse(groupedItem.detail.sellPrice ?? '0') ?? 0;

              final discount = getAllowedDiscountPercent(
                staffDiscount: staffDiscount,
                productId: groupedItem.detail.productId!,
                categoryId: categoryId,
              );

              if (discount != null) {
                setState(() {
                  allowedDiscount = discount;
                  minAllowedPrice =
                      originalPrice - (originalPrice * discount / 100);
                });
              }
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                CustomText(content: 'Enter Price'),
                SizedBox(
                  width: 10,
                ),
                if (allowedDiscount != null)
                  Text(
                    'Max allowed discount: ${allowedDiscount!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            content: TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                child: const Text('Ok'),
                onPressed: () async {
                  final GlobalKey<CartDialogueState> cartDialogKey =
                      GlobalKey<CartDialogueState>();

                  final double? newPrice =
                      double.tryParse(priceController.text);
                  if (newPrice == null || newPrice <= 0) return;

                  if (allowedDiscount == null) {
                    Get.snackbar(
                      'Not Allowed',
                      'No discount configured for this product',
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  final double originalPrice =
                      double.tryParse(groupedItem.detail.sellPrice ?? '0') ?? 0;

                  final bool isAllowed = isPriceWithinDiscount(
                    originalPrice: originalPrice,
                    enteredPrice: newPrice,
                    allowedDiscountPercent: allowedDiscount!,
                  );

                  if (!isAllowed) {
                    Get.snackbar(
                      'Discount Limit Exceeded',
                      'Maximum allowed discount is $allowedDiscount%',
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  groupedItem.detail.sellPrice = newPrice.toString();

                  Get.back(closeOverlays: true);
                  Get.back(closeOverlays: true);
                  _showCartDialog(
                      context, cartDialogKey, groupedItem.customerId!);
                },
              ),
            ],
          );
        },
      );
    },
  );
}

bool isPriceWithinDiscount({
  required double originalPrice,
  required double enteredPrice,
  required double allowedDiscountPercent,
}) {
  final minAllowedPrice =
      originalPrice - (originalPrice * allowedDiscountPercent / 100);

  return enteredPrice >= minAllowedPrice;
}

String? getCategoryIdFromProductId(String? productId) {
  if (productId == null || productId.isEmpty) return null;

  try {
    return extractCategoryId(productId).toString();
  } catch (e) {
    debugPrint('Category ID extraction failed: $e');
    return null;
  }
}

double? getAllowedDiscountPercent({
  required StaffDiscount staffDiscount,
  required String productId,
  required String categoryId,
}) {
  final categories = staffDiscount.data?.categories ?? [];

  for (final category in categories) {
    for (final product in category.products ?? []) {
      if (product.id == productId) {
        return product.discount?.toDouble();
      }
    }

    if (category.categoryId == categoryId) {
      return category.categoryDiscount?.toDouble();
    }
  }

  return null;
}

void _showCartDialog(BuildContext context,
    GlobalKey<CartDialogueState> dialogKey, String customerid) {
  final productsController = Get.find<ProductsController>();
  CustomerAndOrderController customerAndOrderController =
      Get.find<CustomerAndOrderController>();
  final customerId = customerid;
  final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CartDialogue(
        key: dialogKey,
        active: customerAndOrderController.isActive.value,
        cartItemCount: cartProvider.cartItemCount,
        productsController: productsController,
        customerOrderController: customerAndOrderController,
        isDashboard: false,
        customerId: customerId,
      );
    },
  );
}

Widget _buildPriceRow({
  required String label,
  required double amount,
  bool isTotal = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isTotal ? 17 : 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
      Text(
        "₹${formatAmount(amount)}",
        style: TextStyle(
          fontSize: isTotal ? 19 : 17,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          color: isTotal ? Colors.deepPurple.shade700 : Colors.black87,
        ),
      ),
    ],
  );
}

Widget _buildDiscountRow({
  required IconData icon,
  required String label,
  required percent,
  required double amount,
  required Color color,
}) {
  return Row(
    children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "-${percent.toStringAsFixed(1)}%",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    ],
  );
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


