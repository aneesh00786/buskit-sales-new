import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/order_details_diloag/order_details_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PendingPaymentBottomWidget extends StatelessWidget {
  final PendingPaymentController orderController;

  const PendingPaymentBottomWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return MyCommnonContainer(child: Obx(() {
      return NkWidgetExceptionHandel(
          onRetryPressed: () => {},
          data: orderController.orderDataList,
          child: Column(
            children: [
              _buildDataTableHeader,
              Expanded(child: orderBottomTableWidget)
            ],
          ));
    }));
  }

  Widget get _buildDataTableHeader => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: nkChildWrappedSizeBox(
          width: AppDimensions.instance.width,
          child: DataTable(
              //  columnSpacing: 120.0,
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => primaryColor),
              headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                  color: buttonTextColor,
                  fontSize: NkFontSize.largeFont(),
                  fontWeight: FontWeight.bold),
              // dataRowMaxHeight: AppDimensions.instance!.height * 0.11,
              columns: orderController.orderTableColumCategory
                  .map((element) => DataColumn(
                          label: MyRegularText(
                        label: element,
                        color: buttonTextColor,
                        fontSize: NkFontSize.largeFont(),
                      )))
                  .toList(),
              rows: []),
        ),
      );

  Widget get orderBottomTableWidget => SingleChildScrollView(
        child: nkChildWrappedSizeBox(
          width: AppDimensions.instance.width,
          child: DataTable(
              headingRowHeight: 0.0,
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => primaryColor),
              headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                  color: buttonTextColor,
                  fontSize: NkFontSize.largeFont(),
                  fontWeight: FontWeight.bold),
              dataRowMaxHeight: AppDimensions.instance.height * 0.11,
              columns: orderController.orderTableColumCategory
                  .map((element) => DataColumn(
                          label: MyRegularText(
                        label: element,
                        color: buttonTextColor,
                        fontSize: NkFontSize.largeFont(),
                      )))
                  .toList(),
              rows: genratedRows),
        ),
      );

  List<DataRow> get genratedRows => orderController.orderDataList
      .map(
        (e) => DataRow(
          cells: List.generate(
            orderRowsWidget(e).length,
            (index) => DataCell(
              orderRowsWidget(e)[index],
            ),
          ),
        ),
      )
      .toList();

  List<Widget> orderRowsWidget(OrderData orderData) => [
        customerDetailsWidget(orderData.cart!.first),
        Padding(
          padding: EdgeInsets.only(left: AppDimensions.instance!.width * 0.04),
          child: orderNumberWidget(orderData.cart!.first),
        ),
        Padding(
          padding: EdgeInsets.only(left: AppDimensions.instance!.width * 0.09),
          child: orderCreatedDateWidget(orderData.cart!.first),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: AppDimensions.instance!.width * 0.08,
              right: AppDimensions.instance!.width * 0.06),
          child: orderPrice(orderData.cart!.first),
        ),
        orderStatus(orderData.cart!.first),
        viewOrder(orderData),
      ];

  Widget customerDetailsWidget(CustomerCart orderData) {
    return GestureDetector(
      onTap: () => {},
      child: Row(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRegularText(
                label: orderData.customerDetails?.fullname ?? '',
              ),
              MyRegularText(
                label: orderData.customerDetails?.mobileno ?? '',
              ),
              SizedBox(
                width: 140,
                child: MyRegularText(
                  align: TextAlign.start,
                  label: orderData.customerDetails?.email ?? '',
                ),
              ),
            ])
      ]),
    );
  }

  Widget orderNumberWidget(CustomerCart orderData) {
    return MyRegularText(
        label: orderData.optionOrderData?.orderId ?? '',
        fontWeight: FontWeight.w600);
  }

  Widget orderCreatedDateWidget(CustomerCart orderData) {
    return MyRegularText(
        label: NKDateUtils.fullDayFormat(NKDateUtils.formatStringUTCDateTime(
            orderData.optionOrderData!.orderCreatAt!)),
        fontWeight: FontWeight.w600);
  }

  Widget orderPrice(CustomerCart orderData) {
    return MyRegularText(
      label: orderData.optionOrderData?.orderTotal
              .toString()
              .nkValueWithCurrencySymbol
              .removeAllWhitespace ??
          '',
      fontWeight: FontWeight.w600,
    );
  }

  Widget orderStatus(CustomerCart orderData) {
    return Container(
      padding: nkRegularPadding(),
      decoration: BoxDecoration(
        color:
            OrderHandlingClass.fromType(orderData.optionOrderData!.orderStatus!)
                .orderColor,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: MyRegularText(
        label:
            OrderHandlingClass.fromType(orderData.optionOrderData!.orderStatus!)
                .name,
      ),
    );
  }

  Widget viewOrder(OrderData orderData) {
    return InkResponse(
        onTap: () {
          Get.dialog(OrderDetailsDiloag(
            orderResponce: OptionOrderData.fromJson(orderData.toJson()),
          )).then((value) {
            if (value is bool) {
              orderController.loadOrderData;
            }
          });
        },
        child: SvgPicture.asset(Assets.iconsIcView));
  }
}
