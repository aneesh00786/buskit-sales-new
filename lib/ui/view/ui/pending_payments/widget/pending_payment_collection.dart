// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';


void pendingPaymentCollectionDialog(
    BuildContext context, String customerId) async {
  final PendingPaymentController controller =
      Get.put(PendingPaymentController());

  // Use RxString for reactivity (important for Obx)
  late RxString selectedPaymentMethod = 'Cash'.obs;
  RxInt selectedPaymentMethodInt = 0.obs;

  bool isOnline = await ConnectivityService().isOnline();
  if (!isOnline) {
    showCustomToastDisplay(context, "You are Offline", red, Icons.warning);
    return;
  }

  // Show loading
  late BuildContext loadingContext;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      loadingContext = ctx;
      return const Center(child: CircularProgressIndicator());
    },
  );

  await controller.loadIndividualPendingPayments(customerId);
  Navigator.pop(loadingContext);

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

  // Normal Payment Processing (Cash, Cheque, Bank Transfer)
  void processPayments(List<IndividualPendingData> selectedItemsList, double enteredAmount) {
    double remaining = enteredAmount;
    for (var item in selectedItemsList) {
      if (remaining <= 0) break;

      double itemAmount = (item.pendingAmount ?? item.orderTotal ?? 0).toDouble();
      double appliedAmount = remaining >= itemAmount ? itemAmount : remaining;
      remaining -= appliedAmount;

      ApiWorker().customerPayment(
        context: context,
        checkDueDate: "",
        checkNumber: "",
        detail: remarksController.text,
        orderId: item.orderId.toString(),
        paymentType: selectedPaymentMethod.value == 'Cash'
            ? "0"
            : selectedPaymentMethod.value == 'Cheque'
                ? "1"
                : "2",
        receivedAmount: appliedAmount,
        transactionDate: "",
        transactionId: "",
      );
    }
  }

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

        double itemAmount = (item.pendingAmount ?? item.orderTotal ?? 0).toDouble();
        double appliedAmount = remainingAmount >= itemAmount ? itemAmount : remainingAmount;
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
          Get.back();
          Get.back();
          Get.back();
          // Navigator.of(context).pop(); // Close QR dialog
          // Navigator.of(context).pop(); // Close main dialog
          showCustomToastDisplay(context, "Payment Successful!", Colors.green, Icons.check);
          // controller.loadIndividualPendingPayments(customerId); // Refresh
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

        if (result.paid == true || result.paymentStatus?.toLowerCase() == "paid") {
          handleSuccess(result.paymentIntentId ?? session.sessionId);
        }
      } catch (e) {
        print("Poll error: $e");
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Scan QR to Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                QrImageView(data: session.url, size: 240, backgroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                const SizedBox(height: 16),
                Text("Amount: ${addCurrencySymbol()}${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text("Scan with Phone Camera\nGoogle Pay • Apple Pay • Card", textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    pollTimer?.cancel();
                    Get.back(closeOverlays: true);
                    Get.back();
                    // pollTimer?.cancel();
                    // Navigator.of(ctx).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => pollTimer?.cancel());
  }


  // Online Payment: Create Session + Show QR
  Future<void> _startOnlinePayment(
    double amount,
    List<IndividualPendingData> selectedItemsList, {
    required String remarks,
  }) async {
    if (amount <= 0 || selectedItemsList.isEmpty) {
      showCustomToastDisplay(context, "Invalid amount or no items selected", Colors.red, Icons.error);
      return;
    }

    final String orderIds = selectedItemsList.map((e) => e.orderId.toString()).join(",");

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

      // Navigator.pop(context); // Close loading
      _showQRPaymentModal(
        context: context,
        session: session,
        totalAmount: amount,
        selectedItemsList: selectedItemsList,
        remarks: remarks,
      );
    } catch (error) {
      Navigator.pop(context);
      showCustomToastDisplay(context, "Failed to start online payment: $error", Colors.red, Icons.close);
    }
  }

  // QR Modal + Polling Logic (Same as first dialog)
  
  // Show Main Dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
       PendingPaymentController orderController =
      Get.put(PendingPaymentController());
      // int 0 = 0;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                height: 45,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    dialogCloseButton1(context, red),
                  ],
                ),
              ),

              // Pending Items Table
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() => 

                DataTable(
                          dataRowHeight: 30,
                          headingRowHeight: 40,
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Date',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Invoice',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Amount',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Status',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Payment',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Receivable',
                                fontSize: 13,
                              ),
                            ),
                            DataColumn(
                              label: DialogTableHeaderText(
                                text: 'Select',
                                fontSize: 13,
                              ),
                            ),
                          ],
                          rows: controller.individualPendingPayments
                              .asMap()
                              .entries
                              .map<DataRow>((entry) {
                            int index = entry.key;
                            var payment = entry.value;
                            return DataRow(cells: [
                              DataCell(Center(
                                  child: Text(getFormattedOrderCreatAt(
                                      payment.orderCreatAt)))),
                              DataCell(Center(
                                  child: InkWell(
                                onTap: () {
                                  showInvoicePreviewOnline(
                                    context,
                                    payment.orderId,
                                  );
                                },
                                child: Text(
                                  payment.invoiceId,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                ),
                              ))),
                              DataCell(Center(
                                  child: Text(formatAmount(payment.orderTotal),
                                      maxLines: 1))),
                              DataCell(Center(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    //Color(0xff008000),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      getStatusName(payment.orderStatus),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                              DataCell(
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: payment.paymentStatus == 0
                                          ? Colors.red
                                          : Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: payment.paymentStatus == 0
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Icon(
                                        payment.paymentStatus == 0
                                            ? Icons.close
                                            : Icons.done,
                                        color: Colors.white,
                                        size: 14.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: EditablePendingPaymentCell(
                                      initialValue:
                                          // (payment.orderTotal -
                                          //                 payment.receivedAmount ==
                                          //             payment.orderTotal
                                          //         ? payment.orderTotal
                                          //         : payment.orderTotal -
                                          //             payment.receivedAmount)
                                          payment.pendingAmount.toString(),
                                      index: index,
                                      orderId: payment.orderId,
                                      orderTotal: payment.orderTotal,
                                      // receivable: payment.receivableAmount,
                                      onValueChanged: (newValue, index) {
                                        // Handle editable cells if necessary
                                      },
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
                                      // Update selected items list when checkbox is toggled
                                      selectedItems[index] = value ?? false;

                                      // Recalculate total balance amount
                                      totalBalanceAmount.value =
                                          calculateTotalBalanceAmount();
                                      balanceAmountController.text =
                                          totalBalanceAmount.value
                                              .toStringAsFixed(2);
                                    },
                                  );
                                })),
                              ),
                            ]);
                          }).toList(),
                        )
              
                ),
              ),

              // Payment Input Table
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: 
                DataTable(
                  columns: const [
                     DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Payment Method',
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
                          DataColumn(
                            label: DialogTableHeaderText(
                              text: 'Balance Amount',
                              fontSize: 11,
                              align: TextAlign.start,
                            ),
                          ),
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
                    DataRow(cells: [
                      DataCell(DropdownButtonFormField<String>(
                        value: selectedPaymentMethod.value,
                        items: [
                          'Cash',
                          'Cheque',
                          'Bank Transfer',
                          'QR Payment', // Added
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) selectedPaymentMethod.value = val;
                        },
                      )),
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
                                          hintText: 'Enter Amount',
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
                                    hintText: 'Remarks',
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
                      DataCell(Center(child: ElevatedButton(
                        onPressed: () async {
                          double enteredAmount = double.tryParse(receivedAmountController.text) ?? 0;
                          if (enteredAmount <= 0) {
                            showCustomToastDisplay(context, "Enter valid amount", Colors.red, Icons.error);
                            return;
                          }

                          List<IndividualPendingData> selectedItemsList = [];
                          for (int i = 0; i < selectedItems.length; i++) {
                            if (selectedItems[i]) {
                              selectedItemsList.add(controller.individualPendingPayments[i]);
                            }
                          }

                          if (selectedItemsList.isEmpty) {
                            showCustomToastDisplay(context, "Select at least one item", Colors.red, Icons.error);
                            return;
                          }

                          if (selectedPaymentMethod.value == 'QR Payment') {
                            await _startOnlinePayment(
                              enteredAmount,
                              selectedItemsList,
                              remarks: remarksController.text,
                            );
                            await orderController.loadOrderData(chartIndex: 0);
                          } else {
                            processPayments(selectedItemsList, enteredAmount);
                            Navigator.pop(context);
                            showCustomToastDisplay(context, "Payment submitted", Colors.green, Icons.check);
                            await orderController.loadOrderData(chartIndex: 0);
                          }
                         await orderController.loadOrderData(chartIndex: 0);
                        
                        },
                         style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                              // primaryColor.withOpacity(0.2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                        ),
                        child: Obx(() => Text(selectedPaymentMethod.value == 'QR Payment' ? 'Pay' : 'Submit',style: TextStyle(color: Colors.white),)),
                      ))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


