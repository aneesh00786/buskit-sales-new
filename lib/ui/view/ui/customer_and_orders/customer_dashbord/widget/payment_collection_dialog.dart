// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/model/pending_payment_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/editabledatacell_new.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

void paymentCollectionDialog(
    BuildContext context, List<RecentOrder> selectedOrders) {
  List<num?> newOrderTotal =
      selectedOrders.map((order) => order.receivedAmount).toList();
  double calculateTotalBalanceAmount() {
    return newOrderTotal.fold(0, (sum, value) => sum + (value ?? 0));
  }

  double totalBalanceAmount = calculateTotalBalanceAmount();
  final balanceAmountController = TextEditingController(
    text: totalBalanceAmount.toStringAsFixed(2),
  );
  late RxString selectedPaymentMethod = 'Cash'.obs;
  // String selectedPaymentMethod = 'Cash';
  final receivedAmountController = TextEditingController();
   final remarksController = TextEditingController();

  void processPayments(
      List<IndividualPendingData> selectedItems, double enteredAmount) {
    for (var item in selectedItems) {
      double itemAmount =
          (item.receivableAmount ?? ((item.orderTotal) - (item.receivedAmount)))
              .toDouble();

      if (enteredAmount > 0) {
        double appliedAmount =
            enteredAmount >= itemAmount ? itemAmount : enteredAmount;
        enteredAmount -= appliedAmount;
        //  print('Applied amount : $appliedAmount');
        ApiWorker().customerPayment(
          checkDueDate: "",
          checkNumber: "",
          detail: remarksController.text,
          orderId: item.orderId.toString(),
          //       paymentType: selectedPaymentMethod.value == 'Cash'  // ✅ Add .value
          // ? "0"
          // : selectedPaymentMethod.value == 'Cheque'
          // ? "1"
          // : "2",
          paymentType: selectedPaymentMethod == 'Cash'
              ? "0"
              : selectedPaymentMethod == 'Cheque'
                  ? "1"
                  : "2",
          receivedAmount: appliedAmount,
          transactionDate: "",
          transactionId: "",
        );
      } else {}
    }
  }

  Future<void> _startOnlinePayment(
    double amount,
    List<IndividualPendingData> selectedItemsList, {
    required String remarks,
  }) async {
    final dashProvider = Provider.of<CustomersProvider>(
      context,
      listen: false,
    );
    if (amount <= 0 || selectedItemsList.isEmpty) {
      showCustomToastDisplay(context, "Invalid amount or no items selected",
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
      print('called createOnlinePaymentSession api');

      void _showQRPaymentModal({
        required BuildContext context,
        required OnlinePaymentSession session,
        required double totalAmount,
        required List<IndividualPendingData> selectedItemsList,
        required String remarks,
      }) {
        print('qr payement modal called');
        PendingPaymentController orderController =
            Get.put(PendingPaymentController());
        Timer? pollTimer;
        bool hasSuccess = false;
        bool isChecking = false;
        int pollCount = 0;
        print('startted poll timer variables');
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
              Get.back();
              Get.back();
              Get.back();
              // Navigator.of(context).pop(); // Close QR dialog
              // Navigator.of(context).pop(); // Close main dialog
              showCustomToastDisplay(
                  context, "Payment Successful!", Colors.green, Icons.check);
              print('customerid:${selectedOrders.first.customerId}');
              // dashProvider.fetchCustomersDataDash(selectedOrders.first.customerId);

              Provider.of<CustomersProvider>(context, listen: false)
                  .fetchCustomerDashboardData(selectedOrders.first.customerId);
              Provider.of<CustomersProvider>(context, listen: false)
                  .fetchCustomerDashboardRevenueData(
                      selectedOrders.first.customerId);
              Provider.of<CustomersProvider>(context, listen: false)
                  .fetchCustomerDashboardDataSalseData(
                      selectedOrders.first.customerId);
              Provider.of<CustomersProvider>(context, listen: false)
                  .fetchCustomersDataDash(selectedOrders.first.customerId);
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
            print("Poll error: $e");
          } finally {
            isChecking = false;
          }
        }

        print('session id before poll timer: ${session.sessionId}');

        pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          print('poll timer started');
          if (hasSuccess) {
            pollTimer?.cancel();
            return;
          }
          print('checking payment status....');

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
        print("session id => ${session.url}");
        //  Navigator.pop(context);
        // Get.back(); // Close loading
        print('calling show qr payment dialog');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WillPopScope(
            onWillPop: () async {
              pollTimer?.cancel();
              return true;
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Scan QR to Pay",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                    const Text(
                        "Scan with Phone Camera\nGoogle Pay • Apple Pay • Card",
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        pollTimer?.cancel();
                        Get.back();
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

      print('show qr payment modal finished');

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
      showCustomToastDisplay(context, "Failed to start online payment: $error",
          Colors.red, Icons.close);
    }
  }


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 1.5,
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ScrollbarTheme(
                            data: const ScrollbarThemeData(
                              minThumbLength: 150,
                              thickness: WidgetStatePropertyAll(5),
                              thumbColor: WidgetStatePropertyAll(Colors.blue),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: Container(
                                width: MediaQuery.of( context).size.width * 0.89,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5,right: 10),
                                  child: DataTable(
                                    dataRowHeight: 30,
                                    headingRowHeight: 40,
                                    columnSpacing: getResponsiveColumnSpacing(context),
                                    // columnSpacing: 30,
                                    border: TableBorder.all(
                                        color: Colors.grey.shade300),
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
                                          text: 'Receivable',
                                          fontSize: 13,
                                        ),
                                      ),
                                      DataColumn(
                                        label: DialogTableHeaderText(
                                          text: 'Payment',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    rows:
                                        selectedOrders.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      RecentOrder order = entry.value;
                                      return DataRow(cells: [
                                        DataCell(Center(
                                            child: Text(getFormattedOrderCreatAt(
                                                order.orderCreatAt)))),
                                        DataCell(Center(
                                            child: InkWell(
                                          onTap: () {
                                            showInvoicePreviewOnline(
                                              context,
                                              order.orderId,
                                            );
                                          },
                                          child: Text(
                                            order.invoiceId,
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ))),
                                        DataCell(Center(
                                            child: Text(
                                                formatAmount(order.orderTotal)))),
                                        DataCell(Center(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              //Color(0xff008000),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                              ),
                                              child: Text(
                                                getStatusName(order.orderStatus),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                        DataCell(
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3.0),
                                            child: EditableDataCell(
                                              initialValue:
                                                  order.receivedAmount.toString(),
                                              index: index, // Pass index
                                              orderId: order.orderId,
                                              orderTotal: order.orderTotal,
                                              onValueChanged: (newValue, index) {
                                                // setState(() {
                                                newOrderTotal[index] =
                                                    int.tryParse(newValue);
                                                totalBalanceAmount =
                                                    calculateTotalBalanceAmount();
                                                balanceAmountController.text =
                                                    totalBalanceAmount
                                                        .toStringAsFixed(2);
                                                //  });
                                              },
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: order.paymentStatus == 0
                                                    ? Colors.red
                                                    : Colors.green,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: order.paymentStatus == 0
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(1.0),
                                                child: Icon(
                                                  order.paymentStatus == 0
                                                      ? Icons.close
                                                      : Icons.done,
                                                  color: Colors.white,
                                                  size: 14.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                            DataColumn(label: IntrinsicWidth(child: Text(''))),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: DropdownButtonFormField<String>(
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
                                        value: selectedPaymentMethod.value,
                                        items: [
                                          'Cash',
                                          'Cheque',
                                          'Bank Transfer',
                                          'QR Payment', // Added
                                        ]
                                            .map((e) => DropdownMenuItem(
                                                value: e, child: Text(e)))
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null)
                                            selectedPaymentMethod.value = val;
                                        },
                                      )
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
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
                                        hintText: 'Balance Amount',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: TextField(
                                      controller: receivedAmountController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        hintText: 'Received Amount',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: TextField(
                                      controller: remarksController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        hintText: 'Remarks',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Center(
                                    child: ElevatedButton(
                                  onPressed: () async {
                                    double enteredAmount = double.tryParse(
                                            receivedAmountController.text) ??
                                        0;

                                    if (enteredAmount <= 0) {
                                      showCustomToastDisplay(
                                          context,
                                          "Enter valid amount",
                                          Colors.red,
                                          Icons.error);
                                      return;
                                    }

                                    // CRITICAL FIX: Use selectedOrders directly instead of relying on selectedItems
                                    // Convert RecentOrder → IndividualPendingData (or mimic the structure needed)
                                    List<IndividualPendingData>
                                        selectedItemsList =
                                        selectedOrders.map((order) {
                                      return IndividualPendingData(
                                        orderId: order.orderId,
                                        orderTotal:
                                            order.orderTotal?.toDouble() ?? 0.0,
                                        receivedAmount:
                                            0.0, // assuming full pending for simplicity
                                        receivableAmount:
                                            order.orderTotal?.toInt() ?? 0,
                                        pendingAmount:
                                            order.orderTotal?.toInt() ?? 0,
                                        paymentType: order.paymentType,
                                        creditPeriod: order.creditPeriod ?? 0,
                                        orderCreatAt: DateTime.now(),
                                        orderStatus: order.orderStatus ?? 0,
                                        paymentStatus: order.paymentStatus ?? 0,
                                        customerId:
                                            order.customerId ?? 0.toString(),
                                        invoiceId: order.invoiceId ?? "",
                                        receivedAmountDate: null,
                                        amountEdited: 0,
                                        // Add other required fields if needed
                                      );
                                    }).toList();

                                    if (selectedItemsList.isEmpty) {
                                      showCustomToastDisplay(
                                          context,
                                          "No orders to process",
                                          Colors.red,
                                          Icons.error);
                                      return;
                                    }

                                    // Now proceed with payment
                                    if (selectedPaymentMethod.value ==
                                        'QR Payment') {
                                      print('online payment selected');
                                      await _startOnlinePayment(
                                        enteredAmount,
                                        selectedItemsList,
                                        remarks: remarksController.text,
                                      );
                                    } else {
                                      // Process Cash/Cheque/Bank Transfer
                                      processPayments(
                                          selectedItemsList, enteredAmount);
                                      print(
                                          'enetered amounttt first: $enteredAmount');
                                      print(
                                          'payment method: ${selectedPaymentMethod.value}');
                                      Navigator.pop(context);
                                      showCustomToastDisplay(
                                          context,
                                          "Payment submitted",
                                          Colors.green,
                                          Icons.check);
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
                                        style: TextStyle(color: Colors.white),
                                      )),
                                )
                                )
                                ),
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
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        height: 35,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        child: DropdownButtonFormField<String>(
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
                                            value: selectedPaymentMethod.value,
                                            items: [
                                              'Cash',
                                              'Cheque',
                                              'Bank Transfer',
                                              'QR Payment', // Added
                                            ]
                                                .map((e) => DropdownMenuItem(
                                                    value: e, child: Text(e)))
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null)
                                                selectedPaymentMethod.value =
                                                    val;
                                            },
                                          )
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
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
                                            hintText: 'Balance Amount',
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 10.0),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
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
                                DataColumn(
                                    label: IntrinsicWidth(child: Text(''))),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            hintText: 'Received Amount',
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 10.0),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            hintText: 'Remarks',
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 10.0),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Center(
                                        child: ElevatedButton(
                                      onPressed: () async {
                                        double enteredAmount = double.tryParse(
                                                receivedAmountController
                                                    .text) ??
                                            0;

                                        if (enteredAmount <= 0) {
                                          showCustomToastDisplay(
                                              context,
                                              "Enter valid amount",
                                              Colors.red,
                                              Icons.error);
                                          return;
                                        }

                                        // CRITICAL FIX: Use selectedOrders directly instead of relying on selectedItems
                                        // Convert RecentOrder → IndividualPendingData (or mimic the structure needed)
                                        List<IndividualPendingData>
                                            selectedItemsList =
                                            selectedOrders.map((order) {
                                          return IndividualPendingData(
                                            orderId: order.orderId,
                                            orderTotal:
                                                order.orderTotal?.toDouble() ??
                                                    0.0,
                                            receivedAmount:
                                                0.0, // assuming full pending for simplicity
                                            receivableAmount:
                                                order.orderTotal?.toInt() ?? 0,
                                            pendingAmount:
                                                order.orderTotal?.toInt() ?? 0,
                                            paymentType: order.paymentType,
                                            creditPeriod:
                                                order.creditPeriod ?? 0,
                                            orderCreatAt: DateTime.now(),
                                            orderStatus: order.orderStatus ?? 0,
                                            paymentStatus:
                                                order.paymentStatus ?? 0,
                                            customerId: order.customerId ??
                                                0.toString(),
                                            invoiceId: order.invoiceId ?? "",
                                            receivedAmountDate: null,
                                            amountEdited: 0,
                                            // Add other required fields if needed
                                          );
                                        }).toList();

                                        if (selectedItemsList.isEmpty) {
                                          showCustomToastDisplay(
                                              context,
                                              "No orders to process",
                                              Colors.red,
                                              Icons.error);
                                          return;
                                        }

                                        // Now proceed with payment
                                        if (selectedPaymentMethod.value ==
                                            'QR Payment') {
                                          print('online payment selected');
                                          await _startOnlinePayment(
                                            enteredAmount,
                                            selectedItemsList,
                                            remarks: remarksController.text,
                                          );
                                        } else {
                                          // Process Cash/Cheque/Bank Transfer
                                          processPayments(
                                              selectedItemsList, enteredAmount);
                                          print(
                                              'enetered amounttt first: $enteredAmount');
                                          print(
                                              'payment method: ${selectedPaymentMethod.value}');
                                          Navigator.pop(context);
                                          showCustomToastDisplay(
                                              context,
                                              "Payment submitted",
                                              Colors.green,
                                              Icons.check);
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    )
                                    )
                                    )
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
        ),
      );
    },
  );
}
