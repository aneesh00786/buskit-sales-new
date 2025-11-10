
import 'dart:convert';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
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

  final loginData = SessionHelper.loginSavedData;
  final salesmanInternalId = loginData?.id?.toString();
  debugPrint('Sending salesmanId (user ID): $salesmanInternalId');
  // ---------------------------------------------------------
  // 1. SYNC ROW CONTROLLERS (unchanged)
  // ---------------------------------------------------------
  if (rowControllers.isEmpty) {
    Get.snackbar('Error', 'No items loaded. Please try again.');
    return;
  }
  // final invalidRows = cartItems.where((item) =>
  //     (item.damageQty + item.returnQty) > (item.quantity ?? 0));

  // if (invalidRows.isNotEmpty) {
  //   Get.snackbar(
  //     "Invalid Input",
  //     "Damage + Return Qty cannot exceed Available Qty for ${invalidRows.length} item(s)",
  //     backgroundColor: Colors.red,
  //     colorText: Colors.white,
  //     duration: const Duration(seconds: 4),
  //   );
  //   return; // Stop submission
  // }


  LoginResponse? loginResponce;
  final List<Map<String, dynamic>> returnItems = cartItems
      .where((c) => c.damageQty > 0 || c.returnQty > 0)
      .map((c) {
    final hasImage = c.image != null;
    return {
      "product_id": c.productId ?? "",
      "variation_id": c.variationId ?? "",
      "damage_quantity": c.damageQty,
      "return_quantity": c.returnQty,
      "original_quantity": (c.quantity ?? 0),
      "damage_refund_amount": (c.damageQty * (c.price ?? 0)),
      "return_refund_amount": (c.returnQty * (c.price ?? 0)),
      "item_reason": c.itemReason ?? "",
      "has_image": hasImage,
      "cart_id": c.cartId ?? "",
    };
  }).toList();
  debugPrint('return_items arrayyyy: ${const JsonEncoder.withIndent('  ').convert(returnItems)}');

  if (returnItems.isEmpty) {
    Get.snackbar('Warning', 'Add at least one item to return');
    return;
  }

  // ---------------------------------------------------------
  // 3. CALL THE EXTERNAL FUNCTION
  // ---------------------------------------------------------
  try {
    print('starting to call api function');
    final response = await ApiWorker().submitButtonTap(
      orderId: orderId.value,
      invoiceId: orderData.value!.invoice!.first.invoiceId!,
      returnReason: globalRemarkCtrl.text.trim(),
      returnItems: returnItems,
      customerId: orderData.value?.customerId ?? "",        // ← ADD THESE
      cartId: orderData.value?.cartId ?? "",                // ← ADD THESE
      salesmanId: salesmanInternalId!,        // ← ADD THESE
      salesmanName: orderData.value?.salesmanName ?? "", 
    );
    debugPrint('Response keys: ${response}');
// debugPrint('Status value: ${response['status']} (${response['status'].runtimeType})');
// debugPrint('Status code: ${response['status_code']}');
    if (response['status'] == true) {
      Get.back();
      Get.snackbar('Success', response['message'] ?? 'Return created',colorText: Colors.white,duration: Duration(seconds: 3),backgroundColor: Colors.green);
    } else {
      Get.snackbar('Error', response['message'] ?? 'Unknown error');
    }
  } catch (e) {
    
    debugPrint('Submit Error: $e'); // Use debugPrint
  if (e is DioException) {
    
  }
  Get.snackbar('Error', e.toString());
  }
}
@override
  void onClose() {
    cartItems.clear();
    orderData.value = null;
    globalRemarkCtrl.dispose();
    rowControllers.clear();
    super.onClose();
  }

}
