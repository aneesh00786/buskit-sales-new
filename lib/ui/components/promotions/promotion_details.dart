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
                      ListTile(
                        title: Text(
                          promo.title ?? "Untitled",
                          style: const TextStyle(fontSize: 24),
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

                      /// Type + Status pills
                      _buildTypeAndStatus(promo),
                      _buildPromoCode(promo),

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
                            final customerId = customerAndOrderController
                                    .customerId.value.isNotEmpty
                                ? customerAndOrderController.customerId.value
                                : productController.selectedCustomerId.value;

                            int totalCount = 0;

                            if ((customerAndOrderController
                                    .customerId.value.isNotEmpty) ||
                                (productController
                                    .selectedCustomerName.value.isNotEmpty)) {
                              showCustomToastDisplay(
                                  context,
                                  "ADD TO CART BUTTON PRESSED",
                                  Colors.orange,
                                  Icons.warning);
                              // log("details copy : ${widget.detailsCopy.map((e) => e.toJson()).toList()}");
                              // for (var i = 0;
                              //     i < widget.detailsCopy.length;
                              //     i++) {
                              //   if (localCounts[i] > 0) {
                              //     totalCount += localCounts[i];
                              //   } else {}
                              // }
                              // if (totalCount == 0) {
                              //   showCustomToastDisplay(
                              //       context,
                              //       "Choose at least one variant to add to cart",
                              //       Colors.orange,
                              //       Icons.warning);
                              //   return;
                              // }
                              // for (var i = 0;
                              //     i < widget.detailsCopy.length;
                              //     i++) {
                              //   Detail detail = widget.detailsCopy[i];
                              //   if (localCounts[i] > 0) {
                              //     final bool isPack = detail.saleBy == 'Pack';
                              //     await CartDatabaseManager().addToCart(
                              //       customerId: customerId,
                              //       localCount: localCounts[i],
                              //       detail: detail,
                              //       isPack: isPack,
                              //       productName:
                              //           widget.product.productName ?? '',
                              //       inclTax: widget.product.inclTax ?? '',
                              //       isChcked: true,
                              //       catId: widget.product.catId ?? 0,
                              //     );
                              //     productController.isCartModified
                              //         .value = true;
                              //     log('Product added to cart or draft with ID: ${detail.variationId} with quantity ${localCounts[i]}');
                              //   } else {
                              //     log('Cannot add product with ID: ${detail.variationId} because the count is zero or less.');
                              //   }
                              // }

                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              //   final cartProvider =
                              //       Provider.of<CustomersProvider>(context,
                              //           listen: false);
                              //   cartProvider.updateCartCount(customerId);
                              //   cartProvider.getCartItemCounts(customerId);
                              //   widget.onDone();

                              //   Navigator.pop(context);
                              // });
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

  /// Promotion Type + Status pills
  Widget _buildTypeAndStatus(PromotionReponse promo) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        spacing: 12,
        children: [
          // Promotion type pill
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

          // Status pill
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
                  const SizedBox(width: 8),
                  Text(
                    promo.status?.nkStringCapitalizeFirstCaracter ?? "Inactive",
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
      ),
    );
  }

  Widget _buildPromoCode(PromotionReponse promo) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 20.0, left: 20, right: 20),
      child: Row(
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
      ),
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
            _buildRow("DISCOUNT : ", promo.discountText),
            const Divider(color: Colors.grey),
            _buildRow("SCOPE : ", promo.scopeText),
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
                promo.promoType == "tiered_discount" ? "TIERS : " : "EXTRA : ",
                promo.extraInfoText.toString(),
              ),
            ],

            // Days (for happy_hours)
            if (promo.daysText != null) ...[
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
