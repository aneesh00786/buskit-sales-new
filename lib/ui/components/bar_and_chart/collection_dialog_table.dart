import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

void showValueCollectionDialog(
    BuildContext context, Collection collection, String title) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = MediaQuery.of(context).size.width * 0.7;
            double maxDialogHeight = constraints.maxHeight * 0.7;
            double rowHeight = 40.0;
            double headerHeight = 40.0;
            final completedOrders = collection.payment?.completedOrders ?? [];
            double listHeight = completedOrders.length * rowHeight;
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
                            text: 'Business Name',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Order Date',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Invoice ID',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Status',
                            fontSize: 13,
                          )),
                          Expanded(
                              child: DialogTableHeaderText(
                            text: 'Total Amount',
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                    // Scrollable Content
                    Flexible(
                      child: SizedBox(
                        height: contentHeight,
                        child: ListView.builder(
                          itemCount: completedOrders.isEmpty
                              ? 1
                              : completedOrders.length,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (completedOrders.isEmpty) {
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
                            final order = completedOrders[index];
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
                                        order.businessName ?? '',
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
                                            order.orderCreatAt ?? ''),
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
                                              context, order, true);
                                        },
                                        child: Text(
                                          order.invoiceId ?? '',
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
                                        getStatusName(order.orderStatus ?? 0),
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
                                        formatAmount(order.orderTotal ?? 0.0),
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
                    // Static Total Row
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
                      child: Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: DialogTableHeaderText(
                                text: 'Total',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          const Expanded(child: SizedBox.shrink()),
                          Expanded(
                            child: Center(
                              child: DialogTableHeaderText(
                                text: formatAmount(completedOrders
                                    .map((e) => e.orderTotal ?? 0.0)
                                    .reduce((a, b) => a + b)),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
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
