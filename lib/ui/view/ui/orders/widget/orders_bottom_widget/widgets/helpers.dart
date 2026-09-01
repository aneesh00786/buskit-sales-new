import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_invoice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget placeholderWidget() {
  return const Center(
    child: MyRegularText(
      label: 'N/A',
      fontWeight: FontWeight.w600,
      fontSize: 11,
    ),
  );
}

Widget customerDetailsWidget(CustomerDetails orderData) {
  return GestureDetector(
    onTap: () => {},
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(width: 8),
      ClipOval(
        child: Container(
          height: 34,
          width: 34,
          color: Colors.grey[200],
          child: Image.network(
            '${ApiConstants.imageBaseUrl}${orderData.imageUrl ?? ''}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                content: orderData.businessName ?? 'Unknown',
                maxLine: 2,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              CustomText(
                content: orderData.mobileno ?? 'Unknown',
                maxLine: 2,
                fontSize: 10,
              ),
              MyRegularText(
                align: TextAlign.start,
                label: orderData.email ?? 'Unknown',
                maxlines: 1,
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
      )
    ]),
  );
}

Widget orderNumberWidget(
    OrderData orderDetailsData, int selectedTabIndex) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyRegularText(
          label: orderDetailsData.orderId ?? 'N/A',
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        if (selectedTabIndex != 0) ...[
          const SizedBox(height: 5),
          MyRegularText(
            label: orderDetailsData.generatedDate != null
                ? "${NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(orderDetailsData.generatedDate ?? ''))} ${NKDateUtils.commonTimeOnlyFormat(NKDateUtils.formatStringUTCDateTime(orderDetailsData.generatedDate ?? ''))}"
                : "N/A",
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          MyRegularText(
            label: '${orderDetailsData.fullname} ${orderDetailsData.lastname}',
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ]
      ],
    ),
  );
}
Widget orderCreatedDateWidget(OrderData orderDetailsData, int selectedTabIndex) {
  // 1. Determine which date string to use based on the tab index
  String? rawDateString;

  if (selectedTabIndex == 0) {
    // Case 1: Pending/New -> Use 'generatedDate'
    rawDateString = orderDetailsData.generatedDate;
  } else if (selectedTabIndex == 5) {
    // Case 2: Delivered -> Use 'deliveryDate' (or deliveryDatetime based on your model)
    rawDateString = orderDetailsData.deliveryDatetime?.toString();
  } else if (selectedTabIndex == 6) {
    // Case 3: Rejected -> Use 'rejectedDate'
    rawDateString = orderDetailsData.rejectedDate?.toString();
  } else {
    // Default (e.g., Confirmed, Processing) -> Use 'orderCreatAt'
    rawDateString = orderDetailsData.orderCreatAt?.toString();
  }

  // 2. Validate the date string (Check for null, empty, or '0000' dates)
  final bool hasDate = rawDateString != null &&
      rawDateString.isNotEmpty &&
      !rawDateString.startsWith("0000");

  // 3. Parse the selected string
  final DateTime? parsedDate =
      hasDate ? DateTime.tryParse(rawDateString!) : null;

  // 4. Format the Date and Time strings
  final String dateString = parsedDate != null
      ? NKDateUtils.commonDayFormat2(parsedDate.toLocal()) 
      : 'N/A';

  final String timeString = parsedDate != null
      ? TimeUtils.formatTimeInZone(parsedDate, format: 'hh:mm a') 
      : 'N/A';

  return Center(
    child: selectedTabIndex == 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyRegularText(
                label: dateString,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              MyRegularText(
                label: timeString,
                fontSize: 12,
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Combined Date & Time for other tabs
              MyRegularText(
                label: "$dateString $timeString",
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              // Show Edited By Name in the else case (for tabs other than 0)
              if (selectedTabIndex != 0) ...[
                MyRegularText(
                  label:
                      '${orderDetailsData.editedFullname} ${orderDetailsData.editedLastname}',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ]
            ],
          ),
  );
}
// Widget orderCreatedDateWidget(OrderData orderDetailsData, int selectedTabIndex) {
//   // 1. Safely parse the date string once at the top
//   final bool hasDate = orderDetailsData.generatedDate != null && orderDetailsData.generatedDate!.isNotEmpty;
  
//   // Assuming generatedDate is a String since it was passed to formatStringUTCDateTime
//   final DateTime? parsedDate = hasDate ? DateTime.tryParse(orderDetailsData.generatedDate!) : null;

//   // 2. Prepare the Date string (Keeping your old NKDateUtils logic as requested)
//   final String dateString = parsedDate != null 
//       ? NKDateUtils.commonDayFormat2(parsedDate.toLocal()) 
//       : 'N/A';

//   // 3. Prepare the Time string (Using your NEW TimeUtils logic for time only)
//   final String timeString = parsedDate != null 
//       ? TimeUtils.formatTimeInZone(parsedDate, format: 'hh:mm a') 
//       : 'N/A';

//   return Center(
//     child: selectedTabIndex == 0
//         ? Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               MyRegularText(
//                 label: dateString, // Old Date Logic
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//               MyRegularText(
//                 label: timeString, // New Time Logic
//                 fontSize: 12,
//               ),
//             ],
//           )
//         : Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               MyRegularText(
//                 label: "$dateString $timeString", // Safely combined
//                 fontWeight: FontWeight.w600,
//                 fontSize: 11,
//               ),
//               if (selectedTabIndex != 0) ...[
//                 MyRegularText(
//                   label: '${orderDetailsData.editedFullname} ${orderDetailsData.editedLastname}',
//                   fontWeight: FontWeight.w500,
//                   fontSize: 11,
//                 ),
//               ]
//             ],
//           ),
//   );
// }

Widget orderCreatedByWidget(OrderData orderData) {
  String displayLabel = '';

  // 1. Check if the order came from the web store
  if (orderData.orderSource == 'web_store') {
    displayLabel = 'Web Store';
  } 
  // 2. Otherwise, format the user's name
  else {
    final String firstName = orderData.fullname ?? '';
    final String lastName = orderData.lastname ?? '';
    
    // .trim() removes any extra spaces if one of the names is missing
    displayLabel = '$firstName $lastName'.trim();
    
    // Fallback just in case the name is completely empty
    if (displayLabel.isEmpty) {
      displayLabel = 'N/A';
    }
  }

  return Center(
    child: MyRegularText(
      label: displayLabel,
      fontWeight: FontWeight.w600,
      fontSize: 11,
      maxlines: 2,
    ),
  );
}

// Widget orderCreatedByWidget(OrderData orderData) {
//   return Center(
//     child: MyRegularText(
//       label: '${orderData.fullname} ${orderData.lastname}',
//       fontWeight: FontWeight.w600,
//       fontSize: 11,
//       maxlines: 2,
//     ),
//   );
// }

Widget orderPrice(OrderData orderDetailsData) {
  return Center(
    child: MyRegularText(
      label: orderDetailsData.orderTotal != null
          ? formatAmount(orderDetailsData.orderTotal)
          : 'N/A',
      fontWeight: FontWeight.w600,
      fontSize: 11,
      maxlines: 1,
    ),
  );
}

Widget paymentStatus(OrderData orderData) {
  Color statusColor;
  switch (orderData.paymentStatus) {
    case 0:
      statusColor = Colors.red;
      break;
    case 1:
      statusColor = Colors.green;
      break;
    case 3:
      statusColor = Colors.orange;
      break;
    default:
      statusColor = Colors.grey;
  }

  return Center(
    child: CircleAvatar(
      backgroundColor: statusColor,
      radius: 12,
      child: Icon(
        orderData.paymentStatus == 0
            ? Icons.close
            : Icons.check,
        size: 20,
        color: white,
      ),
    ),
  );
}

Widget orderStatus(OrderData orderData) {
  final bool hasStatus = orderData.orderStatus != null;
  final status = OrderHandlingClass.fromType(orderData.orderStatus ?? 0);
  final Color statusColor = hasStatus ? status.statusBgColor : Colors.grey;
  final Color statusTextColor =
      hasStatus ? status.statusTextColor : Colors.black;
  final String statusLabel = hasStatus ? status.name.tr : 'Unknown';

  return orderData.orderStatus == 14
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: IntrinsicHeight(
              child: Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        content: statusLabel,
                        color: statusTextColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                      if (orderData.orderStatus == 14) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                  color: Colors.blue,
                                  child:  Center(
                                    child: Text(
                                      'Quick Sale'.tr,
                                      style: TextStyle(
                                          color: white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                  )),
                            ),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      : Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Center(
                  child: CustomText(
                    content: statusLabel,
                    color: statusTextColor,
                    fontSize: 11,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
}
Widget viewOrder(OrderController orderController, OrderData orderData, BuildContext context) {
  int selectedTabIndex = orderController.hasOfflineOrders.value
      ? orderController.selectedTabIndex.value - 1
      : orderController.selectedTabIndex.value;
      
  return Center(
    child: IconButton(
      onPressed: () async {
        // ---------------------------------------------------------
        // CONDITION 1: 0th Tab -> Call NEW API (Specific Order)
        // ---------------------------------------------------------
        if (selectedTabIndex == 0) {
          try {
            await orderController.loadSpecificOrderInvoiceData(
              orderId: orderData.orderId!,
            );
            
            Get.back(); // Dismiss loading/dialog if applicable

            if (orderController.fetchSpecificOrderData != null) {
              Get.dialog(
                OrderProcessInvoiceDialog(
                  // Pass data to specificData argument
                  specificData: orderController.fetchSpecificOrderData, 
                  selectedTabIndex: selectedTabIndex,
                  orderController: orderController,
                ),
                barrierDismissible: true,
              );
            } else {
              throw Exception('No specific order data available');
            }
          } catch (e) {
            Get.back();
            Get.snackbar('Error', e.toString());
          }
        } 
        
        // ---------------------------------------------------------
        // CONDITION 2: All other tabs (except 4 & 5) -> Call OLD API
        // ---------------------------------------------------------
        else if (selectedTabIndex >= 1 && selectedTabIndex != 4 && selectedTabIndex != 5) {
          try {
            await orderController.loadOrderProcessInvoiceData(
              orderId: orderData.orderId!,
              orderStatus: orderData.orderStatus!,
            );
            
            Get.back();

            // ignore: unnecessary_null_comparison
            if (orderController.orderProcessInvoiceData != null) {
              Get.dialog(
                OrderProcessInvoiceDialog(
                  // Pass data to invoiceData argument
                  invoiceData: orderController.orderProcessInvoiceData, 
                  selectedTabIndex: selectedTabIndex,
                  orderController: orderController,
                ),
                barrierDismissible: true,
              );
            } else {
              throw Exception('No invoice data available');
            }
          } catch (e) {
            Get.back();
            // Get.snackbar('Error', e.toString());
          }
        } 
        
        // ---------------------------------------------------------
        // CONDITION 3: Tabs 4 & 5 -> Show Online Preview
        // ---------------------------------------------------------
        else if (selectedTabIndex == 4 || selectedTabIndex == 5) {
          showInvoicePreviewOnline(
            context,
            orderData.orderId ?? '',
          );
        }
      },
      icon: const Icon(Icons.visibility, size: 16),
    ),
  );
}
// Widget viewOrder(OrderController orderController, OrderData orderData, BuildContext context) {
//   int selectedTabIndex = orderController.hasOfflineOrders.value
//       ? orderController.selectedTabIndex.value - 1
//       : orderController.selectedTabIndex.value;
      
//   return Center(
//     child: IconButton(
//       onPressed: () async {
//         // Handle all standard tab indices (0, 1, 2, 3) identically
//         if (selectedTabIndex >= 0 && selectedTabIndex != 4 && selectedTabIndex != 5) {
//           try {
//             // 1. Call the new specific order API
//             await orderController.loadSpecificOrderInvoiceData(
//               orderId: orderData.orderId!,
//             );
            
//             Get.back(); // Dismiss loading/dialog if applicable

//             // 2. Check if the specific data was loaded successfully
//             if (orderController.fetchSpecificOrderData != null) {
//               Get.dialog(
//                 OrderProcessInvoiceDialog(
//                   // 3. Pass data to specificData instead of invoiceData
//                   specificData: orderController.fetchSpecificOrderData,
//                   selectedTabIndex: selectedTabIndex,
//                   orderController: orderController,
//                 ),
//                 barrierDismissible: true,
//               );
//             } else {
//               throw Exception('No specific order data available');
//             }
//           } catch (e) {
//             Get.back();
//             Get.snackbar('Error', e.toString());
//           }
//         } 
//         // Handle online previews
//         else if (selectedTabIndex == 4 || selectedTabIndex == 5) {
//           showInvoicePreviewOnline(
//             context,
//             orderData.orderId ?? '',
//           );
//         }
//       },
//       icon: const Icon(Icons.visibility, size: 16),
//     ),
//   );
// }

// Widget viewOrder(OrderController orderController, OrderData orderData,
//     BuildContext context) {
//   int selectedTabIndex = orderController.hasOfflineOrders.value
//       ? orderController.selectedTabIndex.value - 1
//       : orderController.selectedTabIndex.value;
//   return Center(
//     child: IconButton(
//       onPressed: () async {
//         if (selectedTabIndex == 0) {
//           try {
//             await orderController.loadOrderProcessInvoiceData(
//               orderId: orderData.orderId!,
//               orderStatus: orderData.orderStatus!,
//             );
//             Get.back();
//             // ignore: unnecessary_null_comparison
//             if (orderController.orderProcessInvoiceData != null) {
//               Get.dialog(
//                 OrderProcessInvoiceDialog(
//                   invoiceData: orderController.orderProcessInvoiceData,
//                   selectedTabIndex: selectedTabIndex,
//                   orderController: orderController,
//                 ),
//                 barrierDismissible: true,
//               );
//             } else {
//               throw Exception('No invoice data available');
//             }
//           } catch (e) {
//             Get.back();
//             Get.snackbar('Error', e.toString());
//           }
//         } else if (selectedTabIndex >= 1 &&
//             selectedTabIndex != 4 &&
//             selectedTabIndex != 5) {
//           try {
//             await orderController.loadOrderProcessInvoiceData(
//               orderId: orderData.orderId!,
//               orderStatus: orderData.orderStatus!,
//             );
//             Get.back();
//             // ignore: unnecessary_null_comparison
//             if (orderController.orderProcessInvoiceData != null) {
//               Get.dialog(
//                 OrderProcessInvoiceDialog(
//                   invoiceData: orderController.orderProcessInvoiceData,
//                   selectedTabIndex: selectedTabIndex,
//                   orderController: orderController,
//                 ),
//                 barrierDismissible: true,
//               );
//             } else {
//               throw Exception('No invoice data available');
//             }
//           } catch (e) {
//             Get.back();
//             // Get.snackbar('Error', e.toString());
//           }
//         } else if (selectedTabIndex == 4 || selectedTabIndex == 5) {
//           showInvoicePreviewOnline(
//             context,
//             orderData.orderId ?? '',
//           );
//         }
//       },
//       icon: const Icon(Icons.visibility, size: 16),
//     ),
//   );
// }
