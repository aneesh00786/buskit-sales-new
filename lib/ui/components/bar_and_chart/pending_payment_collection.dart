import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/model/pending_payment_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
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
          String uniqueId;

          if (payload['unique_id'] != null) {
            uniqueId = payload['unique_id'].toString();
          } else {
            String timestamp =
                element['timestamp'] ?? DateTime.now().toIso8601String();
            String salesId = payload['sales_id'] ?? 'unknown';
            uniqueId = "${timestamp}_$salesId";
          }

          payments
              .add({'hive_key': key, 'unique_id': uniqueId, 'data': element});
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              title: Row(
                children: [
                  Icon(Icons.cloud_off_rounded,
                      color: Colors.deepOrange, size: 28),
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
                width: double.maxFinite,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: DataTable(
                    headingRowHeight: 48,
                    dataRowHeight: 56,
                    horizontalMargin: 16,
                    columnSpacing: 24,
                    headingRowColor:
                        MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Color(0xFFE2E8F0)),
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    columns: [
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
                      final timestamp =
                          DateTime.parse(data['timestamp'] as String);

                      final formattedTime =
                          TimeUtils.formatTimeInZone(timestamp);

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
                                color: const Color(0xFF0F172A),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
  List<double> currentBalances = filteredPendingAmount.map((item) {
    return (item.receivableAmount ?? ((item.orderTotal ?? 0) - (item.receivedAmount ?? 0))).toDouble();
  }).toList();
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
        total += currentBalances[i]; // Uses the editable list!
      }
    }
    return total;
  }

  // double calculateTotalBalanceAmount() {
  //   double total = 0;
  //   for (int i = 0; i < selectedItems.length; i++) {
  //     if (selectedItems[i]) {
  //       final receivable = filteredPendingAmount[i].pendingAmount;
  //       if (receivable == null) {
  //         total += ((filteredPendingAmount[i].orderTotal ?? 0) -
  //                 (filteredPendingAmount[i].pendingAmount ?? 0))
  //             .toDouble();
  //       } else {
  //         total += receivable;
  //       }
  //     }
  //   }
  //   return total;
  // }

  RxDouble totalBalanceAmount = RxDouble(calculateTotalBalanceAmount());
  RxInt offlineStatusRefresh = 0.obs;

  final balanceAmountController = TextEditingController(
    text: totalBalanceAmount.value.toStringAsFixed(2),
  );
  final receivedAmountController = TextEditingController(
    text: totalBalanceAmount.value.toStringAsFixed(2),
  );

  // final receivedAmountController = TextEditingController();
  final remarksController = TextEditingController();
  Future<void> processPayments(
    List<PendingAmount> selectedItems,
    double enteredAmount,
  ) async {
    for (var item in selectedItems) {
      double itemAmount = (item.receivableAmount ??
              ((item.orderTotal ?? 0) - (item.receivedAmount ?? 0)))
          .toDouble();

      if (enteredAmount > 0.01) {
        double appliedAmount = 0.0;
        if (enteredAmount >= itemAmount) {
          appliedAmount = itemAmount;
        } else {
          appliedAmount = enteredAmount;
        }

        enteredAmount -= appliedAmount;

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

          await Future.delayed(const Duration(milliseconds: 1100));
        }
      }
    }
  }

  Widget customPaymentDataTable() {
    return DataTable(
      columnSpacing: 30,
      horizontalMargin: 15,
      dataRowHeight: 30,
      headingRowHeight: 40,
      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
      headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
      columns: [
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
            bool isOfflinePending =
                isOfflinePaymentPending(payment.orderId.toString());
            return DataRow(cells: [
              DataCell(Center(child: Text(payment.businessName.toString()))),
              DataCell(Center(
                  child: Text(getFormattedOrderCreatAt(payment.orderCreatAt)))),
              DataCell(Center(child: Text(payment.orderId.toString()))),
              DataCell(Center(child: Text(formatAmount(payment.orderTotal)))),
              DataCell(Center(
                  child: Builder(builder: (context) {
                final orderStatus = OrderHandlingClass.fromType(
                    payment.orderStatus?.toInt() ?? 0);
                return Container(
                    decoration: BoxDecoration(
                      color: orderStatus.statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              orderStatus.statusDotColor.withOpacity(0.35)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Text(
                            getStatusName(payment.orderStatus?.toInt() ?? 0)
                                .tr,
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: orderStatus.statusTextColor,
                            ))));
              }))),
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
                            DateFormat('dd-MM-yyyy').parse(payment
                                .dueDate!.first
                                .toString()
                                .replaceAll('/', '-')),
                            format: 'dd-MM-yyyy',
                          )
                        : 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          payment.dueDate != null && payment.dueDate!.isNotEmpty
                              ? getDueDateColor(payment.dueDate!.first)
                              : Colors.grey,
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: isOfflinePending
                      ? InkWell(
                          onTap: () {
                            showOfflineInfoDialog(
                                context, payment.orderId.toString());
                          },
                          child: const Icon(
                            Icons.info,
                            color: primaryColor,
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
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: EditablePendingPaymentCell(
                      initialValue:currentBalances[index].toStringAsFixed(2),
                      //  (payment.orderTotal! -
                      //                 payment.receivedAmount! ==
                      //             payment.orderTotal
                      //         ? payment.orderTotal
                      //         : payment.orderTotal! - payment.receivedAmount!)
                      //     .toString(),
                      index: index,
                      orderId: payment.orderId.toString(),
                      orderTotal: payment.orderTotal?.toInt() ?? 0,
                      // receivable: payment.pendingAmount,
                      onValueChanged: (newValue, idx) {
                        currentBalances[idx] = double.tryParse(newValue) ?? 0.0;
                        totalBalanceAmount.value = calculateTotalBalanceAmount();
                        
                        // Auto-update the text boxes at the bottom!
                        balanceAmountController.text = totalBalanceAmount.value.toStringAsFixed(2);
                        receivedAmountController.text = totalBalanceAmount.value.toStringAsFixed(2);
                      },
                      // (newValue, index) {},
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
                          receivedAmountController.text = 
                          totalBalanceAmount.value.toStringAsFixed(2);
                    },
                  );
                })),
              ),
            ]);
          },
        ),
      ],
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // PendingPaymentController orderController =
      // Get.put(PendingPaymentController());
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isPhonePortrait(context) ? fullScreenWidth(context) : 950,
            maxHeight: fullScreenHeight(context) * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Color(0xFF2D3748)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 17),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Poppins_Regular',
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.dragged)) {
                        return const Color(0xFF2D3748);
                      }
                      return primaryColor;
                    }),
                    trackColor:
                        WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    trackBorderColor:
                        WidgetStateProperty.all(const Color(0xFFE2E8F0)),
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
                        columns: [
                           DataColumn(
                             label: SizedBox(
                               width: 150,
                               child: DialogTableHeaderText(
                                 text: 'Payment Method'.tr,
                                 fontSize: 11,
                                 align: TextAlign.start,
                               ),
                             ),
                           ),
                           DataColumn(
                             label: SizedBox(
                               width: 130,
                               child: DialogTableHeaderText(
                                 text: 'Balance Amount'.tr,
                                 fontSize: 11,
                                 align: TextAlign.start,
                               ),
                             ),
                           ),
                           DataColumn(
                             label: SizedBox(
                               width: 130,
                               child: DialogTableHeaderText(
                                 text: 'Received Amount'.tr,
                                 fontSize: 11,
                                 align: TextAlign.start,
                               ),
                             ),
                           ),
                           DataColumn(
                             label: SizedBox(
                               width: 150,
                               child: DialogTableHeaderText(
                                 text: 'Remarks'.tr,
                                 fontSize: 11,
                                 align: TextAlign.start,
                               ),
                             ),
                           ),
                           const DataColumn(label: Text('')),
                         ],
                        rows: [
                          DataRow(
                            cells: [
                               DataCell(
                                 SizedBox(
                                   width: 150,
                                   child: DropdownButtonFormField<String>(
                                     isExpanded: true,
                                     value: selectedPaymentMethod.value,
                                     decoration: InputDecoration(
                                       filled: true,
                                       fillColor: Colors.white,
                                       border: OutlineInputBorder(
                                         borderSide: BorderSide(
                                             color: Color(0xFFE2E8F0)),
                                         borderRadius: BorderRadius.circular(10.0),
                                       ),
                                       contentPadding: const EdgeInsets.symmetric(
                                           horizontal: 8.0, vertical: 4.0),
                                     ),
                                     dropdownColor: Colors.white,
                                     items: [
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
                                         selectedPaymentMethod.value = value;

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
                                     hint: Text('Select'.tr),
                                     style: const TextStyle(
                                         fontSize: 12, color: Colors.black),
                                     icon: const Icon(Icons.arrow_drop_down,
                                         size: 24.0, color: Colors.black),
                                     iconSize: 24.0,
                                   ),
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
                                                color: Color(0xFFE2E8F0)),
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
                                                color: Color(0xFFE2E8F0)),
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
                                          color: Color(0xFFE2E8F0)),
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
                                      final double enteredAmount =
                                          double.tryParse(
                                                  receivedAmountController
                                                      .text) ??
                                              0;
                                      if (enteredAmount <= 0) {
                                        showCustomToastDisplay(
                                            context,
                                            "Please enter a valid amount".tr,
                                            Colors.red,
                                            Icons.error);
                                        return;
                                      }

                                      // 2. Build Selected List
                                      List<PendingAmount> selectedItemsList =
                                          [];
                                      for (int i = 0;
                                          i < selectedItems.length;
                                          i++) {
                                        if (selectedItems[i]) {
                                          if (title == 'Due Payment') {
                                            selectedItemsList.add(
                                                collection.due!.dueAmount![i]);
                                          } else if (title ==
                                              'Over Due Payment') {
                                            selectedItemsList.add(collection
                                                .overdue!.overdueAmount![i]);
                                          } else {
                                            selectedItemsList.add(collection
                                                .order!.pendingAmount![i]);
                                          }
                                        }
                                      }

                                      if (selectedItemsList.isEmpty) {
                                        showCustomToastDisplay(
                                            context,
                                            "Please select at least one item"
                                                .tr,
                                            Colors.red,
                                            Icons.error);
                                        return;
                                      }

                                      bool isOnline =
                                          await ConnectivityService()
                                              .isOnline();

                                      if (!isOnline &&
                                          selectedPaymentMethod.value ==
                                              'QR Payment') {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text("Online Required".tr),
                                            content: Text(
                                                "QR Payments can only be processed while online. Please select Cash, Cheque, or Bank Transfer for offline collection."
                                                    .tr),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                  child: Text("OK".tr))
                                            ],
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedPaymentMethod.value ==
                                          'QR Payment') {
                                        await _startOnlinePayment(
                                          context,
                                          enteredAmount,
                                          selectedItemsList,
                                          remarks: remarksController.text,
                                        );
                                      } else {
                                        await processPayments(
                                            selectedItemsList, enteredAmount);

                                        if (!isOnline) {
                                          offlineStatusRefresh.value++;
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (ctx) => AlertDialog(
                                              title: const Row(children: [
                                                Icon(Icons.wifi_off,
                                                    color: Colors.orange),
                                                SizedBox(width: 10),
                                                Text("Payment Queued")
                                              ]),
                                              content: Text(
                                                  "You are offline. The payment has been saved locally and will complete automatically when you go online."
                                                      .tr),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                      Get.back();

                                                      final dashboardProvider =
                                                          Provider.of<
                                                                  DashboardProvider>(
                                                              context,
                                                              listen: false);
                                                      dashboardProvider
                                                          .fetchData();
                                                    },
                                                    child: const Text("OK"))
                                              ],
                                            ),
                                          );
                                        } else {
                                          updateSelectedItems();
                                          final dashboardProvider =
                                              Provider.of<DashboardProvider>(
                                                  context,
                                                  listen: false);
                                          await dashboardProvider
                                              .setTempToFilter();
                                          await dashboardProvider
                                              .fetchAllOrdersAtOnce();
                                          dashboardProvider.fetchData();
                                          Get.back();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryButtonColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    ),
                                    child: Obx(
                                      () => Text(
                                        selectedPaymentMethod.value ==
                                                'QR Payment'
                                            ? 'Pay'.tr
                                            : 'Submit'.tr,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //
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
                            columns: [
                              DataColumn(
                                label: SizedBox(
                                  width: 150,
                                  child: DialogTableHeaderText(
                                    text: 'Payment Method'.tr,
                                    fontSize: 11,
                                    align: TextAlign.start,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 130,
                                  child: DialogTableHeaderText(
                                    text: 'Balance Amount'.tr,
                                    fontSize: 11,
                                    align: TextAlign.start,
                                  ),
                                ),
                              ),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        value: selectedPaymentMethod.value,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color(0xFFE2E8F0)),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0, vertical: 4.0),
                                        ),
                                        dropdownColor: Colors.white,
                                        items: [
                                          DropdownMenuItem(
                                              value: 'Cash',
                                              child: Text('Cash'.tr)),
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
                                        hint: Text('Select'.tr),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                        icon: const Icon(Icons.arrow_drop_down,
                                            size: 24.0, color: Colors.black),
                                        iconSize: 24.0,
                                      ),
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
                                                        Color(0xFFE2E8F0)),
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
                            columns: [
                              DataColumn(
                                label: SizedBox(
                                  width: 130,
                                  child: DialogTableHeaderText(
                                    text: 'Received Amount'.tr,
                                    fontSize: 11,
                                    align: TextAlign.start,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 150,
                                  child: DialogTableHeaderText(
                                    text: 'Remarks'.tr,
                                    fontSize: 11,
                                    align: TextAlign.start,
                                  ),
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
                                                        Color(0xFFE2E8F0)),
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
                                              color: Color(0xFFE2E8F0)),
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
                                                "Please select at least one item"
                                                    .tr,
                                                Colors.red,
                                                Icons.error);
                                            return;
                                          }

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

                                            await dashboardProvider
                                                .fetchAllOrdersAtOnce();

                                            dashboardProvider.fetchData();

                                            Get.back();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryButtonColor,
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
          ),
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
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: primaryColor)),
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
}) {
  Timer? pollTimer;
  bool hasSuccess = false;
  bool isChecking = false;
  int pollCount = 0;

  void handleSuccess(String intentId) async {
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

      ApiWorker().customerPayment(
        context: context,
        checkDueDate: "",
        checkNumber: "",
        detail: remarks,
        orderId: item.orderId.toString(),
        paymentType: "3",
        receivedAmount: appliedAmount,
        transactionDate: "",
        transactionId: intentId,
      );
    }

    Future.delayed(Duration.zero, () {
      if (context.mounted) {
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

    await dashboardProvider.fetchAllOrdersAtOnce();

    dashboardProvider.fetchData();
  }

  Future<void> checkPayment() async {
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

        handleSuccess(intentId!);
      } else {
        print("⏳ Payment still pending...");
      }
    } catch (e) {
      print("❌ Poll #$pollCount Error: $e");
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
        if (hasSuccess) {
          pollTimer?.cancel();

          return;
        }
        await checkPayment();

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
                  fontFamily: 'Poppins_Regular',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: session.url,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Amount: ${addCurrencySymbol()}${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Scan with Phone Camera\nGoogle Pay • Apple Pay • Card",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    print("❌ User cancelled payment");
                    pollTimer?.cancel();
                    Navigator.of(ctx).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        fontFamily: 'Poppins_Regular',
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700),
                  ),
                ),
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
