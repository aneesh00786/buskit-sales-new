// lib/snackbar/order_id_snackbar.dart

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/controller/sales_return_search_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/return_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'dart:developer' as dev;

class DialogContent extends StatelessWidget {
  final BuildContext outerContext;
  final TextEditingController controller;
  final SalesReturnSearchController searchCtrl;
  final String customerId;

  const DialogContent({
    required this.outerContext,
    required this.controller,
    required this.searchCtrl,
    required this.customerId,
  });

  void _navigateToProductReturn(BuildContext context, String orderId) {
    // Close the current dialog first
    Navigator.of(context).pop();

    // Show the new dialog after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: outerContext,
        builder: (ctx) => AlertDialog(
          content: SizedBox(
            width: isPhonePortrait(outerContext)
                ? fullScreenWidth(outerContext) * 2.3
                : fullScreenWidth(outerContext) > 640
                    ? fullScreenWidth(outerContext) * 1
                    : fullScreenWidth(outerContext) * 1.1,
            height: isPhonePortrait(outerContext)
                ? fullScreenHeight(outerContext) * 2.3
                : fullScreenHeight(outerContext) > 640
                    ? fullScreenHeight(outerContext) * 1
                    : fullScreenHeight(outerContext) * 1.1,
            child: ProductReturnDialogContent(
              orderId: orderId,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF323232),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.receipt, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Invoice No /  Variant name / Item Number (I/N)',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      onChanged: searchCtrl.onTextChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      final selected = searchCtrl.selectedItem.value;
                      final entered = controller.text.trim();

                      if (selected != null) {
                        _navigateToProductReturn(context, selected.orderId);
                        return;
                      }

                      final matches = searchCtrl.suggestions
                          .where((item) =>
                              item.invoiceId.toLowerCase() ==
                                  entered.toLowerCase() ||
                              item.productName
                                  .toLowerCase()
                                  .contains(entered.toLowerCase()))
                          .toList();

                      if (matches.isNotEmpty) {
                        _navigateToProductReturn(
                            context, matches.first.orderId);
                      } else {
                        Get.snackbar(
                          'No results',
                          'No matching order found for "$entered"',
                          backgroundColor: Colors.red.withOpacity(0.9),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      print('CANCEL PRESSED');
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              // DROPDOWN MOVED OUTSIDE THE ROW
              const SizedBox(height: 8),
              Obx(() {
                final suggestions = searchCtrl.suggestions;
                if (suggestions.isEmpty) return const SizedBox.shrink();

                return Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: suggestions.length,
                      itemBuilder: (context, i) {
                        final item = suggestions[i];
                        return InkWell(
                          onTap: () {
                            try {
                              print('🔥 TAP STARTED 🔥');
                              dev.log('=== ITEM TAPPED ===');
                              dev.log('Order ID: ${item.orderId}');
                              dev.log('Invoice ID: ${item.invoiceId}');
                              dev.log('Product: ${item.productName}');
                              dev.log('===================');

                              print('About to select item...');
                              searchCtrl.selectItem(item);

                              print('About to navigate...');
                              _navigateToProductReturn(context, item.orderId);

                              print('✅ TAP COMPLETED');
                            } catch (e, stackTrace) {
                              print('❌ ERROR IN ONTAP: $e');
                              print('Stack trace: $stackTrace');
                            }
                          },
                          //
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white, // Move color here
                              border: i < suggestions.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   '${item.productName} (${item.variationName} ${item.unitType})',
                                //   style: const TextStyle(
                                //     fontSize: 14,
                                //     color: Colors.black87,
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                // ),
                                const SizedBox(height: 4),
                                Text(
                                  'Invoice: ${item.invoiceId} ',
                                  // | Order: ${item.orderId}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
