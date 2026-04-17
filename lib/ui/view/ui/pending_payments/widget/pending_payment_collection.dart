

import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/model/pending_payment_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart'; // Needed for companyId
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart'; // Required for Offline Storage
import 'package:intl/intl.dart'; // Required for DateFormat
import 'package:qr_flutter/qr_flutter.dart';

// --- OFFLINE HELPER FUNCTIONS ---

// Check if an order has a pending offline payment
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

// bool isOfflinePaymentPending(String orderId) {
//   if (!Hive.isBoxOpen('offlineRequests')) return false;
//   var box = Hive.box('offlineRequests');
//   // Check if any request in the box matches this orderId
//   return box.values.any((request) {
//     if (request is Map) {
//       final payload = request['payload'];
//       return payload != null && payload['order_id'].toString() == orderId;
//     }
//     return false;
//   });
// }
List<Map<String, dynamic>> getOfflinePaymentsList(String orderId) {
  if (!Hive.isBoxOpen('offlineRequests')) return [];
  var box = Hive.box('offlineRequests');
  List<Map<String, dynamic>> payments = [];

  for (var key in box.keys) {
    var element = box.get(key);
    if (element is Map) {
      final payload = element['payload'];
      if (payload != null && payload['order_id'].toString() == orderId) {
        // Generate Unique ID for UI keys
        String uniqueId;
        if (payload['unique_id'] != null) {
          uniqueId = payload['unique_id'].toString();
        } else {
          // Fallback for older records
          String timestamp =
              element['timestamp'] ?? DateTime.now().toIso8601String();
          String salesId = payload['sales_id'] ?? 'unknown';
          uniqueId = "${timestamp}_$salesId";
        }

        payments.add({'hive_key': key, 'unique_id': uniqueId, 'data': element});
      }
    }
  }

  // Sort by timestamp descending (Newest first)
  payments.sort((a, b) {
    var tA = DateTime.parse(a['data']['timestamp']);
    var tB = DateTime.parse(b['data']['timestamp']);
    return tB.compareTo(tA);
  });

  return payments;
}

