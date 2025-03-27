import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';

import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class StaffOrdersDialog extends StatefulWidget {
  final String heading;
  final List<OrderData> orderData;

  const StaffOrdersDialog({
    Key? key,
    required this.heading,
    required this.orderData,
  }) : super(key: key);

  @override
  State<StaffOrdersDialog> createState() => _StaffOrdersDialogState();
}

class _StaffOrdersDialogState extends State<StaffOrdersDialog> {
  final StaffController staffController = StaffController();

  RxList<String> orderTableColumCategory = [
    "Customer List",
    "Order Number",
    "Order Created",
    "Order Price",
    "Invoice",
    "Payment Status",
    "Status",
    "",
  ].obs;

  @override
  void initState() {
    staffController.loadOrderData;
    super.initState();
    if (widget.heading == 'bookings') {
      orderTableColumCategory.value = [
        "Customer List",
        "Order Number",
        "Order Created",
        "Order Price",
        "Status",
        "",
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: NkWidgetExceptionHandel(
          errorCustomWidgets: _buildErrorWidget(),
          data: widget.orderData.length,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.orderData.isNotEmpty
                    ? _buildDataTableHeader()
                    : nkChildWrappedSizeBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableHeader() {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: nkChildWrappedSizeBox(
            width: AppDimensions.instance!.width,
            child: DataTable(
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => primaryColor),
              headingRowHeight: 65,
              dataRowHeight: 65,
              columns: List.generate(
                  orderTableColumCategory.length,
                  (index) => index != orderTableColumCategory.length
                      ? DataColumn(
                          label: Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 30,
                                child: Center(
                                  child: MyRegularText(
                                    label: orderTableColumCategory[index],
                                    color: white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : DataColumn(
                          label: Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: dialogCloseButton1(context, red))))),
              rows: _generateRows(),
            ),
          ),
        ),
        Positioned(top: 0, right: 0, child: dialogCloseButton1(context, red))
      ],
    );
  }

  List<DataRow> _generateRows() {
    return widget.orderData.map(
      (order) {
        final cells = _buildOrderCells(order);
        return DataRow(
          cells: List.generate(cells.length, (index) => DataCell(cells[index])),
        );
      },
    ).toList();
  }

  List<Widget> _buildOrderCells(OrderData order) {
    final customerCart =
        order.cart?.isNotEmpty == true ? order.cart!.first : null;
    print(customerCart.toString());
    if (customerCart == null) {
      return List.generate(orderTableColumCategory.length,
          (index) => const SizedBox.shrink(child: Text('This data is NULL')));
    }
    return [
      _buildCustomerDetailsWidget(customerCart),
      _buildOrderNumberWidget(order),
      _buildOrderCreatedDateWidget(customerCart),
      _buildOrderPriceWidget(customerCart),
      if (widget.heading != 'bookings') ...[
        _buildOrderInvoiceWidget(order),
      ],
      if (widget.heading != 'bookings') ...[
        _buildPaymentStatusWidget(customerCart),
      ],
      _buildOrderStatusWidget(customerCart),
      const SizedBox.shrink(),
    ];
  }

  Widget _buildCustomerDetailsWidget(CustomerCart orderData) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        height: 60,
        width: AppDimensions.instance!.width * 0.20,
        child: Row(
          children: [
            ClipOval(
              child: MyNetworkImage(
                imageUrl: orderData.customerDetails?.imageUrl ?? '',
                height: 25,
                width: 25,
              ),
            ),
            nkSmallSizeBox(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyRegularText(
                    label: orderData.customerDetails?.fullname ?? '',
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    maxlines: 1,
                  ),
                  MyRegularText(
                    label: orderData.customerDetails?.mobileno ?? '',
                    fontSize: 9,
                    overflow: TextOverflow.ellipsis,
                    maxlines: 1,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: MyRegularText(
                      align: TextAlign.start,
                      label: orderData.customerDetails?.email ?? '',
                      fontSize: 9,
                      overflow: TextOverflow.ellipsis,
                      maxlines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNumberWidget(OrderData orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: InkWell(
          onTap: () {
            // _showDetailedOrderDialog(
            //     context, orderData.optionOrderData!.orderId, staffController);
            showDetailedOrderInvoiceDialog(context, orderData.orderId.toString(), false);
          },
          child: MyRegularText(
            label: orderData.orderId ?? '',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCreatedDateWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyRegularText(
              label: NKDateUtils.commonDayFormat2(
                NKDateUtils.formatStringUTCDateTime(
                    orderData.optionOrderData!.orderCreatAt!),
              ),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
            MyRegularText(
              label: NKDateUtils.commonTimeFormat(
                NKDateUtils.formatStringUTCDateTime(
                    orderData.optionOrderData!.orderCreatAt!),
              ),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderPriceWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50,
      child: Center(
        child: MyRegularText(
          label: formatAmount(orderData.optionOrderData?.orderTotal),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOrderInvoiceWidget(OrderData orderData) {
    String invoiceId = orderData.invoice?.isNotEmpty ?? false
        ? orderData.invoice![0].invoiceId ?? ''
        : '';

    return SizedBox(
      height: 50,
      child: Center(
        child: InkWell(
          onTap: () {
            showDetailedOrderInvoiceDialog(context, orderData.orderId.toString(), true);
          },
          child: MyRegularText(
            // label: orderData.optionOrderData!.invoice!.first.cartId.toString(),
            // label: orderData.optionOrderData?.invoice?[0].invoiceId ?? '',
            label: invoiceId,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50, // Set specific height for rows
      child: Center(
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          // padding: nkRegularPadding(),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDBB8),
            borderRadius: BorderRadius.circular(30),
            // color: OrderHandlingClass.fromType(orderData.optionOrderData!.orderStatus!).orderColor,
            // borderRadius: BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          ),
          child: Center(
            child: MyRegularText(
              label: OrderHandlingClass.fromType(
                      orderData.optionOrderData!.orderStatus!)
                  .name,
              fontSize: 10, // Body text size
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusWidget(CustomerCart orderData) {
    return SizedBox(
      height: 50, // Set specific height for rows
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: orderData.optionOrderData!.paymentStatus == 0
                ? Colors.red
                : Colors.green,
            shape: BoxShape.circle,
            border: Border.all(
              color: orderData.optionOrderData!.paymentStatus == 0
                  ? Colors.red
                  : Colors.green,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Icon(
              orderData.optionOrderData!.paymentStatus == 0
                  ? Icons.close
                  : Icons.done,
              color: Colors.white,
              size: 14.0,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildViewOrderWidget(OrderData orderData) {
  //   return Padding(
  //     padding: EdgeInsets.only(right: AppDimensions.instance!.width * 0.03),
  //     child: Center(
  //       child: InkResponse(
  //         onTap: () {
  //           Get.dialog(OrderDetailsDiloag(
  //             orderResponce: OptionOrderData.fromJson(orderData.toJson()),
  //           )).then((value) {
  //             if (value is bool) {
  //               staffController.loadOrderData;
  //             }
  //           });
  //         },
  //         child: SvgPicture.asset(Assets.iconsIcView),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildErrorWidget() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
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
            label: productNotAvailable,
            fontSize: NkFontSize.largeFont() + 5,
          ),
        ],
      ),
    );
  }
}