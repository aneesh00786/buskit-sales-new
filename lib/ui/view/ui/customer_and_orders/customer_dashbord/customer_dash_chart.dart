import 'dart:developer';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/option_dialogues/orders_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/customer_order_status_dialogue.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class OptionWidgetCustomerDash extends StatelessWidget {
  final String customerId;
  final UserType userType;
  final String userId;
  final (String, VoidCallback) Function(int index, OrderStatus orderStatus)?
      optionFun;
  final String? customType;
  final bool? isVisible;
  final OrderStatus? customOrderStatusType;
  final String? startDate;
  final String? endDate;
  final ProductsController? productsController;
  final VoidCallback onContinueShopping;

   OptionWidgetCustomerDash({
    super.key,
    required this.customerId,
    this.optionFun,
    required this.userType,
    required this.userId,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    this.productsController,
    required this.onContinueShopping,
    this.isVisible = false,
  });
    CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.countFuture == null) {
            provider.fetchCustomerDashboardCountData(
              customerId,
            );
          }
        });

        return FutureBuilder<ApiResponsees>(
          future: provider.countFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCube(
                  color: primaryColor,
                  size: 20.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              final chatData = snapshot.data!.data;
              return options(chatData, context, provider);
            } else {
              return const NodataWidget();
            }
          },
        );
      },
    );
  }

  Widget options(OrderDataas orderCountList, BuildContext context,
      CustomersProvider provider) {
    return Row(
      children: _defaultOption(context, provider, orderCountList)
          .map((e) => orderOptions(e, orderCountList, context))
          .toList(),
    );
  }

  List<OptionData> _defaultOption(BuildContext context,
          CustomersProvider provider, OrderDataas orderCountList) =>
      [
        OptionData(
          title: 'Order',
          count: orderCountList.totalOrder.toString(),
          svg: Assets.iconsIcDashboardShoppingCart,
          svgBgColor: const Color.fromARGB(255, 229, 242, 254),
          color: const Color.fromARGB(255, 55, 74, 134),
          onTap: () {
            provider.fetchOrdersForCustomDash(
              OrderStatus.delivered,
              customerId,
            );
            _showOrderStatusDialog(context, provider, OrderStatus.delivered);
          },
        ),
        OptionData(
          title: 'Estimate',
          count: orderCountList.estimateOrder.toString(),
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color.fromARGB(255, 226, 249, 243),
          color: const Color.fromARGB(255, 36, 108, 44),
          onTap: () {
            provider.fetchOrdersForCustomDash(
              OrderStatus.estimates,
              customerId,
            );
            _showOrderTypeDialog(
                context, provider, OrderStatus.estimates, 'Estimate');
          },
        ),
        OptionData(
          title: 'Booking',
          count: orderCountList.preorderOrder.toString(),
          svg: Assets.iconsIcDashboardPreOrder,
          svgBgColor: const Color.fromARGB(255, 230, 247, 251),
          color: const Color.fromARGB(255, 45, 104, 116),
          onTap: () {
            provider.fetchOrdersForCustomDash(
              OrderStatus.preOrder,
              customerId,
            );
            _showOrderTypeDialog(
                context, provider, OrderStatus.preOrder, 'Booking');
          },
        ),
        OptionData(
          title: 'Draft',
          count: orderCountList.draftOrder.toString(),
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color.fromARGB(255, 255, 227, 255),
          color: const Color.fromARGB(255, 100, 43, 109),
          onTap: () {
            provider.fetchOrdersForCustomDash(
              OrderStatus.draft,
              customerId,
            );
            _showOrderTypeDialog(context, provider, OrderStatus.draft, 'Draft',
                onContinueShopping: onContinueShopping);
            CartDatabaseManager().getDraftItems();
          },
        ),
        OptionData(
          title: 'Cancelled',
          count: orderCountList.cancelOrder.toString(),
          svg: Assets.iconsIcDashboardCancel,
          svgBgColor: const Color.fromARGB(255, 255, 228, 228),
          color: const Color.fromARGB(255, 139, 27, 27),
          onTap: () {
            provider.fetchOrdersForCustomDash(
              OrderStatus.cancelled,
              customerId,
            );
            _showOrderTypeDialog(
                context, provider, OrderStatus.cancelled, 'Cancelled');
          },
        ),
      ];

  Widget orderOptions(
      OptionData optionData, OrderDataas orderCountList, BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance.height * 0.03,
      fit: BoxFit.contain,
    );

    return Flexible(
      child: MyCommnonContainer(
        color: white,
        onTap: optionData.onTap,
        margin: nkSymmetricPadding(
          vertical: 0,
          horizontal: AppDimensions.instance!.width * 0.001,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: 20,
        padding: nkLargePadding(),
        isCommonBorder: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: optionData.svgBgColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: svgComponent,
                ),
              ),
              Flexible(
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    CustomText(
                      content: optionData.title,
                      fontSize: (MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                          ? (ResponsiveInfo.isMobileDimension(context)
                              ? 4.9
                              : 13)
                          : (ResponsiveInfo.isMobileDimension(context)
                              ? 7
                              : 13),
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                      //maxLines: optionData.title.length,
                    ),
                    CustomText(
                      content:
                          _getCountForTitle(optionData.title, orderCountList),
                      fontSize: ResponsiveInfo.isMobileDimension(context)
                          ? 7.7
                          : 15.3,
                      fontWeight: FontWeight.w600,
                      color: optionData.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountForTitle(String title, OrderDataas orderCountList) {
    switch (title.toLowerCase()) {
      case 'order':
        return orderCountList.totalOrder.toString() ?? "0";
      case 'estimate':
        return orderCountList.estimateOrder.toString() ?? "0";
      case 'booking':
        return orderCountList.preorderOrder.toString() ?? "0";
      case 'draft':
        return orderCountList.draftOrder.toString() ?? "0";
      case 'cancelled':
        return orderCountList.cancelOrder.toString() ?? "0";
      default:
        return "0";
    }
  }

  String getOrderStatusString(OrderStatus status) {
    switch (status) {
      case OrderStatus.preOrder:
        return 'Pre Order';
      case OrderStatus.outOfDelivery:
        return 'Out For Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.estimates:
        return 'Estimates';

      default:
        throw Exception('Unsupported order status: $status');
    }
  }

  String getOrderStatusName(int orderStatus) {
    switch (orderStatus) {
      case 0:
        return 'Pre Order';
      case 1:
        return 'Out For Delivery';
      case 2:
        return 'Delivered';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Draft';
      case 5:
        return 'Processing';
      case 6:
        return 'Pending';
      case 7:
        return 'Estimates';
      case 8:
        return 'Accept By Admin';
      case 9:
        return 'Reject By Admin';
      case 10:
        return 'Packed For Delivery';
      default:
        return '';
    }
  }

  void _showOrderStatusDialog(BuildContext context, CustomersProvider provider,
      OrderStatus selectedOrderStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                              // double fontSize = 14.0;
                              double fontSize = availableWidth * 0.017;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;
                              double flexWidth = availableWidth / 10;

                              return Stack(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: filteredOrders.length < 11
                                        ? null
                                        : fullScreenHeight(context) * 0.7,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        dataRowHeight: fontSize * 5.5,
                                        headingRowHeight: 45,
                                        headingRowColor:
                                            const WidgetStatePropertyAll(
                                                primaryColor),
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
                                          DataColumn(label: SizedBox()),
                                        ],
                                        rows: filteredOrders.isEmpty
                                            ? [
                                                const DataRow(cells: [
                                                  DataCell(
                                                      Text('Record Not Found')),
                                                  DataCell(Text('')),
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
                                                    order.customer.isNotEmpty
                                                        ? order.customer[0]
                                                        : null;
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 1.5,
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius:
                                                                  (fixedIconSize /
                                                                          2) +
                                                                      2,
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xffe6ecff),
                                                              child: Icon(
                                                                  Icons.person,
                                                                  size:
                                                                      fixedIconSize,
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                            SizedBox(
                                                                width: padding),
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
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .fullName
                                                                        : 'N/A',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            fontSize -
                                                                                2,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .mobileNo
                                                                        : 'N/A',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            fontSize -
                                                                                2,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .email
                                                                        : 'N/A',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            fontSize -
                                                                                2,
                                                                        fontWeight:
                                                                            FontWeight.w400),
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
                                                          onTap: () {
                                                            showDetailedOrderInvoiceDialog(
                                                                context,
                                                                order.orderId??'',
                                                                false);
                                                          },
                                                          child: Center(
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
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 1,
                                                        child: Center(
                                                          child: Text(
                                                            order.orderCreatedAt !=
                                                                    null
                                                                ? getFormattedOrderCreatAt(order
                                                                    .orderCreatedAt
                                                                    .toString())
                                                                : 'N/A',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  fontSize,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 1,
                                                        child: Center(
                                                          child: Text(
                                                            '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  fontSize,
                                                            ),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 1,
                                                        child: Center(
                                                          child: Text(
                                                            formatAmount(order
                                                                .orderTotal),
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  fontSize,
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
                                                                order.orderId??'',
                                                                true);
                                                          },
                                                          child: Center(
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
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 1.1,
                                                        child: Center(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: order.paymentStatus ==
                                                                      0
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: order
                                                                              .paymentStatus ==
                                                                          0
                                                                      ? Colors
                                                                          .red
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
                                                                      ? Icons
                                                                          .close
                                                                      : Icons
                                                                          .done,
                                                                  color: white,
                                                                  size: 14.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 1.1,
                                                        child: Center(
                                                          child: Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Color(
                                                                  0xffffdbb8),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          15.0)),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0,
                                                                      vertical:
                                                                          4.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    getStatusName(
                                                                        order
                                                                            .orderStatus),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            fontSize,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  if (order.orderStatus ==
                                                                          2 &&
                                                                      order.deliveryDate !=
                                                                          null) ...[
                                                                    Text(
                                                                      NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order
                                                                          .deliveryDate!
                                                                          .toIso8601String())),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          2,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            fontSize -
                                                                                2,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ),
                                                                    ),
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                            dataRowHeight: fontSize * 5.5,
                                            headingRowHeight: 45,
                                            headingRowColor:
                                                const WidgetStatePropertyAll(
                                                    primaryColor),
                                            columnSpacing: 10,
                                            headingTextStyle: TextStyle(
                                                fontSize: fontSize + 1,
                                                color: white,
                                                fontWeight: FontWeight.w700),
                                            columns: const [
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Customer List',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Order No.',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Created',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Created By',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Amount',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Invoice',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Payment Status',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Status',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
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
                                                    SizedBox(
                                                        width: flexWidth * 1.5),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 0.9),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 0.9),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1.1),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                        width: flexWidth * 1.1),
                                                  ),
                                                  const DataCell(Text('')),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ],
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
        });
      },
    );
  }

  void _showOrderTypeDialog(BuildContext context, CustomersProvider provider,
      OrderStatus selectedOrderStatus, String orderType,{VoidCallback? onContinueShopping}) {
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
                            return noDataFoundWidget(orderType);
                          } else {
                            final orders = snapshot.data?.data ?? [];

                            final filteredOrders = orders.where((order) {
                              return order.orderStatus ==
                                  selectedOrderStatus.type;
                            }).toList();

                            return LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                double availableWidth = constraints.maxWidth;
                                double fontSize = availableWidth * 0.017;
                                double padding = availableWidth / 100;
                                double fixedIconSize = fontSize;
                                double flexWidth = availableWidth / 9;

                                return Stack(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: filteredOrders.length < 11
                                          ? null
                                          : fullScreenHeight(context) * 0.7,
                                      child: SingleChildScrollView(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: DataTable(
                                                dataRowHeight: fontSize * 5.5,
                                                headingRowHeight: 45,
                                                columnSpacing: 10,
                                                headingTextStyle: TextStyle(
                                                    fontSize: fontSize + 1,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                columns: [
                                                  const DataColumn(
                                                      label: Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'Customer List',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        '$orderType No.',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  const DataColumn(
                                                      label: Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'Created',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  const DataColumn(
                                                      label: Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'Created By',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        '$orderType Amount',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  const DataColumn(
                                                      label: Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'Status',
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
                                                rows: filteredOrders.isEmpty
                                                    ? [
                                                        const DataRow(cells: [
                                                          DataCell(Text(
                                                              'Record Not Found')),
                                                          DataCell(Text('')),
                                                          DataCell(Text('')),
                                                          DataCell(Text('')),
                                                          DataCell(Text('')),
                                                          DataCell(Text('')),
                                                          DataCell(Text('')),
                                                        ])
                                                      ]
                                                    : filteredOrders
                                                        .map((order) {
                                                        final customer = order
                                                                .customer
                                                                .isNotEmpty
                                                            ? order.customer[0]
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
                                                                    CircleAvatar(
                                                                      radius:
                                                                          (fixedIconSize / 2) +
                                                                              2,
                                                                      backgroundColor:
                                                                          const Color(
                                                                              0xffe6ecff),
                                                                      child: Icon(
                                                                          Icons
                                                                              .person,
                                                                          size:
                                                                              fixedIconSize,
                                                                          color:
                                                                              Colors.blue),
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
                                                                            customer != null
                                                                                ? customer.businessName
                                                                                : 'N/A',
                                                                            style:
                                                                                TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            customer != null
                                                                                ? customer.fullName
                                                                                : 'N/A',
                                                                            style:
                                                                                TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.bold),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            customer != null
                                                                                ? customer.mobileNo
                                                                                : 'N/A',
                                                                            style:
                                                                                TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            customer != null
                                                                                ? customer.email
                                                                                : 'N/A',
                                                                            style:
                                                                                TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400),
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
                                                              SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        0.9,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showDetailedOrderInvoiceDialog(
                                                                        context,
                                                                        order.orderId??'',
                                                                        false);
                                                                  },
                                                                  child: Center(
                                                                    child: Text(
                                                                      order
                                                                          .orderId,
                                                                      style: TextStyle(
                                                                          color:
                                                                              primaryColor,
                                                                          fontSize:
                                                                              fontSize,
                                                                          fontWeight:
                                                                              FontWeight.w600),
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
                                                                child: Center(
                                                                  child: Text(
                                                                    order.orderCreatedAt !=
                                                                            null
                                                                        ? getFormattedOrderCreatAt(order
                                                                            .orderCreatedAt
                                                                            .toString())
                                                                        : 'N/A',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          fontSize,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        1,
                                                                child: Center(
                                                                  child: Text(
                                                                    '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          fontSize,
                                                                    ),
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        1,
                                                                child: Center(
                                                                  child: Text(
                                                                    formatAmount(
                                                                        order
                                                                            .orderTotal),
                                                                    maxLines: 1,
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
                                                                        1.1,
                                                                child: Center(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Color(
                                                                          0xffffdbb8),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(15.0)),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              4.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            getStatusName(order.orderStatus),
                                                                            style:
                                                                                TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          if (order.orderStatus == 2 &&
                                                                              order.deliveryDate != null) ...[
                                                                            Text(
                                                                              NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate!.toIso8601String())),
                                                                              textAlign: TextAlign.center,
                                                                              maxLines: 2,
                                                                              style: const TextStyle(
                                                                                fontSize: 10.0,
                                                                                fontWeight: FontWeight.w400,
                                                                              ),
                                                                            ),
                                                                          ]
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(SizedBox(
                                                              width: flexWidth *
                                                                  0.5,
                                                              child: IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (orderType ==
                                                                        'Draft') {
                                                                      final cartProvider = Provider.of<
                                                                              CustomersProvider>(
                                                                          context,
                                                                          listen:
                                                                              false);
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return CartDialogue(
                                                                            active:
                                                                                true,
                                                                            cartItemCount:
                                                                                cartProvider.cartItemCount,
                                                                            productsController:
                                                                                productsController ?? ProductsController(),
                                                                            customerOrderController:
                                                                                customerOrderController,
                                                                            onContinueShopping:
                                                                                onContinueShopping,
                                                                            isFromCustomerDach:
                                                                                true,
                                                                            isDashboard:
                                                                                false,
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                    if (orderType !=
                                                                        'Draft') {
                                                                      showDetailedOrderInvoiceDialog(
                                                                          context,
                                                                          order
                                                                              .orderId,
                                                                          true,
                                                                          isButtonNeeded:
                                                                              true);
                                                                    }
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .visibility,
                                                                    size: 15,
                                                                    color:
                                                                        primaryColor,
                                                                  )),
                                                            )),
                                                          ],
                                                        );
                                                      }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                              dataRowHeight: fontSize * 5.5,
                                              headingRowHeight: 45,
                                              headingRowColor:
                                                  const WidgetStatePropertyAll(
                                                      primaryColor),
                                              columnSpacing: 10,
                                              headingTextStyle: TextStyle(
                                                  fontSize: fontSize + 1,
                                                  color: white,
                                                  fontWeight: FontWeight.w700),
                                              columns: [
                                                const DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Customer List',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      '$orderType No.',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                const DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Created',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                const DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Created By',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      '$orderType Amount',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                const DataColumn(
                                                    label: Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Status',
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                )),
                                                DataColumn(
                                                    label: Expanded(
                                                  child: SizedBox(
                                                      width: flexWidth * 0.5),
                                                )),
                                              ],
                                              rows: [
                                                DataRow(
                                                  cells: [
                                                    DataCell(
                                                      SizedBox(
                                                          width:
                                                              flexWidth * 1.5),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width:
                                                              flexWidth * 0.9),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width: flexWidth * 1),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width: flexWidth * 1),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width: flexWidth * 1),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width:
                                                              flexWidth * 1.1),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width:
                                                              flexWidth * 0.5),
                                                    ),
                                                  ],
                                                )
                                              ]),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: Center(
                                            child: dialogCloseButton1(
                                                context, red)),
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
}

class OptionData {
  String title;
  String count;
  String svg;
  Color svgBgColor;
  Color? color;
  VoidCallback? onTap;

  OptionData({
    required this.title,
    required this.count,
    required this.svg,
    required this.svgBgColor,
    this.onTap,
    this.color,
  });
}
