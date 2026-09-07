import 'dart:async';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/orders_bottom_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class OrderBottomWidget extends StatefulWidget {
  final OrderController orderController;
  final int selectedTabIndex;
  final bool hasOfflineOrders;
  final List<OrderData>? overrideOrders; // New: for search results
  final bool isSearchMode;
  const OrderBottomWidget({
    super.key,
    required this.orderController,
    required this.selectedTabIndex,
    this.hasOfflineOrders = false,
    this.overrideOrders,
    this.isSearchMode = false,
  });

  @override
  State<OrderBottomWidget> createState() => _OrderBottomWidgetState();
}

class _OrderBottomWidgetState extends State<OrderBottomWidget> {
  // LinkedScrollControllerGroup forwards the user's drag delta to every
  // linked controller directly, instead of reacting to a finished position
  // change with jumpTo() — mirrors the fix applied to lead_bottom_screen.dart
  // and sales_return.dart, keeping the frozen (Sl.No/Customer) column's list
  // in sync with the scrollable columns' list.
  late final LinkedScrollControllerGroup _verticalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _scrollController1 = _verticalGroup.addAndGet();
  late final ScrollController _scrollController2 = _verticalGroup.addAndGet();

  // Keeps the scrollable columns' header row moving in sync with the
  // scrollable columns' body rows underneath it — the header is drawn once
  // as a single full-width gradient bar overlaid on top of the body (see
  // _buildHeader/_buildBody below), instead of two separate gradient boxes
  // side by side, which produced a visible seam.
  late final LinkedScrollControllerGroup _horizontalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController _headerHorizontalController =
      _horizontalGroup.addAndGet();
  late final ScrollController _bodyHorizontalController =
      _horizontalGroup.addAndGet();

  NotificationController notificationController =
      Get.find<NotificationController>();

  int? _countForTab;
  bool _isOnline = true; // Default to true, will be updated

  Timer? _debounce;
  Timer? _connectivityTimer;

