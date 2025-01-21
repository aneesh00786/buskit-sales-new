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
    BuildContext context, var orderData, final bool invoice,
    {bool isButtonNeeded = false}) async {
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
                  children: [const Spacer(), dialogCloseButton(context, red)],
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
                                    'Payment Mode : ${_getPaymentTypeName(orderInvoiceData.paymentStatus??0)}'),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ITEMS ORDERED', style: TextStyle(fontSize: 18)),
                    Text(
                      'Order Status : ${getStatusName(orderInvoiceData.orderStatus??0)}',
                      style: const TextStyle(fontSize: 18),
                    ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: DataTable(
                                    dataRowHeight: 40,
                                    headingRowHeight: 40,
                                    horizontalMargin: 20,
                                    columnSpacing: 20,
                                    headingTextStyle: const TextStyle(
                                      color: black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'ITEMS NAME',
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'UNIT PRICE',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'QUANTITY',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Align(
                                          alignment: Alignment.centerRight,
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
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  item.productName.toString()),
                                            ),
                                          ),
                                          DataCell(
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                formatAmount(item.price),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                item.packType == 'Pack'
                                                    ? '${(item.pieces??0 * item.quantity!)} (${item.quantity} ${item.packType})'
                                                    : item.quantity.toString(),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                formatAmount(item.totalPrice),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
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
                                              .fetchSpecificOrderData
                                              ?.orderTotal ??
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
                                          '${taxItem.tax_name ?? 'Tax'} - ${taxItem.tax ?? 0} %',
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
                                  }).toList(),
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
                                      dashBoardController.fetchSpecificOrderData
                                                      ?.tax !=
                                                  null &&
                                              dashBoardController
                                                  .fetchSpecificOrderData!.tax!
                                                  .any((taxItem) =>
                                                      taxItem.tax != null)
                                          ? formatAmount(
                                              '${((dashBoardController.fetchSpecificOrderData?.orderTotal ?? 0) + ((dashBoardController.fetchSpecificOrderData?.orderTotal ?? 0) * (dashBoardController.fetchSpecificOrderData?.tax?.fold(0.0, (sum, taxItem) {
                                                    return sum! +
                                                        (taxItem.tax
                                                                ?.toDouble() ??
                                                            0.0);
                                                  }) ?? 0) / 100))}',
                                            )
                                          : formatAmount(dashBoardController
                                                  .fetchSpecificOrderData
                                                  ?.orderTotal ??
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
                const SizedBox(height: 12),
                if (isButtonNeeded == true) ...[
                  CustomButton(text: 'Convert to Order', onPressed: () {}),
                ],
                // const SizedBox(height: 16),
                // const Text(
                //   'Currency  \$',
                //   style: TextStyle(color: Colors.grey, fontSize: 14),
                // ),
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
