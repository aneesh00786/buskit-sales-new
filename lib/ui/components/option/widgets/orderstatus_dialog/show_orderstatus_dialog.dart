// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

const TextStyle _headerStyle = TextStyle(
  fontFamily: 'Poppins_Regular',
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: Color(0xFF0F172A),
  letterSpacing: 0.3,
);

Widget _buildOrdersDialogHeader(BuildContext context) {
  return Container(
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
              child: const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white, size: 17),
            ),
            const SizedBox(width: 10),
            Text(
              'Orders'.tr,
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
  );
}

Color _orderStatusBadgeColor(int? orderStatus) {
  switch (orderStatus) {
    case 2:
      return const Color(0xFFDCFCE7);
    case 7:
      return const Color(0xFFFEF3C7);
    case 0:
      return const Color(0xFFDBEAFE);
    case 4:
      return const Color(0xFFF1F5F9);
    case 3:
      return const Color(0xFFFEE2E2);
    default:
      return const Color(0xffffdbb8);
  }
}

Color _orderStatusTextColor(int? orderStatus) {
  switch (orderStatus) {
    case 2:
      return const Color(0xFF064E3B);
    case 7:
      return const Color(0xFF78350F);
    case 0:
      return const Color(0xFF1E3A8A);
    case 4:
      return const Color(0xFF0F172A);
    case 3:
      return const Color(0xFF7F1D1D);
    default:
      return Colors.black;
  }
}

