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
                      if (promo.productScope == "products") ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Builder(builder: (context) {
                            final ValueNotifier<int> qty =
                                ValueNotifier<int>(1);

                            double? _parseAmount(String? s) {
                              if (s == null || s.isEmpty) return null;
                              final cleaned =
                                  s.replaceAll(RegExp(r'[^0-9\.]'), '');
                              return double.tryParse(cleaned);
                            }

                            Future<bool> _validateMinOrderBeforeAdd(
                                List<dynamic> allVariants) async {
                              final double? minOrder =
                                  _parseAmount(promo.minOrderValue?.toString());
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

                            // Flattened variants for total calculation
                            final List<dynamic> _allVariantsStatic = promo
                                    .products
                                    ?.expand((p) => p.variants ?? [])
                                    .toList() ??
                                [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Total above quantity selector
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: qty,
                                    builder: (context, value, _) {
                                      double unitSum = 0;
                                      for (final v in _allVariantsStatic) {
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
                                const SizedBox(height: 8),
                                // Quantity selector
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
                                              if (qty.value > 1)
                                                qty.value = qty.value - 1;
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
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () async {
                                    if ((customerAndOrderController
                                            .customerId.value.isNotEmpty) ||
                                        (productController.selectedCustomerName
                                            .value.isNotEmpty)) {
                                      showCustomToastDisplay(
                                          context,
                                          "ADD TO CART - ${promo.promoType?.nkStringCleanAndCapitalize} [${promo.promoCode}]",
                                          Colors.green.shade800,
                                          Icons.check);
                                      // _showPromoDialog(context, promo);

                                      // ---------------------------------------------------------------------------------------------------

                                      final customerId =
                                          customerAndOrderController
                                                  .customerId.value.isNotEmpty
                                              ? customerAndOrderController
                                                  .customerId.value
                                              : productController
                                                  .selectedCustomerId.value;

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
                                            await _validateMinOrderBeforeAdd(
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
                                            await _validateMinOrderBeforeAdd(
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
                                            await _validateMinOrderBeforeAdd(
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
                                            await _validateMinOrderBeforeAdd(
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
                      if (promo.productScope != "products") ...[
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

  void _showPromoDialog(BuildContext context, PromotionReponse promo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(promo.title ?? "Promotion"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Always show the main offer text
                  Text(
                    promo.discountText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Scope (only if not "All Products")
                  if (promo.productScope != "all") ...[
                    Text("Applicable For: ${promo.scopeText}"),
                    const SizedBox(height: 8),
                  ],

                  /// Min order value (if defined)
                  if (promo.minOrderText != null) ...[
                    Text("Minimum Order: ${promo.minOrderText}"),
                    const SizedBox(height: 8),
                  ],

                  /// Time-based conditions
                  if (promo.daysText != null)
                    Text("Valid on: ${promo.daysText}"),
                  if (promo.promoType == "happy_hours" &&
                      promo.startTime != null &&
                      promo.endTime != null) ...[
                    Text("Timing: ${promo.startTime} - ${promo.endTime}"),
                    const SizedBox(height: 8),
                  ],
                  if (promo.promoType == "flash_sale" &&
                      promo.saleDuration != null)
                    Text("Duration: ${promo.saleDuration} minutes"),
                  if (promo.promoType == "limited_time" &&
                      promo.offerDuration != null)
                    Text("Duration: ${promo.offerDuration} hours"),

                  /// Applicable products (only if present)
                  if (promo.products != null && promo.products!.isNotEmpty) ...[
                    const Divider(),
                    const Text("Products:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...promo.products!.map((p) {
                      final variant = p.variants?.isNotEmpty == true
                          ? p.variants!.first
                          : null;
                      return ListTile(
                        dense: true,
                        title: Text(variant?.productName ?? "Unknown"),
                        subtitle: Text(variant?.variationName ?? ""),
                      );
                    }).toList(),
                  ],

                  /// Free items (gift / sample)
                  if (promo.freeItems != null &&
                      promo.freeItems!.isNotEmpty) ...[
                    const Divider(),
                    const Text("Free Item:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...promo.freeItems!.map((f) =>
                        Text("${f.giftName ?? f.sampleDetails ?? 'Item'} "
                            "(Qty: ${f.quantity} ${f.quantityType})")),
                  ],

                  /// Bundle items
                  if (promo.bundleItems != null &&
                      promo.bundleItems!.isNotEmpty) ...[
                    const Divider(),
                    Text("Bundle Price: \$${promo.bundlePrice ?? ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...promo.bundleItems!.map((item) {
                      final product = promo.products?.firstWhere(
                        (p) => p.id == item.variantId,
                      );
                      final variant = product?.variants?.isNotEmpty == true
                          ? product?.variants!.first
                          : null;
                      return ListTile(
                        dense: true,
                        title: Text(variant?.productName ?? "Unknown"),
                        subtitle: Text(
                            "${variant?.variationName ?? ""} x ${item.quantity} ${item.unitType}"),
                      );
                    }).toList(),
                  ],

                  /// Tiered discount details
                  if (promo.extraInfoText != null) ...[
                    const Divider(),
                    const Text("Discount Tiers:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(promo.extraInfoText!),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Apply offer logic
              },
              child: const Text("Apply Offer"),
            ),
          ],
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
    final double _drawerWidth = 300.0;
    final ProductsController productController = Get.find<ProductsController>();
    final CustomerAndOrderController customerAndOrderController =
        Get.find<CustomerAndOrderController>();

    showDialog(
      context: context,
      builder: (context) {
        bool _isDrawerOpen = true;
        String _selectedCategory = '';
        String _selectedOption = '';
        String _id = '';
        Timer? _drawerTimer;
        List<Map<String, dynamic>> _selectedItems = [];

        // Pre-select first category + subcategory
        if (categoryData.data != null && categoryData.data!.isNotEmpty) {
          final firstCategory = categoryData.data![0];
          _selectedCategory = firstCategory.categoryName ?? '';
          if (firstCategory.subCategoryItem != null &&
              firstCategory.subCategoryItem!.isNotEmpty) {
            final firstSub = firstCategory.subCategoryItem![0];
            _id = firstSub.id ?? '';
            _selectedOption = firstSub.subCategory ?? '';
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
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

            void _toggleDrawer() {
              setState(() => _isDrawerOpen = !_isDrawerOpen);

              _drawerTimer?.cancel();
              if (_isDrawerOpen) {
                _drawerTimer = Timer(const Duration(seconds: 3), () {
                  setState(() => _isDrawerOpen = false);
                });
              }
            }

            void _selectCategory(String categoryName) {
              setState(() {
                _selectedCategory = categoryName;

                // Auto-select first subcategory of the new category
                final category = categoryData.data!
                    .firstWhere((c) => c.categoryName == categoryName);
                if (category.subCategoryItem != null &&
                    category.subCategoryItem!.isNotEmpty) {
                  final firstSub = category.subCategoryItem![0];
                  _id = firstSub.id ?? '';
                  _selectedOption = firstSub.subCategory ?? '';
                }
              });
            }

            void _fetchProductsByCategory(String subCategoryId) {
              setState(() {
                _id = subCategoryId;
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
                                  _selectedItems,
                                  productController,
                                  customerAndOrderController,
                                  minOrderAmount,
                                  promo.promoCode,
                                  promo.discountText,
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
                                  if (_selectedItems.isNotEmpty)
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
                                          '${_selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
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
                                  _selectedItems,
                                  productController,
                                  customerAndOrderController,
                                  minOrderAmount,
                                  promo.promoCode,
                                  promo.discountText,
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
                                optionName: _selectedOption,
                                productsController: productController,
                                id: _id,
                                playAddToCartAnimation: playAddToCartAnimation,
                                categoryData: categoryData,
                                onVariantsSelected: (selections) {
                                  // Merge selections into _selectedItems (by variationId + isPack)
                                  setState(() {
                                    for (final s in selections) {
                                      final Detail d = s['detail'] as Detail;
                                      final int qty = s['quantity'] as int;
                                      final bool isPack = s['isPack'] as bool;
                                      final String key =
                                          '${d.variationId}_${isPack ? 'P' : 'U'}';
                                      final idx =
                                          _selectedItems.indexWhere((e) {
                                        final Detail ed = e['detail'] as Detail;
                                        final bool eIsPack =
                                            e['isPack'] as bool;
                                        return ed.variationId ==
                                                d.variationId &&
                                            eIsPack == isPack;
                                      });
                                      if (idx >= 0) {
                                        _selectedItems[idx]['quantity'] =
                                            (_selectedItems[idx]['quantity']
                                                    as int) +
                                                qty;
                                      } else {
                                        _selectedItems.add(s);
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
                              onPressed: _toggleDrawer,
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
                                          _selectCategory(categoryName),
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
                  if (_isDrawerOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isDrawerOpen = false);
                          _drawerTimer?.cancel();
                        },
                        child: Container(color: Colors.transparent),
                      ),
                    ),

                  /// Slide-out category drawer
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: 10,
                    bottom: 0,
                    left: _isDrawerOpen ? 50 : -_drawerWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Container(
                        width: _drawerWidth,
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
                            _fetchProductsByCategory(selectedSubcategoryId);
                          },
                          onDrawerToggle: _toggleDrawer,
                          selectedCategory: _selectedCategory,
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
    String? promoCode,
    String? promoMsg,
  ) {
    double? _parseAmount(String? s) {
      if (s == null || s.isEmpty) return null;
      final cleaned = s.replaceAll(RegExp(r'[^0-9\.]'), '');
      return double.tryParse(cleaned);
    }

    double _priceForItem(Map<String, dynamic> e) {
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

    double _computeSelectedTotal() {
      double total = 0;
      for (final e in selectedItems) {
        final int qty = (e['quantity'] as int);
        total += _priceForItem(e) * qty;
      }
      return total;
    }

    final double? _minOrderValue = _parseAmount(minOrderAmountFormatted);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
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
                                final total = _computeSelectedTotal();
                                return Text(
                                  formatAmount(total.toString()),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                );
                              },
                            ),
                          ],
                        ),
                        if (_minOrderValue != null) ...[
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
                                      final currentTotal =
                                          _computeSelectedTotal();
                                      if (_minOrderValue != null &&
                                          currentTotal < _minOrderValue) {
                                        showCustomToastDisplay(
                                          context,
                                          'Minimum order is $minOrderAmountFormatted. Selected total is ${formatAmount(currentTotal.toString())}.',
                                          Colors.orange,
                                          Icons.warning,
                                        );
                                        return;
                                      }
                                      final customerId =
                                          customerAndOrderController
                                                  .customerId.value.isNotEmpty
                                              ? customerAndOrderController
                                                  .customerId.value
                                              : productController
                                                  .selectedCustomerId.value;

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

                                        await CartDatabaseManager()
                                            .addToCartPromo(
                                          customerId: customerId,
                                          localCount: qty,
                                          detail: detail,
                                          isPack: isPack,
                                          productName: productName,
                                          inclTax: inclTax,
                                          isChcked: true,
                                          catId: catId,
                                          promoCode: promoCode,
                                          promoMsg: promoMsg,
                                        );
                                        productController.isCartModified.value =
                                            true;
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
                                    content: "Add to Selection",
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
            }).toList(),
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
                promo.promoType!.nkStringCleanAndCapitalize ?? "Promotion",
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
