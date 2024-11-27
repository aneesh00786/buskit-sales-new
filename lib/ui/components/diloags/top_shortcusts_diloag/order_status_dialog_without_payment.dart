import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/order_details_diloag/order_details_diloag.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../common/search_model.dart';

class OrderStatusDialogWithOutPayment extends StatefulWidget {
  final String heading;
  final OrderStatus? orderStatus;
  final UserType userType;
  final String userId;
  final String? customType;
  final bool? isVisible;
  final String? startDate;
  final String? endDate;

  const OrderStatusDialogWithOutPayment(
      {super.key,
      required this.heading,
      this.orderStatus,
      required this.userType,
      required this.userId,
      this.customType,
      this.isVisible = true,
      this.startDate,
      this.endDate});

  @override
  State<OrderStatusDialogWithOutPayment> createState() =>
      _OrderStatusDialogWithOutPaymentState();
}

class _OrderStatusDialogWithOutPaymentState
    extends State<OrderStatusDialogWithOutPayment> {
  final ApiWorker _apiWorker = ApiWorker();
  OptionOrderResponce _customerCartResponce = OptionOrderResponce();

  List<CustomerCart> customerCartList = [];

  SearchModel searchModel = SearchModel();

  RxList<String> orderTableColumCategory = [
    " Customer List",
    "Order Number",
    "Order created",
    "Order Price",
    "Status",
    "",
  ].obs;

  @override
  void initState() {
    searchModel.startDate = widget.startDate;
    searchModel.endDate = widget.endDate;
    onUserDetailsGet(widget.userType);
    super.initState();
  }

  void onUserDetailsGet(UserType userType) {
    if (userType == UserType.customer && widget.orderStatus != null) {
      _apiWorker
          .getAllOrderByStatus(
              orderType:
                  widget.customType ?? widget.orderStatus!.type.toString(),
              customerId: userType == UserType.customer ? widget.userId : null,
              searchModel: searchModel)
          .then((value) {
        value.data?.forEach((element) {
          element.cart?.forEach((element) {
            customerCartList.add(element);
          });
        });
        setState(() {
          _customerCartResponce = value;
          customerCartList;
        });
      });
    } else if (userType == UserType.salesman && widget.orderStatus != null) {
      _apiWorker
          .getAllOrderByStatus(
        orderType: widget.customType ?? widget.orderStatus!.type.toString(),
        salesmanId: userType == UserType.salesman ? widget.userId : null,
      )
          .then((value) {
        setState(() {
          _customerCartResponce = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, ore) {
      return SafeArea(
        minimum: nkSymmetricPadding(
            vertical: AppDimensions.instance!.height * 0.08,
            horizontal:
                AppDimensions.instance!.orientation == Orientation.landscape
                    ? AppDimensions.instance!.width * 0.10
                    : AppDimensions.instance!.width * 0.05),
        child: Card(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
            child: Scaffold(
              appBar: _customerCartResponce.data != null &&
                      _customerCartResponce.data!.isNotEmpty
                  ? null
                  : DiloagAppBar(
                      title: widget.heading,
                    ),
              body: NkWidgetExceptionHandel(
                  errorCustomWidgets: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        MyNetworkImage(
                          withoutBaseUrl: true,
                          imageUrl:
                              "https://i.ibb.co/r5kZLkw/bpnlauwze4-79c04e73-online-video-cutter-com-1-Adobe-Express.gif",
                          height: AppDimensions.instance!.height * 0.5,
                          width: AppDimensions.instance!.height * 0.5,
                        ),
                        MyRegularText(
                          align: TextAlign.center,
                          label: "productNotAvailable",
                          fontSize: NkFontSize.largeFont() + 5,
                        )
                      ],
                    ),
                  ),
                  data: _customerCartResponce.data,
                  child: Column(
                    children: [
                      _buildDataTableHeader(),
                      _customerCartResponce.data != null &&
                              _customerCartResponce.data!.isNotEmpty
                          ? Expanded(child: orderBottomTableWidget)
                          : nkChildWrappedSizeBox()
                    ],
                  )),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDataTableHeader() {
    return SingleChildScrollView(
      // scrollDirection: Axis.horizontal,
      child: nkChildWrappedSizeBox(
        width: AppDimensions.instance!.width,
        child: DataTable(
          horizontalMargin: AppDimensions.instance!.width * 0.03,
          headingRowColor:
              MaterialStateColor.resolveWith((states) => primaryColor),
          headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
              color: buttonTextColor,
              fontSize: NkFontSize.largeFont(),
              fontWeight: FontWeight.bold),
          dataRowMaxHeight: AppDimensions.instance!.height * 0.11,
          columns: List.generate(
              orderTableColumCategory.length,
              (index) => index != orderTableColumCategory.length - 1
                  ? DataColumn(
                      label: Flexible(
                      child: MyRegularText(
                        label: orderTableColumCategory[index],
                        color: buttonTextColor,
                        fontSize: NkFontSize.largeFont(),
                      ),
                    ))
                  : DataColumn(
                      label: DiloagAppBar(
                      title: widget.heading,
                    ).closeIcon)),
          rows: [],
        ),
      ),
    );
  }

  Widget get orderBottomTableWidget => SingleChildScrollView(
        child: nkChildWrappedSizeBox(
          width: AppDimensions.instance!.width,
          child: DataTable(
            headingRowHeight: 0,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => primaryColor),
            headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                color: buttonTextColor,
                fontSize: NkFontSize.largeFont(),
                fontWeight: FontWeight.bold),
            dataRowMaxHeight: AppDimensions.instance!.height * 0.11,
            columns: List.generate(
                orderTableColumCategory.length,
                (index) => DataColumn(
                        label: DiloagAppBar(
                      title: widget.heading,
                    ).closeIcon)),
            rows: genratedRows,
          ),
        ),
      );

  List<DataRow> get genratedRows => _customerCartResponce.data!
      .map((e) => DataRow(
            cells: List.generate(orderRowsWidget(e).length,
                (index) => DataCell(orderRowsWidget(e)[index])),
          ))
      .toList();

  List<Widget> orderRowsWidget(OptionOrderData orderData) => [
        customerDetailsWidget(orderData.cart!.first),
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: orderNumberWidget(orderData.cart!.first),
        ),
        orderCreatedDateWidget(orderData.cart!.first),
        orderPrice(orderData.cart!.first),
        orderStatus(orderData.cart!.first),
        viewOrder(orderData),
      ];

  Widget customerDetailsWidget(CustomerCart orderData) {
    return GestureDetector(
      onTap: () => {},
      child: SizedBox(
        width: AppDimensions.instance!.width * 0.12,
        child: Row(children: [
          ClipOval(
            child: MyNetworkImage(
              imageUrl: orderData.customerDetails?.imageUrl ?? '',
              height: AppDimensions.instance!.height * 0.06,
              width: AppDimensions.instance!.height * 0.06,
            ),
          ),
          nkSmallSizeBox(),
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
                  width: AppDimensions.instance!.width * 0.07,
                  child: MyRegularText(
                    align: TextAlign.start,
                    label: orderData.customerDetails?.email ?? '',
                  ),
                ),
              ])
        ]),
      ),
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
/*    return orderController.orderStatus(
        orderController.orderStatusToString(orderData.orderStatus!));*/
  }

  Widget viewOrder(OptionOrderData orderData) {
    return InkResponse(
        onTap: () {
          Get.dialog(OrderDetailsDiloag(
            orderResponce: orderData,
          )).then((value) {});
        },
        child: SvgPicture.asset(Assets.iconsIcView));
  }
}
