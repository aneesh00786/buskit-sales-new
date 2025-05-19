// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/editable_pending_payment_cell.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
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
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _orderScrollController = ScrollController();
  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();

    _headerScrollController.addListener(() {
      if (_orderScrollController.hasClients &&
          _headerScrollController.offset != _orderScrollController.offset) {
        _orderScrollController.jumpTo(_headerScrollController.offset);
      }
    });

    _orderScrollController.addListener(() {
      if (_headerScrollController.hasClients &&
          _orderScrollController.offset != _headerScrollController.offset) {
        _headerScrollController.jumpTo(_orderScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _orderScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (subscriptionController.appPendingPaymentList.value != "true") {
        return Center(
          child: UpgradePlanButton(),
        );
      }

      if (widget.orderController.isLoadingPayment.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
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
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 53 : 58;
    double fontSize = ResponsiveInfo.isMobileDimension(context) ? 7 : 11;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      headerHeight = 55;
      fontSize = 13;
    }

    // If subscriptionController.bookingView.value == 'true'
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
            children: [
              SizedBox(
                width: 205,
                child: Column(
                  children: [
                    Expanded(
                        child: _buildHeaderText("Customer List", fontSize)),
                    const SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
              Expanded(
                child: ScrollbarTheme(
                  data: const ScrollbarThemeData(
                      radius: Radius.circular(10),
                      thumbColor: WidgetStatePropertyAll(Colors.cyanAccent)),
                  child: Scrollbar(
                    controller: _headerScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _headerScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: fullScreenWidth(context) * 0.9,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: _buildHeaderText(
                                          "Order No.", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child:
                                          _buildHeaderText("Date", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child: _buildHeaderText(
                                          "Due Date", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 2,
                                      child:
                                          _buildHeaderText("Days", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child:
                                          _buildHeaderText("Amount", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child: _buildHeaderText(
                                          "Invoice", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child:
                                          _buildHeaderText("Status", fontSize)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      flex: 3,
                                      child: _buildHeaderText("", fontSize)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(
      BuildContext context, PendingPaymentController orderController) {
    double headerHeight = ResponsiveInfo.isMobileDimension(context) ? 53 : 58;
    // if (subscriptionController.appPendingPaymentList.value != 'true') {
    //   return Center(
    //     child: UpgradePlanButton(),
    //   );
    // }
    return Align(
      alignment: FractionalOffset.topCenter,
      child: Container(
        padding: EdgeInsets.only(top: headerHeight),
        child: Row(
          children: [
            SizedBox(
              width: 210,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  itemCount: widget.orderController.orderDataList.length + 1,
                  itemBuilder: (context, index) {
                    if (index < widget.orderController.orderDataList.length) {
                      final customerData =
                          widget.orderController.orderDataList[index];
                      return _buildCustomerDetails(
                          customerData, context, index);
                    } else {
                      return Container(
                        height: 58,
                        color: Colors.grey[200],
                      );
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  trackVisibility: const WidgetStatePropertyAll(true),
                  thumbVisibility: const WidgetStatePropertyAll(true),
                  thumbColor: WidgetStateProperty.all(primaryColor),
                  trackColor: WidgetStateProperty.all(Colors.grey[300]),
                  trackBorderColor: WidgetStateProperty.all(Colors.grey[400]),
                  thickness: WidgetStateProperty.all(5),
                  radius: const Radius.circular(10),
                ),
                child: Scrollbar(
                  controller: _orderScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _orderScrollController,
                    child: SizedBox(
                      width: fullScreenWidth(context) * 0.9,
                      child: ListView.builder(
                        itemCount:
                            widget.orderController.orderDataList.length + 1,
                        itemBuilder: (context, index) {
                          if (index <
                              widget.orderController.orderDataList.length) {
                            final customerData =
                                widget.orderController.orderDataList[index];
                            return _buildOrderRow(customerData, context, index);
                          } else {
                            return _buildPageChanger(context, orderController);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
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
          Expanded(flex: 3, child: _buildOrderNumber(customerData, context)),
          const SizedBox(width: 5),
          Expanded(
              flex: 3, child: _buildOrderCreatedDate(customerData, context)),
          const SizedBox(width: 5),
          Expanded(flex: 3, child: _buildOrderDueDate(customerData, context)),
          const SizedBox(width: 5),
          Expanded(flex: 2, child: _buildOrderDays(customerData, context)),
          const SizedBox(width: 5),
          Expanded(flex: 3, child: _buildOrderPrice(customerData, context)),
          const SizedBox(width: 5),
          Expanded(flex: 3, child: _buildInvoiceNumber(customerData, context)),
          const SizedBox(width: 5),
          Expanded(flex: 3, child: _buildOrderStatus(customerData, context)),
          const SizedBox(width: 5),
          Expanded(
              flex: 3,
              child: _buildPaymentCollectionButton(customerData, context)),
        ],
      ),
    );
  }

  Widget _buildInvoiceNumber(CustomerData customerData, BuildContext context) {
    return Center(
        child: InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return InvoicePreview(
              orderId: customerData.orderId,
            );
          },
        );
      },
      child: Text(
        customerData.invoiceId,
        style: TextStyle(
          color: primaryColor,
          fontFamily: 'Poppins_Regular',
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        maxLines: 1,
      ),
    ));
  }

  Widget _buildHeaderText(String text, double fontSize) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(
      CustomerData customerData, BuildContext context, int index) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        color: index.isEven ? Colors.grey[50] : Colors.white,
        height: 80,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            ClipOval(
              child: Container(
                height: 24,
                width: 24,
                color: Colors.grey[200],
                child: Image.network(
                  '${ApiConstants.baseUrl}uploads/${customerData.imageUrl}',
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    customerData.businessName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins_Regular',
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    customerData.fullname,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins_Regular',
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    customerData.email,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins_Regular',
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNumber(CustomerData customerData, BuildContext context) {
    return Center(
        child: _buildRegularText(
      customerData.orderId,
      context,
      maxLines: 1,
    ));
  }

  Widget _buildOrderCreatedDate(
      CustomerData customerData, BuildContext context) {
    return Center(
      child: _buildRegularText(
        NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(
          customerData.orderCreatAt.toString(),
        )),
        context,
        maxLines: 1,
      ),
    );
  }

  Widget _buildOrderDueDate(CustomerData customerData, BuildContext context) {
    int? creditPeriod = customerData.creditPeriod;
    String? orderCreatAt = customerData.orderCreatAt.toString();
    String? dueDate;

    DateTime orderDate = DateTime.parse(orderCreatAt);

    DateTime dueDateTime = orderDate.add(Duration(days: creditPeriod));

    dueDate = NKDateUtils.commonDayFormat2(dueDateTime);

    return Center(
      child: _buildRegularText(
        dueDate.toString(),
        context,
        maxLines: 1,
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
      child: _buildRegularText(formatAmount(customerData.orderTotal), context,
          fontWeight: FontWeight.w600, maxLines: 1),
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
                      fontSize: 10.0,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkResponse(
        onTap: () {
          if (subscriptionController.appPaymentCollection.value == "true") {
            log('Collect Pyament ${subscriptionController.appPaymentCollection.value}');
            _pendingPaymentCollectionDialog(context, customerData.customerId);
          } else {
            showUpgradePlanDialog(context);
          }
        },
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xff5bc0de),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Text(
                'Collect Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.bold,
                ),
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
    FontWeight fontWeight = FontWeight.normal,
    TextOverflow overflow = TextOverflow.ellipsis,
    int maxLines = 1,
  }) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Poppins_Regular',
        fontSize: 10,
        fontWeight: fontWeight,
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  void _pendingPaymentCollectionDialog(
      BuildContext context, String customerId) async {
    final PendingPaymentController controller =
        Get.put(PendingPaymentController());
    String selectedPaymentMethod = 'Cash';
    RxInt selectedPaymentMethodInt = 0.obs;
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      NkCommonFunction.showErrorSnakBar(
          'No Internet Connection. Please check your network');
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
          final receivable =
              controller.individualPendingPayments[i].receivableAmount;
          if (receivable == null) {
            total += controller.individualPendingPayments[i].orderTotal;
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
                                    child: Text(
                                        formatAmount(payment.orderTotal),
                                        maxLines: 1))),
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
                                        initialValue: (payment.orderTotal -
                                                        payment
                                                            .receivedAmount ==
                                                    payment.orderTotal
                                                ? payment.orderTotal
                                                : payment.orderTotal -
                                                    payment.receivedAmount)
                                            .toString(),
                                        index: index,
                                        orderId: payment.orderId,
                                        orderTotal: payment.orderTotal,
                                        receivable: payment.receivableAmount,
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

                                        if (enteredAmount > 0) {
                                          List<IndividualPendingData>
                                              selectedItemsList =
                                              controller.getSelectedItems();
                                          controller.processPayments(
                                              selectedItemsList, enteredAmount);
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
      return '';
    }

    try {
      if (value is DateTime) {
        return DateFormat('dd-MM-yyyy').format(value);
      }
      DateTime parsedDate = DateTime.parse(value.toString());
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  Widget _buildPageChanger(
      BuildContext context, PendingPaymentController totalValuesController) {
    return Container(
      height: 58,
      color: Colors.grey[200],
      child: Padding(
        padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            right: MediaQuery.of(context).size.width * 0.26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (totalValuesController.orderDataList.length > 10)
              PaginationWidget(),
            const Spacer(),
            if (totalValuesController.selectedTabIndex.value == 0)
              Text(
                'Total:   ${formatAmount(totalValuesController.totalAmount.value)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (totalValuesController.selectedTabIndex.value == 1)
              Text(
                'Total:   ${formatAmount(totalValuesController.nearlyDueAmount.value)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (totalValuesController.selectedTabIndex.value == 2)
              Text(
                'Total:   ${formatAmount(totalValuesController.dueAmount.value)}  ',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (totalValuesController.selectedTabIndex.value == 3)
              Text(
                'Total:   ${formatAmount(totalValuesController.overdueAmount.value)}  ',
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
