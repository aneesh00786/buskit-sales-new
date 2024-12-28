import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDetailedOrderInvoiceDialog(
  BuildContext context,
  var orderData,
  final bool invoice,
) async {
  DashBoardController dashBoardController = Get.put(DashBoardController());

  var orderInvoiceData = await dashBoardController.loadSpecificOrderInvoiceData(
      orderId: orderData.orderId.toString());

  showDialog(
    // ignore: use_build_context_synchronously
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
                  children: [const Spacer(), dialogCloseButton1(context, red)],
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
                          Text(
                            invoice ? 'INVOICE' : 'CUSTOMER & ORDER',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            NKDateUtils.commonDayFormat2(
                                NKDateUtils.formatStringUTCDateTime(
                                    orderInvoiceData.orderCreatAt.toString())),
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
                              Text('Name : ${orderInvoiceData.businessName}'),
                              Text('Email : ${orderInvoiceData.email}'),
                              Text('Phone : ${orderInvoiceData.mobileno}'),
                              Text(
                                  'Salesman : ${orderInvoiceData.salesmanName}'),
                            ],
                          ),
                          if (invoice) ...[
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Payment Status : ',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      TextSpan(
                                        text:
                                            (orderInvoiceData.paymentStatus == 0
                                                ? 'NOT PAID'
                                                : 'COMPLETED'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              orderInvoiceData.paymentStatus ==
                                                      0
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                    'Payment Mode : ${_getPaymentTypeName(orderInvoiceData.paymentStatus!)}'),
                              ],
                            ),
                          ],
                          const Spacer(),
                          ClipOval(
                            child: Container(
                              height: 50,
                              width: 50,
                              color: Colors.lightBlue[100],
                              child: orderInvoiceData.imageUrl != null
                                  ? Image.network(
                                      '${orderInvoiceData.imageUrl}',
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.person,
                                      color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
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
                    Text(
                        'Order Status : ${getStatusName(orderInvoiceData.orderStatus!)}',
                        style: const TextStyle(fontSize: 18))
                  ],
                ),
                const Divider(
                  color: black,
                ),
                Obx(() {
                  return dashBoardController.isInvoiceLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                    rows: dashBoardController
                                        .fetchSpecificOrderData!.cart!
                                        .map((item) {
                                      return DataRow(cells: [
                                        DataCell(
                                            Text(item.productName.toString())),
                                        DataCell(Center(
                                            child: Text(
                                          formatAmount(item.price),
                                          maxLines: 1,
                                        ))),
                                        DataCell(Center(
                                            child: Text(
                                                item.packType == 'Pack'
                                                    ? '${item.pieces} (${item.quantity} ${item.packType})'
                                                    : item.quantity.toString(),
                                                maxLines: 1))),
                                        DataCell(Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                formatAmount(item.price),
                                                maxLines: 1))),
                                      ]);
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
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
                                        formatAmount(dashBoardController
                                            .fetchSpecificOrderData!
                                            .orderTotal),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                  if (dashBoardController
                                          .fetchSpecificOrderData!
                                          .cart!
                                          .first
                                          .tax !=
                                      null) ...[
                                    Row(
                                      children: [
                                        Text(
                                          '${dashBoardController.fetchSpecificOrderData!.cart!.first.taxName} - ${dashBoardController.fetchSpecificOrderData!.cart!.first.tax} %',
                                          style: const TextStyle(
                                            color: black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatAmount(
                                              '${dashBoardController.fetchSpecificOrderData!.orderTotal! * dashBoardController.fetchSpecificOrderData!.cart!.first.tax! / 100}'),
                                          // formatAmount(invoiceData.cart!.first.tax),
                                          // taxAmount), // Use the calculated tax amount here
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ],
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
                                        dashBoardController
                                                    .fetchSpecificOrderData!
                                                    .cart!
                                                    .first
                                                    .tax !=
                                                null
                                            ? formatAmount(
                                                '${(dashBoardController.fetchSpecificOrderData!.orderTotal! + dashBoardController.fetchSpecificOrderData!.orderTotal! * dashBoardController.fetchSpecificOrderData!.cart!.first.tax! / 100)}')
                                            : formatAmount(dashBoardController
                                                .fetchSpecificOrderData!
                                                .orderTotal),
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
                          ],
                        );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Currency  \$',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            )
            // }),
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