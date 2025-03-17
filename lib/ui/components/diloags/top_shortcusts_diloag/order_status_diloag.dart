import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
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
import 'package:busskit_salesexecutive/ui/theme/get_theme.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderStatusDiloag extends StatefulWidget {
  final String heading;
  final OrderStatus? orderStatus;
  final UserType userType;
  final String userId;
  final String? startDate;
  final String? endDate;
  final String? customType;
  final bool? isVisible;

  const OrderStatusDiloag(
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
  State<OrderStatusDiloag> createState() => _OrderStatusDiloagState();
}

class _OrderStatusDiloagState extends State<OrderStatusDiloag> {
  final ApiWorker _apiWorker = ApiWorker();
  OptionOrderResponce _customerCartResponce = OptionOrderResponce();

  List<CustomerCart> customerCartList = [];
  SearchModel searchModel = SearchModel();
  double fixedIconSize = 13.0;
  RxList<String> orderTableColumCategory = [
    "Customer List",
    "Order Number",
    "Order created",
    "Order Price",
    "Payment Status",
    "Status",
    "",
  ].obs;

  @override
  void initState() {
    searchModel.startDate = widget.startDate;
    searchModel.endDate = widget.endDate;
    log("Sel date ${searchModel.startDate} ${searchModel.endDate}");
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
              orderType:
                  widget.customType ?? widget.orderStatus!.type.toString(),
              salesmanId: userType == UserType.salesman ? widget.userId : null,
              searchModel: searchModel)
          .then((value) {
        setState(() {
          _customerCartResponce = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_customerCartResponce.data == null ||
                  _customerCartResponce.data!.isEmpty)
                DiloagAppBar(title: widget.heading),
              NkWidgetExceptionHandel(
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
                        height: AppDimensions.instance.height * 0.3,
                        width: AppDimensions.instance.width * 0.3,
                      ),
                      MyRegularText(
                        align: TextAlign.center,
                        label: productNotAvailable,
                        fontSize: NkFontSize.largeFont() + 5,
                      ),
                    ],
                  ),
                ),
                data: _customerCartResponce.data,
                child: Column(
                  children: [
                    _buildDataTableHeader(),
                    _customerCartResponce.data != null &&
                            _customerCartResponce.data!.isNotEmpty
                        ? SizedBox(
                            height: AppDimensions.instance.height * 0.5,
                            child: orderBottomTableWidget,
                          )
                        : nkChildWrappedSizeBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableHeader() {
    return SingleChildScrollView(
      child: nkChildWrappedSizeBox(
        width: AppDimensions.instance.width,
        child: Theme(
          data: NkGetXTheme.lightTheme,
          child: DataTable(
            horizontalMargin: 22,
            headingRowColor:
                WidgetStateColor.resolveWith((states) => primaryColor),
            headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                color: buttonTextColor,
                fontSize: NkFontSize.largeFont(),
                fontWeight: FontWeight.bold),
            columnSpacing: AppDimensions.instance.width * 0.04,
            dataRowMaxHeight: AppDimensions.instance.height * 0.11,
            columns: List.generate(
                orderTableColumCategory.length,
                (index) => index != orderTableColumCategory.length - 1
                    ? DataColumn(
                        label: Flexible(
                        child: MyRegularText(
                          label: orderTableColumCategory[index],
                          color: buttonTextColor,
                          fontSize: NkFontSize.largeFont(largeFont: 13),
                        ),
                      ))
                    : DataColumn(
                        label: DiloagAppBar(
                        title: widget.heading,
                      ).closeIcon)),
            rows: const [],
          ),
        ),
      ),
    );
  }

  Widget get orderBottomTableWidget => SingleChildScrollView(
        child: nkChildWrappedSizeBox(
          width: AppDimensions.instance.width,
          child: Theme(
            data: NkGetXTheme.lightTheme,
            child: DataTable(
              headingRowHeight: 0,
              headingRowColor:
                  WidgetStateColor.resolveWith((states) => primaryColor),
              headingTextStyle: Get.theme.textTheme.bodyMedium?.copyWith(
                  color: buttonTextColor,
                  fontSize: NkFontSize.largeFont(),
                  fontWeight: FontWeight.bold),
              dataRowMaxHeight: AppDimensions.instance.height * 0.11,
              columnSpacing: AppDimensions.instance.width * 0.03,
              columns: List.generate(
                  orderTableColumCategory.length,
                  (index) => DataColumn(
                          label: DiloagAppBar(
                        title: widget.heading,
                      ).closeIcon)),
              rows: genratedRows,
            ),
          ),
        ),
      );

  List<DataRow> get genratedRows => _customerCartResponce.data!
      .map((e) => DataRow(
            cells: List.generate(orderRowsWidget(e).length,
                (index) => DataCell(orderRowsWidget(e)[index])),
          ))
      .toList();

  List<Widget> orderRowsWidget(OptionOrderData orderData) {
    if (orderData.cart == null || orderData.cart!.isEmpty) {
      return [
        const Text('No Data'),
        const Text('No Data'),
        const Text('No Data'),
        const Text('No Data'),
        const Text('No Data'),
        const Text('No Data'),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {},
        ),
      ];
    }

    final cartItem = orderData.cart!.first;
    return [
      Theme(
        data: NkGetXTheme.lightTheme,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xffe6ecff),
              child: Icon(
                Icons.person,
                size: fixedIconSize,
                color: Colors.blue,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cartItem.customerDetails?.fullname ?? 'N/A'),
                Text(cartItem.customerDetails?.mobileno ?? 'N/A'),
                Text(cartItem.customerDetails?.address ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
      Text(cartItem.optionOrderData?.orderId ?? 'N/A'),
      Text(formatDate(cartItem.createdAt)),
      Text('${cartItem.optionOrderData?.orderTotal ?? 'N/A'}'),
      NkCommonFunction.isPaymentComplete(
              cartItem.optionOrderData?.paymentStatus ?? 0)
          .$1,
      Text('${cartItem.pieces ?? 'N/A'}'),
      Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 31,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffffdbb8),
              borderRadius: BorderRadius.circular(4.6),
            ),
            //                                         child:
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text('Delivered'),
            ),
          ),
        ),
      )
    ];
  }

  Widget customerDetailsWidget(CustomerCart orderData) {
    return GestureDetector(
      onTap: () => {},
      child: Row(children: [
        Theme(
          data: NkGetXTheme.lightTheme,
          child: Column(
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
              ]),
        )
      ]),
    );
  }

  Widget orderNumberWidget(CustomerCart orderData) {
    return MyRegularText(
        label: orderData.optionOrderData?.orderId ?? '',
        fontWeight: FontWeight.w600);
  }

  Widget orderCreatedDateWidget(CustomerCart orderData) {
    return Padding(
      padding: const EdgeInsets.only(right: 68.0, left: 30.0),
      child: MyRegularText(
          label: NKDateUtils.fullDayFormat(NKDateUtils.formatStringUTCDateTime(
              orderData.optionOrderData!.orderCreatAt!)),
          fontWeight: FontWeight.w600),
    );
  }

  Widget orderPrice(CustomerCart orderData) {
    return Padding(
      padding: const EdgeInsets.only(right: 88.0),
      child: MyRegularText(
        label: orderData.optionOrderData?.orderTotal
                .toString()
                .nkValueWithCurrencySymbol
                .removeAllWhitespace ??
            '',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null) {
      return 'N/A';
    }
    DateTime? dateTime = DateTime.tryParse(dateString);
    if (dateTime == null) {
      return 'Invalid Date';
    }
    return DateFormat('yyyy-MM-dd').format(dateTime);
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

///////dropdown/////////changes/////
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
