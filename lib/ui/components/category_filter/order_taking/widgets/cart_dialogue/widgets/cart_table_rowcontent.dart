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
      // Calculate base price and total quantity
      // final double basePrice =
      //     double.tryParse(groupedItem.detail.sellPrice?.toString() ?? '0') ??
      //         0.0;
      final taxDiscountAmount = ((groupedItem.detail.tax ?? 0.0) *
          ((groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
              ? (groupedItem.detail.pieces?.toDouble() ?? 1) *
                  groupedItem.detail.count.toDouble()
              : groupedItem.detail.count.toDouble()) *
          ((double.tryParse(groupedItem.detail.discount?.toString() ?? '0') ??
                  0.0) /
              100));
      final double totalQuantity =
          (groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack')
              ? (groupedItem.detail.pieces?.toDouble() ?? 1) *
                  groupedItem.detail.count.toDouble()
              : groupedItem.detail.count.toDouble();


double totalPrice = groupedItem.totalPrice;

// ✅ Use backend values if available, don't overwrite
double CustomerDiscount;
if (groupedItem.CustomerDiscount != null && groupedItem.CustomerDiscount! > 0) {
  // Already set from backend
  CustomerDiscount = groupedItem.CustomerDiscount!;
  print('Using backend customer discount: $CustomerDiscount');
} else {
  // Not set, use 0
  CustomerDiscount = 0.0;
}

num tieredDiscount;
if (groupedItem.tieredDiscount != null && groupedItem.tieredDiscount! > 0) {
  // Already set from backend
  tieredDiscount = groupedItem.tieredDiscount!;
  print('Using backend tiered discount: $tieredDiscount');
} else {
  // Not set, use 0
  tieredDiscount = 0;
}

print('tiered discount in calculations: $tieredDiscount');

// Calculate total discount percentage (or use backend value if available)
double totalDiscountPercent = CustomerDiscount + tieredDiscount;

// ✅ Use existing discount amount if available, otherwise calculate
double totalDiscountAmount;
if (groupedItem.totalDiscountAmount != null && groupedItem.totalDiscountAmount! > 0) {
  // Already set from backend - don't recalculate
  totalDiscountAmount = groupedItem.totalDiscountAmount!;
  print('Using backend discount amount: $totalDiscountAmount');
} else {
  // Calculate for new items
  totalDiscountAmount = totalPrice * (totalDiscountPercent / 100.0);
  groupedItem.totalDiscountAmount = totalDiscountAmount;
  print('Calculated discount amount: $totalDiscountAmount');
}

// Calculate final price
double finalPrice = totalPrice - totalDiscountAmount;
groupedItem.finalPrice = finalPrice;



//       double totalPrice = groupedItem.totalPrice;
//       final double CustomerDiscount = groupedItem.CustomerDiscount ?? 0.0;
//       print('customerdiscountttt:$CustomerDiscount');
//       var tieredDiscount = groupedItem.tieredDiscount ?? 0;
//       double totalDiscountPercent = CustomerDiscount + tieredDiscount;

// // // Calculate total discount amount (in currency, not percent)
//       double totalDiscountAmount = totalPrice * (totalDiscountPercent / 100.0);

// // // Optional: Calculate final price after discount
//       double finalPrice = totalPrice - totalDiscountAmount;

//       groupedItem.totalDiscountAmount = totalDiscountAmount;
      groupedItem.finalPrice = finalPrice;

      // // Calculate total base price before discount
      // final double totalBasePrice = basePrice * totalQuantity;

      // // Get discount percentage and max discount if available
      // final double discountPercentage =
      //     double.tryParse(groupedItem.detail.discount?.toString() ?? '0') ??
      //         0.0;
      // final double? maxDiscount = groupedItem.detail.maxDiscount?.toDouble();

      // // Calculate uncapped discount amount
      // double uncappedDiscountAmount =
      //     totalBasePrice * (discountPercentage / 100);

      // // Apply max discount cap if available
      // double actualDiscountAmount = uncappedDiscountAmount;
      // if (maxDiscount != null &&
      //     maxDiscount > 0 &&
      //     uncappedDiscountAmount > maxDiscount) {
      //   actualDiscountAmount = maxDiscount;
      // }

      // // Calculate tax discount based on actual discount percentage
      // final double effectiveDiscountPercentage = totalBasePrice > 0
      //     ? (actualDiscountAmount / totalBasePrice) * 100
      //     : 0;
      // final taxDiscountAmount = (groupedItem.detail.tax ?? 0.0) *
      //     totalQuantity *
      //     (effectiveDiscountPercentage / 100);

      // // Set the discount price for display
      // final discountPrice = actualDiscountAmount;
      final tax = (groupedItem.detail.tax ?? 0) *
          (groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack'
              ? (groupedItem.detail.pieces ?? 0) * groupedItem.detail.count
              : 1);
      // log('Tax Discount Row Item : $discountPrice');
      // log('Tax Discount Row Item : $taxDiscountAmount');
      // log('Draft id is Contains or not? == ${groupedItem.draftId}');
      // log('Incl Tax  == ${groupedItem.detail.inclTax}');
      // log('Discount Amount on Get Rows : ${groupedItem.detail.discount}');
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
          DataCell(TableContent(
              fontSize: fontSize,
              maxLines: 1,
              content: formatAmount(groupedItem.detail.sellPrice ?? '0'))),
               DataCell(
  TableContent(
    fontSize: fontSize,
    maxLines: 2,
    content: (groupedItem.detail.packtype == 'Pack' || groupedItem.isPack == true)
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
                            groupedItem.detail.sellPrice?.toString() ?? '0') ??
                        0.0;

                    // Price per sellable unit (pack = whole pack price, else per piece)
                    final double pricePerSellableUnit =
                        (groupedItem.isPack == true ||
                                groupedItem.detail.packtype == 'Pack')
                            ? basePricePerUnit
                            : basePricePerUnit;

                    // Total original price before any discount
                    final double originalTotalPrice =
                        pricePerSellableUnit * totalQuantity;

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
                    final double userDiscountPercent = pricePerSellableUnit > 0
                        ? (userFlatDiscountPerUnit / pricePerSellableUnit) * 100
                        : 0.0;

                    final double totalEffectiveDiscountPercent =
                        originalTotalPrice > 0
                            ? (totalDiscountApplied / originalTotalPrice) * 100
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
                                      groupedItem.detail.productName ?? "Item",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${totalQuantity.toInt()} × ${groupedItem.isPack == true || groupedItem.detail.packtype == 'Pack' ? 'Pack' : 'Piece'}",
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
                                  amount: CustomerDiscount * totalQuantity,
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
                                  amount: promoDiscountAmountPerUnit * totalQuantity,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (CustomerDiscount == 0 && tieredDiscount == 0)
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
          // DataCell(
          //   TableContent(
          //     maxLines: 1,
          //     fontSize: fontSize,
          //     content: formatAmount(discountPrice),
          //     // Add visual indicator for max discount cap
          //     suffix: maxDiscount != null &&
          //             maxDiscount > 0 &&
          //             uncappedDiscountAmount > maxDiscount
          //         ? " (max)"
          //         : null,
          //     suffixStyle: maxDiscount != null &&
          //             maxDiscount > 0 &&
          //             uncappedDiscountAmount > maxDiscount
          //         ? const TextStyle(
          //             color: Colors.red,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 10)
          //         : null,
          //   ),
          // ),
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
          // DataCell(
          //   Center(
          //     child: ConstrainedBox(
          //       constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
          //       // child: CustomText(
          //       //   content: formatAmount(groupedItem.totalPrice),
          //       //   textAlign: TextAlign.right,
          //       //   fontSize: fontSize,
          //       //   maxLine: 1,
          //       // ),
          //       child: Builder(builder: (context) {
          //         // Recalculate total price for promo items to ensure it's always up-to-date
          //         double displayTotal = groupedItem.totalPrice;

          //         if (groupedItem.isPromo ?? false) {
          //           double basePrice =
          //               double.tryParse(groupedItem.detail.sellPrice ?? '0') ??
          //                   0;
          //           int pieces = groupedItem.detail.pieces?.toInt() ?? 1;
          //           num count = groupedItem.detail.count;
          //           num tax = groupedItem.detail.tax ?? 0;
          //           double discountPercentage =
          //               groupedItem.detail.discount?.toDouble() ?? 0;
          //           double? maxDiscount =
          //               groupedItem.detail.maxDiscount?.toDouble();

          //           // Calculate total quantity and base price
          //           num totalCount =
          //               groupedItem.isPack == true ? count * pieces : count;
          //           double totalBasePrice = basePrice * totalCount;

          //           // Calculate discount with max discount cap
          //           double uncappedDiscountAmount =
          //               totalBasePrice * (discountPercentage / 100);
          //           double actualDiscountAmount = uncappedDiscountAmount;

          //           if (maxDiscount != null &&
          //               maxDiscount > 0 &&
          //               uncappedDiscountAmount > maxDiscount) {
          //             actualDiscountAmount = maxDiscount;
          //           }

          //           // Calculate effective discount percentage and apply to price and tax
          //           double effectiveDiscountPercentage = totalBasePrice > 0
          //               ? (actualDiscountAmount / totalBasePrice) * 100
          //               : 0;
          //           double effectiveSellingPrice =
          //               basePrice * (1 - effectiveDiscountPercentage / 100);
          //           tax = tax * (1 - effectiveDiscountPercentage / 100);

          //           double priceWithTax =
          //               groupedItem.detail.inclTax == "incl_tax"
          //                   ? effectiveSellingPrice
          //                   : effectiveSellingPrice + tax;

          //           displayTotal = priceWithTax * totalCount;
          //         }

          //         return CustomText(
          //           content: formatAmount(displayTotal),
          //           textAlign: TextAlign.right,
          //           fontSize: fontSize,
          //           maxLine: 1,
          //         );
          //       }),
          //     ),
          //   ),
          // ),
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
            // const SizedBox(width: 8),
            // Text(
            //   "(₹${formatAmount(amount)})",
            //   style: TextStyle(
            //     // color: color.white. shade700,
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
        ),
      ),
    ],
  );
}
// ignore: must_be_immutable
class TableContent extends StatelessWidget {
  double fontSize;
  String content;
  int maxLines;
  String? suffix;
  TextStyle? suffixStyle;

  TableContent({
    super.key,
    required this.fontSize,
    required this.content,
    this.maxLines = 2,
    this.suffix,
    this.suffixStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
        child: suffix != null
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: content,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: suffix,
                      style: suffixStyle ??
                          TextStyle(
                            fontSize: fontSize,
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              )
            : CustomText(
                content: content,
                textAlign: TextAlign.center,
                fontSize: fontSize,
                maxLine: maxLines,
              ),
      ),
    );
  }
}
