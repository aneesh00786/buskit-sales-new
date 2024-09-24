import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_filter_widget.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/product_details_diloag/product_details_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/widgets/my_theme_button.dart';

class CustomerOrderDetailMiddelWidget extends StatefulWidget {
  final ProductsController productsController;

  const CustomerOrderDetailMiddelWidget(
      {Key? key, required this.productsController})
      : super(key: key);

  @override
  State<CustomerOrderDetailMiddelWidget> createState() =>
      _CustomerOrderDetailMiddelWidgetState();
}

class _CustomerOrderDetailMiddelWidgetState
    extends State<CustomerOrderDetailMiddelWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

      child:Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            return Container();
            // return CategoryFilterWidget(
            //   onRetryPressed: () {
            //     widget.productsController.loadDataOfCategory;
            //   },
            //   categoryData: widget.productsController.categoryData.value.data,
            //   onSelected: (category, subCategory) {
            //     if (widget.productsController.categoryData.value.data != null) {
            //       widget.productsController.selectedSubCategoryId.value = widget
            //           .productsController
            //           .categoryData
            //           .value
            //           .data![category!]
            //           .subCategoryItem![subCategory!]
            //           .id!;
            //       widget.productsController.selectedCategoryId.value = widget
            //           .productsController.categoryData.value.data![category].id!;
            //       widget.productsController.selectedSubCategoryIndex.value =
            //           subCategory;
            //       widget.productsController.selectedCategoryIndex.value =
            //           category;
            //       /*   widget.productsController.productList.value = widget
            //             .productsController
            //             .categoryData
            //             .value
            //             .data![category]
            //             .subCategoryItem![subCategory]
            //             .productList ??
            //         [];*/

            //       WidgetsBinding.instance.addPostFrameCallback((_) {
            //         setState(() {
            //           widget.productsController.updateProductList(
            //               widget
            //                   .productsController
            //                   .categoryData
            //                   .value
            //                   .data![category]
            //                   .subCategoryItem![subCategory]
            //                   .productList
            //                   ?.map((e) => e)
            //                   .toSet()
            //                   .toList() ??
            //                   [],
            //               isBackupUpdate: true);
            //         });
            //       });
            //     }
            //   },
            // );
          })
          ,
          nkMediumSizeBox(),

          MyCommnonContainer(
          isCommonBorder: true,
    padding: nkRegularPadding(),
    width: AppDimensions.instance!.width * 0.3,
    //decoration: decoration,
    child:
          productListWidget(widget.productsController.productList),)
        ],
      ) ,
      scrollDirection: Axis.horizontal,
    )


      ;
  }

  Widget productListWidget(List<ProductList> productData) {
    return Obx(() {
      return NkWidgetExceptionHandel(
          data: productData,
          isShowRetrySection: false,
          onRetryPressed: () {
            //widget.productsController.loadDataOfProduct();
          },
          replaceWidget: widget.productsController.emptyProductWidget(),
          child: GridView.builder(
              shrinkWrap: true,
              physics: NkGeneralSize.commonPysics(),
              itemCount: productData.length,
              cacheExtent: 300,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                AppDimensions.instance.updateGridCount(Get.context!),
                mainAxisExtent: AppDimensions.instance.height * 0.26,
                crossAxisSpacing: AppDimensions.instance.width * 0.012,
                mainAxisSpacing: AppDimensions.instance.width * 0.018,
              ),
              itemBuilder: (context, index) {
                var data = productData[index];
                return productComponent(data);
              }),



        ) ;




        ;
    });
  }

  Widget productComponent(ProductList data) {
    return MyCommnonContainer(
      isCommonBorder: true,
      width:300,

      padding: nkSmallPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: MyNetworkImage(
              imageUrl: data.imagePath ?? '',
              fit: BoxFit.cover,
              height: AppDimensions.instance!.height * 0.14,
            ),
          ),
          MyRegularText(
            label: data.productname ?? 'No Name',
            fontSize: NkFontSize.largeFont(),
            maxlines: 1,
            fontWeight: NkGeneralSize.nkBoldFontWeight(),
          ),
          nkSmallSizeBox(),
          productButton(data)
        ],
      ),
    );
  }

  Widget productButton(ProductList productVariant) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: MyThemeButton(
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
                        productsController: widget.productsController,
                      ),
                      barrierColor: backgroundColor.withOpacity(0.5))
                  .then((value) {
                setState(() {});
              });
            },
          ),
        ),
        if (productVariant.variant
                ?.any((element) => (element.quntity ?? 0) > 0) ==
            true) ...[
          nkSmallSizeBox(),
          MyCommnonContainer(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            isCommonBorder: true,
            child: MyRegularText(
              label: productVariant.variant
                      ?.where((element) => (element.quntity ?? 0) > 0)
                      .length
                      .toString() ??
                  "0",
            ),
          )
        ]
      ],
    );
  }
}
