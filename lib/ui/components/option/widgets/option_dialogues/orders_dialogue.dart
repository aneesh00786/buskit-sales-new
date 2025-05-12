import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/detailed_order_customer_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/detailed_order_dialogue.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildOrdersDialogueMainDash({
  required List<OrdersDash> filteredOrders,
  required BuildContext context,
  required bool isCustomer,
}) {
  List<String> headers = [
    "Customer List",
    "Order NO",
    "Created",
    "Created By",
    "Order Amount",
    "Invoice",
    "Payment Status",
    "Status",
  ];
  List<TableViewRow> rows = filteredOrders.isEmpty
      ? [
          const TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("No Records Found")),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
              TableViewCell(child: SizedBox()),
            ],
          ),
        ]
      : filteredOrders.map((order) {
          final customer = order.customer.isNotEmpty ? order.customer[0] : null;
          return TableViewRow(
            height: 80,
            cells: [
              TableViewCell(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xffe6ecff),
                      child: Icon(Icons.person, size: 14, color: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer != null ? customer.businessName : 'N/A',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer != null ? customer.fullName : 'N/A',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer != null ? customer.mobileNo : 'N/A',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer != null ? customer.email : 'N/A',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TableViewCell(
                child: InkWell(
                  onTap: () {
                    isCustomer
                        ? showDetailedOrderDialog(context, order, false)
                        : showDetailedCustomerOrderDialog(
                            context,
                            order,
                          );
                  },
                  child: Text(
                    order.orderId,
                    style: const TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableViewCell(
                child: Text(
                  // ignore: unnecessary_null_comparison
                  order.orderCreatedAt != null
                      ? getFormattedOrderCreatAt(
                          order.orderCreatedAt.toString())
                      : 'N/A',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  formatAmount(order.orderTotal),
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: InkWell(
                  onTap: () {
                    //  isCustomer? showDetailedOrderDialog(context, order, true):showDetailedCustomerOrderDialog(
                    //   context,
                    //   order,
                    //  );
                    showDialog(
                      context: context,
                      builder: (context) {
                        return InvoicePreview(
                          orderId: order.orderId,
                        );
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      order.invoice.isEmpty
                          ? 'Not Found'
                          : order.invoice[0].invoiceId,
                      style: const TextStyle(color: primaryColor, fontSize: 12),
                    ),
                  ),
                ),
              ),
              TableViewCell(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          order.paymentStatus == 0 ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: order.paymentStatus == 0
                              ? Colors.red
                              : Colors.green),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Icon(
                          order.paymentStatus == 0 ? Icons.close : Icons.done,
                          color: white,
                          size: 14.0),
                    ),
                  ),
                ),
              ),
              TableViewCell(
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffffdbb8),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getStatusName(order.orderStatus),
                            style: const TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.w400),
                          ),
                          if (order.orderStatus == 2 &&
                              order.deliveryDate != null) ...[
                            Text(
                                NKDateUtils.commonFullDateTimeFormat(
                                    NKDateUtils.formatStringUTCDateTime(
                                        order.deliveryDate!.toIso8601String())),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w400,
                                )),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList();

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      double maxDialogHeight = MediaQuery.of(context).size.height * 0.8;
      double headerHeight = 60;
      double rowHeight = 90;
      double contentHeight = headerHeight + (rows.length * rowHeight);
      double containerHeight = contentHeight.clamp(0, maxDialogHeight);

      return Stack(
        children: [
          SizedBox(
            width: availableWidth,
            height: containerHeight,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    color: primaryColor,
                  ),
                  height: headerHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            headers[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width <= 800
                                  ? 12.3
                                  : 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      ...headers.sublist(1).map(
                            (label) => Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width <= 800
                                            ? 12.3
                                            : 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: rows.length,
                    shrinkWrap: true,
                    physics: contentHeight > maxDialogHeight
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: rows[index].cells[0].child,
                              ),
                            ),
                            ...rows[index].cells.sublist(1).map(
                                  (cell) => Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: cell.child,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              height: 30,
              width: 30,
              child: Center(child: dialogCloseButton1(context, red)),
            ),
          ),
        ],
      );
    },
  );
}
