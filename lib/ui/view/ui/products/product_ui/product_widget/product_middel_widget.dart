import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/view/product_list.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/product_details_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
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
                ? CustomerDachScreen(cusId: productsController.selectedCustomerId.value,cusImage: '',cusName: '',isFromCalendar: true,)
                : OrderTaking(productsController: productsController,cusImage: '',);
          }),
        );
      },
    );
  }
  Widget productComponent(ProductList data) {
    return MyCommnonContainer(
      isCommonBorder: true,
      padding: nkSmallPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: MyNetworkImage(
              imageUrl: data.imagePath ?? '',
              fit: BoxFit.cover,
              height: AppDimensions.instance.height * 0.14,
            ),
          ),
          MyRegularText(
            label: data.productname ?? 'No Name',
            fontSize: NkFontSize.largeFont(),
            maxlines: 1,
            fontWeight: NkGeneralSize.nkBoldFontWeight(),
          ),
        ],
      ),
    );
  }

  Widget productButton(ProductList productVariant) => MyThemeButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                NkGeneralSize.nkCommonBorderRadius(borderRadius: 8))),
        height: AppDimensions.instance.height * 0.02,
        fontSize: NkFontSize.smallFont(),
        buttonText: addToCart,
        onPressed: () {
          Get.dialog(
              ProductDetailsDialog(
                productData: productVariant,
                productsController: productsController,
              ),
              barrierColor: backgroundColor.withOpacity(0.5));
        },
      );
}
