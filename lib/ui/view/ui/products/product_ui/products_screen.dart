import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_order_details/widgets/customer_order_details_middel.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_widget/product_middel_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductsController productsController = Get.find<ProductsController>();
  HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();

    productsController.loadProductFrequency();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: Obx(() {
            if (productsController.customerAndOrderData.value.customerId !=
                null) {
              return CustomerOrderDetailMiddelWidget(
                key: const Key("CustomerOrderDetailMiddelWidget"),
                productsController: productsController,
              );
            } else {
              return ProductMiddelWidget(
                productsController: productsController,
              );
            }
          }),
        );
      },
    );
  }
}
