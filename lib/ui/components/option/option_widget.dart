import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/products_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../generated/assets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OptionWidget extends StatefulWidget {
  final UserType userType;
  final String userId;
  final (String, VoidCallback) Function(int index, OrderStatus orderStatus)?
      optionFun;
  final int? orderCount;
  final int? eastimatesCount;
  final int? preOrderCount;
  final int? draftCount;
  final int? cancelledCount;
  final String? customType;
  final bool? isVisible;
  final OrderStatus? customOrderStatusType;
  final String? startDate;
  final String? endDate;
  HomeController? homeController;
  OptionWidget({
    super.key,
    this.optionFun,
    required this.userType,
    required this.userId,
    this.orderCount,
    this.eastimatesCount,
    this.preOrderCount,
    this.draftCount,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    this.isVisible = false,
    this.cancelledCount,
    this.homeController,
  });

  @override
  State<OptionWidget> createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());

  ProductsController productsController = Get.put(ProductsController());

  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<ResponseModell>(
          future: provider.futureResponseModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCube(
                  color: primaryColor,
                  size: 20.0,
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const NodataWidget();
            } else if (snapshot.hasData) {
              final chatData = snapshot.data!.orderCountList;
              return options(chatData, context, provider);
            } else {
              return const NodataWidget();
            }
          },
        );
      },
    );
  }

  Widget options(OrderCountListt? orderCountList, BuildContext context,
      DashboardProvider provider) {
    return Row(
      children: _defaultOption(context, provider)
          .map((e) => orderOptions(e, orderCountList, context))
          .toList(),
    );
  }

  List<OptionData> _defaultOption(
          BuildContext context, DashboardProvider provider) =>
      [
        OptionData(
            title: 'Order',
            count: widget.orderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardShoppingCart,
            svgBgColor: const Color.fromARGB(255, 229, 242, 254),
            color: Color.fromARGB(255, 55, 74, 134),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.delivered);
              _showOrderStatusDialog(context, provider, OrderStatus.delivered);
            }),
        OptionData(
            title: 'Estimate',
            count: widget.eastimatesCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardEstimates,
            svgBgColor: const Color.fromARGB(255, 226, 249, 243),
            color: Color.fromARGB(255, 36, 108, 44),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.estimates);
              _showEstimatesDialog(
                  context, provider, OrderStatus.estimates, 'Estimate', false);
            }),
        OptionData(
            title: 'Booking',
            count: widget.preOrderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardPreOrder,
            svgBgColor: const Color.fromARGB(255, 230, 247, 251),
            color: Color.fromARGB(255, 45, 104, 116),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.preOrder);
              _showEstimatesDialog(
                  context, provider, OrderStatus.preOrder, 'Booking', false);
            }),
        OptionData(
            title: 'Draft',
            count: widget.draftCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardDraft,
            svgBgColor: const Color.fromARGB(255, 255, 227, 255),
            color: Color.fromARGB(255, 100, 43, 109),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.draft);
              _showEstimatesDialog(
                  context, provider, OrderStatus.draft, 'Draft', true);
              //     final customerId =
              //     customerOrderController.customerId.isNotEmpty
              //         ? customerOrderController.customerId.value
              //         : productsController.selectedCustomerId.value;
              // CartDatabaseManager().getCartItems(customerId);
              CartDatabaseManager().getDraftItems();
            }),
        OptionData(
            title: 'Cancelled',
            count: widget.cancelledCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardCancel,
            svgBgColor: const Color.fromARGB(255, 255, 228, 228),
            color: Color.fromARGB(255, 139, 27, 27),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.cancelled);
              _showEstimatesDialog(
                  context, provider, OrderStatus.cancelled, 'Cancelled', false);
            }),
      ];

  Widget orderOptions(OptionData optionData, OrderCountListt? orderCountList,
      BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance!.height * 0.03,
      fit: BoxFit.contain,
    );

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 3, left: 3),
        child: MyCommnonContainer(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
              blurRadius: 2,
              offset: Offset(4, 4),
            ),
          ],
          borderRadius: 20,
          onTap: optionData.onTap,
          margin: nkSymmetricPadding(
            vertical: 0,
            horizontal: AppDimensions.instance!.width * 0.001,
          ),
          padding: nkLargePadding(),
          isCommonBorder: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      ),
                      CustomText(
                        content:
                            _getCountForTitle(optionData.title, orderCountList),
                        fontSize: ResponsiveInfo.isMobileDimension(context)
                            ? 7.7
                            : 15.3,
                        fontWeight: FontWeight.w800,
                        color: optionData.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderStatusDialog(BuildContext context, DashboardProvider provider,
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
                              double fontSize =
                                  (availableWidth * 0.017).clamp(7.0, 15.0);
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;
                              double flexWidth = availableWidth / 10;

                              return Stack(
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
                                              fullScreenWidth(context) > 740
                                                  ? 45
                                                  : 75,
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
                                                    DataCell(Text(
                                                        'Record Not Found')),
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
                                                          width:
                                                              flexWidth * 1.5,
                                                          child: Row(
                                                            children: [
                                                              ClipOval(
                                                                child:
                                                                    Container(
                                                                  height:
                                                                      fixedIconSize *
                                                                          2,
                                                                  width:
                                                                      fixedIconSize *
                                                                          2,
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  child: Image
                                                                      .network(
                                                                    'http://16.50.232.153:3000/uploads/${customer?.imageUrl}',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder:
                                                                        (context,
                                                                            error,
                                                                            stackTrace) {
                                                                      return Container(
                                                                        color: const Color(
                                                                            0xffe6ecff),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .person,
                                                                          color:
                                                                              Colors.blue,
                                                                          size: fixedIconSize *
                                                                              2,
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
                                                                      maxLines:
                                                                          1,
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
                                                                          fontSize: fontSize -
                                                                              2,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      maxLines:
                                                                          1,
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
                                                                          fontSize: fontSize -
                                                                              2,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      maxLines:
                                                                          1,
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
                                                          width:
                                                              flexWidth * 0.9,
                                                          child: InkWell(
                                                            onTap: () {
                                                              showDetailedOrderInvoiceDialog(
                                                                  context,
                                                                  order.orderId,
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
                                                          width:
                                                              flexWidth * 0.9,
                                                          child: InkWell(
                                                            onTap: () {
                                                              showDetailedOrderInvoiceDialog(
                                                                  context,
                                                                  order.orderId,
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
                                                          width:
                                                              flexWidth * 1.1,
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
                                                                        1.0),
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
                                                        ),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                          width:
                                                              flexWidth * 1.2,
                                                          child: Center(
                                                            child: Container(
                                                              clipBehavior: Clip
                                                                  .antiAlias,
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
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0.0,
                                                                    vertical:
                                                                        0.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              6,
                                                                          horizontal:
                                                                              12.0),
                                                                      child:
                                                                          Text(
                                                                        getStatusName(
                                                                            order.orderStatus),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                fontSize,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                        textAlign:
                                                                            TextAlign.center,
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
                                                                          NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order
                                                                              .deliveryDate!
                                                                              .toIso8601String())),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          maxLines:
                                                                              2,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                fontSize - 2,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                    if (order
                                                                            .orderStatus ==
                                                                        14) ...[
                                                                      const SizedBox(
                                                                          height:
                                                                              5),
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
                                    controller: _scrollController2,
                                    child: SizedBox(
                                      width: fullScreenWidth(context) > 640
                                          ? fullScreenWidth(context) * 1
                                          : fullScreenWidth(context) * 1.1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: DataTable(
                                                dataRowHeight: fontSize * 5.5,
                                                headingRowHeight:
                                                    fullScreenWidth(context) >
                                                            740
                                                        ? 45
                                                        : 75,
                                                headingRowColor:
                                                    const WidgetStatePropertyAll(
                                                        primaryColor),
                                                columnSpacing: 10,
                                                headingTextStyle: TextStyle(
                                                    fontSize: fontSize + 1,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                columns: [
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 1.5,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Customer List',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 0.9,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Order No.',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 1,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Created',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 1,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Created By',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 1,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Amount',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 0.9,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Invoice',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 1.1,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Payment Status',
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: SizedBox(
                                                    width: flexWidth * 1.2,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: fullScreenWidth(
                                                                      context) >
                                                                  740
                                                              ? 0
                                                              : 30),
                                                      child: const Center(
                                                        child: Text(
                                                          'Status',
                                                          maxLines: 2,
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
                                                        SizedBox(
                                                            width: flexWidth *
                                                                1.5),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width: flexWidth *
                                                                0.9),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width:
                                                                flexWidth * 1),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width:
                                                                flexWidth * 1),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width:
                                                                flexWidth * 1),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width: flexWidth *
                                                                0.9),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width: flexWidth *
                                                                1.1),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width: flexWidth *
                                                                1.1),
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

  Future<void> _initializeCustomerData(
      CustomerDash? customer,
      ProductsController productsController,
      CustomerAndOrderController customerAndOrderController) async {
    final customerId = customer?.customerId;
    final customerName = customer?.businessName;
    final customerImage = customer?.imageUrl;
    if (customerId!.isEmpty) {
      log('Error: Customer ID is empty in CustomerDachScreen.');
      return;
    }
    customerAndOrderController.setCustomerId(customer?.customerId ?? '');
    productsController.selectedCustomerId.value = customer?.customerId ?? '';
    productsController.updateSelectedCustomer(
      name: customerName ?? '',
      imageUrl: customerImage ?? '',
      id: customerId,
    );
    log('CustomerDachScreen - Initialized Customer ID: $customerId, Name: $customerName, Image: $customerImage');
  }

  void _showEstimatesDialog(BuildContext context, DashboardProvider provider,
      OrderStatus selectedOrderStatus, String orderType, bool isDraft) {
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
                                                  DataColumn(
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
                                                        'Amount',
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
                                                                      order.orderId ??
                                                                          '',
                                                                      false,
                                                                    );
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
                                                                    final cartProvider = Provider.of<
                                                                            CustomersProvider>(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                    customerOrderController
                                                                        .customerId
                                                                        .value = customer
                                                                            ?.customerId ??
                                                                        '';
                                                                    if (isDraft) {
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
                                                                                productsController,
                                                                            customerOrderController:
                                                                                customerOrderController,
                                                                            isDashboard:
                                                                                true,
                                                                            customerId:
                                                                                customer?.customerId ?? '',
                                                                            onContinueShopping:
                                                                                () {
                                                                              Future.delayed(const Duration(milliseconds: 300), () {
                                                                                _initializeCustomerData(customer, productsController, customerOrderController);
                                                                                widget.homeController?.sidebarXController.selectIndex(2);
                                                                                widget.homeController?.selectedIndex.value = 2;
                                                                                Get.to(
                                                                                    () => OrderTaking(
                                                                                          productsController: productsController,
                                                                                        ),
                                                                                    id: 2);
                                                                              });
                                                                              // final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                                                                              // customerOrderController.setCustomerId(customer?.customerId ?? '');
                                                                              // cartProvider.updateCartCount(customer?.customerId ?? '');
                                                                              // productsController.selectedCustomerName.value = customer?.businessName ?? '';
                                                                              // productsController.selectedCustomerImageUrl.value = customer?.imageUrl ?? '';
                                                                              // productsController.selectedCustomerId.value = customer?.customerId ?? '';
                                                                              // CartDatabaseManager().getCartItems(customer?.customerId ?? '');
                                                                              // CartDatabaseManager().getDraftItems();

                                                                              // Future.delayed(const Duration(milliseconds: 300), () {
                                                                              //   Get.toNamed(name:AppRoutes.product, id: 2);
                                                                              // });
                                                                            },
                                                                          );
                                                                        },
                                                                      );
                                                                    } else {
                                                                      showDetailedOrderInvoiceDialog(
                                                                        context,
                                                                        order.orderId ??
                                                                            '',
                                                                        true,
                                                                        isButtonNeeded:
                                                                            true,
                                                                      );
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
                                                DataColumn(
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
                                                      'Amount',
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

  //   Future<void> _initializeCustomerData(CustomerDash customer) async {
  String _getCountForTitle(String title, OrderCountListt? orderCountList) {
    switch (title.toLowerCase()) {
      case 'order':
        return orderCountList?.totalOrder.toString() ?? "0";
      case 'estimate':
        return orderCountList?.estimateOrder.toString() ?? "0";
      case 'booking':
        return orderCountList?.preorderOrder.toString() ?? "0";
      case 'draft':
        return orderCountList?.draftOrder.toString() ?? "0";
      case 'cancelled':
        return orderCountList?.cancelOrder.toString() ?? "0";
      default:
        return "0";
    }
  }

  // String getOrderStatusString(OrderStatus status) {
  Widget _buildTableHeader1(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
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

Text text(List<InvoiceDash> invoices, dynamic s) {
  String invoiceId = invoices.map((invoice) => invoice.invoiceId).join(', ');
  return Text(invoiceId,
      style: TextStyle(
        fontSize: s,
        color: primaryColor,
        fontWeight: FontWeight.w400,
        // fontFamily: 'Poppins_Regular',
      ));
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

Widget noDataFoundWidget(String type) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      double availableWidth = constraints.maxWidth;
      double fontSize = 14.0;
      double padding = availableWidth / 100;
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: DataTable(
                      dataRowHeight: fontSize * 5.5,
                      headingRowHeight: 45,
                      headingRowColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => primaryColor,
                      ),
                      columnSpacing: padding * 1.5,
                      headingTextStyle: const TextStyle(
                          fontSize: 14,
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
                              '$type No.',
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
                              'Amount',
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
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('Record Not Found')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ])
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
                child: Center(child: dialogCloseButton1(context, red)),
              ),
            ),
          ],
        ),
      );
    },
  );
}
