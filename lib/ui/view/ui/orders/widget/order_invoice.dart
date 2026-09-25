// import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
// import 'package:busskit_salesexecutive/common/height_width.dart';
// import 'package:busskit_salesexecutive/common/time_convertion.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
// import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
// import 'package:flutter/material.dart';

// // ignore: must_be_immutable
// class OrderProcessInvoiceDialog extends StatefulWidget {
//   OrderProcessInvoiceData? invoiceData;
//   SpecificOrderData? specificData;
//   final int selectedTabIndex;
//   final OrderController orderController;
//   OrderProcessInvoiceDialog({
//     super.key,
//     this.invoiceData,
//     this.specificData,
//     required this.selectedTabIndex,
//     required this.orderController,
//   });

//   @override
//   State<OrderProcessInvoiceDialog> createState() =>
//       _OrderProcessInvoiceDialogState();
// }

// class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
//   bool isRejecting = false;
//   bool isChanged = false;

//   @override
//   Widget build(BuildContext context) {
//     // 1. Determine which API data was passed to the dialog
//     final bool isSpecific = widget.specificData != null;

//     // Use 'dynamic' to access shared properties
//     final dynamic data = isSpecific ? widget.specificData : widget.invoiceData;

//     // --- EXTRACT COMMON HEADER INFO ---
//     final DateTime? createdAt = data?.orderCreatAt;
//     final String dateString = createdAt != null
//         ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
//         : 'N/A';

//     final String businessName = data?.businessName ?? 'N/A';
//     final String email = data?.email ?? 'N/A';
//     final String phone = isSpecific
//         ? (widget.specificData?.mobileno ?? 'N/A')
//         : (widget.invoiceData?.mobileNo ?? 'N/A');
//     final String orderSource = data?.orderSource ?? '';
//     final String salesmanName = data?.salesmanName ?? 'N/A';
//     final String imageUrl = data?.imageUrl ?? '';
//     final double orderTotal = (data?.orderTotal ?? 0).toDouble();

//     final List<dynamic> cartList = data?.cart ?? [];
//     final List<dynamic> taxList = data?.tax ?? [];

//     // --- CALCULATE SUMMARY VALUES SAFELY ---

//     // 1. Calculate Subtotal
//     final double subtotalAmount = cartList.fold<double>(0, (sum, item) {
//       double itemAmount = 0.0;
//       if (isSpecific) {
//         try {
//           itemAmount = (item.price ?? 0).toDouble();
//         } catch (_) {
//           try {
//             itemAmount = (item.unitPrice ?? 0).toDouble();
//           } catch (_) {}
//         }
//       } else {
//         // OLD API: Use 'price' as requested
//         try {
//           itemAmount = (item.price ?? 0).toDouble();
//         } catch (_) {}
//       }
//       return sum + itemAmount;
//     });

//     // 2. Calculate Total Discount
//     final double totalDiscount = cartList.fold<double>(0, (sum, item) {
//       double disc = 0.0;
//       try {
//         disc = double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0;
//       } catch (_) {}
//       return sum + disc;
//     });

//     // 3. Calculate Total Tax (Sum of 'tax' field from ALL cart items)
//     final double totalTax = cartList.fold<double>(0, (sum, item) {
//       double itemTax = 0.0;
//       try {
//         itemTax = double.tryParse(item.tax?.toString() ?? '0') ?? 0.0;
//       } catch (_) {}
//       return sum + itemTax;
//     });

//     // 4. Prepare Tax Breakdown text (Only if 'tax' array exists)
//     final List<String> taxBreakdownParts = [];
//     if (taxList.isNotEmpty) {
//       for (final t in taxList) {
//         final String name = (t.taxName ?? '').toString().trim();
//         if (name.isEmpty) continue;
//         final double percent = (t.tax ?? 0).toDouble();
//         taxBreakdownParts.add('$name ${percent.toStringAsFixed(0)}%');
//       }
//     }
//     final String taxBreakdownText = taxBreakdownParts.join(', ');

