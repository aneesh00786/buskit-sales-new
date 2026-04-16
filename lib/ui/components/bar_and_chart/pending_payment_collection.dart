
import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/model/pending_payment_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/dashboard_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

void pendingPaymentCollectionDialog(
    BuildContext context, String title, Collection collection) {
  final ScrollController scrollController = ScrollController();

  if (collection.order == null || collection.order!.pendingAmount == null) {
    return;
  }
  bool isOfflinePaymentPending(String orderId) {
    if (!Hive.isBoxOpen('offlineRequests')) return false;
    var box = Hive.box('offlineRequests');
    return box.values.any((request) {
      if (request is Map) {
        final payload = request['payload'];
        return payload != null && payload['order_id'].toString() == orderId;
      }
      return false;
    });
  }
  List<Map<String, dynamic>> getOfflinePaymentsList(String orderId) {
    if (!Hive.isBoxOpen('offlineRequests')) return [];
    var box = Hive.box('offlineRequests');
    List<Map<String, dynamic>> payments = [];

    for (var key in box.keys) {
      var element = box.get(key);
      if (element is Map) {
        final payload = element['payload'];
        if (payload != null && payload['order_id'].toString() == orderId) {
          
          // ✅ NEW LOGIC: Try to get the ID directly from the saved payload first
          String uniqueId;
          
          if (payload['unique_id'] != null) {
             // 1. BEST CASE: Read the exact ID generated during payment
             uniqueId = payload['unique_id'].toString();
          } else {
             // 2. FALLBACK: Only reconstruct if it's an old record (backward compatibility)
             String timestamp = element['timestamp'] ?? DateTime.now().toIso8601String();
             String salesId = payload['sales_id'] ?? 'unknown'; 
             uniqueId = "${timestamp}_$salesId";
          }

          payments.add({
            'hive_key': key, 
            'unique_id': uniqueId, // Now guaranteed to match the API function
            'data': element
          });
        }
      }
    }
    
    // Sort by timestamp descending
    payments.sort((a, b) {
      var tA = DateTime.parse(a['data']['timestamp']);
      var tB = DateTime.parse(b['data']['timestamp']);
      return tB.compareTo(tA);
    });

    return payments;
  }

  // List<Map<String, dynamic>> getOfflinePaymentsList(String orderId) {
  //   if (!Hive.isBoxOpen('offlineRequests')) return [];
  //   var box = Hive.box('offlineRequests');
  //   List<Map<String, dynamic>> payments = [];

  //   // Iterate keys to ensure we have the Hive Key for deletion
  //   for (var key in box.keys) {
  //     var element = box.get(key);
  //     if (element is Map) {
  //       final payload = element['payload'];
  //       if (payload != null && payload['order_id'].toString() == orderId) {
  //         // Construct the requested unique key: time_stamp_sales_id
  //         // Note: Assuming 'sales_id' exists in payload or strictly using timestamp if not.
  //         String timestamp = element['timestamp'] ?? DateTime.now().toIso8601String();
  //         String salesId = payload['sales_id'] ?? 'unknown'; 
  //         String uniqueId = "${timestamp}_$salesId";

  //         payments.add({
  //           'hive_key': key, // Critical for deletion
  //           'unique_id': uniqueId,
  //           'data': element
  //         });
  //       }
  //     }
  //   }
    
  //   // Sort by timestamp descending (newest first)
  //   payments.sort((a, b) {
  //     var tA = DateTime.parse(a['data']['timestamp']);
  //     var tB = DateTime.parse(b['data']['timestamp']);
  //     return tB.compareTo(tA);
  //   });

  //   return payments;
  // }
  Map<String, dynamic>? getOfflinePaymentDetails(String orderId) {
    if (!Hive.isBoxOpen('offlineRequests')) return null;
    var box = Hive.box('offlineRequests');
    try {
      var request = box.values.firstWhere((element) {
        if (element is Map) {
          final payload = element['payload'];
          return payload != null && payload['order_id'].toString() == orderId;
        }
        return false;
      });
      return request;
    } catch (e) {
      return null;
    }
  }
  void showOfflineInfoDialog(BuildContext context, String orderId) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final paymentList = getOfflinePaymentsList(orderId);

          // Auto-close if list became empty
          if (paymentList.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(dialogContext).pop();
              final dashboardProvider = Provider.of<DashboardProvider>(
                context,
                listen: false,
              );
              dashboardProvider.fetchData();
            });
            return const SizedBox.shrink();
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            title: Row(
              children:  [
                Icon(Icons.cloud_off_rounded, color: Colors.deepOrange, size: 28),
                SizedBox(width: 12),
                Text(
                  "Offline Payment Queue".tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite, // helps DataTable take available width
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowHeight: 56,
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                  columns:  [
                    DataColumn(
                      label: Text(
                        'Order ID'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Amount'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Time'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  rows: paymentList.map<DataRow>((item) {
                    final data = item['data'];
                    final payload = data['payload'] as Map;
                    final hiveKey = item['hive_key'];
                    final uniqueKeyStr = item['unique_id'];
                    final timestamp = DateTime.parse(data['timestamp'] as String);
                    
                     final formattedTime = TimeUtils.formatTimeInZone(timestamp);
                    // final formattedTime = DateFormat('hh:mm a • dd MMM').format(timestamp);

                    return DataRow(
                      key: ValueKey(uniqueKeyStr),
                      cells: [
                        DataCell(
                          Text(
                            payload['order_id'].toString(),
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            "${addCurrencySymbol()}${payload['recieved_amount']}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            tooltip: 'Delete from queue',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Remove payment?"),
                                  content: const Text(
                                    "This offline payment record will be permanently deleted from the queue.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed:(){
                                        Navigator.pop(ctx, true);
                                        Get.back(); // Close the info dialog as well
                                      } ,
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final box = Hive.box('offlineRequests');
                                await box.delete(hiveKey);
                                setState(() {}); // refresh table
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  "Close",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
//   void showOfflineInfoDialog(BuildContext context, String orderId) {
//   showDialog(
//     context: context,
//     builder: (ctx) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           var paymentList = getOfflinePaymentsList(orderId);

//           if (paymentList.isEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Navigator.pop(ctx);
//               final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
//               dashboardProvider.fetchData();
//             });
//             return const SizedBox();
//           }

//           return AlertDialog(
//             title: const Row(
//               children: [
//                 Icon(Icons.wifi_off, color: Colors.orange),
//                 SizedBox(width: 10),
//                 Text("Offline Queue", style: TextStyle(fontSize: 16)),
//               ],
//             ),
//             content: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.vertical,
//                 child: DataTable(
//                   columnSpacing: 20,
//                   headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
//                   columns: const [
//                     DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Amount',  style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Time',    style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Action',  style: TextStyle(fontWeight: FontWeight.bold))),
//                   ],
//                   rows: paymentList.map<DataRow>((item) {
//                     final data        = item['data'];
//                     final payload     = data['payload'];
//                     final hiveKey     = item['hive_key'];
//                     final uniqueKeyStr = item['unique_id'];
//                     final timestamp   = DateTime.parse(data['timestamp']);
//                     // ✅ Single-line time format (no \n)
//                     final formattedTime = DateFormat('hh:mm a, dd MMM').format(timestamp);

//                     return DataRow(
//                       key: ValueKey(uniqueKeyStr),
//                       cells: [
//                         // ✅ Fixed width + no wrap on every cell
//                         DataCell(
//                           SizedBox(
//                             width: 80,
//                             child: Text(
//                               payload['order_id'].toString(),
//                               overflow: TextOverflow.ellipsis,
//                               softWrap: false,
//                             ),
//                           ),
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 80,
//                             child: Text(
//                               "${addCurrencySymbol()}${payload['recieved_amount']}",
//                               overflow: TextOverflow.ellipsis,
//                               softWrap: false,
//                             ),
//                           ),
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 110,
//                             child: Text(
//                               formattedTime,
//                               style: const TextStyle(fontSize: 12),
//                               overflow: TextOverflow.ellipsis,
//                               softWrap: false,       // ✅ Prevent line break
//                             ),
//                           ),
//                         ),
//                         DataCell(
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () async {
//                               var box = Hive.box('offlineRequests');
//                               await box.delete(hiveKey);
//                               setState(() {});
//                               Get.back();
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text("Close"),
//               )
//             ],
//           );
//         },
//       );
//     },
//   );
// }
  

  late RxString selectedPaymentMethod;
  selectedPaymentMethod = 'Cash'.obs;
  // String selectedPaymentMethod = 'Cash';
  RxInt selectedPaymentMethodInt = 0.obs;
  DateTime parseCustomDate(String dateStr) {
    final dateFormat = DateFormat("dd/MM/yyyy");
    return dateFormat.parse(dateStr);
  }

  RxList<bool> selectedItems = <bool>[].obs;
  List<PendingAmount> filteredPendingAmount = [];
  void updateSelectedItems() {
    selectedItems.value = List<bool>.generate(
      filteredPendingAmount.length,
      (index) => false,
    );
  }

  bool isWithinThreeDays(DateTime date) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfThreeDaysFromNow = startOfToday
        .add(const Duration(days: 3, hours: 23, minutes: 59, seconds: 59));
    return date.isAtSameMomentAs(startOfToday) ||
        (date.isAfter(startOfToday) && date.isBefore(endOfThreeDaysFromNow)) ||
        date.isAtSameMomentAs(endOfThreeDaysFromNow);
  }

  if (title == 'Due Payment') {
    filteredPendingAmount = collection.due!.dueAmount!.toList();
  } else if (title == 'Over Due Payment') {
    filteredPendingAmount = collection.overdue!.overdueAmount!.toList();
  } else if (title == 'Pending Payment') {
    filteredPendingAmount = collection.order!.pendingAmount!.toList();
  }
  updateSelectedItems();
  Color getDueDateColor(String dueDateStr) {
    try {
      DateTime dueDate = parseCustomDate(dueDateStr);

      if (_isDateToday(dueDate)) {
        return Colors.orange;
      } else if (_isDateBeforeToday(dueDate)) {
        return Colors.red;
      } else if (isWithinThreeDays(dueDate)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  double calculateTotalBalanceAmount() {
    double total = 0;
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        final receivable = filteredPendingAmount[i].pendingAmount;
        if (receivable == null) {
          total += ((filteredPendingAmount[i].orderTotal ?? 0) -
                  (filteredPendingAmount[i].pendingAmount ?? 0))
              .toDouble();
        } else {
          total += receivable;
        }
      }
    }
    return total;
  }

  RxDouble totalBalanceAmount = RxDouble(calculateTotalBalanceAmount());
  RxInt offlineStatusRefresh = 0.obs; // Triggers table rebuild when offline payments change

  final balanceAmountController = TextEditingController(
    text: totalBalanceAmount.value.toStringAsFixed(2),
  );

  final receivedAmountController = TextEditingController();
  final remarksController = TextEditingController();
 Future<void> processPayments(
    List<PendingAmount> selectedItems,
    double enteredAmount,
  ) async {
    for (var item in selectedItems) {
      double itemAmount = (item.receivableAmount ??
              ((item.orderTotal ?? 0) - (item.receivedAmount ?? 0)))
          .toDouble();

      // Ensure we have enough balance (checking > 0.01 handles decimal errors)
      if (enteredAmount > 0.01) {
        
        // Logic: Pay strict item amount, or whatever is left in enteredAmount
        double appliedAmount = 0.0;
        if (enteredAmount >= itemAmount) {
           appliedAmount = itemAmount;
        } else {
           appliedAmount = enteredAmount;
        }

        enteredAmount -= appliedAmount;

        // Only call API if we are actually paying something
        if (appliedAmount > 0) {
            await ApiWorker().customerPayment(
              context: context,
              checkDueDate: "",
              checkNumber: "",
              detail: remarksController.text,
              orderId: item.orderId.toString(),
              paymentType: selectedPaymentMethod.value == 'Cash'
                  ? "0"
                  : selectedPaymentMethod.value == 'Cheque'
                      ? "1"
                      : selectedPaymentMethod.value == 'Bank Transfer'
                          ? "2"
                          : "0",
              receivedAmount: appliedAmount,
              transactionDate: "",
              transactionId: "",
            );

            // ✅ FORCE > 1 SECOND DELAY
            // Many systems use keys like "2023-10-10 10:00:01".
            // If you save two records in the same second, they overwrite each other.
            // 1100ms ensures the clock moves to the next second.
            await Future.delayed(const Duration(milliseconds: 1100));
        }
      }
    }
  }

  // Future<void> processPayments(
  //   List<PendingAmount> selectedItems,
  //   double enteredAmount,
  // ) async {
  //   for (var item in selectedItems) {
  //     double itemAmount = (item.receivableAmount ??
  //             ((item.orderTotal ?? 0) - (item.receivedAmount ?? 0)))
  //         .toDouble();

  //     if (enteredAmount > 0) {
  //       double appliedAmount =
  //           enteredAmount >= itemAmount ? itemAmount : enteredAmount;
  //       enteredAmount -= appliedAmount;
        
  //       // Await the API call here
  //       await ApiWorker().customerPayment(
  //         context: context,
  //         checkDueDate: "",
  //         checkNumber: "",
  //         detail: remarksController.text,
  //         orderId: item.orderId.toString(),
  //         paymentType: selectedPaymentMethod.value == 'Cash'
  //             ? "0"
  //             : selectedPaymentMethod.value == 'Cheque'
  //                 ? "1"
  //                 : selectedPaymentMethod.value == 'Bank Transfer'
  //                     ? "2"
  //                     : "0",
  //         receivedAmount: appliedAmount,
  //         transactionDate: "",
  //         transactionId: "",
  //       );
  //     }
  //   }
  // }


  Widget customPaymentDataTable() {
    return DataTable(
      columnSpacing: 30,
      horizontalMargin: 15,
      dataRowHeight: 30,
      headingRowHeight: 40,
      border: TableBorder.all(color: Colors.grey.shade300),
      columns:  [
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Customer'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Date'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Order No.'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Amount'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Status'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Invoice'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Due Date'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Payment'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Receivable'.tr,
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Select'.tr,
            fontSize: 13,
          ),
        ),
      ],
      rows: [
        ...filteredPendingAmount.asMap().entries.map<DataRow>(
          (entry) {
            int index = entry.key;
            var payment = entry.value;
            bool isOfflinePending = isOfflinePaymentPending(payment.orderId.toString());
            return DataRow(cells: [
              DataCell(Center(child: Text(payment.businessName.toString()))),
              DataCell(Center(
                  child: Text(getFormattedOrderCreatAt(payment.orderCreatAt)))),
              DataCell(Center(child: Text(payment.orderId.toString()))),
              DataCell(Center(child: Text(formatAmount(payment.orderTotal)))),
              DataCell(Center(
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Text(
                              getStatusName(payment.orderStatus?.toInt() ?? 0).tr,
                              style: const TextStyle(
                                color: Colors.white,
                              )))))),
              DataCell(Center(
                  child: InkWell(
                      onTap: () {
                        showInvoicePreviewOnline(
                          context,
                          payment.orderId ?? '',
                        );
                      },
                      child: Text(
                        payment.invoiceId.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: primaryColor),
                      )))),
                   DataCell(
  Center(
    child: Text(
      payment.dueDate != null && payment.dueDate!.isNotEmpty
          ? TimeUtils.formatTimeInZone(
              // THIS IS THE FIX: Tell Dart exactly what format the string is in before parsing
              DateFormat('dd-MM-yyyy').parse(payment.dueDate!.first.toString().replaceAll('/', '-')),
              format: 'dd-MM-yyyy',
            )
          : 'N/A',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: payment.dueDate != null && payment.dueDate!.isNotEmpty
            ? getDueDateColor(payment.dueDate!.first)
            : Colors.grey, 
      ),
    ),
  ),
),
              // DataCell(
              //   Center(
              //     child: Text(
              //       payment.dueDate != null && payment.dueDate!.isNotEmpty
              //           ? payment.dueDate!.first.toString().replaceAll('/', '-')
              //           : 'N/A',
              //       style: TextStyle(
              //         fontWeight: FontWeight.w600,
              //         color: payment.dueDate != null &&
              //                 payment.dueDate!.isNotEmpty
              //             ? getDueDateColor(payment.dueDate!.first)
              //             : Colors
              //                 .grey, // Set color to grey for null or empty dueDate
              //       ),
              //     ),
              //   ),
              // ),
              DataCell(
                Center(
                  child: isOfflinePending
                      ? InkWell(
                          onTap: () {
                             showOfflineInfoDialog(context, payment.orderId.toString());
                          },
                          child: const Icon(
                            Icons.info,
                            color: Colors.blue, 
                            size: 20,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: payment.paymentStatus == 0
                                ? Colors.red
                                : payment.paymentStatus == 1
                                    ? Colors.green
                                    : payment.paymentStatus == 3
                                        ? Colors.amber
                                        : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: payment.paymentStatus == 0
                                  ? Colors.red
                                  : payment.paymentStatus == 1
                                      ? Colors.green
                                      : payment.paymentStatus == 3
                                          ? Colors.amber
                                          : Colors.grey,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Icon(
                              payment.paymentStatus == 0 ? Icons.close : Icons.done,
                              color: Colors.white,
                              size: 14.0,
                            ),
                          ),
                        ),
                ),
              ),
              // DataCell(
              //   Center(
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: payment.paymentStatus == 0
              //             ? Colors.red
              //             : payment.paymentStatus == 1
              //                 ? Colors.green
              //                 : payment.paymentStatus == 3
              //                     ? Colors.amber
              //                     : Colors.grey,
              //         shape: BoxShape.circle,
              //         border: Border.all(
              //           color: payment.paymentStatus == 0
              //               ? Colors.red
              //               : payment.paymentStatus == 1
              //                   ? Colors.green
              //                   : payment.paymentStatus == 3
              //                       ? Colors.amber
              //                       : Colors.grey,
              //         ),
              //       ),
              //       child: Padding(
              //         padding: const EdgeInsets.all(1.0),
              //         child: Icon(
              //           payment.paymentStatus == 0 ? Icons.close : Icons.done,
              //           color: Colors.white,
              //           size: 14.0,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              DataCell(
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: EditablePendingPaymentCell(
                      initialValue: (payment.orderTotal! -
                                      payment.receivedAmount! ==
                                  payment.orderTotal
                              ? payment.orderTotal
                              : payment.orderTotal! - payment.receivedAmount!)
                          .toString(),
                      index: index,
                      orderId: payment.orderId.toString(),
                      orderTotal: payment.orderTotal?.toInt() ?? 0,
                      // receivable: payment.pendingAmount,
                      onValueChanged: (newValue, index) {},
                      amountEdited: payment.amountEdited,
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(child: Obx(() {
                  return Checkbox(
                    value: selectedItems[index],
                    onChanged: (bool? value) {
                      selectedItems[index] = value ?? false;

                      totalBalanceAmount.value = calculateTotalBalanceAmount();
                      balanceAmountController.text =
                          totalBalanceAmount.value.toStringAsFixed(2);
                    },
                  );
                })),
              ),
            ]);
          },
        ),
        // DataRow(cells: [
        //   const DataCell(
        //     Center(
        //       child: Text(
        //         'Totaltt',
        //         style: TextStyle(
        //             fontSize: 12,
        //             fontWeight: FontWeight.w600,
        //             fontFamily: 'Poppins_Regular'),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   ),
        //   const DataCell(Text('')),
        //   const DataCell(Text('')),
        //   DataCell(
        //     Center(
        //       child: Text(
        //         formatAmount(
        //           filteredPendingAmount
        //               .map((e) => e.orderTotal ?? 0.0)
        //               .fold(0.0, (a, b) => a + b),
        //         ),
        //         style: const TextStyle(
        //             fontSize: 12,
        //             fontWeight: FontWeight.w600,
        //             fontFamily: 'Poppins_Regular'),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   ),
        //   const DataCell(Text('')),
        //   const DataCell(Text('')),
        //   const DataCell(Text('')),
        //   const DataCell(Text('')),
        //   DataCell(
        //     Center(
        //       child: Text(
        //         formatAmount(
        //           filteredPendingAmount
        //               .map((e) => e.pendingAmount ?? 0.0)
        //               .fold(0.0, (a, b) => a + b),
        //         ),
        //         style: const TextStyle(
        //             fontSize: 12,
        //             fontWeight: FontWeight.w600,
        //             fontFamily: 'Poppins_Regular'),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   ),
        //   const DataCell(Text('')),
        // ]),
      ],
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // PendingPaymentController orderController =
      // Get.put(PendingPaymentController());
      return Dialog(
        insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 45,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: primaryColor,
                //Color(0xff008000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins_Regular',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  dialogCloseButton1(context, red),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1.3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.dragged)) {
                        return Colors.blueAccent.shade700;
                      }
                      return Colors.blueAccent.shade400;
                    }),
                    trackColor: WidgetStateProperty.all(Colors.blue.shade50),
                    trackBorderColor:
                        WidgetStateProperty.all(Colors.blue.shade100),
                    thickness: WidgetStateProperty.all(6),
                    radius: const Radius.circular(10),
                    minThumbLength: 50,
                  ),
                  child: Scrollbar(
                    controller: scrollController,
                    interactive: true,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Obx(() {
                          offlineStatusRefresh.value; // reactive dependency
                          return customPaymentDataTable();
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (!isPhonePortrait(context)) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        dataRowHeight: 35,
                        headingRowHeight: 30,
                        columns:  [
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Payment Method'.tr,
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Balance Amount'.tr,
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Received Amount'.tr,
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Remarks'.tr,
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(label: Text('')),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(
                                DropdownButtonFormField<String>(
                                  value: selectedPaymentMethod.value,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  dropdownColor: Colors.white,
                                  items:  [
                                    DropdownMenuItem(
                                        value: 'Cash', child: Text('Cash'.tr)),
                                    DropdownMenuItem(
                                        value: 'Cheque', child: Text('Cheque'.tr)),
                                    DropdownMenuItem(
                                        value: 'Bank Transfer',
                                        child: Text('Bank Transfer'.tr)),
                                    DropdownMenuItem(
                                        value: 'QR Payment',
                                        child: Text('QR Payment'.tr)),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectedPaymentMethod.value =
                                          value; // ← now valid

                                      selectedPaymentMethodInt.value =
                                          switch (value) {
                                        'Cash' => 0,
                                        'Cheque' => 1,
                                        'Bank Transfer' => 2,
                                        'QR Payment' => 3,
                                        _ => 0,
                                      };
                                    }
                                  },
                                  // itemHeight: 10,
                                  hint: const Text('Select'),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 24.0, color: Colors.black),
                                  iconSize: 24.0,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Text(addCurrencySymbol()),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        controller: balanceAmountController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    Text(addCurrencySymbol()),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: TextField(
                                        controller: receivedAmountController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter Amount'.tr,
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                TextField(
                                  controller: remarksController,
                                  decoration: InputDecoration(
                                    hintText: 'Remarks'.tr,
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // 1. Validation
                                      final double enteredAmount = double.tryParse(receivedAmountController.text) ?? 0;
                                      if (enteredAmount <= 0) {
                                        showCustomToastDisplay(context, "Please enter a valid amount".tr, Colors.red, Icons.error);
                                        return;
                                      }

                                      // 2. Build Selected List
                                      List<PendingAmount> selectedItemsList = [];
                                      for (int i = 0; i < selectedItems.length; i++) {
                                        if (selectedItems[i]) {
                                          if (title == 'Due Payment') {
                                            selectedItemsList.add(collection.due!.dueAmount![i]);
                                          } else if (title == 'Over Due Payment') {
                                            selectedItemsList.add(collection.overdue!.overdueAmount![i]);
                                          } else {
                                            selectedItemsList.add(collection.order!.pendingAmount![i]);
                                          }
                                        }
                                      }

                                      if (selectedItemsList.isEmpty) {
                                        showCustomToastDisplay(context, "Please select at least one item".tr, Colors.red, Icons.error);
                                        return;
                                      }

                                      // 3. CHECK CONNECTIVITY
                                      bool isOnline = await ConnectivityService().isOnline();

                                      // 4. Handle Offline QR Constraint
                                      if (!isOnline && selectedPaymentMethod.value == 'QR Payment') {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title:  Text("Online Required".tr),
                                            content:  Text("QR Payments can only be processed while online. Please select Cash, Cheque, or Bank Transfer for offline collection.".tr),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx), child:  Text("OK".tr))
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      // 5. Normal Processing (Online or Offline-allowed methods)
                                      if (selectedPaymentMethod.value == 'QR Payment') {
                                        // This implies isOnline is TRUE (checked above)
                                        await _startOnlinePayment(
                                          context,
                                          enteredAmount,
                                          selectedItemsList,
                                          remarks: remarksController.text,
                                        );
                                      } else {
                                        // Cash/Cheque/Bank (Online OR Offline)
                                        
                                        // Await processing (which queues to Hive if offline)
                                        await processPayments(selectedItemsList, enteredAmount);
                                        
                                        // Handle Offline Feedback
                                        if (!isOnline) {
                                          offlineStatusRefresh.value++; // ← rebuild table so ALL selected orders show the info icon
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (ctx) => AlertDialog(
                                              title: const Row(children: [Icon(Icons.wifi_off, color: Colors.orange), SizedBox(width:10), Text("Payment Queued")]),
                                              content:  Text("You are offline. The payment has been saved locally and will complete automatically when you go online.".tr),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx); // Close Dialoglll
                                                    Get.back(); // Close Collection Dialog
                                                    
                                                    // Trigger Dashboard refresh (to update UI with Info icons)
                                                    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
                                                    dashboardProvider.fetchData();
                                                  }, 
                                                  child: const Text("OK")
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          // Normal Online Success Flow
                                          updateSelectedItems();
                                          final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
                                          await dashboardProvider.setTempToFilter();
                                          await dashboardProvider.fetchAllOrdersAtOnce();
                                          dashboardProvider.fetchData();
                                          Get.back();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                    ),
                                    child: Obx(
                                      () => Text(
                                        selectedPaymentMethod.value == 'QR Payment' ? 'Pay'.tr : 'Submit'.tr,
                                        style: const TextStyle(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // DataCell(
                              //   Center(
                              //     child: ElevatedButton(
                              //       onPressed: () async {
                              //         final double enteredAmount =
                              //             double.tryParse(
                              //                     receivedAmountController
                              //                         .text) ??
                              //                 0;

                              //         if (enteredAmount <= 0) {
                              //           showCustomToastDisplay(
                              //               context,
                              //               "Please enter a valid amount",
                              //               Colors.red,
                              //               Icons.error);
                              //           return;
                              //         }

                              //         // Build selected items ONCE — used by BOTH flows
                              //         List<PendingAmount> selectedItemsList =
                              //             [];
                              //         for (int i = 0;
                              //             i < selectedItems.length;
                              //             i++) {
                              //           if (selectedItems[i]) {
                              //             if (title == 'Due Payment') {
                              //               selectedItemsList.add(
                              //                   collection.due!.dueAmount![i]);
                              //             } else if (title ==
                              //                 'Over Due Payment') {
                              //               selectedItemsList.add(collection
                              //                   .overdue!.overdueAmount![i]);
                              //             } else {
                              //               selectedItemsList.add(collection
                              //                   .order!.pendingAmount![i]);
                              //             }
                              //           }
                              //         }

                              //         if (selectedItemsList.isEmpty) {
                              //           showCustomToastDisplay(
                              //               context,
                              //               "Please select at least one item",
                              //               Colors.red,
                              //               Icons.error);
                              //           return;
                              //         }

                              //         // Now decide: Online Payment → QR flow, else → normal payment
                              //         if (selectedPaymentMethod.value ==
                              //             'QR Payment') {
                              //           // await _startOnlinePayment(
                              //           //   context,
                              //           //   enteredAmount,
                              //           //   selectedItemsList,
                              //           //   // collection,
                              //           // );
                              //           await _startOnlinePayment(
                              //             context,
                              //             enteredAmount,
                              //             selectedItemsList,
                              //             remarks: remarksController.text,
                              //           );

                              //           print(
                              //               'payament_type:${selectedPaymentMethod.value}');
                              //         } else {
                              //           // Normal Cash/Cheque/Bank Transfer
                              //           processPayments(
                              //             selectedItemsList,
                              //             enteredAmount,
                              //           );
                              //           // _resetPaymentForm();
                              //           updateSelectedItems();
                              //           final dashboardProvider =
                              //               Provider.of<DashboardProvider>(
                              //                   context,
                              //                   listen: false);
                              //           await dashboardProvider
                              //               .setTempToFilter();

                              //           // DASHBOARD TOP WIDGET ONTAP DIALOG DATA
                              //           await dashboardProvider
                              //               .fetchAllOrdersAtOnce();

                              //           dashboardProvider.fetchData();

                              //           Get.back();
                              //         }
                              //       },
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: Colors.blue,
                              //         // primaryColor.withOpacity(0.2),
                              //         shape: RoundedRectangleBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(10.0)),
                              //       ),
                              //       child: Obx(
                              //         () => Text(
                              //           selectedPaymentMethod.value ==
                              //                   'QR Payment'
                              //               ? 'Pay'
                              //               : 'Submit',
                              //           style: const TextStyle(
                              //               fontSize: 14, color: Colors.white),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (isPhonePortrait(context)) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DataTable(
                            dataRowHeight: 35,
                            headingRowHeight: 30,
                            columns:  [
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Payment Method'.tr,
                                  fontSize: 11,
                                  align: TextAlign.start,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Balance Amount'.tr,
                                  fontSize: 11,
                                  align: TextAlign.start,
                                ),
                              ),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(
                                    DropdownButtonFormField<String>(
                                      // itemHeight: 9,
                                      value: selectedPaymentMethod.value,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                      ),
                                      dropdownColor: Colors.white,
                                      items:  [
                                        DropdownMenuItem(
                                            value: 'Cash', child: Text('Cash'.tr)),
                                        DropdownMenuItem(
                                            value: 'Cheque',
                                            child: Text('Cheque'.tr)),
                                        DropdownMenuItem(
                                            value: 'Bank Transfer',
                                            child: Text('Bank Transfer'.tr)),
                                        DropdownMenuItem(
                                            value: 'QR Payment',
                                            child: Text('QR Payment'.tr)),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          selectedPaymentMethod.value =
                                              value; // ← now valid

                                          selectedPaymentMethodInt.value =
                                              switch (value) {
                                            'Cash' => 0,
                                            'Cheque' => 1,
                                            'Bank Transfer' => 2,
                                            'QR Payment' => 3,
                                            _ => 0,
                                          };
                                        }
                                      },
                                      hint:  Text('Select'.tr),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      icon: const Icon(Icons.arrow_drop_down,
                                          size: 24.0, color: Colors.black),
                                      iconSize: 24.0,
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(addCurrencySymbol()),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: TextField(
                                            readOnly: true,
                                            controller: balanceAmountController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          DataTable(
                            dataRowHeight: 35,
                            headingRowHeight: 30,
                            columns: const [
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Received Amount',
                                  fontSize: 11,
                                  align: TextAlign.start,
                                ),
                              ),
                              DataColumn(
                                label: DialogTableHeaderText(
                                  text: 'Remarks',
                                  fontSize: 11,
                                  align: TextAlign.start,
                                ),
                              ),
                              DataColumn(label: Text('')),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(addCurrencySymbol()),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                receivedAmountController,
                                            decoration: InputDecoration(
                                              hintText: 'Enter Amount'.tr,
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    TextField(
                                      controller: remarksController,
                                      decoration: InputDecoration(
                                        hintText: 'Remarks'.tr,
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final double enteredAmount =
                                              double.tryParse(
                                                      receivedAmountController
                                                          .text) ??
                                                  0;

                                          if (enteredAmount <= 0) {
                                            showCustomToastDisplay(
                                                context,
                                                "Please enter a valid amount",
                                                Colors.red,
                                                Icons.error);
                                            return;
                                          }

                                          // Build selected items ONCE — used by BOTH flows
                                          List<PendingAmount>
                                              selectedItemsList = [];
                                          for (int i = 0;
                                              i < selectedItems.length;
                                              i++) {
                                            if (selectedItems[i]) {
                                              if (title == 'Due Payment') {
                                                selectedItemsList.add(collection
                                                    .due!.dueAmount![i]);
                                              } else if (title ==
                                                  'Over Due Payment') {
                                                selectedItemsList.add(collection
                                                    .overdue!
                                                    .overdueAmount![i]);
                                              } else {
                                                selectedItemsList.add(collection
                                                    .order!.pendingAmount![i]);
                                              }
                                            }
                                          }

                                          if (selectedItemsList.isEmpty) {
                                            showCustomToastDisplay(
                                                context,
                                                "Please select at least one item".tr,
                                                Colors.red,
                                                Icons.error);
                                            return;
                                          }

                                          // Now decide: Online Payment → QR flow, else → normal payment
                                          if (selectedPaymentMethod.value ==
                                              'QR Payment') {
                                            await _startOnlinePayment(
                                              context,
                                              enteredAmount,
                                              selectedItemsList,
                                              remarks: remarksController.text,
                                            );
                                          } else {
                                            // Normal Cash/Cheque/Bank Transfer
                                            processPayments(selectedItemsList,
                                                enteredAmount);
                                            // _resetPaymentForm();
                                            updateSelectedItems();
                                            final dashboardProvider =
                                                Provider.of<DashboardProvider>(
                                                    context,
                                                    listen: false);
                                            await dashboardProvider
                                                .setTempToFilter();

                                            // DASHBOARD TOP WIDGET ONTAP DIALOG DATA
                                            await dashboardProvider
                                                .fetchAllOrdersAtOnce();

                                            dashboardProvider.fetchData();

                                            Get.back();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          // primaryColor.withOpacity(0.2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                        ),
                                        child: Obx(() => Text(
                                              selectedPaymentMethod.value ==
                                                      'QR Payment'
                                                  ? 'Pay'
                                                  : 'Submit',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _startOnlinePayment(
  BuildContext context,
  double amount,
  List<PendingAmount> selectedItemsList, {
  required String remarks,
}) async {
  if (amount <= 0 || selectedItemsList.isEmpty) {
    showCustomToastDisplay(context, "Invalid amount or no items selected".tr,
        Colors.red, Icons.error);
    return;
  }

  final String orderIds =
      selectedItemsList.map((e) => e.orderId.toString()).join(",");

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final session = await ApiWorker().createOnlinePaymentSession(
      amount: amount,
      orderIds: orderIds,
    );

    Navigator.pop(context); // Close loading

    _showQRPaymentModal(
      context: context,
      session: session,
      totalAmount: amount,
      selectedItemsList: selectedItemsList,
      remarks: remarks,
      // paymentType: paymentType,
      // onPaymentSuccess: onPaymentSuccess,
    );
  } catch (error) {
    Navigator.pop(context); // if loading dialog still open
    showCustomToastDisplay(
      context,
      "Failed to start online payment: $error",
      Colors.red,
      Icons.close,
    );
  }
}

void _showQRPaymentModal({
  required BuildContext context,
  required OnlinePaymentSession session,
  required double totalAmount,
  required List<PendingAmount> selectedItemsList,
  required String remarks,
  // required String paymentType,
  // required VoidCallback onPaymentSuccess,
}) {
  Timer? pollTimer;
  bool hasSuccess = false;
  bool isChecking = false; // Prevent overlapping calls
  int pollCount = 0;

//  String? paymentIntentId;
  void handleSuccess(String intentId) async {
    // PendingPaymentController orderController =
    // Get.put(PendingPaymentController());
    int selectedTabIndex = 0;
    if (hasSuccess) return;
    hasSuccess = true;

    print("💳 Payment Intent IDss: $intentId");

    pollTimer?.cancel();

    double remainingAmount = totalAmount;

    for (var item in selectedItemsList) {
      if (remainingAmount <= 0) break;

      double itemAmount = (item.receivableAmount ??
              ((item.orderTotal ?? 0) - (item.receivedAmount ?? 0)))
          .toDouble();

      double appliedAmount =
          remainingAmount >= itemAmount ? itemAmount : remainingAmount;
      remainingAmount -= appliedAmount;

      //  pendingPaymentCollectionDialog(
      //                   context, 'Pending Payment',collection);
      // Call API with payment_type = "3" for Online Payment
      ApiWorker().customerPayment(
        context: context,
        checkDueDate: "",
        checkNumber: "",
        detail: remarks,
        orderId: item.orderId.toString(),
        paymentType: "3", // ✅ Hardcoded for Online Payment
        receivedAmount: appliedAmount,
        transactionDate: "",
        transactionId: intentId, // Use session ID as transaction ID
      );
    }

    // Use a small delay to ensure context is still valid
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        // orderController.loadOrderData(chartIndex: selectedTabIndex);
        Navigator.of(context).pop();

        showCustomToastDisplay(
          context,
          "Payment Successful!",
          Colors.green,
          Icons.check,
        );
        Navigator.of(context).pop();
      }
    });
    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    await dashboardProvider.setTempToFilter();

    // DASHBOARD TOP WIDGET ONTAP DIALOG DATA
    await dashboardProvider.fetchAllOrdersAtOnce();

    dashboardProvider.fetchData();
    //  orderController.loadOrderData(chartIndex: 0);
  }

  Future<void> checkPayment() async {
    // Prevent overlapping API calls
    if (isChecking || hasSuccess) {
      print("⏭️ Skipping check (already checking or succeeded)");
      return;
    }

    isChecking = true;
    pollCount++;

    try {
      final result = await ApiWorker().verifyOnlinePaymentSession(
        sessionId: session.sessionId,
        companyId: "1",
      );
      if (result.paid == true ||
          result.paymentStatus?.toLowerCase() == "paid") {
        final intentId = result.paymentIntentId;
        // print("💰 Payment detected as successful!");
        handleSuccess(intentId!);
      } else {
        print("⏳ Payment still pending...");
      }
    } catch (e) {
      print("❌ Poll #$pollCount Error: $e");
      // Continue polling on error - don't set hasSuccess
    } finally {
      isChecking = false;
    }
  }

  // Start initial aggressive polling
  pollTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) async {
    if (hasSuccess) {
      pollTimer?.cancel();
      // print("🛑 Timer cancelled - payment successful");
      return;
    }

    await checkPayment();

    // After 15 attempts (~12 seconds), switch to slower polling
    if (pollCount == 15) {
      // print("⏰ Switching to slower polling (3s interval)");
      pollTimer?.cancel();

      // Create new timer for slower polling
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        if (hasSuccess) {
          pollTimer?.cancel();
          // print("🛑 Slow timer cancelled - payment successful");
          return;
        }
        await checkPayment();

        // Optional: Stop after 5 minutes total
        if (pollCount > 100) {
          print("⏱️ Max polling attempts reached");
          pollTimer?.cancel();
        }
      });
    }
  });

  // Show QR Dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => WillPopScope(
      onWillPop: () async {
        print("🚪 Dialog dismissed by user");
        pollTimer?.cancel();
        return true;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Scan QR to Pay",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: session.url,
                size: 240,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 16),
              Text(
                "Amount: ${addCurrencySymbol()}${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Scan with Phone Camera\nGoogle Pay • Apple Pay • Card",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print("❌ User cancelled payment");
                  pollTimer?.cancel();
                  Navigator.of(ctx).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    ),
  ).then((_) {
    print("🔚 Dialog closed - cleaning up timer");
    pollTimer?.cancel();
  });
}

DateTime normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _isDateBeforeToday(DateTime date) {
  final today = normalizeDate(DateTime.now());
  final normalizedDate = normalizeDate(date);
  return normalizedDate.isBefore(today);
}

bool _isDateToday(DateTime date) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfToday = startOfToday
      .add(const Duration(days: 1))
      .subtract(const Duration(seconds: 1));
  return date.isAtSameMomentAs(startOfToday) ||
      (date.isAfter(startOfToday) && date.isBefore(endOfToday));
}