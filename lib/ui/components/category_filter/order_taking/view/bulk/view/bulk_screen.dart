
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/model/bulk_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
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
      backgroundColor: const Color(0xFFF8F9FE),

      // Use the AppBar/Header structure from previous UI
      body: FutureBuilder<Bulk>(
        future: _bulkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error: ${snapshot.error}')); // Simplified for brevity
          }
          if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
            return const Center(child: Text('No bulk volumes found'));
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.volumeName ?? "Bulk Item",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 28)),
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
            const SizedBox(height: 12),
            Text('Category'.tr + ': ${data.categoryName ?? 'N/A'}',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Product Details Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomText(
                        content: "Product".tr,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                                   content:
    '${data.variationName ?? "N/A"} ${data.unitType ?? ""} - ${data.productName ?? "N/A"}',
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold, fontSize: 16,
                            ),
                            CustomText(
                                content: "(${data.subcategoryName ?? 'N/A'})",
                                fontSize: 12,
                                color: Colors.grey
                                ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
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
            const SizedBox(height: 16),

            // Dynamic Savings Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF7EE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: CustomText(
                  content:
                      'You Save'.tr + ': \u200E${formatAmount(savings.toStringAsFixed(2))} ($discountText)',
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String price) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            )),
        Text(price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
      ],
    );
  }

  // --- Quantity Manager Widget ---
  Widget _buildQuantityManager() {
    const Color primaryColor = Color(0xFF4285F4); 

    return Container(
      width: 120, 
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(255, 241, 240, 240),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Decrement Button
          Container(
            height: 45,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: InkWell(
              onTap: () {
                if (_currentQuantity > 1) {
                  setState(() {
                    _currentQuantity--;
                  });
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    '-',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Quantity Display
          Text(
            _currentQuantity.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          // Increment Button
          Container(
            height: 45,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentQuantity++;
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                   child: Text(
                    '+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildActionButtons(BuildContext context) {
    final data = widget.data;
    
    // Calculate Total Amount dynamically
    final double bulkPrice = double.tryParse(data.volumePrice.toString()) ?? 0.0;
    final double totalAmount = bulkPrice * _currentQuantity;

    return Row(
      children: [
        // 1. Quantity Manager
        _buildQuantityManager(),
        
        const SizedBox(width: 15),

        // 2. Total Amount Display (New)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Total:".tr, style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              formatAmount(totalAmount.toStringAsFixed(2)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22, // Slightly larger to be prominent
                color: Colors.black
              ),
            ),
          ],
        ),
        
       Spacer(),
        
        SizedBox(
          width: 200,
          height: 45,
          child: ElevatedButton(
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
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    content: Text(
      "${data.productName} is currently out of stock.",
      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
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
        child:  Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    content: Text(
       "Only $availableStock items available. You requested $totalRequestedStock items ($_currentQuantity bulks of $itemsPerBulk).",
      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            "OK".tr,
            style: const TextStyle(
              color: Color(0xFF4285F4), // Or you can change back to primaryColor here
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
              backgroundColor: const Color(0xFF4285F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
             
              // minimumSize: const Size(double.infinity, 45), 
            ),
            child:  Text("Add".tr,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
          ),
        ),
      ],
    );
  }
}