  @override
  void didUpdateWidget(covariant OrderBottomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTabIndex != widget.selectedTabIndex) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        widget.orderController.loadOrderData(
          selectedIndex: widget.hasOfflineOrders
              ? widget.selectedTabIndex - 1
              : widget.selectedTabIndex,
          // widget.selectedTabIndex
        );
        widget.orderController.loadOrderCountData();
      });
    }
  }

  Future<void> _loadCountForTab(int tabIndex) async {
    final count = await _getCountForTab(tabIndex);
    setState(() {
      _countForTab = count;
    });
  }

  @override
  void initState() {
    super.initState();

    _loadCountForTab(widget.selectedTabIndex);
    _checkConnectivity();

    // Set up periodic connectivity check
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    bool isOnline = await ConnectivityService().isOnline();
    setState(() {
      _isOnline = isOnline;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _connectivityTimer?.cancel();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  String get option {
    int tabIndex = widget.hasOfflineOrders
        ? widget.selectedTabIndex - 1
        : widget.selectedTabIndex;
    switch (tabIndex) {
      case 0:
        return 'Recieved';
      case 1:
        return 'Waiting';
      case 2:
        return 'Quick Sale';
      case 3:
        return 'Processing';
      case 4:
        return 'Packed & ready for delivery';
      case 5:
        return 'Delivered';
      case 6:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  Future<int> _getCountForTab(int index) async {
    if (widget.hasOfflineOrders) {
      switch (index) {
        case 0:
          return widget.orderController.offlineOrderCount.value;
        case 1:
          return notificationController
                  .recentOrderCountData.mainNotification?.recentOrders ??
              0.toInt();
        case 2:
          return notificationController
                  .recentOrderCountData.mainNotification?.waitingForApproval ??
              0.toInt();
        case 3:
          return notificationController
                  .recentOrderCountData.mainNotification?.quickSale ??
              0.toInt();
        case 4:
          return notificationController
                  .recentOrderCountData.mainNotification?.processingOrders ??
              0.toInt();
        case 5:
          return notificationController.recentOrderCountData.mainNotification
                  ?.packedAndReadyForDelivery ??
              0.toInt();
        case 6:
          return 0;
        case 7:
          return 0;
        default:
          return 0;
      }
    }
    {
      switch (index) {
        case 0:
          return notificationController
                  .recentOrderCountData.mainNotification?.recentOrders ??
              0.toInt();
        case 1:
          return notificationController
                  .recentOrderCountData.mainNotification?.waitingForApproval ??
              0.toInt();
        case 2:
          return notificationController
                  .recentOrderCountData.mainNotification?.quickSale ??
              0.toInt();
        case 3:
          return notificationController
                  .recentOrderCountData.mainNotification?.processingOrders ??
              0.toInt();
        case 4:
          return notificationController.recentOrderCountData.mainNotification
                  ?.packedAndReadyForDelivery ??
              0.toInt();
        case 5:
          return 0;
        case 6:
          return 0;
        default:
          return 0;
      }
    }
  }

  double _tableWidth(BuildContext context) => isTabletOrPhoneLandscape(context)
      ? MediaQuery.of(context).size.width
      : fullScreenWidth(context) * 2;

  @override
  Widget build(BuildContext context) {
    int tabIndex = widget.hasOfflineOrders
        ? widget.selectedTabIndex - 1
        : widget.selectedTabIndex;
    List<OrderData> currentOrderList = widget.overrideOrders ?? widget.orderController.orderDataList;

    return Obx(
      () {
        if (currentOrderList.isEmpty &&
            _countForTab == null) {
          return const Center(
              child: Text(
            'LOADING',
          ));
        }

        if (currentOrderList.isEmpty && _countForTab == 0) {
          return Center(child: Text('Record Not Found'.tr));
        }

        if (currentOrderList.isEmpty && _countForTab != 0) {
          if (widget.orderController.offlineOrderCount.value != 0 ||
              !_isOnline) {
            return const Center(
                child:
                    Text('You are offline. Recent orders will not function.'));
          } else {
            return const Center(
                child: Text(
              'LOADING',
            ));
          }
        }

        return NkWidgetExceptionHandel(
          onRetryPressed: () => {},
          data: currentOrderList,
          child: Stack(
            children: [
              _buildBody(context, tabIndex),
              _buildHeader(context, tabIndex),
            ],
          ),
        );
      },
    );
  }

  // Single continuous gradient bar spanning the frozen (Sl.No/List) column
  // and the horizontally-scrollable columns, overlaid on top of the body via
  // a Stack — avoids the visible seam that two side-by-side gradient
  // containers produced. Mirrors lead_bottom_screen.dart/sales_return.dart's
  // _buildHeader.
  Widget _buildHeader(BuildContext context, int tabIndex) {
    const double headerHeight = 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: CustomText(
                          content: 'Sl No.'.tr,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins_Regular'),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: CustomText(
                          content: '$option'.tr + ' ' + 'List'.tr,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Poppins_Regular'),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _headerHorizontalController,
                primary: false,
                child: SizedBox(
                  width: _tableWidth(context),
                  child: buildOrdersHeaderCells(tabIndex),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, int tabIndex) {
    List<OrderData> currentOrderList = widget.overrideOrders ?? widget.orderController.orderDataList;
    const double headerHeight = 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: headerHeight),
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const ClampingScrollPhysics(),
                      controller: _scrollController1,
                      itemCount: currentOrderList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        OrderData orderData =
                            currentOrderList[index];
                        if (orderData.cart == null || orderData.cart!.isEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? Colors.white
                                  : const Color(0xFFF8FAFC),
                              border: const Border(
                                bottom: BorderSide(
                                    color: Color(0xFFE2E8F0), width: 0.6),
                              ),
                            ),
                            height: (fullScreenHeight(context) - 242) / 10,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: CustomText(
                                      content:
                                          '${((widget.orderController.currentPage.value - 1) * 10) + (index + 1)}.',
                                      maxLine: 1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 8,
                                  child: customerDetailsWidget(
                                      orderData.customer!.first),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? Colors.white
                                : const Color(0xFFF8FAFC),
                            border: const Border(
                              bottom: BorderSide(
                                  color: Color(0xFFE2E8F0), width: 0.6),
                            ),
                          ),
                          height: (MediaQuery.of(context).orientation ==
                                  Orientation.portrait)
                              ? (fullScreenHeight(context) - 250) / 10
                              : 70,
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: CustomText(
                                    content:
                                        '${((widget.orderController.currentPage.value - 1) * 10) + (index + 1)}.',
                                    maxLine: 1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                flex: 8,
                                child: customerDetailsWidget(
                                    orderData.customer!.first),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(3),
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0), width: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        OrderPaginationWidget(
                            orderController: widget.orderController),
                        const Spacer()
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _bodyHorizontalController,
                primary: false,
                child: SizedBox(
                  width: _tableWidth(context),
                  child: OrdersBottomTitleRow(
                    widget: widget,
                    scrollController2: _scrollController2,
                    tabIndex: tabIndex,
                    orderList: currentOrderList, // Pass correct list
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
