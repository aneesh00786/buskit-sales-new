import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OrderBottomWidget extends StatelessWidget {
  final OrderController orderController;



   OrderBottomWidget({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return  Obx(() {
      return NkWidgetExceptionHandel(
          onRetryPressed: () => {},
          data: orderController.orderDataList,
          child: Stack(
            children: [
              // _buildDataTableHeader,

              Align(
                child:     Container(
                  width: double.infinity,
                  height:(MediaQuery.of(context).orientation ==
                      Orientation.portrait)
                      ? (ResponsiveInfo.isMobileDimension(context)
                      ? 50
                      : 65)
                      : (ResponsiveInfo.isMobileDimension(context)
                      ? 70
                      : 80) ,
                  color: Color(0xff727df5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Expanded(child: Padding(
                        child: Text(
                          "Customer List",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                              fontSize: (MediaQuery.of(
                                  context)
                                  .orientation ==
                                  Orientation
                                      .portrait)
                                  ? (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 3
                                  : 6)
                                  : (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 6
                                  : 10),
                              color:
                              Colors.white,
                              fontFamily:
                              'Poppins_Regular',
                              fontWeight:
                              FontWeight
                                  .bold),
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                        ),
                        padding:
                        EdgeInsets.all(2),
                      ),flex: 2,),
                      Expanded(child: Padding(
                        child: Text(
                          "Order Number",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                              fontSize: (MediaQuery.of(
                                  context)
                                  .orientation ==
                                  Orientation
                                      .portrait)
                                  ? (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 3
                                  : 6)
                                  : (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 6
                                  : 10),
                              color:
                              Colors.white,
                              fontFamily:
                              'Poppins_Regular',
                              fontWeight:
                              FontWeight
                                  .bold),
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                        ),
                        padding:
                        EdgeInsets.all(2),
                      ),flex: 1,),
                      Expanded(child: Padding(
                        child: Text(
                          "Order created",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                              fontSize: (MediaQuery.of(
                                  context)
                                  .orientation ==
                                  Orientation
                                      .portrait)
                                  ? (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 3
                                  : 6)
                                  : (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 6
                                  : 10),
                              color:
                              Colors.white,
                              fontFamily:
                              'Poppins_Regular',
                              fontWeight:
                              FontWeight
                                  .bold),
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                        ),
                        padding:
                        EdgeInsets.all(2),
                      ),flex: 1,),
                      Expanded(child: Padding(
                        child: Text(
                          "Order Price",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                              fontSize: (MediaQuery.of(
                                  context)
                                  .orientation ==
                                  Orientation
                                      .portrait)
                                  ? (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 3
                                  : 6)
                                  : (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 6
                                  : 10),
                              color:
                              Colors.white,
                              fontFamily:
                              'Poppins_Regular',
                              fontWeight:
                              FontWeight
                                  .bold),
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                        ),
                        padding:
                        EdgeInsets.all(2),
                      ),flex: 1,),
                      Expanded(child: Padding(
                        child: Text(
                          "Status",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                              fontSize: (MediaQuery.of(
                                  context)
                                  .orientation ==
                                  Orientation
                                      .portrait)
                                  ? (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 3
                                  : 6)
                                  : (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 6
                                  : 10),
                              color:
                              Colors.white,
                              fontFamily:
                              'Poppins_Regular',
                              fontWeight:
                              FontWeight
                                  .bold),
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                        ),
                        padding:
                        EdgeInsets.all(2),
                      ),flex: 1,),
                      Expanded(child: Padding(
                        child: Text(
                          "",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                              fontSize: (MediaQuery.of(
                                  context)
                                  .orientation ==
                                  Orientation
                                      .portrait)
                                  ? (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 3
                                  : 6)
                                  : (ResponsiveInfo
                                  .isMobileDimension(
                                  context)
                                  ? 6
                                  : 10),
                              color:
                              Colors.white,
                              fontFamily:
                              'Poppins_Regular',
                              fontWeight:
                              FontWeight
                                  .bold),
                          maxLines: 2,
                          overflow: TextOverflow
                              .ellipsis,
                        ),
                        padding:
                        EdgeInsets.all(2),
                      ),flex: 1,),


                    ],
                  ),
                ) ,
                alignment: FractionalOffset.topCenter,
              )


         ,

Align(
  alignment: FractionalOffset.topCenter,

  child: Padding(padding: EdgeInsets.fromLTRB(0, (MediaQuery.of(context).orientation ==
      Orientation.portrait)
      ? (ResponsiveInfo.isMobileDimension(context)
      ? 60
      : 70)
      : (ResponsiveInfo.isMobileDimension(context)
      ? 70
      : 80), 0, 0),

    child: ListView.builder(
        itemCount: orderController.orderDataList.length,
        shrinkWrap: true,
        primary: false,

        itemBuilder: (BuildContext context, int index) {

          OrderData orderData =orderController.orderDataList[index];
          return Padding(padding: EdgeInsets.all(

              (MediaQuery.of(
                  context)
                  .orientation ==
                  Orientation
                      .portrait)
                  ? (ResponsiveInfo
                  .isMobileDimension(
                  context)
                  ? 3
                  : 6)
                  : (ResponsiveInfo
                  .isMobileDimension(
                  context)
                  ? 6
                  : 10)



          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child:customerDetailsWidget(orderData.cart!.first,context),flex: 2, )
              ,
              Expanded(
                flex: 1,
                child: orderNumberWidget(orderData.cart!.first,context),
              ),
              Expanded(
                flex: 1,
                child: orderCreatedDateWidget(orderData.cart!.first,context),
              ),
              Expanded(
                flex: 1,
                child: orderPrice(orderData.cart!.first,context),
              ),
              Expanded(child: orderStatus(orderData.cart!.first,context),flex: 1)

              ,
              Expanded(child: viewOrder(orderData,context),flex: 1),

            ],
          ),

          )

            ;
        }),


  ) ,
)








              // Expanded(child: orderBottomTableWidget)
            ],
          ));
    });
  }

  Widget get _buildDataTableHeader => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: nkChildWrappedSizeBox(
          width: AppDimensions.instance!.width,
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
          width: AppDimensions.instance!.width,
          child: DataTable(
              headingRowHeight: 0.0,
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => primaryColor),
              headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                  color: buttonTextColor,
                  fontSize: NkFontSize.largeFont(),
                  fontWeight: FontWeight.bold),
              dataRowMaxHeight: 50,
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
  //   Expanded(child:customerDetailsWidget(orderData.cart!.first),flex: 2, )
  //       ,
  //       Expanded(
  // flex: 1,
  //         child: orderNumberWidget(orderData.cart!.first),
  //       ),
  //       Expanded(
  //       flex: 1,
  //         child: orderCreatedDateWidget(orderData.cart!.first),
  //       ),
  //       Expanded(
  //         flex: 1,
  //         child: orderPrice(orderData.cart!.first),
  //       ),
  //   Expanded(child: orderStatus(orderData.cart!.first,co),flex: 1)
  //
  //       ,
  // Expanded(child: viewOrder(orderData),flex: 1),
      ];

  Widget customerDetailsWidget(CustomerCart orderData,BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Row(children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRegularText(
                label: orderData.customerDetails?.fullname ?? '',
                fontSize: (MediaQuery.of(
                    context)
                    .orientation ==
                    Orientation
                        .portrait)
                    ? (ResponsiveInfo
                    .isMobileDimension(
                    context)
                    ? 3
                    : 6)
                    : (ResponsiveInfo
                    .isMobileDimension(
                    context)
                    ? 6
                    : 10),
              ),
              MyRegularText(
                label: orderData.customerDetails?.mobileno ?? '',
                fontSize: (MediaQuery.of(
                    context)
                    .orientation ==
                    Orientation
                        .portrait)
                    ? (ResponsiveInfo
                    .isMobileDimension(
                    context)
                    ? 3
                    : 6)
                    : (ResponsiveInfo
                    .isMobileDimension(
                    context)
                    ? 6
                    : 10),
              ),
              SizedBox(

                child: MyRegularText(
                  align: TextAlign.start,
                  label: orderData.customerDetails?.email ?? '',
                  fontSize: (MediaQuery.of(
                      context)
                      .orientation ==
                      Orientation
                          .portrait)
                      ? (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 3
                      : 6)
                      : (ResponsiveInfo
                      .isMobileDimension(
                      context)
                      ? 6
                      : 10),
                ),
              ),
            ])
      ]),
    );
  }

  Widget orderNumberWidget(CustomerCart orderData,BuildContext context) {
    return MyRegularText(
        label: orderData.optionOrderData?.orderId ?? '',
        fontWeight: FontWeight.w600,
    fontSize: (MediaQuery.of(
        context)
        .orientation ==
        Orientation
            .portrait)
        ? (ResponsiveInfo
        .isMobileDimension(
        context)
        ? 3
        : 6)
        : (ResponsiveInfo
        .isMobileDimension(
        context)
        ? 6
        : 10),

    );
  }

  Widget orderCreatedDateWidget(CustomerCart orderData,BuildContext context) {
    return MyRegularText(
        label: NKDateUtils.fullDayFormat(NKDateUtils.formatStringUTCDateTime(
            orderData.optionOrderData!.orderCreatAt!)),
        fontSize: (MediaQuery.of(
            context)
            .orientation ==
            Orientation
                .portrait)
            ? (ResponsiveInfo
            .isMobileDimension(
            context)
            ? 3
            : 6)
            : (ResponsiveInfo
            .isMobileDimension(
            context)
            ? 6
            : 10),

        fontWeight: FontWeight.w600);
  }

  Widget orderPrice(CustomerCart orderData,BuildContext context) {
    return MyRegularText(
      label: orderData.optionOrderData?.orderTotal
              .toString()
              .nkValueWithCurrencySymbol
              .removeAllWhitespace ??
          '',
      fontWeight: FontWeight.w600,
      fontSize: (MediaQuery.of(
          context)
          .orientation ==
          Orientation
              .portrait)
          ? (ResponsiveInfo
          .isMobileDimension(
          context)
          ? 3
          : 6)
          : (ResponsiveInfo
          .isMobileDimension(
          context)
          ? 6
          : 10),
    );
  }

  Widget orderStatus(CustomerCart orderData,BuildContext context ) {
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
        fontSize:  (MediaQuery.of(
          context)
          .orientation ==
          Orientation
              .portrait)
        ? (ResponsiveInfo
        .isMobileDimension(
        context)
        ? 3
        : 6)
        : (ResponsiveInfo
        .isMobileDimension(
        context)
        ? 6
        : 10),
      ),
    );
  }

  Widget viewOrder(OrderData orderData,BuildContext context) {
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
        child: SvgPicture.asset(Assets.iconsIcView,width:  (MediaQuery.of(
            context)
            .orientation ==
            Orientation
                .portrait)
        ? (ResponsiveInfo
        .isMobileDimension(
        context)
        ? 10
        : 13)
        : (ResponsiveInfo
        .isMobileDimension(
        context)
        ? 15
        : 18),
        height: (MediaQuery.of(
            context)
            .orientation ==
            Orientation
                .portrait)
            ? (ResponsiveInfo
            .isMobileDimension(
            context)
            ? 10
            : 13)
            : (ResponsiveInfo
            .isMobileDimension(
            context)
            ? 15
            : 18),


        ));
  }
}
