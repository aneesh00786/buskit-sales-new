import 'dart:async';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_screen.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_category_list.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_product_list.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_product_list_by_brand.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_status_chip.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class PromotionDetails extends StatefulWidget {
  final ProductsController controller;

  const PromotionDetails({super.key, required this.controller});

  @override
  State<PromotionDetails> createState() => _PromotionDetailsState();
}

class _PromotionDetailsState extends State<PromotionDetails> {
  @override
  void initState() {
    super.initState();

    widget.controller.selectedPromotion.value = null;
  }

  @override
  Widget build(BuildContext context) {
    CustomerAndOrderController customerAndOrderController =
        Get.find<CustomerAndOrderController>();
    ProductsController productController = Get.find<ProductsController>();

    return Obx(() {
      final promo = widget.controller.selectedPromotion.value;

      if (promo == null) {
        return const Center(
          child: Text("Select a promotion to see details"),
        );
      }

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF2D3748)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_offer_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      promo.title ?? "Untitled".tr,
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    /// Description + status chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              (promo.description == null ||
                                      promo.description!.isEmpty)
                                  ? "No description".tr
                                  : promo.description!,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_isPromoOutOfStock(promo)) ...[
                            const PromoStockStatusChip(),
                            const SizedBox(width: 8), // Spacing between chips
                          ],
                          _buildStatus(promo),
                        ],
                      ),
                    ),

                    buildPromotionDetails(promo),
                    // if (_isPromoOutOfStock(promo))
                    //    Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    //     child: Text(
                    //       "OUT OF STOCK".tr,
                    //       style: const TextStyle(
                    //         color: Colors.red,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),

                    /// Type + Status pills
                    _buildTypeAndStatus(promo),
                    // _buildPromoCode(promo),

                    /// Discount / Scope / Target
                    _buildDiscountScopeTarget(promo),

                    /// Expiry
                    const SizedBox(
                      height: 24,
                    ),
                    if (promo.startDate != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Text(
                          "Started: ${NKDateUtils.commonDayFormat(NKDateUtils.formatStringUTCDateTime(promo.startDate.toString()))}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Text(
                        promo.endDate == null
                            ? "Expiry: N/A".tr
                            : 'Expiry:'.tr +
                                ' ${NKDateUtils.commonDayFormat(NKDateUtils.formatStringUTCDateTime(promo.endDate.toString()))}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),

                    /// Add to cart button
                    const SizedBox(height: 20),

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
                                            padding: const EdgeInsets.symmetric(
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
                                  List<Map<String, dynamic>> itemsToCheck = [];
                                  if (promo.bundleItems != null) {
                                    for (final bundleItem
                                        in promo.bundleItems!) {
                                      Product? promoProduct;
                                      try {
                                        promoProduct = promo.products
                                            ?.firstWhere((p) =>
                                                p.id == bundleItem.variantId);
                                      } catch (e) {}
                                      if (promoProduct?.variants?.isNotEmpty ==
                                          true) {
                                        final variant =
                                            promoProduct!.variants!.first;
                                        itemsToCheck.add({
                                          'name': variant.productName ??
                                              'Bundle Item',
                                          'quantity': bundleQty.value *
                                              (bundleItem.quantity ?? 1),
                                          'stock': (variant.stock as num?)
                                                  ?.toInt() ??
                                              0,
                                        });
                                      }
                                    }
                                  }
                                  if (!await _checkStockAndShowPopup(
                                      context, itemsToCheck)) return;
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

                                    // 1. Initialize total tax variable for the bundle
                                    double totalBundleCatTax = 0.0;

                                    // Initialize detailed bundle message
                                    String bundleDetailsMsg =
                                        "Bundle: ${promo.title}\n\n";

                                    if (promo.bundleItems != null &&
                                        promo.bundleItems!.isNotEmpty) {
                                      bundleDetailsMsg += "Items included:\n";

                                      for (final bundleItem
                                          in promo.bundleItems!) {
                                        // --- A. Find variant info for names/prices (from Promo Object) ---
                                        Product? promoProduct;
                                        try {
                                          promoProduct =
                                              promo.products?.firstWhere(
                                            (p) => p.id == bundleItem.variantId,
                                          );
                                        } catch (e) {
                                          promoProduct = null;
                                        }

                                        // --- B. LOOKUP CAT_TAX FROM CONTROLLER (products list) ---
                                        double itemCatTax = 0.0;

                                        try {
                                          // Use 'products' list from your controller
                                          final productModelInstance = widget
                                              .controller.products
                                              .firstWhere(
                                            (p) =>
                                                p.productId ==
                                                bundleItem.productId,
                                            // Fallback to a dummy model with 0 tax if not found
                                            orElse: () =>
                                                ProductModel(catTax: 0),
                                          );

                                          // Extract the tax safely
                                          itemCatTax =
                                              (productModelInstance.catTax ?? 0)
                                                  .toDouble();
                                        } catch (e) {
                                          print(
                                              "Error finding product model in controller list: $e");
                                        }

                                        // --- C. Calculate Totals & Build Message ---
                                        if (promoProduct
                                                ?.variants?.isNotEmpty ==
                                            true) {
                                          final variant =
                                              promoProduct!.variants!.first;
                                          final unitPrice = double.tryParse(
                                                  variant.sellPrice
                                                          ?.toString() ??
                                                      '0') ??
                                              0;
                                          final qty = bundleItem.quantity ?? 1;
                                          final totalPrice = unitPrice * qty;

                                          // Add to total bundle tax: (Item Tax * Quantity)
                                          totalBundleCatTax +=
                                              (itemCatTax * qty);

                                          // Append details to message string
                                          bundleDetailsMsg +=
                                              "• ${variant.productName ?? 'Unknown'} (${variant.variationName ?? ''})\n";
                                          bundleDetailsMsg +=
                                              "  Qty: $qty ${bundleItem.unitType}\n";
                                          bundleDetailsMsg +=
                                              "  Price: ${formatAmount(unitPrice.toString())} each\n";
                                          bundleDetailsMsg +=
                                              "  Total: ${formatAmount(totalPrice.toString())}\n";
                                          // Optional: You can remove this line from the user-facing message if you prefer
                                          // bundleDetailsMsg += "  Cat Tax (est): $itemCatTax\n\n";
                                        }
                                      }
                                      bundleDetailsMsg +=
                                          "Bundle Price: ${formatAmount(promo.bundlePrice)}";
                                    }

                                    // --- 2. CREATE BUNDLE DETAIL ---
                                    final bundleDetail = Detail(
                                      variationId: "BUNDLE_${promo.id}",
                                      productId: "BUNDLE_${promo.id}",
                                      variationName: promo.title ?? "Bundle",
                                      unitType: "bundle",
                                      price:
                                          promo.bundlePrice?.toString() ?? "0",
                                      sellPrice:
                                          promo.bundlePrice?.toString() ?? "0",
                                      tax:
                                          totalBundleCatTax, // Assign the calculated total tax here
                                      packtype: "bundle",
                                      pieces: 1,
                                      stock: 999,
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

                                    const catId = 0; // Special ID for bundles

                                    print(
                                        'Total Calculated Bundle Tax: $totalBundleCatTax');

                                    // --- 3. ADD TO CART ---
                                    await CartDatabaseManager().addToCartPromo(
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
                                      catTax:
                                          totalBundleCatTax, // Pass the calculated value to your DB manager
                                    );

                                    // --- 4. SUCCESS FEEDBACK ---
                                    showCustomToastDisplay(
                                      context,
                                      "Bundle added to cart",
                                      Colors.green.shade800,
                                      Icons.check,
                                    );

                                    // Update cart counts and close
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
                                  }
                                },
                                // onTap: () async {
                                //   if ((customerAndOrderController
                                //           .customerId.value.isNotEmpty) ||
                                //       (productController.selectedCustomerName
                                //           .value.isNotEmpty)) {
                                //     final customerId =
                                //         customerAndOrderController
                                //                 .customerId.value.isNotEmpty
                                //             ? customerAndOrderController
                                //                 .customerId.value
                                //             : productController
                                //                 .selectedCustomerId.value;

                                //     // Create a special bundle detail with bundle price
                                //     final bundleDetail = Detail(
                                //       variationId:
                                //           "BUNDLE_${promo.id}", // Special bundle ID
                                //       productId: "BUNDLE_${promo.id}",
                                //       variationName: promo.title ?? "Bundle",
                                //       unitType: "bundle",
                                //       price: promo.bundlePrice?.toString() ??
                                //           "0",
                                //       sellPrice:
                                //           promo.bundlePrice?.toString() ??
                                //               "0",
                                //       tax: 0, // Bundle tax handled separately
                                //       packtype: "bundle",
                                //       pieces: 1,
                                //       stock: 999, // High stock for bundles
                                //       lowstock: 0,
                                //       fullstock: 999,
                                //       imageUrl:
                                //           promo.products?.isNotEmpty == true
                                //               ? promo.products![0].variants
                                //                           ?.isNotEmpty ==
                                //                       true
                                //                   ? promo.products![0]
                                //                       .variants![0].imageUrl
                                //                   : null
                                //               : null,
                                //       productName: promo.title ?? "Bundle",
                                //     );

                                //     const catId =
                                //         0; // Special category for bundles

                                //     // Create detailed bundle message with all items
                                //     String bundleDetailsMsg =
                                //         "Bundle: ${promo.title}\n\n";
                                //     if (promo.bundleItems != null &&
                                //         promo.bundleItems!.isNotEmpty) {
                                //       bundleDetailsMsg += "Items included:\n";
                                //       for (final bundleItem
                                //           in promo.bundleItems!) {
                                //         // Find the corresponding product variant
                                //         Product? product;
                                //         try {
                                //           product =
                                //               promo.products?.firstWhere(
                                //             (p) =>
                                //                 p.id == bundleItem.variantId,
                                //           );
                                //         } catch (e) {
                                //           product = null;
                                //         }

                                //         if (product?.variants?.isNotEmpty ==
                                //             true) {
                                //           final variant =
                                //               product!.variants!.first;
                                //           final unitPrice = double.tryParse(
                                //                   variant.sellPrice
                                //                           ?.toString() ??
                                //                       '0') ??
                                //               0;
                                //           final totalPrice = unitPrice *
                                //               (bundleItem.quantity ?? 1);

                                //           bundleDetailsMsg +=
                                //               "• ${variant.productName ?? 'Unknown'} (${variant.variationName ?? ''})\n";
                                //           bundleDetailsMsg +=
                                //               "  Qty: ${bundleItem.quantity} ${bundleItem.unitType}\n";
                                //           bundleDetailsMsg +=
                                //               "  Price: ${formatAmount(unitPrice.toString())} each\n";
                                //           bundleDetailsMsg +=
                                //               "  Total: ${formatAmount(totalPrice.toString())}\n";
                                //           bundleDetailsMsg +=
                                //               "  Variant Id: ${variant.id}\n\n";
                                //         }
                                //       }
                                //       bundleDetailsMsg +=
                                //           "Bundle Price: ${formatAmount(promo.bundlePrice)}";
                                //     }

                                //     await CartDatabaseManager()
                                //         .addToCartPromo(
                                //       customerId: customerId,
                                //       localCount: bundleQty.value,
                                //       detail: bundleDetail,
                                //       isPack: true,
                                //       productName: promo.title ?? "Bundle",
                                //       inclTax: "0",
                                //       isChcked: true,
                                //       catId: catId,
                                //       promoCode: promo.promoCode,
                                //       promoMsg: bundleDetailsMsg,
                                //     );

                                //     productController.isCartModified.value =
                                //         true;

                                //     WidgetsBinding.instance
                                //         .addPostFrameCallback((_) {
                                //       final cartProvider =
                                //           Provider.of<CustomersProvider>(
                                //               context,
                                //               listen: false);
                                //       cartProvider
                                //           .updateCartCount(customerId);
                                //       cartProvider
                                //           .getCartItemCounts(customerId);
                                //     });

                                //     showCustomToastDisplay(
                                //       context,
                                //       "Bundle added to cart",
                                //       Colors.green.shade800,
                                //       Icons.check,
                                //     );
                                //   } else {
                                //     showDialog(
                                //       barrierDismissible: false,
                                //       context: context,
                                //       builder: (context) {
                                //         return AlertDialog(
                                //           actions: [
                                //             const SizedBox(height: 20),
                                //             const Center(
                                //                 child: Icon(
                                //                     Icons
                                //                         .warning_amber_outlined,
                                //                     size: 50,
                                //                     color: Colors.orange)),
                                //             const SizedBox(height: 20),
                                //             Center(
                                //                 child: CustomText(
                                //                     content:
                                //                         "Please Select a Customer",
                                //                     fontSize: 18)),
                                //             TextButton(
                                //               onPressed: () =>
                                //                   Navigator.pop(context),
                                //               child: CustomText(
                                //                   content: "Ok",
                                //                   color: primaryColor),
                                //             ),
                                //           ],
                                //         );
                                //       },
                                //     );
                                //   }
                                // },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: primaryColor,
                                  ),
                                  child: const Center(
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
                          final List<dynamic> allVariantsStatic = promo.products
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
                                    "Select Products & Quantities".tr,
                                    style: const TextStyle(
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
                          final ValueNotifier<int> qty = ValueNotifier<int>(1);
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

                            for (final v in allVariants) {
                              final double unit = double.tryParse(
                                      (v.sellPrice ?? '0').toString()) ??
                                  0;
                              final int pcs = (v.pieces ?? 1).toInt();
                              final double itemTotal =
                                  (unit * pcs) * (qty.value);

                              // Check if this specific item meets the minimum
                              if (itemTotal < minOrder) {
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
                                                    "Minimum order for ${v.productName} is ${formatAmount(promo.minOrderValue)}",
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
                            }
                            return true;
                          }

                          // Future<bool> validateMinOrderBeforeAdd(
                          //     List<dynamic> allVariants) async {
                          //   final double? minOrder =
                          //       parseAmount(promo.minOrderValue?.toString());
                          //   if (minOrder == null) return true;
                          //   double total = 0;
                          //   for (final v in allVariants) {
                          //     // Since addToCart uses isPack: true, use unit * pieces
                          //     final double unit = double.tryParse(
                          //             (v.sellPrice ?? '0').toString()) ??
                          //         0;
                          //     final int pcs = (v.pieces ?? 1).toInt();
                          //     total += (unit * pcs) * (qty.value);
                          //   }
                          //   if (total < minOrder) {
                          //     await showDialog(
                          //       context: context,
                          //       barrierDismissible: false,
                          //       builder: (context) {
                          //         return AlertDialog(
                          //           actions: [
                          //             const SizedBox(height: 20),
                          //             const Center(
                          //                 child: Icon(
                          //                     Icons.warning_amber_outlined,
                          //                     size: 50,
                          //                     color: Colors.orange)),
                          //             const SizedBox(height: 20),
                          //             Center(
                          //                 child: CustomText(
                          //                     content:
                          //                         "Minimum order is ${formatAmount(promo.minOrderValue)}",
                          //                     fontSize: 18)),
                          //             TextButton(
                          //               onPressed: () =>
                          //                   Navigator.pop(context),
                          //               child: CustomText(
                          //                   content: "Ok",
                          //                   color: primaryColor),
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );
                          //     return false;
                          //   }
                          //   return true;
                          // }

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
                                        borderRadius: BorderRadius.circular(10),
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
                                            hint: Text('Select Tier'.tr),
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
                                                  '$requiredQty $qtyType - ${discountValue.toStringAsFixed(0)}% off',
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
                                              print('tapped increase button');
                                              qty.value = qty.value + 1;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
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
                                      'Total:'.tr +
                                          ' ${formatAmount(total.toString())}',
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
                                    if (promo.promoType == "tiered_discount" &&
                                        selectedTier.value == null) {
                                      showCustomToastDisplay(
                                        context,
                                        "Please select a tier discount 1",
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
                                      // Decide which discount field to use
                                      final discountValue = promo.promoType ==
                                              "percentage_discount"
                                          ? double.tryParse(
                                              promo.discountValue.toString())
                                          : double.tryParse(promo
                                              .discountPercentage
                                              .toString());

                                      // Flatten all product variants into one list
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

                                      // Validate min order with selected quantity
                                      final allowed =
                                          await validateMinOrderBeforeAdd(
                                              allVariants);
                                      if (!allowed) return;
                                      List<Map<String, dynamic>> itemsToCheck =
                                          allVariants
                                              .map((v) => {
                                                    'name': v.productName ??
                                                        'Product',
                                                    'quantity': qty.value,
                                                    'stock': (v.stock as num?)
                                                            ?.toInt() ??
                                                        0,
                                                  })
                                              .toList();
                                      if (!await _checkStockAndShowPopup(
                                          context, itemsToCheck)) return;

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
                                          tax: double.tryParse(v.tax ?? '0') ??
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
                                          promoMsg: promo.discountText,
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
                                    }

                                    // --- FLAT DISCOUNT promos (cart-level fixed amount) ---

                                    if (promo.promoType == "flat_discount") {
                                      // Flatten variants
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

                                      // Validate min order with existing helper (based on selected qty)
                                      final allowed =
                                          await validateMinOrderBeforeAdd(
                                              allVariants);
                                      if (!allowed) return;
                                      List<Map<String, dynamic>> itemsToCheck =
                                          allVariants
                                              .map((v) => {
                                                    'name': v.productName ??
                                                        'Product',
                                                    'quantity': qty.value,
                                                    'stock': (v.stock as num?)
                                                            ?.toInt() ??
                                                        0,
                                                  })
                                              .toList();
                                      if (!await _checkStockAndShowPopup(
                                          context, itemsToCheck)) return;

                                      // 1) Add products normally
                                      for (final v in allVariants) {
                                        // --- A. LOOKUP CAT TAX FROM CONTROLLER LIST (No Hive) ---
                                        // We search the loaded products list to find the ProductModel instance
                                        double fetchedCatTax = 0.0;
                                        try {
                                          final productModelInstance = widget
                                              .controller.products
                                              .firstWhere(
                                            (p) => p.productId == v.productId,
                                            // Fallback to dummy model if not found
                                            orElse: () =>
                                                ProductModel(catTax: 0),
                                          );

                                          fetchedCatTax =
                                              (productModelInstance.catTax ?? 0)
                                                  .toDouble();
                                        } catch (e) {
                                          print(
                                              "[PROMO] Flat Discount - Error finding product model for ID ${v.productId}: $e");
                                        }
                                        final double flatAmount =
                                            double.tryParse(promo.discountValue
                                                        ?.toString() ??
                                                    '0') ??
                                                0;
                                        print(
                                            'flat amount in details class:$flatAmount');
                                        if (flatAmount > 0) {
                                          productController
                                                  .flatDiscountByCustomer[
                                              customerId] = flatAmount;
                                        }

                                        // --- B. Create Detail Object ---
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
                                          // You may need to assign discount here if 'flat' logic requires per-item discount field
                                        );

                                        final catId = extractCategoryId(
                                            v.productId.toString());

                                        print(
                                            'fetched cattax in flat discount: $fetchedCatTax');

                                        // --- C. Add to Cart with Tax ---
                                        await CartDatabaseManager().addToCartPromo(
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
                                            catTax: fetchedCatTax,
                                            flatDiscount: flatAmount);

                                        productController.isCartModified.value =
                                            true;
                                      }

                                      // 2) Store fixed flat discount per customer for cart total display

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
                                    }

                                    // --- Tiered Discount promos ---

                                    if (promo.promoType == "tiered_discount") {
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

                                      // Validate min order with selected quantity
                                      final allowed =
                                          await validateMinOrderBeforeAdd(
                                              allVariants);
                                      if (!allowed) return;
                                      List<Map<String, dynamic>> itemsToCheck =
                                          allVariants
                                              .map((v) => {
                                                    'name': v.productName ??
                                                        'Product',
                                                    'quantity': qty.value,
                                                    'stock': (v.stock as num?)
                                                            ?.toInt() ??
                                                        0,
                                                  })
                                              .toList();
                                      if (!await _checkStockAndShowPopup(
                                          context, itemsToCheck)) return;

                                      // Iterate through all variants in the promotion
                                      for (final v in allVariants) {
                                        double fetchedCatTax = 0.0;

                                        // A. Try finding in current loaded products (Fastest)
                                        final productModelInstance = widget
                                            .controller.products
                                            .firstWhere(
                                          (p) => p.productId == v.productId,
                                          orElse: () => ProductModel(catTax: 0),
                                        );
                                        fetchedCatTax =
                                            (productModelInstance.catTax ?? 0)
                                                .toDouble();

                                        // B. If not found or 0 (likely different category), FETCH FROM API
                                        if (fetchedCatTax == 0) {
                                          try {
                                            // 1. Extract SubCategory ID from Product ID (e.g., C49SC7)
                                            // Ensure extractSubCategoryId function is available in your file
                                            final subCatId =
                                                extractSubCategoryId(
                                                    v.productId.toString());
                                            final companyId = SessionHelper
                                                    .loginSavedData
                                                    ?.company_id ??
                                                0;

                                            print(
                                                "[PROMO] Product not in current list. Fetching from API for SCID: $subCatId");

                                            // 2. Call your API to get the real product details
                                            final remoteProducts =
                                                await ApiWorker()
                                                    .getTempProduct(subCatId,
                                                        companyid: companyId);

                                            // 3. Find the specific product in the fetched list
                                            final remoteProduct =
                                                remoteProducts.firstWhere(
                                              (p) => p.productId == v.productId,
                                              orElse: () =>
                                                  ProductModel(catTax: 0),
                                            );

                                            // 4. Update the tax
                                            fetchedCatTax =
                                                (remoteProduct.catTax ?? 0)
                                                    .toDouble();
                                            print(
                                                "[PROMO] Fetched remote tax: $fetchedCatTax");
                                          } catch (e) {
                                            print(
                                                "[PROMO] Error fetching remote tax: $e");
                                          }
                                        }
                                        log("[PROMO] Processing variant → ID: ${v.id}, ProductId: ${v.productId}, Tax Found: $fetchedCatTax");

                                        // --- 2. Calculate Tiered Discount ---
                                        double? tieredDiscount;
                                        if (promo.promoType ==
                                                "tiered_discount" &&
                                            selectedTier.value != null) {
                                          // For tiered_discount, use the selected tier's discount
                                          tieredDiscount = double.tryParse(
                                                  selectedTier
                                                          .value!.discountValue
                                                          ?.toString() ??
                                                      '0') ??
                                              0;
                                          print(
                                              'tiered discount from details class:$tieredDiscount');
                                        } else {
                                          // For other promotions, calculate based on quantity
                                          tieredDiscount =
                                              _calculateTieredDiscount(
                                                  promo, qty.value, true);
                                        }

                                        // --- 3. Extract Category ID & Customer Discounts ---
                                        final catId = extractCategoryId(
                                            v.productId.toString());
                                        final discountBox = await Hive.openBox<
                                            CustomerDiscountModel>('discounts');

                                        CustomerDiscountModel? discountData =
                                            discountBox.values.firstWhere(
                                          (item) =>
                                              item.customerId == customerId,
                                          orElse: () => CustomerDiscountModel(),
                                        );

                                        double userDiscountPercent = 0.0;

                                        if (discountData.discounts != null &&
                                            discountData
                                                .discounts!.isNotEmpty) {
                                          final matchedDiscount = discountData
                                              .discounts!
                                              .firstWhere(
                                            (d) {
                                              final dCat = int.tryParse(
                                                  d.categoriesId?.trim() ?? "");
                                              return dCat == catId ||
                                                  dCat == 114;
                                            },
                                            orElse: () => DiscountModel(),
                                          );

                                          userDiscountPercent = double.tryParse(
                                                  matchedDiscount.discount
                                                          ?.trim() ??
                                                      "0") ??
                                              0.0;
                                        }

                                        // --- 4. Create Detail Object ---
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
                                          discount: userDiscountPercent,
                                          inclTax: v.inclTax ?? '',
                                        );

                                        print(
                                            'fetched cattax in the tiered discount: $fetchedCatTax');

                                        // --- 5. PASS catTax TO FUNCTION ---
                                        await CartDatabaseManager()
                                            .addToCartPromo(
                                          customerId: customerId,
                                          localCount: qty.value,
                                          detail: detail,
                                          isPack: true,
                                          productName: v.productName ?? '',
                                          inclTax: detail.inclTax ?? '',
                                          isChcked: true,
                                          catId: catId,
                                          promoCode: promo.promoCode,
                                          promoMsg: promo.discountText,
                                          CustomerDiscount:
                                              detail.discount!.toDouble(),
                                          tieredDiscount: tieredDiscount,
                                          catTax: fetchedCatTax,
                                        );

                                        productController.isCartModified.value =
                                            true;
                                      }

                                      showCustomToastDisplay(
                                        context,
                                        "Tiered discount added to cart",
                                        Colors.green.shade800,
                                        Icons.check,
                                      );

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
                                    }

                                    // --- Free Item promos ---

                                    if (promo.promoType == "free_gift" ||
                                        promo.promoType == "free_sample") {
                                      // Flatten variants
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

                                      // Validate min order with selected quantity
                                      final allowed =
                                          await validateMinOrderBeforeAdd(
                                              allVariants);
                                      if (!allowed) return;
                                      List<Map<String, dynamic>> itemsToCheck =
                                          allVariants
                                              .map((v) => {
                                                    'name': v.productName ??
                                                        'Product',
                                                    'quantity': qty.value,
                                                    'stock': (v.stock as num?)
                                                            ?.toInt() ??
                                                        0,
                                                  })
                                              .toList();
                                      if (!await _checkStockAndShowPopup(
                                          context, itemsToCheck)) return;
                                      for (final v in allVariants) {
                                        log("[PROMO] Processing variant → ID: ${v.id}, ProductId: ${v.productId}, Name: ${v.productName}");

                                        // --- 1. LOOKUP CAT TAX FROM CONTROLLER LIST ---
                                        // Search the loaded products list to find the ProductModel instance
                                        double fetchedCatTax = 0.0;
                                        try {
                                          final productModelInstance = widget
                                              .controller.products
                                              .firstWhere(
                                            (p) => p.productId == v.productId,
                                            // Fallback to dummy model if not found
                                            orElse: () =>
                                                ProductModel(catTax: 0),
                                          );

                                          fetchedCatTax =
                                              (productModelInstance.catTax ?? 0)
                                                  .toDouble();
                                        } catch (e) {
                                          print(
                                              "[PROMO] Free Gift - Error finding product model for ID ${v.productId}: $e");
                                        }

                                        // --- 2. Create Detail Object ---
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

                                        print(
                                            'fetched cattax in free gift/sample: $fetchedCatTax');

                                        // --- 3. Add to Cart with Tax ---
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
                                          catTax:
                                              fetchedCatTax, // <--- Assigning the value here
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

                                      showCustomToastDisplay(
                                        context,
                                        "Free items added to cart",
                                        Colors.green.shade800,
                                        Icons.check,
                                      );
                                    }

                                    // --- BOGO promos ---

                                    if (promo.promoType == "bogo") {
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

                                      // Validate min order using PAID quantity only
                                      final allowed =
                                          await validateMinOrderBeforeAdd(
                                              allVariants);
                                      if (!allowed) return;
                                      List<Map<String, dynamic>> itemsToCheck =
                                          allVariants
                                              .map((v) => {
                                                    'name': v.productName ??
                                                        'Product',
                                                    'quantity': qty.value * 2,
                                                    'stock': (v.stock as num?)
                                                            ?.toInt() ??
                                                        0,
                                                  })
                                              .toList();
                                      if (!await _checkStockAndShowPopup(
                                          context, itemsToCheck)) return;

                                      for (final v in allVariants) {
                                        // --- 1. LOOKUP CAT TAX FROM CONTROLLER LIST (No Hive) ---
                                        double fetchedCatTax = 0.0;
                                        try {
                                          final productModelInstance = widget
                                              .controller.products
                                              .firstWhere(
                                            (p) => p.productId == v.productId,
                                            // Fallback to dummy model if not found
                                            orElse: () =>
                                                ProductModel(catTax: 0),
                                          );

                                          fetchedCatTax =
                                              (productModelInstance.catTax ?? 0)
                                                  .toDouble();

                                          // OPTIONAL: You might want to add the API fallback here too,
                                          // just like you did in the tiered_discount case, if the product isn't loaded!
                                        } catch (e) {
                                          print(
                                              "[PROMO] BOGO - Error finding product model for ID ${v.productId}: $e");
                                        }

                                        // --- 2. Create Detail Object ---
                                        final paidDetail = Detail(
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
                                          // Default to 0 for customer discount unless you want BOGO to stack with user discounts
                                          discount: 0.0,
                                        );

                                        final catId = extractCategoryId(
                                            v.productId.toString());

                                        print(
                                            'fetched cattax in BOGO: $fetchedCatTax');

                                        // --- 3. HARDCODE BOGO DISCOUNT ---
                                        // BOGO equates to a 50% discount
                                        const double bogoDiscountPercentage =
                                            50.0;

                                        // --- 4. Add items with Tax and 50% Discount ---
                                        await CartDatabaseManager()
                                            .addToCartPromo(
                                          customerId: customerId,
                                          localCount: qty.value * 2,
                                          detail: paidDetail,
                                          isPack: true,
                                          productName: v.productName ?? '',
                                          inclTax: v.tax ?? '',
                                          isChcked: true,
                                          catId: catId,
                                          promoCode: promo.promoCode,
                                          promoMsg: promo.discountText,
                                          catTax: fetchedCatTax,
                                          CustomerDiscount:
                                              paidDetail.discount!.toDouble(),
                                          bogoDiscount:
                                              bogoDiscountPercentage, // Inject the 50% discount here
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

                                      showCustomToastDisplay(
                                        context,
                                        "BOGO items added to cart (50% Off)",
                                        Colors.green.shade800,
                                        Icons.check,
                                      );
                                    }

                                    // --- BUY X GET Y promos ---

                                    if (promo.promoType == "buy_x_get_y") {
                                      // Extract deal config (assuming one primary deal)
                                      final deals = promo.deals ?? [];
                                      if (deals.isEmpty) {
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
                                              ?.expand((p) => p.variants ?? [])
                                              .toList() ??
                                          [];

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

                                      // Compute quantities
                                      final int paidToAdd = qty.value;
                                      final int dealsApplicable =
                                          qty.value ~/ buyQty;
                                      final int freeToAdd =
                                          dealsApplicable * getQty;

                                      // Search in promo.getProducts for matching variant
                                      String? getVariantId =
                                          deal.getVariantId?.toString();
                                      var getVariant;
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
                                      for (final v in paidVariants) {
                                        // --- A. LOOKUP CAT TAX FOR PAID ITEM ---
                                        double paidItemCatTax = 0.0;
                                        try {
                                          final productModelInstance = widget
                                              .controller.products
                                              .firstWhere(
                                            (p) => p.productId == v.productId,
                                            orElse: () =>
                                                ProductModel(catTax: 0),
                                          );
                                          paidItemCatTax =
                                              (productModelInstance.catTax ?? 0)
                                                  .toDouble();
                                        } catch (e) {
                                          print(
                                              "[PROMO] BuyXGetY (Paid) - Error finding product model: $e");
                                        }

                                        final paidDetail = Detail(
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

                                        // --- COMBINE QUANTITIES ---
                                        // Force the free quantity into the paid item's row, ignoring ID differences
                                        int combinedQty = paidToAdd + freeToAdd;
                                        List<Map<String, dynamic>>
                                            itemsToCheck = [
                                          {
                                            'name': v.productName ?? 'Product',
                                            'quantity': combinedQty,
                                            'stock':
                                                (v.stock as num?)?.toInt() ?? 0,
                                          }
                                        ];
                                        if (!await _checkStockAndShowPopup(
                                            context, itemsToCheck)) return;
// 1. Get the unit price of the free item
                                        double freeUnitPrice = 0.0;
                                        if (getVariant != null) {
                                          freeUnitPrice = double.tryParse(
                                                  (getVariant.sellPrice ?? '0')
                                                      .toString()) ??
                                              0.0;
                                        } else {
                                          freeUnitPrice = double.tryParse(
                                                  (v.sellPrice ?? '0')
                                                      .toString()) ??
                                              0.0;
                                        }

                                        // 2. This is the EXACT monetary discount you want to show (Unit Price * Free Items)
                                        double targetDiscountAmount =
                                            freeUnitPrice * freeToAdd;

                                        // 3. Calculate how the cart table will calculate the total row value
                                        double baseSellPrice = double.tryParse(
                                                (v.sellPrice ?? '0')
                                                    .toString()) ??
                                            0.0;
                                        int pieces = (v.pieces ?? 1).toInt();
                                        int qtyFactor = buyIsPack ? pieces : 1;
                                        double totalRowValue = baseSellPrice *
                                            qtyFactor *
                                            combinedQty;

                                        // 4. Calculate the exact percentage needed to trick the cart into giving exactly the targetDiscountAmount
                                        double dynamicDiscountPercentage = 0.0;
                                        if (totalRowValue > 0) {
                                          dynamicDiscountPercentage =
                                              (targetDiscountAmount /
                                                      totalRowValue) *
                                                  100.0;
                                        }

                                        // Add to cart as a single combined row
                                        await CartDatabaseManager()
                                            .addToCartPromo(
                                          customerId: customerId,
                                          localCount: combinedQty,
                                          detail: paidDetail,
                                          isPack: buyIsPack,
                                          productName: v.productName ?? '',
                                          inclTax: v.tax ?? '',
                                          isChcked: true,
                                          catId: catId,
                                          promoCode: promo.promoCode,
                                          promoMsg:
                                              "${promo.discountText} (Includes $freeToAdd Free)",
                                          catTax: paidItemCatTax,
                                          bogoDiscount:
                                              dynamicDiscountPercentage,
                                          // Tricks the cart into reducing the total price
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

                                      showCustomToastDisplay(
                                        context,
                                        "Buy X Get Y items added to cart",
                                        Colors.green.shade800,
                                        Icons.check,
                                      );
                                    }

//                                       if (promo.promoType == "buy_x_get_y") {
//   // Extract deal config (assuming one primary deal)
//   final deals = promo.deals ?? [];
//   if (deals.isEmpty) {
//     showCustomToastDisplay(
//       context,
//       "No deal configuration found for this promotion",
//       Colors.orange,
//       Icons.warning,
//     );
//     return;
//   }

//   final deal = deals.first;

//   final int buyQty = (deal.buyQuantity ?? 0).toInt();
//   final int getQty = (deal.getQuantity ?? 0).toInt();
//   final String buyQtyType = (deal.buyQuantityType ?? '').toString().toLowerCase();
//   final String getQtyType = (deal.getQuantityType ?? '').toString().toLowerCase();

//   if (buyQty <= 0 || getQty < 0) {
//     showCustomToastDisplay(
//       context,
//       "Invalid deal quantities",
//       Colors.orange,
//       Icons.warning,
//     );
//     return;
//   }

//   // Determine pack/unit based on type strings (e.g., 'carton' => pack)
//   bool isPackFromType(String t) {
//     return t == 'carton' || t == 'box' || t == 'pack';
//   }

//   final bool buyIsPack = isPackFromType(buyQtyType);
//   final bool getIsPack = isPackFromType(getQtyType);

//   // Collect paid variants from promo.products
//   final paidVariants = promo.products?.expand((p) => p.variants ?? []).toList() ?? [];

//   // Validate min order against PAID items only
//   final allowed = await validateMinOrderBeforeAdd(paidVariants);
//   if (!allowed) return;

//   // Enforce buy_x condition against selected quantity
//   if (qty.value < buyQty) {
//     showCustomToastDisplay(
//       context,
//       'Select at least $buyQty to qualify for GET items',
//       Colors.orange,
//       Icons.warning,
//     );
//     return;
//   }

//   // Compute how many deal sets apply
//   // final int dealsApplicable = qty.value ~/ buyQty;

//   // 1) Add PAID items: quantity = selectedQty (user-chosen)
//   final int paidToAdd = qty.value;

//   for (final v in paidVariants) {

//     // --- A. LOOKUP CAT TAX FOR PAID ITEM ---
//     double paidItemCatTax = 0.0;
//     try {
//       final productModelInstance = widget.controller.products.firstWhere(
//         (p) => p.productId == v.productId,
//         orElse: () => ProductModel(catTax: 0),
//       );
//       paidItemCatTax = (productModelInstance.catTax ?? 0).toDouble();
//     } catch (e) {
//       print("[PROMO] BuyXGetY (Paid) - Error finding product model: $e");
//     }

//     final paidDetail = Detail(
//       variationId: v.id,
//       productId: v.productId,
//       variationName: v.variationName,
//       unitType: v.unitType,
//       price: (v.price ?? '0').toString(),
//       sellPrice: (v.sellPrice ?? '0').toString(),
//       tax: double.tryParse(v.tax ?? '0') ?? 0,
//       packtype: v.packtype,
//       pieces: v.pieces,
//       stock: v.stock,
//       lowstock: v.lowstock,
//       fullstock: v.fullstock,
//       imageUrl: v.imageUrl,
//       productName: v.productName,
//     );

//     final catId = extractCategoryId(v.productId.toString());

//     print('fetched cattax for PAID item in BuyXGetY: $paidItemCatTax');

//     await CartDatabaseManager().addToCartPromo(
//       customerId: customerId,
//       localCount: paidToAdd,
//       detail: paidDetail,
//       isPack: buyIsPack,
//       productName: v.productName ?? '',
//       inclTax: v.tax ?? '',
//       isChcked: true,
//       catId: catId,
//       promoCode: promo.promoCode,
//       promoMsg: promo.discountText,
//       catTax: paidItemCatTax, // <--- Assigning value for paid item
//     );

//     productController.isCartModified.value = true;
//   }

//   // 2) Add FREE items from get variant
//   String? getVariantId = deal.getVariantId?.toString();
//   var getVariant;

//   // Search in promo.getProducts for matching variant
//   final getProducts = promo.getProducts ?? [];
//   for (final gp in getProducts) {
//     final vars = gp.variants ?? [];
//     for (final gv in vars) {
//       if (getVariantId == null || gv.id.toString() == getVariantId) {
//         getVariant = gv;
//         getVariantId = gv.id.toString();
//         break;
//       }
//     }
//     if (getVariant != null) break;
//   }

//   if (getVariant != null) {
//     // Determine quantity to add
//     final int dealsApplicable = qty.value ~/ buyQty;
//     final int freeToAdd = dealsApplicable * getQty;

//     if (freeToAdd > 0) {
//       final bool isFreeDeal = (deal.discountType?.toString().toLowerCase() == 'free');

//       // --- B. LOOKUP CAT TAX FOR FREE ITEM ---
//       double freeItemCatTax = 0.0;

//       // Only fetch tax if it's NOT a completely free deal (otherwise tax is 0)
//       if (!isFreeDeal) {
//         try {
//           final productModelInstance = widget.controller.products.firstWhere(
//             (p) => p.productId == getVariant.productId,
//             orElse: () => ProductModel(catTax: 0),
//           );
//           freeItemCatTax = (productModelInstance.catTax ?? 0).toDouble();
//         } catch (e) {
//           print("[PROMO] BuyXGetY (Free) - Error finding product model: $e");
//         }
//       }

//       final freeDetail = Detail(
//         variationId: getVariant.id,
//         productId: getVariant.productId,
//         variationName: getVariant.variationName,
//         unitType: getVariant.unitType,
//         price: isFreeDeal ? '0' : (getVariant.price ?? '0').toString(),
//         sellPrice: isFreeDeal ? '0' : (getVariant.sellPrice ?? '0').toString(),
//         tax: isFreeDeal ? 0 : double.tryParse(getVariant.tax ?? '0') ?? 0,
//         packtype: getVariant.packtype,
//         pieces: getVariant.pieces,
//         stock: getVariant.stock,
//         lowstock: getVariant.lowstock,
//         fullstock: getVariant.fullstock,
//         imageUrl: getVariant.imageUrl,
//         productName: getVariant.productName,
//       );

//       final catId = extractCategoryId(getVariant.productId.toString());

//       print('fetched cattax for GET item in BuyXGetY: $freeItemCatTax');

//       await CartDatabaseManager().addToCartPromo(
//         customerId: customerId,
//         localCount: freeToAdd,
//         detail: freeDetail,
//         isPack: getIsPack,
//         productName: getVariant.productName ?? '',
//         inclTax: getVariant.tax ?? '',
//         isChcked: true,
//         catId: catId,
//         promoCode: "FREE",
//         promoMsg: "This item is Free",
//         catTax: freeItemCatTax, // <--- Assigning value for free item
//       );

//       productController.isCartModified.value = true;
//     }
//   }

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
//     cartProvider.updateCartCount(customerId);
//     cartProvider.getCartItemCounts(customerId);
//   });

//   showCustomToastDisplay(
//     context,
//     "Buy X Get Y items added to cart",
//     Colors.green.shade800,
//     Icons.check,
//   );
// }

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
                                      "Add to Cart".tr,
                                      style: const TextStyle(
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
                            if ((customerAndOrderController
                                    .customerId.value.isNotEmpty) ||
                                (productController
                                    .selectedCustomerName.value.isNotEmpty)) {
                              showCustomToastDisplay(
                                  context,
                                  "Show products - ${promo.promoType?.nkStringCleanAndCapitalize}",
                                  Colors.green.shade800,
                                  Icons.check);

                              if (promo.productScope == "categories") {
                                if (promo.categories!.isNotEmpty) {
                                  // Collect all subcategory IDs as List<String>
                                  final List<String> subcatIds = promo
                                      .categories!
                                      .expand((category) => (category.subIds ??
                                          []) as Iterable<String>)
                                      .toList();

                                  // Call API with subcatIds
                                  CategoryModel categoryData = await ApiWorker()
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
                                int companyId =
                                    SessionHelper.loginSavedData?.company_id ??
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
                                "Select Products".tr,
                                style: const TextStyle(
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
    });
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, Color(0xFF2D3748)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.inventory_2_outlined,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Products & Quantities".tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (promo.minOrderValue != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    "${'MIN ORDER'.tr} : ${formatAmount(promo.minOrderValue)}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 11.5,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Removed global tier selection dropdown

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
                                                  color:
                                                      const Color(0xFF0F172A),
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

                                        // Tier Selector or Quantity Selector based on promo type
                                        promo.promoType == "tiered_discount" &&
                                                promo.tiers != null &&
                                                promo.tiers!.isNotEmpty
                                            ? Container(
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade400),
                                                  color: Colors.white,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 4.0),
                                                child: StatefulBuilder(
                                                  builder:
                                                      (context, tierSetState) {
                                                    // Get or initialize tier for this variant
                                                    Tier? selectedVariantTier;

                                                    // Check if this variant already has a tier selected
                                                    final existingIndex =
                                                        selectedItems
                                                            .indexWhere((e) =>
                                                                e['variant']
                                                                    .id ==
                                                                variant.id);
                                                    if (existingIndex >= 0 &&
                                                        selectedItems[
                                                                    existingIndex]
                                                                ['tier'] !=
                                                            null) {
                                                      selectedVariantTier =
                                                          selectedItems[
                                                                  existingIndex]
                                                              ['tier'] as Tier?;
                                                    }

                                                    return DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButton<Tier>(
                                                        value:
                                                            selectedVariantTier,
                                                        hint: const Text(
                                                            'Select Tier'),
                                                        isExpanded: true,
                                                        items: promo.tiers!
                                                            .map((Tier tier) {
                                                          final requiredQty =
                                                              (tier.buyQuantity
                                                                          as num?)
                                                                      ?.toInt() ??
                                                                  0;
                                                          final discountValue =
                                                              double.tryParse(tier
                                                                          .discountValue
                                                                          ?.toString() ??
                                                                      '0') ??
                                                                  0;

                                                          return DropdownMenuItem<
                                                              Tier>(
                                                            value: tier,
                                                            child: Text(
                                                              'Buy $requiredQty - $discountValue%',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged:
                                                            (Tier? newValue) {
                                                          tierSetState(() {
                                                            selectedVariantTier =
                                                                newValue;
                                                          });

                                                          // Update selected items with the tier
                                                          if (newValue !=
                                                              null) {
                                                            final buyQty = (newValue
                                                                            .buyQuantity
                                                                        as num?)
                                                                    ?.toInt() ??
                                                                1;
                                                            _updateSelectedItemsWithTier(
                                                              variant,
                                                              buyQty, // Use tier's buy quantity
                                                              selectedItems,
                                                              setState,
                                                              newValue,
                                                            );
                                                          } else {
                                                            _updateSelectedItemsWithTier(
                                                              variant,
                                                              0, // Remove if no tier selected
                                                              selectedItems,
                                                              setState,
                                                              null,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade400),
                                                  color: Colors.white,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      tooltip: 'Decrease',
                                                      icon: const Icon(
                                                          Icons.remove,
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Text(
                                                        '$qty',
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      tooltip: 'Increase',
                                                      icon: const Icon(
                                                          Icons.add,
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
                                  'Total Items'.tr +
                                      ': ${selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
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
                                  'Total Amount'.tr +
                                      ': ${formatAmount(_computeTotalAmount(selectedItems))}',
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
                                    List<Map<String, dynamic>> itemsToCheck =
                                        selectedItems.map((e) {
                                      final variant = e['variant'] as dynamic;
                                      return {
                                        'name':
                                            variant.productName ?? 'Product',
                                        'quantity': e['quantity'] as int,
                                        'stock':
                                            (variant.stock as num?)?.toInt() ??
                                                0,
                                      };
                                    }).toList();

                                    if (!await _checkStockAndShowPopup(
                                        context, itemsToCheck)) return;

                                    // Special case: Flat discount (cart-level)
                                    if (promo.promoType == "flat_discount") {
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

                                        // Compute total for EACH item individually
                                        for (final e in selectedItems) {
                                          final v = e['variant'];
                                          final int qty = e['quantity'] as int;

                                          final double unit = double.tryParse(
                                                  (v.sellPrice ?? '0')
                                                      .toString()) ??
                                              0;
                                          final int pcs =
                                              (v.pieces ?? 1).toInt();
                                          final double itemTotal =
                                              (unit * pcs) * qty;

                                          if (itemTotal < minOrder) {
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
                                                                "Minimum order for ${v.productName} is ${formatAmount(promo.minOrderValue)}",
                                                            fontSize: 18)),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
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
                                        }
                                        return true;
                                      }

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

                                      return; // stop here, don’t run normal flow
                                    }

                                    // ---------------- Normal promo flow (unchanged) ----------------

                                    // Validate tier selection for tiered_discount
                                    if (promo.promoType == "tiered_discount") {
                                      // For tiered_discount, check if any item is missing a tier selection
                                      bool missingTier = false;
                                      for (final item in selectedItems) {
                                        if (item['tier'] == null) {
                                          missingTier = true;
                                          break;
                                        }
                                      }

                                      if (missingTier) {
                                        showCustomToastDisplay(
                                          context,
                                          "Please select a tier discount for all selected products",
                                          Colors.orange,
                                          Icons.warning,
                                        );
                                        return;
                                      }
                                    }

                                    // Validate min order
                                    // Validate min order for each individual item
                                    final double? minOrder =
                                        promo.minOrderValue != null
                                            ? double.tryParse(
                                                promo.minOrderValue.toString())
                                            : null;

                                    if (minOrder != null) {
                                      for (final e in selectedItems) {
                                        final variant = e['variant'] as dynamic;
                                        final int qty = e['quantity'] as int;
                                        final double unit = double.tryParse(
                                                (variant.sellPrice ?? '0')
                                                    .toString()) ??
                                            0;
                                        final int pcs =
                                            (variant.pieces ?? 1).toInt();
                                        final double itemTotal =
                                            (unit * pcs) * qty;

                                        if (itemTotal < minOrder) {
                                          showCustomToastDisplay(
                                            context,
                                            'Minimum order for ${variant.productName} is ${formatAmount(promo.minOrderValue)}. Selected total is ${formatAmount(itemTotal.toString())}.',
                                            Colors.orange,
                                            Icons.warning,
                                          );
                                          return;
                                        }
                                      }
                                    }
                                    // final double total = double.tryParse(
                                    //         _computeTotalAmount(
                                    //             selectedItems)) ??
                                    //     0;

                                    // final double? minOrder =
                                    //     promo.minOrderValue != null
                                    //         ? double.tryParse(
                                    //             promo.minOrderValue.toString())
                                    //         : null;

                                    // if (minOrder != null && total < minOrder) {
                                    //   showCustomToastDisplay(
                                    //     context,
                                    //     'Minimum order is ${formatAmount(promo.minOrderValue)}. Selected total is ${formatAmount(total.toString())}.',
                                    //     Colors.orange,
                                    //     Icons.warning,
                                    //   );
                                    //   return;
                                    // }

                                    // Add all selected items to cart
                                    for (final e in selectedItems) {
                                      final variant = e['variant'] as dynamic;
                                      final int qty = e['quantity'] as int;

                                      // --- 1. LOOKUP CAT TAX FROM CONTROLLER LIST ---
                                      // Use the productId from the variant to find the parent ProductModel
                                      double fetchedCatTax = 0.0;
                                      String? inclTaxValue;
                                      try {
                                        final productModelInstance = widget
                                            .controller.products
                                            .firstWhere(
                                          (p) =>
                                              p.productId == variant.productId,
                                          // Fallback to dummy model if not found
                                          orElse: () => ProductModel(catTax: 0),
                                        );

                                        fetchedCatTax =
                                            (productModelInstance.catTax ?? 0)
                                                .toDouble();
                                        inclTaxValue =
                                            productModelInstance.inclTax;
                                        print(
                                            'inclusive tax value from product model: $inclTaxValue');
                                      } catch (err) {
                                        print(
                                            "[PROMO] Error finding product model for tax lookup: $err");
                                      }

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
                                                e['tier'] != null
                                            ? double.tryParse(e['tier']
                                                        .discountValue
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

                                      // --- 2. Pass fetchedCatTax to the function ---
                                      await _addToCartWithPromoLogic(
                                        customerId: customerId,
                                        localCount: qty,
                                        detail: detail,
                                        isPack: true,
                                        productName: variant.productName ?? '',
                                        inclTax: inclTaxValue ?? '',
                                        catId: catId,
                                        promo: promo,
                                        productController: productController,
                                        context: context,
                                        selectedTier: selectedTier.value,
                                        catTax:
                                            fetchedCatTax, // <--- Assigning the value here
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
                            child: Text(
                              "Add to Cart".tr,
                              style: const TextStyle(
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
    double? catTax,
    double? calculatedDiscount, // <--- 1. ADD THIS NEW PARAMETER
  }) async {
    // 2. USE THE CALCULATED DISCOUNT FIRST
    double? discountValue = calculatedDiscount;
    double? maxDiscountValue;
    bool isPercentageBasedDiscount = false;

    // If it wasn't passed, do the normal fallback calculation
    if (discountValue == null) {
      if (promo.promoType == "percentage_discount" ||
          promo.promoType == "happy_hours" ||
          promo.promoType == "seasonal" ||
          promo.promoType == "flash_sale" ||
          promo.promoType == "limited_time") {
        isPercentageBasedDiscount = true;
        discountValue = promo.promoType == "percentage_discount"
            ? double.tryParse(promo.discountValue.toString())
            : double.tryParse(promo.discountPercentage.toString());

        // Store max discount value for percentage-based discounts
        if (promo.maxDiscount != null &&
            promo.maxDiscount.toString().isNotEmpty) {
          maxDiscountValue = double.tryParse(promo.maxDiscount.toString());
        }
      } else if (promo.promoType == "tiered_discount") {
        // Handle tiered discount - use selected tier if available, otherwise calculate
        if (selectedTier != null) {
          discountValue =
              double.tryParse(selectedTier.discountValue?.toString() ?? '0') ??
                  0;
        } else {
          discountValue = _calculateTieredDiscount(promo, localCount, isPack);
        }
      }
    } else {
      if (promo.maxDiscount != null &&
          promo.maxDiscount.toString().isNotEmpty) {
        maxDiscountValue = double.tryParse(promo.maxDiscount.toString());
        isPercentageBasedDiscount = true;
      }
    }

    final detailWithDiscount = (discountValue != null && discountValue > 0)
        ? detail.copyWith(
            discount: discountValue,
            maxDiscount: isPercentageBasedDiscount ? maxDiscountValue : null,
          )
        : detail;
    print('discount value being added to cart: $discountValue');
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
        catTax: catTax,
        bogoDiscount: discountValue);

    productController.isCartModified.value = true;
  }

  /// Checks if the overall promotion is completely out of stock
  bool _isPromoOutOfStock(PromotionReponse promo) {
    if (promo.productScope == "products" ||
        promo.promoType == "product_bundle") {
      if (promo.products != null && promo.products!.isNotEmpty) {
        int totalStock = 0;
        for (var p in promo.products!) {
          if (p.variants != null) {
            for (var v in p.variants!) {
              totalStock += (v.stock as num?)?.toInt() ?? 0;
            }
          }
        }
        return totalStock <= 0;
      }
    }
    return false;
  }

  /// Validates stock for cart items and shows a popup if validation fails
  Future<bool> _checkStockAndShowPopup(
      BuildContext context, List<Map<String, dynamic>> itemsToCheck) async {
    for (var item in itemsToCheck) {
      int qty = item['quantity'] ?? 0;
      int stock = item['stock'] ?? 0;
      String name = item['name'] ?? 'Product';

      if (stock <= 0) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            surfaceTintColor:
                Colors.transparent, // Removes Android 12+ weird tint
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 10),
                Text(
                  "Out of Stock".tr,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "$name is currently out of stock.",
              style: TextStyle(color: const Color(0xFF0F172A), fontSize: 16),
            ),
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    "OK".tr,
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        // await showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title:  Text("Out of Stock".tr, style: const TextStyle(color: Colors.red)),
        //     content: Text("$name is currently out of stock."),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text("OK", style: TextStyle(color: primaryColor)),
        //       ),
        //     ],
        //   ),
        // );
        return false;
      } else if (qty > stock) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            surfaceTintColor:
                Colors.transparent, // Removes Android 12+ weird tint
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange), // Orange for insufficient
                const SizedBox(width: 10),
                Text(
                  "Insufficient Stock".tr,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "Only $stock available for $name. You requested $qty.",
              style: TextStyle(color: const Color(0xFF0F172A), fontSize: 16),
            ),
            actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    "OK".tr,
                    style: const TextStyle(
                      color: Color(
                          0xFF4285F4), // Or you can change back to primaryColor here
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title:  Text("Insufficient Stock".tr, style: TextStyle(color: Colors.orange)),
        //     content: Text("Only $stock available for $name. You requested $qty."),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child:  Text("OK".tr, style: TextStyle(color: primaryColor)),
        //       ),
        //     ],
        //   ),
        // );
        return false;
      }
    }
    return true;
  }

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
      final qtyType = (tier.buyQuantityType)?.toLowerCase() ?? '';

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
        return discountValue;
      }
    }

    return null;
  }

  void _updateSelectedItemsWithTier(
    dynamic variant,
    int quantity,
    List<Map<String, dynamic>> selectedItems,
    void Function(void Function()) setState,
    Tier? tier,
  ) {
    setState(() {
      final idx =
          selectedItems.indexWhere((e) => e['variant'].id == variant.id);
      if (idx >= 0) {
        if (quantity > 0 && tier != null) {
          selectedItems[idx]['quantity'] = quantity;
          selectedItems[idx]['tier'] = tier;
        } else {
          selectedItems.removeAt(idx);
        }
      } else if (quantity > 0 && tier != null) {
        selectedItems.add({
          'variant': variant,
          'quantity': quantity,
          'tier': tier,
        });
      }
    });
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, Color(0xFF2D3748)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Products".tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (minOrderAmount != null &&
                                      minOrderAmount != "") ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "${'MIN ORDER'.tr} : $minOrderAmount",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 11.5,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    if (selectedItems.isNotEmpty)
                                      Positioned(
                                        right: -6,
                                        top: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          constraints: const BoxConstraints(
                                              minWidth: 16, minHeight: 16),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, Color(0xFF2D3748)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Products".tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins_Regular',
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (minOrderAmount != null &&
                                      minOrderAmount != "") ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "${'MIN ORDER'.tr} : $minOrderAmount",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 11.5,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Selected items button
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    if (selectedItems.isNotEmpty)
                                      Positioned(
                                        right: -6,
                                        top: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          constraints: const BoxConstraints(
                                              minWidth: 16, minHeight: 16),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${selectedItems.fold<int>(0, (sum, e) => sum + (e['quantity'] as int))}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            right: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.menu,
                                size: 20,
                                color: Colors.black87,
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
                                  final bool isSelected =
                                      selectedCategory == categoryName;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => selectCategory(categoryName),
                                      child: Center(
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          margin:
                                              const EdgeInsets.only(bottom: 6),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? primaryColor
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            initial,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
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

  // Builds a grouped product list with a table-like structure
  Widget _buildGroupedProductsList(
    BuildContext context,
    List<Map<String, dynamic>> selectedItems,
    void Function(void Function()) setStateDialog,
    void Function(void Function()) parentSetState,
    PromotionReponse promo, // <-- Added promo parameter to calculate discounts
  ) {
    // Group items by product name
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (final item in selectedItems) {
      final Detail detail = item['detail'] as Detail;
      final String productName = detail.productName ?? 'Unknown Product';

      if (!groupedItems.containsKey(productName)) {
        groupedItems[productName] = [];
      }
      groupedItems[productName]!.add(item);
    }

    final headerStyle = TextStyle(
      fontSize: 12,
      color: const Color(0xFF0F172A),
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedItems.entries.map((entry) {
        final String productName = entry.key;
        final List<Map<String, dynamic>> variants = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product header
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Variant', style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Unit Price',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Pack',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Price',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Quantity',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Amount',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Disc',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Tax',
                          textAlign: TextAlign.center, style: headerStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Total',
                          textAlign: TextAlign.right, style: headerStyle)),
                  const SizedBox(width: 30), // Space for delete button
                ],
              ),
            ),

            // Variants
            ...variants.map((item) {
              final Detail detail = item['detail'] as Detail;
              final int quantity = item['quantity'] as int;
              final bool isPack = item['isPack'] as bool;

              // 1. Unit Price & Pack
              final double unitPrice =
                  double.tryParse(detail.sellPrice?.toString() ?? '0') ?? 0.0;
              final int pieces = (detail.pieces ?? 1).toInt();
              final String packText = isPack
                  ? '${detail.packtype ?? 'Bag'}\n(${pieces} Pcs)'
                  : 'Pcs';
              final int qtyFactor = isPack ? pieces : 1;

              // 2. Base Price
              final double basePrice = unitPrice * qtyFactor;
              final double totalBase = basePrice * quantity;

              // 3. Discount Calculation
              double discountPercent = 0.0;
              if (promo.promoType == "percentage_discount" ||
                  promo.promoType == "happy_hours" ||
                  promo.promoType == "seasonal" ||
                  promo.promoType == "flash_sale" ||
                  promo.promoType == "limited_time") {
                discountPercent = double.tryParse(
                        promo.discountValue?.toString() ??
                            promo.discountPercentage?.toString() ??
                            '0') ??
                    0.0;
              } else if (promo.promoType == "tiered_discount" &&
                  item['tier'] != null) {
                discountPercent = double.tryParse(
                        item['tier'].discountValue?.toString() ?? '0') ??
                    0.0;
              }

              double maxDiscountValue =
                  double.tryParse(promo.maxDiscount?.toString() ?? '0') ?? 0.0;
              double uncappedDiscountAmount =
                  totalBase * (discountPercent / 100);
              double discountAmount = uncappedDiscountAmount;

              if (maxDiscountValue > 0 &&
                  uncappedDiscountAmount > maxDiscountValue) {
                discountAmount = maxDiscountValue;
              }

              double priceAfterDiscount = totalBase - uncappedDiscountAmount;

              // 4. Tax Calculation
              // 4. Tax Calculation
              double fetchedCatTax = 0.0;
              String? resolvedInclTax = detail.inclTax;
              try {
                final productModelInstance =
                    Get.find<ProductsController>().products.firstWhere(
                          (p) => p.productId == detail.productId,
                          orElse: () => ProductModel(catTax: 0),
                        );
                fetchedCatTax = (productModelInstance.catTax ?? 0).toDouble();
                if (productModelInstance.inclTax != null &&
                    productModelInstance.inclTax.toString().isNotEmpty) {
                  resolvedInclTax = productModelInstance.inclTax;
                }
              } catch (err) {}

              // 1. The result of subtraction (Amount - Discount)
              // Note: priceAfterDiscount was already calculated just above as (totalBase - discountAmount)

              // 2. Apply the fetchedCatTax percentage to the subtracted result
              double taxAmount = priceAfterDiscount *
                  (fetchedCatTax /
                      100.0); // Added .0 to ensure exact decimal math
              print(
                  'inclusive tax in the promotion details: ${resolvedInclTax}');
              // 5. Final Total
              double finalTotal = resolvedInclTax == "incl_tax"
                  ? priceAfterDiscount
                  : priceAfterDiscount + taxAmount;
              final String variantName = detail.variationName ?? 'Standard';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    // Variant name
                    Expanded(
                      flex: 1,
                      child: Text(
                        variantName,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Unit Price
                    Expanded(
                      flex: 1,
                      child: Text(formatAmount(unitPrice.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.blue)),
                    ),
                    // Pack
                    Expanded(
                      flex: 1,
                      child: Text(packText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11)),
                    ),
                    // Price
                    Expanded(
                      flex: 1,
                      child: Text(formatAmount(basePrice.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    // Quantity
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrement Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(11),
                              onTap: quantity > 1
                                  ? () {
                                      final int indexToUpdate =
                                          selectedItems.indexWhere((element) {
                                        final Detail elementDetail =
                                            element['detail'] as Detail;
                                        final bool elementIsPack =
                                            element['isPack'] as bool;
                                        return elementDetail.id == detail.id &&
                                            elementIsPack == isPack;
                                      });

                                      if (indexToUpdate != -1) {
                                        int currentQty =
                                            selectedItems[indexToUpdate]
                                                ['quantity'] as int;
                                        if (currentQty > 1) {
                                          // Prevents quantity from going to 0
                                          setStateDialog(() {
                                            selectedItems[indexToUpdate]
                                                ['quantity'] = currentQty - 1;
                                          });
                                          parentSetState(
                                              () {}); // Updates the badge counter in the background
                                        }
                                      }
                                    }
                                  : null,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: quantity > 1
                                      ? primaryColor
                                      : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 13,
                                  color: quantity > 1
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 22,
                            child: Text(
                              quantity.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          // Increment Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(11),
                              onTap: () {
                                final int indexToUpdate =
                                    selectedItems.indexWhere((element) {
                                  final Detail elementDetail =
                                      element['detail'] as Detail;
                                  final bool elementIsPack =
                                      element['isPack'] as bool;
                                  return elementDetail.id == detail.id &&
                                      elementIsPack == isPack;
                                });

                                if (indexToUpdate != -1) {
                                  int currentQty = selectedItems[indexToUpdate]
                                      ['quantity'] as int;
                                  setStateDialog(() {
                                    selectedItems[indexToUpdate]['quantity'] =
                                        currentQty + 1;
                                  });
                                  parentSetState(
                                      () {}); // Updates the badge counter in the background
                                }
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add,
                                    size: 13, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(formatAmount(totalBase.toString()),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12))),
                    // Discount
                    Expanded(
                      flex: 1,
                      child: Text(
                          formatAmount(uncappedDiscountAmount.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    // Tax
                    Expanded(
                      flex: 1,
                      child: Text(formatAmount(taxAmount.toString()),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    // Total
                    Expanded(
                      flex: 1,
                      child: Text(formatAmount(finalTotal.toString()),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),

                    // Delete button
                    SizedBox(
                      width: 30,
                      child: IconButton(
                        icon: const Icon(Icons.delete,
                            size: 16, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: Colors.white,
                                title: const Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Remove Item',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'Are you sure you want to remove this variant from the list?'
                                      .tr,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.grey, width: 2),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                            final int indexToRemove =
                                                selectedItems
                                                    .indexWhere((element) {
                                              final Detail elementDetail =
                                                  element['detail'] as Detail;
                                              final bool elementIsPack =
                                                  element['isPack'] as bool;
                                              return elementDetail.id ==
                                                      detail.id &&
                                                  elementIsPack == isPack;
                                            });

                                            if (indexToRemove != -1) {
                                              setStateDialog(() {
                                                selectedItems
                                                    .removeAt(indexToRemove);
                                              });
                                              parentSetState(() {});
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 2),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(color: Color(0xFFE2E8F0)),
          ],
        );
      }).toList(),
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
          final ScrollController horizontalTableController = ScrollController();
          final ScrollController verticalTableController = ScrollController();
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: const EdgeInsets.all(
                16), // Adds a nice margin around the dialog on small screens
            child: Container(
              width: fullScreenWidth(context) *
                  0.95, // Increased from 0.6 to 0.95 for much more width
              constraints: const BoxConstraints(
                  maxWidth:
                      1200), // Prevents it from getting too stretched on huge desktop monitors
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Allows the dialog to shrink vertically if there is less data
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Select Products".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins_Regular',
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
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
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: fullScreenHeight(context) *
                                  0.65, // Dynamically grows up to 65% of screen height, then scrolls
                            ),
                            child: Scrollbar(
                              controller: horizontalTableController,
                              thumbVisibility: true,
                              notificationPredicate: (notif) =>
                                  notif.metrics.axis == Axis.horizontal,
                              child: SingleChildScrollView(
                                controller: horizontalTableController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width:
                                      980, // Ensures every column has enough room to stay on a single line
                                  child: Scrollbar(
                                    controller: verticalTableController,
                                    thumbVisibility: true,
                                    notificationPredicate: (notif) =>
                                        notif.metrics.axis == Axis.vertical,
                                    child: SingleChildScrollView(
                                      controller: verticalTableController,
                                      child: _buildGroupedProductsList(
                                        context,
                                        selectedItems,
                                        setStateDialog,
                                        parentSetState,
                                        promo,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total:'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      )),
                                  Builder(
                                    builder: (_) {
                                      final total = computeSelectedTotal();
                                      return Text(
                                        formatAmount(total.toString()),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (minOrderValue != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Min Order:'.tr,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        )),
                                    Text(minOrderAmountFormatted ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                        )),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Spacer(),
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
                                      List<Map<String, dynamic>> itemsToCheck =
                                          selectedItems.map((e) {
                                        final Detail detail =
                                            e['detail'] as Detail;
                                        return {
                                          'name':
                                              detail.productName ?? 'Product',
                                          'quantity': e['quantity'] as int,
                                          'stock':
                                              (detail.stock as num?)?.toInt() ??
                                                  0,
                                        };
                                      }).toList();

                                      if (!await _checkStockAndShowPopup(
                                          context, itemsToCheck)) return;

                                      // ---------------- Flat Discount Promo ----------------

                                      if (promo.promoType == "flat_discount") {
                                        // Validate min order for each individual product
                                        if (minOrderValue != null) {
                                          for (final e in selectedItems) {
                                            final int qty =
                                                (e['quantity'] as int);
                                            final double itemTotal =
                                                priceForItem(e) * qty;
                                            final Detail detail =
                                                e['detail'] as Detail;

                                            if (itemTotal < minOrderValue) {
                                              showCustomToastDisplay(
                                                context,
                                                'Minimum order for ${detail.productName} is $minOrderAmountFormatted. Selected total is ${formatAmount(itemTotal.toString())}.',
                                                Colors.orange,
                                                Icons.warning,
                                              );
                                              return;
                                            }
                                          }
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

                                          // --- 1. LOOKUP CAT TAX FROM CONTROLLER LIST ---
                                          // Use the productId from the detail object to find the parent ProductModel
                                          double fetchedCatTax = 0.0;
                                          try {
                                            final productModelInstance = widget
                                                .controller.products
                                                .firstWhere(
                                              (p) =>
                                                  p.productId ==
                                                  detail.productId,
                                              // Fallback to dummy model if not found
                                              orElse: () =>
                                                  ProductModel(catTax: 0),
                                            );

                                            fetchedCatTax =
                                                (productModelInstance.catTax ??
                                                        0)
                                                    .toDouble();
                                          } catch (err) {
                                            print(
                                                "[PROMO] Flat Discount - Error finding product model for tax lookup: $err");
                                          }

                                          print(
                                              'fetched cattax for Flat Discount item: $fetchedCatTax');

                                          // --- 2. Pass fetchedCatTax to the helper function ---
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
                                            catTax:
                                                fetchedCatTax, // <--- Assigning the value here
                                            // selectedTier: selectedTier.value,
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

                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        return; // Stop here, skip normal flow
                                      }

                                      // ---------------- Normal Promo Flow ----------------

                                      // Validate min order for each individual product
                                      if (minOrderValue != null) {
                                        for (final e in selectedItems) {
                                          final int qty =
                                              (e['quantity'] as int);
                                          final double itemTotal =
                                              priceForItem(e) * qty;
                                          final Detail detail =
                                              e['detail'] as Detail;

                                          if (itemTotal < minOrderValue) {
                                            showCustomToastDisplay(
                                              context,
                                              'Minimum order for ${detail.productName} is $minOrderAmountFormatted. Selected total is ${formatAmount(itemTotal.toString())}.',
                                              Colors.orange,
                                              Icons.warning,
                                            );
                                            return;
                                          }
                                        }
                                      }

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
                                        final tier =
                                            (e['discount'] as num?) ?? 0;
                                        print(
                                            'discount in the addtocartwith promo logic on tap:$tier');
                                        // --- 1. CALCULATE EXACT DISCOUNT PERCENTAGE ---
                                        double discountPercent = 0.0;
                                        if (promo.promoType ==
                                                "percentage_discount" ||
                                            promo.promoType == "happy_hours" ||
                                            promo.promoType == "seasonal" ||
                                            promo.promoType == "flash_sale" ||
                                            promo.promoType == "limited_time") {
                                          discountPercent = double.tryParse(
                                                  promo.discountValue
                                                          ?.toString() ??
                                                      promo.discountPercentage
                                                          ?.toString() ??
                                                      '0') ??
                                              0.0;
                                        } else if (promo.promoType ==
                                                "tiered_discount" &&
                                            e['tier'] != null) {
                                          discountPercent = double.tryParse(
                                                  e['tier']
                                                          ?.discountValue
                                                          ?.toString() ??
                                                      '0') ??
                                              0.0;
                                        } else if (promo.promoType == "bogo") {
                                          discountPercent = 50.0;
                                        }
                                        print(
                                            'discount perecntage in the details screen:$discountPercent');

                                        // Handle Maximum Discount Cap
                                        // double sellPrice = double.tryParse(detail.sellPrice?.toString() ?? '0') ?? 0.0;
                                        // int pieces = (detail.pieces ?? 1).toInt();
                                        // int qtyFactor = (detail.packtype == 'Pack' || isPack) ? pieces : 1;
                                        // double totalBasePrice = (sellPrice * qtyFactor) * qty;

                                        // double maxDiscountValue = double.tryParse(promo.maxDiscount?.toString() ?? '0') ?? 0.0;
                                        // double uncappedDiscountAmount = totalBasePrice * (discountPercent / 100.0);

                                        // if (maxDiscountValue > 0 && uncappedDiscountAmount > maxDiscountValue) {
                                        //   // Recalculate percentage to enforce the exact max discount cap in the cart table
                                        //   if (totalBasePrice > 0) {
                                        //     discountPercent = (maxDiscountValue / totalBasePrice) * 100.0;
                                        //   }
                                        // }

                                        // --- 2. LOOKUP CAT TAX FROM CONTROLLER LIST ---
                                        double fetchedCatTax = 0.0;
                                        try {
                                          final productModelInstance = widget
                                              .controller.products
                                              .firstWhere(
                                            (p) =>
                                                p.productId == detail.productId,
                                            orElse: () =>
                                                ProductModel(catTax: 0),
                                          );
                                          fetchedCatTax =
                                              (productModelInstance.catTax ?? 0)
                                                  .toDouble();
                                        } catch (err) {
                                          print(
                                              "[PROMO] Error finding product model for tax lookup: $err");
                                        }

                                        // --- 3. Pass values to Cart Logic ---
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
                                            catTax: fetchedCatTax,
                                            calculatedDiscount:
                                                discountPercent);
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
                                    content: "Add to Cart".tr,
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

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins_Regular',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 38,
        width: 38,
        child: CachedNetworkImage(
          imageUrl: '${ApiConstants.imageBaseUrl}/$imageUrl',
          placeholder: (context, url) => Container(
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Image.asset('assets/images/Image-not-found.png'),
        ),
      ),
    );
  }

  Widget _buildPromoProductRow({
    required String? imageUrl,
    required String title,
    String? subtitle,
    String? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildProductThumbnail(imageUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ],
      ),
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
            _buildSectionTitle("Bundle Items".tr),
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
                return _buildPromoProductRow(
                  imageUrl: variant.imageUrl,
                  title: variant.productName ?? "-",
                  subtitle:
                      "${variant.variationName ?? "-"} • ${'Qty'.tr}: ${bundleItem.quantity} ${bundleItem.unitType}",
                  trailing: formatAmount(variant.sellPrice ?? '0'),
                );
              }
              return const SizedBox();
            }),
            const SizedBox(height: 8),
          ],

          /// ✅ Show Applicable Products
          if (promo.productScope == "products" &&
              promo.products != null &&
              promo.products!.isNotEmpty) ...[
            _buildSectionTitle("Applicable Products".tr),
            ...promo.products!.map((product) {
              if (product.variants == null || product.variants!.isEmpty) {
                return const SizedBox();
              }

              return Column(
                children: product.variants!.map((variant) {
                  return _buildPromoProductRow(
                    imageUrl: variant.imageUrl,
                    title:
                        '${variant.variationName ?? ""}${variant.unitType != null ? " ${variant.unitType}" : ""} - ${variant.productName ?? "-"}',
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  /// Promotion Type + Status pills
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeAndStatus(PromotionReponse promo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Promo code pill
          _buildPromoCode(promo),
          // Promotion type pill
          _buildInfoChip(
            icon: Icons.sell_outlined,
            label: promo.promoType!.nkStringCleanAndCapitalize,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(PromotionReponse promo) {
    return PromoStatusChip(promo: promo);
  }

  Widget _buildPromoCode(PromotionReponse promo) {
    return _buildInfoChip(
      icon: Icons.confirmation_number_outlined,
      label: '${'Code'.tr} : ${promo.promoCode}',
      color: const Color(0xFF16A34A),
    );
  }

  /// Discount / Scope / Target / Extra Info
  Widget _buildDiscountScopeTarget(PromotionReponse promo) {
    final rows = <MapEntry<String, String>>[
      MapEntry("Offer".tr, promo.discountText),
      MapEntry("Applicable".tr, promo.scopeText),
      MapEntry("Target".tr, promo.targetText),

      // Min order (if available)
      if (promo.minOrderValue != null)
        MapEntry("Min Order".tr, formatAmount(promo.minOrderValue)),

      // Bundle price for product_bundle
      if (promo.promoType == "product_bundle" && promo.bundlePrice != null)
        MapEntry("Bundle Price".tr, formatAmount(promo.bundlePrice)),

      // Extra info (tiers / bundle items)
      if (promo.extraInfoText != null)
        MapEntry(
          promo.promoType == "tiered_discount"
              ? "Tiers".tr
              : promo.promoType == "product_bundle"
                  ? "Items".tr
                  : "Extra".tr,
          promo.extraInfoText.toString(),
        ),

      // Days (for happy_hours)
      if (promo.daysText != null && promo.daysText != '')
        MapEntry("Days".tr, promo.daysText!),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < rows.length; i++)
              _buildRow(rows[i].key, rows[i].value,
                  isLast: i == rows.length - 1),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
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
    const Color statusColor = Color(0xFF16A34A);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: 7,
          horizontal: _expanded ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            if (_expanded) ...[
              const SizedBox(width: 7),
              Text(
                statusText,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
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
