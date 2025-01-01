import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/option_dialogues/show_dash_main_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
// import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart' as font;
// import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
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
              _showEstimatesDialog(
                  context, provider, OrderStatus.estimates, 'Estimate');
            }),
        OptionData(
            title: 'Pre-Orders',
            count: preOrderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardPreOrder,
            svgBgColor: const Color.fromARGB(255, 230, 247, 251),
            color: Color.fromARGB(255, 45, 104, 116),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.preOrder);
             _showEstimatesDialog(
                  context, provider, OrderStatus.preOrder, 'Pre-Order');
            }),
        OptionData(
            title: 'Draft',
            count: draftCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardDraft,
            svgBgColor: const Color.fromARGB(255, 255, 227, 255),
            color: Color.fromARGB(255, 100, 43, 109),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.draft);
              _showEstimatesDialog(
                  context, provider, OrderStatus.draft, 'Draft');
            }),
        OptionData(
            title: 'Cancelled',
            count: cancelledCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardCancel,
            svgBgColor: const Color.fromARGB(255, 255, 228, 228),
            color: Color.fromARGB(255, 139, 27, 27),
            onTap: () {
              provider.fetchOrdersSabik(OrderStatus.cancelled);
              _showEstimatesDialog(
                  context, provider, OrderStatus.cancelled, 'Cancelled');
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
                              double fontSize = 14.0;
                              double padding = availableWidth / 100;
                              double fixedIconSize = fontSize;
                              double flexWidth = availableWidth / 10;

                              return Stack(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: filteredOrders.length <= 10
                                            ? null
                                            : MediaQuery.of(context).size.height * 0.8,
                                    child: SingleChildScrollView(
                                      child: DataTable(
                                        dataRowHeight: fontSize * 5.5,
                                        headingRowColor:
                                            const WidgetStatePropertyAll(
                                                primaryColor),
                                        headingRowHeight: 45,
                                        columnSpacing: 10,
                                        headingTextStyle: const TextStyle(
                                            fontSize: 15,
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
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            myFont,
                                                                        fontSize:
                                                                            11,
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
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            myFont,
                                                                        fontSize:
                                                                            10,
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
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            myFont,
                                                                        fontSize:
                                                                            10,
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
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            myFont,
                                                                        fontSize:
                                                                            10,
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
                                                                order,
                                                                false);
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              order.orderId,
                                                              style: const TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      myFont,
                                                                  fontSize:
                                                                      11.0,
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
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  myFont,
                                                              fontSize: 11.0,
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
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  myFont,
                                                              fontSize: 11.0,
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
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  myFont,
                                                              fontSize: 11.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                        width: flexWidth * 0.8,
                                                        child: InkWell(
                                                          onTap: () {
                                                            showDetailedOrderInvoiceDialog(
                                                                context,
                                                                order,
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
                                                              style: const TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      myFont,
                                                                  fontSize:
                                                                      11.0,
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
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            myFont,
                                                                        fontSize:
                                                                            11.0,
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
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10.0,
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
                                  Positioned(
                                    top: 0,
                                    child: DataTable(
                                        dataRowHeight: fontSize * 5.5,
                                        headingRowHeight: 45,
                                        headingRowColor:
                                            const WidgetStatePropertyAll(
                                                primaryColor),
                                        columnSpacing: 10,
                                        headingTextStyle: const TextStyle(
                                            fontSize: 15,
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
                                                'Order Created',
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
                                                'Order Amount',
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
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(width: flexWidth * 1),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                    width: flexWidth * 0.8),
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

  void _showEstimatesDialog(BuildContext context, DashboardProvider provider,
      OrderStatus selectedOrderStatus, String orderType) {
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
                                double fontSize = 14.0;
                                double padding = availableWidth / 100;
                                double fixedIconSize = fontSize;
                                double flexWidth = availableWidth / 9;

                                return Stack(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width,
                                      height: filteredOrders.length < 10
                                          ? null
                                          : MediaQuery.of(context).size.height * 0.8,
                                      child: SingleChildScrollView(
                                        child: DataTable(
                                          dataRowHeight: fontSize * 5.5,
                                          headingRowHeight: 45,
                                          columnSpacing: 10,
                                          headingTextStyle: const TextStyle(
                                              fontSize: 15,
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
                                                  '$orderType Created',
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
                                                  'Invoice',
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
                                                        SizedBox(
                                                          width:
                                                              flexWidth * 1.5,
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
                                                                    Icons
                                                                        .person,
                                                                    size:
                                                                        fixedIconSize,
                                                                    color: Colors
                                                                        .blue),
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
                                                                          ? customer.businessName
                                                                          : 'N/A',
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              myFont,
                                                                          fontSize:
                                                                              11,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
                                                                    ),
                                                                    Text(
                                                                      customer !=
                                                                              null
                                                                          ? customer.fullName
                                                                          : 'N/A',
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              myFont,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.bold),
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
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              myFont,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400),
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
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              myFont,
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400),
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
                                                              flexWidth * 0.9,
                                                          child: InkWell(
                                                            onTap: () {
                                                              showDetailedOrderInvoiceDialog(
                                                                  context,
                                                                  order,
                                                                  false);
                                                            },
                                                            child: Center(
                                                              child: Text(
                                                                order.orderId,
                                                                style: const TextStyle(
                                                                    color:
                                                                        primaryColor,
                                                                    fontFamily:
                                                                        myFont,
                                                                    fontSize:
                                                                        11.0,
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
                                                              flexWidth * 1,
                                                          child: Center(
                                                            child: Text(
                                                              order.orderCreatedAt !=
                                                                      null
                                                                  ? getFormattedOrderCreatAt(order
                                                                      .orderCreatedAt
                                                                      .toString())
                                                                  : 'N/A',
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    myFont,
                                                                fontSize:
                                                                    11.0,
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
                                                              flexWidth * 1,
                                                          child: Center(
                                                            child: Text(
                                                              '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    myFont,
                                                                fontSize:
                                                                    11.0,
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
                                                          child: Center(
                                                            child: Text(
                                                              formatAmount(order
                                                                  .orderTotal),
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    myFont,
                                                                fontSize:
                                                                    11.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                          width:
                                                              flexWidth * 0.8,
                                                          child: InkWell(
                                                            onTap: () {
                                                              showDetailedOrderInvoiceDialog(
                                                                  context,
                                                                  order,
                                                                  true,
                                                                  isButtonNeeded: orderType ==
                                                                          'Cancelled'
                                                                      ? false
                                                                      : true);
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
                                                                style: const TextStyle(
                                                                    color:
                                                                        primaryColor,
                                                                    fontFamily:
                                                                        myFont,
                                                                    fontSize:
                                                                        11.0,
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
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xffffdbb8),
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            15.0)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
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
                                                                          order.orderStatus),
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              myFont,
                                                                          fontSize:
                                                                              11.0,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign.center,
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
                                                                            TextAlign.center,
                                                                        maxLines:
                                                                            2,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              10.0,
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
                                                      DataCell(SizedBox(
                                                        width:
                                                            flexWidth * 0.5,
                                                        child: IconButton(
                                                            onPressed: () {
                                                              showDetailedOrderInvoiceDialog(
                                                                  context,
                                                                  order,
                                                                  true,
                                                                  isButtonNeeded:
                                                                      true);
                                                            },
                                                            icon: const Icon(
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
                                              headingTextStyle:
                                                  const TextStyle(
                                                      fontSize: 15,
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
                                                      '$orderType Created',
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
                                                      'Invoice',
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
                                                              0.8),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width: flexWidth *
                                                              1.1),
                                                    ),
                                                    DataCell(
                                                      SizedBox(
                                                          width: flexWidth *
                                                              0.5),
                                                    ),
                                                    // const DataCell(Text('')),
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

  // String getOrderStatusString(OrderStatus status) {
  //   switch (status) {
  //     case OrderStatus.preOrder:
  //       return 'Pre Order';
  //     case OrderStatus.outOfDelivery:
  //       return 'Out For Delivery';
  //     case OrderStatus.delivered:
  //       return 'Delivered';
  //     case OrderStatus.cancelled:
  //       return 'Cancelled';
  //     case OrderStatus.draft:
  //       return 'Draft';
  //     case OrderStatus.processing:
  //       return 'Processing';
  //     case OrderStatus.pending:
  //       return 'Pending';
  //     case OrderStatus.estimates:
  //       return 'Estimates';

  //     default:
  //       throw Exception('Unsupported order status: $status');
  //   }
  // }

  // String getOrderStatusName(int orderStatus) {
  //   switch (orderStatus) {
  //     case 0:
  //       return 'Pre Order';
  //     case 1:
  //       return 'Out For Delivery';
  //     case 2:
  //       return 'Delivered';
  //     case 3:
  //       return 'Cancelled';
  //     case 4:
  //       return 'Draft';
  //     case 5:
  //       return 'Processing';
  //     case 6:
  //       return 'Pending';
  //     case 7:
  //       return 'Estimates';
  //     case 8:
  //       return 'Accept By Admin';
  //     case 9:
  //       return 'Reject By Admin';
  //     case 10:
  //       return 'Packed For Delivery';
  //     default:
  //       return '';
  //   }
  // }

  // String getPaymentStatusName(int payment) {
  //   switch (payment) {
  //     case 0:
  //       return 'Pre Order';
  //     case 1:
  //       return 'Completed';
  //     case 2:
  //       return 'Delivered';
  //     case 3:
  //       return 'Cancelled';
  //     case 4:
  //       return 'Draft';
  //     case 5:
  //       return 'Processing';
  //     case 6:
  //       return 'Pending';
  //     case 7:
  //       return 'Estimates';
  //     case 8:
  //       return 'Accept By Admin';
  //     case 9:
  //       return 'Reject By Admin';
  //     case 10:
  //       return 'Packed For Delivery';
  //     default:
  //       return '';
  //   }
  // }


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
                              '$type Number',
                              maxLines: 2,
                            ),
                          ),
                        )),
                        DataColumn(
                            label: Expanded(
                          child: Center(
                            child: Text(
                              '$type Created',
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
                              '$type Price',
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