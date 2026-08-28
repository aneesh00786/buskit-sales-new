import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/model/staff_discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_details.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_heading.dart';
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
      // final taxDiscountAmount = ((groupedItem.detail.tax ?? 0.0) *
      //     ((groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
      //         ? (groupedItem.detail.pieces?.toDouble() ?? 1) *
      //             groupedItem.detail.count.toDouble()
      //         : groupedItem.detail.count.toDouble()) *
      //     ((double.tryParse(groupedItem.detail.discount?.toString() ?? '0') ??
      //             0.0) /
      //         100));

      final double sellingPrice =
          double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '0') ??
              0.0;

      double originalUnitPrice =
          double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '') ?? 0.0;
      if (originalUnitPrice <= 0.0) {
        originalUnitPrice =
            double.tryParse(groupedItem.detail.price?.toString() ?? '') ?? 0.0;
      }

      int qtyFactor =
          (groupedItem.detail.packtype == 'Pack' || groupedItem.isPack == true)
              ? (groupedItem.detail.pieces?.toInt() ?? 1)
              : 1;

      final double? apiSellingPackPrice = (groupedItem.isPack == true ||
              groupedItem.detail.packtype == 'Pack')
          ? (double.tryParse(
              groupedItem.detail.sellingPackPrice?.toString() ?? ''))
          : null;

      // 1. Original Base Sell Amount (Pre-Discount & Pre-Edit)
      final double originalBaseSellAmount = (apiSellingPackPrice != null && apiSellingPackPrice > 0)
          ? apiSellingPackPrice
          : originalUnitPrice * qtyFactor;

      // 2. Current Base Sell Amount (reflects salesman price override if edited)
      double currentBaseSellAmount = originalBaseSellAmount;
      if (groupedItem.detail.displayPrice != null) {
        final double editedUnitPrice =
            double.tryParse(groupedItem.detail.displayPrice!) ?? originalUnitPrice;
        currentBaseSellAmount = (apiSellingPackPrice != null && apiSellingPackPrice > 0)
            ? (double.tryParse(groupedItem.detail.displayPrice!) ?? originalBaseSellAmount)
            : editedUnitPrice * qtyFactor;
      }

      double productQuantity = groupedItem.detail.count.toDouble();

      // 3. Edit-price discount (difference between original price and edited price)
      double editPriceDiscountAmount = 0.0;
      if (groupedItem.detail.displayPrice != null) {
        final double priceDiff = originalBaseSellAmount - currentBaseSellAmount;
        if (priceDiff > 0) {
          editPriceDiscountAmount = priceDiff * productQuantity;
        }
      }

      final bool isBulk = (groupedItem.detail.bulkId != null &&
              groupedItem.detail.bulkId!.isNotEmpty) ||
          (groupedItem.detail.packtype == 'Bulk') ||
          (groupedItem.isPack == true &&
              groupedItem.detail.bulkDiscount != null &&
              groupedItem.detail.bulkDiscount! > 0) ||
          (groupedItem.detail.bulkDiscountAmount != null &&
              groupedItem.detail.bulkDiscountAmount! > 0);

      final bool isPromoItem = (groupedItem.isPromo == true) && !isBulk;

      double CustomerDiscount = (!isBulk &&
              groupedItem.CustomerDiscount != null &&
              groupedItem.CustomerDiscount! > 0)
          ? groupedItem.CustomerDiscount!
          : 0.0;

      num tieredDiscount = (isPromoItem &&
              groupedItem.tieredDiscount != null &&
              groupedItem.tieredDiscount! > 0)
          ? groupedItem.tieredDiscount!
          : 0;

      num flatDiscount = (isPromoItem &&
              groupedItem.flatDiscount != null &&
              groupedItem.flatDiscount! > 0)
          ? groupedItem.flatDiscount!
          : 0;

      num bulkDiscountAmount = (groupedItem.detail.bulkDiscountAmount != null &&
              groupedItem.detail.bulkDiscountAmount! > 0)
          ? groupedItem.detail.bulkDiscountAmount!
          : 0;

      num? bulkDiscount = (groupedItem.detail.bulkDiscount != null && groupedItem.detail.bulkDiscount! > 0)
          ? groupedItem.detail.bulkDiscount
          : 0;

      num bogoDiscount = (isPromoItem &&
              groupedItem.bogoDiscount != null &&
              groupedItem.bogoDiscount! > 0)
          ? groupedItem.bogoDiscount!
          : 0;

      double totalDiscountPercent = CustomerDiscount + tieredDiscount + bogoDiscount + (bulkDiscount ?? 0);

      // 4. Percentage discount calculated on original base amount
      double percentageDiscountAmount =
          (originalBaseSellAmount * productQuantity) * (totalDiscountPercent / 100.0);

      // Only add flat bulkDiscountAmount if bulk percentage discount is NOT already applied
      num effectiveBulkDiscountAmount = ((bulkDiscount ?? 0) > 0)
          ? 0
          : bulkDiscountAmount;

      // 5. Total discount amount includes percentage, flat, bulk, and price edit difference
      double totalDiscountAmount = percentageDiscountAmount + flatDiscount + effectiveBulkDiscountAmount + editPriceDiscountAmount;

      groupedItem.totalDiscountAmount = totalDiscountAmount;

      // 6. Price After Discount
      double priceAfterDiscount =
          (originalBaseSellAmount * productQuantity) - totalDiscountAmount;
      if (priceAfterDiscount < 0) priceAfterDiscount = 0.0;

      double bulkTaxPercentage = (groupedItem.detail.bulkTax ?? 0).toDouble();
      double taxPercentage = bulkTaxPercentage > 0 
          ? bulkTaxPercentage 
          : (groupedItem.catTax ?? 0).toDouble();

      // 7. Tax calculated strictly from priceAfterDiscount
      double tax;
      if (groupedItem.detail.inclTax == "N.A") {
        tax = 0.0;
        groupedItem.taxAmount = 0.0;
      } else {
        tax = priceAfterDiscount * (taxPercentage / 100);
        groupedItem.taxAmount = tax;
      }

      double finalPrice;
      if (groupedItem.detail.inclTax == "incl_tax" || groupedItem.detail.inclTax == "N.A") {
        finalPrice = priceAfterDiscount;
      } else {
        finalPrice = priceAfterDiscount + tax;
      }
      groupedItem.finalPrice = finalPrice;
      groupedItem.totalPrice = (originalBaseSellAmount * productQuantity);
      try {
        groupedItem.save();
      } catch (_) {}

      // double finalPrice;
      // if (groupedItem.detail.inclTax == "incl_tax") {
      //   print('its inclusive tax');
      //   finalPrice = priceAfterDiscount;
      // } else {
      //   print('its not inclusive tax');
      //   finalPrice = priceAfterDiscount + tax;
      // }
      // groupedItem.finalPrice = finalPrice;

      return DataRow(
        cells: [
          DataCell(
            SizedBox(width: CartColumnWidths.checkbox, child: SizedBox(
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
            ),),
          ),

          DataCell(
            SizedBox(width: CartColumnWidths.variant, child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product / Variant Image Thumbnail
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (groupedItem.detail.imageUrl != null &&
                          groupedItem.detail.imageUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: (groupedItem.detail.imageUrl!.startsWith('http://') ||
                                  groupedItem.detail.imageUrl!.startsWith('https://'))
                              ? groupedItem.detail.imageUrl!
                              : '${ApiConstants.imageBaseUrl}/${groupedItem.detail.imageUrl}',
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/Image-not-found.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          'assets/images/Image-not-found.png',
                          fit: BoxFit.contain,
                        ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${groupedItem.detail.variationName} ${groupedItem.detail.unitType}',
                        style: TextStyle(
                          fontSize: fontSize >= 13.0 ? fontSize : 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.start,
                        maxLines: groupedItem.promoCode == null ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
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
                  ),
                ],
              ],
            ),
          ),
        ],
      ),),
    ),

          // Cell 3: Unit Price
          DataCell(
            SizedBox(width: CartColumnWidths.unitPrice, child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: (groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
                  ? Text(
                      formatAmount(groupedItem.detail.displayPrice ?? groupedItem.detail.sellPrice ?? '0'),
                      style: TextStyle(
                        fontFamily: fontFamilyName,
                        fontSize: fontSize >= 13.0 ? fontSize : 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : InkWell(
                      onTap: () {
                        _showEditPriceDialog(
                          context,
                          groupedItem,
                        );
                      },
                      child: () {
                        double originalPrice = double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '') ?? 0.0;
                        if (originalPrice <= 0.0) {
                          originalPrice = double.tryParse(groupedItem.detail.price?.toString() ?? '') ?? 0.0;
                        }
                        final double currentPrice = double.tryParse(groupedItem.detail.displayPrice ?? groupedItem.detail.sellPrice ?? '0') ?? 0.0;
                        final bool isPriceEdited = groupedItem.detail.displayPrice != null;
                        final double cellFontSize = fontSize >= 13.0 ? fontSize : 13.5;

                        if (isPriceEdited) {
                          return RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                // Old price — struck-through in grey
                                TextSpan(
                                  text: formatAmount(originalPrice.toString()),
                                  style: TextStyle(
                                    fontFamily: fontFamilyName,
                                    fontSize: cellFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                // Separator
                                TextSpan(
                                  text: ' / ',
                                  style: TextStyle(
                                    fontFamily: fontFamilyName,
                                    fontSize: cellFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                    height: 1.4,
                                  ),
                                ),
                                // New price — blue & underlined
                                TextSpan(
                                  text: formatAmount(currentPrice.toString()),
                                  style: TextStyle(
                                    fontFamily: fontFamilyName,
                                    fontSize: cellFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2563EB),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFF2563EB),
                                    decorationThickness: 1.2,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text(
                            formatAmount(groupedItem.detail.sellPrice ?? '0'),
                            style: TextStyle(
                              fontFamily: fontFamilyName,
                              fontSize: cellFontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2563EB),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF2563EB),
                              decorationThickness: 1.2,
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                      }(),
                    ),
              ),
            ),),
          ),

          // Cell 4: Pack Price
          DataCell(
            SizedBox(width: CartColumnWidths.packPrice, child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: (groupedItem.detail.packtype == 'Pack' || groupedItem.isPack == true)
                  ? InkWell(
                      onTap: () {
                        _showEditPackPriceDialog(
                          context,
                          groupedItem,
                        );
                      },
                      child: () {
                        final int pieces = groupedItem.detail.pieces?.toInt() ?? 1;
                        double originalPrice = double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '') ?? 0.0;
                        if (originalPrice <= 0.0) {
                          originalPrice = double.tryParse(groupedItem.detail.price?.toString() ?? '') ?? 0.0;
                        }
                        // Use API selling_pack_price if available, else calculate
                        final double? apiPackPrice = double.tryParse(
                            groupedItem.detail.sellingPackPrice?.toString() ?? '');
                        final double originalPackPrice = (apiPackPrice != null && apiPackPrice > 0)
                            ? apiPackPrice
                            : originalPrice * pieces;

                        final double currentUnitPrice = double.tryParse(groupedItem.detail.displayPrice ?? groupedItem.detail.sellPrice ?? '0') ?? 0.0;
                        final double currentPackPrice = (groupedItem.detail.displayPrice != null)
                            ? (apiPackPrice != null && apiPackPrice > 0
                                ? (double.tryParse(groupedItem.detail.displayPrice!) ?? originalPackPrice)
                                : currentUnitPrice * pieces)
                            : originalPackPrice;     // unedited: use calculated/API pack price
                        final bool isPriceEdited = groupedItem.detail.displayPrice != null;
                        final double cellFontSize = fontSize >= 13.0 ? fontSize : 13.5;

                        if (isPriceEdited) {
                          return RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                // Old pack price — struck-through in grey
                                TextSpan(
                                  text: formatAmount(originalPackPrice.toString()),
                                  style: TextStyle(
                                    fontFamily: fontFamilyName,
                                    fontSize: cellFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                // Separator
                                TextSpan(
                                  text: ' / ',
                                  style: TextStyle(
                                    fontFamily: fontFamilyName,
                                    fontSize: cellFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                    height: 1.4,
                                  ),
                                ),
                                // New pack price — blue & underlined
                                TextSpan(
                                  text: formatAmount(currentPackPrice.toString()),
                                  style: TextStyle(
                                    fontFamily: fontFamilyName,
                                    fontSize: cellFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2563EB),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFF2563EB),
                                    decorationThickness: 1.2,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text(
                            formatAmount(currentPackPrice.toString()),
                            style: TextStyle(
                              fontFamily: fontFamilyName,
                              fontSize: cellFontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2563EB),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF2563EB),
                              decorationThickness: 1.2,
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                      }(),
                    )
                  : Text(
                      '-',
                      style: TextStyle(
                        fontFamily: fontFamilyName,
                        fontSize: fontSize >= 13.0 ? fontSize : 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),),
          ),

          // Cell 5: Pack
          DataCell(
            SizedBox(width: CartColumnWidths.pack, child: TableContent(
              fontSize: fontSize,
              maxLines: 2,
              content: (groupedItem.detail.packtype == 'Pack' ||
                      groupedItem.isPack == true)
                  // If it is a pack, show Pack and Pcs.
                  // If packtype itself is null but isPack is true, it fallbacks to 'Bulk'
                  ? '${groupedItem.detail.packtype ?? 'Bulk'} \n(${groupedItem.detail.pieces ?? 0} Pcs)'
                  // If it's not a pack, check if packtype is null. If so, show 'Bulk', otherwise 'Pcs'
                  : (groupedItem.detail.packtype == null ? 'Bulk' : 'Pcs'),
            ),),
          ),

          // Cell 6: Quantity manager
          DataCell(
            SizedBox(width: CartColumnWidths.quantity, child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: productQuantityManager(
                  groupedItem,
                  ((groupedItem.detail.inclTax == 'incl_tax' || groupedItem.detail.inclTax == 'N.A')
                      ? groupedItem.totalPrice.toString()
                      : (groupedItem.totalPrice + (groupedItem.detail.tax ?? 0))
                          .toString()),
                  fontSize,
                  availableWidth,
                ),
              ),
            ),),
          ),

          // Cell 7: Price (original pre-discount total)
          DataCell(
            SizedBox(width: CartColumnWidths.price, child: TableContent(
              fontSize: fontSize,
              maxLines: 1,
              content: formatAmount(
                  (originalBaseSellAmount * productQuantity).toString()),
            ),),
          ),

          DataCell(
            SizedBox(
              width: CartColumnWidths.disc,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TableContent(
                      maxLines: 1,
                      fontSize: fontSize,
                      content: formatAmount(totalDiscountAmount),
                    ),
                  ),
                  if (totalDiscountAmount > 0) ...[
                    const SizedBox(width: 3),
                    InkWell(
                      child: const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Colors.blueGrey,
                      ),
                    onTap: () {
                      final double quantity = productQuantity;
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

                      final bool isBulkItem = (groupedItem.detail.bulkId != null &&
                              groupedItem.detail.bulkId!.isNotEmpty) ||
                          (groupedItem.detail.packtype == 'Bulk') ||
                          (groupedItem.isPack == true &&
                              groupedItem.detail.bulkDiscount != null &&
                              groupedItem.detail.bulkDiscount! > 0) ||
                          (groupedItem.detail.bulkDiscountAmount != null &&
                              groupedItem.detail.bulkDiscountAmount! > 0);

                      final double effectiveBulkDiscountPercent =
                          (groupedItem.detail.bulkDiscount != null &&
                                  groupedItem.detail.bulkDiscount! > 0)
                              ? groupedItem.detail.bulkDiscount!.toDouble()
                              : ((bulkDiscount != null && bulkDiscount > 0)
                                  ? bulkDiscount.toDouble()
                                  : 0.0);

                      final double effectiveCustomerDiscountPercent =
                          isBulkItem ? 0.0 : CustomerDiscount;

                      final double calculatedBulkDiscountAmount =
                          (effectiveBulkDiscountPercent > 0)
                              ? ((originalBaseSellAmount * quantity) *
                                  (effectiveBulkDiscountPercent / 100.0))
                              : (bulkDiscountAmount * quantity).toDouble();

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 12,
                          title: Row(
                            children: [
                              const Icon(Icons.discount_outlined,
                                  color: Colors.deepPurple, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "Discount Details".tr,
                                style: const TextStyle(
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
                                            color: const Color(0xFF0F172A),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Bulk Discount
                                if (isBulkItem &&
                                    (effectiveBulkDiscountPercent > 0 ||
                                        bulkDiscountAmount > 0)) ...[
                                  _buildDiscountRow(
                                    icon: Icons.inventory_2_outlined,
                                    label: "Bulk Discount".tr,
                                    percent: effectiveBulkDiscountPercent,
                                    amount: calculatedBulkDiscountAmount,
                                    color: Colors.indigo.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Customer Discount (as %)
                                if (!isBulkItem &&
                                    effectiveCustomerDiscountPercent > 0) ...[
                                  _buildDiscountRow(
                                    icon: Icons.card_giftcard_rounded,
                                    label: "Customer Discount".tr,
                                    percent: effectiveCustomerDiscountPercent,
                                    amount: (originalBaseSellAmount * quantity) *
                                        (effectiveCustomerDiscountPercent /
                                            100.0),
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Promo Discount
                                if (tieredDiscount > 0) ...[
                                  _buildDiscountRow(
                                    icon: Icons.local_offer_outlined,
                                    label: "Promo Offer".tr,
                                    percent: tieredDiscount,
                                    amount: (originalBaseSellAmount * quantity) *
                                        (tieredDiscount / 100.0),
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Flat Discount
                                if (flatDiscount > 0) ...[
                                  _buildDiscountRow(
                                    icon: Icons.money_off_rounded,
                                    label: "Flat Discount".tr,
                                    percent: 0,
                                    amount: flatDiscount.toDouble() * quantity,
                                    color: Colors.purple.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // BOGO Discount
                                if (bogoDiscount > 0) ...[
                                  _buildDiscountRow(
                                    icon: Icons.redeem_rounded,
                                    label: "BOGO Offer".tr,
                                    percent: bogoDiscount,
                                    amount: (originalBaseSellAmount * quantity) *
                                        (bogoDiscount / 100.0),
                                    color: Colors.teal.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Edit-price discount (salesman price override)
                                if (editPriceDiscountAmount > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.teal.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            color: Colors.teal.shade700,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Price Edit Discount'.tr,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.teal.shade700,
                                                    fontSize: 13),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Original: ${formatAmount(originalBaseSellAmount.toString())}',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 12,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '→ ${formatAmount(currentBaseSellAmount.toString())}',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .teal.shade700,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '-${formatAmount(editPriceDiscountAmount.toString())}',
                                          style: TextStyle(
                                              color: Colors.teal.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                if (effectiveCustomerDiscountPercent == 0 &&
                                    effectiveBulkDiscountPercent == 0 &&
                                    bulkDiscountAmount == 0 &&
                                    tieredDiscount == 0 &&
                                    flatDiscount == 0 &&
                                    bogoDiscount == 0 &&
                                    editPriceDiscountAmount == 0)
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      "No discount applied".tr,
                                      style: const TextStyle(
                                          color: const Color(0xFF0F172A),
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
                                       Text(
                                        "You Saved".tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                         () {
                                           final double originalBaseAmount =
                                               originalBaseSellAmount *
                                                   productQuantity;
                                           final double editPricePercent =
                                               originalBaseAmount > 0
                                                   ? (editPriceDiscountAmount /
                                                           originalBaseAmount) *
                                                       100
                                                   : 0.0;
                                           final double totalSavedPercent =
                                               totalDiscountPercent +
                                                   editPricePercent;
                                           return '${totalSavedPercent.toStringAsFixed(1)}%';
                                         }(),
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
                                label:  Text("Got it".tr,
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
                  ),
                ],
              ],
            ),),
          ),
          DataCell(
            SizedBox(
              width: CartColumnWidths.tax,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TableContent(
                        maxLines: 1,
                        fontSize: fontSize,
                        content: groupedItem.detail.inclTax == "N.A"
                            ? formatAmount(0)
                            : formatAmount(tax),
                      ),
                    ),
                    if (groupedItem.detail.inclTax == 'incl_tax') ...[
                      const SizedBox(width: 3),
                      Text(
                        'Incl.Tax'.tr,
                        style: TextStyle(
                          fontSize: fontSize > 3 ? fontSize - 3 : 9.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                          fontFamily: fontFamilyName,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          DataCell(
            SizedBox(width: CartColumnWidths.total, child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
                child: TableContent(
                  content: formatAmount(finalPrice),
                  fontSize: fontSize,
                  maxLines: 1,
                ),
              ),
            ),),
          ),
          DataCell(
            SizedBox(width: CartColumnWidths.delete, child: Center(
              child: SizedBox(
                width: 30,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                  onPressed: () {
                    deleteConfirmationDialogue(
                        context, groupedItem, groupedItems);
                  },
                ),
              ),
            ),),
          ),
        ],
      );
    }).toList();
  }
}

void _showEditPriceDialog(BuildContext context, CartItem groupedItem) {
  double originalPrice =
      double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '') ?? 0.0;
  if (originalPrice <= 0.0) {
    originalPrice =
        double.tryParse(groupedItem.detail.price?.toString() ?? '') ?? 0.0;
  }

  final TextEditingController priceController = TextEditingController(
    text: double.tryParse(groupedItem.detail.displayPrice ?? groupedItem.detail.sellPrice ?? '0')?.toStringAsFixed(2) ?? '',
  );

  double? allowedDiscount;
  bool isLoading = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (isLoading) {
            isLoading = false;
            Future.microtask(() async {
              final staffDiscount = await ApiWorker().getStaffDiscount();
              final String? categoryId =
                  getCategoryIdFromProductId(groupedItem.detail.productId);
              if (categoryId == null || staffDiscount == null) return;
              final discount = getAllowedDiscountPercent(
                staffDiscount: staffDiscount,
                productId: groupedItem.detail.productId!,
                categoryId: categoryId,
              );
              if (discount != null) {
                setState(() {
                  allowedDiscount = discount;
                });
              }
            });
          }

          final String currencySymbol = (SessionHelper.settingsData
                      ?.firstWhere(
                        (setting) => setting.key == 'currency_symbol',
                        orElse: () => AllCompanySettingsData(
                          key: 'currency_symbol',
                          value: '₹',
                        ),
                      )
                      .value ??
                  '₹')
              .trim();

          final double? enteredPrice =
              double.tryParse(priceController.text);
          final double discountPct = (enteredPrice != null &&
                  originalPrice > 0 &&
                  enteredPrice < originalPrice)
              ? ((originalPrice - enteredPrice) / originalPrice) * 100
              : 0.0;
          final bool isPriceEdited =
              enteredPrice != null && enteredPrice != originalPrice;

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            content: Container(
              width: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade700,
                          Colors.deepPurple.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Unit Price'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Original: ',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13),
                              ),
                              Text(
                                formatAmount(originalPrice.toString()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (allowedDiscount != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Max discount: ${allowedDiscount!.toStringAsFixed(0)}%  '
                              '(Min price: ${formatAmount((originalPrice - originalPrice * allowedDiscount! / 100).toString())})',
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Body ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Price'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: priceController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: Center(
                              widthFactor: 1,
                              child: Text(
                                currencySymbol,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade400,
                                ),
                              ),
                            ),
                            hintText: '0.00',
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.deepPurple.shade200, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.deepPurple.shade600, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isPriceEdited)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: discountPct > 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: discountPct > 0
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  discountPct > 0
                                      ? Icons.trending_down
                                      : Icons.trending_up,
                                  color: discountPct > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    discountPct > 0
                                        ? 'Discount: ${discountPct.toStringAsFixed(1)}%  '
                                            '(Saving: ${formatAmount((originalPrice - (enteredPrice ?? 0)).toString())} per unit)'
                                        : 'Price is not less than original',
                                    style: TextStyle(
                                      color: discountPct > 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                child: Text('Cancel'.tr,
                                    style: TextStyle(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurple.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                onPressed: () async {
                                  final GlobalKey<CartDialogueState>
                                      cartDialogKey =
                                      GlobalKey<CartDialogueState>();

                                  final double? newPrice =
                                      double.tryParse(priceController.text);
                                  if (newPrice == null || newPrice <= 0)
                                    return;

                                  if (newPrice > originalPrice) {
                                    Get.snackbar(
                                      'Invalid Price'.tr,
                                      'New unit price must be less than or equal to the original price.'
                                          .tr,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                    );
                                    return;
                                  }

                                  if (newPrice < originalPrice && allowedDiscount == null) {
                                    Get.snackbar(
                                      'Not Allowed',
                                      'No discount configured for this product',
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                    );
                                    return;
                                  }

                                  if (allowedDiscount != null) {
                                    final bool isAllowed =
                                        isPriceWithinDiscount(
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
                                  }

                                  groupedItem.detail.displayPrice =
                                      newPrice.toString();
                                  groupedItem.totalPrice =
                                      Utils().calculateTotalPrice(groupedItem,
                                          groupedItem.detail.count.toInt());
                                  try {
                                    groupedItem.save();
                                  } catch (_) {}

                                  final cartState =
                                      context.findAncestorStateOfType<CartDialogueState>();
                                  if (cartState != null) {
                                    cartState.refreshCart();
                                  }
                                  Get.back();
                                },
                                child: Text('Apply'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showEditPackPriceDialog(BuildContext context, CartItem groupedItem) {
  final int pieces = groupedItem.detail.pieces?.toInt() ?? 1;
  double originalUnitPrice =
      double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '') ?? 0.0;
  if (originalUnitPrice <= 0.0) {
    originalUnitPrice =
        double.tryParse(groupedItem.detail.price?.toString() ?? '') ?? 0.0;
  }
  // Use API selling_pack_price if available, else fallback to unitPrice * pieces
  final double? apiPackPrice = double.tryParse(
      groupedItem.detail.sellingPackPrice?.toString() ?? '');
  final double originalPackPrice = (apiPackPrice != null && apiPackPrice > 0)
      ? apiPackPrice
      : originalUnitPrice * pieces;

  // Current pack price: if user already edited, use displayPrice;
  // otherwise use the calculated/API pack price.
  final double currentPackPrice = (groupedItem.detail.displayPrice != null)
      ? (apiPackPrice != null && apiPackPrice > 0
          ? (double.tryParse(groupedItem.detail.displayPrice!) ?? originalPackPrice)
          : (double.tryParse(groupedItem.detail.displayPrice!) ?? originalUnitPrice) * pieces)
      : originalPackPrice;

  final TextEditingController priceController = TextEditingController(
    text: currentPackPrice.toStringAsFixed(2),
  );

  double? allowedDiscount;
  bool isLoading = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (isLoading) {
            isLoading = false;
            Future.microtask(() async {
              final staffDiscount = await ApiWorker().getStaffDiscount();
              final String? categoryId =
                  getCategoryIdFromProductId(groupedItem.detail.productId);
              if (categoryId == null || staffDiscount == null) return;
              final discount = getAllowedDiscountPercent(
                staffDiscount: staffDiscount,
                productId: groupedItem.detail.productId!,
                categoryId: categoryId,
              );
              if (discount != null) {
                setState(() {
                  allowedDiscount = discount;
                });
              }
            });
          }

          final String currencySymbol = (SessionHelper.settingsData
                      ?.firstWhere(
                        (setting) => setting.key == 'currency_symbol',
                        orElse: () => AllCompanySettingsData(
                          key: 'currency_symbol',
                          value: '₹',
                        ),
                      )
                      .value ??
                  '₹')
              .trim();

          final double? enteredPackPrice =
              double.tryParse(priceController.text);
          final double discountPct = (enteredPackPrice != null &&
                  originalPackPrice > 0 &&
                  enteredPackPrice < originalPackPrice)
              ? ((originalPackPrice - enteredPackPrice) / originalPackPrice) * 100
              : 0.0;
          final bool isPriceEdited =
              enteredPackPrice != null && enteredPackPrice != originalPackPrice;

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            content: Container(
              width: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade700,
                          Colors.deepPurple.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Pack Price'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Original: ',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13),
                              ),
                              Text(
                                formatAmount(originalPackPrice.toString()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (allowedDiscount != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Max discount: ${allowedDiscount!.toStringAsFixed(0)}%  '
                              '(Min price: ${formatAmount((originalPackPrice - originalPackPrice * allowedDiscount! / 100).toString())})',
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Body ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Pack Price'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: priceController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: Center(
                              widthFactor: 1,
                              child: Text(
                                currencySymbol,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade400,
                                ),
                              ),
                            ),
                            hintText: '0.00',
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.deepPurple.shade200, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.deepPurple.shade600, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isPriceEdited)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: discountPct > 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: discountPct > 0
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  discountPct > 0
                                      ? Icons.trending_down
                                      : Icons.trending_up,
                                  color: discountPct > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    discountPct > 0
                                        ? 'Discount: ${discountPct.toStringAsFixed(1)}%  '
                                            '(Saving: ${formatAmount((originalPackPrice - (enteredPackPrice ?? 0)).toString())} total)'
                                        : 'Price is not less than original',
                                    style: TextStyle(
                                      color: discountPct > 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                child: Text('Cancel'.tr,
                                    style: TextStyle(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurple.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                ),
                                onPressed: () async {
                                  final GlobalKey<CartDialogueState>
                                      cartDialogKey =
                                      GlobalKey<CartDialogueState>();

                                  final double? newPackPrice =
                                      double.tryParse(priceController.text);
                                  if (newPackPrice == null || newPackPrice <= 0)
                                    return;

                                  if (newPackPrice > originalPackPrice) {
                                    Get.snackbar(
                                      'Invalid Price'.tr,
                                      'New pack price must be less than or equal to the original price.'
                                          .tr,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                    );
                                    return;
                                  }

                                  if (newPackPrice < originalPackPrice && allowedDiscount == null) {
                                    Get.snackbar(
                                      'Not Allowed',
                                      'No discount configured for this product',
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                    );
                                    return;
                                  }

                                  if (allowedDiscount != null) {
                                    final bool isAllowed =
                                        isPriceWithinDiscount(
                                      originalPrice: originalPackPrice,
                                      enteredPrice: newPackPrice,
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
                                  }

                                  final double computedUnitPrice = newPackPrice / pieces;
                                  groupedItem.detail.displayPrice =
                                      computedUnitPrice.toString();
                                  groupedItem.totalPrice =
                                      Utils().calculateTotalPrice(groupedItem,
                                          groupedItem.detail.count.toInt());

                                  final cartState =
                                      context.findAncestorStateOfType<CartDialogueState>();
                                  if (cartState != null) {
                                    cartState.refreshCart();
                                  }
                                  Get.back();
                                },
                                child: Text('Apply'.tr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
  final minAllowedPrice = double.parse(
      (originalPrice - (originalPrice * allowedDiscountPercent / 100))
          .toStringAsFixed(2));

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
  required dynamic percent,
  required double amount,
  required Color color,
}) {
  final double pVal =
      (num.tryParse(percent?.toString() ?? '0') ?? 0).toDouble();
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
              pVal > 0
                  ? "-${pVal.toStringAsFixed(1)}%"
                  : "-${formatAmount(amount.toString())}",
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
  final double fontSize;
  final String content;
  final int maxLines;
  final TextAlign align;

  const TableContent({
    super.key,
    required this.fontSize,
    required this.content,
    this.align = TextAlign.center,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: align == TextAlign.start
            ? Alignment.centerLeft
            : align == TextAlign.end
                ? Alignment.centerRight
                : Alignment.center,
        child: CustomText(
          content: content,
          textAlign: align,
          fontSize: fontSize >= 13.0 ? fontSize : 13.5,
          fontWeight: FontWeight.w600,
          maxLine: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}


