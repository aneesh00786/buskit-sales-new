import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_bottom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class OrdersTabBar extends StatefulWidget {
  final OrderController orderController;
  final int passIndex;
  final NotificationController notificationController;

  OrdersTabBar(
      {required this.orderController,
      this.passIndex = 0,
      required this.notificationController});

  @override
  _OrdersTabBarState createState() => _OrdersTabBarState();
}

class _OrdersTabBarState extends State<OrdersTabBar> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  NotificationController notificationController =
      Get.find<NotificationController>();
  final List<String> _tabs = [
    'Latest',
    'Waiting for Approval',
    'Quick Sale',
    'Processing',
    'Packed & Ready for Delivery',
    'Delivered',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.passIndex;
    widget.orderController.loadOrderCountData();
    widget.orderController.updateTabIndex(_selectedTabIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onBarTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  int _getCountForTab(int index) {
    switch (index) {
      case 0:
        return notificationController
            .recentOrderCountData.mainNotification?.recentOrders??0
            .toInt();
      case 1:
        return notificationController
            .recentOrderCountData.mainNotification?.waitingForApproval??0
            .toInt();
      case 2:
        return notificationController
            .recentOrderCountData.mainNotification?.quickSale??0
            .toInt();
      case 3:
        return notificationController
            .recentOrderCountData.mainNotification?.processingOrders??0
            .toInt();
      case 4:
        return notificationController
            .recentOrderCountData.mainNotification?.packedAndReadyForDelivery??0
            .toInt();
      case 5:
        return 0;
      case 6:
        return 0;

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              trackBorderColor: WidgetStatePropertyAll(Colors.transparent),
              thumbColor:
                  MaterialStatePropertyAll(primaryColor.withOpacity(0.3)),
              trackColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedTabIndex == index;
                        int count = _getCountForTab(index);
    
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                            widget.orderController
                                .updateTabIndex(_selectedTabIndex);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.cyan
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  child: Text(_tabs[index]),
                                ),
                                if (count != 0) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          if (widget.orderController.isLoading.value ||
              widget.orderController.isCountLoading.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                SpinKitFadingCube(
                  color: primaryColor,
                  size: 20.0,
                ),
              ],
            );
          }
          return Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: OrderBottomWidget(
                orderController: widget.orderController,
                selectedTabIndex: _selectedTabIndex,
              ),
            ),
          );
        }),
      ],
    );
  }
}
