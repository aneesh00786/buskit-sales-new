import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_increment_decrement.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/nk_loading_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../category_filter/category_model.dart';

class ProductDetailsDialog extends Dialog {
  final ProductsController productsController;
  final ProductList productData;
  const ProductDetailsDialog(
      {super.key, required this.productData, required this.productsController});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        minimum: nkSymmetricPadding(
            vertical: AppDimensions.instance!.height * 0.08,
            horizontal:
                AppDimensions.instance!.orientation == Orientation.landscape
                    ? AppDimensions.instance!.width * 0.20
                    : AppDimensions.instance!.width * 0.05),
        child: Card(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
            child: Scaffold(
              appBar: DiloagAppBar(
                title: productVariant,
              ),
              body: productMainWidget,
            ),
          ),
        ),
      );
    });
  }

  Widget get productMainWidget => Column(
        children: [
          productImageAndName,
          Flexible(child: productVariantListTable),
          nkMediumSizeBox(),
          NkLoadingButton(
            //btnController: productsController.btnController,
            width: AppDimensions.instance!.width * 0.12,
            padding: nkRegularPadding(),
            onPressed: () {
              var data = productData.variant!
                  .where((element) =>
                      element.quntity != null && element.quntity != 0)
                  .toList();

              if (data.isEmpty) {
                // productsController.btnController.error();
                // productsController.btnController.reset();
                return;
              }
              final productBYData = AddToCartModel(
                customerId:
                    productsController.customerAndOrderData.value.customerId!,
                salesmanId: SessionHelper.loginSavedData!.salesmanId!,
                cartId:
                    productsController.customerAndOrderData.value.cartId ?? '',
                cartList: data
                    .map((e) => SendCartData(
                        productId: e.productId!,
                        variantId: e.variationId!,
                        pack: e.packtype == 'Pack'
                            ? e.pieces.toString()
                            : e.quntity.toString(),
                        packType: e.packtype == 'Pack' ? 'Pack' : 'Pcs',
                        price: e.price.toString(),
                        discount: 0,
                        quantity: e.quntity!.toInt(),
                        variantName: ''
                        ))
                    .toList(),
                total: data
                    .map((e) => e.price!)
                    .reduce((a, b) => a + b)
                    .toString(),
                discount: '0',
              );

              /////////////////////////////// [Item Selected in Cart Validation]///////////////////////////////////

              /*  if (productBYData.any((element) => element.name!.price != 0)) {
                productsController.addProductToCart(
                    productBYData, productsController);
              } else {
                NkCommonFunction.showErrorSnakBar(noItemAddedToCart);
                productsController.btnController.error();
                productsController.btnController.reset();
              }*/
              productsController.addProductToCart(
                  productBYData, productsController);
            },
            buttonText: addToCart,
          )
        ],
      );

  Widget get productImageAndName => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            direction: Axis.vertical,
            children: [
              MyRegularText(
                label: productData.productname ?? '',
                fontWeight: NkGeneralSize.nkBoldFontWeight(),
                fontSize: NkFontSize.extraLargeFont() - 10,
              ),
              const MyRegularText(
                label: "Product Code:C-LEN/SC_RLE/ADB",
                color: secondaryTextColor,
              ),
            ],
          ),
          nkMediumSizeBox(),
          MyNetworkImage(
            imageUrl: productData.imagePath ?? '',
            height: AppDimensions.instance!.height * 0.2,
          )
        ],
      );

  Widget get productVariantListTable => SizedBox(
        width: double.maxFinite,
        child: DataTable(
            headingRowColor:
                MaterialStateColor.resolveWith((states) => primaryColor),
            headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                color: buttonTextColor, fontSize: NkFontSize.largeFont()),
            columns: productVariantTableColumn,
            rows: productVariantTableRow),
      );

  List<DataColumn> get productVariantTableColumn =>
      productsController.productVariantColumnNames
          .map((element) => DataColumn(
                  label: MyRegularText(
                color: buttonTextColor,
                align: TextAlign.center,
                fontSize: NkFontSize.largeFont(),
                label: element,
              )))
          .toList();

  List<DataRow> get productVariantTableRow =>
      productData.variant
          ?.map((e) => DataRow(cells: [
                DataCell(MyRegularText(
                  label: e.variants ?? "0",
                )),
                DataCell(MyRegularText(
                  label: "${e.packtype}(${e.pieces?.toInt() ?? 0} PCS) ",
                )),
                DataCell(
                  MyRegularText(
                    label: "${e.price?.toInt() ?? 0}"
                        .nkValueWithCurrencySymbol
                        .removeAllWhitespace,
                  ),
                ),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    productsController.isStockAvlableWidget(e.price!).$1,
                    nkMediumSizeBox(),
                    productsController.isStockAvlableWidget(e.price!).$2
                        ? NkIncrementDecrement(
                            initialCount: (e.quntity ?? 0).toInt(),
                            onValueChange: (counts) {
                              e.quntity = counts;

                              /*     productsController.addProductToCart(CartDartModel(
                          variantId: e.productId,
                            discount: 0,
                            pack: "${e.packtype}(${e.pieces?.toInt() ?? 0} PCS) ",
                            price: e.price,
                            productName: productData.productname,
                            variant: e.variants,
                            quntity: counts,
                            total: (e.price! * counts).toInt().toString())); */
                            },
                          )
                        : nkChildWrappedSizeBox()
                  ],
                ))
                // DataCell(NkIncrementDecrement(initialCount: e.stock!.toInt(),)),
              ]))
          .toList() ??
      [];
}
