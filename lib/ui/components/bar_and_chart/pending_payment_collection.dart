// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

void pendingPaymentCollectionDialog(
    BuildContext context, String title, Collection collection) {
  final ScrollController scrollController = ScrollController();

  if (collection.order == null || collection.order!.pendingAmount == null) {
    return;
  }
  String selectedPaymentMethod = 'Cash';
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

  final balanceAmountController = TextEditingController(
    text: totalBalanceAmount.value.toStringAsFixed(2),
  );

  final receivedAmountController = TextEditingController();
  final remarksController = TextEditingController();

  void processPayments(
      List<PendingAmount> selectedItems, double enteredAmount) {
    for (var item in selectedItems) {
      double itemAmount = (item.receivableAmount ??
              ((item.orderTotal ?? 0) - (item.receivedAmount ?? 0)))
          .toDouble();

      if (enteredAmount > 0) {
        double appliedAmount =
            enteredAmount >= itemAmount ? itemAmount : enteredAmount;
        enteredAmount -= appliedAmount;
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
      } else {}
    }
  }

  Widget customPaymentDataTable() {
    return DataTable(
      columnSpacing: 30,
      horizontalMargin: 15,
      dataRowHeight: 30,
      headingRowHeight: 40,
      border: TableBorder.all(color: Colors.grey.shade300),
      columns: const [
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Customer',
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Date',
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Order No.',
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
            text: 'Invoice',
            fontSize: 13,
          ),
        ),
        DataColumn(
          label: DialogTableHeaderText(
            text: 'Due Date',
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
      rows: [
        ...filteredPendingAmount.asMap().entries.map<DataRow>(
          (entry) {
            int index = entry.key;
            var payment = entry.value;
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
                              getStatusName(payment.orderStatus?.toInt() ?? 0),
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
                        ? payment.dueDate!.first.toString().replaceAll('/', '-')
                        : 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: payment.dueDate != null &&
                              payment.dueDate!.isNotEmpty
                          ? getDueDateColor(payment.dueDate!.first)
                          : Colors
                              .grey, // Set color to grey for null or empty dueDate
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Container(
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
        DataRow(cells: [
          const DataCell(
            Center(
              child: Text(
                'Total',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins_Regular'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const DataCell(Text('')),
          const DataCell(Text('')),
          DataCell(
            Center(
              child: Text(
                formatAmount(
                  filteredPendingAmount
                      .map((e) => e.orderTotal ?? 0.0)
                      .fold(0.0, (a, b) => a + b),
                ),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins_Regular'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          const DataCell(Text('')),
          DataCell(
            Center(
              child: Text(
                formatAmount(
                  filteredPendingAmount
                      .map((e) => e.pendingAmount ?? 0.0)
                      .fold(0.0, (a, b) => a + b),
                ),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins_Regular'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const DataCell(Text('')),
        ]),
      ],
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                    title,
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
                        child: customPaymentDataTable(),
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
                                        List<PendingAmount> selectedItemsList =
                                            [];
                                        for (int i = 0;
                                            i < selectedItems.length;
                                            i++) {
                                          if (selectedItems[i]) {
                                            selectedItemsList.add(collection
                                                .order!.pendingAmount![i]);
                                          }
                                        }

                                        processPayments(
                                            selectedItemsList, enteredAmount);

                                        updateSelectedItems();
                                      } else {}
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
                                    DropdownButtonFormField<String>(
                                      value: selectedPaymentMethod,
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
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Cash', child: Text('Cash')),
                                        DropdownMenuItem(
                                            value: 'Cheque',
                                            child: Text('Cheque')),
                                        DropdownMenuItem(
                                            value: 'Bank Transfer',
                                            child: Text('Bank Transfer')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          selectedPaymentMethod = value;
                                          switch (value) {
                                            case 'Cash':
                                              selectedPaymentMethodInt.value =
                                                  0;
                                              break;
                                            case 'Cheque':
                                              selectedPaymentMethodInt.value =
                                                  1;
                                              break;
                                            case 'Bank Transfer':
                                              selectedPaymentMethodInt.value =
                                                  2;
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
                                              hintText: 'Enter Amount',
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
                                        hintText: 'Remarks',
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
                                        onPressed: () {
                                          double enteredAmount =
                                              double.tryParse(
                                                      receivedAmountController
                                                          .text) ??
                                                  0;
                                          if (enteredAmount > 0) {
                                            List<PendingAmount>
                                                selectedItemsList = [];
                                            for (int i = 0;
                                                i < selectedItems.length;
                                                i++) {
                                              if (selectedItems[i]) {
                                                selectedItemsList.add(collection
                                                    .order!.pendingAmount![i]);
                                              }
                                            }

                                            processPayments(selectedItemsList,
                                                enteredAmount);

                                            updateSelectedItems();
                                          } else {
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
