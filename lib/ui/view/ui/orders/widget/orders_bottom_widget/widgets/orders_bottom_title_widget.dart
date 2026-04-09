// ignore_for_file: unnecessary_null_comparison



// orders_bottom_title_row.dart
// ignore_for_file: unnecessary_null_comparison

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/orders_bottom_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersBottomTitleRow extends StatelessWidget {
  final OrderBottomWidget widget;
  final ScrollController scrollController2;
  final int tabIndex;
  final List<OrderData> orderList;

  const OrdersBottomTitleRow({
    super.key,
    required this.widget,
    required this.scrollController2,
    required this.tabIndex,
    required this.orderList,
  });

  // THIS IS THE KEY: Correctly returns List<OrderData>
  List<OrderData> get _displayList {
    if (widget.isSearchMode && widget.overrideOrders != null) {
      return widget.overrideOrders!;
    }
    return widget.orderController.orderDataList;
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderData> orders = _displayList;
    final bool isEmpty = orders.isEmpty;

    return Column(
      children: [
        // HEADER ROW
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
                if (tabIndex == 0) ...[
                  const SizedBox(width: 5),
                  _headerCell('Order NO'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Created'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Created By'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Order Amount'.tr, 5),
                  const SizedBox(width: 5),
                  _headerCell('Payment Status'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Status'.tr, 4),
                  const Expanded(flex: 2, child: SizedBox()),
                  const SizedBox(width: 5),
                ] else ...[
                  const SizedBox(width: 5),
                  _headerCell('Order Details'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Process Date'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Order Amount'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Payment Status'.tr, 4),
                  const SizedBox(width: 5),
                  _headerCell('Status'.tr, 4),
                  const Expanded(flex: 2, child: SizedBox()),
                  const SizedBox(width: 5),
                ],
              ],
            ),
          ),
        ),

        // EMPTY STATE (when search returns nothing)
        if (isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No orders found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

        // MAIN LIST (normal or search results)
        if (!isEmpty)
          Expanded(
            child: OrdersBottomList(
              scrollController2: scrollController2,
              widget: widget,
              tabIndex: tabIndex,
              orderList: orders, // This is now 100% safe List<OrderData>
            ),
          ),

        // FOOTER
        Container(
          padding: const EdgeInsets.all(3),
          height: 50,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  // Helper for clean header cells
  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Center(
        child: CustomText(
          content: text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }
}

