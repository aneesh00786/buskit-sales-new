// import 'package:busskit_salesexecutive/common/custom_fonts.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:flutter/material.dart';

// class DeleteConfirmationDialogue extends StatefulWidget {
//   List<CartItem> cartItems;
//   CartItem cartItem;
//   int index;
//   List<int> quantities;
//   DeleteConfirmationDialogue({super.key,required this.cartItem,required this.index,required this.quantities,required this.cartItems});

//   @override
//   State<DeleteConfirmationDialogue> createState() => _DeleteConfirmationDialogueState();
// }

// class _DeleteConfirmationDialogueState extends State<DeleteConfirmationDialogue> {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: CustomText(
//         content: 'Delete ${widget.cartItem.productName}..?',
//         fontWeight: FontWeight.bold,
//       ),
//       actions: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: CustomText(
//             content: 'Are you sure you want to delete this item?',
//             fontSize: 15,
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: CustomText(
//                 content: 'Cancel',
//                 color: primaryColor,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteCartItem(widget.index);
//                 Navigator.pop(context);
//               },
//               child: CustomText(
//                 content: 'Confirm',
//                 color: primaryColor,
//               ),
//             )
//           ],
//         )
//       ],
//     );
    
//   }
//     void deleteCartItem(int index) {
//     final itemToDelete = widget.cartItems[index];
//     CartDatabaseManager().deleteCartItem(itemToDelete);
//     setState(() {
//       widget.cartItems.removeAt(index);
//       widget.quantities.removeAt(index);
//     });
//   }
// }
