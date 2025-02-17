import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

void showValueOrderDialog(
    BuildContext context, Delivery deliveryData, String title, int status) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.6;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 30.0;

            final filteredOrders = deliveryData.order!.totalOrders!
                .where((orderDetails) => status == 5
                    ? (orderDetails.orderStatus == 5 ||
                        orderDetails.orderStatus == 14)
                    : orderDetails.orderStatus == status)
                .toList();

            double listHeight = filteredOrders.length * rowHeight;
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
                    // Dialog Header
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
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          dialogCloseButton1(context, red),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      height: headerHeight,
                      child: const Row(
                        children: [
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Customer',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Date',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Amount',
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView( // Use ScrollView here
                        child: SizedBox(
                          height: contentHeight,
                          child: ListView.builder(
                            itemCount: filteredOrders.isEmpty
                                ? 1
                                : filteredOrders.length,
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (filteredOrders.isEmpty) {
                                return Container(
                                  height: rowHeight,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'No data available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              final orderDetails = filteredOrders[index];
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
                                          orderDetails.businessName ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          getFormattedOrderCreatAt(
                                              orderDetails.orderCreatAt ?? ''),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: InkWell(
                                          onTap: () {
                                            showDetailedOrderInvoiceDialog(
                                                context, orderDetails.orderId??'', true);
                                          },
                                          child: Text(
                                            orderDetails.invoiceId ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          getStatusName(
                                              orderDetails.orderStatus ?? 0),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          formatAmount(
                                              orderDetails.orderTotal ?? 0.0),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      height: rowHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DialogTableHeaderText(
                              text: 'Total',
                              fontSize: 12,
                              align: TextAlign.left,
                            ),
                            DialogTableHeaderText(
                              text: formatAmount(
                                filteredOrders
                                    .map((e) => e.orderTotal ?? 0.0)
                                    .fold(0.0, (a, b) => a + b),
                              ),
                              fontSize: 13,
                              align: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    )
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
