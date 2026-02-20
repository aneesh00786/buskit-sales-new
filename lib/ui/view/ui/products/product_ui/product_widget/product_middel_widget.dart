import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductMiddelWidget extends StatelessWidget {
  final ProductsController productsController;

  const ProductMiddelWidget({super.key, required this.productsController});
  @override
  Widget build(BuildContext context) {
    return OrderTaking(
              productsController: productsController,
              isDirectDialogue: true,
            );
    // Obx(() {
      // return productsController.isReached.value
      //     ? 
      //     CustomerDachScreen(
      //         isFromCalendar: true,
      //         cusId: productsController.selectedCustomerId.value,
      //         cusName: productsController.selectedCustomerName.value,
      //         cusImage: productsController.selectedCustomerImageUrl.value,
      //         cusEmail: productsController.selectedCustomerEmail.value,
      //         cusMobile: productsController.selectedCustomerMobileNo.value,
      //       )
      //     :
        //  return  
    // });
  }
}
