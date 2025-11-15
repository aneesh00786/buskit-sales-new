

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_row_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/return_info_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class ProductReturnController extends GetxController {
  var orderId = ''.obs;
  var isLoading = true.obs;
  var cartItems = <Cart>[].obs;
  var orderDataItems = <ProductReturnData>[].obs;
  var orderData = Rxn<ProductReturnData>();
  final Rx<ReturnInfo?> returnInfo = Rx<ReturnInfo?>(null);
  final List<ProductReturnRowController> rowControllers = [];
  final TextEditingController globalRemarkCtrl = TextEditingController();
   final RxBool isSubmitting = false.obs;


   bool hasPendingReturn(Cart cart) {
    final info = returnInfo.value;
    if (info == null || cart.variationId == null) return false;

    // Use the `aggregated` list – it's a summary of pending qty per variation_id
    return info.aggregated.any((agg) => agg.variationId == cart.variationId);
  }
  Future<void> fetchProductReturnDetails() async {
    if (orderId.value.isEmpty) return;
    try {
          print('🔍 Fetching details for orderId: ${orderId.value}');

      isLoading(true);
      final response = await ApiWorker().getProductReturnDetails(orderId: orderId.value);
      
      if (response.data?.isNotEmpty == true) {
        final order = response.data!.first;
        orderData.value = order;
        final newCartItems = order.cart ?? [];
        for (var item in newCartItems) {
          item.damageQty = 0;
          item.returnQty = 0;
          item.image = null;
          item.itemReason = '';
        }
        cartItems.assignAll(newCartItems);
        print('orderDatar Response:${cartItems.value}');
      } else {
        Get.snackbar("Error", "No order found",
            colorText: white, backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load order: ${e.toString()}",
          colorText: white, backgroundColor: Colors.red);
      print("error:${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
    bool _validateAllRows() {
  for (final cart in cartItems) {
    final currentTotal = (cart.damageQty ?? 0) + (cart.returnQty ?? 0);
    
    // Skip items with no return quantity in current request
    if (currentTotal == 0) continue;
    
    final pendingQty = returnInfo.value?.aggregated
        .firstWhere(
          (agg) => agg.variationId == cart.variationId,
          orElse: () => Aggregated(variationId: '', pendingQty: 0),
        )
        .pendingQty ?? 0;
    
    final supplied = cart.suppliedQty ?? 0;
    final availableQty = supplied - pendingQty;
    
    if (currentTotal > availableQty) {
      print('Validation failed for ${cart.productName} (${cart.variationName}): '
          'Trying to return: $currentTotal, '
          'Supplied: $supplied, '
          'Already pending: $pendingQty, '
          'Available: $availableQty');
      
      Get.snackbar(
        'Invalid Quantity',
        'Cannot return $currentTotal units of ${cart.productName}. '
        'Only $availableQty units available (Supplied: $supplied, Pending: $pendingQty)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return false;
    }
  }
  return true;
}



  // bool _validateAllRows() {
  //   for (final cart in cartItems) {
  //     final total = (cart.damageQty ?? 0) + (cart.returnQty ?? 0) ;
  //     final supplied = cart.suppliedQty ?? 0;
  //     if (total > supplied) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }
Future<void> submitReturn() async {
  if (isSubmitting.value) return;
  isSubmitting.value = true; // Start loading

  try {
    // ── Validation 1: Remark ──
    if (globalRemarkCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Remark is required',
          colorText: white, backgroundColor: Colors.red);
      return;
    }

    // ── Validation 2: Quantity ──
    if (!_validateAllRows()) {
      Get.snackbar(
        'Invalid Quantity',
        'Please enter a quantity less than or equal to the supplied quantity',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // ── Validation 3: Row controllers ──
    if (rowControllers.isEmpty) {
      Get.snackbar('Error', 'No items loaded. Please try again.',
          colorText: white, backgroundColor: Colors.red);
      return;
    }

    // ── Build imageList ──
    final List<Map<String, dynamic>> imageList = [];
    for (var i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      if (item.image != null) {
        imageList.add({'client_key': i, 'file': item.image});
      }
    }
     print('Imagelistt:$imageList');
    // ── Build returnItems ──
    final List<Map<String, dynamic>> returnItems = [];
    for (var i = 0; i < cartItems.length; i++) {
      final c = cartItems[i];
      final damageQty = c.damageQty ?? 0;
      final returnQty = c.returnQty ?? 0;
      if (damageQty == 0 && returnQty == 0) continue;

      final hasImage = c.image != null;
      returnItems.add({
        "client_key": i,
        "product_id": c.productId ?? "",
        "variation_id": c.variationId ?? "",
        "damage_quantity": damageQty,
        "return_quantity": returnQty,
        "original_quantity": (c.quantity ?? 0),
        "damage_refund_amount": damageQty * (c.price ?? 0),
        "return_refund_amount": returnQty * (c.price ?? 0),
        "item_reason": c.itemReason ?? "",
        "has_image": hasImage,
        "cart_id": c.cartId ?? "",
      });
    }

    if (returnItems.isEmpty) {
      Get.snackbar('Warning', 'Add at least one item to return',
          colorText: white, backgroundColor: Colors.red);
      return;
    }

    // ── Show Full-Screen Loader (only if we reach API call) ──
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // ── API CALL ──
    final loginData = SessionHelper.loginSavedData;
    final salesmanInternalId = loginData?.salesmanId?.toString();

    final response = await ApiWorker().submitButtonTap(
      orderId: orderId.value,
      invoiceId: orderData.value!.invoice!.first.invoiceId!,
      returnReason: globalRemarkCtrl.text.trim(),
      returnItems: returnItems,
      customerId: orderData.value?.customerId ?? "",
      cartId: orderData.value?.cartId ?? "",
      salesmanId: salesmanInternalId!,
      salesmanName: orderData.value?.salesmanName ?? "",
      imageList: imageList,
    );
    if(Get.isDialogOpen == true) Get.back();

    if (response['status'] == true) {
      // Get.back(); // Close current screen
      Get.snackbar(
        'Success',
        response['message'] ?? 'Return created',
        colorText: Colors.white,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      );
      Future.delayed(const Duration(seconds: 1), () {
    if (Get.isOverlaysOpen || Get.isDialogOpen == true) {
      Get.back(closeOverlays: true); // Close any open dialog/snackbar first
    }
    Get.back(closeOverlays: true); // Now go back to previous screen
  });
      
    } else {
      Get.snackbar(
        'Error',
        response['message'] ?? 'Unknown error',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  } catch (e) {
if (Get.isDialogOpen == true) Get.back();
    debugPrint('Submit Error: $e');
    Get.snackbar('Error', e.toString(),
        colorText: Colors.white, backgroundColor: Colors.red);
  } finally {
    
    // Get.to(SalesReturn());
  // Correct and safe
    isSubmitting.value = false; 
  
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


// class ProductReturnController extends GetxController {
//   var orderId = ''.obs;
//   var isLoading = true.obs;
//   var cartItems = <Cart>[].obs;
//   var orderData = Rxn<ProductReturnData>(); // Full order details
//   final List<ProductReturnRowController> rowControllers = [];
//   final TextEditingController globalRemarkCtrl = TextEditingController();
//   Future<void> fetchProductReturnDetails() async {
//     if (orderId.value.isEmpty) return;

//     try {
//       isLoading(true);

//       final response =  await ApiWorker().getProductReturnDetails(orderId: orderId.value);
//       if(response.data?.isNotEmpty == true){
//         final order = response.data!.first;
//         orderData.value = order;
//         final newCartItems = order.cart ?? [];
//         for(var item in newCartItems){
//           item.damageQty = 0;
//           item.returnQty = 0;
//           item.image = null;
//           item.itemReason = '';
//         }
//         cartItems.assignAll(newCartItems);
//       }
//       // if (response.data!.isNotEmpty) {
//       //   orderData.value = response.data!.first;
//       //  cartItems.assignAll(response.data!.first.cart ?? []);
//       // } 
//       else {
//         Get.snackbar("Error", "No order found",colorText: white,backgroundColor: Colors.red);
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to load order: ${e.toString()},",colorText: white,backgroundColor: Colors.red);
//       print("error:${e.toString()}");
//     } finally {
//       isLoading(false);
//     }
//   }
//   bool _validateAllRows() {
//     for (final cart in cartItems) {
//       final total = (cart.damageQty ?? 0) + (cart.returnQty ?? 0);
//       final supplied = cart.suppliedQty ?? 0;
//       if (total > supplied) {
//         return false;
//       }
//     }
//     return true;
//   }
// Future<void> submitReturn() async {
//   if (globalRemarkCtrl.text.trim().isEmpty) {
//       Get.snackbar('Error', 'Remark is required',colorText: white,backgroundColor: Colors.red);
//       return;
//     }
//     if (!_validateAllRows()) {
//       Get.snackbar(
//         'Invalid Quantity',
//         'Please enter a quantity less than or equal to the supplied quantity',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//       return;
//     }

//   final loginData = SessionHelper.loginSavedData;
//   final salesmanInternalId = loginData?.salesmanId?.toString();
//   debugPrint('Sending salesmanId (user ID): $salesmanInternalId');
//   // ---------------------------------------------------------
//   // 1. SYNC ROW CONTROLLERS (unchanged)
//   // ---------------------------------------------------------
//   if (rowControllers.isEmpty) {
//     Get.snackbar('Error', 'No items loaded. Please try again.',colorText: white,backgroundColor: Colors.red);
//     return;
//   }
//   final List<Map<String, dynamic>> imageList = [];

// for (var i = 0; i < cartItems.length; i++) {
//   final item = cartItems[i];
//   if (item.image != null) {
//     imageList.add({
//       'index': i, // 👈 store the list index
//       'file': item.image, // File object
//     });
//   }
// }

// print('image list:$imageList');


  
//   LoginResponse? loginResponce;
//   final List<Map<String, dynamic>> returnItems = cartItems
//       .where((c) => c.damageQty > 0 || c.returnQty > 0)
//       .map((c) {
//     final hasImage = c.image != null;
//     return {
//       "product_id": c.productId ?? "",
//       "variation_id": c.variationId ?? "",
//       "damage_quantity": c.damageQty,
//       "return_quantity": c.returnQty,
//       "original_quantity": (c.quantity ?? 0),
//       "damage_refund_amount": (c.damageQty * (c.price ?? 0)),
//       "return_refund_amount": (c.returnQty * (c.price ?? 0)),
//       "item_reason": c.itemReason ?? "",
//       "has_image": hasImage,
//       "cart_id": c.cartId ?? "",
//     };
//   }).toList();
  

//   if (returnItems.isEmpty) {
//     Get.snackbar('Warning', 'Add at least one item to return',colorText: white,backgroundColor: Colors.red);
//     return;
//   }

//   // ---------------------------------------------------------
//   // 3. CALL THE EXTERNAL FUNCTION
//   // ---------------------------------------------------------
//   try {
//     print('starting to call api function');
//     final response = await ApiWorker().submitButtonTap(
//       orderId: orderId.value,
//       invoiceId: orderData.value!.invoice!.first.invoiceId!,
//       returnReason: globalRemarkCtrl.text.trim(),
//       returnItems: returnItems,
//       customerId: orderData.value?.customerId ?? "",        // ← ADD THESE
//       cartId: orderData.value?.cartId ?? "",                // ← ADD THESE
//       salesmanId: salesmanInternalId!,        // ← ADD THESE
//       salesmanName: orderData.value?.salesmanName ?? "", 
//       imageList: imageList,
//     );
    
// // debugPrint('Status value: ${response['status']} (${response['status'].runtimeType})');
// // debugPrint('Status code: ${response['status_code']}');
//     if (response['status'] == true) {
//       Get.back();
//       Get.snackbar('Success', response['message'] ?? 'Return created',colorText: Colors.white,duration: Duration(seconds: 3),backgroundColor: Colors.green);
//     } else {
//       Get.snackbar('Error', response['message'] ?? 'Unknown error',colorText: Colors.white,backgroundColor: Colors.red);
//     }
//   } catch (e) {
    
//     debugPrint('Submit Error: $e'); // Use debugPrint
//   if (e is DioException) {
    
//   }
//   Get.snackbar('Error', e.toString(),colorText: Colors.white,backgroundColor: Colors.red);
//   }
// }
// @override
//   void onClose() {
//     cartItems.clear();
//     orderData.value = null;
//     globalRemarkCtrl.dispose();
//     rowControllers.clear();
//     super.onClose();
//   }

// }
