import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_bottom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersTabBar extends StatefulWidget {
  final OrderController orderController;
  final int passIndex;

  OrdersTabBar({required this.orderController, this.passIndex = 0});

  @override
  _OrdersTabBarState createState() => _OrdersTabBarState();
}

class _OrdersTabBarState extends State<OrdersTabBar> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
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
        return widget.orderController.receivedCount.value;
      case 1:
        return widget.orderController.approvalCount.value;
      case 2:
        return widget.orderController.quickSaleCount.value;
      case 3:
        return widget.orderController.processingCount.value;
      case 4:
        return widget.orderController.packedCount.value;
      case 5:
        return widget.orderController.deliveredCount.value;
      case 6:
        return widget.orderController.rejectedCount.value;

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.orderController.isLoading.value ||
          widget.orderController.isCountLoading.value) {
        return Center(
            child: Text('LOADING'));
      }

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  trackBorderColor: WidgetStatePropertyAll(Colors.transparent),
                  thumbColor: MaterialStatePropertyAll(Colors.cyan),
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
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: _tabs.length,
                          itemBuilder: (context, index) {
                            bool isSelected = _selectedTabIndex == index;
                            int count = _getCountForTab(
                                index);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTabIndex = index;
                                });
                                widget.orderController
                                    .updateTabIndex(_selectedTabIndex);
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 0),
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
                                    Text(
                                      _tabs[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (count != 0) ...[
                                      SizedBox(width: 8),
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: red,
                                        child: Center(
                                          child: Text(
                                            count.toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: white,
                                              fontWeight: FontWeight.bold,
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
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: OrderBottomWidget(
                orderController: widget.orderController,
                selectedTabIndex: _selectedTabIndex,
              ),
            ),
          ],
        ),
      );
    });
  }
}
