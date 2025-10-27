// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_null_comparison

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/nodata_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/option/widgets/orderstatus_dialog/show_orderstatus_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';
import '../../../generated/assets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: must_be_immutable
class OptionWidget extends StatefulWidget {
  final UserType userType;
  final String userId;
  final (String, VoidCallback) Function(int index, OrderStatus orderStatus)?
      optionFun;
  final int orderCount;
  final int eastimatesCount;
  final int eastimatesFilterCount;
  final int preOrderCount;
  final int preOrderFilterCount;
  final int draftCount;
  final int draftFilterCount;
  final int cancelledCount;
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
    required this.orderCount,
    required this.eastimatesCount,
    required this.eastimatesFilterCount,
    required this.preOrderCount,
    required this.preOrderFilterCount,
    required this.draftCount,
    required this.draftFilterCount,
    required this.cancelledCount,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    this.isVisible = false,
    this.homeController,
  });

  @override
  State<OptionWidget> createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());

  ProductsController productsController = Get.find<ProductsController>();
  final subscriptionController = Get.find<SubscriptionController>();

  late LinkedScrollControllerGroup _controllers;

  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;

  late ScrollController _scrollController4;
  late ScrollController _scrollController5;
  late ScrollController _scrollController6;

  late ScrollController _scrollController7;
  late ScrollController _scrollController8;
  late ScrollController _scrollController9;

  int _offlineDraftCount = 0;
  int _onlineDraftCount = 0;
  int get _totalDraftCount => _offlineDraftCount + _onlineDraftCount;

  int _onlineUnfilteredDraftCount = 0;
  int get _totalUnfilteredDraftCount =>
      _offlineDraftCount + _onlineUnfilteredDraftCount;

  // Add: Function to get offline draft count for a customer
  Future<int> getOfflineDraftCount() async {
    try {
      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
      return drafts.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _fetchDraftCounts(OrderCountListt? orderCountList) async {
    int offlineCount = await getOfflineDraftCount();
    int onlineCount =
        orderCountList != null ? (orderCountList.draftFilteredCount ?? 0) : 0;
    int onlineUnfilteredCount =
        orderCountList != null ? (orderCountList.draftOrder ?? 0) : 0;
    setState(() {
      _offlineDraftCount = offlineCount;
      _onlineDraftCount = onlineCount;
      _onlineUnfilteredDraftCount = onlineUnfilteredCount;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeDraftCounts();

    _controllers = LinkedScrollControllerGroup();

    // SET 1
    _scrollController1 = _controllers.addAndGet();
    _scrollController2 = _controllers.addAndGet();
    _scrollController3 = _controllers.addAndGet();

    // SET 2
    _scrollController4 = _controllers.addAndGet();
    _scrollController5 = _controllers.addAndGet();
    _scrollController6 = _controllers.addAndGet();

    // SET 3
    _scrollController7 = _controllers.addAndGet();
    _scrollController8 = _controllers.addAndGet();
    _scrollController9 = _controllers.addAndGet();
  }

  Future<void> _initializeDraftCounts() async {
    await _fetchDraftCounts(null);
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
              // return options(
              //     OrderCountListt(
              //       cancelOrder: 0,
              //       draftFilteredCount: 0,
              //       draftOrder: 0,
              //       estimateFilterOrder: 0,
              //       estimateOrder: 0,
              //       preorderFilterOrder: 0,
              //       preorderOrder: 0,
              //       totalOrder: 0,
              //     ),
              //     context,
              //     provider);
            } else if (snapshot.hasData) {
              final countData = snapshot.data!.orderCountList;

              _fetchDraftCounts(countData);

              return options(countData, context, provider);
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
          DashboardProvider provider, OrderCountListt? orderCountList) =>
      [
        OptionData(
          title: 'Orders',
          count: widget.orderCount.toString(),
          unfilteredCount: 0.toString(),
          svg: Assets.iconsIcDashboardShoppingCart,
          svgBgColor: const Color.fromARGB(255, 229, 242, 254),
          color: const Color.fromARGB(255, 55, 74, 134),
          onTap: () {
            if (orderCountList?.totalOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.delivered);
              showOrderStatusDialog(
                context,
                provider,
                OrderStatus.delivered,
                _scrollController1,
                _scrollController2,
                _scrollController3,
              );
            }
          },
        ),
        OptionData(
          title: 'Estimates',
          unfilteredCount: widget.eastimatesCount.toString(),
          count: widget.eastimatesFilterCount.toString(),
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color.fromARGB(255, 226, 249, 243),
          color: const Color.fromARGB(255, 36, 108, 44),
          onTap: () {
            if (orderCountList?.estimateFilterOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.estimates, checkDate: true);
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.estimates,
                'Estimate',
                false,
                productsController,
                customerOrderController,
                widget.homeController,
              );
            }
          },
          onUnFilterTap: () {
            if (orderCountList?.estimateOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.estimates, checkDate: false);
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.estimates,
                'Estimate',
                false,
                productsController,
                customerOrderController,
                widget.homeController,
              );
            }
          },
        ),
        OptionData(
          title: 'Bookings',
          unfilteredCount: widget.preOrderCount.toString(),
          count: widget.preOrderFilterCount.toString(),
          svg: Assets.iconsIcDashboardPreOrder,
          svgBgColor: const Color.fromARGB(255, 230, 247, 251),
          color: const Color.fromARGB(255, 45, 104, 116),
          onTap: () {
            if (subscriptionController.bookingView.value == 'true') {
              if (orderCountList?.preorderFilterOrder.toString() == "0") {
                showCustomToastDisplay(
                    context, "No Record Found", red, Icons.close);
              } else {
                provider.fetchOrdersData(OrderStatus.preOrder, checkDate: true);
                _showOrderTypeDialog(
                  context,
                  provider,
                  OrderStatus.preOrder,
                  'Booking',
                  false,
                  productsController,
                  customerOrderController,
                  widget.homeController,
                );
              }
            } else {
              showUpgradePlanDialog(context);
            }
          },
          onUnFilterTap: () {
            if (subscriptionController.bookingView.value == 'true') {
              if (orderCountList?.preorderOrder.toString() == "0") {
                showCustomToastDisplay(
                    context, "No Record Found", red, Icons.close);
              } else {
                provider.fetchOrdersData(OrderStatus.preOrder,
                    checkDate: false);
                _showOrderTypeDialog(
                  context,
                  provider,
                  OrderStatus.preOrder,
                  'Booking',
                  false,
                  productsController,
                  customerOrderController,
                  widget.homeController,
                );
              }
            } else {
              showUpgradePlanDialog(context);
            }
          },
        ),
        OptionData(
          title: 'Drafts',
          // unfilteredCount: 0.toString(),
          unfilteredCount: widget.draftCount.toString(),
          // count: widget.draftCount.toString(),
          count: widget.draftFilterCount.toString(),
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color.fromARGB(255, 255, 227, 255),
          color: const Color.fromARGB(255, 100, 43, 109),
          onTap: () async {
            var offlineDraftsBox = await Hive.openBox('offlineDrafts');
            List<dynamic> drafts = offlineDraftsBox
                .get('drafts', defaultValue: []) as List<dynamic>;
            List<dynamic> offlineDraftDetails = drafts.toList();
            if (_totalDraftCount == 0) {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              // Draft filtering handled within the app, not using checkDate
              provider.fetchOrdersData(
                OrderStatus.draft,
                checkDate: false,
              );
              _showDraftDialog(
                context,
                provider,
                OrderStatus.draft,
                'Draft',
                true,
                productsController,
                customerOrderController,
                widget.homeController,
                offlineDraftDetails: offlineDraftDetails,
                filterNeeded: true,
              );
              CartDatabaseManager().getDraftItems();
            }
          },
          onUnFilterTap: () async {
            var offlineDraftsBox = await Hive.openBox('offlineDrafts');
            List<dynamic> drafts = offlineDraftsBox
                .get('drafts', defaultValue: []) as List<dynamic>;
            List<dynamic> offlineDraftDetails = drafts.toList();
            if (_totalUnfilteredDraftCount == 0) {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersData(
                OrderStatus.draft,
                checkDate: false,
              );
              _showDraftDialog(
                context,
                provider,
                OrderStatus.draft,
                'Draft',
                true,
                productsController,
                customerOrderController,
                widget.homeController,
                offlineDraftDetails: offlineDraftDetails,
                filterNeeded: false,
              );
              CartDatabaseManager().getDraftItems();
            }
          },
        ),
        OptionData(
          title: 'Cancelled',
          unfilteredCount: 0.toString(),
          count: widget.cancelledCount.toString(),
          svg: Assets.iconsIcDashboardCancel,
          svgBgColor: const Color.fromARGB(255, 255, 228, 228),
          color: const Color.fromARGB(255, 139, 27, 27),
          onTap: () {
            if (orderCountList?.cancelOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found", red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.cancelled);
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.cancelled,
                'Cancelled',
                false,
                productsController,
                customerOrderController,
                widget.homeController,
              );
            }
          },
        ),
      ];

  Widget orderOptions(OptionData optionData, OrderCountListt? orderCountList,
      BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance.height * 0.02,
      fit: BoxFit.contain,
    );

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
                horizontal: AppDimensions.instance.width * 0.001,
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
                            // leave space for badge
                            SizedBox(width: 30),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Red count badge brought to front with hit area
            if (_getUnFilteredCountForTitle(optionData.title, orderCountList) !=
                "0")
              Positioned(
                right: 12,
                top: isPhonePortrait(context) ? 20 : 24,
                child: InkWell(
                  onTap: optionData.onUnFilterTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8), // 8px hit area
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: red,
                      child: CustomText(
                        content: _getUnFilteredCountForTitle(
                            optionData.title, orderCountList),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
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

  String _getCountForTitle(String title, OrderCountListt? orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return orderCountList?.totalOrder.toString() ?? "0";
      case 'estimates':
        return orderCountList?.estimateFilterOrder.toString() ?? "0";
      case 'bookings':
        return orderCountList?.preorderFilterOrder.toString() ?? "0";
      case 'drafts':
        // return orderCountList?.draftOrder.toString() ?? "0";
        return _totalDraftCount.toString();
      case 'cancelled':
        return orderCountList?.cancelOrder.toString() ?? "0";
      default:
        return "0";
    }
  }

  String _getUnFilteredCountForTitle(
      String title, OrderCountListt? orderCountList) {
    switch (title.toLowerCase()) {
      case 'orders':
        return "0";
      case 'estimates':
        return orderCountList?.estimateOrder.toString() ?? "0";
      case 'bookings':
        return orderCountList?.preorderOrder.toString() ?? "0";
      case 'drafts':
        return _totalUnfilteredDraftCount.toString();
      case 'cancelled':
        return "0";
      default:
        return "0";
    }
  }

  void _showDraftDialog(
      BuildContext context,
      DashboardProvider provider,
      OrderStatus selectedOrderStatus,
      String orderType,
      bool isDraft,
      ProductsController productsController,
      CustomerAndOrderController customerOrderController,
      HomeController? homeController,
      {List<dynamic>? offlineDraftDetails,
      bool filterNeeded = false}) {
    final HomeController homeController2 = Get.put(HomeController());

    VoidCallback? onDraftUpdated;
    if (isDraft) {
      onDraftUpdated = () async {
        List<dynamic> freshOfflineDraftDetails = [];
        try {
          var offlineDraftsBox = await Hive.openBox('offlineDrafts');
          List<dynamic> drafts =
              offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
          freshOfflineDraftDetails = drafts.toList();
        } catch (e) {
      //
        }

        if (mounted) {
          await provider.fetchOrdersData(OrderStatus.draft, checkDate: false);
          Navigator.of(context, rootNavigator: true).pop();
          _showDraftDialog(
            context,
            provider,
            selectedOrderStatus,
            orderType,
            isDraft,
            productsController,
            customerOrderController,
            homeController,
            offlineDraftDetails: freshOfflineDraftDetails,
          );
        }
      };
    }

    showDialog(
      barrierDismissible: false,
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
                          } else {
                            final orders = snapshot.data?.data ?? [];

                            final filteredOrdersOg = orders.where((order) {
                              return order.orderStatus ==
                                  selectedOrderStatus.type;
                            }).toList();

                            final filteredOrders = filterNeeded
                                ? _applyDateFiltering(
                                    filteredOrdersOg, provider)
                                : filteredOrdersOg;

                            // Handle offline and online order duplication
                            // If online order for a customer exists and same customer has an offline draft,
                            // don't display the offline draft, but add its total to the online order total
                            Map<String, double> customerOfflineTotals = {};
                            List<dynamic> filteredOfflineDrafts = [];

                            if (offlineDraftDetails != null &&
                                offlineDraftDetails.isNotEmpty) {
                              for (var draft in offlineDraftDetails) {
                                final customerId =
                                    draft['displayData']['customerId'];
                                final displayTotal =
                                    draft['displayData']['displayTotal'] ?? 0.0;

                                // Check if this customer has an online draft
                                bool hasOnlineDraft =
                                    filteredOrders.any((order) {
                                  final customer = order.customer.isNotEmpty
                                      ? order.customer[0]
                                      : null;
                                  return customer?.customerId == customerId;
                                });

                                if (hasOnlineDraft) {
                                  // Add offline total to customer's offline totals map
                                  customerOfflineTotals[customerId] =
                                      (customerOfflineTotals[customerId] ??
                                              0.0) +
                                          displayTotal;
                                } else {
                                  // No online draft for this customer, keep offline draft visible
                                  filteredOfflineDrafts.add(draft);
                                }
                              }
                            }

                            return LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                double availableWidth = constraints.maxWidth;
                                double fontSize = isPhonePortrait(context)
                                    ? 14
                                    : availableWidth * 0.017;
                                double padding = availableWidth / 100;
                                double fixedIconSize = fontSize;
                                double flexWidth = isPhonePortrait(context)
                                    ? availableWidth / 3.5
                                    : availableWidth / 9;

                                return Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController7,
                                          child: SizedBox(
                                            width: isPhonePortrait(context)
                                                ? fullScreenWidth(context) * 2.3
                                                : fullScreenWidth(context),
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
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: DataTable(
                                                            dataRowHeight:
                                                                fontSize * 5.5,
                                                            // horizontalMargin: 5,
                                                            headingRowHeight:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 75
                                                                    : 45,
                                                            columnSpacing: 10,
                                                            headingTextStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        fontSize +
                                                                            1,
                                                                    color:
                                                                        white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                            columns: [
                                                              const DataColumn(
                                                                  label:
                                                                      Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    'Customer List',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              )),
                                                              DataColumn(
                                                                  label:
                                                                      Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    '$orderType No.',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              )),
                                                              const DataColumn(
                                                                  label:
                                                                      Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    'Created',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              )),
                                                              const DataColumn(
                                                                  label:
                                                                      Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    'Created By',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              )),
                                                              DataColumn(
                                                                  label:
                                                                      Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    '$orderType Amount',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              )),
                                                              const DataColumn(
                                                                  label:
                                                                      Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    'Status',
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              )),
                                                              const DataColumn(
                                                                  label:
                                                                      Expanded(
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
                                                                      filteredOfflineDrafts
                                                                          .isEmpty)
                                                                  ? [
                                                                      const DataRow(
                                                                          cells: [
                                                                            DataCell(Text('Record Not Found')),
                                                                            DataCell(Text('')),
                                                                            DataCell(Text('')),
                                                                            DataCell(Text('')),
                                                                            DataCell(Text('')),
                                                                            DataCell(Text('')),
                                                                            DataCell(Text('')),
                                                                          ])
                                                                    ]
                                                                  : [
                                                                      ...filteredOrders
                                                                          .map(
                                                                              (order) {
                                                                        final customer = order.customer.isNotEmpty
                                                                            ? order.customer[0]
                                                                            : null;

                                                                        // Get offline total for this customer if exists
                                                                        final offlineTotal = customer?.customerId !=
                                                                                null
                                                                            ? customerOfflineTotals[customer?.customerId] ??
                                                                                0.0
                                                                            : 0.0;

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
                                                                                width: flexWidth * 1,
                                                                                child: InkWell(
                                                                                  onTap: () async {
                                                                                    bool isOnline = await ConnectivityService().isOnline();
                                                                                    if (isOnline) {
                                                                                      showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: orderType);
                                                                                    } else {
                                                                                      showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                                                    }
                                                                                  },
                                                                                  child: Center(
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
                                                                                width: flexWidth * 1,
                                                                                child: Center(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        order.orderCreatedAt != null ? getFormattedOrderCreatAt(order.orderCreatedAt.toString()) : 'N/A',
                                                                                        style: TextStyle(
                                                                                          fontSize: fontSize,
                                                                                        ),
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                      Text(
                                                                                        order.orderCreatedAt != null ? NKDateUtils.commonTimeOnlyFormat(order.orderCreatedAt) : 'N/A',
                                                                                        style: TextStyle(
                                                                                          fontSize: fontSize,
                                                                                        ),
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ],
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
                                                                                      fontSize: fontSize,
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
                                                                                    // formatAmount(order.orderTotal),
                                                                                    formatAmount(offlineTotal != 0 ? offlineTotal : (order.orderTotal ?? 0.0)),
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
                                                                                width: flexWidth * 1.1,
                                                                                child: Center(
                                                                                  child: Container(
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
                                                                                              NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate!.toIso8601String())),
                                                                                              textAlign: TextAlign.center,
                                                                                              maxLines: 2,
                                                                                              style: const TextStyle(
                                                                                                fontSize: 10.0,
                                                                                                fontWeight: FontWeight.w400,
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
                                                                            DataCell(SizedBox(
                                                                              width: flexWidth * 0.5,
                                                                              child: IconButton(
                                                                                  onPressed: () async {
                                                                                    if (orderType == 'Draft') {
                                                                                      final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                                                                                      productsController.selectedCustomerId.value = customer?.customerId ?? '';
                                                                                      productsController.selectedCustomerName.value = customer?.businessName ?? '';
                                                                                      productsController.selectedCustomerMobileNo.value = customer?.mobileNo ?? '';
                                                                                      productsController.selectedCustomerEmail.value = customer?.email ?? '';
                                                                                      customerOrderController.customerId.value = customer?.customerId ?? '';
                                                                                      customerOrderController.customerId.value = customer?.customerId ?? '';
                                                                                      showDialog(
                                                                                        barrierDismissible: false,
                                                                                        context: context,
                                                                                        builder: (BuildContext context) {
                                                                                          return CartDialogue(
                                                                                            active: true,
                                                                                            cartItemCount: cartProvider.cartItemCount,
                                                                                            productsController: productsController,
                                                                                            customerOrderController: customerOrderController,
                                                                                            isDashboard: true,
                                                                                            customerId: customer?.customerId ?? '',
                                                                                            onContinueShopping: () {
                                                                                              Future.delayed(const Duration(milliseconds: 300), () {
                                                                                                _initializeCustomerData(customer?.customerId ?? '', customer?.businessName ?? '', customer?.imageUrl ?? '', productsController, customerOrderController);
                                                                                                widget.homeController?.sidebarXController.selectIndex(2);
                                                                                                widget.homeController?.selectedIndex.value = 2;
                                                                                                Get.to(
                                                                                                    () => OrderTaking(
                                                                                                          productsController: productsController,
                                                                                                        ),
                                                                                                    id: 2);
                                                                                              });
                                                                                            },
                                                                                            onDraftUpdated: onDraftUpdated,
                                                                                          );
                                                                                        },
                                                                                      );
                                                                                    } else {
                                                                                      bool isOnline = await ConnectivityService().isOnline();
                                                                                      if (isOnline) {
                                                                                        if (orderType != 'Booking' && orderType != 'Estimate') {
                                                                                          showDetailedOrderInvoiceDialog(context, order.orderId, false);
                                                                                        }
                                                                                        if (orderType == 'Booking') {
                                                                                          showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: 'BOOKING');
                                                                                        }
                                                                                        if (orderType == 'Estimate') {
                                                                                          showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: 'ESTIMATE');
                                                                                        }
                                                                                      } else {
                                                                                        showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                                                      }
                                                                                    }
                                                                                  },
                                                                                  icon: const Icon(
                                                                                    Icons.visibility,
                                                                                    size: 15,
                                                                                    color: primaryColor,
                                                                                  )),
                                                                            )),
                                                                          ],
                                                                        );
                                                                      }),
                                                                      // --- OFFLINE DRAFTS --- - FIRST OCCURRENCE
                                                                      if (filteredOfflineDrafts
                                                                          .isNotEmpty)
                                                                        ...filteredOfflineDrafts
                                                                            .map((draft) {
                                                                          final orderId = draft['order_id'].toString().startsWith('DRAFT')
                                                                              ? draft['order_id']
                                                                              : '';

                                                                          final customerId =
                                                                              draft['displayData']['customerId'] ?? 'dummy_customerName';
                                                                          final customerName =
                                                                              draft['displayData']['customerName'] ?? 'dummy_customerName';
                                                                          final customerMobile =
                                                                              draft['displayData']['mobileNo'] ?? 'dummy_mobile';
                                                                          final customerEmail =
                                                                              draft['displayData']['email'] ?? 'dummy_email';
                                                                          final createdDate =
                                                                              draft['displayData']['createdDate'] ?? 'dummy_createdDate';
                                                                          final displayTotal =
                                                                              draft['displayData']['displayTotal'] ?? 'dummy_total';
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
                                                                                            // '${ApiConstants.baseUrl1}/uploads/${customer?.imageUrl}',
                                                                                            '',
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
                                                                              ), // Customer List (dummy)
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
                                                                                      "${SessionHelper.loginSavedData?.fullname?.nkStringCapitalizeFirstCaracter} ${SessionHelper.loginSavedData?.lastname}",
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
                                                                                        final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                                                                                        productsController.selectedCustomerId.value = customerId;
                                                                                        productsController.selectedCustomerName.value = customerName;
                                                                                        productsController.selectedCustomerMobileNo.value = customerMobile;
                                                                                        productsController.selectedCustomerEmail.value = customerEmail;
                                                                                        showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) {
                                                                                            return CartDialogue(
                                                                                              active: true,
                                                                                              cartItemCount: cartProvider.cartItemCount,
                                                                                              productsController: productsController,
                                                                                              customerOrderController: customerOrderController,
                                                                                              isDashboard: true,
                                                                                              customerId: customerId,
                                                                                              onContinueShopping: () {
                                                                                                Future.delayed(const Duration(milliseconds: 300), () {
                                                                                                  _initializeCustomerData(customerId, customerName, customerEmail, productsController, customerOrderController);
                                                                                                  homeController2.sidebarXController.selectIndex(2);
                                                                                                  homeController2.selectedIndex.value = 2;
                                                                                                  Get.to(
                                                                                                      () => OrderTaking(
                                                                                                            productsController: productsController,
                                                                                                            selectedCustId: customerId ?? '',
                                                                                                          ),
                                                                                                      id: 2);
                                                                                                });
                                                                                              },
                                                                                              onDraftUpdated: onDraftUpdated, // Pass the callback
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
                                                                        }),
                                                                    ]
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController9,
                                          child: SizedBox(
                                            width: isPhonePortrait(context)
                                                ? fullScreenWidth(context) * 2.3
                                                : fullScreenWidth(context),
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
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            'Total',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      DataColumn(
                                                          label: Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            formatAmount(filteredOrders
                                                                    .fold<double>(
                                                                        0.0,
                                                                        (sum,
                                                                            order) {
                                                                  final customer = order
                                                                          .customer
                                                                          .isNotEmpty
                                                                      ? order
                                                                          .customer[0]
                                                                      : null;
                                                                  final customerId =
                                                                      customer
                                                                          ?.customerId;

                                                                  if (customerId !=
                                                                          null &&
                                                                      customerOfflineTotals
                                                                          .containsKey(
                                                                              customerId)) {
                                                                    // If offline draft exists for this customer, use ONLY offline total
                                                                    final offlineAmount =
                                                                        customerOfflineTotals[
                                                                            customerId]!;
                                                                    return sum +
                                                                        offlineAmount;
                                                                  } else {
                                                                    // Otherwise use online total
                                                                    final onlineAmount =
                                                                        order.orderTotal ??
                                                                            0.0;
                                                                    return sum +
                                                                        onlineAmount;
                                                                  }
                                                                })
                                                                // Add totals from offline drafts that are displayed separately
                                                                +
                                                                filteredOfflineDrafts
                                                                    .fold<double>(
                                                                        0.0,
                                                                        (sum,
                                                                            draft) {
                                                                  final offlineAmount =
                                                                      draft['displayData']
                                                                              [
                                                                              'displayTotal'] ??
                                                                          0.0;
                                                                  return sum +
                                                                      offlineAmount;
                                                                })),
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
                                                                        4.8),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        0.4),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        4),
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
                                      ],
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController8,
                                      child: SizedBox(
                                        width: isPhonePortrait(context)
                                            ? fullScreenWidth(context) * 2.3
                                            : fullScreenWidth(context),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: DataTable(
                                                  dataRowHeight: 0,
                                                  headingRowHeight:
                                                      isPhonePortrait(context)
                                                          ? 75
                                                          : 45,
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
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Customer List',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: Center(
                                                          child: Text(
                                                            '$orderType No.',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Created',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Created By',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: Center(
                                                          child: Text(
                                                            '$orderType Amount',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Status',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: SizedBox(
                                                          width:
                                                              flexWidth * 0.5),
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
                                                              width: flexWidth *
                                                                  1),
                                                        ),
                                                        DataCell(
                                                          SizedBox(
                                                              width: flexWidth *
                                                                  1),
                                                        ),
                                                        DataCell(
                                                          SizedBox(
                                                              width: flexWidth *
                                                                  1),
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
                                                      ],
                                                    )
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

  // Helper method to apply date filtering based on provider's filter settings
  List<OrdersDash> _applyDateFiltering(
      List<OrdersDash> orders, DashboardProvider provider) {
    if (orders.isEmpty) {
      return orders;
    }

    debugPrint(
        "[Filter] Orders BEFORE filtering (sample): ${orders.take(5).map((o) => o.orderCreatedAt).toList()}");

    List<OrdersDash> filteredOrders = [];

    switch (provider.selectedFilter) {
      case FilterDateEnum.today:
        if (provider.selectedDate.isNotEmpty) {
          final selectedDate = DateTime.parse(provider.selectedDate);
          final today =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
          filteredOrders = orders.where((order) {
            if (order.orderCreatedAt == null) return false;
            final orderDate = DateTime.parse(order.orderCreatedAt.toString());
            final orderDay =
                DateTime(orderDate.year, orderDate.month, orderDate.day);
            return orderDay.isAtSameMomentAs(today);
          }).toList();
        } else {
          filteredOrders = orders;
        }
        break;

      case FilterDateEnum.thisWeek:
        if (provider.selectedFilterWeeks.isNotEmpty) {
          filteredOrders = orders.where((order) {
            if (order.orderCreatedAt == null) return false;
            final orderDate = DateTime.parse(order.orderCreatedAt.toString());

            final weekNumber = ((orderDate
                        .difference(DateTime(orderDate.year, 1, 1))
                        .inDays) ~/
                    7) +
                1;

            final weekName = "week$weekNumber";
            return provider.selectedFilterWeeks.contains(weekName);
          }).toList();
        } else {
          filteredOrders = orders;
        }
        break;

      case FilterDateEnum.thisMonth:
        debugPrint(
            "[Filter] Selected Months: ${provider.selectedFilterMonths}");
        if (provider.selectedFilterMonths.isNotEmpty) {
          filteredOrders = orders.where((order) {
            if (order.orderCreatedAt == null) return false;
            final orderDate = DateTime.parse(order.orderCreatedAt.toString());
            final monthNames = [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ];
            final orderMonthName = monthNames[orderDate.month - 1];
            return provider.selectedFilterMonths.contains(orderMonthName);
          }).toList();
        } else {
          filteredOrders = orders;
        }
        break;

      case FilterDateEnum.thisYear:
        final selectedYear = provider.selectedYear;
        filteredOrders = orders.where((order) {
          if (order.orderCreatedAt == null) return false;
          final orderDate = DateTime.parse(order.orderCreatedAt.toString());
          return orderDate.year == selectedYear;
        }).toList();
        break;

      case FilterDateEnum.range:
        debugPrint(
            "[Filter] Selected Range: ${provider.selectedStartDate} → ${provider.selectedEndDate}");
        if (provider.selectedStartDate.isNotEmpty &&
            provider.selectedEndDate.isNotEmpty) {
          final startDate = DateTime.parse(provider.selectedStartDate);
          final endDate = DateTime.parse(provider.selectedEndDate);
          filteredOrders = orders.where((order) {
            if (order.orderCreatedAt == null) return false;
            final orderDate = DateTime.parse(order.orderCreatedAt.toString());
            return orderDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                orderDate.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();
        } else {
          filteredOrders = orders;
        }
        break;
    }

    debugPrint(
        "[Filter] Orders AFTER filtering: count = ${filteredOrders.length}");
    debugPrint(
        "[Filter] Orders AFTER filtering (sample): ${filteredOrders.take(5).map((o) => o.orderCreatedAt).toList()}");

    return filteredOrders;
  }

  void _showOrderTypeDialog(
    BuildContext context,
    DashboardProvider provider,
    OrderStatus selectedOrderStatus,
    String orderType,
    bool isDraft,
    ProductsController productsController,
    CustomerAndOrderController customerOrderController,
    HomeController? homeController,
  ) {
    showDialog(
      barrierDismissible: false,
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
                                double fontSize = isPhonePortrait(context)
                                    ? 14
                                    : (availableWidth * 0.017).clamp(7.0, 15.0);
                                double padding = availableWidth / 100;
                                double fixedIconSize = fontSize;
                                double flexWidth = isPhonePortrait(context)
                                    ? availableWidth / 3.5
                                    : availableWidth / 9;

                                return Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController4,
                                          child: SizedBox(
                                            width: isPhonePortrait(context)
                                                ? fullScreenWidth(context) * 2.3
                                                : fullScreenWidth(context),
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
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: DataTable(
                                                          dataRowHeight:
                                                              fontSize * 5.5,
                                                          // horizontalMargin: 5,
                                                          headingRowHeight:
                                                              isPhonePortrait(
                                                                      context)
                                                                  ? 75
                                                                  : 45,
                                                          columnSpacing: 10,
                                                          headingTextStyle:
                                                              TextStyle(
                                                                  fontSize:
                                                                      fontSize +
                                                                          1,
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
                                                          rows: filteredOrders
                                                                  .isEmpty
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
                                                                              flexWidth * 1,
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
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  order.orderCreatedAt != null ? getFormattedOrderCreatAt(order.orderCreatedAt.toString()) : 'N/A',
                                                                                  style: TextStyle(
                                                                                    fontSize: fontSize,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                Text(
                                                                                  order.orderCreatedAt != null ? NKDateUtils.commonTimeOnlyFormat(order.orderCreatedAt) : 'N/A',
                                                                                  style: TextStyle(
                                                                                    fontSize: fontSize,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ],
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
                                                                                        NKDateUtils.commonFullDateTimeFormat(NKDateUtils.formatStringUTCDateTime(order.deliveryDate!.toIso8601String())),
                                                                                        textAlign: TextAlign.center,
                                                                                        maxLines: 2,
                                                                                        style: const TextStyle(
                                                                                          fontSize: 10.0,
                                                                                          fontWeight: FontWeight.w400,
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
                                                                      DataCell(
                                                                          SizedBox(
                                                                        width: flexWidth *
                                                                            0.5,
                                                                        child: IconButton(
                                                                            onPressed: () async {
                                                                              bool isOnline = await ConnectivityService().isOnline();
                                                                              if (isOnline) {
                                                                                if (orderType != 'Booking' && orderType != 'Estimate') {
                                                                                  showDetailedOrderInvoiceDialog(context, order.orderId, false);
                                                                                }
                                                                                if (orderType == 'Booking') {
                                                                                  showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: 'BOOKING');
                                                                                }
                                                                                if (orderType == 'Estimate') {
                                                                                  showDetailedOrderInvoiceDialog(context, order.orderId, false, changedTitle: 'ESTIMATE');
                                                                                }
                                                                              } else {
                                                                                showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
                                                                              }
                                                                            },
                                                                            icon: const Icon(
                                                                              Icons.visibility,
                                                                              size: 15,
                                                                              color: primaryColor,
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
                                            ),
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController6,
                                          child: SizedBox(
                                            width: isPhonePortrait(context)
                                                ? fullScreenWidth(context) * 2.3
                                                : fullScreenWidth(context),
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
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            'Total',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      const DataColumn(
                                                          label: Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      )),
                                                      DataColumn(
                                                          label: Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            formatAmount(filteredOrders.fold<
                                                                    double>(
                                                                0.0,
                                                                (sum, order) =>
                                                                    sum +
                                                                    (order.orderTotal ??
                                                                        0.0))),
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
                                                                        4.8),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        0.4),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                                width:
                                                                    flexWidth *
                                                                        4),
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
                                      ],
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController5,
                                      child: SizedBox(
                                        width: isPhonePortrait(context)
                                            ? fullScreenWidth(context) * 2.3
                                            : fullScreenWidth(context),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: DataTable(
                                                  dataRowHeight: 0,
                                                  headingRowHeight:
                                                      isPhonePortrait(context)
                                                          ? 75
                                                          : 45,
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
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Customer List',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: Center(
                                                          child: Text(
                                                            '$orderType No.',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Created',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Created By',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: Center(
                                                          child: Text(
                                                            '$orderType Amount',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                            top:
                                                                isPhonePortrait(
                                                                        context)
                                                                    ? 30
                                                                    : 0),
                                                        child: const Center(
                                                          child: Text(
                                                            'Status',
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                    DataColumn(
                                                        label: Expanded(
                                                      child: SizedBox(
                                                          width:
                                                              flexWidth * 0.5),
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
                                                              width: flexWidth *
                                                                  1),
                                                        ),
                                                        DataCell(
                                                          SizedBox(
                                                              width: flexWidth *
                                                                  1),
                                                        ),
                                                        DataCell(
                                                          SizedBox(
                                                              width: flexWidth *
                                                                  1),
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
                                                      ],
                                                    )
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

Future<void> _initializeCustomerData(
    String customerId,
    String businessName,
    String customerImage,
    ProductsController productsController,
    CustomerAndOrderController customerAndOrderController) async {
  if (customerId.isEmpty) {
    return;
  }
  customerAndOrderController.setCustomerId(customerId);
  productsController.selectedCustomerId.value = customerId;
  productsController.updateSelectedCustomer(
    name: businessName,
    imageUrl: customerImage,
    id: customerId,
  );
}

Text text(List<InvoiceDash> invoices, dynamic s) {
  String invoiceId = invoices.map((invoice) => invoice.invoiceId).join(', ');
  return Text(invoiceId,
      style: TextStyle(
        fontSize: s,
        color: primaryColor,
        fontWeight: FontWeight.w400,
      ));
}
