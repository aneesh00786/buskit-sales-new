// import 'dart:developer';
// import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
// import 'package:busskit_salesexecutive/common/custom_fonts.dart';
// import 'package:busskit_salesexecutive/common/snack_bar_widget.dart';
// import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
// import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

// addProductsToCart(
//     {required BuildContext context,
//     required List<CartItem> cartItems,
//     required CustomerAndOrderController customeController,
//     required double finalAmount,
//     required ProductsController productsController,
//     required String? selectedValue}) async {
// //Picked--------------------------------------------------------------------CartDialogue
//   if (cartItems.isNotEmpty && customeController.customerId.value.isNotEmpty) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//     await Future.delayed(Duration(seconds: 2));
//     List<Detail> detail = cartItems.map((e) => e.detail).toList();

//     final productBYData = AddToCartModel(
//       customerId: customeController.customerId.value,
//       salesmanId: SessionHelper.loginSavedData!.salesmanId!,
//       cartId: '',
//       cartList: detail
//           .map((e) => SendCartData(
//                 productId: e.productId ?? '',
//                 variantId: e.variationId ?? '',
//                 pack: '2',
//                 price: e.price.toString(),
//                 discount: '0',
//                 quantity: e.count.toInt(),
//               ))
//           .toList(),
//       total: finalAmount.toStringAsFixed(0),
//       discount: '0',
//     );
//     CartOrderModel? cartOrder =
//         await ApiWorker().addToCart(productBYData.toJson());
//     log('CartId :${cartOrder?.cartId}');
//     if (cartOrder != null) {
//       int orderStatus;
//       if (selectedValue == 'Sale Order') {
//         orderStatus = 11;
//       } else if (selectedValue == 'Pre Order') {
//         orderStatus = 0;
//       } else if (selectedValue == 'Estimate') {
//         orderStatus = 7;
//       } else {
//         orderStatus = -1;
//       }
//       CartOrderModel order = CartOrderModel(
//         customerId: customeController.customerId.value,
//         salesmanId: SessionHelper.loginSavedData!.salesmanId!,
//         cartId: cartOrder.cartId,
//         orderStatus: orderStatus,
//       );

//       log('CartId :${cartOrder.cartId}');
//       await productsController.placeOrder(order);
//       cartItems.clear();
//       CartDatabaseManager().clearCart();
//     }
//     Navigator.pop(context);
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Center(
//             child: Container(
//                 height: 100,
//                 width: 100,
//                 child: Lottie.asset(
//                     'assets/images/Animation - 1726906882515.json')),
//           ),
//           content: CustomText(
//             content: 'Your order has been successfully placed.',
//             fontSize: 18,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   } else if (customeController.customerId.value.isEmpty) {
//     showCustomSnackBar(
//       context,
//       'No Customer Selected',
//     );
//   } else {
//     showCustomSnackBar(
//       context,
//       'Your Cart is Empty',
//     );
//   }
//   //Picked--------------------------------------------------------------------CartDialogue
// }
