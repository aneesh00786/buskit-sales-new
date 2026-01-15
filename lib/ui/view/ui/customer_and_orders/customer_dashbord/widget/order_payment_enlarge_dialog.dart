import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/custom_dialog_heading.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_collection_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_history_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

showCustomDialog(BuildContext context, List<RecentOrder> recentOrders) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: isPhonePortrait(context) ? EdgeInsets.zero : null,
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = isPhonePortrait(context)
                ? fullScreenWidth(context)
                : fullScreenWidth(context) * 0.8;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 30.0;
            double listHeight = recentOrders.length * rowHeight;
            double contentHeight =
                listHeight > maxDialogHeight ? maxDialogHeight : listHeight;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                          const Expanded(
                            child: Text(
                              "Order & Payments",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          nkSmallSizeBox(),
                          SizedBox(
                            height: 25,
                            child: ElevatedButton(
                              onPressed: () {
                                List<RecentOrder> selectedOrders = [];
                                for (var order in recentOrders) {
                                  if (context
                                      .read<CustomersProvider>()
                                      .isOrderSelected(order)) {
                                    selectedOrders.add(order);
                                  }
                                }
                                if (selectedOrders.isNotEmpty) {
                                  paymentCollectionDialog(
                                      context, selectedOrders);
                                } else {
                                  showCustomToastDisplay(
                                      context,
                                      'Please select an order to change payment details',
                                      red,
                                      Icons.close);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff5bc0de),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              child: const Text(
                                'Collection',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          dialogCloseButton1(context, red),
                        ],
                      ),
                    ),
                    CustomDialogHeading(headerHeight: headerHeight),
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount:
                              recentOrders.isEmpty ? 1 : recentOrders.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (recentOrders.isEmpty) {
                              return SizedBox(
                                height: rowHeight,
                                child: Center(child: NodataWidget()),
                              );
                            } else {
                              var order = recentOrders[index];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                height: rowHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Center(
                                            child: Text(
                                                getFormattedOrderCreatAt(
                                                    order.orderCreatAt)))),
                                    Expanded(
                                        flex: 1,
                                        child:
                                            Center(child: Text(order.orderId))),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            //Color(0xff008000),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 2),
                                            child: Center(
                                              child: Text(
                                                getStatusName(
                                                    order.orderStatus),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Change Flexible to Expanded so it calculates available space for FittedBox
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit
                                                    .scaleDown, // Only shrinks, never grows larger than fontSize
                                                child: MyRegularText(
                                                  label:
                                                      '${formatAmount(order.orderTotal.toStringAsFixed(2))} / '
                                                      '${formatAmount((order.receivableAmount ?? order.orderTotal).toStringAsFixed(2))} / '
                                                      '${formatAmount(order.receivedAmount.toStringAsFixed(2))}',
                                                  maxlines: 1,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            if (order.paymentStatus == 3) ...[
                                              PaymentHistoryButton(
                                                orderId: order.orderId,
                                                iconSize: 11 + 2,
                                              )
                                              // const SizedBox(width: 4),
                                              //  IconButton(
                                              //       padding: EdgeInsets.zero,
                                              //       constraints: const BoxConstraints(),
                                              //       icon: const Icon(
                                              //         Icons.info_outline,
                                              //         size: 13, // 11 + 2
                                              //         color: Colors.blue,
                                              //       ),
                                              //       onPressed: () {

                                              //         // Your button logic
                                              //       },
                                              //     ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Expanded(
                                    //     child: Center(
                                    //         child: Text(formatAmount(
                                    //             order.orderTotal)))),
                                    Expanded(
                                      flex: 1,
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
                                                    : order.duedate?[1] <= 3 &&
                                                            order.duedate?[1] >=
                                                                1
                                                        ? Colors.amber
                                                        : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Consumer<CustomersProvider>(
                                          builder: (context, provider, child) {
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
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
