import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductMiddelWidget extends StatelessWidget {
  final ProductsController productsController;

  ProductMiddelWidget({Key? key, required this.productsController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        return SizedBox(
          height: 1200,
          width: availableWidth,
          child: Obx(() {
            log('isReached state: ${productsController.isReached.value}');  
            return productsController.isReached.value
                ? CustomerDachScreen(isFromCalendar: true,)
                : OrderTaking(productsController: productsController,);
          }),
        );
      },
    );
  }
}
