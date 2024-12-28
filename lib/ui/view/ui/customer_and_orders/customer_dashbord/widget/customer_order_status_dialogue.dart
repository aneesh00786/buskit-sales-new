import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_table_view/scrollable_table_view.dart';

Widget buildOrdersTable(
    {required List<OrdersDash> filteredOrders, required BuildContext context}) {
  List<String> headers = [
    "Customer List",
    "Order Number",
    "Order Created",
    "Order Amount",
    "Invoice",
    "Payment Status",
    "Status",
  ];
  List<TableViewRow> rows = filteredOrders.isEmpty
      ? [
          TableViewRow(
            height: 60,
            cells: [
              TableViewCell(child: Text("No Records Found")),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xffe6ecff),
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            customer?.businessName ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer?.mobileNo ?? 'N/A',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer?.email ?? 'N/A',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
                child: Text(
                  order.orderId,
                  style: TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  order.orderCreatedAt != null
                      ? formatNullableDate(order.orderCreatedAt)
                      : 'N/A',
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: Text(
                  '\$${order.orderTotal.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                ),
              ),
              TableViewCell(
                child: InkWell(
                    onTap: () {
                      _showDetailedOrderDialog(context, order);
                    },
                    child: text(order.invoice, 14.0)),
              ),
              TableViewCell(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          order.paymentStatus == 0 ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      order.paymentStatus == 0 ? Icons.close : Icons.done,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
              TableViewCell(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffffdbb8),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getStatusName(order.orderStatus),
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
            ],
          );
        }).toList();

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      double maxDialogHeight = 500;
      double rowHeight = 60;
      int maxVisibleRows = 6;
      double calculatedHeight =
          (rows.length * rowHeight).clamp(0, maxDialogHeight);

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: calculatedHeight,
          maxWidth: availableWidth,
        ),
        child: Stack(
          children: [
            Container(
              width: availableWidth,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              headers[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        ...headers
                            .sublist(1)
                            .map(
                              (label) => Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      height: 100,
                      child: ListView.builder(
                        itemCount: rows.length,
                        shrinkWrap: true,
                        physics: rows.length > maxVisibleRows
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          log('Length of the rows ${rows.length}');
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
                                ...rows[index]
                                    .cells
                                    .sublist(1)
                                    .map(
                                      (cell) => Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: cell.child,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
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
        ),
      );
    },
  );
}

Text text(List<InvoiceDash> invoices, dynamic s) {
  String invoiceIds = invoices.map((invoice) => invoice.invoiceId).join(', ');
  return Text(invoiceIds,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: s,
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ));
}

String _getStatusName(int status) {
  switch (status) {
    case 5:
      return 'Order Processing';
    case 10:
      return 'Packed for Delivery';
    case 1:
      return 'Out for Delivery';
    case 2:
      return 'Delivered';
    default:
      return 'Unknown';
  }
}

String formatNullableDate(DateTime? date, {String format = 'dd/MM/yyyy'}) {
  if (date == null) return 'N/A';
  return DateFormat(format).format(date);
}

void _showDetailedOrderDialog(BuildContext context, OrdersDash order) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.2),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Divider(),
                        //     Text('${order.cart[0]}'),
                        MyRegularText(
                            label: order.customer.isNotEmpty
                                ? '${order.customer[0].fullName}'
                                : 'N/A',
                            style: const TextStyle(fontSize: 20)),
                        MyRegularText(
                            label: order.invoice.isNotEmpty &&
                                    order.invoice[0].createdAt != null
                                ? 'Invoice Date: ${getFormattedOrderCreatAt(order.invoice[0].createdAt)}'
                                : 'Invoice Date: N/A'),
                        MyRegularText(
                            label: order.invoice.isNotEmpty
                                ? 'Invoice N0: ${order.invoice[0].invoiceId}'
                                : 'Invoice N0: N/A'),
                      ],
                    ),
                  ),
                  //VerticalDivider(),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Divider(),
                        MyRegularText(
                            label: order.customer[0].businessName,
                            style: const TextStyle(fontSize: 16)),
                        MyRegularText(label: order.customer[0].fullName),
                        MyRegularText(label: order.customer[0].email),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  LayoutBuilder(builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: SingleChildScrollView(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: secondaryTextColor, width: 0.7),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                      label: 'QTY',
                                      style:
                                          TextStyle(color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                      label: 'Description',
                                      style:
                                          TextStyle(color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                      label: 'Price',
                                      style:
                                          TextStyle(color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                      label: 'Sub Total',
                                      style:
                                          TextStyle(color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...order.cart.map((item) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                        label: item.quantity.toString()),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                        label: item.variationName),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                        label: item.price.toStringAsFixed(2)),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MyRegularText(
                                        label: (item.price).toStringAsFixed(2)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      )),
                    );
                  }),
                ],
              ),
              const Divider(),
              LayoutBuilder(builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: secondaryTextColor, width: 0.7),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: MyRegularText(
                                  label: 'Payment Info',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: MyRegularText(
                                  label: 'Due By',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: MyRegularText(
                                  label: 'Total Due',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyRegularText(
                                  label: order.paymentDetail.toString()),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyRegularText(
                                  label: getFormattedOrderCreatAt(
                                      order.checkDueDate)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyRegularText(
                                  label: order.orderTotal.toStringAsFixed(2)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  // DataTable(
                  //   columns: [
                  //     DataColumn(label: Text('Payment Info')),
                  //     DataColumn(label: Text('Due By')),
                  //     DataColumn(label: Text('Total Due')),
                  //   ],
                  //   rows: [
                  //     DataRow(cells: [
                  //       DataCell(Text(order.paymentDetail)),
                  //       DataCell(Text(order.checkDueDate.toString())),
                  //       DataCell(Text(order.orderTotal.toStringAsFixed(2))),
                  //     ]),
                  //   ],
                  // ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryColor),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryColor),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4.0), // Adjust the radius value as needed
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Handle accept action
                      Navigator.of(context).pop();
                    },
                    child: const Text('Accept',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