void showOrderStatusDialog(
  BuildContext context,
  DashboardProvider provider,
  OrderStatus selectedOrderStatus,
) {
  final TextEditingController searchCtrl = TextEditingController();
  String search = '';
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FutureBuilder<OrderResponse>(
                        future: provider.orderResponse,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildOrdersDialogHeader(context),
                                Container(
                                  height: 180,
                                  alignment: Alignment.center,
                                  child: const SpinKitThreeBounce(
                                      color: primaryColor, size: 26),
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildOrdersDialogHeader(context),
                                Center(
                                  child: Text('Error: ${snapshot.error}'),
                                ),
                              ],
                            );
                          }

                          final orders = snapshot.data?.data ?? [];
                          final filteredOrders = orders.where((order) {
                            if (search.isEmpty) return true;
                            final lower = search.toLowerCase();
                            final matchesOrderId =
                                order.orderId.toLowerCase().contains(lower);
                            final matchesInvoiceId =
                                order.invoice.isNotEmpty
                                    ? order.invoice[0].invoiceId
                                        .toLowerCase()
                                        .contains(lower)
                                    : false;
                            return matchesOrderId || matchesInvoiceId;
                          }).toList();

                          final double overallTotal =
                              filteredOrders.fold<double>(
                            0.0,
                            (sum, order) => sum + (order.orderTotal ?? 0.0),
                          );

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildOrdersDialogHeader(context),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: isPhonePortrait(context)
                                          ? double.infinity
                                          : 320,
                                      child: TextField(
                                        controller: searchCtrl,
                                        onChanged: (val) =>
                                            setState(() => search = val),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search Order ID or Invoice ID'
                                                  .tr,
                                          prefixIcon: const Icon(Icons.search,
                                              color: Colors.blue),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.blue,
                                                width: 1.5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.blue,
                                                width: 2.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 12),
                                          suffixIcon: search.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons.clear,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    searchCtrl.clear();
                                                    setState(
                                                        () => search = '');
                                                  },
                                                )
                                              : null,
                                        ),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (filteredOrders.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 40),
                                  child: Center(
                                    child: Text(
                                      'Record Not Found'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Flexible(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double fontSize =
                                          isPhonePortrait(context)
                                              ? 12.5
                                              : 13.0;
                                      return ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor:
                                              WidgetStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    WidgetState.dragged)
                                                ? primaryColor
                                                : primaryColor
                                                    .withOpacity(0.55),
                                          ),
                                          trackColor: WidgetStateProperty.all(
                                              primaryColor.withOpacity(0.06)),
                                          trackBorderColor:
                                              WidgetStateProperty.all(
                                                  primaryColor
                                                      .withOpacity(0.18)),
                                          radius: const Radius.circular(10),
                                          thickness:
                                              WidgetStateProperty.all(8),
                                          minThumbLength: 60,
                                          crossAxisMargin: 2,
                                          mainAxisMargin: 2,
                                        ),
                                        child: Scrollbar(
                                        controller: verticalScrollController,
                                        thumbVisibility: true,
                                        trackVisibility: true,
                                        notificationPredicate: (notif) =>
                                            notif.metrics.axis ==
                                            Axis.vertical,
                                        child: Scrollbar(
                                          controller:
                                              horizontalScrollController,
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          notificationPredicate: (notif) =>
                                              notif.metrics.axis ==
                                              Axis.horizontal,
                                          child: SingleChildScrollView(
                                            controller:
                                                verticalScrollController,
                                            scrollDirection: Axis.vertical,
                                            child: SingleChildScrollView(
                                              controller:
                                                  horizontalScrollController,
                                              scrollDirection:
                                                  Axis.horizontal,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minWidth:
                                                        constraints.maxWidth),
                                                child: DataTable(
                                                  headingRowColor:
                                                      WidgetStateProperty.all(
                                                          const Color(
                                                              0xFFF1F5F9)),
                                                  headingTextStyle:
                                                      _headerStyle,
                                                  dataRowMinHeight: 58,
                                                  dataRowMaxHeight: 82,
                                                  columnSpacing: 14,
                                                  horizontalMargin: 16,
                                                  columns: [
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Customer'
                                                                    .tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Order No.'
                                                                    .tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Created'.tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Created By'
                                                                    .tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Amount'.tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Invoice'.tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Payment Status'
                                                                    .tr,
                                                                style:
                                                                    _headerStyle))),
                                                    DataColumn(
                                                        headingRowAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        label: Center(
                                                            child: Text(
                                                                'Status'.tr,
                                                                style:
                                                                    _headerStyle))),
                                                  ],
                                                  rows:
                                                      filteredOrders.map((order) {
                                                    final customer = order
                                                            .customer
                                                            .isNotEmpty
                                                        ? order.customer[0]
                                                        : null;
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                          SizedBox(
                                                            width: 210,
                                                            child: Row(
                                                              children: [
                                                                ClipOval(
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30,
                                                                    width: 30,
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                    child:
                                                                        Image
                                                                            .network(
                                                                      '${ApiConstants.baseUrl1}/uploads/${customer?.imageUrl}',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder:
                                                                          (context,
                                                                              error,
                                                                              stackTrace) {
                                                                        return Container(
                                                                          color:
                                                                              const Color(0xffe6ecff),
                                                                          child:
                                                                              const Icon(
                                                                            Icons.person,
                                                                            color:
                                                                                Colors.blue,
                                                                            size:
                                                                                18,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Expanded(
                                                                  child:
                                                                      Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        customer !=
                                                                                null
                                                                            ? customer.businessName
                                                                            : 'N/A',
                                                                        style: TextStyle(
                                                                            fontSize: fontSize,
                                                                            fontWeight: FontWeight.bold),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      Text(
                                                                        customer !=
                                                                                null
                                                                            ? customer.mobileNo
                                                                            : 'N/A',
                                                                        style: TextStyle(
                                                                            fontSize: fontSize - 1,
                                                                            fontWeight: FontWeight.w400),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      Text(
                                                                        customer !=
                                                                                null
                                                                            ? customer.email
                                                                            : 'N/A',
                                                                        style: TextStyle(
                                                                            fontSize: fontSize - 1,
                                                                            fontWeight: FontWeight.w400),
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          InkWell(
                                                            onTap: () async {
                                                              bool isOnline =
                                                                  await ConnectivityService()
                                                                      .isOnline();
                                                              if (isOnline) {
                                                                showDetailedOrderInvoiceDialog(
                                                                    context,
                                                                    order
                                                                        .orderId,
                                                                    false);
                                                              } else {
                                                                showCustomToastDisplay(
                                                                    context,
                                                                    "You are Offline!"
                                                                        .tr,
                                                                    red,
                                                                    Icons
                                                                        .warning);
                                                              }
                                                            },
                                                            child: Text(
                                                              order.orderId,
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontSize:
                                                                      fontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                TimeUtils
                                                                    .formatTimeInZone(
                                                                  order.generatedAt ??
                                                                      DateTime
                                                                          .now(),
                                                                  format:
                                                                      'dd/MM/yyyy',
                                                                ),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                TimeUtils
                                                                    .formatTimeInZone(
                                                                  order.generatedAt ??
                                                                      DateTime
                                                                          .now(),
                                                                  format:
                                                                      'hh:mm a',
                                                                ),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        fontSize -
                                                                            1,
                                                                    color: Colors
                                                                        .black54),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          SizedBox(
                                                            width: 130,
                                                            child: Text(
                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                              style:
                                                                  TextStyle(
                                                                fontSize:
                                                                    fontSize,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            formatAmount(order
                                                                .orderTotal),
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  fontSize,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          InkWell(
                                                            onTap: () async {
                                                              if (order
                                                                  .invoice
                                                                  .isNotEmpty) {
                                                                bool isOnline =
                                                                    await ConnectivityService()
                                                                        .isOnline();
                                                                if (isOnline) {
                                                                  showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return InvoicePreview(
                                                                          orderId:
                                                                              order.orderId);
                                                                    },
                                                                  );
                                                                } else {
                                                                  showCustomToastDisplay(
                                                                      context,
                                                                      "You are Offline!"
                                                                          .tr,
                                                                      red,
                                                                      Icons
                                                                          .warning);
                                                                }
                                                              }
                                                            },
                                                            child: Text(
                                                              order.invoice
                                                                      .isEmpty
                                                                  ? ''
                                                                  : order
                                                                      .invoice[
                                                                          0]
                                                                      .invoiceId,
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontSize:
                                                                      fontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: order
                                                                          .paymentStatus ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: order.paymentStatus ==
                                                                          0
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      4.0),
                                                              child: Icon(
                                                                  order.paymentStatus ==
                                                                          0
                                                                      ? Icons
                                                                          .close
                                                                      : Icons
                                                                          .done,
                                                                  color:
                                                                      white,
                                                                  size: 14.0),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: _orderStatusBadgeColor(
                                                                  order
                                                                      .orderStatus),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            2,
                                                                        horizontal:
                                                                            12.0),
                                                                    child:
                                                                        Text(
                                                                      getStatusName(
                                                                              order.orderStatus)
                                                                          .tr,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              fontSize,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              _orderStatusTextColor(order.orderStatus)),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  if (order.orderStatus ==
                                                                          2 &&
                                                                      order.deliveryDate !=
                                                                          null) ...[
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        order.deliveryDate !=
                                                                                null
                                                                            ? TimeUtils.formatTimeInZone(
                                                                                order.deliveryDate!,
                                                                                format: 'dd-MM-yyyy hh:mm ',
                                                                              )
                                                                            : 'N/A',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            fontSize: fontSize - 2,
                                                                            fontWeight: FontWeight.w400),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  if (order
                                                                          .orderStatus ==
                                                                      14) ...[
                                                                    const SizedBox(
                                                                        height:
                                                                            5),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              2),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color:
                                                                            Colors.blue,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        'Quick Sale'
                                                                            .tr,
                                                                        style: const TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 10),
                                                                      ),
                                                                    ),
                                                                  ]
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (filteredOrders.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    border: Border(
                                        top: BorderSide(
                                            color: Color(0xFFCBD5E1))),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Showing'.tr} ${filteredOrders.length} ${'Orders'.tr} ${'Records'.tr}',
                                        style: const TextStyle(
                                            fontFamily: 'Poppins_Regular',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: primaryColor
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${'Total'.tr}: ',
                                              style: const TextStyle(
                                                  fontFamily:
                                                      'Poppins_Regular',
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              formatAmount(overallTotal),
                                              style: const TextStyle(
                                                  fontFamily:
                                                      'Poppins_Regular',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: primaryColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
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
