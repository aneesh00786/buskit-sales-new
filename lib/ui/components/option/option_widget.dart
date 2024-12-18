import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/nodata_table_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../generated/assets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OptionWidget extends StatelessWidget {
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

  const OptionWidget({
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
  });

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
            title: 'Orders',
            count: orderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardShoppingCart,
            svgBgColor: const Color.fromARGB(255, 229, 242, 254),
            color: Color.fromARGB(255, 55, 74, 134),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.delivered);
              _showOrderStatusDialog(context, provider, OrderStatus.delivered);
            }),
        OptionData(
            title: 'Estimates',
            count: eastimatesCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardEstimates,
            svgBgColor: const Color.fromARGB(255, 226, 249, 243),
            color: Color.fromARGB(255, 36, 108, 44),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.estimates);
              _showEstimatesDialog(context, provider, OrderStatus.estimates);
            }),
        OptionData(
            title: 'Pre-Orders',
            count: preOrderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardPreOrder,
            svgBgColor: const Color.fromARGB(255, 230, 247, 251),
            color: Color.fromARGB(255, 45, 104, 116),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.preOrder);
              _showPreOrderDialog(context, provider, OrderStatus.preOrder);
            }),
        OptionData(
            title: 'Draft',
            count: draftCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardDraft,
            svgBgColor: const Color.fromARGB(255, 255, 227, 255),
            color: Color.fromARGB(255, 100, 43, 109),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.draft);
              _showDraftDialog(context, provider, OrderStatus.draft);
            }),
        OptionData(
            title: 'Cancelled',
            count: cancelledCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardCancel,
            svgBgColor: const Color.fromARGB(255, 255, 228, 228),
            color: Color.fromARGB(255, 139, 27, 27),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.cancelled);
              _showCancelledDialog(context, provider, OrderStatus.cancelled);
              // ignore: avoid_print
              print('this reponse type  : " ; ${OrderStatus.cancelled}');
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

  String _getCountForTitle(String title, OrderCountListt? orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return orderCountList?.totalOrder.toString() ?? "0";
      case 'estimates':
        return orderCountList?.estimateOrder.toString() ?? "0";
      case 'pre-orders':
        return orderCountList?.preorderOrder.toString() ?? "0";
      case 'draft':
        return orderCountList?.draftOrder.toString() ?? "0";
      case 'cancelled':
        return orderCountList?.cancelOrder.toString() ?? "0";
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

  String getPaymentStatusName(int payment) {
    switch (payment) {
      case 0:
        return 'Pre Order';
      case 1:
        return 'Completed';
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

void _showOrderStatusDialog(BuildContext context, DashboardProvider provider,
      OrderStatus selectedOrderStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Row(
            // remove if dialog
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

                          // Filter orders based on selected order status
                          final filteredOrders = orders.where((order) {
                            return order.orderStatus ==
                                selectedOrderStatus.type;
                          }).toList();

                          return LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double availableWidth = constraints.maxWidth;
                              // double fontSize = (availableWidth / 70).clamp(11, 14);
                              double fontSize = 14.0;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;
                              double flexWidth = availableWidth / 10;

                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Stack(
                                  children: [
                                    DataTable(
                                      dataRowHeight: fontSize * 5.5,
                                      headingRowHeight: 45,
                                      headingRowColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (states) => primaryColor,
                                      ),
                                      columnSpacing: padding * 1.5,
                                      headingTextStyle: const TextStyle(
                                          fontSize: 14,
                                          color: white,
                                          fontWeight: FontWeight.w700),
                                      columns: const [
                                        DataColumn(
                                            label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Customer List',
                                              maxLines: 2,
                                              // textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                        DataColumn(
                                            label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Order Number',
                                              maxLines: 2,
                                              //  textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                        DataColumn(
                                            label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Order Created',
                                              maxLines: 2,
                                              //  textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                        DataColumn(
                                            label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Created By',
                                              maxLines: 2,
                                              //  textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                        DataColumn(
                                            label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Order Price',
                                              maxLines: 2,
                                              //  textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )),
                                        DataColumn(
                                            label: Expanded(
                                          child: Center(
                                            child: Text(
                                              'Invoice',
                                              maxLines: 2,
                                              //  textAlign: TextAlign.center,
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
                                              //  textAlign: TextAlign.center,
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
                                                      width: flexWidth *
                                                          1.5, // Set an explicit width for each column
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
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
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
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
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
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
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
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                  maxLines:
                                                                      1, // Control email to 1 line and ellipsis
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
                                                      width: flexWidth *
                                                          1, // Explicit width for this cell
                                                      child: InkWell(
                                                        onTap: () {
                                                          _showDetailedOrderDialog(
                                                              context,
                                                              order,
                                                              false);
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            order.orderId,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
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
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
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
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: flexWidth * 0.8,
                                                      child: Center(
                                                        child: Text(
                                                          formatAmount(
                                                              order.orderTotal),
                                                          maxLines: 1,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: flexWidth * 0.8,
                                                      child: InkWell(
                                                        onTap: () {
                                                          _showDetailedOrderDialog(
                                                              context,
                                                              order,
                                                              true);
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            order.invoice
                                                                    .isEmpty
                                                                ? 'Not Found'
                                                                : order
                                                                    .invoice[0]
                                                                    .invoiceId,
                                                            style: const TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: flexWidth *
                                                          1, // Explicit width for this cell
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                order.paymentStatus ==
                                                                        0
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: order.paymentStatus ==
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
                                                      width: flexWidth *
                                                          1.1, // Explicit width for this cell
                                                      child: Center(
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xffffdbb8),
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
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
                                                                  _getStatusName(
                                                                      order
                                                                          .orderStatus),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
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
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10.0,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      )),
                                                                  // Text(
                                                                  //     DateFormat(
                                                                  //           'HH:MM XM')
                                                                  //       .format(order.deliveryDate as DateTime)
                                                                  //       .toString(),
                                                                  //     maxLines: 1,
                                                                  //     style:
                                                                  //         const TextStyle(
                                                                  //       fontSize:
                                                                  //           10.0,
                                                                  //       fontWeight:
                                                                  //           FontWeight
                                                                  //               .w400,
                                                                  //     ))
                                                                ]
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(Text('')),
                                                ],
                                              );
                                            }).toList(),
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
                                ),
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

  void _showEstimatesDialog(BuildContext context, DashboardProvider provider,
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
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return nodataDialogueTable(
                              head_1: 'Customer List',
                              head_2: 'Estimate Number',
                              head_3: 'Estimate Created',
                              head_4: 'Created By',
                              head_5: 'Estimate Price',
                              head_6: 'Status');
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
                              // double fontSize = (availableWidth / 70).clamp(11, 14);
                              double fontSize = 14.0;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;

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
                                            headingRowColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (states) => primaryColor,
                                            ),
                                            columnSpacing: padding * 1.5,
                                            headingTextStyle: const TextStyle(
                                                fontSize: 14,
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
                                                    'Estimate Number',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Estimate Created',
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
                                                    'Estimate Price',
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
                                                : filteredOrders.map((order) {
                                                    final customer = order
                                                            .customer.isNotEmpty
                                                        ? order.customer[0]
                                                        : null;
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                width:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xffe6ecff),
                                                                  child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size:
                                                                        fixedIconSize,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      padding),
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
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          fontSize *
                                                                              0.1),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .fullName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .mobileNo
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .email
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: InkWell(
                                                                onTap: () {
                                                                  _showDetailedOrderDialog(
                                                                      context,
                                                                      order,
                                                                      false);
                                                                },
                                                                child: Center(
                                                                    child: Text(
                                                                        order
                                                                            .orderId,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14)))),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.orderCreatedAt !=
                                                                      null
                                                                  ? getFormattedOrderCreatAt(order
                                                                      .orderCreatedAt
                                                                      .toString())
                                                                  : 'N/A',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                // fontFamily: 'Poppins_Regular',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.salesmanId,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              formatAmount(order
                                                                  .orderTotal),
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffffdbb8),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50.0)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        4.0),
                                                                child: Text(
                                                                  _getStatusName(
                                                                      order
                                                                          .orderStatus),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    // fontFamily: 'Poppins_Regular',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(Text('')),
                                                      ],
                                                    );
                                                  }).toList(),
                                          ),
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
                                ),
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

  void _showPreOrderDialog(BuildContext context, DashboardProvider provider,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<OrderResponse>(
                      future: provider.orderResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return nodataDialogueTable(
                              head_1: 'Customer List',
                              head_2: 'Pre-Order Number',
                              head_3: 'Pre-Order Created',
                              head_4: 'Created By',
                              head_5: 'Pre-Order Price',
                              head_6: 'Status');
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
                              // double fontSize = (availableWidth / 70).clamp(11, 14);
                              double fontSize = 14.0;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;

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
                                            headingRowColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (states) => primaryColor,
                                            ),
                                            columnSpacing: padding * 1.5,
                                            headingTextStyle: const TextStyle(
                                                fontSize: 14,
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
                                                    'Pre-Order Number',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Pre-Order Created',
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
                                                    'Pre-Order Price',
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
                                                      // DataCell(Text('')),
                                                    ])
                                                  ]
                                                : filteredOrders.map((order) {
                                                    final customer = order
                                                            .customer.isNotEmpty
                                                        ? order.customer[0]
                                                        : null;
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                width:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xffe6ecff),
                                                                  child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size:
                                                                        fixedIconSize,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      padding),
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
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          fontSize *
                                                                              0.1),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .mobileNo
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .email
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: InkWell(
                                                                onTap: () {
                                                                  _showDetailedOrderDialog(
                                                                      context,
                                                                      order,
                                                                      false);
                                                                },
                                                                child: Center(
                                                                    child: Text(
                                                                        order
                                                                            .orderId,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14)))),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.orderCreatedAt !=
                                                                      null
                                                                  ? getFormattedOrderCreatAt(order
                                                                      .orderCreatedAt
                                                                      .toString())
                                                                  : 'N/A',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                // fontFamily: 'Poppins_Regular',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.salesmanId,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              formatAmount(order
                                                                  .orderTotal),
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffffdbb8),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50.0)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        4.0),
                                                                child: Text(
                                                                  _getStatusName(
                                                                      order
                                                                          .orderStatus),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    // fontFamily: 'Poppins_Regular',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(Text('')),
                                                      ],
                                                    );
                                                  }).toList(),
                                          ),
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
                                ),
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

  void _showDraftDialog(BuildContext context, DashboardProvider provider,
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
                    color: white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<OrderResponse>(
                      future: provider.orderResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return nodataDialogueTable(
                              head_1: 'Customer List',
                              head_2: 'Draft Number',
                              head_3: 'Draft Created',
                              head_4: 'Created By',
                              head_5: 'Draft Price',
                              head_6: 'Status');
                        } else {
                          final orders = snapshot.data?.data ?? [];

                          // Filter orders based on selected order status
                          final filteredOrders = orders.where((order) {
                            return order.orderStatus ==
                                selectedOrderStatus.type;
                          }).toList();

                          return LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double availableWidth = constraints.maxWidth;
                              // double fontSize = (availableWidth / 70).clamp(11, 14);
                              double fontSize = 14.0;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;

                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                            // horizontalMargin: 30,
                                            dataRowHeight: fontSize * 5.5,
                                            headingRowHeight: 45,
                                            headingRowColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (states) => primaryColor,
                                            ),
                                            columnSpacing: padding * 1.5,
                                            headingTextStyle: const TextStyle(
                                                fontSize: 14,
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
                                                    'Draft Number',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Draft Created',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              'Created By',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                child: Center(
                                                  child: Text(
                                                    'Draft Price',
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              )),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text('Status',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                '',
                                              )))),
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
                                                      // DataCell(Text('')),
                                                    ])
                                                  ]
                                                : filteredOrders.map((order) {
                                                    final customer = order
                                                            .customer.isNotEmpty
                                                        ? order.customer[0]
                                                        : null;
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                width:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xffe6ecff),
                                                                  child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size:
                                                                        fixedIconSize,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      padding),
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
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          fontSize *
                                                                              0.1),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .mobileNo
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .email
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: InkWell(
                                                                onTap: () {
                                                                  _showDetailedOrderDialog(
                                                                      context,
                                                                      order,
                                                                      false);
                                                                },
                                                                child: Center(
                                                                    child: Text(
                                                                        order
                                                                            .orderId,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14)))),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.orderCreatedAt !=
                                                                      null
                                                                  ? getFormattedOrderCreatAt(order
                                                                      .orderCreatedAt
                                                                      .toString())
                                                                  : 'N/A',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                // fontFamily: 'Poppins_Regular',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.salesmanId,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              formatAmount(order
                                                                  .orderTotal),
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffffdbb8),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50.0)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        4.0),
                                                                child: Text(
                                                                  _getStatusName(
                                                                      order
                                                                          .orderStatus),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    // fontFamily: 'Poppins_Regular',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(Text('')),
                                                      ],
                                                    );
                                                  }).toList(),
                                          ),
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
                                ),
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

  void _showCancelledDialog(BuildContext context, DashboardProvider provider,
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
                    color: white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<OrderResponse>(
                      future: provider.orderResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return nodataDialogueTable(
                              head_1: 'Customer List',
                              head_2: 'Cancelled Order Number',
                              head_3: 'Cancelled Order Created',
                              head_4: 'Created By',
                              head_5: 'Cancelled Order Price',
                              head_6: 'Status');
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
                              // double fontSize = (availableWidth / 70).clamp(11, 14);
                              double fontSize = 14.0;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;

                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                            // horizontalMargin: 45,
                                            dataRowHeight: fontSize * 5.5,
                                            headingRowHeight: 45,
                                            headingRowColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                              (states) => primaryColor,
                                            ),
                                            columnSpacing: padding * 1.5,
                                            headingTextStyle: const TextStyle(
                                                fontSize: 14,
                                                color: white,
                                                fontWeight: FontWeight.w700),
                                            columns: const [
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              'Customer List',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              'Cancelled Order Number',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              'Cancelled Order Created',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              'Created By',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                              'Cancelled Order Price',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text('Status',
                                                              maxLines: 2)))),
                                              DataColumn(
                                                  label: Expanded(
                                                      child: Center(
                                                          child: Text(
                                                '',
                                              )))),
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
                                                : filteredOrders.map((order) {
                                                    final customer = order
                                                            .customer.isNotEmpty
                                                        ? order.customer[0]
                                                        : null;
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                width:
                                                                    fixedIconSize *
                                                                        1.6,
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xffe6ecff),
                                                                  child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size:
                                                                        fixedIconSize,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      padding),
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
                                                                        ? customer
                                                                            .businessName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          fontSize *
                                                                              0.1),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .fullName
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .mobileNo
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    customer !=
                                                                            null
                                                                        ? customer
                                                                            .email
                                                                        : 'N/A',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      // fontFamily: 'Poppins_Regular',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: InkWell(
                                                                onTap: () {
                                                                  _showDetailedOrderDialog(
                                                                      context,
                                                                      order,
                                                                      false);
                                                                },
                                                                child: Center(
                                                                    child: Text(
                                                                        order
                                                                            .orderId,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14)))),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.orderCreatedAt !=
                                                                      null
                                                                  ? getFormattedOrderCreatAt(order
                                                                      .orderCreatedAt
                                                                      .toString())
                                                                  : 'N/A',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                // fontFamily: 'Poppins_Regular',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              order.salesmanId,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              formatAmount(order
                                                                  .orderTotal),
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Center(
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffffdbb8),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50.0)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        4.0),
                                                                child: Text(
                                                                  _getStatusName(
                                                                      order
                                                                          .orderStatus),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    // fontFamily: 'Poppins_Regular',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(Text('')),
                                                      ],
                                                    );
                                                  }).toList(),
                                          ),
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
                                ),
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