// Get details for the info dialog
Map<String, dynamic>? getOfflinePaymentDetails(String orderId) {
  if (!Hive.isBoxOpen('offlineRequests')) return null;
  var box = Hive.box('offlineRequests');
  try {
    return box.values.firstWhere((element) {
      if (element is Map) {
        final payload = element['payload'];
        return payload != null && payload['order_id'].toString() == orderId;
      }
      return false;
    });
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

          // Auto-close when last item is deleted
          if (paymentList.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(dialogContext).pop();
              // Optional: refresh parent screen / controller
              // Get.find<PendingPaymentController>()?.update();
              // or Provider.of<SomeProvider>(context, listen: false).fetchData();
            });
            return const SizedBox.shrink();
          }

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            title: Row(
              children: const [
                Icon(Icons.cloud_off_rounded,
                    color: Colors.deepOrange, size: 28),
                SizedBox(width: 12),
                Text(
                  "Offline Payment Queue",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowHeight: 56,
                  horizontalMargin: 16,
                  columnSpacing: 32,
                  headingRowColor:
                      MaterialStateProperty.all(Colors.grey.shade100),
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
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
                    final timestamp =
                        DateTime.parse(data['timestamp'] as String);

                    final formattedTime =
                        DateFormat('dd MMM • hh:mm a').format(timestamp);

                    final paymentType = payload['payment_type'] == '0'
                        ? 'Cash'
                        : payload['payment_type'] == '1'
                            ? 'Cheque'
                            : 'Bank';

                    return DataRow(
                      key: ValueKey(uniqueKeyStr),
                      cells: [
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
                            paymentType,
                            style: const TextStyle(fontSize: 14),
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
                            tooltip: 'Remove from queue',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Remove this payment?"),
                                  content: const Text(
                                    "This offline payment record will be permanently deleted.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx, true);
                                        Get.back(); // Close the info dialog as well
                                      },
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
// void showOfflineInfoDialog(BuildContext context, String orderId) {
//   showDialog(
//     context: context,
//     builder: (ctx) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           // Fetch the list every time the builder runs (allowing delete updates)
//           var paymentList = getOfflinePaymentsList(orderId);

//           // If user deleted the last item, close the dialog automatically
//           if (paymentList.isEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Navigator.pop(ctx);
//               // Optional: Trigger a refresh on the main controller if needed
//               // Get.find<PendingPaymentController>().update();
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
//                     DataColumn(label: Text('Amount',  style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Type',    style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Time',    style: TextStyle(fontWeight: FontWeight.bold))),
//                     DataColumn(label: Text('Action',  style: TextStyle(fontWeight: FontWeight.bold))),
//                   ],
//                   rows: paymentList.map<DataRow>((item) {
//                     final data        = item['data'];
//                     final payload     = data['payload'];
//                     final hiveKey     = item['hive_key'];
//                     final uniqueKeyStr = item['unique_id'];
//                     final timestamp   = DateTime.parse(data['timestamp']);
//                     final formattedTime = DateFormat('dd MMM, hh:mm a').format(timestamp);

//                     String paymentType = payload['payment_type'] == '0' ? 'Cash'
//                                        : payload['payment_type'] == '1' ? 'Cheque'
//                                        : 'Bank';

//                     return DataRow(
//                       key: ValueKey(uniqueKeyStr),
//                       cells: [
//                         DataCell(
//                           Text("${addCurrencySymbol()}${payload['recieved_amount']}"),
//                         ),
//                         DataCell(
//                           Text(paymentType),
//                         ),
//                         DataCell(
//                           Text(formattedTime, style: const TextStyle(fontSize: 12)),
//                         ),
//                         DataCell(
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () async {
//                               // Delete from Hive
//                               var box = Hive.box('offlineRequests');
//                               await box.delete(hiveKey);

//                               // Trigger UI rebuild inside this dialog
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

//

// ---------------------------------
void pendingPaymentCollectionDialog(
    BuildContext context, String customerId) async {
  final PendingPaymentController controller =
      Get.put(PendingPaymentController());

  // Use RxString for reactivity
  late RxString selectedPaymentMethod = 'Cash'.obs;

  // 1. ALWAYS SHOW LOADING INITIALIZATION
  // We do this regardless of online/offline status because the controller
  // determines the source (API or Hive).
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  // 2. LOAD DATA
  // Ensure your PendingPaymentController.loadIndividualPendingPayments
  // is updated to fetch from Hive if the API fails/offline.
  await controller.loadIndividualPendingPayments(customerId);

  // Close the loading indicator
  Get.back();

  // 3. CHECK IF DATA WAS FOUND
  if (controller.individualPendingPayments.isEmpty) {
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      // Offline and no data in Hive
      showCustomToastDisplay(
          context,
          "No offline data available. Please connect to the internet once to sync this customer.".tr,
          Colors.red,
          Icons.warning);
    } else {
      // Online and no data from API
      showCustomToastDisplay(
          context,
          "No pending payments found for this customer.".tr,
          Colors.orange,
          Icons.info);
    }
    return; // Exit if no data
  }

  // 4. PREPARE UI STATE
  RxList<bool> selectedItems = List<bool>.generate(
    controller.individualPendingPayments.length,
    (index) => false,
  ).obs;

  double calculateTotalBalanceAmount() {
    double total = 0;
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        final item = controller.individualPendingPayments[i];
        total += (item.pendingAmount ?? item.orderTotal ?? 0).toDouble();
      }
    }
    return total;
  }

  RxDouble totalBalanceAmount = RxDouble(calculateTotalBalanceAmount());
  final balanceAmountController = TextEditingController(
    text: totalBalanceAmount.value.toStringAsFixed(2),
  );
  final receivedAmountController = TextEditingController();
  final remarksController = TextEditingController();

  // Listen to selection changes
  ever(selectedItems, (_) {
    totalBalanceAmount.value = calculateTotalBalanceAmount();
    balanceAmountController.text = totalBalanceAmount.value.toStringAsFixed(2);
  });

  // --- INTERNAL FUNCTION: PROCESS PAYMENTS (Online & Offline) ---
  Future<void> processPayments(List<IndividualPendingData> selectedItemsList,
      double enteredAmount) async {
    double remaining = enteredAmount;

    // Check connectivity right before processing
    bool isNowOnline = await ConnectivityService().isOnline();

    for (var item in selectedItemsList) {
      if (remaining <= 0) break;

      double itemAmount =
          (item.pendingAmount ?? item.orderTotal ?? 0).toDouble();
      double appliedAmount = remaining >= itemAmount ? itemAmount : remaining;
      remaining -= appliedAmount;

      final paymentType = selectedPaymentMethod.value == 'Cash'
          ? "0"
          : selectedPaymentMethod.value == 'Cheque'
              ? "1"
              : "2";

      if (isNowOnline) {
        // ONLINE: Call API Directly
        ApiWorker().customerPayment(
          context: context,
          checkDueDate: "",
          checkNumber: "",
          detail: remarksController.text,
          orderId: item.orderId.toString(),
          paymentType: paymentType,
          receivedAmount: appliedAmount,
          transactionDate: "",
          transactionId: "",
        );
      } else {
        // OFFLINE: Save to Hive
        final requestPayload = {
          "check_due_date": "",
          "check_number": "",
          "detail": remarksController.text,
          "order_id": item.orderId.toString(),
          "payment_type": paymentType,
          "recieved_amount": appliedAmount,
          "transation_date": "",
          "transation_id": "",
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        };

        var box = await Hive.openBox('offlineRequests');
        await box.add({
          "url": '${ApiConstants.baseUrl}${ApiConstants.customerPayment}',
          "payload": requestPayload,
          "timestamp": DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // --- INTERNAL FUNCTION: SHOW QR MODAL ---
  void _showQRPaymentModal({
    required BuildContext context,
    required OnlinePaymentSession session,
    required double totalAmount,
    required List<IndividualPendingData> selectedItemsList,
    required String remarks,
  }) {
    PendingPaymentController orderController =
        Get.put(PendingPaymentController());
    Timer? pollTimer;
    bool hasSuccess = false;
    bool isChecking = false;
    int pollCount = 0;

    void handleSuccess(String intentId) {
      if (hasSuccess) return;
      hasSuccess = true;
      pollTimer?.cancel();

      double remainingAmount = totalAmount;
      for (var item in selectedItemsList) {
        if (remainingAmount <= 0) break;

        double itemAmount =
            (item.pendingAmount ?? item.orderTotal ?? 0).toDouble();
        double appliedAmount =
            remainingAmount >= itemAmount ? itemAmount : remainingAmount;
        remainingAmount -= appliedAmount;

        ApiWorker().customerPayment(
          context: context,
          checkDueDate: "",
          checkNumber: "",
          detail: remarks,
          orderId: item.orderId.toString(),
          paymentType: "3", // Online Payment
          receivedAmount: appliedAmount,
          transactionDate: "",
          transactionId: intentId,
        );
      }

      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          Get.back(); // Close QR
          Get.back(); // Close Loading/Main
          Get.back();
          showCustomToastDisplay(
              context, "Payment Successful!".tr, Colors.green, Icons.check);
        }
      });
      orderController.loadOrderData(chartIndex: 0);
    }

    Future<void> checkPayment() async {
      if (isChecking || hasSuccess) return;
      isChecking = true;
      pollCount++;

      try {
        final result = await ApiWorker().verifyOnlinePaymentSession(
          sessionId: session.sessionId,
          companyId: "1",
        );

        if (result.paid == true ||
            result.paymentStatus?.toLowerCase() == "paid") {
          handleSuccess(result.paymentIntentId ?? session.sessionId);
        }
      } catch (e) {
        // print("Poll error: $e");
      } finally {
        isChecking = false;
      }
    }

    pollTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) async {
      if (hasSuccess) {
        pollTimer?.cancel();
        return;
      }
      await checkPayment();

      if (pollCount == 15) {
        pollTimer?.cancel();
        pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          if (hasSuccess || pollCount > 100) {
            pollTimer?.cancel();
            return;
          }
          await checkPayment();
        });
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async {
          pollTimer?.cancel();
          return true;
        },
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text("Scan QR to Pay".tr,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                QrImageView(
                    data: session.url,
                    size: 240,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(12)),
                const SizedBox(height: 16),
                Text(
                    "Amount: ${addCurrencySymbol()}${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                 Text(
                    "Scan with Phone Camera\nGoogle Pay • Apple Pay • Card".tr,
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    pollTimer?.cancel();
                    Get.back(closeOverlays: true);
                    Get.back();
                  },
                  child:  Text("Cancel".tr),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => pollTimer?.cancel());
  }

  // --- INTERNAL FUNCTION: START ONLINE PAYMENT ---
  Future<void> _startOnlinePayment(
    double amount,
    List<IndividualPendingData> selectedItemsList, {
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

      _showQRPaymentModal(
        context: context,
        session: session,
        totalAmount: amount,
        selectedItemsList: selectedItemsList,
        remarks: remarks,
      );
    } catch (error) {
      Navigator.pop(context);
      showCustomToastDisplay(context, "Failed to start online payment: $error",
          Colors.red, Icons.close);
    }
  }

  // --- 5. BUILD MAIN DIALOG UI ---
  showDialog(
    context: context,
    builder: (BuildContext context) {
      PendingPaymentController orderController =
          Get.put(PendingPaymentController());

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width:double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  height: 45,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text('Payment'.tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      dialogCloseButton1(context, red),
                    ],
                  ),
                ),
          
                // Pending Items Table
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                   width: double.infinity,
                    child: Obx(() => DataTable(
                         columnSpacing: 15.0, 
                          dataRowHeight: 30,
                          headingRowHeight: 40,
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns:  [
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Date'.tr, fontSize: 13)),
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Invoice'.tr, fontSize: 13)),
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Amount'.tr, fontSize: 13)),
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Status'.tr, fontSize: 13)),
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Payment'.tr, fontSize: 13)),
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Receivable'.tr, fontSize: 13)),
                            DataColumn(
                                label: DialogTableHeaderText(
                                    text: 'Select'.tr, fontSize: 13)),
                          ],
                          rows: controller.individualPendingPayments
                              .asMap()
                              .entries
                              .map<DataRow>((entry) {
                            int index = entry.key;
                            var payment = entry.value;
                            
                            // Check offline status for Info Icon
                            bool isOfflinePending =
                                isOfflinePaymentPending(payment.orderId.toString());
                            
                            return DataRow(cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    payment.orderCreatAt != null &&
                                            payment.orderCreatAt
                                                .toString()
                                                .isNotEmpty
                                        ? TimeUtils.formatTimeInZone(
                                            DateTime.parse(
                                                payment.orderCreatAt.toString()),
                                            format: 'dd-MM-yyyy'
                                            // Optional: Add a specific format here if needed, like format: 'dd-MM-yyyy'
                                            )
                                        : 'N/A',
                                  ),
                                ),
                              ),
                              // DataCell(Center(child: Text(getFormattedOrderCreatAt(payment.orderCreatAt)))),
                              DataCell(Center(
                                  child: InkWell(
                                onTap: () => showInvoicePreviewOnline(
                                    context, payment.orderId),
                                child: Text(payment.invoiceId,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontFamily: 'Poppins_Regular',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10),
                                    maxLines: 1),
                              ))),
                              DataCell(Center(
                                  child: Text(formatAmount(payment.orderTotal),
                                      maxLines: 1))),
                              DataCell(Center(
                                  child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0))),
                                child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(getStatusName(payment.orderStatus).tr,
                                        style:
                                            const TextStyle(color: Colors.white))),
                              ))),
                              // Payment Status / Info Icon
                              DataCell(Center(
                                child: isOfflinePending
                                    ? InkWell(
                                        onTap: () {
                                          showOfflineInfoDialog(
                                              context, payment.orderId.toString());
                                        },
                                        child: const Icon(Icons.info,
                                            color: Colors.blue, size: 20),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: payment.paymentStatus == 0
                                              ? Colors.red
                                              : Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: payment.paymentStatus == 0
                                                  ? Colors.red
                                                  : Colors.green),
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Icon(
                                                payment.paymentStatus == 0
                                                    ? Icons.close
                                                    : Icons.done,
                                                color: Colors.white,
                                                size: 14.0)),
                                      ),
                              )),
                              DataCell(Center(
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 3.0),
                                      child: EditablePendingPaymentCell(
                                        initialValue:
                                            payment.pendingAmount.toString(),
                                        index: index,
                                        orderId: payment.orderId,
                                        orderTotal: payment.orderTotal,
                                        onValueChanged: (newValue, index) {},
                                        amountEdited: payment.amountEdited,
                                      )))),
                              DataCell(Center(child: Obx(() {
                                return Checkbox(
                                  value: selectedItems[index],
                                  onChanged: (bool? value) {
                                    selectedItems[index] = value ?? false;
                                    totalBalanceAmount.value =
                                        calculateTotalBalanceAmount();
                                    balanceAmountController.text =
                                        totalBalanceAmount.value.toStringAsFixed(2);
                                  },
                                );
                              }))),
                            ]);
                          }).toList(),
                        )),
                  ),
                ),
          // const SizedBox(height: 10),
                // Payment Input Table
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    // padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      columnSpacing: 15.0,
                      columns:  [
                        DataColumn(
                            label: DialogTableHeaderText(
                                text: 'Payment Method'.tr,
                                fontSize: 11,
                                align: TextAlign.start)),
                        DataColumn(
                            label: DialogTableHeaderText(
                                text: 'Balance Amount'.tr,
                                fontSize: 11,
                                align: TextAlign.start)),
                        DataColumn(
                            label: DialogTableHeaderText(
                                text: 'Received Amount'.tr,
                                fontSize: 11,
                                align: TextAlign.start)),
                        DataColumn(
                            label: DialogTableHeaderText(
                                text: 'Remarks'.tr,
                                fontSize: 11,
                                align: TextAlign.start)),
                        DataColumn(label: Text('')),
                      ],
                      rows: [
                        DataRow(cells: [
                          // Dropdown
                          DataCell(DropdownButtonFormField<String>(
                            value: selectedPaymentMethod.value,
                            items: ['Cash', 'Cheque', 'Bank Transfer', 'QR Payment']
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e.tr)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) selectedPaymentMethod.value = val;
                            },
                          )),
                          // Balance
                          DataCell(Row(children: [
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
                                                BorderRadius.circular(10.0)),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8.0))))
                          ])),
                          // Received
                          DataCell(Row(children: [
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
                                                BorderRadius.circular(10.0)),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8.0))))
                          ])),
                          // Remarks
                          DataCell(TextField(
                              controller: remarksController,
                              decoration: InputDecoration(
                                  hintText: 'Remarks'.tr,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10.0)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0)))),
                          // Submit Button
                          DataCell(Center(
                              child: ElevatedButton(
                            onPressed: () async {
                              // Validation
                              double enteredAmount =
                                  double.tryParse(receivedAmountController.text) ??
                                      0;
                              if (enteredAmount <= 0) {
                                showCustomToastDisplay(context,
                                    "Enter valid amount".tr, Colors.red, Icons.error);
                                return;
                              }
                            
                              List<IndividualPendingData> selectedItemsList = [];
                              for (int i = 0; i < selectedItems.length; i++) {
                                if (selectedItems[i])
                                  selectedItemsList
                                      .add(controller.individualPendingPayments[i]);
                              }
                              if (selectedItemsList.isEmpty) {
                                showCustomToastDisplay(
                                    context,
                                    "Select at least one item".tr,
                                    Colors.red,
                                    Icons.error);
                                return;
                              }
                            
                              // Check Connectivity for processing
                              bool isOnlineForSubmit =
                                  await ConnectivityService().isOnline();
                            
                              if (selectedPaymentMethod.value == 'QR Payment') {
                                if (!isOnlineForSubmit) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Online Required"),
                                      content:  Text(
                                          "QR Payments can only be processed while online.".tr),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child:  Text("OK".tr))
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                await _startOnlinePayment(
                                    enteredAmount, selectedItemsList,
                                    remarks: remarksController.text);
                                await orderController.loadOrderData(chartIndex: 0);
                              } else {
                                // Offline/Online Processing (Cash/Cheque/Bank)
                                await processPayments(
                                    selectedItemsList, enteredAmount);
                            
                                if (isOnlineForSubmit) {
                                  Navigator.pop(context);
                                  showCustomToastDisplay(
                                      context,
                                      "Payment submitted".tr,
                                      Colors.green,
                                      Icons.check);
                                  await orderController.loadOrderData(
                                      chartIndex: 0);
                                } else {
                                  // Offline Success Dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => AlertDialog(
                                      title:  Row(children: [
                                        Icon(Icons.wifi_off, color: Colors.orange),
                                        SizedBox(width: 10),
                                        Text("Payment Queue".tr)
                                      ]),
                                      content:  Text(
                                          "You are offline. The payment has been saved locally and will complete automatically when you go online.".tr),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              Get.back();
                                              controller
                                                  .refresh(); // Refresh UI to show info icons
                                            },
                                            child:  Text("OK".tr))
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            child: Obx(() => Text(
                                  selectedPaymentMethod.value == 'QR Payment'
                                      ? 'Pay'.tr
                                      : 'Submit'.tr,
                                  style: const TextStyle(color: Colors.white),
                                )),
                          ))),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
