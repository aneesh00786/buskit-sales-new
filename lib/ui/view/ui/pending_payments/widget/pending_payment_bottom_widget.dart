import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_collect_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_pagination.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/order_details_diloag/order_details_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:intl/intl.dart';

class PendingPaymentBottomWidget extends StatefulWidget {
  final PendingPaymentController orderController;
  final int selectedTabIndex;

  const PendingPaymentBottomWidget({
    super.key,
    required this.orderController,
    required this.selectedTabIndex,
  });

  @override
  State<PendingPaymentBottomWidget> createState() =>
      _PendingPaymentBottomWidgetState();
}

class _PendingPaymentBottomWidgetState
    extends State<PendingPaymentBottomWidget> {
  @override
  void didUpdateWidget(covariant PendingPaymentBottomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTabIndex != widget.selectedTabIndex) {
      print(
          "Tab changed: Reloading data for tab index ${widget.selectedTabIndex}");
      widget.orderController.loadOrderData(chartIndex: widget.selectedTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.orderController.orderDataList.isEmpty) {
        return const Center(child: NodataWidget());
      }

      return NkWidgetExceptionHandel(
        onRetryPressed: () => {},
        data: widget.orderController.orderDataList,
        child: Stack(
          children: [
            _buildHeader(context),
            _buildOrderList(context, widget.orderController),
            // _buildPageChanger(context),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 45 : 50;
    double fontSize = ResponsiveInfo.isMobileDimension(context) ? 7 : 11;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      headerHeight = ResponsiveInfo.isMobileDimension(context) ? 50 : 55;
      fontSize = ResponsiveInfo.isMobileDimension(context) ? 11 : 13;
    }

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        color: primaryColor,
        child: Padding(
          padding:
              EdgeInsets.all(ResponsiveInfo.isMobileDimension(context) ? 2 : 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 4, child: _buildHeaderText("Customer List", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildHeaderText("Order No.", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildHeaderText("Date", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildHeaderText("Due Date", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: _buildHeaderText("Days", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildHeaderText("Price", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: _buildHeaderText("Status", fontSize)),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: _buildHeaderText("", fontSize)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text, double fontSize) {
    return Center(
      child: CustomText(
        content: text,
        textAlign: TextAlign.center,
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderList(
      BuildContext context, PendingPaymentController orderController) {
    double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 45 : 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Container(
        padding: EdgeInsets.only(
          top: headerHeight,
        ),
        child: ListView.builder(
          itemCount: widget.orderController.orderDataList.length + 1,
          itemBuilder: (context, index) {
            if (index < widget.orderController.orderDataList.length) {
              final customerData = widget.orderController.orderDataList[index];
              return _buildOrderRow(customerData, context, index);
            } else {
              return _buildPageChanger(context, orderController);
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrderRow(
      CustomerData customerData, BuildContext context, int index) {
    double rowHeight = 80;

    return Container(
      color: index.isEven ? Colors.grey[50] : Colors.white,
      height: rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 4, child: _buildCustomerDetails(customerData, context)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: _buildOrderNumber(customerData, context)),
          const SizedBox(width: 10),
          Expanded(
              flex: 2, child: _buildOrderCreatedDate(customerData, context)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: _buildOrderDueDate(customerData, context)),
          const SizedBox(width: 10),
          Expanded(flex: 1, child: _buildOrderDays(customerData, context)),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: _buildOrderPrice(customerData, context)),
          const SizedBox(width: 10),
          Expanded(flex: 3, child: _buildOrderStatus(customerData, context)),
          const SizedBox(width: 10),
          Expanded(
              flex: 3,
              child: _buildPaymentCollectionButton(customerData, context)),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(
      CustomerData customerData, BuildContext context) {
    double fontSize = ResponsiveInfo.isMobileDimension(context) ? 5 : 8;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      fontSize = ResponsiveInfo.isMobileDimension(context) ? 8 : 10;
    }

    return GestureDetector(
      onTap: () => {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          ClipOval(
            child: Container(
              height: 40,
              width: 40,
              color: Colors.grey[200],
              child: Image.network(
                'http://16.50.232.153:3000/uploads/${customerData.imageUrl}',
                fit: BoxFit.cover,
                width: 25,
                height: 25,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.person, color: Colors.blue, size: 25),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                content:  customerData.businessName ?? '',
                  
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                 content:  customerData.fullname ?? '',
                  fontSize: 11, color: Colors.black,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Text(
                //   customerData. ?? '',
                //   style: const TextStyle(fontSize: 11, color: Colors.black),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
                CustomText(
                content:   customerData.email ?? '',
                 fontSize: 10, color: Colors.black,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNumber(CustomerData customerData, BuildContext context) {
    return Center(
        child: _buildRegularText(customerData.orderId ?? '', context));
  }

  Widget _buildOrderCreatedDate(
      CustomerData customerData, BuildContext context) {
    return Center(
      child: _buildRegularText(
        NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(
          customerData.orderCreatAt.toString(),
        )),
        context,
      ),
    );
  }

  Widget _buildOrderDueDate(CustomerData customerData, BuildContext context) {
    int? creditPeriod = customerData.creditPeriod;
    String? orderCreatAt = customerData.orderCreatAt.toString();
    //calculate due date
    String? dueDate;

    if (creditPeriod != null && orderCreatAt != null) {
      // Parse the order created date
      DateTime orderDate = DateTime.parse(orderCreatAt);

      // Add the credit period (days) to the order date
      DateTime dueDateTime = orderDate.add(Duration(days: creditPeriod));

      // Format the due date into the desired string format (e.g., 'dd-MM-yyyy')
      dueDate = NKDateUtils.commonDayFormat2(dueDateTime);
    }

    return Center(
      child: _buildRegularText(
        // NKDateUtils.commonDayFormat(NKDateUtils.formatStringUTCDateTime(
        //   orderCreatAt,
        // )),
        dueDate.toString(),
        context,
      ),
    );
  }

  Widget _buildOrderDays(CustomerData customerData, BuildContext context) {
    DateTime orderCreatedDate = NKDateUtils.formatStringUTCDateTime(
      customerData.orderCreatAt.toString(),
    );
    DateTime currentDate = DateTime.now();
    int daysDifference = currentDate.difference(orderCreatedDate).inDays;
    return Center(
      child: _buildRegularText('$daysDifference', context),
    );
  }

  Widget _buildOrderPrice(CustomerData customerData, BuildContext context) {
    return Center(
      child: _buildRegularText(
        formatAmount(customerData.orderTotal),
        context,
        fontWeight: FontWeight.w600,
      ),
    );
  }

 Widget _buildOrderStatus(CustomerData customerData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xffffdbb8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  content: OrderHandlingClass.fromType(customerData.orderStatus)
                      .name,
                  textAlign: TextAlign.center,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                if (customerData.orderStatus == 2 &&
                    customerData.deliveryDate != null) ...[
                  Text(
                    NKDateUtils.commonFullDateTimeFormat(
                        NKDateUtils.formatStringUTCDateTime(
                            customerData.deliveryDate!.toIso8601String())),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCollectionButton(
      CustomerData customerData, BuildContext context) {
    double fontSize = ResponsiveInfo.isMobileDimension(context) ? 8 : 10;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkResponse(
        onTap: () {
          _pendingPaymentCollectionDialog(context, customerData.customerId);
        },
        child: Container(
          height: fontSize * 4,
          decoration: BoxDecoration(
            color: const Color(0xff5bc0de),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              'Collect Payment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
                fontFamily: 'Poppins_Regular',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegularText(
    String label,
    BuildContext context, {
    FontWeight fontWeight = FontWeight.w700,
    TextOverflow overflow = TextOverflow.ellipsis,
    int maxLines = 1,
  }) {
    double fontSize = ResponsiveInfo.isMobileDimension(context) ? 8 :12;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      fontSize = ResponsiveInfo.isMobileDimension(context) ? 10 : 12;
    }

    return MyRegularText(
      overflow: overflow,
      label: label,
      fontSize: fontSize,
      fontWeight: fontWeight,
      maxlines: maxLines,
    );
  }

  void _pendingPaymentCollectionDialog(
      BuildContext context, String customerId) {
    final PendingPaymentController controller = Get.find();

    String selectedPaymentMethod = 'Cash';
    RxInt selectedPaymentMethodInt = 0.obs;

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
          final receivable =
              controller.individualPendingPayments[i].receivableAmount;
          if (receivable == null) {
            total += controller.individualPendingPayments[i].orderTotal ?? 0;
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
                // Header of the dialog
                Container(
                  height: 45,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xff008000),
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
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: SizedBox(
                          width: 25.8,
                          height: 25.8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.5),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // First table
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(() {
                          return DataTable(
                            dataRowHeight: 30,
                            headingRowHeight: 40,
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
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
                                DataCell(Center(child: Text(payment.orderId))),
                                DataCell(Center(
                                    child: Text(
                                        formatAmount(payment.orderTotal),
                                        maxLines: 1))),
                                DataCell(Center(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xff008000),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
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
                                            payment.orderTotal.toString(),
                                        index: index,
                                        orderId: payment.orderId,
                                        orderTotal: payment.orderTotal,
                                        receivable: payment.receivableAmount,
                                        onValueChanged: (newValue, index) {
                                          // Handle editable cells if necessary
                                        },
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
                                          child: Text('Cash'), value: 'Cash'),
                                      DropdownMenuItem(
                                          child: Text('Cheque'),
                                          value: 'Cheque'),
                                      DropdownMenuItem(
                                          child: Text('Bank Transfer'),
                                          value: 'Bank Transfer'),
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
                                      SizedBox(width: 5),
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
                                      SizedBox(width: 5),
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
                                        int enteredAmount = int.tryParse(
                                                receivedAmountController
                                                    .text) ??
                                            0;
                                        print("Entered Amount: $enteredAmount");

                                        if (enteredAmount > 0) {
                                          // Get the list of selected items from the selection logic
                                          List<IndividualPendingData>
                                              selectedItemsList =
                                              controller.getSelectedItems();
                                          print(
                                              "Selected Items List: $selectedItemsList");

                                          // Call the processPayments function
                                          controller.processPayments(
                                              selectedItemsList, enteredAmount);
                                        } else {
                                          print("Please enter a valid amount.");
                                        }
                                      },
                                      child: const Text('Submit',
                                          style: TextStyle(fontSize: 14)),
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor:
                                            primaryColor.withOpacity(0.2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
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



  String getFormattedOrderCreatAt(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      print('Error: Invalid date value');
      return ''; // Return an empty string for null or empty values
    }

    try {
      // Check if the value is already in DateTime format
      if (value is DateTime) {
        return DateFormat('dd-MM-yyyy').format(value);
      }

      // Attempt to parse the string as a DateTime object
      DateTime parsedDate = DateTime.parse(value.toString());

      // Return the formatted date
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      print('Error parsing date: $e');
      return ''; // Return an empty string if parsing fails
    }
  }

  Widget _buildPageChanger(
      BuildContext context, PendingPaymentController totalValuesController) {
    // double fontSize = ResponsiveInfo.isMobileDimension(context) ? 6 : 9;
    // if (MediaQuery.of(context).orientation != Orientation.portrait) {
    //   fontSize = ResponsiveInfo.isMobileDimension(context) ? 10 : 12;
    // }
    return Container(
      height: 58,
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (totalValuesController.orderDataList.length > 10)
              PaginationWidget(),
            const Spacer(),
            if (totalValuesController.selectedTabIndex == 0)
              Text(
                'Total:   ${formatAmount(totalValuesController.totalAmount)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (totalValuesController.selectedTabIndex == 1)
              Text(
                'Total:   ${formatAmount(totalValuesController.nearlyDueAmount)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (totalValuesController.selectedTabIndex == 2)
              Text(
                'Total:   ${formatAmount(totalValuesController.dueAmount)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (totalValuesController.selectedTabIndex == 3)
              Text(
                'Total:   ${formatAmount(totalValuesController.overdueAmount)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
          ],
        ),
      ),
    );
  }
}
