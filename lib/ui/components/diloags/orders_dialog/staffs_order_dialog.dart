// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/orders_dialog/widgets/staff_orders_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/orders_dialog/widgets/staff_orders_tablerow.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';

import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class StaffOrdersDialog extends StatefulWidget {
  final String heading;
  final List<OrderData> orderData;

  const StaffOrdersDialog({
    super.key,
    required this.heading,
    required this.orderData,
  });

  @override
  State<StaffOrdersDialog> createState() => _StaffOrdersDialogState();
}

class _StaffOrdersDialogState extends State<StaffOrdersDialog> {
  final StaffController staffController = StaffController();
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  RxList<String> orderTableColumCategory = [
    "Customer List",
    "Order Number",
    "Order Created",
    "Order Price",
    "Invoice",
    "Payment Status",
    "Status",
    "",
  ].obs;

  @override
  void initState() {
    staffController.loadOrderData;
    super.initState();
    if (widget.heading == 'bookings') {
      orderTableColumCategory.value = [
        "Customer List",
        "Order Number",
        "Order Created",
        "Order Price",
        "Status",
        "",
      ];
    }
    _scrollController1.addListener(() {
      final position = _scrollController1.position.pixels;
      if (_scrollController2.hasClients &&
          _scrollController2.position.pixels != position) {
        _scrollController2.jumpTo(position);
      }
      if (_scrollController3.hasClients &&
          _scrollController3.position.pixels != position) {
        _scrollController3.jumpTo(position);
      }
    });
    _scrollController2.addListener(() {
      final position = _scrollController2.position.pixels;
      if (_scrollController1.hasClients &&
          _scrollController1.position.pixels != position) {
        _scrollController1.jumpTo(position);
      }
      if (_scrollController3.hasClients &&
          _scrollController3.position.pixels != position) {
        _scrollController3.jumpTo(position);
      }
    });
    _scrollController3.addListener(() {
      final position = _scrollController3.position.pixels;
      if (_scrollController1.hasClients &&
          _scrollController1.position.pixels != position) {
        _scrollController1.jumpTo(position);
      }
      if (_scrollController2.hasClients &&
          _scrollController2.position.pixels != position) {
        _scrollController2.jumpTo(position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Gradient Header Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF2D3748)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.heading.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins_Regular',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Table Content
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                  double availableWidth = constraints.maxWidth;
                  double fontSize = (availableWidth * 0.017).clamp(7.0, 15.0);
                  double padding = availableWidth / 100;
                  double fixedIconSize = fontSize;
                  double flexWidth = availableWidth / 10;
                  final filteredOrders = widget.orderData;
                  return Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController1,
                            child: SizedBox(
                              width: fullScreenWidth(context) > 640
                                  ? fullScreenWidth(context) * 1
                                  : fullScreenWidth(context) * 1.1,
                              height: filteredOrders.length < 11
                                  ? null
                                  : fullScreenHeight(context) * 0.7,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  dataRowHeight: fontSize * 5.5,
                                  headingRowHeight:
                                      fullScreenWidth(context) > 740 ? 45 : 75,
                                  headingRowColor: const WidgetStatePropertyAll(
                                      Color(0xFFF1F5F9)),
                                  columnSpacing: 10,
                                  headingTextStyle: TextStyle(
                                      fontSize: fontSize + 1,
                                      color: white,
                                      fontWeight: FontWeight.w700),
                                  columns: const [
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                    DataColumn(label: SizedBox()),
                                  ],
                                  rows: filteredOrders.isEmpty
                                      ? [
                                           DataRow(cells: [
                                            DataCell(Text('Record Not Found'.tr)),
                                            DataCell(Text('')),
                                            DataCell(Text('')),
                                            DataCell(Text('')),
                                            DataCell(Text('')),
                                            DataCell(Text('')),
                                            DataCell(Text('')),
                                            DataCell(Text('')),
                                          ])
                                        ]
                                      : filteredOrders.map((order) {
                                          final customer =
                                              order.customer!.isNotEmpty
                                                  ? order.customer![0]
                                                  : null;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width: flexWidth * 1.5,
                                                  child: Row(
                                                    children: [
                                                      ClipOval(
                                                        child: Container(
                                                          height:
                                                              fixedIconSize * 2,
                                                          width:
                                                              fixedIconSize * 2,
                                                          color:
                                                              Colors.grey[200],
                                                          child: Image.network(
                                                            'http://16.50.232.153:3000/uploads/${customer?.imageUrl}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                color: const Color(
                                                                    0xffe6ecff),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .blue,
                                                                  size:
                                                                      fixedIconSize *
                                                                          2,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: padding),
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              customer != null
                                                                  ? customer
                                                                      .businessName!
                                                                  : 'N/A',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      fontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              customer != null
                                                                  ? customer
                                                                          .mobileno ??
                                                                      ''
                                                                  : 'N/A',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      fontSize -
                                                                          2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              customer != null
                                                                  ? customer
                                                                          .email ??
                                                                      ''
                                                                  : 'N/A',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      fontSize -
                                                                          2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                                  width: flexWidth * 0.9,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      bool isOnline =
                                                          await ConnectivityService()
                                                              .isOnline();
                                                      if (isOnline) {
                                                        showDetailedOrderInvoiceDialog(
                                                            context,
                                                            order.orderId ?? '',
                                                            false);
                                                      } else {
                                                        showCustomToastDisplay(
                                                            context,
                                                            "You are Offline!",
                                                            red,
                                                            Icons.warning);
                                                      }
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        order.orderId ?? '',
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            fontSize: fontSize,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: flexWidth * 1,
                                                  child: Center(
                                                    child: Text(
                                                      order.orderCreatAt !=
                                                                  null &&
                                                              order.orderCreatAt
                                                                  .toString()
                                                                  .isNotEmpty
                                                          ? TimeUtils
                                                              .formatTimeInZone(
                                                              DateTime.parse(order
                                                                  .orderCreatAt
                                                                  .toString()),
                                                              // Notice the \n right in the middle instead of a space!
                                                              format:
                                                                  'dd/MM/yyyy\nhh:mm a',
                                                            )
                                                          : 'N/A',
                                                      style: TextStyle(
                                                        fontSize: fontSize,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    //  Text(
                                                    //   // ignore: unnecessary_null_comparison
                                                    //   order.orderCreatAt != null
                                                    //       ? NKDateUtils.commonFullDateTimeFormat(
                                                    //               NKDateUtils
                                                    //                   .formatStringUTCDateTime(
                                                    //                       order.orderCreatAt ??
                                                    //                           ''))
                                                    //           .replaceAll(
                                                    //               " ", "\n")
                                                    //       : 'N/A',
                                                    //   style: TextStyle(
                                                    //     fontSize: fontSize,
                                                    //   ),
                                                    //   maxLines: 2,
                                                    //   overflow:
                                                    //       TextOverflow.ellipsis,
                                                    //   textAlign:
                                                    //       TextAlign.center,
                                                    // ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: flexWidth * 1,
                                                  child: Center(
                                                    child: Text(
                                                      formatAmount(
                                                          order.orderTotal),
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
                                                  width: flexWidth * 0.9,
                                                  child: InkWell(
                                                    onTap: () {
                                                      showInvoicePreviewOnline(
                                                        context,
                                                        order.orderId ?? '',
                                                      );
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        order.invoice!.isEmpty
                                                            ? ''
                                                            : order.invoice![0]
                                                                    .invoiceId ??
                                                                '',
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            fontSize: fontSize,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: flexWidth * 1.2,
                                                  child: Center(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            order.paymentStatus ==
                                                                    0
                                                                ? Colors.red
                                                                : Colors.green,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                order.paymentStatus ==
                                                                        0
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Icon(
                                                            order.paymentStatus ==
                                                                    0
                                                                ? Icons.close
                                                                : Icons.done,
                                                            color: white,
                                                            size: 14.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: flexWidth * 1.2,
                                                  child: Center(
                                                    child: Container(
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0xffffdbb8),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15.0)),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0.0,
                                                                vertical: 0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          6,
                                                                      horizontal:
                                                                          12.0),
                                                              child: Text(
                                                                getStatusName(
                                                                    order.orderStatus ??
                                                                        0).tr,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            if (order.orderStatus ==
                                                                    2 &&
                                                                order.deliveryDatetime !=
                                                                    null) ...[
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                                child: Text(
                                                                  order.deliveryDatetime !=
                                                                              null &&
                                                                          order
                                                                              .deliveryDatetime
                                                                              .toString()
                                                                              .isNotEmpty
                                                                      ? TimeUtils
                                                                          .formatTimeInZone(
                                                                          // Assuming it's a string. If it's already a DateTime, just pass order.deliveryDatetime!
                                                                          DateTime.parse(order
                                                                              .deliveryDatetime
                                                                              .toString()),
                                                                          format:
                                                                              'dd/MM/yyyy\nhh:mm a',
                                                                        )
                                                                      : 'N/A',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                // Text(
                                                                //   NKDateUtils.commonFullDateTimeFormat(
                                                                //       NKDateUtils
                                                                //           .formatStringUTCDateTime(
                                                                //               order.deliveryDatetime!)),
                                                                //   textAlign:
                                                                //       TextAlign
                                                                //           .center,
                                                                //   maxLines: 2,
                                                                //   style:
                                                                //       TextStyle(
                                                                //     fontSize:
                                                                //         fontSize -
                                                                //             2,
                                                                //     fontWeight:
                                                                //         FontWeight
                                                                //             .w400,
                                                                //   ),
                                                                // ),
                                                              ),
                                                            ],
                                                            if (order
                                                                    .orderStatus ==
                                                                14) ...[
                                                              const SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Container(
                                                                        color: Colors.blue,
                                                                        child:  Center(
                                                                          child:
                                                                              Text(
                                                                            'Quick Sale'.tr,
                                                                            style: TextStyle(
                                                                                color: white,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 10),
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
                                              const DataCell(Text('')),
                                            ],
                                          );
                                        }).toList(),
                                ),
                              ),
                            ),
                          ),
                          StaffOrdersBottomWidget(
                              scrollController3: _scrollController3,
                              flexWidth: flexWidth,
                              fontSize: fontSize,
                              filteredOrders: filteredOrders),
                        ],
                      ),
                      StaffOrdersTableRow(
                          scrollController2: _scrollController2,
                          flexWidth: flexWidth,
                          fontSize: fontSize),
                      const SizedBox.shrink(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
