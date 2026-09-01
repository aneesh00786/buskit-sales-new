import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginationWidget extends StatelessWidget {
  final PendingPaymentController orderController;

  const PaginationWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int currentPage = orderController.currentPageRx.value;
      final int totalPages = orderController.totalPageRx.value;

      if (totalPages <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryColor, Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 32,
              width: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: currentPage > 1
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
                onPressed: currentPage > 1
                    ? orderController.goToPreviousPage
                    : null,
              ),
            ),
            Text(
              '$currentPage / $totalPages',
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 32,
              width: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: currentPage < totalPages
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
                onPressed: currentPage < totalPages
                    ? orderController.goToNextPage
                    : null,
              ),
            ),
          ],
        ),
      );
    });
  }
}
