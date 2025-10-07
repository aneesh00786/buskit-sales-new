// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_screen.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_category_list.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_product_list.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_product_list_by_brand.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:provider/provider.dart';

class PromotionDetails extends StatelessWidget {
  final ProductsController controller;

  const PromotionDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    CustomerAndOrderController customerAndOrderController =
        Get.find<CustomerAndOrderController>();
    ProductsController productController = Get.find<ProductsController>();

    return Expanded(
      child: Obx(() {
        final promo = controller.selectedPromotion.value;

        if (promo == null) {
          return const Center(
            child: Text("Select a promotion to see details"),
          );
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            children: [
              Container(
                height: 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      /// Title + description
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                promo.title ?? "Untitled",
                                style: const TextStyle(fontSize: 24),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                (promo.description == null ||
                                        promo.description!.isEmpty)
                                    ? "No description"
                                    : promo.description!,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          _buildStatus(promo),
                          SizedBox(width: 20),
                        ],
                      ),

                      buildPromotionDetails(promo),

                      /// Type + Status pills
                      _buildTypeAndStatus(promo),
                      // _buildPromoCode(promo),

                      /// Discount / Scope / Target
                      _buildDiscountScopeTarget(promo),

                      /// Expiry
                      SizedBox(
                        height: 24,
                      ),
                      if (promo.startDate != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22.0),
                          child: Text(
                            "Started: ${NKDateUtils.commonDayFormat3(NKDateUtils.formatStringUTCDateTime(promo.startDate.toString()))}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Text(
                          promo.endDate == null
                              ? "Expiry: N/A"
                              : "Expiry: ${NKDateUtils.commonDayFormat3(NKDateUtils.formatStringUTCDateTime(promo.endDate.toString()))}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),

                      /// Add to cart button
                      SizedBox(height: 20),

                      /// Bundle quantity selector for product_bundle promotions
                      if (promo.promoType == "product_bundle") ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Builder(builder: (context) {
                            // Create quantity notifier for bundle
                            final ValueNotifier<int> bundleQty =
                                ValueNotifier<int>(1);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bundle Price: ${formatAmount(promo.bundlePrice)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Quantity:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Decrease',
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              if (bundleQty.value > 1) {
                                                bundleQty.value =
                                                    bundleQty.value - 1;
                                              }
                                            },
                                          ),
                                          ValueListenableBuilder<int>(
                                            valueListenable: bundleQty,
                                            builder: (context, value, _) =>
                                                Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(
                                                '$value',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Increase',
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              bundleQty.value =
                                                  bundleQty.value + 1;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () async {
                                    if ((customerAndOrderController
                                            .customerId.value.isNotEmpty) ||
                                        (productController.selectedCustomerName
                                            .value.isNotEmpty)) {
                                      final customerId =
                                          customerAndOrderController
                                                  .customerId.value.isNotEmpty
                                              ? customerAndOrderController
                                                  .customerId.value
                                              : productController
                                                  .selectedCustomerId.value;

                                      log("[BUNDLE] === Product Bundle Promo Started ===");
                                      log("[BUNDLE] Bundle price: ${promo.bundlePrice}");
                                      log("[BUNDLE] Quantity: ${bundleQty.value}");

                                      // Create a special bundle detail with bundle price
                                      final bundleDetail = Detail(
                                        variationId:
                                            "BUNDLE_${promo.id}", // Special bundle ID
                                        productId: "BUNDLE_${promo.id}",
                                        variationName: promo.title ?? "Bundle",
                                        unitType: "bundle",
                                        price: promo.bundlePrice?.toString() ??
                                            "0",
                                        sellPrice:
                                            promo.bundlePrice?.toString() ??
                                                "0",
                                        tax: 0, // Bundle tax handled separately
                                        packtype: "bundle",
                                        pieces: 1,
                                        stock: 999, // High stock for bundles
                                        lowstock: 0,
                                        fullstock: 999,
                                        imageUrl:
                                            promo.products?.isNotEmpty == true
                                                ? promo.products![0].variants
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? promo.products![0]
                                                        .variants![0].imageUrl
                                                    : null
                                                : null,
                                        productName: promo.title ?? "Bundle",
                                      );

                                      final catId =
                                          0; // Special category for bundles

                                      // Create detailed bundle message with all items
                                      String bundleDetailsMsg =
                                          "Bundle: ${promo.title}\n\n";
                                      if (promo.bundleItems != null &&
                                          promo.bundleItems!.isNotEmpty) {
                                        bundleDetailsMsg += "Items included:\n";
                                        for (final bundleItem
                                            in promo.bundleItems!) {
                                          // Find the corresponding product variant
                                          Product? product;
                                          try {
                                            product =
                                                promo.products?.firstWhere(
                                              (p) =>
                                                  p.id == bundleItem.variantId,
                                            );
                                          } catch (e) {
                                            product = null;
                                          }

                                          if (product?.variants?.isNotEmpty ==
                                              true) {
                                            final variant =
                                                product!.variants!.first;
                                            final unitPrice = double.tryParse(
                                                    variant.sellPrice
                                                            ?.toString() ??
                                                        '0') ??
                                                0;
                                            final totalPrice = unitPrice *
                                                (bundleItem.quantity ?? 1);

                                            bundleDetailsMsg +=
                                                "• ${variant.productName ?? 'Unknown'} (${variant.variationName ?? ''})\n";
                                            bundleDetailsMsg +=
                                                "  Qty: ${bundleItem.quantity} ${bundleItem.unitType}\n";
                                            bundleDetailsMsg +=
                                                "  Price: ${formatAmount(unitPrice.toString())} each\n";
                                            bundleDetailsMsg +=
                                                "  Total: ${formatAmount(totalPrice.toString())}\n\n";
                                          }
                                        }
                                        bundleDetailsMsg +=
                                            "Bundle Price: ${formatAmount(promo.bundlePrice)}";
                                      }

                                      await CartDatabaseManager()
                                          .addToCartPromo(
                                        customerId: customerId,
                                        localCount: bundleQty.value,
                                        detail: bundleDetail,
                                        isPack: true,
                                        productName: promo.title ?? "Bundle",
                                        inclTax: "0",
                                        isChcked: true,
                                        catId: catId,
                                        promoCode: promo.promoCode,
                                        promoMsg: bundleDetailsMsg,
                                      );

                                      log("[BUNDLE] ✅ Bundle added to cart → customerId: $customerId, quantity: ${bundleQty.value}");
                                      productController.isCartModified.value =
                                          true;

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        final cartProvider =
                                            Provider.of<CustomersProvider>(
                                                context,
                                                listen: false);
                                        log("[BUNDLE] Updating cart count for customer: $customerId");
                                        cartProvider
                                            .updateCartCount(customerId);
                                        cartProvider
                                            .getCartItemCounts(customerId);
                                      });

                                      showCustomToastDisplay(
                                        context,
                                        "Bundle added to cart",
                                        Colors.green.shade800,
                                        Icons.check,
                                      );

                                      log("[BUNDLE] === Product Bundle Promo Completed ===");
                                    } else {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            actions: [
                                              const SizedBox(height: 20),
                                              const Center(
                                                  child: Icon(
                                                      Icons
                                                          .warning_amber_outlined,
                                                      size: 50,
                                                      color: Colors.orange)),
                                              const SizedBox(height: 20),
                                              Center(
                                                  child: CustomText(
                                                      content:
                                                          "Please Select a Customer",
                                                      fontSize: 18)),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: CustomText(
                                                    content: "Ok",
                                                    color: primaryColor),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Add Bundle to Cart",
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],

                      if (promo.productScope == "products") ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Builder(builder: (context) {
                            // Flattened variants for total calculation
                            final List<dynamic> allVariantsStatic = promo
                                    .products
                                    ?.expand((p) => p.variants ?? [])
                                    .toList() ??
                                [];

                            // If multiple products, show product selection dialog
                            if (allVariantsStatic.length > 1) {
                              return InkWell(
                                onTap: () async {
                                  if ((customerAndOrderController
                                          .customerId.value.isNotEmpty) ||
                                      (productController.selectedCustomerName
                                          .value.isNotEmpty)) {
                                    _showMultiProductSelectionDialog(
                                      context,
                                      promo,
                                      allVariantsStatic,
                                    );
                                  } else {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          actions: [
                                            const SizedBox(height: 20),
                                            const Center(
                                                child: Icon(
                                                    Icons
                                                        .warning_amber_outlined,
                                                    size: 50,
                                                    color: Colors.orange)),
                                            const SizedBox(height: 20),
                                            Center(
                                                child: CustomText(
                                                    content:
                                                        "Please Select a Customer",
                                                    fontSize: 18)),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: CustomText(
                                                  content: "Ok",
                                                  color: primaryColor),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: primaryColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Select Products & Quantities",
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Single product - show quantity selector or tier dropdown for tiered_discount
                            final ValueNotifier<int> qty =
                                ValueNotifier<int>(1);
                            final ValueNotifier<Tier?> selectedTier =
                                ValueNotifier<Tier?>(null);

                            double? parseAmount(String? s) {
                              if (s == null || s.isEmpty) return null;
                              final cleaned =
                                  s.replaceAll(RegExp(r'[^0-9\.]'), '');
                              return double.tryParse(cleaned);
                            }

                            Future<bool> validateMinOrderBeforeAdd(
                                List<dynamic> allVariants) async {
                              final double? minOrder =
                                  parseAmount(promo.minOrderValue?.toString());
                              if (minOrder == null) return true;
                              double total = 0;
                              for (final v in allVariants) {
                                // Since addToCart uses isPack: true, use unit * pieces
                                final double unit = double.tryParse(
                                        (v.sellPrice ?? '0').toString()) ??
                                    0;
                                final int pcs = (v.pieces ?? 1).toInt();
                                total += (unit * pcs) * (qty.value);
                              }
                              if (total < minOrder) {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      actions: [
                                        const SizedBox(height: 20),
                                        const Center(
                                            child: Icon(
                                                Icons.warning_amber_outlined,
                                                size: 50,
                                                color: Colors.orange)),
                                        const SizedBox(height: 20),
                                        Center(
                                            child: CustomText(
                                                content:
                                                    "Minimum order is ${formatAmount(promo.minOrderValue)}",
                                                fontSize: 18)),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: CustomText(
                                              content: "Ok",
                                              color: primaryColor),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return false;
                              }
                              return true;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Total above quantity selector
                                const SizedBox(height: 8),
                                // Show tier dropdown for tiered_discount, quantity selector for others
                                if (promo.promoType == "tiered_discount" &&
                                    promo.tiers != null &&
                                    promo.tiers!.isNotEmpty) ...[
                                  // Tier dropdown for tiered_discount
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 200,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                          color: Colors.white,
                                        ),
                                        child: ValueListenableBuilder<Tier?>(
                                          valueListenable: selectedTier,
                                          builder: (context, value, _) =>
                                              DropdownButtonHideUnderline(
                                            child: DropdownButton<Tier>(
                                              value: value,
                                              hint: const Text('Select Tier'),
                                              isExpanded: true,
                                              items:
                                                  promo.tiers!.map((Tier tier) {
                                                final requiredQty =
                                                    (tier.buyQuantity as num?)
                                                            ?.toInt() ??
                                                        0;
                                                final qtyType =
                                                    tier.buyQuantityType ?? '';
                                                final discountValue =
                                                    double.tryParse(tier
                                                                .discountValue
                                                                ?.toString() ??
                                                            '0') ??
                                                        0;
                                                return DropdownMenuItem<Tier>(
                                                  value: tier,
                                                  child: Text(
                                                    '${requiredQty} ${qtyType} - ${discountValue.toStringAsFixed(0)}% off',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (Tier? newValue) {
                                                selectedTier.value = newValue;
                                                if (newValue != null) {
                                                  // Set quantity to the tier's required quantity
                                                  qty.value =
                                                      (newValue.buyQuantity
                                                                  as num?)
                                                              ?.toInt() ??
                                                          1;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // Quantity selector for non-tiered_discount promotions
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              tooltip: 'Decrease',
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if (qty.value > 1) {
                                                  qty.value = qty.value - 1;
                                                }
                                              },
                                            ),
                                            ValueListenableBuilder<int>(
                                              valueListenable: qty,
                                              builder: (context, value, _) =>
                                                  Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  '$value',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Increase',
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                qty.value = qty.value + 1;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: qty,
                                    builder: (context, value, _) {
                                      double unitSum = 0;
                                      for (final v in allVariantsStatic) {
                                        final double unit = double.tryParse(
                                                (v.sellPrice ?? '0')
                                                    .toString()) ??
                                            0;
                                        final int pcs = (v.pieces ?? 1).toInt();
                                        unitSum += unit * pcs;
                                      }
                                      final double total = unitSum * value;
                                      return Text(
                                        'Total: ${formatAmount(total.toString())}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: () async {
                                    if ((customerAndOrderController
                                            .customerId.value.isNotEmpty) ||
                                        (productController.selectedCustomerName
                                            .value.isNotEmpty)) {
                                      //COMEBACK
                                      // showCustomToastDisplay(
                                      //     context,
                                      //     "ADD TO CART - ${promo.promoType?.nkStringCleanAndCapitalize} [${promo.promoCode}]",
                                      //     Colors.green.shade800,
                                      //     Icons.check);
                                      // _showPromoDialog(context, promo);

                                      // ---------------------------------------------------------------------------------------------------

                                      final customerId =
                                          customerAndOrderController
                                                  .customerId.value.isNotEmpty
                                              ? customerAndOrderController
                                                  .customerId.value
                                              : productController
                                                  .selectedCustomerId.value;

                                      // Validate tier selection for tiered_discount promotions
                                      if (promo.promoType ==
                                              "tiered_discount" &&
                                          selectedTier.value == null) {
                                        showCustomToastDisplay(
                                          context,
                                          "Please select a tier discount",
                                          Colors.orange,
                                          Icons.warning,
                                        );
                                        return;
                                      }

                                      // --- Percentage Discount based promos ---
                                      if (promo.promoType ==
                                              "percentage_discount" ||
                                          promo.promoType == "happy_hours" ||
                                          promo.promoType == "seasonal" ||
                                          promo.promoType == "flash_sale" ||
                                          promo.promoType == "limited_time") {
                                        log("[PROMO] === Percentage Discount Promo Started ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        // Decide which discount field to use
                                        final discountValue = promo.promoType ==
                                                "percentage_discount"
                                            ? double.tryParse(
                                                promo.discountValue.toString())
                                            : double.tryParse(promo
                                                .discountPercentage
                                                .toString());

                                        log("[PROMO] Promo Discount: $discountValue");

                                        // Flatten all product variants into one list
                                        final allVariants = promo.products
                                                ?.expand(
                                                    (p) => p.variants ?? [])
                                                .toList() ??
                                            [];

                                        log("[PROMO] Flattened variants count: ${allVariants.length}");

                                        if (allVariants.isEmpty) {
                                          log("[PROMO] No variants found in promo → stopping flow");
                                          showCustomToastDisplay(
                                            context,
                                            "No variants found for this promotion",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Validate min order with selected quantity
                                        final allowed =
                                            await validateMinOrderBeforeAdd(
                                                allVariants);
                                        if (!allowed) return;

                                        for (final v in allVariants) {
                                          log("[PROMO] Processing variant → ID: ${v.id}, ProductId: ${v.productId}, "
                                              "Name: ${v.productName}, SellPrice: ${v.sellPrice}, Tax: ${v.tax}");

                                          // Map each variant into your Detail model
                                          final detail = Detail(
                                            variationId: v.id,
                                            productId: v.productId,
                                            variationName: v.variationName,
                                            unitType: v.unitType,
                                            price: (v.price ?? '0').toString(),
                                            sellPrice:
                                                (v.sellPrice ?? '0').toString(),
                                            tax:
                                                double.tryParse(v.tax ?? '0') ??
                                                    0,
                                            packtype: v.packtype,
                                            pieces: v.pieces,
                                            stock: v.stock,
                                            lowstock: v.lowstock,
                                            fullstock: v.fullstock,
                                            imageUrl: v.imageUrl,
                                            productName: v.productName,
                                            discount: discountValue,
                                          );

                                          log("[PROMO] Mapped Detail → variationId: ${detail.variationId}, "
                                              "productId: ${detail.productId}, name: ${detail.productName}");

                                          final bool isPack =
                                              detail.saleBy == 'Pack';
                                          log("[PROMO] IsPack? $isPack");

                                          final catId = extractCategoryId(
                                              v.productId.toString());
                                          log("[PROMO] Extracted CategoryId: $catId from productId: ${v.productId}");

                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: qty.value,
                                            detail: detail,
                                            isPack: true,
                                            productName: v.productName ?? '',
                                            inclTax: v.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: promo.promoCode,
                                            promoMsg: promo.discountText,
                                          );

                                          log("[PROMO] ✅ Added to cart → variationId: ${detail.variationId}, customerId: $customerId");
                                          productController
                                              .isCartModified.value = true;
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          log("[PROMO] Updating cart count for customer: $customerId");
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        log("[PROMO] === Percentage Discount Promo Completed ===");
                                      }

                                      // --- FLAT DISCOUNT promos (cart-level fixed amount) ---
                                      if (promo.promoType == "flat_discount") {
                                        log("[PROMO] === Flat Discount Promo Started (cart-level) ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        // Flatten variants
                                        final allVariants = promo.products
                                                ?.expand(
                                                    (p) => p.variants ?? [])
                                                .toList() ??
                                            [];
                                        if (allVariants.isEmpty) {
                                          showCustomToastDisplay(
                                            context,
                                            "No variants found for this promotion",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Validate min order with existing helper (based on selected qty)
                                        final allowed =
                                            await validateMinOrderBeforeAdd(
                                                allVariants);
                                        if (!allowed) return;

                                        // 1) Add products normally without modifying discount
                                        for (final v in allVariants) {
                                          final detail = Detail(
                                            variationId: v.id,
                                            productId: v.productId,
                                            variationName: v.variationName,
                                            unitType: v.unitType,
                                            price: (v.price ?? '0').toString(),
                                            sellPrice:
                                                (v.sellPrice ?? '0').toString(),
                                            tax:
                                                double.tryParse(v.tax ?? '0') ??
                                                    0,
                                            packtype: v.packtype,
                                            pieces: v.pieces,
                                            stock: v.stock,
                                            lowstock: v.lowstock,
                                            fullstock: v.fullstock,
                                            imageUrl: v.imageUrl,
                                            productName: v.productName,
                                          );

                                          final catId = extractCategoryId(
                                              v.productId.toString());

                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: qty.value,
                                            detail: detail,
                                            isPack: true,
                                            productName: v.productName ?? '',
                                            inclTax: v.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: promo.promoCode,
                                            promoMsg:
                                                "Flat discount will be applied on total",
                                          );

                                          productController
                                              .isCartModified.value = true;
                                        }

                                        // 2) Store fixed flat discount per customer for cart total display
                                        final double flatAmount =
                                            double.tryParse(promo.discountValue
                                                        ?.toString() ??
                                                    '0') ??
                                                0;
                                        if (flatAmount > 0) {
                                          productController
                                                  .flatDiscountByCustomer[
                                              customerId] = flatAmount;
                                          log("[PROMO] Stored cart-level flat discount ${flatAmount.toStringAsFixed(2)} for $customerId");
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        showCustomToastDisplay(
                                          context,
                                          "Items added. Flat discount will be applied on total",
                                          Colors.green.shade800,
                                          Icons.check,
                                        );

                                        log("[PROMO] === Flat Discount Promo Completed (cart-level) ===");
                                      }

                                      // --- Tiered Discount promos ---
                                      if (promo.promoType ==
                                          "tiered_discount") {
                                        log("[PROMO] === Tiered Discount Promo Started ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        final allVariants = promo.products
                                                ?.expand(
                                                    (p) => p.variants ?? [])
                                                .toList() ??
                                            [];

                                        log("[PROMO] Flattened variants count: ${allVariants.length}");

                                        if (allVariants.isEmpty) {
                                          log("[PROMO] No variants found in promo → stopping flow");
                                          showCustomToastDisplay(
                                            context,
                                            "No variants found for this promotion",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Validate min order with selected quantity
                                        final allowed =
                                            await validateMinOrderBeforeAdd(
                                                allVariants);
                                        if (!allowed) return;

                                        for (final v in allVariants) {
                                          log("[PROMO] Processing variant → ID: ${v.id}, ProductId: ${v.productId}, "
                                              "Name: ${v.productName}, SellPrice: ${v.sellPrice}, Tax: ${v.tax}");

                                          // Calculate tiered discount for this quantity
                                          double? tieredDiscount;
                                          if (promo.promoType ==
                                                  "tiered_discount" &&
                                              selectedTier.value != null) {
                                            // For tiered_discount, use the selected tier's discount
                                            tieredDiscount = double.tryParse(
                                                    selectedTier.value!
                                                            .discountValue
                                                            ?.toString() ??
                                                        '0') ??
                                                0;
                                            log("[PROMO] Using selected tier discount: $tieredDiscount% for tiered_discount");
                                          } else {
                                            // For other promotions, calculate based on quantity
                                            tieredDiscount =
                                                _calculateTieredDiscount(
                                                    promo, qty.value, true);
                                            log("[PROMO] Tiered discount calculated: $tieredDiscount% for quantity: ${qty.value}");
                                          }

                                          // Map each variant into your Detail model
                                          final detail = Detail(
                                            variationId: v.id,
                                            productId: v.productId,
                                            variationName: v.variationName,
                                            unitType: v.unitType,
                                            price: (v.price ?? '0').toString(),
                                            sellPrice:
                                                (v.sellPrice ?? '0').toString(),
                                            tax:
                                                double.tryParse(v.tax ?? '0') ??
                                                    0,
                                            packtype: v.packtype,
                                            pieces: v.pieces,
                                            stock: v.stock,
                                            lowstock: v.lowstock,
                                            fullstock: v.fullstock,
                                            imageUrl: v.imageUrl,
                                            productName: v.productName,
                                            discount: tieredDiscount,
                                          );

                                          log("[PROMO] Mapped Detail → variationId: ${detail.variationId}, "
                                              "productId: ${detail.productId}, name: ${detail.productName}");

                                          final bool isPack =
                                              detail.saleBy == 'Pack';
                                          log("[PROMO] IsPack? $isPack");

                                          final catId = extractCategoryId(
                                              v.productId.toString());
                                          log("[PROMO] Extracted CategoryId: $catId from productId: ${v.productId}");

                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: qty.value,
                                            detail: detail,
                                            isPack: true,
                                            productName: v.productName ?? '',
                                            inclTax: v.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: promo.promoCode,
                                            promoMsg: promo.discountText,
                                          );

                                          log("[PROMO] ✅ Added to cart → variationId: ${detail.variationId}, customerId: $customerId");
                                          productController
                                              .isCartModified.value = true;
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          log("[PROMO] Updating cart count for customer: $customerId");
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        log("[PROMO] === Tiered Discount Promo Completed ===");
                                      }

                                      // --- Free Item promos ---
                                      if (promo.promoType == "free_gift" ||
                                          promo.promoType == "free_sample") {
                                        log("[PROMO] === Free Item Promo Started ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        final allVariants = promo.products
                                                ?.expand(
                                                    (p) => p.variants ?? [])
                                                .toList() ??
                                            [];

                                        log("[PROMO] Flattened variants count: ${allVariants.length}");

                                        if (allVariants.isEmpty) {
                                          log("[PROMO] No variants found in promo → stopping flow");
                                          showCustomToastDisplay(
                                            context,
                                            "No variants found for this promotion",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Validate min order with selected quantity
                                        final allowed =
                                            await validateMinOrderBeforeAdd(
                                                allVariants);
                                        if (!allowed) return;

                                        for (final v in allVariants) {
                                          log("[PROMO] Processing variant → ID: ${v.id}, ProductId: ${v.productId}, "
                                              "Name: ${v.productName}, SellPrice: ${v.sellPrice}, Tax: ${v.tax}");

                                          final detail = Detail(
                                            variationId: v.id,
                                            productId: v.productId,
                                            variationName: v.variationName,
                                            unitType: v.unitType,
                                            price: (v.price ?? '0').toString(),
                                            sellPrice:
                                                (v.sellPrice ?? '0').toString(),
                                            tax:
                                                double.tryParse(v.tax ?? '0') ??
                                                    0,
                                            packtype: v.packtype,
                                            pieces: v.pieces,
                                            stock: v.stock,
                                            lowstock: v.lowstock,
                                            fullstock: v.fullstock,
                                            imageUrl: v.imageUrl,
                                            productName: v.productName,
                                          );

                                          log("[PROMO] Mapped Detail → variationId: ${detail.variationId}, "
                                              "productId: ${detail.productId}, name: ${detail.productName}");

                                          final bool isPack =
                                              detail.saleBy == 'Pack';
                                          log("[PROMO] IsPack? $isPack");

                                          final catId = extractCategoryId(
                                              v.productId.toString());
                                          log("[PROMO] Extracted CategoryId: $catId from productId: ${v.productId}");

                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: qty.value,
                                            detail: detail,
                                            isPack: true,
                                            productName: v.productName ?? '',
                                            inclTax: v.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: promo.promoCode,
                                            promoMsg: promo.discountText,
                                          );

                                          log("[PROMO] ✅ Added to cart → variationId: ${detail.variationId}, customerId: $customerId");
                                          productController
                                              .isCartModified.value = true;
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          log("[PROMO] Updating cart count for customer: $customerId");
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        log("[PROMO] === Free Item Promo Completed ===");
                                      }

                                      // --- BOGO promos ---
                                      if (promo.promoType == "bogo") {
                                        log("[PROMO] === BOGO Promo Started ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        final allVariants = promo.products
                                                ?.expand(
                                                    (p) => p.variants ?? [])
                                                .toList() ??
                                            [];

                                        log("[PROMO] Flattened variants count: ${allVariants.length}");

                                        if (allVariants.isEmpty) {
                                          log("[PROMO] No variants found in promo → stopping flow");
                                          showCustomToastDisplay(
                                            context,
                                            "No variants found for this promotion",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Validate min order using PAID quantity only
                                        final allowed =
                                            await validateMinOrderBeforeAdd(
                                                allVariants);
                                        if (!allowed) return;

                                        for (final v in allVariants) {
                                          log("[PROMO] Processing BOGO variant → ID: ${v.id}, ProductId: ${v.productId}, Name: ${v.productName}");

                                          // Paid detail
                                          final paidDetail = Detail(
                                            variationId: v.id,
                                            productId: v.productId,
                                            variationName: v.variationName,
                                            unitType: v.unitType,
                                            price: (v.price ?? '0').toString(),
                                            sellPrice:
                                                (v.sellPrice ?? '0').toString(),
                                            tax:
                                                double.tryParse(v.tax ?? '0') ??
                                                    0,
                                            packtype: v.packtype,
                                            pieces: v.pieces,
                                            stock: v.stock,
                                            lowstock: v.lowstock,
                                            fullstock: v.fullstock,
                                            imageUrl: v.imageUrl,
                                            productName: v.productName,
                                          );

                                          final catId = extractCategoryId(
                                              v.productId.toString());

                                          // 1) Add PAID items (qty)
                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: qty.value,
                                            detail: paidDetail,
                                            isPack: true,
                                            productName: v.productName ?? '',
                                            inclTax: v.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: promo.promoCode,
                                            promoMsg: promo.discountText,
                                          );

                                          productController
                                              .isCartModified.value = true;
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          log("[PROMO] Updating cart count for customer: $customerId");
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        log("[PROMO] === BOGO Promo Completed ===");
                                      }

                                      // --- BUY X GET Y promos ---
                                      if (promo.promoType == "buy_x_get_y") {
                                        log("[PROMO] === BUY_X_GET_Y Promo Started ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        // Extract deal config (assuming one primary deal)
                                        final deals = promo.deals ?? [];
                                        if (deals.isEmpty) {
                                          log("[PROMO] No deals configured → stopping flow");
                                          showCustomToastDisplay(
                                            context,
                                            "No deal configuration found for this promotion",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        final deal = deals.first;

                                        final int buyQty =
                                            (deal.buyQuantity ?? 0).toInt();
                                        final int getQty =
                                            (deal.getQuantity ?? 0).toInt();
                                        final String buyQtyType =
                                            (deal.buyQuantityType ?? '')
                                                .toString()
                                                .toLowerCase();
                                        final String getQtyType =
                                            (deal.getQuantityType ?? '')
                                                .toString()
                                                .toLowerCase();

                                        if (buyQty <= 0 || getQty < 0) {
                                          log("[PROMO] Invalid buy/get quantities → buy:$buyQty get:$getQty");
                                          showCustomToastDisplay(
                                            context,
                                            "Invalid deal quantities",
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Determine pack/unit based on type strings (e.g., 'carton' => pack)
                                        bool isPackFromType(String t) {
                                          return t == 'carton' ||
                                              t == 'box' ||
                                              t == 'pack';
                                        }

                                        final bool buyIsPack =
                                            isPackFromType(buyQtyType);
                                        final bool getIsPack =
                                            isPackFromType(getQtyType);

                                        // Collect paid variants from promo.products
                                        final paidVariants = promo.products
                                                ?.expand(
                                                    (p) => p.variants ?? [])
                                                .toList() ??
                                            [];

                                        if (paidVariants.isEmpty) {
                                          log("[PROMO] No paid variants found in promo.products");
                                        }

                                        // Validate min order against PAID items only
                                        final allowed =
                                            await validateMinOrderBeforeAdd(
                                                paidVariants);
                                        if (!allowed) return;

                                        // Enforce buy_x condition against selected quantity
                                        if (qty.value < buyQty) {
                                          showCustomToastDisplay(
                                            context,
                                            'Select at least $buyQty to qualify for GET items',
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Compute how many deal sets apply and quantities to add
                                        final int dealsApplicable =
                                            qty.value ~/ buyQty;

                                        // 1) Add PAID items: quantity = selectedQty (user-chosen)
                                        final int paidToAdd = qty.value;
                                        for (final v in paidVariants) {
                                          final paidDetail = Detail(
                                            variationId: v.id,
                                            productId: v.productId,
                                            variationName: v.variationName,
                                            unitType: v.unitType,
                                            price: (v.price ?? '0').toString(),
                                            sellPrice:
                                                (v.sellPrice ?? '0').toString(),
                                            tax:
                                                double.tryParse(v.tax ?? '0') ??
                                                    0,
                                            packtype: v.packtype,
                                            pieces: v.pieces,
                                            stock: v.stock,
                                            lowstock: v.lowstock,
                                            fullstock: v.fullstock,
                                            imageUrl: v.imageUrl,
                                            productName: v.productName,
                                          );

                                          final catId = extractCategoryId(
                                              v.productId.toString());

                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: paidToAdd,
                                            detail: paidDetail,
                                            isPack: buyIsPack,
                                            productName: v.productName ?? '',
                                            inclTax: v.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: promo.promoCode,
                                            promoMsg: promo.discountText,
                                          );

                                          productController
                                              .isCartModified.value = true;
                                        }

                                        // 2) Add FREE items from get variant
                                        // Prefer deal.getVariantId when present; fallback to first variant in promo.getProducts
                                        String? getVariantId =
                                            deal.getVariantId?.toString();
                                        var getVariant;

                                        // Search in promo.getProducts for matching variant
                                        final getProducts =
                                            promo.getProducts ?? [];
                                        for (final gp in getProducts) {
                                          final vars = gp.variants ?? [];
                                          for (final gv in vars) {
                                            if (getVariantId == null ||
                                                gv.id.toString() ==
                                                    getVariantId) {
                                              getVariant = gv;
                                              getVariantId = gv.id.toString();
                                              break;
                                            }
                                          }
                                          if (getVariant != null) break;
                                        }

                                        if (getVariant == null) {
                                          log("[PROMO] No eligible GET variant found; skipping free item add");
                                        } else {
                                          // 2) Add FREE items: quantity = dealsApplicable * getQty
                                          final int freeToAdd =
                                              dealsApplicable * getQty;

                                          final bool isFreeDeal = (deal
                                                  .discountType
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'free');

                                          final freeDetail = Detail(
                                            variationId: getVariant.id,
                                            productId: getVariant.productId,
                                            variationName:
                                                getVariant.variationName,
                                            unitType: getVariant.unitType,
                                            price: isFreeDeal
                                                ? '0'
                                                : (getVariant.price ?? '0')
                                                    .toString(),
                                            sellPrice: isFreeDeal
                                                ? '0'
                                                : (getVariant.sellPrice ?? '0')
                                                    .toString(),
                                            tax: isFreeDeal
                                                ? 0
                                                : double.tryParse(
                                                        getVariant.tax ??
                                                            '0') ??
                                                    0,
                                            packtype: getVariant.packtype,
                                            pieces: getVariant.pieces,
                                            stock: getVariant.stock,
                                            lowstock: getVariant.lowstock,
                                            fullstock: getVariant.fullstock,
                                            imageUrl: getVariant.imageUrl,
                                            productName: getVariant.productName,
                                          );

                                          final catId = extractCategoryId(
                                              getVariant.productId.toString());

                                          await CartDatabaseManager()
                                              .addToCartPromo(
                                            customerId: customerId,
                                            localCount: freeToAdd,
                                            detail: freeDetail,
                                            isPack: getIsPack,
                                            productName:
                                                getVariant.productName ?? '',
                                            inclTax: getVariant.tax ?? '',
                                            isChcked: true,
                                            catId: catId,
                                            promoCode: "FREE",
                                            promoMsg: "This item is Free",
                                            // promoCode: promo.promoCode,
                                            // promoMsg: promo.discountText,
                                          );

                                          productController
                                              .isCartModified.value = true;
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          log("[PROMO] Updating cart count for customer: $customerId");
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        log("[PROMO] === BUY_X_GET_Y Promo Completed ===");
                                      }

                                      // ---------------------------------------------------------------------------------------------------
                                    } else {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            actions: [
                                              const SizedBox(height: 20),
                                              const Center(
                                                  child: Icon(
                                                      Icons
                                                          .warning_amber_outlined,
                                                      size: 50,
                                                      color: Colors.orange)),
                                              const SizedBox(height: 20),
                                              Center(
                                                  child: CustomText(
                                                      content:
                                                          "Please Select a Customer",
                                                      fontSize: 18)),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: CustomText(
                                                    content: "Ok",
                                                    color: primaryColor),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Add to Cart",
                                        style: TextStyle(
                                          color: white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                      if (promo.productScope != "products" &&
                          promo.promoType != "product_bundle") ...[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: InkWell(
                            onTap: () async {
                              log("10");
                              if ((customerAndOrderController
                                      .customerId.value.isNotEmpty) ||
                                  (productController
                                      .selectedCustomerName.value.isNotEmpty)) {
                                showCustomToastDisplay(
                                    context,
                                    "Show products - ${promo.promoType?.nkStringCleanAndCapitalize}",
                                    Colors.green.shade800,
                                    Icons.check);

                                log("1");

                                if (promo.productScope == "categories") {
                                  if (promo.categories!.isNotEmpty) {
                                    // Collect all subcategory IDs as List<String>
                                    final List<String> subcatIds = promo
                                        .categories!
                                        .expand((category) =>
                                            (category.subIds ?? [])
                                                as Iterable<String>)
                                        .toList();

                                    log("Collected subcatIds: $subcatIds");

                                    // Call API with subcatIds
                                    CategoryModel categoryData =
                                        await ApiWorker()
                                            .getCategoryForPromo(subcatIds);

                                    _showProductSelectionDialog(
                                      context,
                                      promo,
                                      categoryData,
                                      promo.minOrderValue != null
                                          ? formatAmount(promo.minOrderValue)
                                          : null,
                                    );
                                  }
                                }

                                if (promo.productScope == "all") {
                                  int companyId = SessionHelper
                                          .loginSavedData?.company_id ??
                                      0;

                                  // Call API with subcatIds
                                  CategoryModel categoryData = await ApiWorker()
                                      .getCategory(companyid: companyId);

                                  _showProductSelectionDialog(
                                    context,
                                    promo,
                                    categoryData,
                                    promo.minOrderValue != null
                                        ? formatAmount(promo.minOrderValue)
                                        : null,
                                  );
                                }

                                if (promo.productScope == "brands") {
                                  var response = await ApiWorker()
                                      .getProductByBrand(promo.brands ?? []);

                                  log("BRANDS RESPONSE : $response");

                                  _showProductSelectionByBrandDialog(
                                    context,
                                    promo,
                                    response,
                                    promo.brands?.join(', ') ?? '',
                                    promo.minOrderValue != null
                                        ? formatAmount(promo.minOrderValue)
                                        : null,
                                  );
                                }

                                // ---------------------------------------------------------------------------------------------------
                              } else {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      actions: [
                                        const SizedBox(height: 20),
                                        const Center(
                                            child: Icon(
                                                Icons.warning_amber_outlined,
                                                size: 50,
                                                color: Colors.orange)),
                                        const SizedBox(height: 20),
                                        Center(
                                            child: CustomText(
                                                content:
                                                    "Please Select a Customer",
                                                fontSize: 18)),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: CustomText(
                                              content: "Ok",
                                              color: primaryColor),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  "Select Products",
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showMultiProductSelectionDialog(
    BuildContext context,
    PromotionReponse promo,
    List<dynamic> variants,
  ) {
    final ProductsController productController = Get.find<ProductsController>();
    final CustomerAndOrderController customerAndOrderController =
        Get.find<CustomerAndOrderController>();

    showDialog(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> selectedItems = [];

        return StatefulBuilder(
          builder: (context, setState) {
            // Add tier selection for tiered_discount promotions
            final ValueNotifier<Tier?> selectedTier =
                ValueNotifier<Tier?>(null);

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: fullScreenWidth(context) * 0.8,
                height: fullScreenHeight(context) * 0.7,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Products & Quantities",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (promo.minOrderValue != null) ...[
                                  Text(
                                    "MIN ORDER : ${formatAmount(promo.minOrderValue)}",
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 12,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          dialogCloseButton1(context, red),
                        ],
                      ),
                    ),

                    // Tier selection for tiered_discount promotions

                    // Product List
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: variants.length,
                          itemBuilder: (context, index) {
                            final variant = variants[index];

                            return StatefulBuilder(
                              builder: (context, itemSetState) {
                                int qty = 0; // Start with 0 quantity

                                // Check if this variant is already selected
                                final existingIndex = selectedItems.indexWhere(
                                    (e) => e['variant'].id == variant.id);
                                if (existingIndex >= 0) {
                                  qty = selectedItems[existingIndex]['quantity']
                                      as int;
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        ClipOval(
                                          child: SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '${ApiConstants.imageBaseUrl}/${variant.imageUrl}',
                                              placeholder: (context, url) =>
                                                  const Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: CircleAvatar(
                                                    radius: 10,
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      'assets/images/Image-not-found.png'),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Product Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                variant.productName ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                variant.variationName ?? "-",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                formatAmount(
                                                    variant.sellPrice ?? '0'),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Quantity Selector
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Decrease',
                                                icon: const Icon(Icons.remove,
                                                    size: 18),
                                                onPressed: () {
                                                  if (qty > 0) {
                                                    qty = qty - 1;
                                                    itemSetState(() {});
                                                    _updateSelectedItems(
                                                        variant,
                                                        qty,
                                                        selectedItems,
                                                        setState);
                                                  }
                                                },
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  '$qty',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              IconButton(
                                                tooltip: 'Increase',
                                                icon: const Icon(Icons.add,
                                                    size: 18),
                                                onPressed: () {
                                                  qty = qty + 1;
                                                  itemSetState(() {});
                                                  _updateSelectedItems(
                                                      variant,
                                                      qty,
                                                      selectedItems,
                                                      setState);
                                                },
                                              ),
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
                        ),
                      ),
                    ),

                    // Footer with Add to Cart
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total Items: ${selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total Amount: ${formatAmount(_computeTotalAmount(selectedItems))}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: selectedItems.isEmpty
                                ? null
                                : () async {
                                    final customerId =
                                        customerAndOrderController
                                                .customerId.value.isNotEmpty
                                            ? customerAndOrderController
                                                .customerId.value
                                            : productController
                                                .selectedCustomerId.value;

                                    // Special case: Flat discount (cart-level)
                                    if (promo.promoType == "flat_discount") {
                                      log("[PROMO] === Flat Discount Promo Started (cart-level) ===");
                                      log("[PROMO] Promo details: ${promo.toJson()}");

                                      // Flatten all variants in this promo
                                      final allVariants = promo.products
                                              ?.expand((p) => p.variants ?? [])
                                              .toList() ??
                                          [];
                                      if (allVariants.isEmpty) {
                                        showCustomToastDisplay(
                                          context,
                                          "No variants found for this promotion",
                                          Colors.orange,
                                          Icons.warning,
                                        );
                                        return;
                                      }

                                      double? parseAmount(String? s) {
                                        if (s == null || s.isEmpty) return null;
                                        final cleaned = s.replaceAll(
                                            RegExp(r'[^0-9\.]'), '');
                                        return double.tryParse(cleaned);
                                      }

                                      Future<bool> validateMinOrderBeforeAdd(
                                          List<dynamic> allVariants) async {
                                        final double? minOrder = parseAmount(
                                            promo.minOrderValue?.toString());
                                        if (minOrder == null) return true;
                                        double total = 0;
                                        // Compute total using selectedItems quantities
                                        for (final e in selectedItems) {
                                          final v = e['variant'];
                                          final int qty = e['quantity'] as int;

                                          final double unit = double.tryParse(
                                                  (v.sellPrice ?? '0')
                                                      .toString()) ??
                                              0;
                                          final int pcs =
                                              (v.pieces ?? 1).toInt();

                                          total += (unit * pcs) * qty;
                                        }

                                        if (total < minOrder) {
                                          await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                actions: [
                                                  const SizedBox(height: 20),
                                                  const Center(
                                                      child: Icon(
                                                          Icons
                                                              .warning_amber_outlined,
                                                          size: 50,
                                                          color:
                                                              Colors.orange)),
                                                  const SizedBox(height: 20),
                                                  Center(
                                                      child: CustomText(
                                                          content:
                                                              "Minimum order is ${formatAmount(promo.minOrderValue)}",
                                                          fontSize: 18)),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: CustomText(
                                                        content: "Ok",
                                                        color: primaryColor),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          return false;
                                        }
                                        return true;
                                      }

                                      // Validate min order using existing helper
                                      final allowed =
                                          await validateMinOrderBeforeAdd(
                                              allVariants);
                                      if (!allowed) return;

                                      // 1) Add all promo variants to cart (no discount on each product directly)
                                      for (final e in selectedItems) {
                                        final v = e['variant'];
                                        final int qty = e['quantity'] as int;

                                        final detail = Detail(
                                          variationId: v.id,
                                          productId: v.productId,
                                          variationName: v.variationName,
                                          unitType: v.unitType,
                                          price: (v.price ?? '0').toString(),
                                          sellPrice:
                                              (v.sellPrice ?? '0').toString(),
                                          tax: double.tryParse(v.tax ?? '0') ??
                                              0,
                                          packtype: v.packtype,
                                          pieces: v.pieces,
                                          stock: v.stock,
                                          lowstock: v.lowstock,
                                          fullstock: v.fullstock,
                                          imageUrl: v.imageUrl,
                                          productName: v.productName,
                                        );

                                        final catId = extractCategoryId(
                                            v.productId.toString());

                                        await CartDatabaseManager()
                                            .addToCartPromo(
                                          customerId: customerId,
                                          localCount:
                                              qty, // ✅ now correctly from selectedItems
                                          detail: detail,
                                          isPack: true,
                                          productName: v.productName ?? '',
                                          inclTax: v.tax ?? '',
                                          isChcked: true,
                                          catId: catId,
                                          promoCode: promo.promoCode,
                                          promoMsg:
                                              "Flat discount will be applied on total",
                                        );

                                        productController.isCartModified.value =
                                            true;
                                      }

                                      // 2) Store cart-level discount for display
                                      final double flatAmount = double.tryParse(
                                              promo.discountValue?.toString() ??
                                                  '0') ??
                                          0;
                                      if (flatAmount > 0) {
                                        productController
                                                .flatDiscountByCustomer[
                                            customerId] = flatAmount;
                                        log("[PROMO] Stored cart-level flat discount ${flatAmount.toStringAsFixed(2)} for $customerId");
                                      }

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        final cartProvider =
                                            Provider.of<CustomersProvider>(
                                                context,
                                                listen: false);
                                        cartProvider
                                            .updateCartCount(customerId);
                                        cartProvider
                                            .getCartItemCounts(customerId);
                                      });

                                      showCustomToastDisplay(
                                        context,
                                        "Items added. Flat discount will be applied on total",
                                        Colors.green.shade800,
                                        Icons.check,
                                      );

                                      log("[PROMO] === Flat Discount Promo Completed (cart-level) ===");
                                      return; // stop here, don’t run normal flow
                                    }

                                    // ---------------- Normal promo flow (unchanged) ----------------

                                    // Validate tier selection for tiered_discount
                                    if (promo.promoType == "tiered_discount" &&
                                        selectedTier.value == null) {
                                      showCustomToastDisplay(
                                        context,
                                        "Please select a tier discount",
                                        Colors.orange,
                                        Icons.warning,
                                      );
                                      return;
                                    }

                                    // Validate min order
                                    final double total = double.tryParse(
                                            _computeTotalAmount(
                                                selectedItems)) ??
                                        0;

                                    final double? minOrder =
                                        promo.minOrderValue != null
                                            ? double.tryParse(
                                                promo.minOrderValue.toString())
                                            : null;

                                    if (minOrder != null && total < minOrder) {
                                      showCustomToastDisplay(
                                        context,
                                        'Minimum order is ${formatAmount(promo.minOrderValue)}. Selected total is ${formatAmount(total.toString())}.',
                                        Colors.orange,
                                        Icons.warning,
                                      );
                                      return;
                                    }

                                    // Add all selected items to cart
                                    for (final e in selectedItems) {
                                      final variant = e['variant'] as dynamic;
                                      final int qty = e['quantity'] as int;

                                      final detail = Detail(
                                        variationId: variant.id,
                                        productId: variant.productId,
                                        variationName: variant.variationName,
                                        unitType: variant.unitType,
                                        price:
                                            (variant.price ?? '0').toString(),
                                        sellPrice: (variant.sellPrice ?? '0')
                                            .toString(),
                                        tax: double.tryParse(
                                                variant.tax ?? '0') ??
                                            0,
                                        packtype: variant.packtype,
                                        pieces: variant.pieces,
                                        stock: variant.stock,
                                        lowstock: variant.lowstock,
                                        fullstock: variant.fullstock,
                                        imageUrl: variant.imageUrl,
                                        productName: variant.productName,
                                        discount: promo.promoType ==
                                                    "tiered_discount" &&
                                                selectedTier.value != null
                                            ? double.tryParse(selectedTier
                                                        .value!.discountValue
                                                        ?.toString() ??
                                                    '0') ??
                                                0
                                            : promo.promoType ==
                                                    "percentage_discount"
                                                ? double.tryParse(promo
                                                    .discountValue
                                                    .toString())
                                                : double.tryParse(promo
                                                    .discountPercentage
                                                    .toString()),
                                      );

                                      final catId = extractCategoryId(
                                          variant.productId.toString());

                                      await _addToCartWithPromoLogic(
                                        customerId: customerId,
                                        localCount: qty,
                                        detail: detail,
                                        isPack: true,
                                        productName: variant.productName ?? '',
                                        inclTax: variant.tax ?? '',
                                        catId: catId,
                                        promo: promo,
                                        productController: productController,
                                        context: context,
                                        selectedTier: selectedTier.value,
                                      );
                                    }

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      final cartProvider =
                                          Provider.of<CustomersProvider>(
                                              context,
                                              listen: false);
                                      cartProvider.updateCartCount(customerId);
                                      cartProvider
                                          .getCartItemCounts(customerId);
                                    });

                                    Navigator.pop(context);
                                    showCustomToastDisplay(
                                      context,
                                      "Added ${selectedItems.length} products to cart",
                                      Colors.green.shade800,
                                      Icons.check,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryButtonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

  String _computeTotalAmount(List<Map<String, dynamic>> selectedItems) {
    double total = 0;
    for (final e in selectedItems) {
      final variant = e['variant'] as dynamic;
      final int qty = e['quantity'] as int;
      final double unit =
          double.tryParse((variant.sellPrice ?? '0').toString()) ?? 0;
      final int pcs = (variant.pieces ?? 1).toInt();
      total += (unit * pcs) * qty;
    }
    return total.toString();
  }

  /// Helper function to handle addToCartPromo with proper promo type logic
  Future<void> _addToCartWithPromoLogic({
    required String customerId,
    required int localCount,
    required Detail detail,
    required bool isPack,
    required String productName,
    required String inclTax,
    required int catId,
    required PromotionReponse promo,
    required ProductsController productController,
    required BuildContext context,
    Tier? selectedTier,
  }) async {
    // Determine discount value based on promo type
    double? discountValue;
    if (promo.promoType == "percentage_discount" ||
        promo.promoType == "happy_hours" ||
        promo.promoType == "seasonal" ||
        promo.promoType == "flash_sale" ||
        promo.promoType == "limited_time") {
      discountValue = promo.promoType == "percentage_discount"
          ? double.tryParse(promo.discountValue.toString())
          : double.tryParse(promo.discountPercentage.toString());
    } else if (promo.promoType == "tiered_discount") {
      // Handle tiered discount - use selected tier if available, otherwise calculate
      if (selectedTier != null) {
        discountValue =
            double.tryParse(selectedTier.discountValue?.toString() ?? '0') ?? 0;
      } else {
        discountValue = _calculateTieredDiscount(promo, localCount, isPack);
      }
    }

    // Create detail with discount if applicable
    final detailWithDiscount = discountValue != null
        ? Detail(
            variationId: detail.variationId,
            productId: detail.productId,
            variationName: detail.variationName,
            unitType: detail.unitType,
            price: detail.price,
            sellPrice: detail.sellPrice,
            tax: detail.tax,
            packtype: detail.packtype,
            pieces: detail.pieces,
            stock: detail.stock,
            lowstock: detail.lowstock,
            fullstock: detail.fullstock,
            imageUrl: detail.imageUrl,
            productName: detail.productName,
            discount: discountValue,
          )
        : detail;

    await CartDatabaseManager().addToCartPromo(
      customerId: customerId,
      localCount: localCount,
      detail: detailWithDiscount,
      isPack: isPack,
      productName: productName,
      inclTax: inclTax,
      isChcked: true,
      catId: catId,
      promoCode: promo.promoCode,
      promoMsg: promo.discountText,
    );

    productController.isCartModified.value = true;
  }

  /// Calculate tiered discount based on quantity and tiers
  double? _calculateTieredDiscount(
      PromotionReponse promo, int quantity, bool isPack) {
    if (promo.tiers == null || promo.tiers!.isEmpty) return null;

    // Sort tiers by buy_quantity in descending order to find the highest applicable tier
    final sortedTiers = List<Tier>.from(promo.tiers!);
    sortedTiers.sort((a, b) {
      final aQty = (a.buyQuantity as num?)?.toInt() ?? 0;
      final bQty = (b.buyQuantity as num?)?.toInt() ?? 0;
      return bQty.compareTo(aQty); // Descending order
    });

    // Find the highest tier that the quantity qualifies for
    for (final tier in sortedTiers) {
      final requiredQty = (tier.buyQuantity as num?)?.toInt() ?? 0;
      final qtyType = (tier.buyQuantityType as String?)?.toLowerCase() ?? '';

      // Check if quantity type matches (pack/box/unit)
      bool typeMatches = false;
      if (isPack) {
        typeMatches =
            qtyType == 'pack' || qtyType == 'box' || qtyType == 'carton';
      } else {
        typeMatches =
            qtyType == 'unit' || qtyType == 'piece' || qtyType == 'pcs';
      }

      if (quantity >= requiredQty && typeMatches) {
        final discountValue =
            double.tryParse(tier.discountValue?.toString() ?? '0') ?? 0;
        log("[TIERED] Applied tier: $requiredQty $qtyType → $discountValue% discount for quantity: $quantity");
        return discountValue;
      }
    }

    log("[TIERED] No tier applicable for quantity: $quantity, isPack: $isPack");
    return null;
  }

  void _updateSelectedItems(
    dynamic variant,
    int quantity,
    List<Map<String, dynamic>> selectedItems,
    void Function(void Function()) setState,
  ) {
    setState(() {
      final idx =
          selectedItems.indexWhere((e) => e['variant'].id == variant.id);
      if (idx >= 0) {
        if (quantity > 0) {
          selectedItems[idx]['quantity'] = quantity;
        } else {
          selectedItems.removeAt(idx);
        }
      } else if (quantity > 0) {
        selectedItems.add({
          'variant': variant,
          'quantity': quantity,
        });
      }
    });
  }

  void _showProductSelectionByBrandDialog(
    BuildContext context,
    PromotionReponse promo,
    List<ProductModel> productList,
    String brandName,
    String? minOrderAmount,
  ) {
    final ProductsController productController = Get.find<ProductsController>();
    final CustomerAndOrderController customerAndOrderController =
        Get.find<CustomerAndOrderController>();

    showDialog(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> selectedItems = [];

        return StatefulBuilder(
          builder: (context, setState) {
            // Add tier selection for tiered_discount promotions
            final ValueNotifier<Tier?> selectedTier =
                ValueNotifier<Tier?>(null);

            // Animation controller inside dialog
            final AnimationController animationController = AnimationController(
              duration: const Duration(milliseconds: 500),
              vsync: Navigator.of(context), // use Navigator as TickerProvider
            );

            // Play add-to-cart animation
            void playAddToCartAnimation() {
              animationController
                  .forward()
                  .then((_) => animationController.reverse());
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Products",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (minOrderAmount != null &&
                                      minOrderAmount != "") ...[
                                    Text(
                                      "MIN ORDER : $minOrderAmount",
                                      style: const TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 12,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                _showSelectedItemsDialog(
                                  context,
                                  setState,
                                  selectedItems,
                                  productController,
                                  customerAndOrderController,
                                  minOrderAmount,
                                  promo,
                                );
                              },
                              child: Text(
                                "Selected Products",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins_Regular',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'View selected items',
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  if (selectedItems.isNotEmpty)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () {
                                _showSelectedItemsDialog(
                                  context,
                                  setState,
                                  selectedItems,
                                  productController,
                                  customerAndOrderController,
                                  minOrderAmount,
                                  promo,
                                );
                              },
                            ),
                            const SizedBox(width: 30),
                            dialogCloseButton1(context, red),
                          ],
                        ),
                      ),

                      /// Product Grid by Brand
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ProductGridPromoByBrand(
                            optionName:
                                brandName, // <-- show brandName instead of subcategory
                            productsController: productController,
                            id: "", // no subcategory filtering
                            playAddToCartAnimation: playAddToCartAnimation,
                            products: productList,
                            promo: promo,
                            onVariantsSelected: (selections) {
                              // Merge selections into _selectedItems (by variationId + isPack)
                              setState(() {
                                for (final s in selections) {
                                  final Detail d = s['detail'] as Detail;
                                  final int qty = s['quantity'] as int;
                                  final bool isPack = s['isPack'] as bool;
                                  final idx = selectedItems.indexWhere((e) {
                                    final Detail ed = e['detail'] as Detail;
                                    final bool eIsPack = e['isPack'] as bool;
                                    return ed.variationId == d.variationId &&
                                        eIsPack == isPack;
                                  });
                                  if (idx >= 0) {
                                    selectedItems[idx]['quantity'] =
                                        (selectedItems[idx]['quantity']
                                                as int) +
                                            qty;
                                  } else {
                                    selectedItems.add(s);
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showProductSelectionDialog(
    BuildContext context,
    PromotionReponse promo,
    CategoryModel categoryData,
    String? minOrderAmount,
  ) {
    final double drawerWidth = 300.0;
    final ProductsController productController = Get.find<ProductsController>();
    final CustomerAndOrderController customerAndOrderController =
        Get.find<CustomerAndOrderController>();

    showDialog(
      context: context,
      builder: (context) {
        bool isDrawerOpen = true;
        String selectedCategory = '';
        String selectedOption = '';
        String id = '';
        Timer? drawerTimer;
        List<Map<String, dynamic>> selectedItems = [];

        // Pre-select first category + subcategory
        if (categoryData.data != null && categoryData.data!.isNotEmpty) {
          final firstCategory = categoryData.data![0];
          selectedCategory = firstCategory.categoryName ?? '';
          if (firstCategory.subCategoryItem != null &&
              firstCategory.subCategoryItem!.isNotEmpty) {
            final firstSub = firstCategory.subCategoryItem![0];
            id = firstSub.id ?? '';
            selectedOption = firstSub.subCategory ?? '';
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            // Add tier selection for tiered_discount promotions
            final ValueNotifier<Tier?> selectedTier =
                ValueNotifier<Tier?>(null);

            // Animation controller inside dialog
            final AnimationController animationController = AnimationController(
              duration: const Duration(milliseconds: 500),
              vsync: Navigator.of(context), // use Navigator as TickerProvider
            );

            // Play add-to-cart animation
            void playAddToCartAnimation() {
              animationController
                  .forward()
                  .then((_) => animationController.reverse());
            }

            void toggleDrawer() {
              setState(() => isDrawerOpen = !isDrawerOpen);

              drawerTimer?.cancel();
              if (isDrawerOpen) {
                drawerTimer = Timer(const Duration(seconds: 3), () {
                  setState(() => isDrawerOpen = false);
                });
              }
            }

            void selectCategory(String categoryName) {
              setState(() {
                selectedCategory = categoryName;

                // Auto-select first subcategory of the new category
                final category = categoryData.data!
                    .firstWhere((c) => c.categoryName == categoryName);
                if (category.subCategoryItem != null &&
                    category.subCategoryItem!.isNotEmpty) {
                  final firstSub = category.subCategoryItem![0];
                  id = firstSub.id ?? '';
                  selectedOption = firstSub.subCategory ?? '';
                }
              });
            }

            void fetchProductsByCategory(String subCategoryId) {
              setState(() {
                id = subCategoryId;
                // _selectedOption = subCategoryName;
              });
              // Trigger API call if needed
              // productController.fetchProductsByCategory(subCategoryId);
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Products",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (minOrderAmount != null &&
                                      minOrderAmount != "") ...[
                                    Text(
                                      "MIN ORDER : $minOrderAmount",
                                      style: const TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 12,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),
                            // Selected items icon button
                            InkWell(
                              onTap: () {
                                _showSelectedItemsDialog(
                                  context,
                                  setState,
                                  selectedItems,
                                  productController,
                                  customerAndOrderController,
                                  minOrderAmount,
                                  promo,
                                );
                              },
                              child: Text(
                                "Selected Products",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins_Regular',
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              tooltip: 'View selected items',
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  if (selectedItems.isNotEmpty)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: () {
                                _showSelectedItemsDialog(
                                  context,
                                  setState,
                                  selectedItems,
                                  productController,
                                  customerAndOrderController,
                                  minOrderAmount,
                                  promo,
                                );
                              },
                            ),
                            SizedBox(width: 30),
                            dialogCloseButton1(context, red),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 60),
                            Expanded(
                              child: ProductGridPromo(
                                optionName: selectedOption,
                                productsController: productController,
                                id: id,
                                playAddToCartAnimation: playAddToCartAnimation,
                                categoryData: categoryData,
                                promo: promo,
                                onVariantsSelected: (selections) {
                                  // Merge selections into _selectedItems (by variationId + isPack)
                                  setState(() {
                                    for (final s in selections) {
                                      final Detail d = s['detail'] as Detail;
                                      final int qty = s['quantity'] as int;
                                      final bool isPack = s['isPack'] as bool;
                                      final idx = selectedItems.indexWhere((e) {
                                        final Detail ed = e['detail'] as Detail;
                                        final bool eIsPack =
                                            e['isPack'] as bool;
                                        return ed.variationId ==
                                                d.variationId &&
                                            eIsPack == isPack;
                                      });
                                      if (idx >= 0) {
                                        selectedItems[idx]['quantity'] =
                                            (selectedItems[idx]['quantity']
                                                    as int) +
                                                qty;
                                      } else {
                                        selectedItems.add(s);
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// Vertical mini drawer with initials
                  Positioned(
                    left: 0,
                    top: 10,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Container(
                        width: 50,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: primaryColor.withOpacity(0.2),
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.menu,
                                size: 20,
                                color: primaryColor,
                              ),
                              onPressed: toggleDrawer,
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount: categoryData.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final categories = categoryData.data ?? [];
                                  final categoryName =
                                      categories[index].categoryName ?? '';
                                  final initial = categoryName.isNotEmpty
                                      ? categoryName[0].toUpperCase()
                                      : '';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: IconButton(
                                      icon: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () =>
                                          selectCategory(categoryName),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Overlay when drawer is open
                  if (isDrawerOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isDrawerOpen = false);
                          drawerTimer?.cancel();
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),

                  /// Slide-out category drawer
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: 10,
                    bottom: 0,
                    left: isDrawerOpen ? 50 : -drawerWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Container(
                        width: drawerWidth,
                        color: Colors.white,
                        child: CategoryListPromo(
                          categoryModel: categoryData,
                          categories: categoryData.data!.map((entry) {
                            return CategoryItemPromo(
                              title: entry.categoryName ?? '',
                              options: entry.subCategoryItem ?? [],
                            );
                          }).toList(),
                          onOptionSelected: (selectedSubcategoryId) {
                            log('Selected Subcategory ID: $selectedSubcategoryId');
                            fetchProductsByCategory(selectedSubcategoryId);
                          },
                          onDrawerToggle: toggleDrawer,
                          selectedCategory: selectedCategory,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSelectedItemsDialog(
    BuildContext context,
    void Function(void Function()) parentSetState,
    List<Map<String, dynamic>> selectedItems,
    ProductsController productController,
    CustomerAndOrderController customerAndOrderController,
    String? minOrderAmountFormatted,
    PromotionReponse promo,
  ) {
    double? parseAmount(String? s) {
      if (s == null || s.isEmpty) return null;
      final cleaned = s.replaceAll(RegExp(r'[^0-9\.]'), '');
      return double.tryParse(cleaned);
    }

    double priceForItem(Map<String, dynamic> e) {
      final Detail d = e['detail'] as Detail;
      final bool isPack = e['isPack'] as bool;
      // Prefer sellingPackPrice when pack; fallback to sellPrice * pieces
      if (isPack) {
        final double pack = (d.sellingPackPrice?.toDouble() ?? 0);
        if (pack > 0) return pack;
        final double unit = double.tryParse(d.sellPrice.toString()) ?? 0;
        final int pcs = (d.pieces ?? 1).toInt();
        return unit * pcs;
      } else {
        return double.tryParse(d.sellPrice.toString()) ?? 0;
      }
    }

    double computeSelectedTotal() {
      double total = 0;
      for (final e in selectedItems) {
        final int qty = (e['quantity'] as int);
        total += priceForItem(e) * qty;
      }
      return total;
    }

    final double? minOrderValue = parseAmount(minOrderAmountFormatted);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          // Add tier selection for tiered_discount promotions
          final ValueNotifier<Tier?> selectedTier = ValueNotifier<Tier?>(null);

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SizedBox(
              width: fullScreenWidth(context) * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Select Products",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins_Regular',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 30),
                        dialogCloseButton1(context, red),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedItems.isEmpty) ...[
                          const Text('No items selected yet.'),
                        ],
                        if (selectedItems.isNotEmpty) ...[
                          SizedBox(
                            height: fullScreenHeight(context) * 0.5,
                            child: Scrollbar(
                              thumbVisibility:
                                  true, // always show the scrollbar
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: selectedItems.length,
                                itemBuilder: (context, index) {
                                  final e = selectedItems[index];
                                  final Detail d = e['detail'] as Detail;
                                  final int qty = e['quantity'] as int;
                                  final bool isPack = e['isPack'] as bool;
                                  final String priceText =
                                      formatAmount(d.sellPrice);

                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                        d.productName ?? d.variationName ?? ''),
                                    subtitle: Text(
                                        '${d.variationName ?? ''} • ${isPack ? 'Pack' : 'Pcs'}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Qty: $qty'),
                                            Text(priceText),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 14, color: Colors.red),
                                          onPressed: () {
                                            setStateDialog(() {
                                              selectedItems.removeAt(index);
                                            });
                                            parentSetState(() {
                                              selectedItems.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Divider(color: Colors.grey),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Builder(
                              builder: (_) {
                                final total = computeSelectedTotal();
                                return Text(
                                  formatAmount(total.toString()),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                );
                              },
                            ),
                          ],
                        ),
                        if (minOrderValue != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Min Order:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              Text(minOrderAmountFormatted ?? ''),
                            ],
                          ),
                        ],
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Spacer(),
                            ElevatedButton(
                              onPressed: selectedItems.isEmpty
                                  ? null
                                  : () async {
                                      final customerId =
                                          customerAndOrderController
                                                  .customerId.value.isNotEmpty
                                              ? customerAndOrderController
                                                  .customerId.value
                                              : productController
                                                  .selectedCustomerId.value;

                                      // ---------------- Flat Discount Promo ----------------
                                      if (promo.promoType == "flat_discount") {
                                        log("[PROMO] === Flat Discount Promo Started (cart-level) ===");
                                        log("[PROMO] Promo details: ${promo.toJson()}");

                                        final currentTotal =
                                            computeSelectedTotal();

                                        // Validate min order
                                        if (minOrderValue != null &&
                                            currentTotal < minOrderValue) {
                                          showCustomToastDisplay(
                                            context,
                                            'Minimum order is $minOrderAmountFormatted. Selected total is ${formatAmount(currentTotal.toString())}.',
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }

                                        // Add all promo variants to cart (no discount at item level)
                                        for (final e in selectedItems) {
                                          final Detail detail =
                                              e['detail'] as Detail;
                                          final int qty = e['quantity'] as int;
                                          final bool isPack =
                                              e['isPack'] as bool;
                                          final String productName =
                                              (e['productName'] as String?) ??
                                                  '';
                                          final String inclTax =
                                              (e['inclTax'] as String?) ?? '';
                                          final int catId =
                                              (e['catId'] as int?) ?? 0;

                                          await _addToCartWithPromoLogic(
                                            customerId: customerId,
                                            localCount: qty,
                                            detail: detail,
                                            isPack: isPack,
                                            productName: productName,
                                            inclTax: inclTax,
                                            catId: catId,
                                            promo: promo,
                                            productController:
                                                productController,
                                            context: context,
                                            selectedTier: selectedTier.value,
                                          );
                                        }

                                        // Store cart-level flat discount
                                        final double flatAmount =
                                            double.tryParse(promo.discountValue
                                                        ?.toString() ??
                                                    '0') ??
                                                0;
                                        if (flatAmount > 0) {
                                          productController
                                                  .flatDiscountByCustomer[
                                              customerId] = flatAmount;
                                          log("[PROMO] Stored cart-level flat discount ${flatAmount.toStringAsFixed(2)} for $customerId");
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final cartProvider =
                                              Provider.of<CustomersProvider>(
                                                  context,
                                                  listen: false);
                                          cartProvider
                                              .updateCartCount(customerId);
                                          cartProvider
                                              .getCartItemCounts(customerId);
                                        });

                                        showCustomToastDisplay(
                                          context,
                                          "Items added. Flat discount will be applied on total",
                                          Colors.green.shade800,
                                          Icons.check,
                                        );

                                        log("[PROMO] === Flat Discount Promo Completed (cart-level) ===");
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        return; // Stop here, skip normal flow
                                      }

                                      // ---------------- Normal Promo Flow ----------------

                                      final currentTotal =
                                          computeSelectedTotal();

                                      // Validate min order
                                      if (minOrderValue != null &&
                                          currentTotal < minOrderValue) {
                                        showCustomToastDisplay(
                                          context,
                                          'Minimum order is $minOrderAmountFormatted. Selected total is ${formatAmount(currentTotal.toString())}.',
                                          Colors.orange,
                                          Icons.warning,
                                        );
                                        return;
                                      }

                                      // Tier validation for tiered_discount
                                      if (promo.promoType ==
                                              "tiered_discount" &&
                                          selectedTier.value == null) {
                                        showCustomToastDisplay(
                                          context,
                                          "Please select a tier discount",
                                          Colors.orange,
                                          Icons.warning,
                                        );
                                        return;
                                      }

                                      // Add selected items normally
                                      for (final e in selectedItems) {
                                        final Detail detail =
                                            e['detail'] as Detail;
                                        final int qty = e['quantity'] as int;
                                        final bool isPack = e['isPack'] as bool;
                                        final String productName =
                                            (e['productName'] as String?) ?? '';
                                        final String inclTax =
                                            (e['inclTax'] as String?) ?? '';
                                        final int catId =
                                            (e['catId'] as int?) ?? 0;

                                        await _addToCartWithPromoLogic(
                                          customerId: customerId,
                                          localCount: qty,
                                          detail: detail,
                                          isPack: isPack,
                                          productName: productName,
                                          inclTax: inclTax,
                                          catId: catId,
                                          promo: promo,
                                          productController: productController,
                                          context: context,
                                          selectedTier: selectedTier.value,
                                        );
                                      }

                                      // Refresh cart counts
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        final cartProvider =
                                            Provider.of<CustomersProvider>(
                                                context,
                                                listen: false);
                                        cartProvider
                                            .updateCartCount(customerId);
                                        cartProvider
                                            .getCartItemCounts(customerId);
                                      });

                                      Navigator.pop(context);
                                      Navigator.pop(context);

                                      parentSetState(() {
                                        selectedItems.clear();
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryButtonColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: fullScreenWidth(context) * 0.04,
                                  vertical: fullScreenHeight(context) * 0.01,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomText(
                                    content: "Add to Cart",
                                    fontSize: fullScreenWidth(context) * 0.02,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: fullScreenWidth(context) * 0.02,
                                  ),
                                  Icon(
                                    Icons.shopping_bag,
                                    size: fullScreenWidth(context) * 0.03,
                                    color: white,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildPromotionDetails(PromotionReponse promo) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ Show Bundle Items for product_bundle
          if (promo.promoType == "product_bundle" &&
              promo.bundleItems != null &&
              promo.bundleItems!.isNotEmpty) ...[
            const Text(
              "Bundle Items:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...promo.bundleItems!.map((bundleItem) {
              // Find the corresponding product variant
              Product? product;
              try {
                product = promo.products?.firstWhere(
                  (p) => p.id == bundleItem.variantId,
                );
              } catch (e) {
                product = null;
              }

              if (product?.variants?.isNotEmpty == true) {
                final variant = product!.variants!.first;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: ClipOval(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CachedNetworkImage(
                        imageUrl:
                            '${ApiConstants.imageBaseUrl}/${variant.imageUrl}',
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: CircleAvatar(
                              radius: 10, child: CircularProgressIndicator()),
                        ),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/images/Image-not-found.png'),
                      ),
                    ),
                  ),
                  title: Text(variant.productName ?? "-"),
                  subtitle: Text(
                      "${variant.variationName ?? "-"} • Qty: ${bundleItem.quantity} ${bundleItem.unitType}"),
                  trailing: Text(
                    formatAmount(variant.sellPrice ?? '0'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),
            const Divider(),
          ],

          /// ✅ Show Applicable Products
          if (promo.productScope == "products" &&
              promo.products != null &&
              promo.products!.isNotEmpty) ...[
            const Text(
              "Applicable Products:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...promo.products!.map((product) {
              if (product.variants == null || product.variants!.isEmpty) {
                return const SizedBox();
              }

              return Column(
                children: product.variants!.map((variant) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: ClipOval(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CachedNetworkImage(
                          imageUrl:
                              '${ApiConstants.imageBaseUrl}/${variant.imageUrl}',
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CircleAvatar(
                                radius: 10, child: CircularProgressIndicator()),
                          ),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/Image-not-found.png'),
                        ),
                      ),
                    ),
                    // const Icon(Icons.shopping_bag, size: 40),
                    title: Text(variant.productName ?? "-"),
                    subtitle: Text(variant.variationName ?? "-"),
                  );
                }).toList(),
              );
            }),
            const Divider(),
          ],
        ],
      ),
    );
  }

  /// Promotion Type + Status pills
  Widget _buildTypeAndStatus(PromotionReponse promo) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        spacing: 12,
        children: [
          // Promotion type pill
          _buildPromoCode(promo),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: primaryColor,
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 225, 228, 255),
                    Color.fromARGB(255, 216, 220, 255),
                  ],
                ),
              ),
              child: Text(
                promo.promoType!.nkStringCleanAndCapitalize,
                style: const TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(PromotionReponse promo) {
    return PromoStatusChip(promo: promo);
  }

  Widget _buildPromoCode(PromotionReponse promo) {
    return Row(
      spacing: 12,
      children: [
        // Promo code pill
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.green.shade400,
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Code : ${promo.promoCode}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Discount / Scope / Target / Extra Info
  Widget _buildDiscountScopeTarget(PromotionReponse promo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blueGrey.shade50,
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow("OFFER : ", promo.discountText),
            const Divider(color: Colors.grey),
            _buildRow("APPLICABLE : ", promo.scopeText),
            const Divider(color: Colors.grey),
            _buildRow("TARGET : ", promo.targetText),

            // Min order (if available)
            if (promo.minOrderValue != null) ...[
              const Divider(color: Colors.grey),
              _buildRow("MIN ORDER : ", formatAmount(promo.minOrderValue)),
            ],

            // Bundle price for product_bundle
            if (promo.promoType == "product_bundle" &&
                promo.bundlePrice != null) ...[
              const Divider(color: Colors.grey),
              _buildRow("BUNDLE PRICE : ", formatAmount(promo.bundlePrice)),
            ],

            // Extra info (tiers / bundle items)
            if (promo.extraInfoText != null) ...[
              const Divider(color: Colors.grey),
              _buildRow(
                promo.promoType == "tiered_discount"
                    ? "TIERS : "
                    : promo.promoType == "product_bundle"
                        ? "ITEMS : "
                        : "EXTRA : ",
                promo.extraInfoText.toString(),
              ),
            ],

            // Days (for happy_hours)
            if (promo.daysText != null && promo.daysText != '') ...[
              const Divider(color: Colors.grey),
              _buildRow("DAYS : ", promo.daysText!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              color: black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class PromoStatusChip extends StatefulWidget {
  final PromotionReponse promo;

  const PromoStatusChip({super.key, required this.promo});

  @override
  State<PromoStatusChip> createState() => _PromoStatusChipState();
}

class _PromoStatusChipState extends State<PromoStatusChip>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final statusText =
        widget.promo.status?.nkStringCapitalizeFirstCaracter ?? "Inactive";

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.green.shade400,
        ),
        padding: const EdgeInsets.all(2),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: _expanded ? 16 : 10,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromARGB(255, 203, 255, 205),
                  Color.fromARGB(255, 185, 255, 187),
                ],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 5,
                ),
                if (_expanded) ...[
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extracts the numeric categoryId (everything after 'C' before 'SC')
int extractCategoryId(String productId) {
  final scIndex = productId.indexOf("SC");
  if (scIndex == -1 || !productId.startsWith("C")) {
    throw ArgumentError("Invalid productId: $productId");
  }
  final categoryPart = productId.substring(1, scIndex); // skip 'C'
  return int.tryParse(categoryPart) ??
      (throw ArgumentError("Invalid category number in: $productId"));
}

/// Extract subCategoryId dynamically (everything before "PD")
String extractSubCategoryId(String productId) {
  final pdIndex = productId.indexOf("PD");
  if (pdIndex == -1) {
    throw ArgumentError("Invalid productId: missing PD → $productId");
  }
  return productId.substring(0, pdIndex);
}
