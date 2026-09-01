// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/customers_and_orders_dialo_table.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/offline_order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

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
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    widget.orderController.hasOfflineOrders.value = false;
    _selectedTabIndex = widget.passIndex;
    widget.orderController.loadOrderCountData();
    widget.orderController.updateTabIndex(_selectedTabIndex);
    _setHasOfflineOrdersOnInit();
    _searchController = widget.orderController.searchTextController;
    _searchController.addListener(() {
      final query = _searchController.text.trim();

      // Update reactive query
      widget.orderController.searchQuery.value = query;

      // Trigger search IMMEDIATELY — no delay, no debounce
      _triggerSearch();
    });
  }

  void _triggerSearch() {
    final hasOffline = widget.orderController.hasOfflineOrders.value;
    final index = _selectedTabIndex;

    // Don't search on Offline Orders tab
    if (hasOffline && index == 0) return;

    final status = _getStatusForTab(index, hasOfflineOrders: hasOffline);
    widget.orderController
        .performSearch(query: _searchController.text, status: status);
  }

  int _getStatusForTab(int index, {required bool hasOfflineOrders}) {
    if (hasOfflineOrders) index += 1; // because index 0 is Offline
    return widget
        .orderController.selectedStatusCountIndex.value; // or use mapping
  }

  void _setHasOfflineOrdersOnInit() async {
    var offlineOrdersBox = await Hive.openBox('offlineOrders');
    if (offlineOrdersBox.isNotEmpty) {
      setState(() {
        widget.orderController.hasOfflineOrders.value = true;
      });
    }
  }

  List<String> _computedTabs() {
    return widget.orderController.hasOfflineOrders.value
        ? [
            'Offline Orders'.tr,
            'Latest'.tr,
            'Waiting for Approval'.tr,
            'Quick Sale'.tr,
            'Processing'.tr,
            'Packed & Ready for Delivery'.tr,
            'Delivered'.tr,
            'Rejected'.tr,
          ]
        : [
            'Latest'.tr,
            'Waiting for Approval'.tr,
            'Quick Sale'.tr,
            'Processing'.tr,
            'Packed & Ready for Delivery'.tr,
            'Delivered'.tr,
            'Rejected'.tr,
          ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<int> _getCountForTab(int index) async {
    if (widget.orderController.hasOfflineOrders.value) {
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
          return notificationController
                  .recentOrderCountData.mainNotification?.delivered ??
              0.toInt();

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
          return notificationController
                  .recentOrderCountData.mainNotification?.delivered ??
              0.toInt();
        case 6:
          return 0;
        default:
          return 0;
      }
    }
  }

  bool _shouldShowUpgradeButton(int index) {
    if (widget.orderController.hasOfflineOrders.value) {
      switch (index) {
        case 0:
          return true;
        case 1:
          {
            if (subscriptionController.receivedOrder.value == "true") {
              return true;
            } else {
              return false;
            }
          }
        case 2:
          {
            if (subscriptionController.customerApprovalOption.value == "true") {
              return true;
            } else {
              return false;
            }
          }
        case 3:
          {
            if (subscriptionController.quickSale.value == "true") {
              return true;
            } else {
              return false;
            }
          }
        case 4:
          {
            if (subscriptionController.processing.value == "true") {
              return true;
            } else {
              return false;
            }
          }
        case 5:
          {
            if (subscriptionController.packedReady.value == "true") {
              return true;
            } else {
              return false;
            }
          }
        case 6:
          {
            if (subscriptionController.delivered.value == "true") {
              return true;
            } else {
              return false;
            }
          }
        case 7:
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
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.orderController.isCountLoading.value) {
        return const Center(child: Text('LOADING'));
      }

      final tabs = _computedTabs();

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
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedTabIndex == index;

                          if (widget.orderController.hasOfflineOrders.value &&
                              index == 0) {
                            return GestureDetector(
                              onTap: () {
                                if (!_shouldShowUpgradeButton(index)) {
                                  showUpgradePlanDialog(context);
                                } else {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                  widget.orderController.updateTabIndex(
                                      _selectedTabIndex,
                                      hasOfflineOrders: widget.orderController
                                          .hasOfflineOrders.value);
                                  widget.orderController.currentPage.value = 1;
                                }
                              },
                              child: Obx(() {
                                int count = widget
                                    .orderController.offlineOrderCount.value;
                                return Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 8, bottom: 0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        tabs[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : primaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                      ),
                                      if (count != 0) ...[
                                        const SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: red,
                                          child: Center(
                                            child: Text(
                                              count.toString(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins_Regular',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                );
                              }),
                            );
                          }

                          return FutureBuilder<int>(
                            future: _getCountForTab(index),
                            builder: (context, snapshot) {
                              int count = snapshot.data ?? 0;

                              return GestureDetector(
                                onTap: () {
                                  if (!_shouldShowUpgradeButton(index)) {
                                    showUpgradePlanDialog(context);
                                  } else {
                                    setState(() {
                                      _selectedTabIndex = index;
                                    });
                                    widget.orderController.updateTabIndex(
                                        _selectedTabIndex,
                                        hasOfflineOrders: widget.orderController
                                            .hasOfflineOrders.value);
                                    widget.orderController.currentPage.value =
                                        1;
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 8, bottom: 0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        tabs[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : primaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          fontFamily: 'Poppins_Regular',
                                        ),
                                      ),
                                      if (count != 0) ...[
                                        const SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: red,
                                          child: Center(
                                            child: Text(
                                              count.toString(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins_Regular',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 8, 400, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                // hintText: "Search in ${tabs[_selectedTabIndex]}...",
                hintText: 'Order Id / Invoice No.'.tr,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),

                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),

                // Focused state border
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              // onChanged: _onSearchChanged,
            ),
          ),
          if (!_shouldShowUpgradeButton(_selectedTabIndex))
            const Expanded(child: Center(child: UpgradePlanButton()))
          else
            Expanded(
              child: Obx(() {
                // Offline Orders Tab
                if (widget.orderController.hasOfflineOrders.value &&
                    _selectedTabIndex == 0) {
                  return OfflineOrderBottomWidget(
                      orderController: widget.orderController);
                }

                // Search Mode
                if (widget.orderController.isSearching.value) {
                  if (widget.orderController.isSearchLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.orderController.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No orders found",
                            style: TextStyle(
                                color: const Color(0xFF0F172A), fontSize: 16),
                          ),
                          Text(
                            "Try searching with Order ID or Invoice No.",
                            style: TextStyle(
                                color: const Color(0xFF0F172A), fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return OrderBottomWidget(
                    orderController: widget.orderController,
                    selectedTabIndex: _selectedTabIndex,
                    hasOfflineOrders:
                        widget.orderController.hasOfflineOrders.value,
                    overrideOrders:
                        widget.orderController.searchResults, // Key!
                    isSearchMode: true,
                  );
                }

                // Normal Tab Mode
                return OrderBottomWidget(
                  orderController: widget.orderController,
                  selectedTabIndex: _selectedTabIndex,
                  hasOfflineOrders:
                      widget.orderController.hasOfflineOrders.value,
                );
              }),
            ),
        ],
      );
    });
  }
}
