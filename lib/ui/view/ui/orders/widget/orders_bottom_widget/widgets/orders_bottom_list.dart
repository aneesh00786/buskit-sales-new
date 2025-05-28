import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/helpers.dart';
import 'package:flutter/material.dart';

class OrdersBottomList extends StatelessWidget {
  const OrdersBottomList({
    super.key,
    required ScrollController scrollController2,
    required this.widget,
  }) : _scrollController2 = scrollController2;

  final ScrollController _scrollController2;
  final OrderBottomWidget widget;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        controller: _scrollController2,
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
              height: (MediaQuery.of(context)
                          .orientation ==
                      Orientation.portrait)
                  ? (fullScreenHeight(context) - 250) / 10
                  : 70,
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: placeholderWidget()),
                  Expanded(
                      flex: 4,
                      child: placeholderWidget()),
                  Expanded(
                      flex: 4,
                      child: placeholderWidget()),
                  Expanded(
                      flex: 5,
                      child: placeholderWidget()),
                  Expanded(
                      flex: 4,
                      child: placeholderWidget()),
                  Expanded(
                      flex: 2,
                      child: placeholderWidget()),
                ],
              ),
            );
          }
          return Container(
            color: index.isEven
                ? Colors.white
                : Colors.grey[50],
            height: (MediaQuery.of(context).orientation ==
                    Orientation.portrait)
                ? (fullScreenHeight(context) - 250) / 10
                : 70,
            child: Row(
              children: [
                if (widget.selectedTabIndex == 0) ...[
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: orderNumberWidget(
                        orderData.cart!.first,
                        orderData,
                        widget.selectedTabIndex),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: orderCreatedDateWidget(
                        orderData.cart!.first,
                        orderData,
                        widget.selectedTabIndex),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child:
                        orderCreatedByWidget(orderData),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 5,
                    child:
                        orderPrice(orderData.cart!.first),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: paymentStatus(
                        orderData.cart!.first),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: orderStatus(
                        orderData.cart!.first),
                  ),
                  Expanded(
                      flex: 2,
                      child: viewOrder(
                          widget.orderController,
                          orderData,
                          context)),
                  const SizedBox(width: 5),
                ],
                if (widget.selectedTabIndex != 0) ...[
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: orderNumberWidget(
                        orderData.cart!.first,
                        orderData,
                        widget.selectedTabIndex),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: orderCreatedDateWidget(
                        orderData.cart!.first,
                        orderData,
                        widget.selectedTabIndex),
                  ),
                  const SizedBox(width: 5),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child:
                        orderPrice(orderData.cart!.first),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: paymentStatus(
                        orderData.cart!.first),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 4,
                    child: orderStatus(
                        orderData.cart!.first),
                  ),
                  Expanded(
                      flex: 2,
                      child: viewOrder(
                          widget.orderController,
                          orderData,
                          context)),
                  const SizedBox(width: 5),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}