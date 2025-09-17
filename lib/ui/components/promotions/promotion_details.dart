import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_screen.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';

class PromotionDetails extends StatelessWidget {
  final ProductsController controller;

  const PromotionDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
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
