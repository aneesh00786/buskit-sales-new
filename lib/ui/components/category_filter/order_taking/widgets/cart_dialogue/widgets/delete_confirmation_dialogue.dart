//   import 'package:busskit_salesexecutive/common/custom_fonts.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:flutter/material.dart';

// Future<dynamic> showVariantDeleteDIalog(
//       BuildContext context, String productName) {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: CustomText(
//             content: 'Delete ${productName}..?',
//             fontWeight: FontWeight.bold,
//           ),
//           actions: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: CustomText(
//                 content: 'Are you sure you want to delete this item?',
//                 fontSize: 15,
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: CustomText(
//                     content: 'Cancel',
//                     color: primaryColor,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     _deleteItem(productName);

//                     Navigator.pop(context);
//                   },
//                   child: CustomText(
//                     content: 'Confirm',
//                     color: primaryColor,
//                   ),
//                 )
//               ],
//             )
//           ],
//         );
//       },
//     );
//   }