import 'package:busskit_salesexecutive/ui/components/bar_and_chart/customer_collection_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/customer_order_delevery_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_popup_menue.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_total_sale_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDashboardBottomWidget extends StatelessWidget {
  final CustomerDashbordController customerDashBoardController;

  const CustomerDashboardBottomWidget(
      {super.key, required this.customerDashBoardController});

  @override
  Widget build(BuildContext context) {
    return nkMediumSizeBox(
      width: double.maxFinite,
      height: AppDimensions.instance.height * 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: bottomLeftSideComponent()),
          nkSmallSizeBox(),
          Flexible(child: topSellingProductWidget())
        ],
      ),
    );
  }

  Widget bottomLeftSideComponent() {
    return MyCommnonContainer(
      padding: nkSymmetricPadding(),
      isCommonBorder: true,
      child: Column(
        children: [
          Obx(() {
            return Align(
              alignment: Alignment.topLeft,
              child: MyPopUpMenu<int>(
                  onItemSelected: (value) {
                    customerDashBoardController.selectYearIndex.value = value;
                    // customerDashBoardController
                    //     .getCustomerDahsboardTotalSaleData(
                    //         customerDashBoardController
                    //             .customerAndOrderData.value.customerId!,
                    //         customerDashBoardController
                    //                 .customerDashboardData
                    //                 .value
                    //                 .yearList?[customerDashBoardController
                    //                     .selectYearIndex.value]
                    //                 .year
                    //                 ?.toString() ??
                    //             '');
                    customerDashBoardController.updateWidget();
                  },
                  items: List.generate(
                      customerDashBoardController
                              .customerDashboardData.value.yearList?.length ??
                          0, (index) {
                    var data = customerDashBoardController
                        .customerDashboardData.value.yearList?[index];
                    return PopupMenuItem(
                      value: index,
                      child: MyRegularText(
                        label: data?.year?.toString() ?? '',
                      ),
                    );
                  }),
                  buttonChild: MyCommnonContainer(
                    color: primaryColor.withOpacity(0.4),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyRegularText(
                          label: customerDashBoardController
                                  .customerDashboardData
                                  .value
                                  .yearList?[customerDashBoardController
                                      .selectYearIndex.value]
                                  .year
                                  .toString() ??
                              '',
                        ),
                        const Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  )),
            );
          }),
          Row(
            children: [
              Flexible(child: collectionChart()),
              Flexible(child: orderDeliveryChart())
            ],
          ),
          //nkLargeSizeBox(),
          //nkSmallSizeBox(),
          // MyThemeButton(
          //   buttonText: orderTaking,
          //   onPressed: () {
          //     customerDashBoardController.customerAndOrderData.value.cart =
          //         null;
          //     customerDashBoardController
          //         .getCustomerCartData(customerDashBoardController
          //             .customerAndOrderData.value.customerId!)
          //         .then((value) {
          //       if (value.data != null && value.data!.isNotEmpty) {
          //         customerDashBoardController.customerAndOrderData.value.cart =
          //             value.data?.first.cart;
          //       }
          //       Get.toNamed(AppRoutes.customerOrderDetails,
          //           arguments:
          //               customerDashBoardController.customerAndOrderData.value);
          //     });
          //   },
          //   height: 26,
          //   width: AppDimensions.instance!.width * 0.12,
          // )
        ],
      ),
    );
  }

  Widget collectionChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        middleWidgetHeading(collection),
        nkLargeSizeBox(),
        Obx(() {
          return CustomerCollectionPieChart(
            collectionData: customerDashBoardController
                    .customerDashboardTotalSaleData.value.totalSale ??
                TotalSale(),
          );
        }),
      ],
    );
  }

  Widget orderDeliveryChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        middleWidgetHeading(orderDelivery),
        nkLargeSizeBox(),
        Obx(() {
          return CustomerOrderDeleveryPieChart(
            deleveryData: customerDashBoardController
                    .customerDashboardTotalSaleData.value.totalSale ??
                TotalSale(),
          );
        }),
      ],
    );
  }

  Widget middleWidgetHeading(String text) {
    return MyRegularText(
        label: text,
        fontSize: NkFontSize.largeFont(),
        fontWeight: FontWeight.w500,
        color: secondaryTextColor);
  }

  Widget topSellingProductWidget() {
    return MyCommnonContainer(
      isCommonBorder: true,
      padding: nkRegularPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          middleWidgetHeading(topSellingProduct),
          nkMediumSizeBox(),
          Flexible(child: topSellingProductList())
        ],
      ),
    );
  }

  Widget topSellingProductList() {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        physics: NkGeneralSize.commonPysics(),
        itemCount: customerDashBoardController
                .customerDashboardData.value.frequantliyProductLists?.length ??
            0,
        itemBuilder: (context, index) {
          var topSellingProduct = customerDashBoardController
              .customerDashboardData.value.frequantliyProductLists?[index];
          return topSellingProductListComponent(topSellingProduct!);
        },
        separatorBuilder: (context, index) {
          return nkSmallSizeBox();
        },
      );
    });
  }

  Widget topSellingProductListComponent(FrequantliyProductLists productData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        itemComponet(
            productData.variationName
                .toString()
                .nkStringCapitalizeFirstCaracter,
            NKDateUtils.apiDayFormat(NKDateUtils.formatStringUTCDateTime(
                productData.createdAt.toString()))),
        itemComponet(
            (productData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
            price),
        itemComponet(productData.quantity?.toString() ?? '0', quantity),
        itemComponet(
            (productData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
            amount),
      ],
    );
  }

  Widget itemComponet(String title, String subTitle) {
    return nkChildWrappedSizeBox(
      width: AppDimensions.instance.width * 0.09,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyRegularText(
            label: title,
            color: primaryColor,
          ),
          MyRegularText(
            label: subTitle,
            color: secondaryTextColor,
            fontSize: NkFontSize.smallFont(),
          )
        ],
      ),
    );
  }
}
