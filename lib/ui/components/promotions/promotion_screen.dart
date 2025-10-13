import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_details.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_list.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';

class PromotionScreen extends StatefulWidget {
  final ProductsController controller;

  const PromotionScreen({super.key, required this.controller});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  @override
  void initState() {
    super.initState();
    setFirstPromoActive();
  }

  void setFirstPromoActive() {
    if (widget.controller.promotions.isNotEmpty) {
      widget.controller.selectedPromotion.value =
          widget.controller.promotions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool portrait = isPhonePortrait(context);

    if (widget.controller.promotions.isNotEmpty) {
      widget.controller.selectedPromotion.value =
          widget.controller.promotions.first;
    }

    return Scaffold(
      appBar: isPhonePortrait(context)
          ? AppBar(
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
                child: PromotionList(controller: widget.controller),
              ),
            )
          : null,

      // 👉 Body
      body: portrait
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: PromotionDetails(controller: widget.controller),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Flexible(
                      flex: 2,
                      child: PromotionList(controller: widget.controller)),
                  const SizedBox(width: 10),
                  Flexible(
                      flex: 3,
                      child: PromotionDetails(controller: widget.controller)),
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
      case 'free_gift':
        if (freeItems != null && freeItems!.isNotEmpty) {
          final gift = freeItems!.first;
          return "Free: ${gift.giftName ?? 'Gift'}";
        }
        return "Free Gift";
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
          return "${tiers!.length} tiers (${min.toStringAsFixed(2)}% - ${max.toStringAsFixed(2)}%)";
        }
        return "Tiered Discount";
      case 'flat_discount':
        return "\$${discountValue ?? '0'} off";
      case 'percentage_discount':
        final percent = "${discountValue ?? '0'}% off";
        if (maxDiscount != null) {
          return "$percent (max \$${maxDiscount})";
        }
        return percent;
      case 'happy_hours':
        final percent = "${discountPercentage ?? '0'}% off";
        if (startTime != null && endTime != null) {
          return "$percent during $startTime - $endTime";
        }
        return percent;
      case 'seasonal':
        final percent = "${discountPercentage ?? '0'}% off";
        if (seasonName != null) {
          return "$percent - $seasonName";
        }
        return percent;
      case 'flash_sale':
        final percent = "${discountPercentage ?? '0'}% off";
        if (saleDuration != null) {
          return "$percent for $saleDuration minutes";
        }
        return percent;
      case 'limited_time':
        final percent = "${discountPercentage ?? '0'}% off";
        if (offerDuration != null) {
          return "$percent for $offerDuration hours";
        }
        return percent;
      case 'buy_x_get_y':
        if (deals != null && deals!.isNotEmpty) {
          final deal = deals!.first;
          return "Buy ${deal.buyQuantity} ${deal.buyQuantityType}, "
              "Get ${deal.getQuantity} ${deal.getQuantityType} free";
        }
        return "Buy X Get Y";
      default:
        return "Special Offer";
    }
  }

  /// Scope text
  String get scopeText {
    switch (productScope) {
      case 'all':
        return "All Products";
      case 'products':
        final count = products?.length ?? 0;
        if (count == 0) {
          return "No Products";
        } else {
          return "$count product${count != 1 ? 's' : ''}";
        }
      case 'categories':
        final count = categories?.length ?? 0;
        return "$count categor${count != 1 ? 'ies' : 'y'}";
      case 'brands':
        final count = brands?.length ?? 0;
        return "$count brand${count != 1 ? 's' : ''}";
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
        if (targetUsers != null) {
          final count = targetUsersDecoded.length;
          return "$count customer${count > 1 ? 's' : ''}";
        }
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
              .join("\n");
        }
        return null;
      default:
        return null;
    }
  }

  /// Helper to decode target users JSON safely
  List<String> get targetUsersDecoded {
    try {
      if (targetUsers == null) return [];

      if (targetUsers is String) {
        final decoded = jsonDecode(targetUsers!);
        if (decoded is List) {
          return List<String>.from(decoded);
        }
      } else if (targetUsers is List) {
        return List<String>.from(targetUsers as List);
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  /// Min order text
  String? get minOrderText {
    if (minOrderValue != null) {
      return "\$${minOrderValue}";
    }
    return null;
  }

  /// Days text (for happy hours)
  String? get daysText {
    if (promoType == 'happy_hours' && daysOfWeek != null) {
      return daysOfWeek;
    }
    return null;
  }
}
