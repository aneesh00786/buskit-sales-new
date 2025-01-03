import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
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
            // Adjust the dialog's width and height
            double dialogWidth = MediaQuery.of(context).size.width * 0.7;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0; // Height of each row
            double headerHeight = 30.0; // Height of header row

            // Calculate the list height based on the number of items
            double listHeight = recentOrders.length * rowHeight;

            // Ensure content height doesn't exceed the max dialog height
            double contentHeight =
                listHeight > maxDialogHeight ? maxDialogHeight : listHeight;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxDialogHeight,
              ),
              child: Container(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                      color: primaryColor,
                      ),
                      height: headerHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Date",
                                  fontSize: 13,
                                ),
                              ),
                          ),
                          Expanded(
                            child: Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Invoice",
                                  fontSize: 13,
                                ),
                              ),
                          ),
                          Expanded(
                            child: Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Status",
                                  fontSize: 13,
                                ),
                              ),
                          ),
                          Expanded(
                            child: Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Amount",
                                  fontSize: 13,
                                ),
                              ),
                          ),
                          Expanded(
                            child: Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Due By",
                                  fontSize: 13,
                                ),
                              ),
                          ),
                          Expanded(
                            child: Center(
                                child: DialogTableHeaderTextWhite(
                                  text: "Select",
                                  fontSize: 13,
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount:
                              recentOrders.isEmpty ? 1 : recentOrders.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (recentOrders.isEmpty) {
                              return Container(
                                height: rowHeight,
                                child: Center(child: Text('No data available')),
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
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:10,
                                                  vertical: 2
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    getStatusName(
                                                        order.orderStatus),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ),),
                                    Expanded(
                                        child: Center(
                                            child: Text(formatAmount(
                                                order.orderTotal)))),
                                    Expanded(
                                        child: Center(
                                            child: Text(
                                                getFormattedOrderCreatAt(
                                                    order.orderCreatAt)))),
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
