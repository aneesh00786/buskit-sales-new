// import 'dart:developer';

// import 'package:busskit_salesexecutive/common/custom_fonts.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:flutter/material.dart';

// class QuanityControll extends StatefulWidget {
//   final Detail detail;
//   final double screenWidth;
//   final double fontSize;
//   final double iconSize;

//   QuanityControll(
//       {required this.detail,
//       required this.screenWidth,
//       required this.fontSize,
//       required this.iconSize});

//   @override
//   _QuanityControllState createState() => _QuanityControllState();
// }

// class _QuanityControllState extends State<QuanityControll> {
//   @override
//   void initState() {
//     super.initState();
//     if (widget.detail.count > 0) {
//       widget.detail.count = 0; // Ensure count starts at 0
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(5),
//         color: Color.fromARGB(255, 240, 239, 239),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(5),
//                 bottomLeft: Radius.circular(5),
//               ),
//             ),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   if (widget.detail.count > 0) {
//                     widget.detail.count--;
//                     calculateAmount(widget.detail);
//                   }
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(2.5),
//                 child: Icon(
//                   Icons.remove,
//                   color: white,
//                   size: widget.iconSize,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: widget.screenWidth * 0.01,
//           ),
//           CustomText(
//             content: '${widget.detail.count.toStringAsFixed(0)}',
//             fontSize: widget.fontSize,
//           ),
//           SizedBox(
//             width: widget.screenWidth * 0.01,
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(5),
//                 bottomRight: Radius.circular(5),
//               ),
//             ),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   if (widget.detail.stock == 0) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         backgroundColor: Colors.red,
//                         content: CustomText(
//                           content: 'This item is out of stock',
//                           color: Colors.white,
//                         ),
//                         duration: const Duration(seconds: 2),
//                       ),
//                     );
//                   } else {
//                     widget.detail.count++;
//                     calculateAmount(widget.detail);
//                   }
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(2.5),
//                 child: Icon(
//                   Icons.add,
//                   color: white,
//                   size: widget.iconSize,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void calculateAmount(Detail detail) {
//     double? price = double.tryParse(detail.sellPrice ?? '');
//     if (price != null) {
//       if (detail.saleBy == 'Pack') {
//         detail.totalPrice = price * detail.pieces! * detail.count; 
//         log("Total price for ${detail.price}, Pieces: ${detail.pieces}: Total Price: ${detail.totalPrice}");
//       } else {
//         detail.totalPrice = price * detail.count; 
//         log("Total price for ${detail.price}, Total Price: ${detail.totalPrice}");
//       }
//     } else {
//       log("Price is not valid for detail: ${detail.price}");
//       detail.totalPrice = 0.0;
//     }
//   }
// }
