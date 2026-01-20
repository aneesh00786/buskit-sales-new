
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/model/bulk_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
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
             return Center(child: Text('Error: ${snapshot.error}')); // Simplified for brevity
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

class DynamicBulkCard extends StatelessWidget {
  final dynamic data; // Replace 'dynamic' with your actual Model class name

  const DynamicBulkCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Calculate values from your data
    final discountText = data.discountPercentage != null
        ? '${data.discountPercentage!.toStringAsFixed(1)}% OFF'
        : '0%';
    
    // Calculate total savings: (Unit Price * Qty) - Bulk Price
    final double unitPrice = double.tryParse(data.unitPrice.toString()) ?? 0.0;
    final double bulkPrice = double.tryParse(data.volumePrice.toString()) ?? 0.0;
    final int qty = data.itemNumbers ?? 0;
    final double savings = (unitPrice * qty) - bulkPrice;

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
              children: [
                Text(data.volumeName ?? "Bulk Item", 
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              
              ],
            ),
            const SizedBox(height: 12),
            Text("Category: ${data.categoryName ?? 'N/A'}", 
                 style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
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
                       CustomText(content: "Product", color: Colors.black,fontWeight: FontWeight.bold,),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             CustomText(content:data.productName ?? "N/A", 
                                //  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                 overflow: TextOverflow.ellipsis,fontWeight: FontWeight.bold,fontSize: 16,),
                            CustomText(content:"(${data.subcategoryName ?? 'N/A'})", fontSize: 12,
                            color: Colors.grey
                                //  style: const TextStyle(color: Colors.grey, fontSize: 12)
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
                      // _buildQtyDisplay(qty),
                      _buildPriceInfo("Unit Price", "$qty"),
                      _buildPriceInfo("Unit Price", "${formatAmount(unitPrice)}"),
                      _buildPriceInfo("Bulk Price", "${formatAmount(bulkPrice)}"),
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
                child:  CustomText(content:
                  "You Save: ${formatAmount(savings.toStringAsFixed(2))} ($discountText)",
                  color: Colors.green, fontWeight: FontWeight.bold,fontSize: 18,
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
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 20,)),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
       SizedBox(width: 400,),
        Expanded(
          child: ElevatedButton(
           onPressed: () async {
  // 1. Retrieve the controllers using GetX (as used in your variant_dialogue.dart)
  final CustomerAndOrderController customerAndOrderController = Get.find<CustomerAndOrderController>();
  final ProductsController productController = Get.find<ProductsController>();

  // 2. Determine the Customer ID following your existing logic
  final customerId = customerAndOrderController.customerId.value.isNotEmpty
      ? customerAndOrderController.customerId.value
      : productController.selectedCustomerId.value;

  try {
    double bPrice = double.tryParse(data.volumePrice ?? '0') ?? 0.0;
    int items = data.itemNumbers ?? 1;
    double calculatedSellPrice = bPrice / items;
    print('calculated sell price: $calculatedSellPrice');
    // 4. Call the database function
    await CartDatabaseManager().addToCart(
      customerId: customerId,
      localCount: 1, 
      productName: data.productName ?? '',
      isPack: true, 
      isChcked: true,
      catId: int.tryParse(data.categoryId ?? '0') ?? 0,
      inclTax: "true", 
      
      detail: Detail(
        id: int.tryParse(data.productVariantId ?? '0'),
        productId: data.productId,                        
        variationId: data.productVariantId,
        variationName: "${data.volumeName ?? ''} [BULK_ID:${data.id}]",
        sellPrice:calculatedSellPrice.toString(), 
        pieces: data.itemNumbers,
        unitType: "Pack",
        stock: 1
      ),
    );

    // 5. Update the UI state
    productController.isCartModified.value = true;
    
    // Ensure the context is the valid BuildContext from the Widget tree
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    cartProvider.updateCartCount(customerId);
    cartProvider.getCartItemCounts(customerId);

    // 6. Success Feedback using your custom toast
    showCustomToastDisplay(
      context, // This must be a BuildContext
      "Bulk added to cart", 
      Colors.green, 
      Icons.shopping_cart_checkout
    );

  } catch (e) {
    showCustomToastDisplay(
      context, 
      "Error adding to cart: $e", 
      Colors.red, 
      Icons.error_outline
    );
  }
},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, 
            fontSize: 22)),
          ),
        ),
      ],
    );
  }
}


