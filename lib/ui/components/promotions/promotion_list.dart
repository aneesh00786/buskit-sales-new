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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blueGrey.shade50,
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),

            /// Reactive UI with GetX
            Expanded(
              child: Obx(() {
                if (controller.isPromotionLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.promotions.isEmpty) {
                  return const Center(
                    child: Text("No promotions available"),
                  );
                }

                return ListView.separated(
                  itemCount: controller.promotions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final promo = controller.promotions[index];
                    return _buildPromotionCard(promo, context);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Bar
  Widget _buildHeader() {
    return Container(
      height: 40,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Text(
              "Active Promotions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          // Close button only shown in drawer mode
          if (isDrawer)
            Positioned(
              right: 0,
              top: 0,
              child: Builder(
                builder: (context) => SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 1)),
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Promotion Card Item
  Widget _buildPromotionCard(PromotionReponse promo, BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 100,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Container(
            height: 100,
            width: 8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text(promo.title ?? "Untitled"),
              subtitle: Text(
                (promo.description == null || promo.description!.isEmpty)
                    ? "No description"
                    : promo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                controller.selectPromotion(promo);
                // Close drawer if in drawer mode
                if (isDrawer) {
                  Navigator.of(context).pop();
                }
              }, // 👈 important
            ),
          ),
        ],
      ),
    );
  }
}
