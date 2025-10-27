
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_order_details/customer_order_details_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_order_details/widgets/customer_order_details_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/customer_order_details_middel.dart';

class CustomerOrderDetailsScreen extends StatefulWidget {
  final CustomerAndOrderData customerAndOrderData;

  const CustomerOrderDetailsScreen(
      {super.key, required this.customerAndOrderData});

  @override
  State<CustomerOrderDetailsScreen> createState() =>
      _CustomerOrderDetailsScreenState();
}

class _CustomerOrderDetailsScreenState
    extends State<CustomerOrderDetailsScreen> {
  CustomerOrderDetailsController customerOrderDetailsController =
      Get.put(CustomerOrderDetailsController());
  ProductsController productsController = Get.find<ProductsController>();

  @override
  void initState() {
    customerOrderDetailsController.customerAndOrderData.value =
        widget.customerAndOrderData;
    // productsController.loadDataOfCategory.whenComplete(() {
    // });
    productsController.updateCustomerAndOrderData(widget.customerAndOrderData);
    super.initState();
  }

  @override
  void dispose() {
    productsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        body: GetBuilder<ProductsController>(
          init: productsController,
          assignId: true,
          builder: (productsController) {
            return SafeArea(
              minimum: nkRegularPadding(),
              child: Column(
                children: [
                  CustomerOrderDetailsTopWidget(
                    customerOrderDetailsController:
                        customerOrderDetailsController,
                    productsController: productsController,
                  ),
                  nkMediumSizeBox(),
                  nkMediumSizeBox(),
                  Flexible(
                    child: CustomerOrderDetailMiddelWidget(
                      productsController: productsController,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
