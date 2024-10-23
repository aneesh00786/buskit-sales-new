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
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductMiddelWidget extends StatelessWidget {
  final ProductsController productsController;

  const ProductMiddelWidget({Key? key, required this.productsController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
       return SizedBox(
          height: 1200,
          width: availableWidth,
          child: 
         Obx(() {
            return productsController.isReached.value
                ? CustomerDachScreen(
                    cusId: 'CUST01',
                  )
                : OrderTaking(
                    productsController: productsController,
                  );
          }),
          );
      },
    );
  }

  // Widget productListWidget(List<ProductList> productData) {
  //   return Obx(() {
  //     return NkWidgetExceptionHandel(
  //       data: productData,
  //       isShowRetrySection: false,
  //       onRetryPressed: () {
  //         //productsController.loadDataOfProduct();
  //       },
  //       replaceWidget: productsController.emptyProductWidget(),
  //       child: GridView.builder(
  //           shrinkWrap: true,
  //           physics: NkGeneralSize.commonPysics(),
  //           itemCount: productData.length,
  //           cacheExtent: 300,
  //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //             // crossAxisCount:
  //             //     AppDimensions.updateGridCount(Get.context!).gridItemCount,
  //             crossAxisCount: 3,
  //             mainAxisExtent: AppDimensions.instance.height * 0.26,
  //             crossAxisSpacing: AppDimensions.instance.width * 0.012,
  //             mainAxisSpacing: AppDimensions.instance.width * 0.018,
  //           ),
  //           itemBuilder: (context, index) {
  //             var data = productData[index];
  //             return productComponent(data);
  //           }),
  //     );
  //   });
  // }

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

          /*productButton(data)*/
        ],
      ),
    );
  }

  Widget productButton(ProductList productVariant) => MyThemeButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                NkGeneralSize.nkCommonBorderRadius(borderRadius: 8))),
        height: AppDimensions.instance!.height * 0.02,
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
