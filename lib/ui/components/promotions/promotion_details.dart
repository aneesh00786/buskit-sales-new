import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_screen.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
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
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: InkWell(
                          onTap: () async {
                            if ((customerAndOrderController
                                    .customerId.value.isNotEmpty) ||
                                (productController
                                    .selectedCustomerName.value.isNotEmpty)) {
                              showCustomToastDisplay(
                                  context,
                                  "ADD TO CART - ${promo.promoType?.nkStringCleanAndCapitalize} [${promo.promoCode}]",
                                  Colors.green.shade800,
                                  Icons.check);
                              // _showPromoDialog(context, promo);

                              // ---------------------------------------------------------------------------------------------------

                              final customerId = customerAndOrderController
                                      .customerId.value.isNotEmpty
                                  ? customerAndOrderController.customerId.value
                                  : productController.selectedCustomerId.value;

                              // --- Percentage Discount based promos ---
                              if (promo.promoType == "percentage_discount" ||
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
                                    : double.tryParse(
                                        promo.discountPercentage.toString());

                                log("[PROMO] Promo Discount: $discountValue");

                                // Flatten all product variants into one list
                                final allVariants = promo.products
                                        ?.expand((p) => p.variants ?? [])
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
                                    sellPrice: (v.sellPrice ?? '0').toString(),
                                    tax: double.tryParse(v.tax ?? '0') ?? 0,
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

                                  final bool isPack = detail.saleBy == 'Pack';
                                  log("[PROMO] IsPack? $isPack");

                                  final catId =
                                      extractCategoryId(v.productId.toString());
                                  log("[PROMO] Extracted CategoryId: $catId from productId: ${v.productId}");

                                  await CartDatabaseManager().addToCartPromo(
                                    customerId: customerId,
                                    localCount: 1,
                                    detail: detail,
                                    isPack: true,
                                    productName: v.productName ?? '',
                                    inclTax: v.tax ?? '',
                                    isChcked: true,
                                    catId: catId,
                                    promoCode: promo.promoCode,
                                  );

                                  log("[PROMO] ✅ Added to cart → variationId: ${detail.variationId}, customerId: $customerId");
                                  productController.isCartModified.value = true;
                                }

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  final cartProvider =
                                      Provider.of<CustomersProvider>(context,
                                          listen: false);
                                  log("[PROMO] Updating cart count for customer: $customerId");
                                  cartProvider.updateCartCount(customerId);
                                  cartProvider.getCartItemCounts(customerId);
                                });

                                log("[PROMO] === Percentage Discount Promo Completed ===");
                              }

                              // --- Free Item promos ---
                              if (promo.promoType == "free_gift" ||
                                  promo.promoType == "free_sample") {
                                log("[PROMO] === Free Item Promo Started ===");
                                log("[PROMO] Promo details: ${promo.toJson()}");

                                final allVariants = promo.products
                                        ?.expand((p) => p.variants ?? [])
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

                                for (final v in allVariants) {
                                  log("[PROMO] Processing variant → ID: ${v.id}, ProductId: ${v.productId}, "
                                      "Name: ${v.productName}, SellPrice: ${v.sellPrice}, Tax: ${v.tax}");

                                  final detail = Detail(
                                    variationId: v.id,
                                    productId: v.productId,
                                    variationName: v.variationName,
                                    unitType: v.unitType,
                                    price: (v.price ?? '0').toString(),
                                    sellPrice: (v.sellPrice ?? '0').toString(),
                                    tax: double.tryParse(v.tax ?? '0') ?? 0,
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

                                  final bool isPack = detail.saleBy == 'Pack';
                                  log("[PROMO] IsPack? $isPack");

                                  final catId =
                                      extractCategoryId(v.productId.toString());
                                  log("[PROMO] Extracted CategoryId: $catId from productId: ${v.productId}");

                                  await CartDatabaseManager().addToCartPromo(
                                    customerId: customerId,
                                    localCount: 1,
                                    detail: detail,
                                    isPack: true,
                                    productName: v.productName ?? '',
                                    inclTax: v.tax ?? '',
                                    isChcked: true,
                                    catId: catId,
                                    promoCode: promo.promoCode,
                                  );

                                  log("[PROMO] ✅ Added to cart → variationId: ${detail.variationId}, customerId: $customerId");
                                  productController.isCartModified.value = true;
                                }

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  final cartProvider =
                                      Provider.of<CustomersProvider>(context,
                                          listen: false);
                                  log("[PROMO] Updating cart count for customer: $customerId");
                                  cartProvider.updateCartCount(customerId);
                                  cartProvider.getCartItemCounts(customerId);
                                });

                                log("[PROMO] === Free Item Promo Completed ===");
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
                                            content: "Ok", color: primaryColor),
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
                      ),
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
