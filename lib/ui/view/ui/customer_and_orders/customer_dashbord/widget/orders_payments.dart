// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payment_heading.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_history_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/custom_toast.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/order_payment_enlarge_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_collection_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:provider/provider.dart';




MyCommnonContainer OrdersPayments(
    BuildContext context,
    List<RecentOrder> recentOrders,
    SubscriptionController subscriptionController) {
  return MyCommnonContainer(
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
        blurRadius: 5,
        offset: const Offset(4, 4),
      ),
    ],
    borderRadius: 25,
    height: 300,
    isCommonBorder: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- TOP HEADER (Title & Buttons) remains unchanged ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 5, bottom: 5),
                  child: const Text(
                    'Orders & Payment/s',
                    style: cardHeadingTextStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                const SizedBox(width: 7),
                SizedBox(
                  height: 25,
                  width: 95,
                  child: ElevatedButton(
                    onPressed: () {
                      if (subscriptionController.customerPaymentCollection.value == "true") {
                        List<RecentOrder> selectedOrders = [];
                        for (var order in recentOrders) {
                          if (context.read<CustomersProvider>().isOrderSelected(order)) {
                            selectedOrders.add(order);
                          }
                        }
                        if (selectedOrders.isNotEmpty) {
                          paymentCollectionDialog(context, selectedOrders);
                        } else {
                          showCustomToast(context);
                        }
                      } else {
                        showUpgradePlanDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5bc0de),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text('Collection', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: fullScreenWidth(context) > 630 ? 20 : 2, top: 2),
              child: InkWell(
                onTap: () {
                  showCustomDialog(context, recentOrders);
                },
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor.withOpacity(0.3)),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.open_in_new, size: 17, color: primaryColor),
                    )),
              ),
            ),
          ],
        ),
        nkSmallSizeBox(),

        // --- SCROLLABLE TABLE AREA STARTS HERE ---
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 1. Determine a minimum width for your table to ensure it looks good.
              // If the screen is smaller than 800, it will scroll. 
              // If larger, it will fill the space.
              const double minTableWidth = 800.0; 
              
              // Use the larger of the two: screen width or minTableWidth
              double effectiveWidth = constraints.maxWidth < minTableWidth 
                  ? minTableWidth 
                  : constraints.maxWidth;

              double availableHeight = constraints.maxHeight;
              double fontSize = 11;

              return Scrollbar(
                thumbVisibility: true, // Shows the horizontal scrollbar
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal Scroll
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // minWidth: effectiveWidth, 
                      maxWidth: effectiveWidth
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 2. The Heading (Now scrolls horizontally)
                        const OrdersPaymentHeading(),
                        
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 0),
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                        ),

                        // 3. The Data List (Vertical scroll inside Horizontal scroll)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: recentOrders.map((order) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            getFormattedOrderCreatAt(order.orderCreatAt),
                                            style: TextStyle(fontSize: fontSize),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              showInvoicePreviewOnline(context, order.orderId);
                                            },
                                            child: MyRegularText(
                                              color: primaryColor,
                                              label: order.invoiceId,
                                              fontSize: fontSize,
                                              maxlines: 1,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, // Fixed padding is safer than calculation inside scroll
                                                vertical: 2.0,
                                              ),
                                              child: Text(
                                                getStatusName(order.orderStatus),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: fontSize,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Tooltip(
                                                  message:
                                                      '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
                                                      '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
                                                      '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                  waitDuration: const Duration(milliseconds: 500),
                                                  child: MyRegularText(
                                                    label:
                                                        '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
                                                        '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
                                                        '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                    maxlines: 1,
                                                    fontSize: 11,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              if (order.paymentStatus == 3) ...[
                                                const SizedBox(width: 2),
                                                PaymentHistoryButton(
                                                  orderId: order.orderId,
                                                  iconSize: 13,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            order.duedate!.isNotEmpty
                                                ? order.duedate?.first ?? ''
                                                : '',
                                            style: TextStyle(
                                              color: order.duedate!.isEmpty
                                                  ? Colors.grey
                                                  : order.duedate?[1] >= 3
                                                      ? Colors.green
                                                      : order.duedate?[1] <= 3 && order.duedate?[1] >= 1
                                                          ? Colors.amber
                                                          : Colors.red,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Consumer<CustomersProvider>(
                                            builder: (context, provider, child) {
                                              return Checkbox(
                                                value: provider.isOrderSelected(order),
                                                onChanged: (bool? isSelected) {
                                                  provider.toggleOrderSelection(order);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// MyCommnonContainer OrdersPayments(
//     BuildContext context,
//     List<RecentOrder> recentOrders,
//     SubscriptionController subscriptionController) {
//   return MyCommnonContainer(
//     boxShadow: [
//       BoxShadow(
//         color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
//         blurRadius: 5,
//         offset: const Offset(4, 4),
//       ),
//     ],
//     borderRadius: 25,
//     height: 300,
//     isCommonBorder: true,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.2),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(25),
//                       bottomRight: Radius.circular(25),
//                     ),
//                   ),
//                   padding: const EdgeInsets.only(
//                       right: 20, left: 20, top: 5, bottom: 5),
//                   child: const Text(
//                     'Orders & Payment/s',
//                     style: cardHeadingTextStyle,
//                     maxLines: 1,
//                     softWrap: false,
//                   ),
//                 ),
//                 SizedBox(width: 7,),
//                 SizedBox(
//                   height: 25,
//                   width: 95,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (subscriptionController
//                               .customerPaymentCollection.value ==
//                           "true") {
//                         List<RecentOrder> selectedOrders = [];
//                         for (var order in recentOrders) {
//                           if (context
//                               .read<CustomersProvider>()
//                               .isOrderSelected(order)) {
//                             selectedOrders.add(order);
//                           }
//                         }
//                         if (selectedOrders.isNotEmpty) {
//                           paymentCollectionDialog(context, selectedOrders);
//                         } else {
//                           showCustomToast(context);
//                         }
//                       } else {
//                         showUpgradePlanDialog(context);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xff5bc0de),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4.0),
//                       ),
//                     ),
//                     child: const Text(
//                       'Collection',
//                       style: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.only(
//                   right: fullScreenWidth(context) > 630 ? 20 : 2, top: 2),
//               child: InkWell(
//                 onTap: () {
//                   showCustomDialog(context, recentOrders);
//                 },
//                 child: Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: primaryColor.withOpacity(0.3)),
//                     child: const Padding(
//                       padding: EdgeInsets.all(5.0),
//                       child: Icon(
//                         Icons.open_in_new,
//                         size: 17,
//                         color: primaryColor,
//                       ),
//                     )),
//               ),
//             ),
//           ],
//         ),
//         nkSmallSizeBox(),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(0.0),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 double availableWidth = constraints.maxWidth;
//                 double availableHeight = constraints.maxHeight;
//                 double fontSize = 11;
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     OrdersPaymentHeading(),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4.0, bottom: 0),
//                       child: Container(
//                         height: 1,
//                         color: Colors.grey.shade100,
//                       ),
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.vertical,
//                         child: Column(
//                           children: recentOrders.map((order) {
//                             return Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 0.0),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 1,
//                                     child: Center(
//                                       child: Text(
//                                         getFormattedOrderCreatAt(
//                                             order.orderCreatAt),
//                                         style: TextStyle(
//                                           fontSize: fontSize,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Center(
//                                       child: InkWell(
//                                         onTap: () {
//                                           showInvoicePreviewOnline(
//                                             context,
//                                             order.orderId,
//                                           );
//                                         },
//                                         child: MyRegularText(
//                                           color: primaryColor,
//                                           label: order.invoiceId,
//                                           fontSize: fontSize,
//                                           maxlines: 1,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Center(
//                                       child: Container(
//                                         decoration: const BoxDecoration(
//                                           color: Colors.green,
//                                           //Color(0xff008000),
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(4.0)),
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: availableWidth / 80,
//                                             vertical: availableHeight / 100,
//                                           ),
//                                           child: Text(
//                                             getStatusName(order.orderStatus),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: fontSize,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
   
//    Expanded(
//   flex: 2,
//   child: Center(
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Flexible(
//           child: Tooltip(
//             message:
//                 '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
//                 '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
//                 '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
//             waitDuration: const Duration(milliseconds: 500), // optional
//             child: MyRegularText(
//               label:
//                   '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
//                   '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
//                   '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
//               maxlines: 1,
//               fontSize: 11,
//               overflow: TextOverflow.ellipsis, // 👈 IMPORTANT
//             ),
//           ),
//         ),

//         if (order.paymentStatus == 3) ...[
//           const SizedBox(width: 2),
//           PaymentHistoryButton(
//             orderId: order.orderId,
//             iconSize: 13,
//           ),
//         ],
//       ],
//     ),
//   ),
// ),


// //                                 Expanded(
// //   flex: 2,
// //   child: Center(
// //     child: SingleChildScrollView(
// //       scrollDirection: Axis.horizontal,
// //       physics: const BouncingScrollPhysics(),
// //       // The Row wraps both the Text and the Button
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min, 
// //         children: [
// //           MyRegularText(
// //             label:
// //                 '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
// //                 '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
// //                 '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
// //             maxlines: 1,
// //             fontSize: 11,
// //           ),
// //           // The button is now inside the scrollable Row
// //           if (order.paymentStatus == 3) ...[
// //             const SizedBox(width: 4), // Small gap between text and button
// //             PaymentHistoryButton(
// //               orderId: order.orderId,
// //               iconSize: 11 + 2,
// //             ),
// //           ],
// //         ],
// //       ),
// //     ),
// //   ),
// // ),
//                                   // Expanded(
//                                   //   flex: 2,
//                                   //   child: Center(
//                                   //     child: Row(
//                                   //       mainAxisSize: MainAxisSize.min,
//                                   //       children: [
//                                   //         // Change Flexible to Expanded so it calculates available space for FittedBox
//                                   //         Expanded(
//                                   //           child: FittedBox(
//                                   //             fit: BoxFit
//                                   //                 .scaleDown, // Only shrinks, never grows larger than fontSize
//                                   //             child: MyRegularText(
//                                   //               label:
//                                   //                   '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
//                                   //                   '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
//                                   //                   '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
//                                   //               maxlines: 1,
//                                   //               fontSize: 11,
//                                   //             ),
//                                   //           ),
//                                   //         ),
//                                   //         if (order.paymentStatus == 3) ...[
//                                   //           PaymentHistoryButton(
//                                   //             orderId: order.orderId,
//                                   //             iconSize: 11 + 2,
//                                   //           )
                                          
//                                   //         ],
//                                   //       ],
//                                   //     ),
//                                   //   ),
//                                   // ),
                                 
//                                   Expanded(
//                                     flex: 1,
//                                     child: Center(
//                                       child: Text(
//                                         order.duedate!.isNotEmpty
//                                             ? order.duedate?.first ?? ''
//                                             : '',
//                                         style: TextStyle(
//                                           color: order.duedate!.isEmpty
//                                               ? Colors.grey
//                                               : order.duedate?[1] >= 3
//                                                   ? Colors.green
//                                                   : order.duedate?[1] <= 3 &&
//                                                           order.duedate?[1] >= 1
//                                                       ? Colors.amber
//                                                       : Colors.red,
//                                           fontSize: fontSize,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Center(
//                                       child: Consumer<CustomersProvider>(
//                                         builder: (context, provider, child) {
//                                           return Checkbox(
//                                             value:
//                                                 provider.isOrderSelected(order),
//                                             onChanged: (bool? isSelected) {
//                                               provider
//                                                   .toggleOrderSelection(order);
//                                             },
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