String _getStatusName(int status) {
  switch (status) {
    case 5:
      return 'Order Processing';
    case 10:
      return 'Packed for Delivery';
    case 1:
      return 'Out for Delivery';
    case 2:
      return 'Delivered';
    default:
      return 'Unknown';
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

void _showDetailedOrderDialog(
  BuildContext context,
  OrdersDash orderData,
  final bool invoice,
) {
  DashBoardController dashBoardController = Get.find<DashBoardController>();

  dashBoardController.loadSpecificOrderInvoiceData(orderId: orderData.orderId);

  showDialog(
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
                                NKDateUtils.formatStringUTCDateTime(orderData
                                    .orderCreatedAt
                                    .toIso8601String())),
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
                              Text(
                                orderData.customer.isNotEmpty
                                    ? 'Name : ${orderData.customer[0].fullName}'
                                    : 'N/A',
                              ),
                              Text(
                                orderData.customer.isNotEmpty
                                    ? 'Email : ${orderData.customer[0].email}'
                                    : 'N/A',
                              ),
                              Text(
                                orderData.customer.isNotEmpty
                                    ? 'Phone : ${orderData.customer[0].mobileNo}'
                                    : 'N/A',
                              ),
                              Text(
                                orderData.customer.isNotEmpty
                                    ? 'Salesman : ${orderData.customer[0].salesmanName}'
                                    : 'N/A',
                              ),
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
                                        text: orderData.customer.isNotEmpty
                                            ? (orderData.paymentStatus == 0
                                                ? 'NOT PAID'
                                                : 'COMPLETED')
                                            : 'N/A',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: orderData.paymentStatus == 0
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  orderData.customer.isNotEmpty
                                      ? 'Payment Mode : ${_getPaymentTypeName(orderData.paymentStatus)}'
                                      : 'N/A',
                                ),
                              ],
                            ),
                          ],
                          const Spacer(),
                          ClipOval(
                            child: Container(
                              height: 50,
                              width: 50,
                              color: Colors.lightBlue[100],
                              child: orderData.customer.isNotEmpty
                                  ? Image.network(
                                      'uploads/${orderData.customer[0].imageUrl}')
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
                        'Order Status : ${_getStatusName(orderData.orderStatus)}',
                        style: const TextStyle(fontSize: 18))
                  ],
                ),
                const Divider(
                  color: black,
                ),
                Obx(() {
                  return dashBoardController.isInvoiceLoading.value
                      ? Center(
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
                                            'QUANTITY',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          flex: 2,
                                          child: Text(
                                            'PRICE',
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
                                                item.quantity.toString(),
                                                maxLines: 1))),
                                        DataCell(Center(
                                            child: Text(
                                          formatAmount(item.price),
                                          maxLines: 1,
                                        ))),
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
                                          style: TextStyle(
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
