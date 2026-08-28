import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/dashboard_card.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payment_heading.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_history_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/custom_toast.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/order_payment_enlarge_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_collection_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

const double colDateWidth = 90;
const double colInvoiceWidth = 90;
const double colStatusWidth = 88;
const double colAmountWidth = 200;
const double colDueWidth = 98;
const double colSelectWidth = 50;

const double totalTableWidth = colDateWidth +
    colInvoiceWidth +
    colStatusWidth +
    colAmountWidth +
    colDueWidth +
    colSelectWidth;

Widget OrdersPayments(
  BuildContext context,
  List<RecentOrder> recentOrders,
  SubscriptionController subscriptionController,
  String customerEmail,
  String customerMobile,
) {
  return OrdersPaymentsWidget(
    recentOrders: recentOrders,
    subscriptionController: subscriptionController,
    customerEmail: customerEmail,
    customerMobile: customerMobile,
  );
}

class OrdersPaymentsWidget extends StatefulWidget {
  final List<RecentOrder> recentOrders;
  final SubscriptionController subscriptionController;
  final String customerEmail;
  final String customerMobile;

  const OrdersPaymentsWidget({
    super.key,
    required this.recentOrders,
    required this.subscriptionController,
    required this.customerEmail,
    required this.customerMobile,
  });

  @override
  State<OrdersPaymentsWidget> createState() => _OrdersPaymentsWidgetState();
}

class _OrdersPaymentsWidgetState extends State<OrdersPaymentsWidget> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double fontSize = 11.5;

    return DashboardCard(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Top Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: dashboardContainerHeader('Orders & Payments'.tr),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 24,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.subscriptionController
                                  .customerPaymentCollection.value ==
                              "true") {
                            List<RecentOrder> selectedOrders = [];
                            for (var order in widget.recentOrders) {
                              if (context
                                  .read<CustomersProvider>()
                                  .isOrderSelected(order)) {
                                selectedOrders.add(order);
                              }
                            }
                            if (selectedOrders.isNotEmpty) {
                              String currentCustId =
                                  selectedOrders.first.customerId ?? "";
                              paymentCollectionDialog(
                                context,
                                selectedOrders,
                                currentCustId,
                                customerEmail: widget.customerEmail,
                                customerMobile: widget.customerMobile,
                              );
                            } else {
                              showCustomToast(context);
                            }
                          } else {
                            showUpgradePlanDialog(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5bc0de),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: Text(
                          'Collection'.tr,
                          style: const TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: InkWell(
                  onTap: () {
                    showCustomDialog(
                      context,
                      widget.recentOrders,
                      widget.customerEmail,
                      widget.customerMobile,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primaryColor.withOpacity(0.3),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.open_in_new, size: 17, color: primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          nkSmallSizeBox(),

          // 🔹 Scrollable Table Area with Persistent Horizontal & Vertical Scrollbars
          Expanded(
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              radius: const Radius.circular(8),
              thickness: 6,
              notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: totalTableWidth,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Table Heading
                      const OrdersPaymentHeading(),
                      const SizedBox(height: 4),

                      // Data List
                      Expanded(
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: widget.recentOrders.map((order) {
                                return Container(
                                  height: 38.0,
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Date
                                      SizedBox(
                                        width: colDateWidth,
                                        child: Center(
                                          child: Text(
                                            getFormattedOrderCreatAt(order.orderCreatAt),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins_Regular',
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Invoice
                                      SizedBox(
                                        width: colInvoiceWidth,
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              showInvoicePreviewOnline(context, order.orderId);
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  order.invoiceId,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins_Regular',
                                                    color: primaryColor,
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if ((order.hasActiveLink ?? 0) != 0) ...[
                                                  const SizedBox(height: 2),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    child: const Text(
                                                      'Payment Link Sent',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins_Regular',
                                                        fontSize: 8,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Status
                                      SizedBox(
                                        width: colStatusWidth,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                            ),
                                            child: Text(
                                              getStatusName(order.orderStatus).tr,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins_Regular',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Amount
                                      SizedBox(
                                        width: colAmountWidth,
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Tooltip(
                                                  message:
                                                      '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
                                                      '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
                                                      '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                  waitDuration: const Duration(milliseconds: 500),
                                                  child: Text(
                                                    '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
                                                    '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
                                                    '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins_Regular',
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (order.paymentStatus == 3) ...[
                                                const SizedBox(width: 4),
                                                PaymentHistoryButton(
                                                  orderId: order.orderId,
                                                  iconSize: 13,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Due By
                                      SizedBox(
                                        width: colDueWidth,
                                        child: Center(
                                          child: Text(
                                            order.duedate!.isNotEmpty ? order.duedate?.first ?? '' : '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Poppins_Regular',
                                              fontWeight: FontWeight.w600,
                                              color: order.duedate!.isEmpty
                                                  ? Colors.grey
                                                  : order.duedate?[1] >= 3
                                                      ? Colors.green
                                                      : order.duedate?[1] <= 3 && order.duedate?[1] >= 1
                                                          ? Colors.amber
                                                          : Colors.red,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Select
                                      SizedBox(
                                        width: colSelectWidth,
                                        child: Center(
                                          child: Consumer<CustomersProvider>(
                                            builder: (context, provider, child) {
                                              return Checkbox(
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
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
