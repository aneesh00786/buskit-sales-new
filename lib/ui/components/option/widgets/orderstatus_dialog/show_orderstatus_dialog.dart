// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/orderstatus_dialog/widgets/orderstatus_heading_row.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/orderstatus_dialog/widgets/orderstatus_total_row.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    ScrollController scrollController1,
    ScrollController scrollController2,
    ScrollController scrollController3) {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
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
                            return const SizedBox.shrink();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            final orders = snapshot.data?.data ?? [];
                            print('orderss:$orders');
                            // final filteredOrders = orders.toList();
                            // <<< NEW: filter by Order ID or Invoice ID >>>
                            final filteredOrders = orders.where((order) {
                              if (_search.isEmpty) return true;

                              final lower = _search.toLowerCase();

                              // 1. Search by Order ID
                              final matchesOrderId =
                                  order.orderId.toLowerCase().contains(lower);

                              // 2. Search by Invoice ID (if any invoice exists)
                              final matchesInvoiceId = order.invoice.isNotEmpty
                                  ? order.invoice[0].invoiceId
                                      .toLowerCase()
                                      .contains(lower)
                                  : false;

                              return matchesOrderId || matchesInvoiceId;
                            }).toList();

                            return LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                double availableWidth = constraints.maxWidth;
                                double fontSize = isPhonePortrait(context)
                                    ? 14
                                    : (availableWidth * 0.017).clamp(7.0, 15.0);
                                double padding = availableWidth / 100;
                                double fixedIconSize = fontSize;
                                double flexWidth = isPhonePortrait(context)
                                    ? availableWidth / 5
                                    : availableWidth / 10;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                                child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 17),
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
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: isPhonePortrait(context)
                                                    ? availableWidth - 40
                                                    : 320,
                                                child: TextField(
                                                  controller: _searchCtrl,
                                                  onChanged: (val) {
                                                    setState(
                                                        () => _search = val);
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Search Order ID or Invoice ID'.tr,
                                                    prefixIcon: const Icon(
                                                        Icons.search,
                                                        color: Colors.blue),

                                                    // Blue border (normal & focused)
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 1.5),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 2.0),
                                                    ),

                                                    filled: true,
                                                    fillColor: Colors.grey[50],

                                                    // Proper padding so text isn't stuck to edges
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 14,
                                                            vertical: 12),

                                                    // Clear button (suffix icon)
                                                    suffixIcon: _search
                                                            .isNotEmpty
                                                        ? IconButton(
                                                            icon: const Icon(
                                                                Icons.clear,
                                                                color: Colors
                                                                    .blue),
                                                            onPressed: () {
                                                              _searchCtrl
                                                                  .clear();
                                                              setState(() =>
                                                                  _search = '');
                                                            },
                                                          )
                                                        : null,
                                                  ),
                                                  style: TextStyle(
                                                      fontSize: fontSize),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        OrderStatusHeadingRow(
                                          fontSize: fontSize,
                                          flexWidth: flexWidth,
                                          scrollController2: scrollController2,
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: scrollController1,
                                          child: SizedBox(
                                            width: isPhonePortrait(context)
                                                ? fullScreenWidth(context) * 2.3
                                                : fullScreenWidth(context) > 640
                                                    ? fullScreenWidth(context) *
                                                        1
                                                    : fullScreenWidth(context) *
                                                        1.1,
                                            height: filteredOrders.length < 11
                                                ? isPhoneLandscape(context)
                                                    ? fullScreenHeight(
                                                            context) *
                                                        0.7
                                                    : null
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
                                                            ? 10
                                                            : 75,
                                                    headingRowColor:
                                                        const WidgetStatePropertyAll(
                                                            Colors.white),
                                                    columnSpacing: 10,
                                                    headingTextStyle: TextStyle(
                                                        fontSize: fontSize + 1,
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.w700),
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
                                                    rows: filteredOrders.isEmpty
                                                        ? [
                                                             DataRow(
                                                                cells: [
                                                                  DataCell(Text(
                                                                      'Record Not Found'.tr)),
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
                                                                        flexWidth *
                                                                            1.5,
                                                                    child: Row(
                                                                      children: [
                                                                        ClipOval(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                fixedIconSize * 2,
                                                                            width:
                                                                                fixedIconSize * 2,
                                                                            color:
                                                                                Colors.grey[200],
                                                                            child:
                                                                                Image.network(
                                                                              '${ApiConstants.baseUrl1}/uploads/${customer?.imageUrl}',
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
                                                                        SizedBox(
                                                                            width:
                                                                                padding),
                                                                        Flexible(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
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
                                                                        flexWidth *
                                                                            0.9,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        bool
                                                                            isOnline =
                                                                            await ConnectivityService().isOnline();
                                                                        if (isOnline) {
                                                                          showDetailedOrderInvoiceDialog(
                                                                              context,
                                                                              order.orderId,
                                                                              false);
                                                                        } else {
                                                                          showCustomToastDisplay(
                                                                              context,
                                                                              "You are Offline!".tr,
                                                                              red,
                                                                              Icons.warning);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          order
                                                                              .orderId,
                                                                          style: TextStyle(
                                                                              color: primaryColor,
                                                                              fontSize: fontSize,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            TimeUtils.formatTimeInZone(
                                                                              order.generatedAt ?? DateTime.now(),
                                                                              format: 'dd/MM/yyyy',
                                                                            ),
                                                                            // getFormattedOrderCreatAt(order.generatedAt.toString()),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: fontSize,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            TimeUtils.formatTimeInZone(
                                                                              order.generatedAt ?? DateTime.now(),
                                                                              format: 'hh:mm a',
                                                                            ),

                                                                            // NKDateUtils.commonTimeOnlyFormat(order.generatedAt!),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: fontSize,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              fontSize,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        formatAmount(
                                                                            order.orderTotal),
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              fontSize,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            0.9,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        if (order
                                                                            .invoice
                                                                            .isNotEmpty) {
                                                                          bool
                                                                              isOnline =
                                                                              await ConnectivityService().isOnline();
                                                                          if (isOnline) {
                                                                            showDialog(
                                                                              barrierDismissible: false,
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return InvoicePreview(orderId: order.orderId);
                                                                              },
                                                                            );
                                                                          } else {
                                                                            showCustomToastDisplay(
                                                                                context,
                                                                                "You are Offline!".tr,
                                                                                red,
                                                                                Icons.warning);
                                                                          }
                                                                        }
                                                                      },
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          order.invoice.isEmpty
                                                                              ? ''
                                                                              : order.invoice[0].invoiceId,
                                                                          style: TextStyle(
                                                                              color: primaryColor,
                                                                              fontSize: fontSize,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1.1,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: order.paymentStatus == 0
                                                                              ? Colors.red
                                                                              : Colors.green,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          border:
                                                                              Border.all(color: order.paymentStatus == 0 ? Colors.red : Colors.green),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              1.0),
                                                                          child: Icon(
                                                                              order.paymentStatus == 0 ? Icons.close : Icons.done,
                                                                              color: white,
                                                                              size: 14.0),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  SizedBox(
                                                                    width:
                                                                        flexWidth *
                                                                            1.2,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        clipBehavior:
                                                                            Clip.antiAlias,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              _orderStatusBadgeColor(order.orderStatus),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(15.0)),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 0.0,
                                                                              vertical: 0.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12.0),
                                                                                child: Text(
                                                                                  getStatusName(order.orderStatus).tr,
                                                                                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: _orderStatusTextColor(order.orderStatus)),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              if (order.orderStatus == 2 && order.deliveryDate != null) ...[
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                  child: Text(
                                                                                    order.deliveryDate != null
                                                                                        ? TimeUtils.formatTimeInZone(
                                                                                            order.deliveryDate!, 
                                                                                            format: 'dd-MM-yyyy hh:mm ',
                                                                                          )
                                                                                        : 'N/A',
                                                                                    textAlign: TextAlign.center,
                                                                                    maxLines: 2,
                                                                                    style: TextStyle(
                                                                                      fontSize: fontSize - 2,
                                                                                      fontWeight: FontWeight.w400,
                                                                                    ),
                                                                                  ),
                                                                                  // Text(
                                                                                  //   NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate!.toIso8601String())),
                                                                                  //   textAlign: TextAlign.center,
                                                                                  //   maxLines: 2,
                                                                                  //   style: TextStyle(
                                                                                  //     fontSize: fontSize - 2,
                                                                                  //     fontWeight: FontWeight.w400,
                                                                                  //   ),
                                                                                  // ),
                                                                                ),
                                                                              ],
                                                                              if (order.orderStatus == 14) ...[
                                                                                const SizedBox(height: 5),
                                                                                Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Container(
                                                                                          color: Colors.blue,
                                                                                          child:  Center(
                                                                                            child: Text(
                                                                                              'Quick Sale'.tr,
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
                                                                    Text('')),
                                                              ],
                                                            );
                                                          }).toList(),
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
                ),
            ],
          );
        },
      );
    },
  );
}
