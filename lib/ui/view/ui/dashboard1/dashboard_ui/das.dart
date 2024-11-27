import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/dashboard_customer_dailog/dashboard_customer_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/dashboard_quantity_dailog/dashboard_quantity_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_form_field.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashBoardMiddleWidget extends StatelessWidget {
  final DashBoardController dashBoardController;
  BuildContext context;

  DashBoardMiddleWidget(
      {Key? key, required this.dashBoardController, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return nkMediumSizeBox(
      height: AppDimensions.instance!.height * 0.98,
      child: Column(
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: middleTopLeftComponet()),
                nkSmallSizeBox(),
                Flexible(child: middleTopRightComponet())
              ],
            ),
          ),
          nkMediumSizeBox(),
          Flexible(
            child: Row(
              children: [
                Flexible(child: communicationsDisplayWidget()),
                nkSmallSizeBox(),
                Flexible(child: topSellingProductWidget())
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget middleTopLeftComponet() {
    return MyCommnonContainer(
        isCommonBorder: true,
        padding: nkRegularPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: MyRegularText(
                      label: projectionsVsActual.toUpperCase(),
                      fontWeight: NkGeneralSize.nkBoldFontWeight(),
                      color: secondaryTextColor),
                ),
                const Icon(Icons.menu)
              ],
            ),
            nkMediumSizeBox(),
            // Flexible(
            //   child: nkMediumSizeBox(
            //       height: double.maxFinite,
            //       width: double.maxFinite,
            //       child: CustomBarChart()
            //       /* return BarChartSample2(
            //           categoryData: dashBoardController
            //                   .dashbordData.value.categoryPerformance ??
            //               [],
            //         );*/
            //       ),
            // )
          ],
        ));
  }

  Widget middleWidgetHeading(String text) {
    return MyRegularText(
        label: text,
        fontSize: NkFontSize.largeFont(),
        fontWeight: FontWeight.w500,
        color: secondaryTextColor);
  }

  Widget middleTopRightComponet() {
    Revenuss dummyData = Revenuss(
      totalSell: RevenueData(percentage: 60, totalPrice: 15000),
      sell: RevenueData(percentage: 40, totalPrice: 10000),
    );
    return MyCommnonContainer(
        isCommonBorder: true,
        padding: nkRegularPadding(),
        child: Column(
          children: [
            // middleWidgetHeading(revenue),

            nkLargeSizeBox(),
            // nkSmallSizeBox(),
            // Flexible(
            //   child: Obx(() {
            //     return DoughnutDefault(
            //       categoryData: dummyData,
            //       booking: "Booking : 3",
            //       order: "Order : 3",
            //          aColor: const Color(0xff33b4a8), bColor:  Colors.red, sabik: SizedBox.shrink(), sabik1: SizedBox.shrink(),
            //     );
            //   }),
            // ),
          ],
        ));
  }

  // Widget revenueDiplayWidget(
  //     {required String nameOfProgress,
  //     required String secondNameOfProgress,
  //     Color? color,
  //     Color? progressBGColor,
  //     required String totalAmont,
  //     required double progressValue}) {
  //   dashBoardController.totalRevenue.value = progressValue / 100;
  //   return MyCommnonContainer(
  //     isCommonBorder: false,
  //     width: double.maxFinite,
  //     padding: nkRegularPadding(),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         dashBoardController.revenueProgressBar(
  //             progressValue / 100,
  //             color ?? revenueProgressBarFilledColor,
  //             progressBGColor ?? revenueProgressBarColor),
  //         const Spacer(),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 MyRegularText(
  //                     label: totalAmont,
  //                     fontWeight: NkGeneralSize.nkBoldFontWeight(),
  //                     fontSize: NkFontSize.largeFont()),
  //                 nkMediumSizeBox(),
  //                 Wrap(
  //                   direction: Axis.horizontal,
  //                   spacing: 2,
  //                   alignment: WrapAlignment.center,
  //                   crossAxisAlignment: WrapCrossAlignment.center,
  //                   children: [
  //                     ClipOval(
  //                       child: SizedBox(
  //                           height: AppDimensions.instance!.height * 0.02,
  //                           width: AppDimensions.instance!.height * 0.02,
  //                           child: ColoredBox(
  //                               color: color ?? revenueProgressBarColor)),
  //                     ),
  //                     MyRegularText(
  //                       label: nameOfProgress,
  //                       color: primaryColor,
  //                       fontSize: NkFontSize.smallFont(),
  //                     )
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             nkMediumSizeBox(),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 MyRegularText(
  //                     label: totalAmont,
  //                     fontWeight: NkGeneralSize.nkBoldFontWeight(),
  //                     fontSize: NkFontSize.largeFont()),
  //                 nkMediumSizeBox(),
  //                 Wrap(
  //                   direction: Axis.horizontal,
  //                   spacing: 2,
  //                   alignment: WrapAlignment.center,
  //                   crossAxisAlignment: WrapCrossAlignment.center,
  //                   children: [
  //                     ClipOval(
  //                       child: SizedBox(
  //                           height: AppDimensions.instance!.height * 0.02,
  //                           width: AppDimensions.instance!.height * 0.02,
  //                           child: const ColoredBox(
  //                               color: revenueProgressBarColor)),
  //                     ),
  //                     MyRegularText(
  //                       label: secondNameOfProgress,
  //                       color: primaryColor,
  //                       fontSize: NkFontSize.smallFont(),
  //                     )
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget communicationsDisplayWidget() {
    return MyCommnonContainer(
      height: AppDimensions.instance!.height,
      isCommonBorder: true,
      padding: nkRegularPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          middleWidgetHeading(communications),
          nkSmallSizeBox(),
          for (int i = 0; i < 3; i++) ...[
            communicationsDisplayListWidget(
                dashBoardController.communicationList[i], i),
            nkSmallSizeBox()
          ],
          sendReplay()
        ],
      ),
    );
  }

  Widget sendReplay() {
    double iconSize = 24.0;
    return Row(
      children: [
        Icon(
          Icons.person,
          color: primaryColor,
          size: iconSize,
        ),
        nkSmallSizeBox(),
        Flexible(
            child: MyFormField(
          controller: dashBoardController.communicationController,
          labelText: '',
          enableColor: primaryTextFieldColor,
          focusedColor: primaryTextFieldColor,
          disabledColor: primaryTextFieldColor,
          maxLines: 1,
        )),
        nkSmallSizeBox(),
        Icon(
          Icons.camera_alt_outlined,
          color: primaryColor,
          size: iconSize,
        ),
        nkSmallSizeBox(),
        InkResponse(
          onTap: () {
            if (dashBoardController.selectedCommunicationIndex.value == -1) {
              // NkCommonFunction.showErrorToast(pleaseSelectAUserToSend);
              return;
            }
            if (dashBoardController.communicationController.text.isEmpty) {
          //    NkCommonFunction.showErrorToast(pleaseEnterMessage);
              return;
            }
            dashBoardController.communicationController.clear();
          },
          child: Icon(
            Icons.send,
            color: primaryColor,
            size: iconSize,
          ),
        ),
      ],
    );
  }

  Widget communicationsDisplayListWidget(Map<String, dynamic> data, int index) {
    return Obx(
      () => MyCommnonContainer(
        padding: dashBoardController.selectedCommunicationIndex.value == index
            ? nkSmallPadding()
            : null,
        onTap: () {
          dashBoardController.selectedCommunicationIndex.value = index;

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                          child: MyNetworkImage(
                        imageUrl: data["image"],
                        height: AppDimensions.instance!.height * 0.05,
                        width: AppDimensions.instance!.height * 0.05,
                      )),
                      Text(
                        "   " + data["name"],
                        style: TextStyle(fontSize: 12),
                      )
                    ]),
                content: Container(
                  width: double.maxFinite,
                  color: Color(0xffebe8e5),
                  child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Align(
                              child: Padding(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xffddf7c9),
                                  ),
                                  child: Padding(
                                    child: Container(
                                        constraints: BoxConstraints(
                                            minWidth: 50, maxWidth: 150),
                                        child: Text("Hi..",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87))),
                                    padding: EdgeInsets.all(10),
                                  ),
                                ),
                                padding: EdgeInsets.all(10),
                              ),
                              alignment: (index % 2 == 0)
                                  ? FractionalOffset.topRight
                                  : FractionalOffset.topLeft,
                            )
                          ],
                        );
                      }),
                ),
              );
            },
          );
        },
        isCommonBorder:
            dashBoardController.selectedCommunicationIndex.value == index,
        child: Row(
          children: [
            ClipOval(
                child: MyNetworkImage(
              imageUrl: data["image"],
              height: AppDimensions.instance!.height * 0.05,
              width: AppDimensions.instance!.height * 0.05,
            )),
            nkSmallSizeBox(),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyRegularText(label: data["name"]),
                  MyRegularText(
                    label: data["message"],
                    fontSize: NkFontSize.smallFont(),
                    color: primaryColor,
                    align: TextAlign.start,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget topSellingProductWidget() {
    return MyCommnonContainer(
      isCommonBorder: true,
      padding: nkRegularPadding(),
      child: SingleChildScrollView(
        padding: nkSymmetricPadding(horizontal: 0),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            middleWidgetHeading(topSellingProduct),
            nkMediumSizeBox(),
            topSellingProductList()
          ],
        ),
      ),
    );
  }

  Widget topSellingProductList() {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        physics: NkGeneralSize.commonPysics(),
        itemCount:
            dashBoardController.dashbordData.value.topSellingProducts?.length ??
                0,
        itemBuilder: (context, index) {
          var sellingData =
              dashBoardController.dashbordData.value.topSellingProducts![index];
          return topSellingProductListComponent(
              sellingData as TopSellingProduct); /*  return topSellingProductListComponent(
              (sellingData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
              sellingData.variationName?.toString() ?? '');*/
        },
        separatorBuilder: (context, index) {
          return nkSmallSizeBox();
        },
      );
    });
  }

  Widget topSellingProductListComponent(TopSellingProduct productData) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Get.dialog(DashBoardCustomerDialog(
                  customerList: productData.customer ?? []));
            },
            child: itemComponet(
                productData.variationName
                    .toString()
                    .nkStringCapitalizeFirstCaracter,
                NKDateUtils.commonDayFormat(NKDateUtils.formatStringUTCDateTime(
                    productData.createdAt.toString()))),
          ),
          itemComponet(
              (productData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
              price),
          InkWell(
              onTap: () {
                Get.dialog(DashBoardQuantityDialog(
                  quantityList: productData.quantityList ?? [],
                ));
              },
              child: itemComponet(
                  productData.quantity?.toString() ?? '0', quantity)),
          itemComponet(
              (productData.price?.toString() ?? "0").nkValueWithCurrencySymbol,
              amount),
        ],
      ),
      scrollDirection: Axis.horizontal,
    );
  }

  Widget itemComponet(String title, String subTitle) {
    return nkChildWrappedSizeBox(
      width: AppDimensions.instance!.width * 0.09,
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

/*
  Widget exportWidget(String lable) {
    return MyCommnonContainer(
      padding: nkRegularPadding(
          left: AppDimensions.instance!.height * 0.018,
          right: AppDimensions.instance!.height * 0.018),
      color: const Color(0xFFEEF2F7),
      onTap: () {
        // Get.dialog(CalanderDiloag());
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          MyRegularText(label: lable),
          nkSmallSizeBox(),
          const Flexible(child: Icon(Icons.ios_share_rounded)),
        ],
      ),
    );
  }
*/
}
