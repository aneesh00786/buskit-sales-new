import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_collection_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_history_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Widget _buildPaymentStatusBadge(int? orderStatus, String text) {
  final status = OrderHandlingClass.fromType(orderStatus ?? 0);
  final Color bg = status.statusBgColor;
  final Color textColor = status.statusTextColor;
  final Color dotColor = status.statusDotColor;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: dotColor.withOpacity(0.35), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text.tr,
          style: TextStyle(
            fontFamily: 'Poppins_Regular',
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

showCustomDialog(
  BuildContext context,
  List<RecentOrder> recentOrders,
  String customerEmail,
  String customerMobile,
) {
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();

  final double totalSum = recentOrders.fold<double>(
    0.0,
    (sum, order) => sum + (order.orderTotal),
  );

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: screenHeight * 0.88,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- HEADER ---
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 17),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Order & Payments".tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.35)),
                            ),
                            child: Text(
                              '${recentOrders.length} ${'Orders'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              List<RecentOrder> selectedOrders = [];
                              for (var order in recentOrders) {
                                if (context.read<CustomersProvider>().isOrderSelected(order)) {
                                  selectedOrders.add(order);
                                }
                              }
                              if (selectedOrders.isNotEmpty) {
                                String currentCustId = selectedOrders.first.customerId ?? "";
                                paymentCollectionDialog(
                                  context,
                                  selectedOrders,
                                  currentCustId,
                                  customerEmail: customerEmail,
                                  customerMobile: customerMobile,
                                );
                              } else {
                                showCustomToastDisplay(
                                  context,
                                  'Please select an order to change payment details'.tr,
                                  red,
                                  Icons.close,
                                );
                              }
                            },
                            icon: const Icon(Icons.payment_rounded, size: 14, color: Colors.white),
                            label: Text(
                              'Collection'.tr,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 17),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- BODY ---
                if (recentOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Center(child: NodataWidget()),
                  )
                else
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Scrollbar(
                          controller: verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                          child: Scrollbar(
                            controller: horizontalScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            radius: const Radius.circular(8),
                            thickness: 6,
                            notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                            child: SingleChildScrollView(
                              controller: verticalScrollController,
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                controller: horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                    headingTextStyle: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: 0.3,
                                    ),
                                    dataRowMinHeight: 52,
                                    dataRowMaxHeight: 64,
                                    columnSpacing: 14,
                                    horizontalMargin: 16,
                                    columns: [
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Date'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Invoice'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Status'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Amount (Total / Due / Paid)'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Due By'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                      DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Select'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                    ],
                                    rows: recentOrders.map((order) {
                                      return DataRow(
                                        cells: [
                                          // Date
                                          DataCell(
                                            Center(
                                              child: Text(
                                                getFormattedOrderCreatAt(order.orderCreatAt),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          // Invoice / Order ID
                                          DataCell(
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                ),
                                                child: Text(
                                                  order.orderId,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins_Regular',
                                                    color: primaryColor,
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Status
                                          DataCell(
                                            Center(
                                              child: _buildPaymentStatusBadge(order.orderStatus, getStatusName(order.orderStatus)),
                                            ),
                                          ),
                                          // Amount
                                          DataCell(
                                            Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${formatAmount(order.orderTotal.toStringAsFixed(2))} / ${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / ${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black),
                                                  ),
                                                  if (order.paymentStatus == 3) ...[
                                                    const SizedBox(width: 4),
                                                    PaymentHistoryButton(orderId: order.orderId, iconSize: 14),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Due By
                                          DataCell(
                                            Center(
                                              child: Text(
                                                order.duedate!.isNotEmpty ? order.duedate?.first ?? '' : '-',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins_Regular',
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: order.duedate!.isEmpty
                                                      ? Colors.grey
                                                      : order.duedate?[1] >= 3
                                                          ? Colors.green.shade700
                                                          : order.duedate?[1] <= 3 && order.duedate?[1] >= 1
                                                              ? Colors.amber.shade800
                                                              : Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Select Checkbox
                                          DataCell(
                                            Center(
                                              child: Consumer<CustomersProvider>(
                                                builder: (context, provider, child) {
                                                  return Checkbox(
                                                    activeColor: primaryColor,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                    value: provider.isOrderSelected(order),
                                                    onChanged: (bool? isSelected) {
                                                      provider.toggleOrderSelection(order);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // --- FOOTER ---
                if (recentOrders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'Showing'.tr} ${recentOrders.length} ${'Orders'.tr}',
                          style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${'Total'.tr}: ',
                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              Text(
                                formatAmount(totalSum),
                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 14, fontWeight: FontWeight.w800, color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
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
