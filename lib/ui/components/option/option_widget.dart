import 'dart:developer';

import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/top_shortcusts_diloag/order_status_dialog_without_payment.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/top_shortcusts_diloag/order_status_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';
import '../../utills/const_string.dart';

class OptionWidget extends StatelessWidget {
  final UserType userType;
  final String userId;
  final (String, VoidCallback) Function(int index, OrderStatus orderStatus)?
      optionFun;
  final int? orderCount;
  final int? eastimatesCount;
  final int? preOrderCount;
  final int? draftCount;
  final int? cancelledCount;
  final String? customType;
  final bool? isVisible;
  final OrderStatus? customOrderStatusType;
  final String? startDate;
  final String? endDate;

  const OptionWidget({
    super.key,
    this.optionFun,
    required this.userType,
    required this.userId,
    this.orderCount,
    this.eastimatesCount,
    this.preOrderCount,
    this.draftCount,
    this.customType,
    this.customOrderStatusType,
    this.startDate,
    this.endDate,
    this.isVisible = false,
    this.cancelledCount,
  });

  @override
  Widget build(BuildContext context) {
    return options();
  }

  Widget options() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween ,
      children: _defaultOption.map((e) => orderOptions(e)).toList(),
    );
  }

  List<OptionData> get _defaultOption => [
        OptionData(
            title: orders,
            count: orderCount?.toString() ?? "0",
            svg: Assets.iconsIcDashboardShoppingCart,
            svgBgColor: const Color(0xFFFCDABD),
            onTap: optionFun?.call(0, OrderStatus.preOrder).$2 ??
                () {
                  log('startDateasa++++ +++ 111++ ${startDate}');
                  log('startDateasa+1111+++222 +++ ++ ${endDate}');
                  Get.dialog(OrderStatusDiloag(
                    orderStatus: OrderStatus.preOrder,
                    heading: orders,
                    userType: userType,
                    userId: userId,
                    customType: customOrderStatusType == OrderStatus.preOrder
                        ? customType
                        : null,
                    startDate: startDate,
                    endDate: endDate,
                  ));
                }),
        OptionData(
          title: estimates,
          count: eastimatesCount?.toString() ?? "0",
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color(0xFFC3DDFD),
          onTap: optionFun?.call(1, OrderStatus.estimates).$2 ??
              () {
                Get.dialog(OrderStatusDialogWithOutPayment(
                  heading: estimates,
                  userType: userType,
                  userId: userId,
                  customType: customOrderStatusType == OrderStatus.estimates
                      ? customType
                      : null,
                  startDate: startDate,
                  endDate: endDate,
                ));
              },
        ),
        OptionData(
          title: preOrder,
          count: preOrderCount?.toString() ?? "0",
          svg: Assets.iconsIcDashboardPreOrder,
          onTap: optionFun?.call(2, OrderStatus.preOrder).$2 ??
              () {
                Get.dialog(OrderStatusDialogWithOutPayment(
                  orderStatus: OrderStatus.preOrder,
                  heading: preOrder,
                  userType: userType,
                  userId: userId,
                  customType: customOrderStatusType == OrderStatus.outOfDelivery
                      ? customType
                      : null,
                  startDate: startDate,
                  endDate: endDate,
                ));
                print("per-oder++${preOrderCount.toString()}");
              },
          svgBgColor: const Color(0xFFAFECEF),
        ),
        OptionData(
          title: draft,
          count: draftCount?.toString() ?? "0",
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color(0xFFBCF0DA),
          onTap: optionFun?.call(3, OrderStatus.draft).$2 ??
              () {
                Get.dialog(OrderStatusDialogWithOutPayment(
                  orderStatus: OrderStatus.draft,
                  heading: draft,
                  userType: userType,
                  userId: userId,
                  customType: customOrderStatusType == OrderStatus.draft
                      ? customType
                      : null,
                  startDate: startDate,
                  endDate: endDate,
                ));
              },
        ),
      ];

  Widget orderOptions(OptionData optionData) {
    /* log("count++++${optionData.count.toString()}");*/
    double containerWidth;
    if (ResponsiveInfo.isMobile()) {
      containerWidth = AppDimensions.instance.width * 0.07;
    } else if (ResponsiveInfo.isTablet()) {
      containerWidth = AppDimensions.instance.width * 0.14;
    } else {
      containerWidth = AppDimensions.instance.width * 0.65;
    }
    SvgPicture svgComponet = SvgPicture.asset(
      optionData.svg,
  height: AppDimensions.instance.height * 0.03,
      fit: BoxFit.contain,
    );
    return MyCommnonContainer(
      color: buttonTextColor,
        onTap: optionData.onTap,
        margin: nkSymmetricPadding(
            vertical: 0, horizontal: AppDimensions.instance.width * 0.004),
        padding: nkSymmetricPadding(),
         width: containerWidth,
         // ResponsiveInfo.isMobile()?AppDimensions.instance.width * 0.05:AppDimensions.instance.width * 0.135,
        isCommonBorder: true,
        child:
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ClipOval(
            child: ColoredBox(
                color: optionData.svgBgColor,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: svgComponet,
                )),
          ),
          //nkExtraSmallSizeBox(),
          Flexible(
            child: Wrap(
              direction: Axis.vertical,
              //spacing: 0.2,
              children: [
                MyRegularText(
                  label: optionData.title,
                  maxlines: optionData.title.length,

                ),
                MyRegularText(
                  label: optionData.count,

                )
              ],
            ),
          )
        ])



          ,
      );

  }
}

class OptionData {
  String title;
  String count;
  String svg;
  Color svgBgColor;
  VoidCallback? onTap;

  static const int preOrders = 0;
  static const int delivered = 2;
  static const int draft = 2;

  OptionData({
    required this.title,
    required this.count,
    required this.svg,
    required this.svgBgColor,
    this.onTap,
  });
}
