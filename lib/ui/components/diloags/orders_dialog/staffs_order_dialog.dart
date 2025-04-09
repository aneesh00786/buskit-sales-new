import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';

import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class StaffOrdersDialog extends StatefulWidget {
  final String heading;
  final List<OrderData> orderData;

  const StaffOrdersDialog({
    Key? key,
    required this.heading,
    required this.orderData,
  }) : super(key: key);

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
                                  headingRowColor:
                                      const WidgetStatePropertyAll(primaryColor),
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
                                          const DataRow(cells: [
                                            DataCell(Text('Record Not Found')),
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
                                                          height: fixedIconSize * 2,
                                                          width: fixedIconSize * 2,
                                                          color: Colors.grey[200],
                                                          child: Image.network(
                                                            'http://16.50.232.153:3000/uploads/${customer?.imageUrl}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                error, stackTrace) {
                                                              return Container(
                                                                color: const Color(
                                                                    0xffe6ecff),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color:
                                                                      Colors.blue,
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
                                                              overflow: TextOverflow
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
                                                                      fontSize - 2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              maxLines: 1,
                                                              overflow: TextOverflow
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
                                                                      fontSize - 2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              maxLines: 1,
                                                              overflow: TextOverflow
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
                                                    onTap: () {
                                                      showDetailedOrderInvoiceDialog(
                                                          context,
                                                          order.orderId ?? '',
                                                          false);
                                                    },
                                                    child: Center(
                                                      child: Text(
                                                        order.orderId ?? '',
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            fontSize: fontSize,
                                                            fontWeight:
                                                                FontWeight.w600),
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
                                                      // ignore: unnecessary_null_comparison
                                                      order.orderCreatAt != null
                                                          ? NKDateUtils.commonFullDateTimeFormat(
                                                                      NKDateUtils
                                                                          .formatStringUTCDateTime(
                                                                              order
                                                                                  .orderCreatAt??'')).replaceAll(" ", "\n")
                                                          : 'N/A',
                                                      style: TextStyle(
                                                        fontSize: fontSize,
                                                        
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign: TextAlign.center,
                                                    ),
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
                                                      showDetailedOrderInvoiceDialog(
                                                          context,
                                                          order.orderId ?? '',
                                                          true);
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
                                                                FontWeight.w600),
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
                                                            order.paymentStatus == 0
                                                                ? Colors.red
                                                                : Colors.green,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                order.paymentStatus ==
                                                                        0
                                                                    ? Colors.red
                                                                    : Colors.green),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                1.0),
                                                        child: Icon(
                                                            order.paymentStatus == 0
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
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color(0xffffdbb8),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15.0)),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets
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
                                                                      vertical: 6,
                                                                      horizontal:
                                                                          12.0),
                                                              child: Text(
                                                                getStatusName(order
                                                                        .orderStatus ??
                                                                    0),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                textAlign: TextAlign
                                                                    .center,
                                                              ),
                                                            ),
                                                            if (order.orderStatus ==
                                                                    2 &&
                                                                order.deliveryDatetime !=
                                                                    null) ...[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8.0),
                                                                child: Text(
                                                                  NKDateUtils.commonFullDateTimeFormat(
                                                                      NKDateUtils
                                                                          .formatStringUTCDateTime(
                                                                              order
                                                                                  .deliveryDatetime!)),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            if (order.orderStatus ==
                                                                14) ...[
                                                              const SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Container(
                                                                        color: Colors.blue,
                                                                        child: const Center(
                                                                          child:
                                                                              Text(
                                                                            'Quick Sale',
                                                                            style: TextStyle(
                                                                                color:
                                                                                    white,
                                                                                fontWeight:
                                                                                    FontWeight.bold,
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController3,
                            child: SizedBox(
                              width: fullScreenWidth(context) > 640
                                  ? fullScreenWidth(context) * 1
                                  : fullScreenWidth(context) * 1.1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DataTable(
                                        dataRowHeight: 0,
                                        headingRowHeight: 30,
                                        headingRowColor:
                                            const WidgetStatePropertyAll(
                                                primaryColor),
                                        columnSpacing: 10,
                                        columns: [
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1.5,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 0.9,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1,
                                            child:  Center(
                                              child: CustomText(
                                              content:  'Total',
                                              color: white,
                                              fontSize: fontSize,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1,
                                            child: Center(
                                              child: CustomText(
                                              content:   formatAmount(
                                                    filteredOrders.fold<double>(
                                                  0.0,
                                                  (sum, order) =>
                                                      sum +
                                                      (order.orderTotal ?? 0.0),
                                                )),
                                                color: white,
                                                fontSize: fontSize,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 0.9,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1.2,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          DataColumn(
                                              label: SizedBox(
                                            width: flexWidth * 1.2,
                                            child: const Center(
                                              child: Text(
                                                '',
                                                maxLines: 2,
                                              ),
                                            ),
                                          )),
                                          const DataColumn(
                                              label: Expanded(
                                            child: Center(
                                              child: Text(
                                                '',
                                              ),
                                            ),
                                          )),
                                        ],
                                        rows: [
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(width: flexWidth * 1.5),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 0.9),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 0.9),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1.1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1.1),
                                              ),
                                              const DataCell(Text('')),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController2,
                        child: SizedBox(
                          width: fullScreenWidth(context) > 640
                              ? fullScreenWidth(context) * 1
                              : fullScreenWidth(context) * 1.1,
                          child: Row(
                            children: [
                              Expanded(
                                child: DataTable(
                                    dataRowHeight: 0,
                                    headingRowHeight:
                                        fullScreenWidth(context) > 740 ? 45 : 75,
                                    headingRowColor:
                                        const WidgetStatePropertyAll(primaryColor),
                                    columnSpacing: 10,
                                    columns: [
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 1.5,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                             content:  'Customer List',
                                              color: white,
                                              fontSize: fontSize + 1,
                                              
                                            ),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 0.9,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                              content:'Order No.',
                                              color: white,
                                              fontSize: fontSize + 1,
                                            ),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                             content:  'Created',
                                             color: white,
                                             fontSize: fontSize + 1,
                                            ),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                             content:  'Amount',
                                              color: white,
                                              fontSize: fontSize + 1,
                                            ),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 0.9,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                             content:  'Invoice',
                                              color: white,
                                              fontSize: fontSize + 1,
                                            ),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 1.2,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                            content:  'Payment Status',
                                              color: white,
                                              fontSize: fontSize + 1,
                                            ),
                                          ),
                                        ),
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: flexWidth * 1.2,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: fullScreenWidth(context) > 740
                                                  ? 0
                                                  : 30),
                                          child:  Center(
                                            child: CustomText(
                                             content:  'Status',
                                              color: white,
                                              fontSize: fontSize + 1,
                                            ),
                                          ),
                                        ),
                                      )),
                                      const DataColumn(
                                          label: Expanded(
                                        child: Center(
                                          child: Text(
                                            '',
                                          ),
                                        ),
                                      )),
                                    ],
                                    rows: [
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(width: flexWidth * 1.5),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 0.9),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 0.9),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1.2),
                                          ),
                                          DataCell(
                                            SizedBox(width: flexWidth * 1.1),
                                          ),
                                          const DataCell(Text('')),
                                        ],
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: SizedBox(
                          height: 45,
                          width: 45,
                          child: Center(child: dialogCloseButton1(context, red)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTableHeader() {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: nkChildWrappedSizeBox(
            width: AppDimensions.instance!.width,
            child: DataTable(
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => primaryColor),
              headingRowHeight: 65,
              dataRowHeight: 65,
              columns: List.generate(
                  orderTableColumCategory.length,
                  (index) => index != orderTableColumCategory.length
                      ? DataColumn(
                          label: Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 30,
                                child: Center(
                                  child: MyRegularText(
                                    label: orderTableColumCategory[index],
                                    color: white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : DataColumn(
                          label: Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: dialogCloseButton1(context, red))))),
              rows: _generateRows(),
            ),
          ),
        ),
        Positioned(top: 0, right: 0, child: dialogCloseButton1(context, red))
      ],
    );
  }

  List<DataRow> _generateRows() {
    return widget.orderData.map(
      (order) {
        final cells = _buildOrderCells(order);
        return DataRow(
          cells: List.generate(cells.length, (index) => DataCell(cells[index])),
        );
      },
    ).toList();
  }

  List<Widget> _buildOrderCells(OrderData order) {
    final customerCart =
        order.cart?.isNotEmpty == true ? order.cart!.first : null;
    print(customerCart.toString());
    if (customerCart == null) {
      return List.generate(orderTableColumCategory.length,
          (index) => const SizedBox.shrink(child: Text('This data is NULL')));
    }
    return [
      _buildCustomerDetailsWidget(customerCart),
      _buildOrderNumberWidget(order),
      _buildOrderCreatedDateWidget(customerCart),
      _buildOrderPriceWidget(customerCart),
      if (widget.heading != 'bookings') ...[
        _buildOrderInvoiceWidget(order),
      ],
      if (widget.heading != 'bookings') ...[
        _buildPaymentStatusWidget(customerCart),
      ],
      _buildOrderStatusWidget(customerCart),
      const SizedBox.shrink(),
    ];
  }

  Widget _buildCustomerDetailsWidget(CustomerCart orderData) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        height: 60,
        width: AppDimensions.instance.width * 0.20,
        child: Row(
          children: [
            ClipOval(
              child: MyNetworkImage(
                imageUrl: orderData.customerDetails?.imageUrl ?? '',
                height: 25,
                width: 25,
              ),
            ),
            nkSmallSizeBox(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyRegularText(
                    label: orderData.customerDetails?.fullname ?? '',
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    maxlines: 1,
                  ),
                  MyRegularText(
                    label: orderData.customerDetails?.mobileno ?? '',
                    fontSize: 9,
                    overflow: TextOverflow.ellipsis,
                    maxlines: 1,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: MyRegularText(
                      align: TextAlign.start,
                      label: orderData.customerDetails?.email ?? '',
                      fontSize: 9,
                      overflow: TextOverflow.ellipsis,
                      maxlines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNumberWidget(OrderData orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: InkWell(
          onTap: () {
            showDetailedOrderInvoiceDialog(
                context, orderData.orderId.toString(), false);
          },
          child: MyRegularText(
            label: orderData.orderId ?? '',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCreatedDateWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyRegularText(
              label: NKDateUtils.commonDayFormat2(
                NKDateUtils.formatStringUTCDateTime(
                    orderData.optionOrderData!.orderCreatAt!),
              ),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
            MyRegularText(
              label: NKDateUtils.commonTimeFormat(
                NKDateUtils.formatStringUTCDateTime(
                    orderData.optionOrderData!.orderCreatAt!),
              ),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderPriceWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: MyRegularText(
          label: formatAmount(orderData.optionOrderData?.orderTotal),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOrderInvoiceWidget(OrderData orderData) {
    String invoiceId = orderData.invoice?.isNotEmpty ?? false
        ? orderData.invoice![0].invoiceId ?? ''
        : '';

    return SizedBox(
      height: 50,
      child: Center(
        child: InkWell(
          onTap: () {
            showDetailedOrderInvoiceDialog(
                context, orderData.orderId.toString(), true);
          },
          child: MyRegularText(
            label: invoiceId,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDBB8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: MyRegularText(
              label: OrderHandlingClass.fromType(
                      orderData.optionOrderData!.orderStatus!)
                  .name,
              fontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: orderData.optionOrderData!.paymentStatus == 0
                ? Colors.red
                : Colors.green,
            shape: BoxShape.circle,
            border: Border.all(
              color: orderData.optionOrderData!.paymentStatus == 0
                  ? Colors.red
                  : Colors.green,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Icon(
              orderData.optionOrderData!.paymentStatus == 0
                  ? Icons.close
                  : Icons.done,
              color: Colors.white,
              size: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        children: [
          MyNetworkImage(
            withoutBaseUrl: true,
            imageUrl:
                "https://i.ibb.co/r5kZLkw/bpnlauwze4-79c04e73-online-video-cutter-com-1-Adobe-Express.gif",
            height: AppDimensions.instance!.height * 0.5,
            width: AppDimensions.instance!.height * 0.5,
          ),
          MyRegularText(
            align: TextAlign.center,
            label: productNotAvailable,
            fontSize: NkFontSize.largeFont() + 5,
          ),
        ],
      ),
    );
  }
}
