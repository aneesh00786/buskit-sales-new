// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/nodata_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart'
    as ext;
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';

class OptionWidgetCustomerDash extends StatefulWidget {
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
  final ProductsController productsController;
  final VoidCallback onContinueShopping;

  const OptionWidgetCustomerDash({
    super.key,
    required this.customerId,
    this.optionFun,
    required this.userType,
    required this.userId,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    required this.productsController,
    required this.onContinueShopping,
    this.isVisible = false,
  });

  @override
  State<OptionWidgetCustomerDash> createState() =>
      _OptionWidgetCustomerDashState();
}

class _OptionWidgetCustomerDashState extends State<OptionWidgetCustomerDash> {
  CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());

  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  int _offlineDraftCount = 0;
  int _onlineDraftCount = 0;
  int get _totalDraftCount =>
      (_onlineDraftCount == 0 ? _offlineDraftCount : 0) + _onlineDraftCount;

  // Add: Function to get offline draft count for a customer
  Future<int> getOfflineDraftCount(String customerId) async {
    var offlineDraftsBox = await Hive.openBox('offlineDrafts');
    List<dynamic> drafts =
        offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
    return drafts.where((draft) => draft['customer_id'] == customerId).length;
  }

  void _fetchDraftCounts(OrderDataas? orderCountList) async {
    int offlineCount = await getOfflineDraftCount(widget.customerId);
    int onlineCount = orderCountList != null ? (orderCountList.draftOrder) : 0;
    setState(() {
      _offlineDraftCount = offlineCount;
      _onlineDraftCount = onlineCount;
    });
  }

  @override
  void initState() {
    super.initState();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When entering the dashboard, fetch the draft counts
    // The orderCountList is only available in build, so we trigger fetch in build
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.countFuture == null) {
            provider.fetchCustomerDashboardCountData(
              widget.customerId,
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
              final OrderDataas countData = OrderDataas(
                  totalOrder: 0,
                  estimateOrder: 0,
                  estimateFilteredOrder: 0,
                  preorderOrder: 0,
                  preorderFilteredOrder: 0,
                  draftOrder: 0,
                  draftFilteredOrder: 0,
                  cancelOrder: 0);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchDraftCounts(countData);
              });
              return options(countData, context, provider);
            } else if (snapshot.hasData) {
              final countData = snapshot.data!.data;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchDraftCounts(countData);
              });
              return options(countData, context, provider);
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
    if (isTabletOrPhoneLandscape(context)) {
      return Row(
        children: _defaultOption(context, provider, orderCountList)
            .map((e) => orderOptions(e, orderCountList, context))
            .toList(),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 700,
          child: Row(
            children: _defaultOption(context, provider, orderCountList)
                .map((e) => orderOptions(e, orderCountList, context))
                .toList(),
          ),
        ),
      );
    }
  }

  List<OptionData> _defaultOption(BuildContext context,
          CustomersProvider provider, OrderDataas orderCountList) =>
      [
        OptionData(
          title: 'Orders',
          count: orderCountList.totalOrder.toString(),
          unfilteredCount: 0.toString(),
          svg: Assets.iconsIcDashboardShoppingCart,
          svgBgColor: const Color.fromARGB(255, 229, 242, 254),
          color: const Color.fromARGB(255, 55, 74, 134),
          onTap: () async {
            if (orderCountList.totalOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              bool isOnline = await ConnectivityService().isOnline();
              if (isOnline) {
                provider.fetchOrdersForCustomDash(
                  OrderStatus.delivered,
                  widget.customerId,
                );
                _showOrderStatusDialog(
                    context, provider, OrderStatus.delivered);
              } else {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
              }
            }
          },
        ),
        OptionData(
          title: 'Estimates',
          unfilteredCount: orderCountList.estimateOrder.toString(),
          count: orderCountList.estimateFilteredOrder.toString(),
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color.fromARGB(255, 226, 249, 243),
          color: const Color.fromARGB(255, 36, 108, 44),
          onTap: () async {
            if (orderCountList.estimateFilteredOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              bool isOnline = await ConnectivityService().isOnline();
              if (isOnline) {
                provider.fetchOrdersForCustomDash(
                  OrderStatus.estimates,
                  widget.customerId,
                  checkDate: true,
                );
                _showOrderTypeDialog(
                    context, provider, OrderStatus.estimates, 'Estimate');
              } else {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
              }
            }
          },
          onUnFilterTap: () async {
            if (orderCountList.estimateOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              bool isOnline = await ConnectivityService().isOnline();
              if (isOnline) {
                provider.fetchOrdersForCustomDash(
                  OrderStatus.estimates,
                  widget.customerId,
                  checkDate: false,
                );
                _showOrderTypeDialog(
                    context, provider, OrderStatus.estimates, 'Estimate');
              } else {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
              }
            }
          },
        ),
        OptionData(
          title: 'Bookings',
          unfilteredCount: orderCountList.preorderOrder.toString(),
          count: orderCountList.preorderFilteredOrder.toString(),
          svg: Assets.iconsIcDashboardPreOrder,
          svgBgColor: const Color.fromARGB(255, 230, 247, 251),
          color: const Color.fromARGB(255, 45, 104, 116),
          onTap: () async {
            if (orderCountList.preorderFilteredOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              bool isOnline = await ConnectivityService().isOnline();
              if (isOnline) {
                provider.fetchOrdersForCustomDash(
                  OrderStatus.preOrder,
                  widget.customerId,
                  checkDate: true,
                );
                _showOrderTypeDialog(
                    context, provider, OrderStatus.preOrder, 'Booking');
              } else {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
              }
            }
          },
          onUnFilterTap: () async {
            if (orderCountList.preorderOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              bool isOnline = await ConnectivityService().isOnline();
              if (isOnline) {
                provider.fetchOrdersForCustomDash(
                  OrderStatus.preOrder,
                  widget.customerId,
                  checkDate: false,
                );
                _showOrderTypeDialog(
                    context, provider, OrderStatus.preOrder, 'Booking');
              } else {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
              }
            }
          },
        ),
        OptionData(
          title: 'Drafts',
          count: _totalDraftCount.toString(),
          unfilteredCount: 0.toString(),
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color.fromARGB(255, 255, 227, 255),
          color: const Color.fromARGB(255, 100, 43, 109),
          onTap: () async {
            int offlineCount = await getOfflineDraftCount(widget.customerId);
            int onlineCount =
                int.tryParse(orderCountList.draftOrder.toString()) ?? 0;
            var offlineDraftsBox = await Hive.openBox('offlineDrafts');
            List<dynamic> drafts = offlineDraftsBox
                .get('drafts', defaultValue: []) as List<dynamic>;
            List<dynamic> offlineDraftDetails = drafts
                .where((draft) => draft['customer_id'] == widget.customerId)
                .toList();
            if ((onlineCount + (onlineCount == 0 ? offlineCount : 0)) == 0) {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersForCustomDash(
                OrderStatus.draft,
                widget.customerId,
              );
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.draft,
                'Draft',
                onContinueShopping: widget.onContinueShopping,
                offlineDraftDetails: offlineDraftDetails,
              );
              await CartDatabaseManager().getDraftItems();
            }
          },
        ),
        OptionData(
          title: 'Cancelled',
          unfilteredCount: 0.toString(),
          count: orderCountList.cancelOrder.toString(),
          svg: Assets.iconsIcDashboardCancel,
          svgBgColor: const Color.fromARGB(255, 255, 228, 228),
          color: const Color.fromARGB(255, 139, 27, 27),
          onTap: () async {
            if (orderCountList.cancelOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              bool isOnline = await ConnectivityService().isOnline();
              if (isOnline) {
                provider.fetchOrdersForCustomDash(
                  OrderStatus.cancelled,
                  widget.customerId,
                );
                _showOrderTypeDialog(
                    context, provider, OrderStatus.cancelled, 'Cancelled');
              } else {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
              }
            }
          },
        ),
      ];

  Widget orderOptions(
      OptionData optionData, OrderDataas orderCountList, BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance!.height * 0.02,
      fit: BoxFit.contain,
    );

    if (optionData.title == 'Drafts') {
      return Flexible(
        child: MyCommnonContainer(
          color: white,
          onTap: optionData.onTap,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
          borderRadius: 20,
          margin: nkSymmetricPadding(
            vertical: 0,
            horizontal: AppDimensions.instance!.width * 0.001,
          ),
          padding: nkLargePadding(),
          isCommonBorder: true,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            content: optionData.count,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: optionData.color,
                          ),
                          // if (_getUnFilteredCountForTitle(
                          //         optionData.title, orderCountList) !=
                          //     "0") ...[
                          //   const SizedBox(width: 30),
                          //   InkWell(
                          //     onTap: optionData.onUnFilterTap,
                          //     child: CircleAvatar(
                          //       radius:
                          //           ResponsiveInfo.isMobileDimension(context)
                          //               ? 6
                          //               : 10,
                          //       backgroundColor: red,
                          //       child: CustomText(
                          //         content: _getUnFilteredCountForTitle(
                          //             optionData.title, orderCountList),
                          //         fontSize:
                          //             ResponsiveInfo.isMobileDimension(context)
                          //                 ? 7.7
                          //                 : 10,
                          //         fontWeight: FontWeight.bold,
                          //         color: white,
                          //       ),
                          //     ),
                          //   ),
                          // ]
                        ],
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

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(right: 3, left: 3),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main container (parent tap works everywhere else)
            MyCommnonContainer(
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 211, 211, 211).withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(4, 4),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: optionData.svgBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                          maxLine: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              content: _getCountForTitle(
                                  optionData.title, orderCountList),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: optionData.color,
                            ),
                            const SizedBox(width: 30), // leave space for badge
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Red count badge with its own hit area
            if (_getUnFilteredCountForTitle(optionData.title, orderCountList) !=
                "0")
              Positioned(
                right: 12,
                top: 24,
                child: InkWell(
                  onTap: optionData.onUnFilterTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8), // enlarge touch target
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.transparent, width: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: red,
                      child: CustomText(
                        content: _getUnFilteredCountForTitle(
                            optionData.title, orderCountList),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getCountForTitle(String title, OrderDataas orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return orderCountList.totalOrder.toString();
      case 'estimates':
        return orderCountList.estimateFilteredOrder.toString();
      case 'bookings':
        return orderCountList.preorderFilteredOrder.toString();
      case 'drafts':
        return orderCountList.draftOrder.toString();
      case 'cancelled':
        return orderCountList.cancelOrder.toString();
      default:
        return "0";
    }
  }

  String _getUnFilteredCountForTitle(String title, OrderDataas orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return "0";
      case 'estimates':
        return orderCountList.estimateOrder.toString();
      case 'bookings':
        return orderCountList.preorderOrder.toString();
      case 'drafts':
        // return orderCountList?.draftOrder.toString() ?? "0";
        return "0";
      case 'cancelled':
        return "0";
      default:
        return "0";
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
                          // return Center(
                          //   child: Text('Error: ${snapshot.error}'),
                          // );
                          return noOrderDataFoundWidget();
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
                                        controller: _scrollController1,
                                        child: SizedBox(
                                          width: fullScreenWidth(context) > 640
                                              ? fullScreenWidth(context) * 1
                                              : fullScreenWidth(context) * 1.1,
                                          height: filteredOrders.length < 11
                                              ? null
                                              : fullScreenHeight(context) * 0.7,
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
                                                                            'http://16.50.232.153:3000/uploads/${customer?.imageUrl}',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            errorBuilder: (context,
                                                                                error,
                                                                                stackTrace) {
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
                                                                              customer != null ? customer.fullName : 'N/A',
                                                                              style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.bold),
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
                                                                          await ConnectivityService()
                                                                              .isOnline();
                                                                      if (isOnline) {
                                                                        showDetailedOrderInvoiceDialog(
                                                                            context,
                                                                            order.orderId,
                                                                            false);
                                                                      } else {
                                                                        showCustomToastDisplay(
                                                                            context,
                                                                            "You are Offline!",
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
                                                                      maxLines:
                                                                          1,
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
                                                                  child: Center(
                                                                    child: Text(
                                                                      ext.formatAmount(
                                                                          order
                                                                              .orderTotal),
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
                                                                    onTap: () {
                                                                      showInvoicePreviewOnline(
                                                                        context,
                                                                        order
                                                                            .orderId,
                                                                      );
                                                                    },
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        order.invoice.isEmpty
                                                                            ? ''
                                                                            : order.invoice[0].invoiceId,
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
                                                                          1.1,
                                                                  child: Center(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: order.paymentStatus ==
                                                                                0
                                                                            ? Colors.red
                                                                            : Colors.green,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                            color: order.paymentStatus == 0
                                                                                ? Colors.red
                                                                                : Colors.green),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
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
                                                                  width:
                                                                      flexWidth *
                                                                          1.2,
                                                                  child: Center(
                                                                    child:
                                                                        Container(
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Color(
                                                                            0xffffdbb8),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(15.0)),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                0.0,
                                                                            vertical:
                                                                                0.0),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12.0),
                                                                              child: Text(
                                                                                getStatusName(order.orderStatus),
                                                                                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                            if (order.orderStatus == 2 &&
                                                                                order.deliveryDate != null) ...[
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
                                                                            if (order.orderStatus ==
                                                                                14) ...[
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
                                                    headingTextStyle: TextStyle(
                                                        fontSize: fontSize + 2,
                                                        color: white,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    columns: [
                                                      DataColumn(
                                                          label: SizedBox(
                                                        width: flexWidth * 4.5,
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            'Total',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      DataColumn(
                                                          label: SizedBox(
                                                        // color: red,
                                                        width: flexWidth * 4.1,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            formatAmount(
                                                                filteredOrders
                                                                    .fold<
                                                                        double>(
                                                              0.0,
                                                              (sum, order) =>
                                                                  sum +
                                                                  (order.orderTotal ??
                                                                      0.0),
                                                            )),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                    ],
                                                    rows: [
                                                      DataRow(
                                                        cells: [
                                                          DataCell(
                                                            SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        1.5),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        0.9),
                                                          ),
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

  void _showOrderTypeDialog(
    BuildContext context,
    CustomersProvider provider,
    OrderStatus selectedOrderStatus,
    String orderType, {
    VoidCallback? onContinueShopping,
    List<dynamic>? offlineDraftDetails,
  }) {
    var offlineDraftTotal = (offlineDraftDetails == null
        ? 0
        : (offlineDraftDetails.fold<double>(
            0.0,
            (sum, order) =>
                sum + (order['displayData']['displayTotal'] ?? 0.0))));

    VoidCallback? onDraftUpdated;
    if (orderType == 'Draft') {
      onDraftUpdated = () async {
        List<dynamic> freshOfflineDraftDetails = [];
        try {
          var offlineDraftsBox = await Hive.openBox('offlineDrafts');
          List<dynamic> drafts =
              offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
          freshOfflineDraftDetails = drafts.toList();
        } catch (e) {
          log('Error getting fresh offline draft data: $e');
        }

        if (mounted) {
          await provider.fetchOrdersForCustomDash(
            OrderStatus.draft,
            widget.customerId,
          );
          Navigator.of(context, rootNavigator: true).pop();
          _showOrderTypeDialog(context, provider, OrderStatus.draft, 'Draft',
              onContinueShopping: widget.onContinueShopping,
              offlineDraftDetails: freshOfflineDraftDetails);
        }
      };
    }

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
                          } else if (snapshot.hasError &&
                              (offlineDraftDetails == null)) {
                            return noDataFoundWidget(orderType);
                          } else {
                            final orders = snapshot.data?.data ?? [];
                            // offlineDraftDetails is available here for future use
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
                                      child: ScrollbarTheme(
                                        data: const ScrollbarThemeData(
                                          minThumbLength: 150,
                                          thickness: WidgetStatePropertyAll(5),
                                          thumbColor: WidgetStatePropertyAll(
                                              Colors.blue),
                                        ),
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          child: SingleChildScrollView(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 30),
                                                    child: DataTable(
                                                      dataRowHeight:
                                                          fontSize * 5.5,
                                                      headingRowHeight: 45,
                                                      columnSpacing: 10,
                                                      headingTextStyle:
                                                          TextStyle(
                                                              fontSize:
                                                                  fontSize + 1,
                                                              color: white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
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
                                                      rows: [
                                                        ...(filteredOrders
                                                                    .isEmpty &&
                                                                (offlineDraftDetails ==
                                                                        null ||
                                                                    offlineDraftDetails
                                                                        .isEmpty)
                                                            ? [
                                                                const DataRow(
                                                                  cells: [
                                                                    DataCell(Text(
                                                                        'Record Not Found')),
                                                                    DataCell(
                                                                        Text(
                                                                            '')),
                                                                    DataCell(
                                                                        Text(
                                                                            '')),
                                                                    DataCell(
                                                                        Text(
                                                                            '')),
                                                                    DataCell(
                                                                        Text(
                                                                            '')),
                                                                    DataCell(
                                                                        Text(
                                                                            '')),
                                                                    DataCell(
                                                                        Text(
                                                                            '')),
                                                                  ],
                                                                )
                                                              ]
                                                            : [
                                                                ...filteredOrders
                                                                    .map(
                                                                        (order) {
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
                                                                              CircleAvatar(
                                                                                radius: (fixedIconSize / 2) + 2,
                                                                                backgroundColor: const Color(0xffe6ecff),
                                                                                child: Icon(Icons.person, size: fixedIconSize, color: Colors.blue),
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
                                                                                      customer != null ? customer.fullName : 'N/A',
                                                                                      style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.bold),
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
                                                                                showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: orderType);
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
                                                                              order.orderCreatedAt != null ? getFormattedOrderCreatAt(order.orderCreatedAt.toString()) : 'N/A',
                                                                              style: TextStyle(fontSize: fontSize),
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
                                                                              style: TextStyle(fontSize: fontSize),
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
                                                                              // '',
                                                                              formatAmount((filteredOrders.isNotEmpty && offlineDraftDetails != null && offlineDraftDetails.isNotEmpty) ? offlineDraftTotal : ((filteredOrders.fold<double>(0.0, (sum, order) => sum + (order.orderTotal ?? 0.0))) + offlineDraftTotal)),
                                                                              // ext.formatAmount((offlineDraftDetails != null && offlineDraftDetails.isNotEmpty) ? (filteredOrders.fold<double>(0.0, (sum, order) => sum + (order.orderTotal ?? 0.0))) + (offlineDraftDetails.fold<double>(0.0, (sum, order) => sum + (order['displayData']['displayTotal'] ?? 0.0))) : order.orderTotal),
                                                                              maxLines: 1,
                                                                              style: TextStyle(fontSize: fontSize),
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
                                                                              decoration: const BoxDecoration(
                                                                                color: Color(0xffffdbb8),
                                                                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text(
                                                                                      getStatusName(order.orderStatus),
                                                                                      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                    if (order.orderStatus == 2 && order.deliveryDate != null) ...[
                                                                                      Text(
                                                                                        NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate?.toIso8601String() ?? '')),
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
                                                                      DataCell(
                                                                        SizedBox(
                                                                          width:
                                                                              flexWidth * 0.5,
                                                                          child:
                                                                              IconButton(
                                                                            onPressed:
                                                                                () async {
                                                                              if (orderType == 'Draft') {
                                                                                final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                                                                                widget.productsController.selectedCustomerId.value = customer?.customerId ?? '';
                                                                                widget.productsController.selectedCustomerName.value = customer?.businessName ?? '';
                                                                                widget.productsController.selectedCustomerMobileNo.value = customer?.mobileNo ?? '';
                                                                                widget.productsController.selectedCustomerEmail.value = customer?.email ?? '';
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return CartDialogue(
                                                                                      active: true,
                                                                                      cartItemCount: cartProvider.cartItemCount,
                                                                                      productsController: widget.productsController,
                                                                                      customerOrderController: customerOrderController,
                                                                                      onContinueShopping: onContinueShopping,
                                                                                      isFromCustomerDach: true,
                                                                                      isDashboard: false,
                                                                                      customerId: widget.customerId,
                                                                                      onDraftUpdated: onDraftUpdated,
                                                                                    );
                                                                                  },
                                                                                );
                                                                              } else {
                                                                                bool isOnline = await ConnectivityService().isOnline();
                                                                                if (isOnline) {
                                                                                  if (orderType != 'Draft' && orderType != 'Booking' && orderType != 'Estimate') {
                                                                                    showDetailedOrderInvoiceDialog(context, order.orderId, false);
                                                                                  }
                                                                                  if (orderType != 'Draft' && orderType == 'Booking') {
                                                                                    showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: 'BOOKING');
                                                                                  }
                                                                                  if (orderType != 'Draft' && orderType == 'Estimate') {
                                                                                    showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: 'ESTIMATE');
                                                                                  }
                                                                                } else {
                                                                                  showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                                                }
                                                                              }
                                                                            },
                                                                            icon:
                                                                                const Icon(
                                                                              Icons.visibility,
                                                                              size: 15,
                                                                              color: primaryColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }),
                                                                // --- OFFLINE DRAFTS ---
                                                                if (filteredOrders.isEmpty &&
                                                                    offlineDraftDetails !=
                                                                        null &&
                                                                    offlineDraftDetails
                                                                        .isNotEmpty)
                                                                  ...offlineDraftDetails
                                                                      .map(
                                                                    (draft) {
                                                                      final orderId = draft['order_id']
                                                                              .toString()
                                                                              .startsWith('DRAFT')
                                                                          ? draft['order_id']
                                                                          : '';

                                                                      final customerName =
                                                                          draft['displayData']['customerName'] ??
                                                                              'dummy_customerName';
                                                                      final customerId =
                                                                          draft['displayData']['customerId'] ??
                                                                              'dummy_customerName';
                                                                      final customerMobile =
                                                                          draft['displayData']['mobileNo'] ??
                                                                              'dummy_mobile';
                                                                      final customerEmail =
                                                                          draft['displayData']['email'] ??
                                                                              'dummy_email';
                                                                      final createdDate =
                                                                          draft['displayData']['createdDate'] ??
                                                                              'dummy_createdDate';
                                                                      final displayTotal =
                                                                          draft['displayData']['displayTotal'] ??
                                                                              'dummy_total';
                                                                      return DataRow(
                                                                        cells: [
                                                                          DataCell(
                                                                            SizedBox(
                                                                              width: flexWidth * 1.5,
                                                                              child: Row(
                                                                                children: [
                                                                                  CircleAvatar(
                                                                                    radius: (fixedIconSize / 2) + 2,
                                                                                    backgroundColor: const Color(0xffe6ecff),
                                                                                    child: Icon(Icons.person, size: fixedIconSize, color: Colors.blue),
                                                                                  ),
                                                                                  SizedBox(width: padding),
                                                                                  Flexible(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          customerName,
                                                                                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          customerMobile,
                                                                                          style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.bold),
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        Text(
                                                                                          customerEmail,
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
                                                                              width: flexWidth * 0.9,
                                                                              child: InkWell(
                                                                                onTap: () async {
                                                                                  bool isOnline = await ConnectivityService().isOnline();
                                                                                  if (isOnline) {
                                                                                    showDetailedOrderInvoiceDialog(context, orderId, false);
                                                                                  } else {
                                                                                    showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                                                  }
                                                                                },
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    orderId,
                                                                                    style: TextStyle(color: primaryColor, fontSize: fontSize, fontWeight: FontWeight.w600),
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
                                                                                  createdDate != null ? getFormattedOrderCreatAt(createdDate.toString()) : 'N/A',
                                                                                  style: TextStyle(fontSize: fontSize),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            SizedBox(
                                                                              width: flexWidth * 1,
                                                                              child: Center(
                                                                                child: Text(
                                                                                  '${SessionHelper.loginSavedData?.fullname} ${SessionHelper.loginSavedData?.lastname}',
                                                                                  style: TextStyle(fontSize: fontSize),
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
                                                                                  formatAmount(displayTotal),
                                                                                  maxLines: 1,
                                                                                  style: TextStyle(fontSize: fontSize),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            SizedBox(
                                                                              width: flexWidth * 1.1,
                                                                              child: Center(
                                                                                child: Container(
                                                                                  decoration: const BoxDecoration(
                                                                                    color: Color.fromARGB(255, 255, 183, 134),
                                                                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Text(
                                                                                          "Offline",
                                                                                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                                                                                          textAlign: TextAlign.center,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            SizedBox(
                                                                              width: flexWidth * 0.5,
                                                                              child: IconButton(
                                                                                onPressed: () {
                                                                                  if (orderType == 'Draft') {
                                                                                    widget.productsController.selectedCustomerId.value = customerId;
                                                                                    widget.productsController.selectedCustomerName.value = customerName;
                                                                                    widget.productsController.selectedCustomerMobileNo.value = customerMobile;
                                                                                    widget.productsController.selectedCustomerEmail.value = customerEmail;
                                                                                    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return CartDialogue(
                                                                                          active: true,
                                                                                          cartItemCount: cartProvider.cartItemCount,
                                                                                          productsController: widget.productsController,
                                                                                          customerOrderController: customerOrderController,
                                                                                          onContinueShopping: onContinueShopping,
                                                                                          isFromCustomerDach: true,
                                                                                          isDashboard: false,
                                                                                          customerId: widget.customerId,
                                                                                          onDraftUpdated: onDraftUpdated,
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  }
                                                                                },
                                                                                icon: const Icon(
                                                                                  Icons.visibility,
                                                                                  size: 15,
                                                                                  color: primaryColor,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ),
                                                              ]),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                              dataRowHeight: 0,
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
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: SizedBox(
                                        width: double.infinity,
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
                                                headingTextStyle: TextStyle(
                                                    fontSize: fontSize + 2,
                                                    color: white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                columns: [
                                                  const DataColumn(
                                                      label: Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'Total',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  const DataColumn(
                                                      label: Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        '',
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  )),
                                                  DataColumn(
                                                      label: Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        formatAmount((filteredOrders
                                                                    .isNotEmpty &&
                                                                offlineDraftDetails !=
                                                                    null &&
                                                                offlineDraftDetails
                                                                    .isNotEmpty)
                                                            ? offlineDraftTotal
                                                            : ((filteredOrders.fold<
                                                                        double>(
                                                                    0.0,
                                                                    (sum, order) =>
                                                                        sum +
                                                                        (order.orderTotal ??
                                                                            0.0))) +
                                                                offlineDraftTotal)),
                                                        maxLines: 2,
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
                                                                4.8),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width: flexWidth *
                                                                0.5),
                                                      ),
                                                      DataCell(
                                                        SizedBox(
                                                            width:
                                                                flexWidth * 4),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
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
  String unfilteredCount;
  String svg;
  Color svgBgColor;
  Color? color;
  VoidCallback? onTap;
  VoidCallback? onUnFilterTap;

  OptionData({
    required this.title,
    required this.count,
    required this.unfilteredCount,
    required this.svg,
    required this.svgBgColor,
    this.onTap,
    this.onUnFilterTap,
    this.color,
  });
}

Widget noOrderDataFoundWidget() {
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
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('Record Not Found')),
                          DataCell(Text('')),
                          DataCell(Text('')),
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
