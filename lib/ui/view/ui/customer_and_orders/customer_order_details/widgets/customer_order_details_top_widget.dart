import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_diloag_screen.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_order_details/customer_order_details_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerOrderDetailsTopWidget extends StatelessWidget {
  final CustomerOrderDetailsController customerOrderDetailsController;
  final ProductsController productsController;
  const CustomerOrderDetailsTopWidget(
      {super.key,
      required this.customerOrderDetailsController,
      required this.productsController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        topHeadingRow(),
        nkMediumSizeBox(),
      ],
    );
  }

  Widget topHeadingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
            onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios)),
        nkMediumSizeBox(),
        const Spacer(),
        InkResponse(
            // onTap: () {
            //   Get.dialog(CartDiloagScreen(
            //     productsController: productsController,
            //   )).then((value) async {
            //     await productsController.loadSelectedCustomer(
            //         customerOrderDetailsController
            //             .customerAndOrderData.value.customerId!);
            //   });
            // },
            child: const Icon(Icons.shopping_cart_outlined)),
        nkMediumSizeBox(),
        topHeadingCustomerSection(
            customerOrderDetailsController
                    .customerAndOrderData.value.imageUrl ??
                "",
            customerOrderDetailsController.customerAndOrderData.value.fullname
                .toString())
      ],
    );
  }

  Widget topHeadingCustomerSection(String imageUrl, String customerName,
      {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        children: [
          Hero(
            tag: imageUrl + customerName,
            child: ClipOval(
                child: MyNetworkImage(
              imageUrl: imageUrl,
              height: AppDimensions.instance.height * 0.05,
              width: AppDimensions.instance.height * 0.05,
            )),
          ),
          MyRegularText(label: customerName),
        ],
      ),
    );
  }
}
