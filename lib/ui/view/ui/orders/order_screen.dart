import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  final int passIndex;
  const OrderScreen({super.key, this.passIndex = 0});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderController orderController = Get.put(OrderController());
  int selectedTabIndex = 0;
  @override
  void initState() {
    super.initState();
    orderController.loadOrderData;
    selectedTabIndex = widget.passIndex;
   // orderController.loadOrderData(selectedIndex: selectedTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              OrderTopWidget(
                orderController: orderController,
              ),
              nkMediumSizeBox(),
              Flexible(
                  child: OrderBottomWidget(orderController: orderController))
            ],
          ),
        ),
      );
    });
  }
}
