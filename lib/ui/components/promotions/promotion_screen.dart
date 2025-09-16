import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_details.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_list.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotionScreen extends StatelessWidget {
  final ProductsController controller;

  const PromotionScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool portrait = isPhonePortrait(context);

    if (controller.promotions.isNotEmpty) {
      controller.selectedPromotion.value = controller.promotions.first;
    }

    return Scaffold(
      appBar: isPhonePortrait(context)
          ? AppBar(
              // title: const Text("Promotions"),
              // backgroundColor: const Color(0xFF667eea),
              leading: (portrait)
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : null,
              automaticallyImplyLeading: false,
            )
          : null,

      // 👉 Drawer only in portrait mode
      drawer: portrait
          ? Drawer(
              child: SafeArea(
                child: PromotionList(controller: controller),
              ),
            )
          : null,

      // 👉 Body
      body: portrait
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: PromotionDetails(controller: controller),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  PromotionList(controller: controller),
                  const SizedBox(width: 10),
                  PromotionDetails(controller: controller),
                ],
              ),
            ),
    );
  }
}

extension PromotionHelpers on PromotionReponse {
  /// Discount text
  String get discountText {
    switch (promoType) {
      case 'free_sample':
        if (freeItems != null && freeItems!.isNotEmpty) {
          final sample = freeItems!.first;
          return "Sample: ${sample.sampleDetails ?? sample.quantity ?? ''}";
        }
        return "Sample";
      case 'product_bundle':
        return "Bundle at \$${bundlePrice ?? ''}";
      case 'bogo':
        if (deals != null && deals!.isNotEmpty) {
          final deal = deals!.first;
          return "Buy ${deal.buyQuantity} ${deal.buyQuantityType}, "
              "Get ${deal.getQuantity} ${deal.getQuantityType}";
        }
        return "BOGO Deal";
      case 'tiered_discount':
        if (tiers != null && tiers!.isNotEmpty) {
          final discounts = tiers!
              .map((t) => double.tryParse(t.discountValue ?? '0') ?? 0)
              .toList();
          final min = discounts.reduce((a, b) => a < b ? a : b);
          final max = discounts.reduce((a, b) => a > b ? a : b);
          return "${tiers!.length} tier (${min.toStringAsFixed(2)}% - ${max.toStringAsFixed(2)}%)";
        }
        return "Tiered Discount";
      default:
        return "Discount";
    }
  }

  /// Scope text
  String get scopeText {
    switch (productScope) {
      case 'all':
        return "All Products";
      case 'products':
        return "${products?.length ?? 0} product${(products?.length ?? 0) > 1 ? 's' : ''}";
      case 'categories':
        return "${categories?.length ?? 0} categor${(categories?.length ?? 0) > 1 ? 'ies' : 'y'}";
      default:
        return "Scope Unknown";
    }
  }

  /// Target text
  String get targetText {
    switch (applicableFor) {
      case 'all_users':
        return "All Customers";
      case 'specific_users':
        return "Specific Customers";
      default:
        return "Target Unknown";
    }
  }

  /// Items / Tiers / Extra info text
  String? get extraInfoText {
    switch (promoType) {
      case 'product_bundle':
        if (bundleItems != null && bundleItems!.isNotEmpty) {
          final totalQty = bundleItems!.length;
          return "$totalQty item${totalQty > 1 ? 's' : ''}";
        }
        return null;
      case 'tiered_discount':
        if (tiers != null && tiers!.isNotEmpty) {
          return tiers!
              .map((t) =>
                  "Buy ${t.buyQuantity ?? ''} ${t.buyQuantityType ?? ''} → ${t.discountValue ?? ''}% off")
              .join(", ");
        }
        return null;
      default:
        return null;
    }
  }
}
