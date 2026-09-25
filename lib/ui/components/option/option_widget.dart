<<<<<<< HEAD
import 'package:intl/intl.dart';
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_null_comparison

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
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

  late ScrollController _scrollController4;
  late ScrollController _scrollController5;
  late ScrollController _scrollController6;

  late ScrollController _scrollController7;
  late ScrollController _scrollController8;
  late ScrollController _scrollController9;

  int _offlineDraftCount = 0;
  int _onlineDraftCount = 0;
  int get _totalDraftCount => _offlineDraftCount + _onlineDraftCount;

<<<<<<< HEAD
  int _offlineUnfilteredDraftCount = 0;
  int _onlineUnfilteredDraftCount = 0;
  int get _totalUnfilteredDraftCount =>
      _offlineUnfilteredDraftCount + _onlineUnfilteredDraftCount;

  List<dynamic> _getFilteredOfflineDrafts(
      List<dynamic> allDrafts, DashboardProvider? provider) {
    if (provider == null) return allDrafts;
    return allDrafts.where((draft) {
      try {
        final dateStr = draft['displayData']?['createdDate']?.toString();
        if (dateStr == null || dateStr.isEmpty) return false;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;

        switch (provider.selectedFilter) {
          case FilterDateEnum.today:
            final todayStr = DateFormat('yyyy-MM-dd').format(date);
            final selectedStr = provider.selectedDate;
            return todayStr == selectedStr;
          case FilterDateEnum.thisMonth:
            final monthName = DateFormat('MMMM', 'en').format(date);
            final year = date.year;
            int selectedYear = provider.selectedYear != 0
                ? provider.selectedYear
                : DateTime.now().year;
            return provider.selectedFilterMonths.contains(monthName) &&
                year == selectedYear;
          case FilterDateEnum.thisWeek:
            int selectedYear = provider.selectedYear != 0
                ? provider.selectedYear
                : DateTime.now().year;
            return date.year == selectedYear;
          case FilterDateEnum.range:
            if (provider.selectedStartDate.isNotEmpty &&
                provider.selectedEndDate.isNotEmpty) {
              final start = DateTime.tryParse(provider.selectedStartDate);
              final end = DateTime.tryParse(provider.selectedEndDate);
              if (start != null && end != null) {
                return !date.isBefore(start) &&
                    !date.isAfter(end.add(const Duration(days: 1)));
              }
            }
            return true;
          case FilterDateEnum.thisYear:
            int selectedYear = provider.selectedYear != 0
                ? provider.selectedYear
                : DateTime.now().year;
            return date.year == selectedYear;
          default:
            return true;
        }
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Add: Function to get offline draft count for a customer
  Future<int> getOfflineDraftCount(
      {bool filterNeeded = false, DashboardProvider? provider}) async {
=======
  int _onlineUnfilteredDraftCount = 0;
  int get _totalUnfilteredDraftCount =>
      _offlineDraftCount + _onlineUnfilteredDraftCount;

  // Add: Function to get offline draft count for a customer
  Future<int> getOfflineDraftCount() async {
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
    try {
      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
<<<<<<< HEAD
      if (filterNeeded && provider != null) {
        return _getFilteredOfflineDrafts(drafts, provider).length;
      }
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
      return drafts.length;
    } catch (e) {
      return 0;
    }
  }

<<<<<<< HEAD
  Future<void> _fetchDraftCounts(OrderCountListt? orderCountList,
      {DashboardProvider? provider}) async {
    int offlineCount =
        await getOfflineDraftCount(filterNeeded: true, provider: provider);
    int offlineUnfiltered =
        await getOfflineDraftCount(filterNeeded: false);
=======
  Future<void> _fetchDraftCounts(OrderCountListt? orderCountList) async {
    int offlineCount = await getOfflineDraftCount();
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
    int onlineCount =
        orderCountList != null ? (orderCountList.draftFilteredCount ?? 0) : 0;
    int onlineUnfilteredCount =
        orderCountList != null ? (orderCountList.draftOrder ?? 0) : 0;
<<<<<<< HEAD
    if (mounted) {
      setState(() {
        _offlineDraftCount = offlineCount;
        _offlineUnfilteredDraftCount = offlineUnfiltered;
        _onlineDraftCount = onlineCount;
        _onlineUnfilteredDraftCount = onlineUnfilteredCount;
      });
    }
=======
    setState(() {
      _offlineDraftCount = offlineCount;
      _onlineDraftCount = onlineCount;
      _onlineUnfilteredDraftCount = onlineUnfilteredCount;
    });
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
  }

  @override
  void initState() {
    super.initState();
    _initializeDraftCounts();

    _controllers = LinkedScrollControllerGroup();

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

<<<<<<< HEAD
              _fetchDraftCounts(countData, provider: provider);
=======
              _fetchDraftCounts(countData);
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a

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
                  context, "No Record Found".tr, red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.delivered);
              showOrderStatusDialog(
                context,
                provider,
                OrderStatus.delivered,
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
                  context, "No Record Found".tr, red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.estimates, checkDate: true);
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.estimates,
                'Estimate'.tr,
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
                  context, "No Record Found".tr, red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.estimates, checkDate: false);
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.estimates,
                'Estimate'.tr,
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
                    context, "No Record Found".tr, red, Icons.close);
              } else {
                provider.fetchOrdersData(OrderStatus.preOrder, checkDate: true);
                _showOrderTypeDialog(
                  context,
                  provider,
                  OrderStatus.preOrder,
                  'Booking'.tr,
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
                    context, "No Record Found".tr, red, Icons.close);
              } else {
                provider.fetchOrdersData(OrderStatus.preOrder,
                    checkDate: false);
                _showOrderTypeDialog(
                  context,
                  provider,
                  OrderStatus.preOrder,
                  'Booking'.tr,
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
<<<<<<< HEAD
            List<dynamic> filteredOffline =
                _getFilteredOfflineDrafts(drafts, provider);
=======
            List<dynamic> offlineDraftDetails = drafts.toList();
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
            if (_totalDraftCount == 0) {
              showCustomToastDisplay(
                  context, "No Record Found".tr, red, Icons.close);
            } else {
<<<<<<< HEAD
              provider.fetchOrdersData(
                OrderStatus.draft,
                checkDate: true,
=======
              // Draft filtering handled within the app, not using checkDate
              provider.fetchOrdersData(
                OrderStatus.draft,
                checkDate: false,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
              );
              _showDraftDialog(
                context,
                provider,
                OrderStatus.draft,
                'Draft'.tr,
                true,
                productsController,
                customerOrderController,
                widget.homeController,
<<<<<<< HEAD
                offlineDraftDetails: filteredOffline,
=======
                offlineDraftDetails: offlineDraftDetails,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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
                  context, "No Record Found".tr, red, Icons.close);
            } else {
              provider.fetchOrdersData(
                OrderStatus.draft,
                checkDate: false,
              );
              _showDraftDialog(
                context,
                provider,
                OrderStatus.draft,
                'Draft'.tr,
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
                  context, "No Record Found".tr, red, Icons.close);
            } else {
              provider.fetchOrdersData(OrderStatus.cancelled);
              _showOrderTypeDialog(
                context,
                provider,
                OrderStatus.cancelled,
                'Cancelled'.tr,
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
      height: 18,
      width: 18,
      fit: BoxFit.contain,
    );

    String unfilteredCount = _getUnFilteredCountForTitle(optionData.title, orderCountList);
    bool hasUnfiltered = unfilteredCount != "0";

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card container
            InkWell(
              onTap: optionData.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(7, 7, 16, 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: optionData.svgBgColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: svgComponent,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            optionData.title.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _getCountForTitle(
                                optionData.title, orderCountList),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: optionData.color,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Large, easy-to-tap top-right unfiltered badge
            if (hasUnfiltered)
              Positioned(
                right: -6,
                top: -6,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: optionData.onUnFilterTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(5.0), // Generous tap target (36x36 total)
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626), // Vivid red
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            unfilteredCount,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
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

  void _showOrderStatusDialog(BuildContext context, DashboardProvider provider,
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
                        _buildModernEmptyState('No Orders Found', 'There are no delivered orders found.', context)
                      else
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return ScrollbarTheme(
                                data: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.resolveWith(
                                    (states) => states.contains(WidgetState.dragged)
                                        ? primaryColor
                                        : primaryColor.withOpacity(0.55),
                                  ),
                                  trackColor: WidgetStateProperty.all(primaryColor.withOpacity(0.06)),
                                  trackBorderColor: WidgetStateProperty.all(primaryColor.withOpacity(0.18)),
                                  radius: const Radius.circular(10),
                                  thickness: WidgetStateProperty.all(8),
                                  minThumbLength: 60,
                                  crossAxisMargin: 2,
                                  mainAxisMargin: 2,
                                ),
                                child: Scrollbar(
                                controller: verticalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                                child: Scrollbar(
                                  controller: horizontalScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
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
    DashboardProvider provider,
    OrderStatus selectedOrderStatus,
    String orderType,
    bool isDraft,
    ProductsController productsController,
    CustomerAndOrderController customerOrderController,
    HomeController? homeController, {
    List<dynamic>? offlineDraftDetails,
<<<<<<< HEAD
    bool filterNeeded = false,
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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
<<<<<<< HEAD
          await provider.fetchOrdersData(OrderStatus.draft,
              checkDate: filterNeeded);
=======
          await provider.fetchOrdersData(OrderStatus.draft, checkDate: false);
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
          Navigator.of(context, rootNavigator: true).pop();
          _showOrderTypeDialog(
            context,
            provider,
            OrderStatus.draft,
            'Draft',
            true,
            productsController,
            customerOrderController,
            homeController,
<<<<<<< HEAD
            offlineDraftDetails: filterNeeded
                ? _getFilteredOfflineDrafts(freshOfflineDraftDetails, provider)
                : freshOfflineDraftDetails,
            filterNeeded: filterNeeded,
=======
            offlineDraftDetails: freshOfflineDraftDetails,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
          );
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
<<<<<<< HEAD
                  final filteredOrders = isDraft
                      ? orders
                      : orders.where((order) {
                          return order.orderStatus == selectedOrderStatus.type;
                        }).toList();
=======
                  final filteredOrders = orders.where((order) {
                    return order.orderStatus == selectedOrderStatus.type;
                  }).toList();
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a

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
                        _buildModernEmptyState('No Records Found', 'There are no $orderType records found.', context)
                      else
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return ScrollbarTheme(
                                data: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.resolveWith(
                                    (states) => states.contains(WidgetState.dragged)
                                        ? primaryColor
                                        : primaryColor.withOpacity(0.55),
                                  ),
                                  trackColor: WidgetStateProperty.all(primaryColor.withOpacity(0.06)),
                                  trackBorderColor: WidgetStateProperty.all(primaryColor.withOpacity(0.18)),
                                  radius: const Radius.circular(10),
                                  thickness: WidgetStateProperty.all(8),
                                  minThumbLength: 60,
                                  crossAxisMargin: 2,
                                  mainAxisMargin: 2,
                                ),
                                child: Scrollbar(
                                controller: verticalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
                                child: Scrollbar(
                                  controller: horizontalScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
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
                                                          productsController.selectedCustomerId.value = customer?.customerId ?? '';
                                                          productsController.selectedCustomerName.value = customer?.businessName ?? '';
                                                          productsController.selectedCustomerMobileNo.value = customer?.mobileNo ?? '';
                                                          productsController.selectedCustomerEmail.value = customer?.email ?? '';
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return CartDialogue(
                                                                active: true,
                                                                cartItemCount: cartProvider.cartItemCount,
                                                                productsController: productsController,
                                                                customerOrderController: customerOrderController,
                                                                onContinueShopping: null,
                                                                isFromCustomerDach: false,
                                                                isDashboard: true,
                                                                customerId: customer?.customerId ?? '',
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
                                              final customerId = draft['displayData']['customerId'] ?? '';
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
                                                                onContinueShopping: null,
                                                                isFromCustomerDach: false,
                                                                isDashboard: true,
                                                                customerId: customerId,
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

  void _showDraftDialog(
    BuildContext context,
    DashboardProvider provider,
    OrderStatus selectedOrderStatus,
    String orderType,
    bool isDraft,
    ProductsController productsController,
    CustomerAndOrderController customerOrderController,
    HomeController? homeController, {
    List<dynamic>? offlineDraftDetails,
    bool filterNeeded = false,
  }) {
    _showOrderTypeDialog(
      context,
      provider,
      selectedOrderStatus,
      orderType,
      isDraft,
      productsController,
      customerOrderController,
      homeController,
      offlineDraftDetails: offlineDraftDetails,
<<<<<<< HEAD
      filterNeeded: filterNeeded,
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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
