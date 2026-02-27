import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderProcessInvoiceDialog extends StatefulWidget {
  OrderProcessInvoiceData? invoiceData;
  SpecificOrderData? specificData;
  final int selectedTabIndex;
  final OrderController orderController;
  OrderProcessInvoiceDialog({
    super.key,
    this.invoiceData,
    this.specificData,
    required this.selectedTabIndex,
    required this.orderController,
  });

  @override
  State<OrderProcessInvoiceDialog> createState() =>
      _OrderProcessInvoiceDialogState();
}
class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
  bool isRejecting = false;
  bool isChanged = false;
  @override
  Widget build(BuildContext context) {
    // 1. Determine which API data was passed to the dialog
    final bool isSpecific = widget.specificData != null;
    
    // Use 'dynamic' to access shared properties
    final dynamic data = isSpecific ? widget.specificData : widget.invoiceData;
    
    // --- EXTRACT COMMON HEADER INFO ---
    final DateTime? createdAt = data?.orderCreatAt; 
    final String dateString = createdAt != null
        ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
        : 'N/A';

    final String businessName = data?.businessName ?? 'N/A';
    final String email = data?.email ?? 'N/A';
    final String phone = isSpecific ? (widget.specificData?.mobileno ?? 'N/A') : (widget.invoiceData?.mobileNo ?? 'N/A');
    final String orderSource = data?.orderSource ?? '';
    final String salesmanName = data?.salesmanName ?? 'N/A';
    final String imageUrl = data?.imageUrl ?? '';
    final double orderTotal = (data?.orderTotal ?? 0).toDouble();
    
    final List<dynamic> cartList = data?.cart ?? [];
    final List<dynamic> taxList = data?.tax ?? [];

    // --- CALCULATE SUMMARY VALUES SAFELY ---

    // 1. Calculate Subtotal 
    final double subtotalAmount = cartList.fold<double>(
      0, (sum, item) {
        double itemAmount = 0.0;
        if (isSpecific) {
          try { itemAmount = (item.price ?? 0).toDouble(); } catch(_) { try { itemAmount = (item.unitPrice ?? 0).toDouble(); } catch(_) {} }
        } else {
          // OLD API: Use 'price' as requested
          try { itemAmount = (item.price ?? 0).toDouble(); } catch(_) {}
        }
        return sum + itemAmount;
      }
    );

    // 2. Calculate Total Discount 
    final double totalDiscount = cartList.fold<double>(
      0, (sum, item) {
        double disc = 0.0;
        try { disc = double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0; } catch(_) {}
        return sum + disc;
      }
    );

    // 3. Calculate Total Tax (Sum of 'tax' field from ALL cart items)
    // This fixes the issue where the main 'tax' array is empty but items have taxes.
    final double totalTax = cartList.fold<double>(
      0, (sum, item) {
        double itemTax = 0.0;
        try { itemTax = double.tryParse(item.tax?.toString() ?? '0') ?? 0.0; } catch(_) {}
        return sum + itemTax;
      }
    );

    // 4. Build Tax Breakdown Widgets (Only if 'tax' array exists)
    List<Widget> taxWidgets = [];
    if (taxList.isNotEmpty) {
      for (var t in taxList) {
        double tPercent = (t.tax ?? 0).toDouble();
        double tAmount = 0.0;
        try {
          tAmount = (t.taxAmount ?? 0).toDouble();
        } catch (e) {
          tAmount = (tPercent * orderTotal) / 100;
        }
        
        taxWidgets.add(
          Text(
            '${t.taxName ?? ''} (${tPercent.toStringAsFixed(0)}%)',
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          )
        );
      }
    }

    return Dialog(
      insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  dialogCloseButton1(context, red),
                ],
              ),
              const SizedBox(height: 16),
              MyCommnonContainer(
                isCommonBorder: true,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.selectedTabIndex == 5 ? 'INVOICE DETAILS' : 'ORDER DETAILS',
                          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          'Created At : $dateString',
                          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name :   $businessName"),
                            Text("Email :   $email"),
                            Text("Phone :   $phone"),
                            if (orderSource == 'app') Text("Staff :   $salesmanName"),
                          ],
                        ),
                        const Spacer(),
                        ClipOval(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: Image.network(
                              'https://test.thrivewoo.com/uploads/$imageUrl',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.lightBlue[100], child: const Icon(Icons.person, color: Colors.blue)),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: isPhonePortrait(context) ? fullScreenWidth(context) * 2 : fullScreenWidth(context) * 0.85,
                        child: DataTable(
                          dataRowHeight: 40,
                          headingRowHeight: 40,
                          horizontalMargin: 20,
                          headingTextStyle: const TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w600),
                          columns: [
                            DataColumn(label: SizedBox(width: isPhonePortrait(context) ? fullScreenWidth(context) * 0.4 : fullScreenWidth(context) * 0.2, child: const Text('ITEM NAME'))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('U.PRICE', textAlign: TextAlign.center))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('PACKTYPE', textAlign: TextAlign.center))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.center))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('DISCOUNT', textAlign: TextAlign.center))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('TAX', textAlign: TextAlign.center))),
                            const DataColumn(label: Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right))),
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

                                    if (isSpecific) {
                                      try { unitPriceStr = cartItem.unitPrice?.toString() ?? '0'; } catch(_) { try { unitPriceStr = cartItem.price?.toString() ?? '0'; } catch(_) {} }
                                      try { amountStr = cartItem.price?.toString() ?? '0'; } catch(_) {}
                                      try { totalStr = cartItem.totalPrice?.toString() ?? '0'; } catch(_) {}
                                    } else {
                                      try { unitPriceStr = cartItem.unitPrice?.toString() ?? '0'; } catch(_) { try { unitPriceStr = cartItem.price?.toString() ?? '0'; } catch(_) {} }
                                      try { amountStr = cartItem.price?.toString() ?? '0'; } catch(_) {}
                                      try { totalStr = cartItem.total?.toString() ?? '0'; } catch(_) {}
                                    }

                                    try { discountStr = cartItem.discountAmount?.toString() ?? '0'; } catch(_) {}
                                    try { taxStr = cartItem.tax?.toString() ?? '0'; } catch(_) {}

                                    return DataRow(
                                      cells: [
                                        DataCell(Tooltip(message: "${cartItem.productName} - ${cartItem.variationName}", preferBelow: false, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)), child: SizedBox(width: isPhonePortrait(context) ? fullScreenWidth(context) * 0.4 : fullScreenWidth(context) * 0.2, child: ProductNameWithTax(productName: cartItem.productName.toString(), variationName: cartItem.variationName.toString(), isInclTax: cartItem.inclTax == "incl_tax", maxWidth: isPhonePortrait(context) ? fullScreenWidth(context) * 0.4 : fullScreenWidth(context) * 0.2, style: const TextStyle(fontSize: 14))))),
                                        DataCell(Center(child: Text(formatAmount(unitPriceStr),maxLines: 1, overflow: TextOverflow.ellipsis))),
                                        DataCell(Center(
                  child: Text(
                      '${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis))),
                                        // DataCell(Center(child: Text('${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)'),)),
                                      DataCell(Center(
                  child: Text('${cartItem.quantity ?? 0}',
                      maxLines: 1, overflow: TextOverflow.ellipsis))),
                                       DataCell(Center(
                  child: Text(formatAmount(amountStr),
                      maxLines: 1, overflow: TextOverflow.ellipsis))),
                                      DataCell(Center(
                  child: Text(formatAmount(discountStr),
                      maxLines: 1, overflow: TextOverflow.ellipsis))),
                                       DataCell(Center(
                  child: Text(formatAmount(taxStr),
                      maxLines: 1, overflow: TextOverflow.ellipsis))),
                                       DataCell(Align(
                  alignment: Alignment.centerRight,
                  child: Text(formatAmount(totalStr),
                      maxLines: 1, overflow: TextOverflow.ellipsis))),
                                      ],
                                    );
                                  },
                                )
                              : [
                                  const DataRow(cells: [DataCell(Text('No items available.')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text(''))]),
                                ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // --- SUBTOTAL ---
                    Row(
                      children: [
                        const Text('Subtotal', style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text(formatAmount(subtotalAmount)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // --- DISCOUNT ---
                    Row(
                      children: [
                        const Text('Discount', style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text(formatAmount(totalDiscount)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // --- TOTAL TAX ROW (Show if totalTax > 0, regardless of breakdown) ---
                    if (totalTax > 0) 
                      Row(
                        children: [
                          const Text('Total Tax', style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(formatAmount(totalTax)),
                        ],
                      ),
                    
                    if (totalTax > 0) const SizedBox(height: 8),

                    // --- TAX BREAKDOWN (Show only if we have specific tax details) ---
                    if (taxWidgets.isNotEmpty) 
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Taxes - ', style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500)),
                          Expanded(
                            child: Wrap(spacing: 16.0, runSpacing: 4.0, children: taxWidgets),
                          ),
                        ],
                      ),
                      
                    Divider(color: Colors.grey.shade400),
                    Row(
                      children: [
                        const Text('Total', style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(formatAmount(orderTotal.toString()), style: const TextStyle(fontSize: 16, color: red, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.selectedTabIndex == 6) ...[
                    const Text('Rejection Reason : '),
                    Text((data?.rejectionReason?.toString() ?? '')),
                    Text(NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(data?.rejectedDate.toString() ?? ''))),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   // 1. Determine which API data was passed to the dialog
  //   final bool isSpecific = widget.specificData != null;
    
  //   // We use 'dynamic' to easily access shared properties without repeating code
  //   final dynamic data = isSpecific ? widget.specificData : widget.invoiceData;
    
  //   // --- EXTRACT COMMON HEADER INFO ---
  //   final DateTime? createdAt = data?.orderCreatAt; 
  //   final String dateString = createdAt != null
  //       ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
  //       : 'N/A';

  //   final String businessName = data?.businessName ?? 'N/A';
  //   final String email = data?.email ?? 'N/A';
  //   final String phone = isSpecific ? (widget.specificData?.mobileno ?? 'N/A') : (widget.invoiceData?.mobileNo ?? 'N/A');
  //   final String orderSource = data?.orderSource ?? '';
  //   final String salesmanName = data?.salesmanName ?? 'N/A';
  //   final String imageUrl = data?.imageUrl ?? '';
  //   final double orderTotal = (data?.orderTotal ?? 0).toDouble();
    
  //   final List<dynamic> cartList = data?.cart ?? [];
  //   final List<dynamic> taxList = data?.tax ?? [];

  //   // --- CALCULATE SUMMARY VALUES SAFELY ---
  //   // Calculate Subtotal 
  //   final double subtotalAmount = cartList.fold<double>(
  //     0, (sum, item) {
  //       double itemAmount = 0.0;
  //       if (isSpecific) {
  //         try { itemAmount = (item.price ?? 0).toDouble(); } catch(_) {}
  //       } else {
  //         try { itemAmount = (item.price ?? 0).toDouble(); } catch(_) {}
  //       }
  //       return sum + itemAmount;
  //     }
  //   );

  //   // Calculate Total Discount 
  //   final double totalDiscount = cartList.fold<double>(
  //     0, (sum, item) {
  //       double disc = 0.0;
  //       try { disc = double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0; } catch(_) {}
  //       return sum + disc;
  //     }
  //   );

  //   // Calculate Total Tax & Build Tax UI Elements
  //   double totalTax = 0.0;
  //   List<Widget> taxWidgets = [];
    
  //   for (var t in taxList) {
  //     double tPercent = (t.tax ?? 0).toDouble();
  //     double tAmount = 0.0;
      
  //     try {
  //       tAmount = (t.taxAmount ?? 0).toDouble();
  //     } catch (e) {
  //       tAmount = (tPercent * orderTotal) / 100;
  //     }
      
  //     totalTax += tAmount;
      
  //     taxWidgets.add(
  //       Text(
  //         '${t.taxName ?? ''} (${tPercent.toStringAsFixed(0)}%): ${formatAmount(tAmount)}',
  //         style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
  //       )
  //     );
  //   }

  //   return Dialog(
  //     insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  //     backgroundColor: white,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               children: [
  //                 const Spacer(),
  //                 dialogCloseButton1(context, red),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             MyCommnonContainer(
  //               isCommonBorder: true,
  //               padding: const EdgeInsets.all(15),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Text(
  //                         widget.selectedTabIndex == 5
  //                             ? 'INVOICE DETAILS'
  //                             : 'ORDER DETAILS',
  //                         style: const TextStyle(
  //                           color: Colors.black,
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       const Spacer(),
  //                       Text(
  //                         'Created At : $dateString',
  //                         style: const TextStyle(
  //                           color: Colors.black,
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Divider(color: Colors.grey.shade300),
  //                   Row(
  //                     children: [
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text("Name :   $businessName"),
  //                           Text("Email :   $email"),
  //                           Text("Phone :   $phone"),
  //                           if (orderSource == 'app')
  //                             Text("Staff :   $salesmanName"),
  //                         ],
  //                       ),
  //                       const Spacer(),
  //                       ClipOval(
  //                         child: Container(
  //                           height: 50,
  //                           width: 50,
  //                           child: Image.network(
  //                             'https://test.thrivewoo.com/uploads/$imageUrl',
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Container(
  //                                 color: Colors.lightBlue[100],
  //                                 child: const Icon(Icons.person, color: Colors.blue),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                       )
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: SingleChildScrollView(
  //                     scrollDirection: Axis.horizontal,
  //                     child: SizedBox(
  //                       width: isPhonePortrait(context)
  //                           ? fullScreenWidth(context) * 2
  //                           : fullScreenWidth(context) * 0.85,
  //                       child: DataTable(
  //                         // ignore: deprecated_member_use
  //                         dataRowHeight: 40,
  //                         headingRowHeight: 40,
  //                         horizontalMargin: 20,
  //                         headingTextStyle: const TextStyle(
  //                           color: black,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                         columns: [
  //                           DataColumn(
  //                             label: SizedBox(
  //                               width: isPhonePortrait(context)
  //                                   ? fullScreenWidth(context) * 0.4
  //                                   : fullScreenWidth(context) * 0.2,
  //                               child: const Text('ITEM NAME'),
  //                             ),
  //                           ),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('PRICE', textAlign: TextAlign.center))),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('PACKTYPE', textAlign: TextAlign.center))),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center))),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.center))),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('DISCOUNT', textAlign: TextAlign.center))),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('TAX', textAlign: TextAlign.center))),
  //                           const DataColumn(label: Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right))),
  //                         ],
  //                         rows: cartList.isNotEmpty
  //                             ? List.generate(
  //                                 cartList.length,
  //                                 (index) {
  //                                   final cartItem = cartList[index];
                                    
  //                                   // --- EXTRACT VALUES SAFELY ---
  //                                   String unitPriceStr = '0';
  //                                   String amountStr = '0';
  //                                   String totalStr = '0';
  //                                   String discountStr = '0';
  //                                   String taxStr = '0';

  //                                   if (isSpecific) {
  //                                     // NEW API LOGIC
  //                                     try { unitPriceStr = cartItem.unitPrice?.toString() ?? '0'; } catch(_) { try { unitPriceStr = cartItem.unitPrice?.toString() ?? '0'; } catch(_) {} }
  //                                     try { amountStr = cartItem.price?.toString() ?? '0'; } catch(_) {}
  //                                     try { totalStr = cartItem.totalPrice?.toString() ?? '0'; } catch(_) {}
  //                                   } else {
  //                                     // OLD API LOGIC
  //                                     try { unitPriceStr = cartItem.unitPrice?.toString() ?? '0'; } catch(_) { try { unitPriceStr = cartItem.unitPrice?.toString() ?? '0'; } catch(_) {} }
  //                                     // FIX: Set the AMOUNT column to the item's price field explicitly
  //                                     try { amountStr = cartItem.price?.toString() ?? '0'; } catch(_) {}
  //                                     try { totalStr = cartItem.total?.toString() ?? '0'; } catch(_) {}
  //                                   }

  //                                   // Common values for both
  //                                   try { discountStr = cartItem.discountAmount?.toString() ?? '0'; } catch(_) {}
  //                                   try { taxStr = cartItem.tax?.toString() ?? '0'; } catch(_) {}

  //                                   return DataRow(
  //                                     cells: [
  //                                       DataCell(
  //                                         Tooltip(
  //                                           message: "${cartItem.productName} - ${cartItem.variationName}",
  //                                           preferBelow: false,
  //                                           decoration: BoxDecoration(
  //                                             color: Colors.black87,
  //                                             borderRadius: BorderRadius.circular(8),
  //                                           ),
  //                                           child: SizedBox(
  //                                             width: isPhonePortrait(context)
  //                                                 ? fullScreenWidth(context) * 0.4
  //                                                 : fullScreenWidth(context) * 0.2,
  //                                             child: ProductNameWithTax(
  //                                               productName: cartItem.productName.toString(),
  //                                               variationName: cartItem.variationName.toString(),
  //                                               isInclTax: cartItem.inclTax == "incl_tax",
  //                                               maxWidth: isPhonePortrait(context)
  //                                                   ? fullScreenWidth(context) * 0.4
  //                                                   : fullScreenWidth(context) * 0.2,
  //                                               style: const TextStyle(fontSize: 14),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       DataCell(Center(child: Text(formatAmount(unitPriceStr)))),
  //                                      DataCell(Center(child: Text('${cartItem.packType?.toString() ?? '-'} (${cartItem.pieces?.toString() ?? '0'} pcs)'))),
  //                                       // DataCell(Center(child: Text(cartItem.packType?.toString() ?? '-'))),
  //                                       DataCell(Center(child: Text('${cartItem.quantity ?? 0}'))),
  //                                       DataCell(Center(child: Text(formatAmount(amountStr)))), // Amount is now guaranteed to map to .price
  //                                       DataCell(Center(child: Text(formatAmount(discountStr), maxLines: 1))),
  //                                       DataCell(Center(child: Text(formatAmount(taxStr)))),
  //                                       DataCell(
  //                                         Align(
  //                                             alignment: Alignment.centerRight,
  //                                             child: Text.rich(TextSpan(text: formatAmount(totalStr)), maxLines: 1)),
  //                                       ),
  //                                     ],
  //                                   );
  //                                 },
  //                               )
  //                             : [
  //                                 const DataRow(
  //                                   cells: [
  //                                     DataCell(Text('No items available.')),
  //                                     DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
  //                                     DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
  //                                   ],
  //                                 ),
  //                               ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Padding(
  //               padding: const EdgeInsets.all(20.0),
  //               child: Column(
  //                 children: [
  //                   // --- SUBTOTAL ROW ---
  //                   Row(
  //                     children: [
  //                       const Text(
  //                         'Subtotal',
  //                         style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
  //                       ),
  //                       const Spacer(),
  //                       Text(formatAmount(subtotalAmount)),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 8),

  //                   // --- DISCOUNT ROW ---
  //                   Row(
  //                     children: [
  //                       const Text(
  //                         'Discount',
  //                         style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
  //                       ),
  //                       const Spacer(),
  //                       Text(formatAmount(totalDiscount)),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 8),

  //                   // --- TAXES ROW ---
  //                   if (taxWidgets.isNotEmpty) 
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         const Text(
  //                           'Taxes - ',
  //                           style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
  //                         ),
  //                         Expanded(
  //                           flex: 3,
  //                           child: Wrap(
  //                             spacing: 16.0, 
  //                             runSpacing: 4.0, 
  //                             children: taxWidgets,
  //                           ),
  //                         ),
  //                         const Spacer(),
  //                         Text(formatAmount(totalTax)),
  //                       ],
  //                     ),
                      
  //                   Divider(color: Colors.grey.shade400),
  //                   Row(
  //                     children: [
  //                       const Text(
  //                         'Total',
  //                         style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w600),
  //                       ),
  //                       const Spacer(),
  //                       Text(
  //                         formatAmount(orderTotal.toString()),
  //                         style: const TextStyle(fontSize: 16, color: red, fontWeight: FontWeight.w600),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 if (widget.selectedTabIndex == 6) ...[
  //                   const Text('Rejection Reason : '),
  //                   Text((data?.rejectionReason?.toString() ?? '')),
  //                   Text(NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(data?.rejectedDate.toString() ?? ''))),
  //                 ],
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
// }
// class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
//   bool isRejecting = false;
//   bool isChanged = false;

//   @override
//   Widget build(BuildContext context) {
//     // 1. Determine which API data was passed to the dialog
//     final bool isSpecific = widget.specificData != null;
//     print('isSpecific: $isSpecific'); // Debug log
    
//     // We use 'dynamic' to easily access shared properties without repeating code
//     final dynamic data = isSpecific ? widget.specificData : widget.invoiceData;
    
//     // --- EXTRACT COMMON HEADER INFO ---
//     final DateTime? createdAt = data?.orderCreatAt; 
//     final String dateString = createdAt != null
//         ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
//         : 'N/A';

//     final String businessName = data?.businessName ?? 'N/A';
//     final String email = data?.email ?? 'N/A';
//     final String phone = isSpecific ? (widget.specificData?.mobileno ?? 'N/A') : (widget.invoiceData?.mobileNo ?? 'N/A');
//     final String orderSource = data?.orderSource ?? '';
//     final String salesmanName = data?.salesmanName ?? 'N/A';
//     final String imageUrl = data?.imageUrl ?? '';
//     final double orderTotal = (data?.orderTotal ?? 0).toDouble();
    
//     final List<dynamic> cartList = data?.cart ?? [];
//     final List<dynamic> taxList = data?.tax ?? [];

//     // --- CALCULATE SUMMARY VALUES ---
//     // Calculate Subtotal 
//     final double subtotalAmount = cartList.fold<double>(
//       0, (sum, item) {
//         // FIX: The old API uses 'total', the new API uses 'price' for the subtotal amount
//         final num itemAmount = isSpecific ? (item.price ?? 0) : (item.total ?? 0);
//         return sum + itemAmount.toDouble();
//       }
//     );

//     // Calculate Total Discount 
//     final double totalDiscount = cartList.fold<double>(
//       0, (sum, item) => sum + (double.tryParse(item.discountAmount?.toString() ?? '0') ?? 0.0)
//     );

//     // Calculate Total Tax & Build Tax UI Elements
//     double totalTax = 0.0;
//     List<Widget> taxWidgets = [];
    
//     for (var t in taxList) {
//       double tPercent = (t.tax ?? 0).toDouble();
//       double tAmount = 0.0;
      
//       // FIX: Safely try to get 'taxAmount' if the model has it, otherwise fallback to manual calculation
//       try {
//         tAmount = (t.taxAmount ?? 0).toDouble();
//       } catch (e) {
//         tAmount = (tPercent * orderTotal) / 100;
//       }
      
//       totalTax += tAmount;
      
//       taxWidgets.add(
//         Text(
//           '${t.taxName ?? ''} (${tPercent.toStringAsFixed(0)}%): ${formatAmount(tAmount)}',
//           style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
//         )
//       );
//     }

//     return Dialog(
//       insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       backgroundColor: white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
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
//               MyCommnonContainer(
//                 isCommonBorder: true,
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           widget.selectedTabIndex == 5
//                               ? 'INVOICE DETAILS'
//                               : 'ORDER DETAILS',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           'Created At : $dateString',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Divider(color: Colors.grey.shade300),
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Name :   $businessName"),
//                             Text("Email :   $email"),
//                             Text("Phone :   $phone"),
//                             if (orderSource == 'app')
//                               Text("Staff :   $salesmanName"),
//                           ],
//                         ),
//                         const Spacer(),
//                         ClipOval(
//                           child: Container(
//                             height: 50,
//                             width: 50,
//                             child: Image.network(
//                               'https://test.thrivewoo.com/uploads/$imageUrl',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.lightBlue[100],
//                                   child: const Icon(Icons.person, color: Colors.blue),
//                                 );
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: SizedBox(
//                         width: isPhonePortrait(context)
//                             ? fullScreenWidth(context) * 2
//                             : fullScreenWidth(context) * 0.85,
//                         child: DataTable(
//                           // ignore: deprecated_member_use
//                           dataRowHeight: 40,
//                           headingRowHeight: 40,
//                           horizontalMargin: 20,
//                           headingTextStyle: const TextStyle(
//                             color: black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           columns: [
//                             DataColumn(
//                               label: SizedBox(
//                                 width: isPhonePortrait(context)
//                                     ? fullScreenWidth(context) * 0.4
//                                     : fullScreenWidth(context) * 0.2,
//                                 child: const Text('ITEM NAME'),
//                               ),
//                             ),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('PRICE', textAlign: TextAlign.center))),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('PACK TYPE', textAlign: TextAlign.center))),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center))),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.center))),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('DISCOUNT', textAlign: TextAlign.center))),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('TAX', textAlign: TextAlign.center))),
//                             const DataColumn(label: Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right))),
//                           ],
//                           rows: cartList.isNotEmpty
//                               ? List.generate(
//                                   cartList.length,
//                                   (index) {
//                                     final cartItem = cartList[index];
//                                     return DataRow(
//                                       cells: [
//                                         DataCell(
//                                           Tooltip(
//                                             message: "${cartItem.productName} - ${cartItem.variationName}",
//                                             preferBelow: false,
//                                             decoration: BoxDecoration(
//                                               color: Colors.black87,
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: SizedBox(
//                                               width: isPhonePortrait(context)
//                                                   ? fullScreenWidth(context) * 0.4
//                                                   : fullScreenWidth(context) * 0.2,
//                                               child: ProductNameWithTax(
//                                                 productName: cartItem.productName.toString(),
//                                                 variationName: cartItem.variationName.toString(),
//                                                 isInclTax: cartItem.inclTax == "incl_tax",
//                                                 maxWidth: isPhonePortrait(context)
//                                                     ? fullScreenWidth(context) * 0.4
//                                                     : fullScreenWidth(context) * 0.2,
//                                                 style: const TextStyle(fontSize: 14),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         // PRICE
//                                         DataCell(Center(child: Text(formatAmount(isSpecific ? (cartItem.unitPrice?.toString() ?? '0') : (cartItem.price?.toString() ?? '0'))))),
//                                         // PACK TYPE
//                                         DataCell(Center(child: Text(cartItem.packType?.toString() ?? '-'))),
//                                         // QTY
//                                         DataCell(Center(child: Text('${cartItem.quantity ?? 0}'))),
//                                         // AMOUNT (FIXED: old API uses total)
//                                         DataCell(Center(child: Text(formatAmount(isSpecific ? (cartItem.price?.toString() ?? '0') : (cartItem.total?.toString() ?? '0'))))),
//                                         // DISCOUNT
//                                         DataCell(Center(child: Text(formatAmount(cartItem.discountAmount?.toString() ?? '0'), maxLines: 1))),
//                                         // TAX
//                                         DataCell(Center(child: Text(formatAmount(cartItem.tax?.toString() ?? '0')))),
//                                         // TOTAL (FIXED: old API uses total)
//                                         DataCell(
//                                           Align(
//                                               alignment: Alignment.centerRight,
//                                               child: Text.rich(TextSpan(text: formatAmount(isSpecific ? (cartItem.totalPrice?.toString() ?? '0') : (cartItem.total?.toString() ?? '0'))), maxLines: 1)),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 )
//                               : [
//                                   const DataRow(
//                                     cells: [
//                                       DataCell(Text('No items available.')),
//                                       DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
//                                       DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
//                                     ],
//                                   ),
//                                 ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     // --- SUBTOTAL ROW ---
//                     Row(
//                       children: [
//                         const Text(
//                           'Subtotal',
//                           style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         const Spacer(),
//                         Text(formatAmount(subtotalAmount)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // --- DISCOUNT ROW ---
//                     Row(
//                       children: [
//                         const Text(
//                           'Discount',
//                           style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         const Spacer(),
//                         Text(formatAmount(totalDiscount)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // --- TAXES ROW ---
//                     if (taxWidgets.isNotEmpty) 
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Taxes - ',
//                             style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Wrap(
//                               spacing: 16.0, 
//                               runSpacing: 4.0, 
//                               children: taxWidgets,
//                             ),
//                           ),
//                           const Spacer(),
//                           Text(formatAmount(totalTax)),
//                         ],
//                       ),
                      
//                     Divider(color: Colors.grey.shade400),
//                     Row(
//                       children: [
//                         const Text(
//                           'Total',
//                           style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const Spacer(),
//                         Text(
//                           formatAmount(orderTotal.toString()),
//                           style: const TextStyle(fontSize: 16, color: red, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (widget.selectedTabIndex == 6) ...[
//                     const Text('Rejection Reason : '),
//                     Text((data?.rejectionReason?.toString() ?? '')),
//                     Text(NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(data?.rejectedDate.toString() ?? ''))),
//                   ],
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
//   bool isRejecting = false;
//   bool isChanged = false;
// @override
//   Widget build(BuildContext context) {
//     final data = widget.specificData; 
    
//     final DateTime? createdAt = data?.orderCreatAt; 
//     final String dateString = createdAt != null
//         ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
//         : 'N/A';

//     // 1. Calculate the Subtotal (Sum of all amounts/prices)
//     final double subtotalAmount = data?.cart?.fold<double>(
//             0, (sum, item) => sum + (item.price ?? 0).toDouble()) ??
//         0.0;

//     // 2. Calculate the Total Discount (Sum of all discount amounts)
//     final double totalDiscount = data?.cart?.fold<double>(
//             0,
//             (sum, item) =>
//                 sum +
//                 (double.tryParse(item.discountAmount?.toString() ?? '0') ??
//                     0.0)) ??
//         0.0;

//     // 3. NEW: Calculate the Total Tax (Sum of all tax amounts from the tax list)
//     final double totalTax = data?.tax?.fold<double>(
//             0, 
//             (sum, taxItem) => sum + (taxItem.taxAmount?.toDouble() ?? 0.0)) ?? 
//         0.0;

//     return Dialog(
//       insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       backgroundColor: white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
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
//               MyCommnonContainer(
//                 isCommonBorder: true,
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           widget.selectedTabIndex == 5
//                               ? 'INVOICE DETAILS'
//                               : 'ORDER DETAILS',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           'Created At : $dateString',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Divider(color: Colors.grey.shade300),
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Name :   ${data?.businessName ?? 'N/A'}"),
//                             Text("Email :   ${data?.email ?? 'N/A'}"),
//                             Text("Phone :   ${data?.mobileno ?? 'N/A'}"),
//                             if (data?.orderSource == 'app')
//                               Text("Staff :   ${data?.salesmanName ?? 'N/A'}"),
//                           ],
//                         ),
//                         const Spacer(),
//                         ClipOval(
//                           child: Container(
//                             height: 50,
//                             width: 50,
//                             child: Image.network(
//                               'https://test.thrivewoo.com/uploads/${data?.imageUrl ?? ''}',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.lightBlue[100],
//                                   child: const Icon(Icons.person,
//                                       color: Colors.blue),
//                                 );
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: SizedBox(
//                         width: isPhonePortrait(context)
//                             ? fullScreenWidth(context) * 2
//                             : fullScreenWidth(context) * 0.85,
//                         child: DataTable(
//                           // ignore: deprecated_member_use
//                           dataRowHeight: 40,
//                           headingRowHeight: 40,
//                           horizontalMargin: 20,
//                           headingTextStyle: const TextStyle(
//                             color: black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           columns: [
//                             DataColumn(
//                               label: SizedBox(
//                                 width: isPhonePortrait(context)
//                                     ? fullScreenWidth(context) * 0.4
//                                     : fullScreenWidth(context) * 0.2,
//                                 child: const Text('ITEM NAME'),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('PRICE', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('PACK TYPE', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('DISCOUNT', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('TAX', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right)),
//                             ),
//                           ],
//                           rows: (data?.cart != null && data!.cart!.isNotEmpty)
//                               ? List.generate(
//                                   data.cart!.length,
//                                   (index) {
//                                     final cartItem = data.cart![index];
//                                     return DataRow(
//                                       cells: [
//                                         DataCell(
//                                           Tooltip(
//                                             message: "${cartItem.productName} - ${cartItem.variationName}",
//                                             preferBelow: false,
//                                             decoration: BoxDecoration(
//                                               color: Colors.black87,
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: SizedBox(
//                                               width: isPhonePortrait(context)
//                                                   ? fullScreenWidth(context) * 0.4
//                                                   : fullScreenWidth(context) * 0.2,
//                                               child: ProductNameWithTax(
//                                                 productName: cartItem.productName.toString(),
//                                                 variationName: cartItem.variationName.toString(),
//                                                 isInclTax: cartItem.inclTax == "incl_tax",
//                                                 maxWidth: isPhonePortrait(context)
//                                                     ? fullScreenWidth(context) * 0.4
//                                                     : fullScreenWidth(context) * 0.2,
//                                                 style: const TextStyle(fontSize: 14),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.unitPrice?.toString() ?? '0')))),
//                                         DataCell(Center(child: Text(cartItem.packType?.toString() ?? '-'))),
//                                         DataCell(
//                                           Center(
//                                             child:
//                                             Text(
//                                                '${cartItem.quantity ?? 0}'
//                                             )
//                                             //  Text(
//                                             //   (cartItem.packType == 'Pack' || cartItem.packType == 'Carton' || cartItem.packType == 'box')
//                                             //       ? '${(cartItem.pieces ?? 0) * (cartItem.quantity?.toInt() ?? 0)} (${cartItem.quantity ?? 0} ${cartItem.packType})'
//                                             //       : '${cartItem.quantity ?? 0}',
//                                             // ),
//                                           ),
//                                         ),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.price?.toString() ?? '0')))),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.discountAmount?.toString() ?? '0'), maxLines: 1))),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.tax?.toString() ?? '0')))),
//                                         DataCell(
//                                           Align(
//                                               alignment: Alignment.centerRight,
//                                               child: Text.rich(TextSpan(text: formatAmount(cartItem.totalPrice?.toString() ?? '0')), maxLines: 1)),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 )
//                               : [
//                                   const DataRow(
//                                     cells: [
//                                       DataCell(Text('No items available.')),
//                                       DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
//                                       DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
//                                     ],
//                                   ),
//                                 ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     // --- SUBTOTAL ROW ---
//                     Row(
//                       children: [
//                         const Text(
//                           'Subtotal',
//                           style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         const Spacer(),
//                         Text(formatAmount(subtotalAmount)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // --- DISCOUNT ROW ---
//                     Row(
//                       children: [
//                         const Text(
//                           'Discount',
//                           style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         const Spacer(),
//                         Text(formatAmount(totalDiscount)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // --- NEW: TOTAL TAX ROW ---
//                     if (data?.tax != null && data!.tax!.isNotEmpty) 
//                     Row(
//                       children: [
//                        Text(
//                             'Taxes - ',
//                             style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Wrap(
//                               spacing: 16.0, 
//                               runSpacing: 4.0, 
//                               children: data.tax!.map((taxItem) {
//                                 return Text(
//                                   '${taxItem.taxName ?? ''} (${(taxItem.tax ?? 0).toStringAsFixed(0)}%): ${formatAmount(taxItem.taxAmount)}',
//                                   style: const TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         const Spacer(),
//                         Text(formatAmount(totalTax)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // --- INDIVIDUAL TAX BREAKDOWN (Your updated format) ---
//                     // if (data?.tax != null && data!.tax!.isNotEmpty) 
//                       // Row(
//                       //   crossAxisAlignment: CrossAxisAlignment.start,
//                       //   children: [
//                       //     const Text(
//                       //       'Taxes - ',
//                       //       style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                       //     ),
//                       //     Expanded(
//                       //       flex: 3,
//                       //       child: Wrap(
//                       //         spacing: 16.0, 
//                       //         runSpacing: 4.0, 
//                       //         children: data.tax!.map((taxItem) {
//                       //           return Text(
//                       //             '${taxItem.taxName ?? ''} (${(taxItem.tax ?? 0).toStringAsFixed(0)}%): ${formatAmount(taxItem.taxAmount)}',
//                       //             style: const TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),
//                       //           );
//                       //         }).toList(),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
                      
//                     Divider(color: Colors.grey.shade400),
//                     Row(
//                       children: [
//                         const Text(
//                           'Total',
//                           style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const Spacer(),
//                         Text(
//                           formatAmount(data?.orderTotal?.toString() ?? '0'),
//                           style: const TextStyle(fontSize: 16, color: red, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (widget.selectedTabIndex == 6) ...[
//                     const Text('Rejection Reason : '),
//                     Text(data?.rejectionReason?.toString() ?? ''),
//                     // nkMediumSizeBox(), 
//                     Text(NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(data?.rejectedDate.toString() ?? ''))),
//                   ],
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
//   bool isRejecting = false;
//   bool isChanged = false;

//   @override
//   Widget build(BuildContext context) {
//     // 1. Use specificData instead of invoiceData
//     final data = widget.specificData; 
    
//     // Check if your model stores this as a DateTime or String. Assuming DateTime based on your old code:
//     final DateTime? createdAt = data?.orderCreatAt; 
//     final String dateString = createdAt != null
//         ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
//         : 'N/A';

//     return Dialog(
//       insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       backgroundColor: white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
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
//               MyCommnonContainer(
//                 isCommonBorder: true,
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           widget.selectedTabIndex == 5
//                               ? 'INVOICE DETAILS'
//                               : 'ORDER DETAILS',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           'Created At : $dateString',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Divider(color: Colors.grey.shade300),
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Name :   ${data?.businessName ?? 'N/A'}"),
//                             Text("Email :   ${data?.email ?? 'N/A'}"),
//                             Text("Phone :   ${data?.mobileno ?? 'N/A'}"), // Ensure your model matches JSON 'mobileno'
//                             if (data?.orderSource == 'app')
//                               Text("Staff :   ${data?.salesmanName ?? 'N/A'}"),
//                           ],
//                         ),
//                         const Spacer(),
//                         ClipOval(
//                           child: Container(
//                             height: 50,
//                             width: 50,
//                             child: Image.network(
//                               'https://test.thrivewoo.com/uploads/${data?.imageUrl ?? ''}',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.lightBlue[100],
//                                   child: const Icon(Icons.person,
//                                       color: Colors.blue),
//                                 );
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: SizedBox(
//                         width: isPhonePortrait(context)
//                             ? fullScreenWidth(context) * 2
//                             : fullScreenWidth(context) * 0.85,
//                         child: DataTable(
//                           // ignore: deprecated_member_use
//                           dataRowHeight: 40,
//                           headingRowHeight: 40,
//                           horizontalMargin: 20,
//                           headingTextStyle: const TextStyle(
//                             color: black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           columns: [
//                             DataColumn(
//                               label: SizedBox(
//                                 width: isPhonePortrait(context)
//                                     ? fullScreenWidth(context) * 0.4
//                                     : fullScreenWidth(context) * 0.2,
//                                 child: const Text('ITEM NAME'),
//                               ),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('PRICE', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('PACK TYPE', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('AMOUNT', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('DISCOUNT', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('TAX', textAlign: TextAlign.center)),
//                             ),
//                             const DataColumn(
//                               label: Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right)),
//                             ),
//                           ],
//                           rows: (data?.cart != null && data!.cart!.isNotEmpty)
//                               ? List.generate(
//                                   data.cart!.length,
//                                   (index) {
//                                     final cartItem = data.cart![index];
//                                     return DataRow(
//                                       cells: [
//                                         DataCell(
//                                           Tooltip(
//                                             message: "${cartItem.productName} - ${cartItem.variationName}",
//                                             preferBelow: false,
//                                             decoration: BoxDecoration(
//                                               color: Colors.black87,
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: SizedBox(
//                                               width: isPhonePortrait(context)
//                                                   ? fullScreenWidth(context) * 0.4
//                                                   : fullScreenWidth(context) * 0.2,
//                                               child: ProductNameWithTax(
//                                                 productName: cartItem.productName.toString(),
//                                                 variationName: cartItem.variationName.toString(),
//                                                 isInclTax: cartItem.inclTax == "incl_tax",
//                                                 maxWidth: isPhonePortrait(context)
//                                                     ? fullScreenWidth(context) * 0.4
//                                                     : fullScreenWidth(context) * 0.2,
//                                                 style: const TextStyle(fontSize: 14),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.unitPrice?.toString() ?? '0')))),
//                                         DataCell(Center(child: Text(cartItem.packType?.toString() ?? '-'))),
//                                         DataCell(
//                                           Center(
//                                             child: Text(
//                                               (cartItem.packType == 'Pack' || cartItem.packType == 'Carton' || cartItem.packType == 'box')
//                                                   ? '${(cartItem.pieces ?? 0) * (cartItem.quantity?.toInt() ?? 0)} (${cartItem.quantity ?? 0} ${cartItem.packType})'
//                                                   : '${cartItem.quantity ?? 0}',
//                                             ),
//                                           ),
//                                         ),
//                                         // The JSON natively provides 'amount' now
//                                         DataCell(Center(child: Text(formatAmount(cartItem.price?.toString() ?? '0')))),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.discountAmount?.toString() ?? '0'), maxLines: 1))),
//                                         DataCell(Center(child: Text(formatAmount(cartItem.tax?.toString() ?? '0')))),
//                                         DataCell(
//                                           Align(
//                                               alignment: Alignment.centerRight,
//                                               child: Text.rich(TextSpan(text: formatAmount(cartItem.totalPrice?.toString() ?? '0')), maxLines: 1)),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 )
//                               : [
//                                   const DataRow(
//                                     cells: [
//                                       DataCell(Text('No items available.')),
//                                       DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
//                                       DataCell(Text('')), DataCell(Text('')), DataCell(Text('')), DataCell(Text('')),
//                                     ],
//                                   ),
//                                 ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           'Subtotal',
//                           style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         const Spacer(),
//                         // Using total_price from JSON for sum
//                         Text(formatAmount(data?.cart?.fold<num>(0, (sum, item) => sum + (item.totalPrice ?? 0)))),
//                       ],
//                     ),
//                     // NEW TAX MAPPING based on specific order JSON
//                     if (data?.tax != null && data!.tax!.isNotEmpty) ...[
//                       ...(data.tax!).map((taxItem) {
//                         return Row(
//                           children: [
//                             if (taxItem.taxName != null) ...[
//                               Text(
//                                 '${taxItem.taxName ?? ''} - ${(taxItem.tax ?? 0).toStringAsFixed(2)}%',
//                                 style: const TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),
//                               ),
//                               const Spacer(),
//                               // Using tax_amount directly from the JSON
//                               Text(formatAmount(taxItem.taxAmount)), 
//                             ]
//                           ],
//                         );
//                       }),
//                     ],
//                     Divider(color: Colors.grey.shade400),
//                     Row(
//                       children: [
//                         const Text(
//                           'Total',
//                           style: TextStyle(color: black, fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const Spacer(),
//                         Text(
//                           formatAmount(data?.orderTotal?.toString() ?? '0'),
//                           style: const TextStyle(fontSize: 16, color: red, fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (widget.selectedTabIndex == 6) ...[
//                     const Text('Rejection Reason : '),
//                     Text(data?.rejectionReason?.toString() ?? ''),
//                     // Ensure you have nkMediumSizeBox() defined in your app
//                     // nkMediumSizeBox(), 
//                     Text(NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(data?.rejectedDate.toString() ?? ''))),
//                   ],
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// class _OrderProcessInvoiceDialogState extends State<OrderProcessInvoiceDialog> {
//   bool isRejecting = false;
//   bool isChanged = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   String _companyTimeZone = 'UTC';
//   // 1. Calculate the string before the UI code

//   @override
//   Widget build(BuildContext context) {
//     final isSpecificData = widget.selectedTabIndex == 0;
//     final DateTime? createdAt = widget.invoiceData?.orderCreatAt;
//     final String dateString = createdAt != null
//         ? TimeUtils.formatTimeInZone(createdAt, format: 'dd/MM/yyyy hh:mm a')
//         : 'N/A';
//     return Dialog(
//       insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       backgroundColor: white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
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
//               MyCommnonContainer(
//                 isCommonBorder: true,
//                 // color: white,
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           widget.selectedTabIndex == 5
//                               ? 'INVOICE DETAILS'
//                               : 'ORDER DETAILS',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const Spacer(),

// // 2. Simply drop the clean variable into your Text widget
//                         Text(
//                           'Created At : $dateString',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Divider(color: Colors.grey.shade300),
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               ("Name :   ${widget.invoiceData?.businessName}"),
//                             ),
//                             Text(
//                               ("Email :   ${widget.invoiceData?.email}"),
//                             ),
//                             Text(
//                               ("Phone :   ${widget.invoiceData?.mobileNo}"),
//                             ),
//                             if (widget.invoiceData?.orderSource == 'app')
//                               Text(
//                                 "Staff :   ${widget.invoiceData?.salesmanName ?? 'N/A'}",
//                               ),
//                             // Text(
//                             //   ("Staff :   ${widget.invoiceData?.orderSource == 'web_store' ? 'Web Store' : (widget.invoiceData?.salesmanName ?? 'N/A')}"),
//                             // ),
//                           ],
//                         ),
//                         const Spacer(),
//                         ClipOval(
//                           child: Container(
//                             height: 50,
//                             width: 50,
//                             child: Image.network(
//                               // 👇 Removed condition, now safely accessing invoiceData
//                               'https://test.thrivewoo.com/uploads/${widget.invoiceData?.imageUrl ?? ''}',

//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.lightBlue[100],
//                                   child: const Icon(Icons.person,
//                                       color: Colors.blue),
//                                 );
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: SizedBox(
//                         width: isPhonePortrait(context)
//                             ? fullScreenWidth(context) * 2
//                             : fullScreenWidth(context) * 0.85,
//                         child: 
//                         DataTable(
//   // ignore: deprecated_member_use
//   dataRowHeight: 40,
//   headingRowHeight: 40,
//   horizontalMargin: 20,
//   headingTextStyle: const TextStyle(
//     color: black, // Ensure 'black' is defined in your constants
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//   ),
//   columns: [
//     DataColumn(
//       label: SizedBox(
//         width: isPhonePortrait(context)
//             ? fullScreenWidth(context) * 0.4
//             : fullScreenWidth(context) * 0.2,
//         child: const Text('ITEM NAME'),
//       ),
//     ),
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'PRICE',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ),
//     // NEW: PACK TYPE COLUMN
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'PACK TYPE',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ),
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'QTY',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ),
//     // NEW: AMOUNT COLUMN
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'AMOUNT',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ),
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'DISCOUNT',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ),
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'TAX',
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ),
//     const DataColumn(
//       label: Expanded(
//         flex: 2,
//         child: Text(
//           'TOTAL',
//           textAlign: TextAlign.right,
//         ),
//       ),
//     ),
//   ],
//   rows: (widget.invoiceData?.cart != null &&
//           widget.invoiceData!.cart!.isNotEmpty)
//       ? List.generate(
//           widget.invoiceData!.cart!.length,
//           (index) {
//             final cartItem = widget.invoiceData!.cart![index];
//             return DataRow(
//               cells: [
//                 DataCell(
//                   Tooltip(
//                     message:
//                         "${cartItem.productName} - ${cartItem.variationName}",
//                     preferBelow: false,
//                     decoration: BoxDecoration(
//                       color: Colors.black87,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: SizedBox(
//                       width: isPhonePortrait(context)
//                           ? fullScreenWidth(context) * 0.4
//                           : fullScreenWidth(context) * 0.2,
//                       child: ProductNameWithTax(
//                         productName: cartItem.productName.toString(),
//                         variationName: cartItem.variationName.toString(),
//                         isInclTax: cartItem.inclTax == "incl_tax",
//                         maxWidth: isPhonePortrait(context)
//                             ? fullScreenWidth(context) * 0.4
//                             : fullScreenWidth(context) * 0.2,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Price
//                 DataCell(
//                   Center(
//                     child: Text(formatAmount(cartItem.price?.toString() ?? '0')),
//                   ),
//                 ),
//                 // NEW: Pack Type
//                 DataCell(
//                   Center(
//                     child: Text(cartItem.packType?.toString() ?? '-'),
//                   ),
//                 ),
//                 // Quantity
//                 DataCell(
//                   Center(
//                     child: Text(
//                       (cartItem.packType == 'Pack')
//                           ? '${(cartItem.pieces ?? 0) * (cartItem.quantity?.toInt() ?? 0)}'
//                               ' (${cartItem.quantity ?? 0} ${cartItem.packType})'
//                           : '${cartItem.quantity ?? 0}',
//                     ),
//                   ),
//                 ),
//                 // NEW: Amount
//                 DataCell(
//                   Center(
//                     // Note: Depending on your model, you can use cartItem.totalPrice or calculate it
//                     child: Text(formatAmount(
//                         // Assuming you have 'totalPrice' mapped from the JSON's 'total_price'
//                         // Alternatively, replace this with (cartItem.price * cartItem.quantity).toString()
//                         cartItem.price?.toString() ?? '0')),
//                   ),
//                 ),
//                 // Discount
//                 //  DataCell(
//                 //                           Center(
//                 //                             child: Text(
//                 //                               formatAmount(widget
//                 //                                   .invoiceData
//                 //                                   ?.cart?[index]
//                 //                                   .discountAmount),
//                 //                               maxLines: 1,
//                 //                             ),
//                 //                           ),
//                 //                         ),
//                 DataCell(
//                   Center(
//                     child: Text(
//                       formatAmount(cartItem.discountAmount),
//                       maxLines: 1,
//                     ),
//                   ),
//                 ),
//                 // Tax
//                 DataCell(
//                   Center(
//                     child: Text(formatAmount(cartItem.tax)),
//                   ),
//                 ),
//                 // Total
//                 DataCell(
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text.rich(
//                       TextSpan(
//                         text: formatAmount(cartItem.total),
//                       ),
//                       maxLines: 1,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         )
//       : [
//           const DataRow(
//             cells: [
//               DataCell(Text('No items available.')),
//               DataCell(Text('')), // Price
//               DataCell(Text('')), // Pack Type (New)
//               DataCell(Text('')), // Qty
//               DataCell(Text('')), // Amount (New)
//               DataCell(Text('')), // Discount
//               DataCell(Text('')), // Tax
//               DataCell(Text('')), // Total
//             ],
//           ),
//         ],
// ),
//                         // DataTable(
//                         //   // ignore: deprecated_member_use
//                         //   dataRowHeight: 40,
//                         //   headingRowHeight: 40,
//                         //   horizontalMargin: 20,
//                         //   headingTextStyle: const TextStyle(
//                         //     color: black,
//                         //     fontSize: 16,
//                         //     fontWeight: FontWeight.w600,
//                         //   ),
//                         //   columns: [
//                         //     DataColumn(
//                         //       label: SizedBox(
//                         //         width: isPhonePortrait(context)
//                         //             ? fullScreenWidth(context) * 0.4
//                         //             : fullScreenWidth(context) * 0.2,
//                         //         child: const Text('ITEM NAME'),
//                         //       ),
//                         //     ),
//                         //     const DataColumn(
//                         //       label: Expanded(
//                         //         flex: 2,
//                         //         child: Text(
//                         //           'PRICE',
//                         //           textAlign: TextAlign.center,
//                         //         ),
//                         //       ),
//                         //     ),
//                         //     const DataColumn(
//                         //       label: Expanded(
//                         //         flex: 2,
//                         //         child: Text(
//                         //           'QTY',
//                         //           textAlign: TextAlign.center,
//                         //         ),
//                         //       ),
//                         //     ),
//                         //     const DataColumn(
//                         //       label: Expanded(
//                         //         flex: 2,
//                         //         child: Text(
//                         //           'DISCOUNT',
//                         //           textAlign: TextAlign.center,
//                         //         ),
//                         //       ),
//                         //     ),
//                         //     const DataColumn(
//                         //       label: Expanded(
//                         //         flex: 2,
//                         //         child: Text(
//                         //           'TAX',
//                         //           textAlign: TextAlign.center,
//                         //         ),
//                         //       ),
//                         //     ),
//                         //     const DataColumn(
//                         //       label: Expanded(
//                         //         flex: 2,
//                         //         child: Text(
//                         //           'TOTAL',
//                         //           textAlign: TextAlign.right,
//                         //         ),
//                         //       ),
//                         //     ),
//                         //   ],
//                         //   rows: (widget.invoiceData?.cart != null &&
//                         //           widget.invoiceData!.cart!.isNotEmpty)
//                         //       ? List.generate(
//                         //           widget.invoiceData!.cart!.length,
//                         //           (index) {
//                         //             return DataRow(
//                         //               cells: [
//                         //                 // DataCell(
//                         //                 //   SizedBox(
//                         //                 //     width: totalWidth * 0.2,
//                         //                 //     child: Text(
//                         //                 //       ('${widget.invoiceData!.cart![index].productName} - ${widget.invoiceData!.cart![index].variationName}'),
//                         //                 //       maxLines: 2,
//                         //                 //       overflow: TextOverflow.ellipsis,
//                         //                 //       style: const TextStyle(fontSize: 14),
//                         //                 //     ),
//                         //                 //   ),
//                         //                 // ),
//                         //                 DataCell(
//                         //                   Tooltip(
//                         //                     message:
//                         //                         "${widget.invoiceData!.cart![index].productName} - ${widget.invoiceData!.cart![index].variationName}",
//                         //                     preferBelow: false,
//                         //                     decoration: BoxDecoration(
//                         //                       color: Colors.black87,
//                         //                       borderRadius:
//                         //                           BorderRadius.circular(8),
//                         //                     ),
//                         //                     child: SizedBox(
//                         //                       width: isPhonePortrait(context)
//                         //                           ? fullScreenWidth(context) *
//                         //                               0.4
//                         //                           : fullScreenWidth(context) *
//                         //                               0.2,
//                         //                       child: ProductNameWithTax(
//                         //                         productName: widget.invoiceData!
//                         //                             .cart![index].productName
//                         //                             .toString(),
//                         //                         variationName: widget
//                         //                             .invoiceData!
//                         //                             .cart![index]
//                         //                             .variationName
//                         //                             .toString(),
//                         //                         isInclTax: widget.invoiceData!
//                         //                                 .cart![index].inclTax ==
//                         //                             "incl_tax",
//                         //                         maxWidth: isPhonePortrait(
//                         //                                 context)
//                         //                             ? fullScreenWidth(context) *
//                         //                                 0.4
//                         //                             : fullScreenWidth(context) *
//                         //                                 0.2,
//                         //                         style: const TextStyle(
//                         //                             fontSize: 14),
//                         //                       ),
//                         //                     ),
//                         //                   ),
//                         //                 ),
//                         //                 DataCell(
//                         //                   Center(
//                         //                     child: Text(formatAmount(widget
//                         //                             .invoiceData
//                         //                             ?.cart?[index]
//                         //                             .price
//                         //                             ?.toString() ??
//                         //                         '0')),
//                         //                   ),
//                         //                 ),
//                         //                 // Quantity
//                         //                 DataCell(
//                         //                   Center(
//                         //                     child: Text(
//                         //                       (widget.invoiceData!.cart![index]
//                         //                                   .packType ==
//                         //                               'Pack')
//                         //                           ? '${(widget.invoiceData?.cart?[index].pieces ?? 0) * (widget.invoiceData?.cart?[index].quantity?.toInt() ?? 0)}'
//                         //                               ' (${widget.invoiceData?.cart?[index].quantity ?? 0} ${widget.invoiceData?.cart?[index].packType})'
//                         //                           : '${widget.invoiceData?.cart?[index].quantity ?? 0}',
//                         //                     ),
//                         //                   ),
//                         //                 ),
//                         //                 DataCell(
//                         //                   Center(
//                         //                     child: Text(
//                         //                       formatAmount(widget
//                         //                           .invoiceData
//                         //                           ?.cart?[index]
//                         //                           .discountAmount),
//                         //                       maxLines: 1,
//                         //                     ),
//                         //                   ),
//                         //                 ),
//                         //                 DataCell(
//                         //                   Center(
//                         //                     child: Text(formatAmount(widget
//                         //                         .invoiceData
//                         //                         ?.cart?[index]
//                         //                         .tax)),
//                         //                   ),
//                         //                 ),
//                         //                 DataCell(
//                         //                   Align(
//                         //                       alignment: Alignment.centerRight,
//                         //                       child: Text.rich(
//                         //                         TextSpan(
//                         //                           text: formatAmount(widget
//                         //                               .invoiceData!
//                         //                               .cart![index]
//                         //                               .total),
//                         //                         ),
//                         //                         maxLines: 1,
//                         //                       )),
//                         //                 ),
//                         //               ],
//                         //             );
//                         //           },
//                         //         )
//                         //       : [
//                         //           const DataRow(
//                         //             cells: [
//                         //               DataCell(Text('No items available.')),
//                         //               DataCell(Text('')),
//                         //               DataCell(Text('')),
//                         //               DataCell(Text('')),
//                         //               DataCell(Text('')),
//                         //               DataCell(Text('')),
//                         //             ],
//                         //           ),
//                         //         ],
//                         // ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           'Subtotal',
//                           style: TextStyle(
//                             color: black,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           formatAmount(
//                             widget.invoiceData?.cart
//                                 ?.fold<num>(0, (sum, item) => sum + item.total),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if ((widget.invoiceData?.tax != null &&
//                         widget.invoiceData!.tax!
//                             .any((taxItem) => taxItem.tax != null))) ...[
//                       ...(widget.invoiceData!.tax!).map((taxItem) {
//                         final orderTotal =
//                             (widget.invoiceData?.orderTotal ?? 0);
//                         final taxPercentage = taxItem.tax ?? 0.0;
//                         final taxAmount = (taxPercentage * orderTotal) / 100;

//                         return Row(
//                           children: [
//                             if (taxItem.taxName != null) ...[
//                               Text(
//                                 '${taxItem.taxName ?? ''} - ${taxPercentage.toStringAsFixed(2)}%',
//                                 style: const TextStyle(
//                                   color: black,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 formatAmount(taxAmount),
//                               ),
//                             ]
//                           ],
//                         );
//                       }),
//                     ],
//                     Divider(color: Colors.grey.shade400),
//                     Row(
//                       children: [
//                         const Text(
//                           'Total',
//                           style: TextStyle(
//                             color: black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           formatAmount(
//                             widget.invoiceData?.cart
//                                 ?.fold<num>(0, (sum, item) => sum + item.total),
//                           ),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: red,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (widget.selectedTabIndex == 6) ...[
//                     const Text('Rejection Reason : '),
//                     // nkMediumSizeBox(),
//                     Text(widget.invoiceData!.rejectionReason.toString()),
//                     nkMediumSizeBox(),
//                     Text(NKDateUtils.commonDayFormat2(
//                         NKDateUtils.formatStringUTCDateTime(
//                             widget.invoiceData?.rejectedDate.toString() ??
//                                 ''))),
//                   ],
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
