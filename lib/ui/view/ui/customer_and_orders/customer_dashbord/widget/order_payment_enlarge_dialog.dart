import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_collection_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
showCustomDialog(BuildContext context, List<RecentOrder> recentOrders) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.7;
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

                                // Show the appropriate dialog or toast based on the selection
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
                    Container(
                      color: const Color.fromARGB(255, 248, 248, 249),
                      height: headerHeight,
                      child: const Row(
                        children: [
                          DialogTableHeaderText(
                            text: "Date",
                            fontSize: 13,
                          ),
                          DialogTableHeaderText(
                            text: "Invoice",
                            fontSize: 13,
                          ),
                          DialogTableHeaderText(
                            text: "Status",
                            fontSize: 13,
                          ),
                          DialogTableHeaderText(
                            text: "Amount",
                            fontSize: 13,
                          ),
                          DialogTableHeaderText(
                            text: "Due By",
                            fontSize: 13,
                          ),
                          DialogTableHeaderText(
                            text: "Select",
                            fontSize: 13,
                          ),
                        ],
                      ),
                    ),
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
                                child: const Center(child: Text('No data available')),
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
                                        child: Center(
                                            child: Text(
                                                getFormattedOrderCreatAt(
                                                    order.orderCreatAt)))),
                                    Expanded(
                                        child:
                                            Center(child: Text(order.orderId))),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xff008000),
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
                                        child: Center(
                                            child: Text(formatAmount(
                                                order.orderTotal)))),
                                    Expanded(
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
