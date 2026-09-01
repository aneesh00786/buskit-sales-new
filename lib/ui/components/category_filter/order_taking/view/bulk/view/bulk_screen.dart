import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/model/bulk_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/widgets/promo_status_chip.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
// Import the service



class BulkScreen extends StatefulWidget {
  const BulkScreen({super.key});

  @override
  State<BulkScreen> createState() => _BulkScreenState();
}

class _BulkScreenState extends State<BulkScreen> {
  late Future<Bulk> _bulkFuture;

  @override
  void initState() {
    super.initState();
    _bulkFuture = ApiWorker().getBulkVolumes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // Use the AppBar/Header structure from previous UI
      body: FutureBuilder<Bulk>(
        future: _bulkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snapshot.hasError) {
            return _buildStatusMessage(
              icon: Icons.error_outline_rounded,
              message: 'Error: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
            return _buildStatusMessage(
              icon: Icons.inventory_2_outlined,
              message: 'No bulk volumes found'.tr,
            );
          }

          final bulkList = snapshot.data!.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bulkList.length,
            itemBuilder: (context, index) {
              final bulkItem = bulkList[index];
              return DynamicBulkCard(data: bulkItem);
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusMessage({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: primaryColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
class DynamicBulkCard extends StatefulWidget {
  final dynamic data;

  const DynamicBulkCard({super.key, required this.data});

  @override
  State<DynamicBulkCard> createState() => _DynamicBulkCardState();
}

class _DynamicBulkCardState extends State<DynamicBulkCard> {
  // Initialize quantity state
  int _currentQuantity = 1;

  @override
  Widget build(BuildContext context) {
    // Access data via widget.data
    final data = widget.data;

    // Calculate values from your data
    final discountText = data.discountPercentage != null
        ? '${data.discountPercentage!.toStringAsFixed(1)}% OFF'
        : '0%';

    // Calculate total savings: (Unit Price * Qty) - Bulk Price
    final double unitPrice = double.tryParse(data.unitPrice.toString()) ?? 0.0;
    final double bulkPrice = double.tryParse(data.volumePrice.toString()) ?? 0.0;
    final int qty = data.itemNumbers ?? 0;
    // Total savings per bulk unit * selected quantity
    final double savings = ((unitPrice * qty) - bulkPrice) * _currentQuantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFF2D3748)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.volumeName ?? "Bulk Item",
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${'Category'.tr}: ${data.categoryName ?? 'N/A'}',
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final int availableStock = int.tryParse(data.stock?.toString() ?? '0') ?? 0;
                     final int itemsPerBulk = data.itemNumbers ?? 1;
                    // You can change this to `availableStock < (data.itemNumbers ?? 1)`
                    // if you want strict bulk availability checking.
                    if (availableStock <= 0 || availableStock < itemsPerBulk) {
                      return const PromoStockStatusChip();
                    }
                    return const SizedBox.shrink();
                  }
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Product Details Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product".tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.variationName ?? "N/A"} ${data.unitType ?? ""} - ${data.productName ?? "N/A"}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              "(${data.subcategoryName ?? 'N/A'})",
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceInfo("Quantity".tr, "$qty"),
                      _buildPriceInfo(
                          "Unit Price".tr, "${formatAmount(unitPrice)}"),
                      _buildPriceInfo(
                          "Bulk Price".tr, "${formatAmount(bulkPrice)}"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dynamic Savings Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.savings_rounded, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${'You Save'.tr}: ‎${formatAmount(savings.toStringAsFixed(2))} ($discountText)',
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildActionButtons(context),
          ],
        ),
    );
  }

  Widget _buildPriceInfo(String label, String price) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 2),
        Text(price,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF0F172A),
            )),
      ],
    );
  }

  // --- Quantity Manager Widget ---
  Widget _buildQuantityManager() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: _currentQuantity > 1
                ? () {
                    setState(() {
                      _currentQuantity--;
                    });
                  }
                : null,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _currentQuantity > 1
                    ? primaryColor
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: _currentQuantity > 1
                    ? Colors.white
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            _currentQuantity.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              setState(() {
                _currentQuantity++;
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final data = widget.data;

    // Calculate Total Amount dynamically
    final double bulkPrice = double.tryParse(data.volumePrice.toString()) ?? 0.0;
    final double totalAmount = bulkPrice * _currentQuantity;

    return Row(
      children: [
        // 1. Quantity Manager
        _buildQuantityManager(),

        const SizedBox(width: 16),

        // 2. Total Amount Display (New)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Total:".tr,
                 style: const TextStyle(
                   fontFamily: 'Poppins_Regular',
                   color: Color(0xFF64748B),
                   fontSize: 11,
                   fontWeight: FontWeight.w600,
                 )),
            Text(
              formatAmount(totalAmount.toStringAsFixed(2)),
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),

       const Spacer(),

        ElevatedButton(
          onPressed: () async {
               final int availableStock =
                  int.tryParse(data.stock?.toString() ?? '0') ?? 0;
              final int itemsPerBulk = data.itemNumbers ?? 1;
              final int totalRequestedStock = _currentQuantity * itemsPerBulk;

              if (availableStock <= 0) {
            showDialog(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent, // Removes Android 12+ weird tint
    title: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red),
        const SizedBox(width: 10),
        Text(
          "Out of Stock".tr,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    content: Text(
      "${data.productName} is currently out of stock.",
      style: const TextStyle(
          fontFamily: 'Poppins_Regular',
          color: Color(0xFF0F172A),
          fontSize: 15),
    ),
    actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
    actions: [
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(
          "OK".tr,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
);
                // showDialog(
                //   context: context,
                //   builder: (context) => AlertDialog(
                //     title: Text("Out of Stock".tr,
                //         style: TextStyle(color: Colors.red)),
                //     content:
                //         Text("${data.productName} is currently out of stock."),
                //     actions: [
                //       TextButton(
                //         onPressed: () => Navigator.pop(context),
                //         child: const Text("OK",
                //             style: TextStyle(color: Color(0xFF4285F4))),
                //       ),
                //     ],
                //   ),
                // );
                return;
              } else if (totalRequestedStock > availableStock) {
                showDialog(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent, // Removes Android 12+ weird tint
    title: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange), // Orange for insufficient
        const SizedBox(width: 10),
        Text(
          "Insufficient Stock".tr,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    content: Text(
       "Only $availableStock items available. You requested $totalRequestedStock items ($_currentQuantity bulks of $itemsPerBulk).",
      style: const TextStyle(
          fontFamily: 'Poppins_Regular',
          color: Color(0xFF0F172A),
          fontSize: 15),
    ),
    actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
    actions: [
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(
          "OK".tr,
          style: const TextStyle(
            fontFamily: 'Poppins_Regular',
            color: primaryColor, // Or you can change back to primaryColor here
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
);
                // showDialog(
                //   context: context,
                //   builder: (context) =>
                //   AlertDialog(
                //     title:  Text("Insufficient Stock".tr,
                //         style: TextStyle(color: Colors.orange)),
                //     content: Text(
                //         "Only $availableStock items available. You requested $totalRequestedStock items ($_currentQuantity bulks of $itemsPerBulk)."),
                //     actions: [
                //       TextButton(
                //         onPressed: () => Navigator.pop(context),
                //         child: Text("OK".tr,
                //             style: TextStyle(color: Color(0xFF4285F4))),
                //       ),
                //     ],
                //   ),
                // );
                return;
              }
              // 1. Retrieve the controllers
              final CustomerAndOrderController customerAndOrderController =
                  Get.find<CustomerAndOrderController>();
              final ProductsController productController =
                  Get.find<ProductsController>();

              // 2. Determine the Customer ID
              final customerId =
                  customerAndOrderController.customerId.value.isNotEmpty
                      ? customerAndOrderController.customerId.value
                      : productController.selectedCustomerId.value;

              try {
                double bPrice = double.tryParse(data.volumePrice.toString()) ?? 0.0;
                int items = data.itemNumbers ?? 1;
                double calculatedSellPrice = bPrice / items;

                // --- TAX FIX START ---
                double fetchedCatTax = 0.0;
                try {
                  if (productController.products.isNotEmpty) {
                    final productModelInstance = productController.products.firstWhere(
                      (p) => p.productId == data.productId,
                      orElse: () => ProductModel(catTax: 0),
                    );
                    fetchedCatTax = (productModelInstance.catTax ?? 0).toDouble();
                  }
                } catch (e) {
                  // Ignore local lookup errors
                }

                if (fetchedCatTax == 0 && data.productId != null) {
                  try {
                    String pId = data.productId.toString();
                    String subCatId = "";
                    if (pId.contains("PD")) {
                       subCatId = pId.substring(0, pId.indexOf("PD"));
                    }
                    if (subCatId.isNotEmpty) {
                      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
                      final remoteProducts = await ApiWorker().getTempProduct(subCatId, companyid: companyId);
                      final remoteProduct = remoteProducts.firstWhere(
                        (p) => p.productId == data.productId,
                        orElse: () => ProductModel(catTax: 0),
                      );
                      fetchedCatTax = (remoteProduct.catTax ?? 0).toDouble();
                    }
                  } catch (e) {
                    print("[BULK] Error fetching tax: $e");
                  }
                }
                // --- TAX FIX END ---

                // 4. Call the database function
                await CartDatabaseManager().addToCart(
                  customerId: customerId,
                  // Pass the selected quantity
                  localCount: _currentQuantity,
                  productName: data.productName ?? '',
                  isPack: true,
                  isChcked: true,
                  catId: int.tryParse(data.categoryId?.toString() ?? '0') ?? 0,
                  inclTax: data.inclTax ?? '',
                  catTax: fetchedCatTax,
                  bulkId: data.bulkId,
                  detail: Detail(
                      id: int.tryParse(data.productVariantId?.toString() ?? '0'),
                      productId: data.productId,
                      variationId: data.productVariantId,
                      variationName: "${data.variationName ?? ''} ",
                      sellPrice: data.unitPrice ?? '0',
                      pieces: data.itemNumbers,
                      saleBy: 'Pack',
                      packtype: 'Bulk',
                      unitType: "",
                      // Pass quantity as stock/count for cart logic
                      stock: _currentQuantity,
                      bulkId: data.bulkId,
                      bulkDiscount: data.discountPercentage ?? 0,
                      bulkDiscountAmount: num.tryParse(data.discountAmount?.toString() ?? '0') ?? 0,
                      bulkTax: data.bulkTax ?? 0,
                      discount: 0,
                  ),
                );
                // print('detail discount: ${data.discountPercentage}');
                print('detail tax: ${data.bulkTax}');
                print('bulk discount in add to bulk screen:${data.discountPercentage}');

                // 5. Update the UI state
                productController.isCartModified.value = true;
                final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                cartProvider.updateCartCount(customerId);
                cartProvider.getCartItemCounts(customerId);

                // 6. Success Feedback
                showCustomToastDisplay(
                    context,
                    "Added $_currentQuantity Bulk Pack(s) to cart",
                    Colors.green,
                    Icons.shopping_cart_checkout);

                // Optional: Reset quantity to 1 after adding
                setState(() {
                  _currentQuantity = 1;
                });

              } catch (e) {
                print("Error adding to cart: $e");
                showCustomToastDisplay(context, "Error adding to cart: $e",
                    Colors.red, Icons.error_outline);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryButtonColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add".tr,
                    style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(width: 6),
                const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 16),
              ],
            ),
        ),
      ],
    );
  }
}
