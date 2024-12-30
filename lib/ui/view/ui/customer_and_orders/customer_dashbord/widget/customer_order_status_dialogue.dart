import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
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
                child: InkWell(
                  onTap: () {
                    _showDetailedOrderDialog(
                      context,
                      order,
                    );
                  },
                  child: Text(
                    order.orderId,
                    style: TextStyle(fontWeight: FontWeight.w600,color: primaryColor),
                    textAlign: TextAlign.center,
                    
                  ),
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
          Container(
            width: availableWidth,
            height: containerHeight,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
                                    fontSize: 13,
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
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  dialogCloseButton1(context, red),
                ],
              ),
              const SizedBox(height: 16),
              MyCommnonContainer(
                isCommonBorder: true,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'INVOICE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          NKDateUtils.commonDayFormat2(
                              NKDateUtils.formatStringUTCDateTime(
                                  order.orderCreatedAt.toIso8601String())),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customer.isNotEmpty
                                  ? 'Name : ${order.customer[0].fullName}'
                                  : 'N/A',
                            ),
                            Text(
                              order.customer.isNotEmpty
                                  ? 'Email : ${order.customer[0].email}'
                                  : 'N/A',
                            ),
                            Text(
                              order.customer.isNotEmpty
                                  ? 'Phone : ${order.customer[0].mobileNo}'
                                  : 'N/A',
                            ),
                            Text(
                              order.customer.isNotEmpty
                                  ? 'Salesman : ${order.customer[0].salesmanName}'
                                  : 'N/A',
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text:
                                        'Payment Status : ', // This part is always black
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: order.customer.isNotEmpty
                                        ? (order.paymentStatus == 0
                                            ? 'NOT PAID'
                                            : 'COMPLETED')
                                        : 'N/A',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: order.paymentStatus == 0
                                          ? Colors.red
                                          : Colors.green, // Dynamic color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              order.customer.isNotEmpty
                                  ? 'Payment Mode : ${_getPaymentTypeName(order.paymentStatus)}'
                                  : 'N/A',
                            ),
                          ],
                        ),
                        const Spacer(),
                        ClipOval(
                          child: Container(
                            height: 50,
                            width: 50,
                            color: Colors.lightBlue[100],
                            child: order.customer.isNotEmpty
                                ? Image.network(
                                    'uploads/${order.customer[0].imageUrl}')
                                : const Icon(Icons.person, color: Colors.blue),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ITEMS ORDERED',
                          style: TextStyle(fontSize: 18))),
                  const Spacer(),
                  Text('Order Status : ${getStatusName(order.orderStatus)}',
                      style: const TextStyle(fontSize: 18))
                ],
              ),
              const Divider(
                color: black,
              ),
              Row(
                children: [
                  Expanded(
                    child: DataTable(
                      dataRowHeight: 40,
                      headingRowHeight: 40,
                      horizontalMargin: 20,
                      headingTextStyle: const TextStyle(
                        color: black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      columns: const [
                        DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'ITEMS NAME',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'UNIT PRICE',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'QUANTITY',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            flex: 2,
                            child: Text(
                              'TOTAL',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                      rows: order.cart.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item.productName)),
                          DataCell(Center(child: Text(item.price.toString()))),
                          DataCell(Center(
                              child: Text(
                                  item.packType == 'Pack'
                                      ? '${item.pieces} (${item.quantity} ${item.packType})'
                                      : item.quantity.toString(),
                                  maxLines: 1))),
                          DataCell(Align(
                              alignment: Alignment.centerRight,
                              child:
                                  Text(formatAmount(item.price), maxLines: 1))),
                        ]);
                      }).toList(),
                    ),
                  )
                ],
              ),
              // const Divider(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            color: black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatAmount(order.orderTotal),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    // const Row(
                    //   children: [
                    //     Text(
                    //       'Tax Amount',
                    //       style: TextStyle(
                    //         color: black,
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //     Spacer(),
                    //     Text('10%'),
                    //   ],
                    // ),
                    Divider(color: Colors.grey.shade400),
                    Row(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatAmount(order.orderTotal),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            color: red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Currency  \$',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    },
  );
}
String _getPaymentTypeName(int paymentType) {
  switch (paymentType) {
    case 0:
      return 'Cash';
    case 1:
      return 'Cheque';
    case 2:
      return 'Bank Transfer';
    default:
      return 'Unknown';
  }
}