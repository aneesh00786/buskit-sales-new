// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDetailedOrderInvoiceDialog(
    BuildContext context, String orderId, final bool invoice,
    {String changedTitle = 'CUSTOMER & ORDER'}) async {
  DashBoardController dashBoardController = Get.put(DashBoardController());

  var orderInvoiceData = await dashBoardController.loadSpecificOrderInvoiceData(
      orderId: orderId.toString());

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
                          invoice ? 'INVOICE' : changedTitle.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "DATE : ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          NKDateUtils.commonFullDateTimeFormat2(
                              orderInvoiceData.orderCreatAt!),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Text(
                        //   NKDateUtils.commonDayFormat2(
                        //     NKDateUtils.formatStringUTCDateTime(
                        //       orderInvoiceData.orderCreatAt?.toString() ?? '',
                        //     ),
                        //   ),
                        //   style: const TextStyle(
                        //     color: Colors.black,
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Name : ${orderInvoiceData.businessName ?? 'N/A'}'),
                            Text('Email : ${orderInvoiceData.email ?? 'N/A'}'),
                            Text(
                                'Phone : ${orderInvoiceData.mobileno ?? 'N/A'}'),
                            Text(
                                'Staff : ${orderInvoiceData.salesmanName ?? 'N/A'}'),
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
                                      text: (orderInvoiceData.paymentStatus == 0
                                          ? 'NOT PAID'
                                          : 'COMPLETED'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            orderInvoiceData.paymentStatus == 0
                                                ? Colors.red
                                                : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                  'Payment Mode : ${_getPaymentTypeName(orderInvoiceData.paymentStatus ?? 0)}'),
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
                                    '${ApiConstants.imageBaseUrl}${orderInvoiceData.imageUrl}',
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.person, color: Colors.blue),
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
                      'Order Status : ${getStatusName(orderInvoiceData.orderStatus ?? 0)}',
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
                                  columns: [
                                    DataColumn(
                                      label: SizedBox(
                                        width: fullScreenWidth(context) > 740
                                            ? 250
                                            : 130,
                                        child: const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('ITEMS NAME'),
                                        ),
                                      ),
                                    ),
                                    const DataColumn(
                                      label: Expanded(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text('UNIT PRICE')),
                                      ),
                                    ),
                                    const DataColumn(
                                      label: Expanded(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text('QUANTITY')),
                                      ),
                                    ),
                                    const DataColumn(
                                      label: Expanded(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text('TAX')),
                                      ),
                                    ),
                                    const DataColumn(
                                      label: Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text('TOTAL'),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: (dashBoardController
                                              .fetchSpecificOrderData?.cart ??
                                          [])
                                      .map((item) {
                                    return DataRow(cells: [
                                      DataCell(
                                        Tooltip(
                                          message:
                                              "${item.productName} - ${item.variationName}",
                                          preferBelow: false,
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: SizedBox(
                                            width:
                                                fullScreenWidth(context) > 740
                                                    ? 250
                                                    : 130,
                                            child: Text(
                                              "${item.productName} - ${item.variationName}",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            formatAmount(item.price ?? 0),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            item.packType == 'Pack'
                                                ? '${(item.pieces ?? 0) * (item.quantity ?? 0)} (${item.quantity} ${item.packType})'
                                                : item.quantity?.toString() ??
                                                    '0',
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            formatAmount(item.tax ?? 0),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text.rich(
                                            TextSpan(
                                              text: formatAmount(
                                                  item.totalPrice ?? 0),
                                              children: item.inclTax ==
                                                      "incl_tax"
                                                  ? [
                                                      const TextSpan(
                                                        text: "  (Incl. Tax)",
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
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
                                              .fetchSpecificOrderData?.cart
                                              ?.fold(
                                                  0.0,
                                                  (sum, item) =>
                                                      sum +
                                                      (item.totalPrice ?? 0)) ??
                                          0),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                if (dashBoardController
                                            .fetchSpecificOrderData?.tax !=
                                        null &&
                                    dashBoardController
                                        .fetchSpecificOrderData!.tax!
                                        .any((taxItem) =>
                                            taxItem.tax != null)) ...[
                                  ...dashBoardController
                                      .fetchSpecificOrderData!.tax!
                                      .map((taxItem) {
                                    return Row(
                                      children: [
                                        Text(
                                          '${taxItem.taxName ?? 'Tax'} - ${taxItem.tax ?? 0} %',
                                          style: const TextStyle(
                                            color: black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatAmount(
                                            '${(dashBoardController.fetchSpecificOrderData?.orderTotal ?? 0) * (taxItem.tax ?? 0) / 100}',
                                          ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    );
                                  }),
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
                                      formatAmount(dashBoardController
                                              .fetchSpecificOrderData?.cart
                                              ?.fold(
                                                  0.0,
                                                  (sum, item) =>
                                                      sum +
                                                      (item.totalPrice ?? 0)) ??
                                          0),
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