//     return Dialog(
//       insetPadding: const EdgeInsets.all(20),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.95,
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.9,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   const Spacer(),
//                   dialogCloseButton1(context, red),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Flexible(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       MyCommnonContainer(
//                         isCommonBorder: true,
//                         padding: const EdgeInsets.all(15),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   widget.selectedTabIndex == 5
//                                       ? 'INVOICE DETAILS'
//                                       : 'ORDER DETAILS',
//                                   style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   'Created At : $dateString',
//                                   style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ],
//                             ),
//                             Divider(color: Colors.grey.shade300),
//                             Row(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Name :   $businessName"),
//                                     Text("Email :   $email"),
//                                     Text("Phone :   $phone"),
//                                     if (orderSource == 'app')
//                                       Text("Staff :   $salesmanName"),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 ClipOval(
//                                   child: Container(
//                                     height: 50,
//                                     width: 50,
//                                     child: Image.network(
//                                       "${ApiConstants.imageBaseUrl}$imageUrl",
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               Container(
//                                         color: Colors.lightBlue[100],
//                                         child: const Icon(Icons.person,
//                                             color: Colors.blue),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       LayoutBuilder(
//                         builder: (context, constraints) {
//                           final tableWidth = constraints.maxWidth;
//                           final itemNameWidth = tableWidth * 0.2;

//                           return SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: SizedBox(
//                               width: tableWidth,
//                               child: DataTable(
//                                 dataRowHeight: 40,
//                                 headingRowHeight: 40,
//                                 horizontalMargin: 12,
//                                 columnSpacing: 12,
//                                 headingTextStyle: const TextStyle(
//                                     color: black,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600),
//                                 columns: [
//                                   DataColumn(
//                                       label: SizedBox(
//                                           width: itemNameWidth,
//                                           child: const Text('ITEM NAME'))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('U.PRICE',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('PACK TYPE',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('QTY',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('AMOUNT',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('DISCOUNT',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('TAX',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('TOTAL',
//                                               textAlign: TextAlign.right))),
//                                 ],
//                                 rows: cartList.isNotEmpty
//                                     ? List.generate(
//                                         cartList.length,
//                                         (index) {
//                                           final cartItem = cartList[index];

//                                           // --- EXTRACT VALUES SAFELY ---
//                                           String unitPriceStr = '0';
//                                           String amountStr = '0';
//                                           String totalStr = '0';
//                                           String discountStr = '0';
//                                           String taxStr = '0';

//                                           if (isSpecific) {
//                                             try {
//                                               unitPriceStr = cartItem.unitPrice
//                                                       ?.toString() ??
//                                                   '0';
//                                             } catch (_) {
//                                               try {
//                                                 unitPriceStr = cartItem.price
//                                                         ?.toString() ??
//                                                     '0';
//                                               } catch (_) {}
//                                             }
//                                             try {
//                                               amountStr =
//                                                   cartItem.price?.toString() ??
//                                                       '0';
//                                             } catch (_) {}
//                                             try {
//                                               totalStr = cartItem.totalPrice
//                                                       ?.toString() ??
//                                                   '0';
//                                             } catch (_) {}
//                                           } else {
//                                             try {
//                                               unitPriceStr = cartItem.unitPrice
//                                                       ?.toString() ??
//                                                   '0';
//                                             } catch (_) {
//                                               try {
//                                                 unitPriceStr = cartItem.price
//                                                         ?.toString() ??
//                                                     '0';
//                                               } catch (_) {}
//                                             }
//                                             try {
//                                               amountStr =
//                                                   cartItem.price?.toString() ??
//                                                       '0';
//                                             } catch (_) {}
//                                             try {
//                                               totalStr =
//                                                   cartItem.total?.toString() ??
//                                                       '0';
//                                             } catch (_) {}
//                                           }

//                                           try {
//                                             discountStr = cartItem
//                                                     .discountAmount
//                                                     ?.toString() ??
//                                                 '0';
//                                           } catch (_) {}
//                                           try {
//                                             taxStr =
//                                                 cartItem.tax?.toString() ?? '0';
//                                           } catch (_) {}

//                                           return DataRow(
//                                             cells: [
//                                               DataCell(Tooltip(
//                                                   message:
//                                                       "${cartItem.productName} - ${cartItem.variationName}",
//                                                   preferBelow: false,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.black87,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8)),
//                                                   child: SizedBox(
//                                                       width: itemNameWidth,
//                                                       child: ProductNameWithTax(
//                                                         productName: cartItem
//                                                             .productName
//                                                             .toString(),
//                                                         variationName: cartItem
//                                                             .variationName
//                                                             .toString(),
//                                                         isInclTax:
//                                                             cartItem.inclTax ==
//                                                                 "incl_tax",
//                                                         maxWidth: itemNameWidth,
//                                                         style: const TextStyle(
//                                                             fontSize: 12),
//                                                       )))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(
//                                                           unitPriceStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Center(
//                                                 child: Text(
//                                                   // LOGIC:
//                                                   // 1. If packType is 'Pcs' AND pieces is '1' -> Show "Pieces"
//                                                   // 2. Else -> Show standard format like "Pack (10 pcs)"
//                                                   (cartItem.packType
//                                                                   ?.toString()
//                                                                   .toLowerCase() ==
//                                                               'pcs' &&
//                                                           cartItem.pieces
//                                                                   ?.toString() ==
//                                                               '1')
//                                                       ? 'Pieces' // explicitly showing full word here
//                                                       : '${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)',
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: const TextStyle(
//                                                       fontSize: 12),
//                                                 ),
//                                               )),
// //                                                           DataCell(
// //   Center(
// //     child: Text(
// //       // LOGIC: If packType is 'Pcs' AND pieces is 1, show only packType.
// //       // OTHERWISE, show 'PackType (X pcs)'
// //       (cartItem.packType?.toString().toLowerCase() == 'pcs' &&
// //               (cartItem.pieces?.toString() == '1'))
// //           ? (cartItem.packType?.toString() ?? '-')
// //           : '${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)',
// //       maxLines: 1,
// //       overflow: TextOverflow.ellipsis,
// //       style: const TextStyle(fontSize: 12),
// //     ),
// //   ),
// // ),
//                                               // DataCell(Center(
//                                               //     child: Text(
//                                               //   '${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)',
//                                               //   maxLines: 1,
//                                               //   overflow: TextOverflow.ellipsis,
//                                               //   style: const TextStyle(
//                                               //       fontSize: 12),
//                                               // ))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                 '${cartItem.quantity ?? 0}',
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: const TextStyle(
//                                                     fontSize: 12),
//                                               ))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(amountStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(discountStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(taxStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Align(
//                                                   alignment:
//                                                       Alignment.centerRight,
//                                                   child: Text(
//                                                       formatAmount(totalStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12,
//                                                           fontWeight: FontWeight
//                                                               .w600)))),
//                                             ],
//                                           );
//                                         },
//                                       )
//                                     : [
//                                         const DataRow(cells: [
//                                           DataCell(Text('No items available.')),
//                                           DataCell(Text('')),
//                                           DataCell(Text('')),
//                                           DataCell(Text('')),
//                                           DataCell(Text('')),
//                                           DataCell(Text('')),
//                                           DataCell(Text('')),
//                                           DataCell(Text(''))
//                                         ]),
//                                       ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           children: [
//                             // --- SUBTOTAL ---
//                             Row(
//                               children: [
//                                 const Text('Subtotal',
//                                     style: TextStyle(
//                                         color: black,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500)),
//                                 const Spacer(),
//                                 Text(formatAmount(subtotalAmount)),
//                               ],
//                             ),
//                             const SizedBox(height: 8),

//                             // --- DISCOUNT ---
//                             Row(
//                               children: [
//                                 const Text('Discount',
//                                     style: TextStyle(
//                                         color: black,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500)),
//                                 const Spacer(),
//                                 Text(formatAmount(totalDiscount)),
//                               ],
//                             ),
//                             const SizedBox(height: 8),

//                             // --- TAX (Breakdown + Total Tax in SAME ROW) ---
//                             if (totalTax > 0 || taxBreakdownText.isNotEmpty)
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     taxBreakdownText.isNotEmpty
//                                         ? 'Tax $taxBreakdownText'
//                                         : 'Tax',
//                                     style: const TextStyle(
//                                       color: black,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   Text(
//                                     formatAmount(totalTax),
//                                     style: const TextStyle(
//                                       color: black,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                             if (totalTax > 0 || taxBreakdownText.isNotEmpty)
//                               const SizedBox(height: 8),

//                             Divider(color: Colors.grey.shade400),
//                             Row(
//                               children: [
//                                 const Text('Total',
//                                     style: TextStyle(
//                                         color: black,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600)),
//                                 const Spacer(),
//                                 Text(formatAmount(orderTotal.toString()),
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         color: red,
//                                         fontWeight: FontWeight.w600)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (widget.selectedTabIndex == 6) ...[
//                             const Text('Rejection Reason : '),
//                             Text((data?.rejectionReason?.toString() ?? '')),
//                             Text(NKDateUtils.commonDayFormat2(
//                                 NKDateUtils.formatStringUTCDateTime(
//                                     data?.rejectedDate.toString() ?? ''))),
//                           ],
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProductNameWithTax extends StatelessWidget {
//   final String productName;
//   final String variationName;
//   final bool isInclTax;
//   final double maxWidth;
//   final TextStyle style;
//   final Color taxColor;

//   const ProductNameWithTax({
//     super.key,
//     required this.productName,
//     required this.variationName,
//     required this.isInclTax,
//     required this.maxWidth,
//     required this.style,
//     this.taxColor = Colors.green,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final suffix = isInclTax ? ' (Incl. Tax)' : '';

//     final fullText = '$productName - $variationName';
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       maxLines: 1,
//       ellipsis: '...',
//     );

//     for (int i = fullText.length; i >= 0; i--) {
//       final truncated = fullText.substring(0, i).trimRight();
//       final span = TextSpan(
//         text: '$truncated$suffix',
//         style: style,
//       );
//       textPainter.text = span;
//       textPainter.layout(maxWidth: maxWidth);

//       if (!textPainter.didExceedMaxLines) {
//         return Text.rich(
//           TextSpan(
//             text: truncated,
//             style: style,
//             children: [
//               if (i != fullText.length) const TextSpan(text: '...'),
//               if (isInclTax)
//                 TextSpan(
//                   text: suffix,
//                   style: style.copyWith(fontSize: 12, color: taxColor),
//                 ),
//             ],
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.clip,
//         );
//       }
//     }

//     // fallback
//     return Text(
//       suffix,
//       style: style,
//     );
//   }
// }

// import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
// import 'package:busskit_salesexecutive/common/height_width.dart';
// import 'package:busskit_salesexecutive/common/time_convertion.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
// import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
// import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
// import 'package:flutter/material.dart';

// // ignore: must_be_immutable
// class OrderProcessInvoiceDialog extends StatefulWidget {
//   OrderProcessInvoiceData? invoiceData;
//   SpecificOrderData? specificData;
//   final int selectedTabIndex;
//   final OrderController? orderController; // Made optional
//   final bool showPackType; // Added to control column visibility
//   final String? customTitle; // Added for custom titles

//   OrderProcessInvoiceDialog({
//     super.key,
//     this.invoiceData,
//     this.specificData,
//     required this.selectedTabIndex,
//     this.orderController,
//     this.showPackType = true, // Default to true
//     this.customTitle,
//   });

//   @override
//   State<OrderProcessInvoiceDialog> createState() =>
//       _OrderProcessInvoiceDialogState();
// }

// class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
//   bool isRejecting = false;
//   bool isChanged = false;

//   @override
//   Widget build(BuildContext context) {
//     // 1. Determine which API data was passed to the dialog
//     final bool isSpecific = widget.specificData != null;

//     // Use 'dynamic' to access shared properties
//     final dynamic data = isSpecific ? widget.specificData : widget.invoiceData;

//     // --- EXTRACT COMMON HEADER INFO ---
//     final DateTime? createdAt = data?.orderCreatAt;
//     final String dateString = createdAt != null
//         ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
//         : 'N/A';

//     final String businessName = data?.businessName ?? 'N/A';
//     final String email = data?.email ?? 'N/A';
//     final String phone = isSpecific
//         ? (widget.specificData?.mobileno ?? 'N/A')
//         : (widget.invoiceData?.mobileNo ?? 'N/A');
//     final String orderSource = data?.orderSource ?? '';
//     final String salesmanName = data?.salesmanName ?? 'N/A';
//     final String imageUrl = data?.imageUrl ?? '';
//     final double orderTotal = (data?.orderTotal ?? 0).toDouble();

//     final List<dynamic> cartList = data?.cart ?? [];
//     final List<dynamic> taxList = data?.tax ?? [];

//     // --- CALCULATE SUMMARY VALUES SAFELY ---
//     final double subtotalAmount = cartList.fold<double>(0, (sum, item) {
//       double itemAmount = 0.0;
//       if (isSpecific) {
//         try {
//           itemAmount = (item.price ?? 0).toDouble();
//         } catch (_) {
//           try {
//             itemAmount = (item.unitPrice ?? 0).toDouble();
//           } catch (_) {}
//         }
//       } else {
//         try {
//           itemAmount = (item.price ?? 0).toDouble();
//         } catch (_) {}
//       }
//       return sum + itemAmount;
//     });

//     final double totalDiscount = cartList.fold<double>(0, (sum, item) {
//       double disc = 0.0;
//       try {
//         disc = double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0;
//       } catch (_) {}
//       return sum + disc;
//     });

//     final double totalTax = cartList.fold<double>(0, (sum, item) {
//       double itemTax = 0.0;
//       try {
//         itemTax = double.tryParse(item.tax?.toString() ?? '0') ?? 0.0;
//       } catch (_) {}
//       return sum + itemTax;
//     });

//     final List<String> taxBreakdownParts = [];
//     if (taxList.isNotEmpty) {
//       for (final t in taxList) {
//         final String name = (t.taxName ?? '').toString().trim();
//         if (name.isEmpty) continue;
//         final double percent = (t.tax ?? 0).toDouble();
//         taxBreakdownParts.add('$name ${percent.toStringAsFixed(0)}%');
//       }
//     }
//     final String taxBreakdownText = taxBreakdownParts.join(', ');

//     return Dialog(
//       insetPadding: const EdgeInsets.all(20),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.95,
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.9,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   const Spacer(),
//                   dialogCloseButton1(context, red),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Flexible(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       MyCommnonContainer(
//                         isCommonBorder: true,
//                         padding: const EdgeInsets.all(15),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   widget.customTitle ??
//                                       (widget.selectedTabIndex == 5
//                                           ? 'INVOICE DETAILS'
//                                           : 'ORDER DETAILS'),
//                                   style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   'Created At : $dateString',
//                                   style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ],
//                             ),
//                             Divider(color: Colors.grey.shade300),
//                             Row(
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Name :   $businessName"),
//                                     Text("Email :   $email"),
//                                     Text("Phone :   $phone"),
//                                     if (orderSource == 'app')
//                                       Text("Staff :   $salesmanName"),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 ClipOval(
//                                   child: Container(
//                                     height: 50,
//                                     width: 50,
//                                     child: Image.network(
//                                       "${ApiConstants.imageBaseUrl}$imageUrl",
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               Container(
//                                         color: Colors.lightBlue[100],
//                                         child: const Icon(Icons.person,
//                                             color: Colors.blue),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       LayoutBuilder(
//                         builder: (context, constraints) {
//                           final tableWidth = constraints.maxWidth;
//                           final itemNameWidth = tableWidth * 0.2;

//                           return SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: SizedBox(
//                               width: tableWidth,
//                               child: DataTable(
//                                 dataRowHeight: 40,
//                                 headingRowHeight: 40,
//                                 horizontalMargin: 12,
//                                 columnSpacing: 12,
//                                 headingTextStyle: const TextStyle(
//                                     color: black,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600),
//                                 columns: [
//                                   DataColumn(
//                                       label: SizedBox(
//                                           width: itemNameWidth,
//                                           child: const Text('ITEM NAME'))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('U.PRICE',
//                                               textAlign: TextAlign.center))),

//                                   // CONDITIONAL COLUMN: PACK TYPE
//                                   if (widget.showPackType)
//                                     const DataColumn(
//                                         label: Expanded(
//                                             flex: 1,
//                                             child: Text('PACK TYPE',
//                                                 textAlign: TextAlign.center))),

//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('QTY',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('AMOUNT',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('DISCOUNT',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('TAX',
//                                               textAlign: TextAlign.center))),
//                                   const DataColumn(
//                                       label: Expanded(
//                                           flex: 1,
//                                           child: Text('TOTAL',
//                                               textAlign: TextAlign.right))),
//                                 ],
//                                 rows: cartList.isNotEmpty
//                                     ? List.generate(
//                                         cartList.length,
//                                         (index) {
//                                           final cartItem = cartList[index];

//                                           // --- EXTRACT VALUES SAFELY ---
//                                           String unitPriceStr = '0';
//                                           String amountStr = '0';
//                                           String totalStr = '0';
//                                           String discountStr = '0';
//                                           String taxStr = '0';

//                                           if (isSpecific) {
//                                             try {
//                                               unitPriceStr = cartItem.unitPrice
//                                                       ?.toString() ??
//                                                   '0';
//                                             } catch (_) {
//                                               try {
//                                                 unitPriceStr = cartItem.price
//                                                         ?.toString() ??
//                                                     '0';
//                                               } catch (_) {}
//                                             }
//                                             try {
//                                               amountStr =
//                                                   cartItem.price?.toString() ??
//                                                       '0';
//                                             } catch (_) {}
//                                             try {
//                                               totalStr = cartItem.totalPrice
//                                                       ?.toString() ??
//                                                   '0';
//                                             } catch (_) {}
//                                           } else {
//                                             try {
//                                               unitPriceStr = cartItem.unitPrice
//                                                       ?.toString() ??
//                                                   '0';
//                                             } catch (_) {
//                                               try {
//                                                 unitPriceStr = cartItem.price
//                                                         ?.toString() ??
//                                                     '0';
//                                               } catch (_) {}
//                                             }
//                                             try {
//                                               amountStr =
//                                                   cartItem.price?.toString() ??
//                                                       '0';
//                                             } catch (_) {}
//                                             try {
//                                               totalStr =
//                                                   cartItem.total?.toString() ??
//                                                       '0';
//                                             } catch (_) {}
//                                           }

//                                           try {
//                                             discountStr = cartItem
//                                                     .discountAmount
//                                                     ?.toString() ??
//                                                 '0';
//                                           } catch (_) {}
//                                           try {
//                                             taxStr =
//                                                 cartItem.tax?.toString() ?? '0';
//                                           } catch (_) {}

//                                           return DataRow(
//                                             cells: [
//                                               DataCell(Tooltip(
//                                                   message:
//                                                       "${cartItem.productName} - ${cartItem.variationName}",
//                                                   preferBelow: false,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.black87,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8)),
//                                                   child: SizedBox(
//                                                       width: itemNameWidth,
//                                                       child: ProductNameWithTax(
//                                                         productName: cartItem
//                                                             .productName
//                                                             .toString(),
//                                                         variationName: cartItem
//                                                             .variationName
//                                                             .toString(),
//                                                         isInclTax:
//                                                             cartItem.inclTax ==
//                                                                 "incl_tax",
//                                                         maxWidth: itemNameWidth,
//                                                         style: const TextStyle(
//                                                             fontSize: 12),
//                                                       )))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(
//                                                           unitPriceStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),

//                                               // CONDITIONAL CELL: PACK TYPE
//                                               if (widget.showPackType)
//                                                 DataCell(Center(
//                                                   child: Text(
//                                                     (cartItem.packType
//                                                                     ?.toString()
//                                                                     .toLowerCase() ==
//                                                                 'pcs' &&
//                                                             cartItem.pieces
//                                                                     ?.toString() ==
//                                                                 '1')
//                                                         ? 'Pieces'
//                                                         : '${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)',
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                         fontSize: 12),
//                                                   ),
//                                                 )),

//                                               DataCell(Center(
//                                                   child: Text(
//                                                 '${cartItem.quantity ?? 0}',
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: const TextStyle(
//                                                     fontSize: 12),
//                                               ))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(amountStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(discountStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Center(
//                                                   child: Text(
//                                                       formatAmount(taxStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12)))),
//                                               DataCell(Align(
//                                                   alignment:
//                                                       Alignment.centerRight,
//                                                   child: Text(
//                                                       formatAmount(totalStr),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                           fontSize: 12,
//                                                           fontWeight: FontWeight
//                                                               .w600)))),
//                                             ],
//                                           );
//                                         },
//                                       )
//                                     : [
//                                         // Empty row must match column count
//                                         DataRow(cells: [
//                                           const DataCell(Text('No items available.')),
//                                           const DataCell(Text('')),
//                                           if (widget.showPackType) const DataCell(Text('')),
//                                           const DataCell(Text('')),
//                                           const DataCell(Text('')),
//                                           const DataCell(Text('')),
//                                           const DataCell(Text('')),
//                                           const DataCell(Text(''))
//                                         ]),
//                                       ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           children: [
//                             // --- SUBTOTAL ---
//                             Row(
//                               children: [
//                                 const Text('Subtotal',
//                                     style: TextStyle(
//                                         color: black,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500)),
//                                 const Spacer(),
//                                 Text(formatAmount(subtotalAmount)),
//                               ],
//                             ),
//                             const SizedBox(height: 8),

//                             // --- DISCOUNT ---
//                             Row(
//                               children: [
//                                 const Text('Discount',
//                                     style: TextStyle(
//                                         color: black,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500)),
//                                 const Spacer(),
//                                 Text(formatAmount(totalDiscount)),
//                               ],
//                             ),
//                             const SizedBox(height: 8),

//                             // --- TAX ---
//                             if (totalTax > 0 || taxBreakdownText.isNotEmpty)
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     taxBreakdownText.isNotEmpty
//                                         ? 'Tax $taxBreakdownText'
//                                         : 'Tax',
//                                     style: const TextStyle(
//                                       color: black,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   Text(
//                                     formatAmount(totalTax),
//                                     style: const TextStyle(
//                                       color: black,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                             if (totalTax > 0 || taxBreakdownText.isNotEmpty)
//                               const SizedBox(height: 8),

//                             Divider(color: Colors.grey.shade400),
//                             Row(
//                               children: [
//                                 const Text('Total',
//                                     style: TextStyle(
//                                         color: black,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600)),
//                                 const Spacer(),
//                                 Text(formatAmount(orderTotal.toString()),
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         color: red,
//                                         fontWeight: FontWeight.w600)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (widget.selectedTabIndex == 6) ...[
//                             const Text('Rejection Reason : '),
//                             Text((data?.rejectionReason?.toString() ?? '')),
//                             Text(NKDateUtils.commonDayFormat2(
//                                 NKDateUtils.formatStringUTCDateTime(
//                                     data?.rejectedDate.toString() ?? ''))),
//                           ],
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProductNameWithTax extends StatelessWidget {
//   final String productName;
//   final String variationName;
//   final bool isInclTax;
//   final double maxWidth;
//   final TextStyle style;
//   final Color taxColor;

//   const ProductNameWithTax({
//     super.key,
//     required this.productName,
//     required this.variationName,
//     required this.isInclTax,
//     required this.maxWidth,
//     required this.style,
//     this.taxColor = Colors.green,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final suffix = isInclTax ? ' (Incl. Tax)' : '';

//     final fullText = '$productName - $variationName';
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       maxLines: 1,
//       ellipsis: '...',
//     );

//     for (int i = fullText.length; i >= 0; i--) {
//       final truncated = fullText.substring(0, i).trimRight();
//       final span = TextSpan(
//         text: '$truncated$suffix',
//         style: style,
//       );
//       textPainter.text = span;
//       textPainter.layout(maxWidth: maxWidth);

//       if (!textPainter.didExceedMaxLines) {
//         return Text.rich(
//           TextSpan(
//             text: truncated,
//             style: style,
//             children: [
//               if (i != fullText.length) const TextSpan(text: '...'),
//               if (isInclTax)
//                 TextSpan(
//                   text: suffix,
//                   style: style.copyWith(fontSize: 12, color: taxColor),
//                 ),
//             ],
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.clip,
//         );
//       }
//     }

//     // fallback
//     return Text(
//       suffix,
//       style: style,
//     );
//   }
// }

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class OrderProcessInvoiceDialog extends StatefulWidget {
  OrderProcessInvoiceData? invoiceData;
  SpecificOrderData? specificData;
  final int selectedTabIndex;
  final OrderController? orderController;
  final bool showPackType;
  final String? customTitle;

  OrderProcessInvoiceDialog({
    super.key,
    this.invoiceData,
    this.specificData,
    required this.selectedTabIndex,
    this.orderController,
    this.showPackType = true,
    this.customTitle,
  });

  @override
  State<OrderProcessInvoiceDialog> createState() =>
      _OrderProcessInvoiceDialogState();
}

class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
  bool isRejecting = false;
  bool isChanged = false;

  /// Helper to generate the correct Quantity text based on context
  String _getQuantityText(dynamic cartItem) {
    final int quantity =
        int.tryParse(cartItem.quantity?.toString() ?? '0') ?? 0;

    // 1. If Pack Type column is VISIBLE (Standard Order Invoice), just show the number.
    if (widget.showPackType) {
      return '$quantity';
    }

    // 2. If Pack Type column is HIDDEN (Detailed Invoice), show the rich format:
    // Format: "TotalPieces (Qty PackType)" -> e.g. "20 (2 Box)"

    final String packType = cartItem.packType?.toString() ?? '';
    final int piecesPerPack =
        int.tryParse(cartItem.pieces?.toString() ?? '0') ?? 0;

    // If it's just individual pieces, no need for complex calculation
    if (packType.toLowerCase() == 'pcs' ||
        packType.toLowerCase() == 'pieces' ||
        packType.isEmpty) {
      return '$quantity';
    }

    // Calculate total pieces for packs
    final int totalPieces = quantity * piecesPerPack;

    return '$totalPieces ($quantity $packType)';
  }

  @override
  Widget build(BuildContext context) {
    final bool isSpecific = widget.specificData != null;
    final dynamic data = isSpecific ? widget.specificData : widget.invoiceData;

    final DateTime? createdAt = data?.generateAt;
    final String dateString = createdAt != null
        ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
        : 'N/A';

    final String businessName = data?.businessName ?? 'N/A';
    final String email = data?.email ?? 'N/A';
    final String phone = isSpecific
        ? (widget.specificData?.mobileno ?? 'N/A')
        : (widget.invoiceData?.mobileNo ?? 'N/A');
    final String orderSource = data?.orderSource ?? '';
    final String salesmanName = data?.salesmanName ?? 'N/A';
    final String imageUrl = data?.imageUrl ?? '';
    final double orderTotal = (data?.orderTotal ?? 0).toDouble();

    final List<dynamic> cartList = data?.cart ?? [];
    final List<dynamic> taxList = data?.tax ?? [];

    final double subtotalAmount = cartList.fold<double>(0, (sum, item) {
      double itemAmount = 0.0;
      int qty = int.tryParse(item.quantity?.toString() ?? '0') ?? 0;
      try {
        itemAmount = double.tryParse(item.price?.toString() ?? '0') ?? 0.0;
      } catch (_) {}
      itemAmount = itemAmount * qty;
      return sum + itemAmount;
    });

    final double totalDiscount = cartList.fold<double>(0, (sum, item) {
      double disc = 0.0;
      try {
        disc = double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0;
      } catch (_) {}
      return sum + disc;
    });

    final double totalTax = cartList.fold<double>(0, (sum, item) {
      double itemTax = 0.0;
      try {
        itemTax = double.tryParse(item.tax?.toString() ?? '0') ?? 0.0;
      } catch (_) {}
      return sum + itemTax;
    });
    
    final double calculatedOrderTotal = isSpecific
        ? (widget.specificData?.orderTotal ?? 0).toDouble()
        : cartList.fold<double>(0, (sum, item) {
            double itemTotal = 0.0;
            try {
              itemTotal = double.tryParse(item.total?.toString() ?? '0') ?? 0.0;
            } catch (_) {}
            return sum + itemTotal;
          });

    final List<String> taxBreakdownParts = [];
    if (taxList.isNotEmpty) {
      for (final t in taxList) {
        final String name = (t.taxName ?? '').toString().trim();
        if (name.isEmpty) continue;
        if (isSpecific) {
          final double taxAmount = (t.taxAmount ?? 0).toDouble();
          taxBreakdownParts.add('$name ${taxAmount.toStringAsFixed(2)}');
        } else {
          final double percent = (t.tax ?? 0).toDouble();
          taxBreakdownParts.add('$name ${percent.toStringAsFixed(0)}%');
        }
      }
    }
    final String taxBreakdownText = taxBreakdownParts.join(', ');

    final String dialogTitle = widget.customTitle ??
        (widget.selectedTabIndex == 5
            ? 'INVOICE DETAILS'.tr
            : 'ORDER DETAILS'.tr);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context, dialogTitle, dateString),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCustomerCard(
                        businessName: businessName,
                        email: email,
                        phone: phone,
                        salesmanName: salesmanName,
                        orderSource: orderSource,
                        imageUrl: imageUrl,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          final itemNameWidth = tableWidth * 0.2;

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: tableWidth,
                                child: DataTable(
                                  dataRowHeight: 40,
                                  headingRowHeight: 40,
                                  horizontalMargin: 12,
                                  columnSpacing: 12,
                                  headingRowColor:
                                      MaterialStateProperty.all(primaryColor),
                                  headingTextStyle: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                  dataRowColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => Colors.white),
                                  columns: [
                                    DataColumn(
                                        label: SizedBox(
                                            width: itemNameWidth,
                                            child: Text('ITEM NAME'.tr))),
                                    DataColumn(
                                        label: Expanded(
                                            flex: 1,
                                            child: Text('U.PRICE'.tr,
                                                textAlign: TextAlign.center))),

                                    // CONDITIONAL COLUMN: PACK TYPE
                                    if (widget.showPackType)
                                      DataColumn(
                                          label: Expanded(
                                              flex: 1,
                                              child: Text('PACK TYPE'.tr,
                                                  textAlign:
                                                      TextAlign.center))),

                                    DataColumn(
                                        label: Expanded(
                                            flex: 1,
                                            child: Text('QTY'.tr,
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            flex: 1,
                                            child: Text('AMOUNT'.tr,
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            flex: 1,
                                            child: Text('DISCOUNT'.tr,
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            flex: 1,
                                            child: Text('TAX'.tr,
                                                textAlign: TextAlign.center))),
                                    DataColumn(
                                        label: Expanded(
                                            flex: 1,
                                            child: Text('TOTAL'.tr,
                                                textAlign: TextAlign.right))),
                                  ],
                                  rows: cartList.isNotEmpty
                                      ? List.generate(
                                          cartList.length,
                                          (index) {
                                            final cartItem = cartList[index];

                                            // --- EXTRACT VALUES SAFELY ---
                                            String unitPriceStr = '0';
                                            String amountStr = '0';
                                            String totalStr = '0';
                                            String discountStr = '0';
                                            String taxStr = '0';

                                            int qty = int.tryParse(cartItem.quantity?.toString() ?? '0') ?? 0;

                                            if (isSpecific) {
                                              try {
                                                unitPriceStr = cartItem.unitPrice?.toString() ?? '0';
                                              } catch (_) {
                                                unitPriceStr = '0';
                                              }
                                              if (unitPriceStr == '0' || unitPriceStr.isEmpty || unitPriceStr == 'null') {
                                                try {
                                                  unitPriceStr = cartItem.price?.toString() ?? '0';
                                                } catch (_) {}
                                              }
                                              
                                              double packPrice = 0.0;
                                              try {
                                                packPrice = double.tryParse(cartItem.price?.toString() ?? '0') ?? 0.0;
                                              } catch (_) {}
                                              
                                              amountStr = (packPrice * qty).toString();
                                              
                                              try {
                                                totalStr = cartItem.totalPrice?.toString() ?? '0';
                                              } catch (_) {}
                                            } else {
                                              try {
                                                unitPriceStr = cartItem.price?.toString() ?? '0';
                                              } catch (_) {}
                                              
                                              double price = double.tryParse(unitPriceStr) ?? 0.0;
                                              amountStr = (price * qty).toString();
                                              
                                              try {
                                                totalStr = cartItem.total?.toString() ?? '0';
                                              } catch (_) {}
                                            }

                                            try {
                                              discountStr = cartItem.discountAmount?.toString() ?? '0';
                                            } catch (_) {}
                                            try {
                                              taxStr = cartItem.tax?.toString() ?? '0';
                                            } catch (_) {}

                                            return DataRow(
                                              cells: [
                                                DataCell(Tooltip(
                                                    message:
                                                        "${cartItem.productName} - ${cartItem.variationName}",
                                                    preferBelow: false,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black87,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: SizedBox(
                                                        width: itemNameWidth,
                                                        child:
                                                            ProductNameWithTax(
                                                          productName: cartItem
                                                              .productName
                                                              .toString(),
                                                          variationName:
                                                              cartItem
                                                                  .variationName
                                                                  .toString(),
                                                          isInclTax: cartItem
                                                                  .inclTax ==
                                                              "incl_tax",
                                                          maxWidth:
                                                              itemNameWidth,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                        )))),
                                                DataCell(Center(
                                                    child: Text(
                                                        formatAmount(
                                                            unitPriceStr),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12)))),

                                                // CONDITIONAL CELL: PACK TYPE (Only shown if enabled)
                                                if (widget.showPackType)
                                                  DataCell(Center(
                                                    child: Text(
                                                      (cartItem.packType
                                                                      ?.toString()
                                                                      .toLowerCase() ==
                                                                  'pcs' &&
                                                              cartItem.pieces
                                                                      ?.toString() ==
                                                                  '1')
                                                          ? 'Pieces'
                                                          : '${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  )),

                                                // CONDITIONAL QTY CELL
                                                DataCell(Center(
                                                    child: Text(
                                                  _getQuantityText(
                                                      cartItem), // Use helper here
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ))),

                                                DataCell(Center(
                                                    child: Text(
                                                        formatAmount(amountStr),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12)))),
                                                DataCell(Center(
                                                    child: Text(
                                                        formatAmount(
                                                            discountStr),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12)))),
                                                DataCell(Center(
                                                    child: Text(
                                                        formatAmount(taxStr),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12)))),
                                                DataCell(Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                        formatAmount(totalStr),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)))),
                                              ],
                                            );
                                          },
                                        )
                                      : [
                                          DataRow(cells: [
                                            DataCell(
                                                Text('No items available.'.tr)),
                                            const DataCell(Text('')),
                                            if (widget.showPackType)
                                              const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text(''))
                                          ]),
                                        ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTotalsCard(
                        subtotalAmount: subtotalAmount,
                        totalDiscount: totalDiscount,
                        totalTax: totalTax,
                        taxBreakdownText: taxBreakdownText,
                        calculatedOrderTotal: calculatedOrderTotal,
                      ),
                      if (widget.selectedTabIndex == 6) ...[
                        const SizedBox(height: 16),
                        _buildRejectionInfo(data),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* --------------------------------------------------------------
     DIALOG HEADER – gradient bar replacing the old plain
     Spacer()+dialogCloseButton1 row. The close action is the exact
     same Navigator.of(context).pop() the plain close button used.
     -------------------------------------------------------------- */
  Widget _buildDialogHeader(
      BuildContext context, String title, String dateString) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_outlined,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${'Created At'.tr} : ‎$dateString',
                        style: TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkResponse(
            onTap: () => Navigator.of(context).pop(),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     CUSTOMER CARD – bordered card with avatar + customer meta,
     replacing the plain black-text name/email/phone rows.
     -------------------------------------------------------------- */
  Widget _buildCustomerCard({
    required String businessName,
    required String email,
    required String phone,
    required String salesmanName,
    required String orderSource,
    required String imageUrl,
  }) {
    const labelStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: Color(0xFF94A3B8),
    );
    const nameStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF0F172A),
    );
    const metaStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: 12.5,
      color: Color(0xFF64748B),
      height: 1.5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CUSTOMER'.tr.toUpperCase(), style: labelStyle),
                const SizedBox(height: 8),
                Text(businessName, style: nameStyle),
                const SizedBox(height: 8),
                Text('${'Email'.tr}: $email', style: metaStyle),
                Text('${'Phone'.tr}: $phone', style: metaStyle),
                if (orderSource == 'app')
                  Text('${'Staff'.tr}: $salesmanName', style: metaStyle),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipOval(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: primaryColor.withOpacity(0.15), width: 2),
              ),
              child: Image.network(
                "${ApiConstants.imageBaseUrl}$imageUrl",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.lightBlue[100],
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     TOTALS CARD
     -------------------------------------------------------------- */
  Widget _buildTotalsCard({
    required double subtotalAmount,
    required double totalDiscount,
    required double totalTax,
    required String taxBreakdownText,
    required double calculatedOrderTotal,
  }) {
    final bool showTax = totalTax > 0 || taxBreakdownText.isNotEmpty;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _totalRow('Subtotal'.tr, formatAmount(subtotalAmount)),
            const SizedBox(height: 8),
            _totalRow('Discount'.tr, formatAmount(totalDiscount)),
            if (showTax) ...[
              const SizedBox(height: 8),
              _totalRow(
                taxBreakdownText.isNotEmpty
                    ? '${'Tax'.tr}  $taxBreakdownText'
                    : 'Tax'.tr,
                formatAmount(totalTax),
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 10),
            _totalRow(
              'Total'.tr,
              formatAmount(calculatedOrderTotal.toString()),
              isEmphasis: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isEmphasis = false}) {
    final labelStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: isEmphasis ? 13.5 : 12.5,
      fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
      color: isEmphasis ? const Color(0xFF0F172A) : const Color(0xFF64748B),
    );
    final valueStyle = TextStyle(
      fontFamily: 'Poppins_Regular',
      fontSize: isEmphasis ? 15 : 12.5,
      fontWeight: FontWeight.w700,
      color: isEmphasis ? primaryColor : const Color(0xFF0F172A),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: labelStyle)),
        const SizedBox(width: 10),
        Text(value, style: valueStyle),
      ],
    );
  }

  /* --------------------------------------------------------------
     REJECTION INFO – only shown for the rejected-orders tab
     (selectedTabIndex == 6), same data as before, restyled as a
     small tinted card instead of a plain centered Row.
     -------------------------------------------------------------- */
  Widget _buildRejectionInfo(dynamic data) {
    final String reason = data?.rejectionReason?.toString() ?? '';
    final String rejectedDate = NKDateUtils.commonDayFormat2(
        NKDateUtils.formatStringUTCDateTime(
            data?.rejectedDate.toString() ?? ''));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: red.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'Rejection Reason : '.tr}$reason',
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rejectedDate,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductNameWithTax extends StatelessWidget {
  final String productName;
  final String variationName;
  final bool isInclTax;
  final double maxWidth;
  final TextStyle style;
  final Color taxColor;

  const ProductNameWithTax({
    super.key,
    required this.productName,
    required this.variationName,
    required this.isInclTax,
    required this.maxWidth,
    required this.style,
    this.taxColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final suffix = isInclTax ? ' (Incl. Tax)' : '';

    final fullText = '$productName - $variationName';
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );

    for (int i = fullText.length; i >= 0; i--) {
      final truncated = fullText.substring(0, i).trimRight();
      final span = TextSpan(
        text: '$truncated$suffix',
        style: style,
      );
      textPainter.text = span;
      textPainter.layout(maxWidth: maxWidth);

      if (!textPainter.didExceedMaxLines) {
        return Text.rich(
          TextSpan(
            text: truncated,
            style: style,
            children: [
              if (i != fullText.length) const TextSpan(text: '...'),
              if (isInclTax)
                TextSpan(
                  text: suffix,
                  style: style.copyWith(fontSize: 12, color: taxColor),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        );
      }
    }

    // fallback
    return Text(
      suffix,
      style: style,
    );
  }
}
