// ignore_for_file: deprecated_member_use

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersTabBar extends StatefulWidget {
  final OrderController orderController;
  final int passIndex;
  final NotificationController notificationController;

  const OrdersTabBar(
      {super.key,
      required this.orderController,
      this.passIndex = 0,
      required this.notificationController});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersTabBarState createState() => _OrdersTabBarState();
}

class _OrdersTabBarState extends State<OrdersTabBar> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  NotificationController notificationController =
      Get.find<NotificationController>();
  final subscriptionController = Get.find<SubscriptionController>();

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

  int _getCountForTab(int index) {
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

  bool _shouldShowUpgradeButton(int index) {
    switch (index) {
      case 0:
        {
          if (subscriptionController.receivedOrder.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      case 1:
        {
          if (subscriptionController.customerApprovalOption.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      case 2:
        {
          if (subscriptionController.quickSale.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      case 3:
        {
          if (subscriptionController.processing.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      case 4:
        {
          if (subscriptionController.packedReady.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      case 5:
        {
          if (subscriptionController.delivered.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      case 6:
        {
          if (subscriptionController.rejected.value == "true") {
            return true;
          } else {
            return false;
          }
        }
      default:
        {
          if (subscriptionController.receivedOrder.value == "true") {
            return true;
          } else {
            return false;
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.orderController.isCountLoading.value) {
        return const Center(child: Text('LOADING'));
      }
      return Column(
        children: [
          SizedBox(
            height: 60,
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                trackBorderColor:
                    const WidgetStatePropertyAll(Colors.transparent),
                thumbColor:
                    WidgetStatePropertyAll(primaryColor.withOpacity(0.3)),
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
                              if (!_shouldShowUpgradeButton(index)) {
                                showUpgradePlanDialog(context);
                                return;
                              }
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
          if (!_shouldShowUpgradeButton(_selectedTabIndex)) ...[
            Expanded(
              child: Center(
                child: UpgradePlanButton(),
              ),
            ),
          ],
          if (_shouldShowUpgradeButton(_selectedTabIndex))
            Expanded(
              child: OrderBottomWidget(
                orderController: widget.orderController,
                selectedTabIndex: _selectedTabIndex,
              ),
            ),
        ],
      );
    });
  }
}
