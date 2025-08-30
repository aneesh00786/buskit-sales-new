// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/orderstatus_dialog/widgets/orderstatus_heading_row.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/orderstatus_dialog/widgets/orderstatus_total_row.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';

void showOrderStatusDialog(
    BuildContext context,
    DashboardProvider provider,
    OrderStatus selectedOrderStatus,
    ScrollController scrollController1,
    ScrollController scrollController2,
    ScrollController scrollController3) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<OrderResponse>(
                      future: provider.orderResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          final orders = snapshot.data?.data ?? [];

                          final filteredOrders = orders.toList();

                          return LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double availableWidth = constraints.maxWidth;
                              double fontSize =
                                  (availableWidth * 0.017).clamp(7.0, 15.0);
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;
                              double flexWidth = availableWidth / 10;

                              return Stack(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: scrollController1,
                                        child: ScrollbarTheme(
                                          data: const ScrollbarThemeData(
                                            minThumbLength: 150,
                                            thickness:
                                                WidgetStatePropertyAll(5),
                                            thumbColor: WidgetStatePropertyAll(
                                                Colors.blue),
                                          ),
                                          child: Scrollbar(
                                            thumbVisibility: true,
                                            trackVisibility: true,
                                            child: SizedBox(
                                              width: fullScreenWidth(context) >
                                                      640
                                                  ? fullScreenWidth(context) * 1
                                                  : fullScreenWidth(context) *
                                                      1.1,
                                              height: filteredOrders.length < 11
                                                  ? null
                                                  : fullScreenHeight(context) *
                                                      0.7,
                                              child: ScrollbarTheme(
                                                data: const ScrollbarThemeData(
                                                  minThumbLength: 150,
                                                  thickness:
                                                      WidgetStatePropertyAll(5),
                                                  thumbColor:
                                                      WidgetStatePropertyAll(
                                                          Colors.blue),
                                                ),
                                                child: Scrollbar(
                                                  thumbVisibility: true,
                                                  trackVisibility: true,
                                                  child: SingleChildScrollView(
                                                    child: DataTable(
                                                      dataRowHeight:
                                                          fontSize * 5.5,
                                                      headingRowHeight:
                                                          fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 45
                                                              : 75,
                                                      headingRowColor:
                                                          const WidgetStatePropertyAll(
                                                              primaryColor),
                                                      columnSpacing: 10,
                                                      headingTextStyle:
                                                          TextStyle(
                                                              fontSize:
                                                                  fontSize + 1,
                                                              color: white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                      columns: const [
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                        DataColumn(
                                                            label: SizedBox()),
                                                      ],
                                                      rows:
                                                          filteredOrders.isEmpty
                                                              ? [
                                                                  const DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Record Not Found')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text('')),
                                                                      ])
                                                                ]
                                                              : filteredOrders
                                                                  .map((order) {
                                                                  final customer = order
                                                                          .customer
                                                                          .isNotEmpty
                                                                      ? order
                                                                          .customer[0]
                                                                      : null;
                                                                  return DataRow(
                                                                    cells: [
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 1.5,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              ClipOval(
                                                                                child: Container(
                                                                                  height: fixedIconSize * 2,
                                                                                  width: fixedIconSize * 2,
                                                                                  color: Colors.grey[200],
                                                                                  child: Image.network(
                                                                                    'http://16.50.232.153:3000/uploads/${customer?.imageUrl}',
                                                                                    fit: BoxFit.cover,
                                                                                    errorBuilder: (context, error, stackTrace) {
                                                                                      return Container(
                                                                                        color: const Color(0xffe6ecff),
                                                                                        child: Icon(
                                                                                          Icons.person,
                                                                                          color: Colors.blue,
                                                                                          size: fixedIconSize * 2,
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: padding),
                                                                              Flexible(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(
                                                                                      customer != null ? customer.businessName : 'N/A',
                                                                                      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                    Text(
                                                                                      customer != null ? customer.mobileNo : 'N/A',
                                                                                      style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                    Text(
                                                                                      customer != null ? customer.email : 'N/A',
                                                                                      style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 0.9,
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              bool isOnline = await ConnectivityService().isOnline();
                                                                              if (isOnline) {
                                                                                showDetailedOrderInvoiceDialog(context, order.orderId, false);
                                                                              } else {
                                                                                showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                order.orderId,
                                                                                style: TextStyle(color: primaryColor, fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 1,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              // ignore: unnecessary_null_comparison
                                                                              order.orderCreatedAt != null ? getFormattedOrderCreatAt(order.orderCreatedAt.toString()) : 'N/A',
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 1,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                              ),
                                                                              maxLines: 2,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 1,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              formatAmount(order.orderTotal),
                                                                              maxLines: 1,
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 0.9,
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              if (order.invoice.isNotEmpty) {
                                                                                showInvoicePreviewOnline(
                                                                                  context,
                                                                                  order.orderId,
                                                                                );
                                                                              }
                                                                            },
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                order.invoice.isEmpty ? '' : order.invoice[0].invoiceId,
                                                                                style: TextStyle(color: primaryColor, fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 1.1,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(
                                                                                color: order.paymentStatus == 0 ? Colors.red : Colors.green,
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(color: order.paymentStatus == 0 ? Colors.red : Colors.green),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(1.0),
                                                                                child: Icon(order.paymentStatus == 0 ? Icons.close : Icons.done, color: white, size: 14.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 1.2,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Container(
                                                                              clipBehavior: Clip.antiAlias,
                                                                              decoration: const BoxDecoration(
                                                                                color: Color(0xffffdbb8),
                                                                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12.0),
                                                                                      child: Text(
                                                                                        getStatusName(order.orderStatus),
                                                                                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                                        textAlign: TextAlign.center,
                                                                                      ),
                                                                                    ),
                                                                                    if (order.orderStatus == 2 && order.deliveryDate != null) ...[
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                        child: Text(
                                                                                          NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate!.toIso8601String())),
                                                                                          textAlign: TextAlign.center,
                                                                                          maxLines: 2,
                                                                                          style: TextStyle(
                                                                                            fontSize: fontSize - 2,
                                                                                            fontWeight: FontWeight.w400,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                    if (order.orderStatus == 14) ...[
                                                                                      const SizedBox(height: 5),
                                                                                      Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Container(
                                                                                                color: Colors.blue,
                                                                                                child: const Center(
                                                                                                  child: Text(
                                                                                                    'Quick Sale',
                                                                                                    style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                                                  ),
                                                                                                )),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ]
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                    ],
                                                                  );
                                                                }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      OrderstatusTotalRow(
                                        fontSize: fontSize,
                                        flexWidth: flexWidth,
                                        filteredOrders: filteredOrders,
                                        scrollController3: scrollController3,
                                      ),
                                    ],
                                  ),
                                  OrderStatusHeadingRow(
                                    fontSize: fontSize,
                                    flexWidth: flexWidth,
                                    scrollController2: scrollController2,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: SizedBox(
                                      height: 45,
                                      width: 45,
                                      child: Center(
                                          child:
                                              dialogCloseButton1(context, red)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
