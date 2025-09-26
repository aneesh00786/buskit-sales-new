import 'dart:async';
import 'dart:developer';
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

class OrderBottomWidget extends StatefulWidget {
  final OrderController orderController;
  final int selectedTabIndex;
  final bool hasOfflineOrders;
  const OrderBottomWidget({
    super.key,
    required this.orderController,
    required this.selectedTabIndex,
    this.hasOfflineOrders = false,
  });

  @override
  State<OrderBottomWidget> createState() => _OrderBottomWidgetState();
}

class _OrderBottomWidgetState extends State<OrderBottomWidget> {
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController1 = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    int tabIndex = widget.hasOfflineOrders
        ? widget.selectedTabIndex - 1
        : widget.selectedTabIndex;
    return Obx(
      () {
        if (widget.orderController.orderDataList.isEmpty &&
            _countForTab == null) {
          return const Center(
              child: Text(
            'LOADING',
          ));
        }

        if (widget.orderController.orderDataList.isEmpty && _countForTab == 0) {
          return const Center(child: Text('Record Not Found'));
        }

        if (widget.orderController.orderDataList.isEmpty && _countForTab != 0) {
          log("countForTab 2 : $_countForTab");
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
          data: widget.orderController.orderDataList,
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      color: primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: CustomText(
                                    content: 'SI No.',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 8,
                              child: Center(
                                child: CustomText(
                                    content: '$option List',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                    // ignore: unnecessary_null_comparison
                    if (widget.orderController.orderDataList != null) ...[
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const ClampingScrollPhysics(),
                          controller: _scrollController1,
                          itemCount:
                              widget.orderController.orderDataList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            OrderData orderData =
                                widget.orderController.orderDataList[index];
                            if (orderData.cart == null ||
                                orderData.cart!.isEmpty) {
                              return Container(
                                color: index.isEven
                                    ? Colors.white
                                    : Colors.grey[50],
                                height: (fullScreenHeight(context) - 242) / 10,
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2, child: placeholderWidget()),
                                    Expanded(
                                        flex: 8, child: placeholderWidget()),
                                  ],
                                ),
                              );
                            }
                            return Container(
                              color:
                                  index.isEven ? Colors.white : Colors.grey[50],
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
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 8,
                                    child: customerDetailsWidget(
                                        orderData.cart!.first),
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
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            OrderPaginationWidget(
                                orderController: widget.orderController),
                            const Spacer()
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: isTabletOrPhoneLandscape(context)
                        ? MediaQuery.of(context).size.width
                        : fullScreenWidth(context) * 2,
                    child: OrdersBottomTitleRow(
                      widget: widget,
                      scrollController2: _scrollController2,
                      tabIndex: tabIndex,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
