import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_order_details/widgets/customer_order_details_middel.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_widget/product_middel_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_widget/product_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductsController productsController = Get.put(ProductsController());

  @override
  void initState() {
    productsController.loadDataOfCategory.whenComplete(() {
      //productsController.loadDataOfProduct();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        body: GetBuilder<ProductsController>(
            init: productsController,
            dispose: (state) {
              state.controller?.customerAndOrderData.value =
                  CustomerAndOrderData();
            },
            autoRemove: true,
            builder: (productsController) {
              return SingleChildScrollView(
              
                child:Column(
                  children: [
                    ProductTopWidget(productsController: productsController),
                    //nkLargeSizeBox(),
                    productsController
                        .customerAndOrderData.value.customerId !=
                        null
                        ?  CustomerOrderDetailMiddelWidget(
                      key: const Key(
                          "CustomerOrderDetailMiddelWidget"),
                      productsController: productsController,
                    )
                        :  ProductMiddelWidget(
                      productsController: productsController,
                    ),
              
                  ],
                ) ,
                scrollDirection: Axis.vertical,
              );
            }),
      );
    });
  }
}
