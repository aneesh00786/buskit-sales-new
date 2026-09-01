// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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

  late LinkedScrollControllerGroup _controllers;

  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;

  late ScrollController _scrollController4;
  late ScrollController _scrollController5;
  late ScrollController _scrollController6;

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

    _controllers = LinkedScrollControllerGroup();

    // SET 1
    _scrollController1 = _controllers.addAndGet();
    _scrollController2 = _controllers.addAndGet();
    _scrollController3 = _controllers.addAndGet();

    // SET 2
    _scrollController4 = _controllers.addAndGet();
    _scrollController5 = _controllers.addAndGet();
    _scrollController6 = _controllers.addAndGet();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                  context, "No Record Found".tr, red, Icons.close);
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
                    context, "You are Offline!".tr, red, Icons.close);
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
                  context, "No Record Found".tr, red, Icons.close);
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
                    context, "You are Offline!".tr, red, Icons.close);
              }
            }
          },
          onUnFilterTap: () async {
            if (orderCountList.estimateOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found".tr, red, Icons.close);
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
                    context, "You are Offline!".tr, red, Icons.close);
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
                  context, "No Record Found".tr, red, Icons.close);
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
                    context, "You are Offline!".tr, red, Icons.close);
              }
            }
          },
          onUnFilterTap: () async {
            if (orderCountList.preorderOrder.toString() == "0") {
              showCustomToastDisplay(
                  context, "No Record Found".tr, red, Icons.close);
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
                    context, "You are Offline!".tr, red, Icons.close);
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
                  context, "No Record Found".tr, red, Icons.close);
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
                    context, "You are Offline!".tr, red, Icons.close);
              }
            }
          },
        ),
      ];

  Widget orderOptions(
      OptionData optionData, OrderDataas orderCountList, BuildContext context) {
    Image svgComponent = Image.asset(
      optionData.svg,
      height: AppDimensions.instance.height * 0.02,
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
            horizontal: AppDimensions.instance.width * 0.001,
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
                        content: optionData.title.tr,
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
                          content: optionData.title.tr,
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
                top: isPhonePortrait(context) ? 20 : 24,
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

  Widget _buildStatusBadge(int? orderStatus, String text) {
    final status = OrderHandlingClass.fromType(orderStatus ?? 0);
    final Color bg = status.statusBgColor;
    final Color textColor = status.statusTextColor;
    final Color dotColor = status.statusDotColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dotColor.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text.tr,
            style: TextStyle(
              fontFamily: 'Poppins_Regular',
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState(String title, String subtitle, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title.tr,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle.tr,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 12.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOrderStatusDialog(BuildContext context, CustomersProvider provider,
      OrderStatus selectedOrderStatus) {
    final ScrollController verticalScrollController = ScrollController();
    final ScrollController horizontalScrollController = ScrollController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: screenHeight * 0.88,
            ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<OrderResponse>(
                future: provider.orderResponse,
                builder: (context, snapshot) {
                  final orders = snapshot.data?.data ?? [];
                  final filteredOrders = orders.toList();
                  final double totalSum = filteredOrders.fold<double>(
                    0.0,
                    (sum, order) => sum + (order.orderTotal ?? 0.0),
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- HEADER ---
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
                                    fontFamily: 'Poppins_Regular',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (snapshot.connectionState == ConnectionState.done) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                                    ),
                                    child: Text(
                                      '${filteredOrders.length} ${'Records'.tr}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 17),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- BODY ---
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: const SpinKitThreeBounce(color: primaryColor, size: 26),
                        )
                      else if (filteredOrders.isEmpty)
                        _buildModernEmptyState('No Orders Found', 'There are no delivered orders found for this customer.', context)
                      else
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Scrollbar(
                                controller: verticalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: const Radius.circular(8),
                                thickness: 6,
                                notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                                child: Scrollbar(
                                  controller: horizontalScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: const Radius.circular(8),
                                  thickness: 6,
                                  notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                                  child: SingleChildScrollView(
                                    controller: verticalScrollController,
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                      controller: horizontalScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                        child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                        headingTextStyle: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: 0.3,
                                        ),
                                        dataRowMinHeight: 56,
                                        dataRowMaxHeight: 68,
                                        columnSpacing: 14,
                                        horizontalMargin: 16,
                                        columns: [
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Customer'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Order #'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Date'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Sales Rep'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Amount'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Invoice'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Payment'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Status'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Action', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                        ],
                                        rows: filteredOrders.map((order) {
                                          final customer = order.customer.isNotEmpty ? order.customer[0] : null;
                                          return DataRow(
                                            cells: [
                                              // Customer Info
                                              DataCell(
                                                Center(
                                                  child: SizedBox(
                                                    width: 140,
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 14,
                                                          backgroundColor: const Color(0xFFEEF2FF),
                                                          child: const Icon(Icons.person, size: 15, color: primaryColor),
                                                        ),
                                                        const SizedBox(width: 7),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                customer?.businessName ?? 'N/A',
                                                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              if (customer?.fullName != null && customer!.fullName.isNotEmpty)
                                                                Text(
                                                                  customer.fullName,
                                                                  style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              if (customer?.mobileNo != null && customer!.mobileNo.isNotEmpty)
                                                                Text(
                                                                  customer.mobileNo,
                                                                  style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
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
                                              ),
                                              // Order No
                                              DataCell(
                                                Center(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      bool isOnline = await ConnectivityService().isOnline();
                                                      if (isOnline) {
                                                        showDetailedOrderInvoiceDialog(context, order.orderId, false);
                                                      } else {
                                                        showCustomToastDisplay(context, 'You are Offline!'.tr, red, Icons.warning);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: primaryColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                      ),
                                                      child: Text(
                                                        order.orderId,
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins_Regular',
                                                          color: primaryColor,
                                                          fontSize: 11.5,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Date
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    order.orderCreatedAt != null && order.orderCreatedAt.toString().isNotEmpty
                                                        ? TimeUtils.formatTimeInZone(DateTime.parse(order.orderCreatedAt.toString()), format: 'dd-MM-yyyy')
                                                        : 'N/A',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              // Sales Rep
                                              DataCell(
                                                Center(
                                                  child: SizedBox(
                                                    width: 90,
                                                    child: Text(
                                                      '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Amount
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    formatAmount(order.orderTotal ?? 0.0),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              // Invoice
                                              DataCell(
                                                Center(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      bool isOnline = await ConnectivityService().isOnline();
                                                      if (order.invoice.isNotEmpty) {
                                                        if (isOnline) {
                                                          showDialog(
                                                            barrierDismissible: false,
                                                            context: context,
                                                            builder: (context) => InvoicePreview(orderId: order.orderId),
                                                          );
                                                        } else {
                                                          showCustomToastDisplay(context, 'You are Offline!'.tr, red, Icons.warning);
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      order.invoice.isEmpty ? '-' : order.invoice[0].invoiceId,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins_Regular',
                                                        color: order.invoice.isEmpty ? Colors.black54 : primaryColor,
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Payment Status
                                              DataCell(
                                                Center(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                    decoration: BoxDecoration(
                                                      color: order.paymentStatus == 0 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: order.paymentStatus == 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      order.paymentStatus == 0 ? 'Pending'.tr : 'Paid'.tr,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins_Regular',
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w800,
                                                        color: order.paymentStatus == 0 ? const Color(0xFF991B1B) : const Color(0xFF065F46),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Status Badge
                                              DataCell(
                                                Center(
                                                  child: _buildStatusBadge(order.orderStatus, getStatusName(order.orderStatus)),
                                                ),
                                              ),
                                              // Action Icon
                                              DataCell(
                                                Center(
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                    icon: Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEEF2FF),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                                                      ),
                                                      child: const Icon(Icons.visibility_outlined, size: 15, color: primaryColor),
                                                    ),
                                                    onPressed: () async {
                                                      bool isOnline = await ConnectivityService().isOnline();
                                                      if (isOnline) {
                                                        showDetailedOrderInvoiceDialog(context, order.orderId, false);
                                                      } else {
                                                        showCustomToastDisplay(context, 'You are Offline!'.tr, red, Icons.warning);
                                                      }
                                                    },
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
                            );
                            },
                          ),
                        ),

                      // --- FOOTER ---
                      if (filteredOrders.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'Showing'.tr} ${filteredOrders.length} ${'Orders'.tr}',
                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${'Total'.tr}: ',
                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                                    ),
                                    Text(
                                      formatAmount(totalSum),
                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 14, fontWeight: FontWeight.w800, color: primaryColor),
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
        );
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
    final ScrollController verticalScrollController = ScrollController();
    final ScrollController horizontalScrollController = ScrollController();

    var offlineDraftTotal = (offlineDraftDetails == null
        ? 0.0
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
          //
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
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: screenHeight * 0.88,
            ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<OrderResponse>(
                future: provider.orderResponse,
                builder: (context, snapshot) {
                  final orders = snapshot.data?.data ?? [];
                  final filteredOrders = orders.where((order) {
                    return order.orderStatus == selectedOrderStatus.type;
                  }).toList();

                  final double serverTotal = filteredOrders.fold<double>(
                    0.0,
                    (sum, order) => sum + (order.orderTotal ?? 0.0),
                  );
                  final double overallTotal = serverTotal + (offlineDraftTotal is double ? offlineDraftTotal : 0.0);
                  final int totalRecordCount = filteredOrders.length + (offlineDraftDetails?.length ?? 0);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- HEADER ---
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
                                  child: Icon(
                                    orderType == 'Estimate'
                                        ? Icons.receipt_long_outlined
                                        : orderType == 'Booking'
                                            ? Icons.bookmark_border_rounded
                                            : orderType == 'Draft'
                                                ? Icons.edit_note_rounded
                                                : Icons.cancel_outlined,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$orderType ${'List'.tr}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (snapshot.connectionState == ConnectionState.done) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                                    ),
                                    child: Text(
                                      '$totalRecordCount ${'Records'.tr}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 17),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- BODY ---
                      if (snapshot.connectionState == ConnectionState.waiting && offlineDraftDetails == null)
                        Container(
                          height: 180,
                          alignment: Alignment.center,
                          child: const SpinKitThreeBounce(color: primaryColor, size: 26),
                        )
                      else if (filteredOrders.isEmpty && (offlineDraftDetails == null || offlineDraftDetails.isEmpty))
                        _buildModernEmptyState('No Records Found', 'There are no $orderType records found for this customer.', context)
                      else
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Scrollbar(
                                controller: verticalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: const Radius.circular(8),
                                thickness: 6,
                                notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                                child: Scrollbar(
                                  controller: horizontalScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  radius: const Radius.circular(8),
                                  thickness: 6,
                                  notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
                                  child: SingleChildScrollView(
                                    controller: verticalScrollController,
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                      controller: horizontalScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                        child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                        headingTextStyle: const TextStyle(
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: 0.3,
                                        ),
                                        dataRowMinHeight: 56,
                                        dataRowMaxHeight: 68,
                                        columnSpacing: 14,
                                        horizontalMargin: 16,
                                        columns: [
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Customer'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('$orderType #'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Date'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Sales Rep'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Amount'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Status'.tr, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                          DataColumn(headingRowAlignment: MainAxisAlignment.center, label: Center(child: Text('Action', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))))),
                                        ],
                                        rows: [
                                          // Server Orders
                                          ...filteredOrders.map((order) {
                                            final customer = order.customer.isNotEmpty ? order.customer[0] : null;
                                            return DataRow(
                                              cells: [
                                                // Customer Info
                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 145,
                                                      child: Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 14,
                                                            backgroundColor: const Color(0xFFEEF2FF),
                                                            child: const Icon(Icons.person, size: 15, color: primaryColor),
                                                          ),
                                                          const SizedBox(width: 7),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  customer?.businessName ?? 'N/A',
                                                                  style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                if (customer?.fullName != null && customer!.fullName.isNotEmpty)
                                                                  Text(
                                                                    customer.fullName,
                                                                    style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                if (customer?.mobileNo != null && customer!.mobileNo.isNotEmpty)
                                                                  Text(
                                                                    customer.mobileNo,
                                                                    style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
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
                                                ),
                                                // Order No
                                                DataCell(
                                                  Center(
                                                    child: InkWell(
                                                      onTap: () async {
                                                        bool isOnline = await ConnectivityService().isOnline();
                                                        if (isOnline) {
                                                          showDetailedOrderInvoiceDialog(
                                                            context,
                                                            order.orderId,
                                                            false,
                                                            changedTitle: orderType == 'Booking' ? 'BOOKING' : (orderType == 'Estimate' ? 'ESTIMATE' : ''),
                                                          );
                                                        } else {
                                                          showCustomToastDisplay(context, 'You are Offline!'.tr, red, Icons.warning);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: primaryColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                        ),
                                                        child: Text(
                                                          order.orderId,
                                                          style: const TextStyle(
                                                            fontFamily: 'Poppins_Regular',
                                                            color: primaryColor,
                                                            fontSize: 11.5,
                                                            fontWeight: FontWeight.w800,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Date
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      order.orderCreatedAt != null && order.orderCreatedAt.toString().isNotEmpty
                                                          ? TimeUtils.formatTimeInZone(DateTime.parse(order.orderCreatedAt.toString()), format: 'dd-MM-yyyy')
                                                          : 'N/A',
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                // Sales Rep
                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 90,
                                                      child: Text(
                                                        '${order.fullname.nkStringCapitalizeFirstCaracter} ${order.lastname}',
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Amount
                                                DataCell(
                                                  Center(
                                                    child: Text(
                                                      formatAmount(order.orderTotal ?? 0.0),
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                // Status Badge
                                                DataCell(
                                                  Center(
                                                    child: _buildStatusBadge(order.orderStatus, getStatusName(order.orderStatus)),
                                                  ),
                                                ),
                                                // Action
                                                DataCell(
                                                  Center(
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                      icon: Container(
                                                        padding: const EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFEEF2FF),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: primaryColor.withOpacity(0.2)),
                                                        ),
                                                        child: const Icon(Icons.visibility_outlined, size: 15, color: primaryColor),
                                                      ),
                                                      onPressed: () async {
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
                                                            showDetailedOrderInvoiceDialog(
                                                              context,
                                                              order.orderId,
                                                              false,
                                                              changedTitle: orderType == 'Booking' ? 'BOOKING' : (orderType == 'Estimate' ? 'ESTIMATE' : ''),
                                                            );
                                                          } else {
                                                            showCustomToastDisplay(context, 'You are Offline!'.tr, red, Icons.warning);
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),

                                          // Offline Drafts
                                          if (offlineDraftDetails != null && offlineDraftDetails.isNotEmpty)
                                            ...offlineDraftDetails.map((draft) {
                                              final orderId = draft['order_id'] ?? '';
                                              final customerName = draft['displayData']['customerName'] ?? 'N/A';
                                              final customerMobile = draft['displayData']['mobileNo'] ?? '';
                                              final customerEmail = draft['displayData']['email'] ?? '';
                                              final createdDate = draft['displayData']['createdDate'] ?? '';
                                              final displayTotal = draft['displayData']['displayTotal'] ?? 0.0;

                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Center(
                                                      child: SizedBox(
                                                        width: 145,
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 14,
                                                              backgroundColor: const Color(0xFFEEF2FF),
                                                              child: const Icon(Icons.person, size: 15, color: primaryColor),
                                                            ),
                                                            const SizedBox(width: 7),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    customerName,
                                                                    style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  if (customerMobile.isNotEmpty)
                                                                    Text(
                                                                      customerMobile,
                                                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black87),
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
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: primaryColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                                                        ),
                                                        child: Text(
                                                          orderId,
                                                          style: const TextStyle(fontFamily: 'Poppins_Regular', color: primaryColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        createdDate,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: SizedBox(
                                                        width: 90,
                                                        child: Text(
                                                          '${SessionHelper.loginSavedData?.fullname ?? ""}',
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: Text(
                                                        formatAmount(displayTotal is double ? displayTotal : double.tryParse(displayTotal.toString()) ?? 0.0),
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: _buildStatusBadge(4, 'Draft'),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Center(
                                                      child: IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                        icon: Container(
                                                          padding: const EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFEEF2FF),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(color: primaryColor.withOpacity(0.2)),
                                                          ),
                                                          child: const Icon(Icons.visibility_outlined, size: 15, color: primaryColor),
                                                        ),
                                                        onPressed: () {
                                                          final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
                                                          widget.productsController.selectedCustomerId.value = widget.customerId;
                                                          widget.productsController.selectedCustomerName.value = customerName;
                                                          widget.productsController.selectedCustomerMobileNo.value = customerMobile;
                                                          widget.productsController.selectedCustomerEmail.value = customerEmail;
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
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // --- FOOTER ---
                      if (totalRecordCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            border: Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'Showing'.tr} $totalRecordCount $orderType ${'Records'.tr}',
                                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${'Total'.tr}: ',
                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black),
                                    ),
                                    Text(
                                      formatAmount(overallTotal),
                                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 14, fontWeight: FontWeight.w800, color: primaryColor),
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
                      rows:  [
                        DataRow(cells: [
                          DataCell(Text('Record Not Found'.tr)),
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
