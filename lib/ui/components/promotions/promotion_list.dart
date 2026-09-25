import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';

class PromotionList extends StatelessWidget {
  final ProductsController controller;
  final bool isDrawer;

  const PromotionList(
      {super.key, required this.controller, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8FAFC),
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
          _buildHeader(),

          /// Reactive UI with GetX
          Expanded(
            child: Obx(() {
              if (controller.isPromotionLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (controller.promotions.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: controller.promotions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final promo = controller.promotions[index];
                  return _buildPromotionCard(promo, context);
                },
              );
            }),
          ),
        ],
=======
    return Expanded(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF8FAFC),
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
            _buildHeader(),

            /// Reactive UI with GetX
            Expanded(
              child: Obx(() {
                if (controller.isPromotionLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (controller.promotions.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: controller.promotions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final promo = controller.promotions[index];
                    return _buildPromotionCard(promo, context);
                  },
                );
              }),
            ),
          ],
        ),
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
      ),
    );
  }

  /// Header Bar
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
<<<<<<< HEAD
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_offer_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Active Promotions".tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
=======
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                "Active Promotions".tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
          ),
          if (isDrawer)
            Builder(
              builder: (context) => InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_offer_outlined,
                size: 28, color: primaryColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 10),
          Text(
            "No promotions available".tr,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Promotion Card Item
  Widget _buildPromotionCard(PromotionReponse promo, BuildContext context) {
    return Obx(
      () {
        final isSelected = controller.selectedPromotion.value?.id == promo.id;
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              controller.selectPromotion(promo);
              if (isDrawer) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
<<<<<<< HEAD
                color:
                    isSelected ? primaryColor.withOpacity(0.06) : Colors.white,
=======
                color: isSelected ? primaryColor.withOpacity(0.06) : Colors.white,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
<<<<<<< HEAD
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
=======
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [primaryColor, const Color(0xFF2D3748)]
<<<<<<< HEAD
                              : [
                                  const Color(0xFFE2E8F0),
                                  const Color(0xFFE2E8F0)
                                ],
=======
                              : [const Color(0xFFE2E8F0), const Color(0xFFE2E8F0)],
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        size: 15,
<<<<<<< HEAD
                        color:
                            isSelected ? Colors.white : const Color(0xFF64748B),
=======
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title ?? "Untitled".tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (promo.description == null ||
                                    promo.description!.isEmpty)
                                ? "No description".tr
                                : promo.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        size: 20,
<<<<<<< HEAD
                        color: isSelected
                            ? primaryColor
                            : const Color(0xFF94A3B8)),
=======
                        color: isSelected ? primaryColor : const Color(0xFF94A3B8)),
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
