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
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

const double colDateWidth = 70;
const double colInvoiceWidth = 57;
const double colStatusWidth = 70;
const double colAmountWidth = 120;
const double colDueWidth = 65;
const double colSelectWidth = 40;

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
  return DashboardCard(
    height: 300,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- TOP HEADER (Title & Buttons) remains unchanged ---
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
                      if (subscriptionController
                              .customerPaymentCollection.value ==
                          "true") {
                        List<RecentOrder> selectedOrders = [];
                        for (var order in recentOrders) {
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
                            customerEmail: customerEmail, // <--- ADD THIS
                            customerMobile: customerMobile,
                            // Passes the required Customer ID
                          );
                          // paymentCollectionDialog(context, selectedOrders);
                        } else {
                          showCustomToast(context);
                        }
                      } else {
                        showUpgradePlanDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5bc0de),
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
                      context, recentOrders, customerEmail, customerMobile);
                },
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor.withOpacity(0.3)),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.open_in_new,
                          size: 17, color: primaryColor),
                    )),
              ),
            ),
          ],
        ),
        nkSmallSizeBox(),

        // --- SCROLLABLE TABLE AREA STARTS HERE ---
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 1. Determine a minimum width for your table to ensure it looks good.
              // If the screen is smaller than 800, it will scroll.
              // If larger, it will fill the space.
              const double minTableWidth = 800.0;

              // Use the larger of the two: screen width or minTableWidth
              double effectiveWidth = constraints.maxWidth < minTableWidth
                  ? minTableWidth
                  : constraints.maxWidth;

              double availableHeight = constraints.maxHeight;
              double fontSize = 11;

              return Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal Scroll
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        // minWidth: effectiveWidth,
                        // maxWidth: effectiveWidth
                        minWidth: totalTableWidth,
                        maxWidth: totalTableWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 2. The Heading (Now scrolls horizontally)
                        const OrdersPaymentHeading(),

                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 0),
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                        ),

                        // 3. The Data List (Vertical scroll inside Horizontal scroll)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: recentOrders.map((order) {
                                return SizedBox(
                                  height: 35.0,

                                  // padding: const EdgeInsets.symmetric(vertical: 0.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: colDateWidth,
                                        child: Center(
                                          child: Text(
                                            getFormattedOrderCreatAt(
                                                order.orderCreatAt),
                                            style:
                                                TextStyle(fontSize: fontSize),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colInvoiceWidth,
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              showInvoicePreviewOnline(
                                                  context, order.orderId);
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                MyRegularText(
                                                  color: primaryColor,
                                                  label: order.invoiceId,
                                                  fontSize: fontSize,
                                                  maxlines: 1,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                if ((order.hasActiveLink ??
                                                        0) !=
                                                    0) ...[
                                                  const SizedBox(height: 2),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      child: const Text(
                                                        'Payment Link Sent',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colStatusWidth,
                                        child: Center(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    8.0, // Fixed padding is safer than calculation inside scroll
                                                vertical: 2.0,
                                              ),
                                              child: Text(
                                                getStatusName(order.orderStatus)
                                                    .tr,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: fontSize,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                                  waitDuration: const Duration(
                                                      milliseconds: 500),
                                                  child: MyRegularText(
                                                    label:
                                                        '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
                                                        '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
                                                        '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                    maxlines: 1,
                                                    fontSize: 11,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              if (order.paymentStatus == 3) ...[
                                                const SizedBox(width: 2),
                                                PaymentHistoryButton(
                                                  orderId: order.orderId,
                                                  iconSize: 13,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colDueWidth,
                                        child: Center(
                                          child: Text(
                                            order.duedate!.isNotEmpty
                                                ? order.duedate?.first ?? ''
                                                : '',
                                            style: TextStyle(
                                              color: order.duedate!.isEmpty
                                                  ? Colors.grey
                                                  : order.duedate?[1] >= 3
                                                      ? Colors.green
                                                      : order.duedate?[1] <=
                                                                  3 &&
                                                              order.duedate?[
                                                                      1] >=
                                                                  1
                                                          ? Colors.amber
                                                          : Colors.red,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colSelectWidth,
                                        child: Center(
                                          child: Consumer<CustomersProvider>(
                                            builder:
                                                (context, provider, child) {
                                              return Checkbox(
                                                value: provider
                                                    .isOrderSelected(order),
                                                onChanged: (bool? isSelected) {
                                                  provider.toggleOrderSelection(
                                                      order);
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
