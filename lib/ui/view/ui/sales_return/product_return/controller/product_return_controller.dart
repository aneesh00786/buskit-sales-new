
import 'dart:convert';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_row_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class ProductReturnController extends GetxController {
  var orderId = ''.obs;
  var isLoading = true.obs;
  var cartItems = <Cart>[].obs;
  var orderData = Rxn<ProductReturnData>(); // Full order details

  final Dio _dio = Dio();
  final List<ProductReturnRowController> rowControllers = [];
  final TextEditingController globalRemarkCtrl = TextEditingController();
  
   




  Future<void> fetchProductReturnDetails() async {
    if (orderId.value.isEmpty) return;

    try {
      isLoading(true);

      final response =  await ApiWorker().getProductReturnDetails(orderId: orderId.value);
      if(response.data?.isNotEmpty == true){
        final order = response.data!.first;
        orderData.value = order;
        final newCartItems = order.cart ?? [];
        for(var item in newCartItems){
          item.damageQty = 0;
          item.returnQty = 0;
          item.image = null;
          item.itemReason = '';
        }
        cartItems.assignAll(newCartItems);
      }
      // if (response.data!.isNotEmpty) {
      //   orderData.value = response.data!.first;
      //  cartItems.assignAll(response.data!.first.cart ?? []);
      // } 
      else {
        Get.snackbar("Error", "No order found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load order: ${e.toString()}");
      print("error:${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
Future<void> submitReturn() async {
  // ---------------------------------------------------------
  // 1. SYNC ROW CONTROLLERS (unchanged)
  // ---------------------------------------------------------
  if (rowControllers.isEmpty) {
    Get.snackbar('Error', 'No items loaded. Please try again.');
    return;
  }

  for (final ctrl in rowControllers) {
    final cart = ctrl.cart;
    print('Row | Product: ${cart.productName} | '
        'Damage: ${cart.damageQty} | Return: ${cart.returnQty} | '
        'Reason: "${cart.itemReason}" | '
        'Image: ${cart.image != null ? cart.image!.path.split('/').last : 'null'}');
  }

  // ---------------------------------------------------------
  // 2. BUILD return_items
  // ---------------------------------------------------------
  final List<Map<String, dynamic>> returnItems = cartItems
      .where((c) => c.damageQty > 0 || c.returnQty > 0)
      .map((c) {
    final hasImage = c.image != null;
    return {
      "product_id": c.productId ?? "",
      "variation_id": c.variationId ?? "",
      "damage_quantity": c.damageQty,
      "return_quantity": c.returnQty,
      "original_quantity": c.quantity ?? 0,
      "damage_refund_amount": (c.damageQty * (c.price ?? 0)).toStringAsFixed(2),
      "return_refund_amount": (c.returnQty * (c.price ?? 0)).toStringAsFixed(2),
      "item_reason": c.itemReason,
      "has_image": hasImage,
    };
  }).toList();

  if (returnItems.isEmpty) {
    Get.snackbar('Warning', 'Add at least one item to return');
    return;
  }

  // ---------------------------------------------------------
  // 3. CALL THE EXTERNAL FUNCTION
  // ---------------------------------------------------------
  try {
    final response = await ApiWorker().submitButtonTap(
      orderId: orderId.value,
      invoiceId: orderData.value!.invoice!.first.invoiceId!,
      returnReason: globalRemarkCtrl.text.trim(),
      returnItems: returnItems,
    );

    // Success
    if (response['status'] == true) {
      Get.back();
      Get.snackbar('Success', response['message'] ?? 'Return created');
    } else {
      Get.snackbar('Error', response['message'] ?? 'Unknown error');
    }
  } catch (e) {
    Get.snackbar('Error', e.toString());
    print('Submit Error: $e');
  }
}
  

 


// Future<void> submitReturn() async {
//   // ---------------------------------------------------------
//   // 1. SYNC ALL EXISTING ROW CONTROLLERS (they already exist!)
//   // ---------------------------------------------------------
//   if (rowControllers.isEmpty) {
//     Get.snackbar('Error', 'No items loaded. Please try again.');
//     return;
//   }

//   print('=== SYNCING ROWS ===');
//   for (final ctrl in rowControllers) {
//     // ctrl.sync(); // <-- This reads the current TextField values!

//     final cart = ctrl.cart;
//     print('Row | '
//         'Product: ${cart.productName} | '
//         'Damage: ${cart.damageQty} | '
//         'Return: ${cart.returnQty} | '
//         'Reason: "${cart.itemReason}" | '
//         'Image: ${cart.image != null ? cart.image!.path.split('/').last : 'null'}');
//   }

//   // ---------------------------------------------------------
//   // 2. BUILD return_items ARRAY + PRINT
//   // ---------------------------------------------------------
//   final List<Map<String, dynamic>> returnItems = cartItems
//       .where((c) => c.damageQty > 0 || c.returnQty > 0)
//       .map((c) {
//     final hasImage = c.image != null;
//     final item = {
//       "product_id": c.productId ?? "",
//       "variation_id": c.variationId ?? "",
//       "damage_quantity": c.damageQty,
//       "return_quantity": c.returnQty,
//       "original_quantity": c.quantity ?? 0,
//       "damage_refund_amount": (c.damageQty * (c.price ?? 0)).toStringAsFixed(2),
//       "return_refund_amount": (c.returnQty * (c.price ?? 0)).toStringAsFixed(2),
//       "item_reason": c.itemReason,
//       "has_image": hasImage,
//     };
//     print('return_item: ${jsonEncode(item)}');
//     return item;
//   }).toList();

//   if (returnItems.isEmpty) {
//     Get.snackbar('Warning', 'Add at least one item to return');
//     return;
//   }

//   // --------------------------------------------------------1. FULL PAYLOAD
//   // ---------------------------------------------------------
//   final Map<String, dynamic> payload = {
//     "order_id": orderId,
//     "invoice_id": orderData.value!.invoice!.first.invoiceId,
//     "company_id": "1",
//     "return_reason": globalRemarkCtrl.text.trim(),
//     "return_items": jsonEncode(returnItems),
//   };

//   print('\n=== FINAL PAYLOAD ===');
//   payload.forEach((k, v) => print('$k: $v'));
//   print('========================================\n');

//   // ---------------------------------------------------------
//   // 3. SEND TO SERVER
//   // ---------------------------------------------------------
//   try {
//     final response = await _dio.post(
//       "https://test.thrivewoo.com/create_sales_return1",
//       data: payload,
//       options: Options(contentType: Headers.formUrlEncodedContentType),
//     );

//     final resp = response.data as Map<String, dynamic>;
//     print('SERVER RESPONSE: $resp');

//     if (resp['status'] == true) {
//       Get.back();
//       Get.snackbar('Success', resp['message'] ?? 'Return created');
//     } else {
//       Get.snackbar('Error', resp['message'] ?? 'Unknown error');
//     }
//   } on DioException catch (e) {
//     final msg = e.response?.data?['message'] ?? e.message;
//     print('DIO ERROR: $msg');
//     Get.snackbar('Network error', msg);
//   }
// }
@override
  void onClose() {
    cartItems.clear();
    orderData.value = null;
    globalRemarkCtrl.dispose();
    rowControllers.clear();
    super.onClose();
  }

}
