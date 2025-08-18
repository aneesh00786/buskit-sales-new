// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void pendingPaymentCollectionDialog(
    BuildContext context, String customerId) async {
  final PendingPaymentController controller =
      Get.put(PendingPaymentController());
  String selectedPaymentMethod = 'Cash';
  RxInt selectedPaymentMethodInt = 0.obs;
  bool isOnline = await ConnectivityService().isOnline();
  if (!isOnline) {
    showCustomToastDisplay(context, "You are Offline", red, Icons.warning);
  }
  controller.loadIndividualPendingPayments(customerId);
  RxList<bool> selectedItems = List<bool>.generate(
    controller.individualPendingPayments.length,
    (index) => false,
  ).obs;

  void updateSelectedItems() {
    selectedItems.value = List<bool>.generate(
      controller.individualPendingPayments.length,
      (index) => false,
    );
  }

  controller.loadIndividualPendingPayments(customerId).then((_) {
    updateSelectedItems();
  });

  double calculateTotalBalanceAmount() {
    double total = 0;
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        final pendingAmount =
            controller.individualPendingPayments[i].pendingAmount;
        // final receivable = filteredPendingAmount[i].receivableAmount;
        if (pendingAmount == null) {
          total += controller.individualPendingPayments[i].orderTotal;
        } else {
          total += pendingAmount;
        }
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

  late BuildContext loadingContext;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      loadingContext = ctx;
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
  await Future.delayed(const Duration(seconds: 2));
  Navigator.pop(loadingContext);

  void processPayments(
      List<IndividualPendingData> selectedItems, double enteredAmount) {
    log("Processing payments with amount: $enteredAmount");

    for (var item in selectedItems) {
      log("Amount before ${item.orderId}: $enteredAmount");

      double itemAmount =
          (item.receivableAmount ?? ((item.orderTotal) - (item.receivedAmount)))
              .toDouble();

      log("Processing item: ${item.orderId} with amount: $itemAmount");

      if (enteredAmount > 0) {
        double appliedAmount =
            enteredAmount >= itemAmount ? itemAmount : enteredAmount;
        enteredAmount -= appliedAmount;

        log("Applied amount to ${item.orderId}: $appliedAmount");

        ApiWorker().customerPayment(
          context: context,
          checkDueDate: "",
          checkNumber: "",
          detail: remarksController.text,
          orderId: item.orderId.toString(),
          paymentType: selectedPaymentMethod == 'Cash'
              ? "0"
              : selectedPaymentMethod == 'Cheque'
                  ? "1"
                  : "2",
          receivedAmount: appliedAmount,
          transactionDate: "",
          transactionId: "",
        );
      } else {
        log("No remaining balance to process ${item.orderId}");
      }

      log("Amount after ${item.orderId}: $enteredAmount");
      log("-----------------------------------------------------------");
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 45,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  // Color(0xff008000),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment',
                      style: TextStyle(
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
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Obx(() {
                        return DataTable(
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InvoicePreview(
                                        orderId: payment.orderId,
                                      );
                                    },
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
                        );
                      }),
                    ),
                  ),
                ],
              ),
              // Second table
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        dataRowHeight: 35,
                        headingRowHeight: 30,
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
                          DataRow(
                            cells: [
                              DataCell(
                                DropdownButtonFormField<String>(
                                  value: selectedPaymentMethod,
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
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Cash', child: Text('Cash')),
                                    DropdownMenuItem(
                                        value: 'Cheque', child: Text('Cheque')),
                                    DropdownMenuItem(
                                        value: 'Bank Transfer',
                                        child: Text('Bank Transfer')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectedPaymentMethod = value;
                                      // Map the selected value to the corresponding integer
                                      switch (value) {
                                        case 'Cash':
                                          selectedPaymentMethodInt.value = 0;
                                          break;
                                        case 'Cheque':
                                          selectedPaymentMethodInt.value = 1;
                                          break;
                                        case 'Bank Transfer':
                                          selectedPaymentMethodInt.value = 2;
                                          break;
                                      }
                                    }
                                  },
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
                              DataCell(
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      double enteredAmount = double.tryParse(
                                              receivedAmountController.text) ??
                                          0;
                                      if (enteredAmount > 0) {
                                        List<IndividualPendingData>
                                            selectedItemsList = [];
                                        for (int i = 0;
                                            i < selectedItems.length;
                                            i++) {
                                          if (selectedItems[i]) {
                                            selectedItemsList.add(controller
                                                .individualPendingPayments[i]);
                                          }
                                        }
                                        processPayments(
                                            selectedItemsList, enteredAmount);
                                        updateSelectedItems();
                                        Navigator.pop(context);
                                      } else {
                                        log("Please enter a valid amount.");
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shadowColor: Colors.transparent,
                                      backgroundColor:
                                          primaryColor.withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text('Submit',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
