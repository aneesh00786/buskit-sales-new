import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_diloag_screen.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_filter.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductTopWidget extends StatelessWidget {
  final ProductsController productsController;

  const ProductTopWidget({Key? key, required this.productsController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
        //   Flexible(
        //       child: SearchFilter(
        //     onChanged: (changedJson) async {
        //       log("CHangedddd ${changedJson}");
        //       try {
        //         final data =
        //             SearchData.fromJson(jsonDecode(changedJson.toString()));
        //         productsController.searchCustomerController.text =
        //             data.fullname!;
        //         await productsController
        //             .loadSelectedCustomer(data.customerId!)
        //             .whenComplete(() {
        //           productsController
        //               .changeCrossFadeState(CrossFadeState.showSecond);
        //           /*   Get.toNamed(AppRoutes.customerOrderDetails,
        //             arguments: productsController.customerAndOrderData);*/
        //         });
        //       } on FormatException catch (e) {
        //         log("Ignore me ${e}");
        //       }
        //     },
        //     listItemBuilder: (ctx, string) {
        //       final data = SearchData.fromJson(jsonDecode(string));
        //       return productsController.searchCustomerWidget(data);
        //     },
        //     futureRequest: (p0) async {
        //       if (p0.length > 2) {
        //         await productsController.searchCustomer(p0);
        //       }
        //       return productsController.searchData
        //           .map((element) => jsonEncode(element.toJson()))
        //           .toList();
        //     },
        //     searchTextController: productsController.searchCustomerController,
        //   )),
        //   clearButton,
        //   const Spacer(),

        //   /* bulkUploadButton,
        // nkMediumSizeBox(),*/
        //   productsController.customerAndOrderData.value.imageUrl != null
        //       ? topHeadingCustomerSection(
        //           productsController.customerAndOrderData.value.imageUrl ?? '',
        //           productsController.customerAndOrderData.value.fullname!)
        //       : const SizedBox()
        ],
      );
    });
  }

  Widget get clearButton => AnimatedCrossFade(
        alignment: Alignment.centerRight,
        firstChild: const SizedBox(),
        secondChild: MyThemeButton(
          buttonText: "clear",
          onPressed: () {
            productsController.changeCrossFadeState(CrossFadeState.showFirst);

            Future.microtask(() {
              productsController.clearAllData;
            });
          },
        ),
        crossFadeState: productsController.crossFadeState,
        duration: NkCommonFunction.longDuration(),
      );

  Widget topHeadingCustomerSection(String imageUrl, String customerName,
      {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        children: [
          InkResponse(
              onTap: () => Get.dialog(CartDiloagScreen(
                    productsController: productsController,
                  )),
              child: const Icon(Icons.shopping_cart_outlined)),
          ClipOval(
              child: MyNetworkImage(
            imageUrl: imageUrl,
            height: AppDimensions.instance.height * 0.05,
            width: AppDimensions.instance.height * 0.05,
          )),
          MyRegularText(label: customerName),
        ],
      ),
    );
  }
}
