// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:flutter/material.dart';

void showDetailedCustomerOrderDialog(BuildContext context, OrdersDash order) {
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