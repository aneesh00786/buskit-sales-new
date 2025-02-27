import 'dart:async';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_invoice.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';

class OrderBottomWidget extends StatefulWidget {
  final OrderController orderController;
  final int selectedTabIndex;

  const OrderBottomWidget({
    super.key,
    required this.orderController,
    required this.selectedTabIndex,
  });

  @override
  State<OrderBottomWidget> createState() => _OrderBottomWidgetState();
}

class _OrderBottomWidgetState extends State<OrderBottomWidget> {
  Timer? _debounce;
  @override
  void didUpdateWidget(covariant OrderBottomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTabIndex != widget.selectedTabIndex) {
      _debounce?.cancel();
      _debounce = Timer(Duration(milliseconds: 300), () {
        widget.orderController
            .loadOrderData(selectedIndex: widget.selectedTabIndex);
        widget.orderController.loadOrderCountData();
      });
    }
  }

  String get option {
    switch (widget.selectedTabIndex) {
      case 0:
        return 'Recieved';
      case 1:
        return 'Waiting';
      case 2:
        return 'Quick Sale';
      case 3:
        return 'Processing';
      case 4:
        return 'Packed & ready for delivery';
      case 5:
        return 'Delivered';
      case 6:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (widget.orderController.isOrderLoading.value) {
          return const Center(child: Text('LOADING'));
        }
        if (widget.orderController.orderDataList.isEmpty) {
          return const Center(child: Text('Record Not Found'));
        }

        return NkWidgetExceptionHandel(
          onRetryPressed: () => {},
          data: widget.orderController.orderDataList,
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      color: primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: CustomText(
                                    content: 'SI No.',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 8,
                              child: Center(
                                child: CustomText(
                                    content: '$option List',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                    if (widget.orderController.orderDataList != null) ...[
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          itemCount:
                              widget.orderController.orderDataList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            OrderData orderData =
                                widget.orderController.orderDataList[index];
                            if (orderData.cart == null ||
                                orderData.cart!.isEmpty) {
                              return Container(
                                color: index.isEven
                                    ? Colors.white
                                    : Colors.grey[50],
                                height: (fullScreenHeight(context) - 242) / 10,
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2, child: placeholderWidget()),
                                    Expanded(
                                        flex: 8, child: placeholderWidget()),
                                  ],
                                ),
                              );
                            }
                            return Container(
                              color:
                                  index.isEven ? Colors.white : Colors.grey[50],
                              height: (fullScreenHeight(context) - 242) / 10,
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: CustomText(
                                        content:
                                            '${((widget.orderController.currentPage.value - 1) * 10) + (index + 1)}.',
                                        maxLine: 1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 8,
                                    child: customerDetailsWidget(
                                        orderData.cart!.first),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        height: 50,
                        color: Colors.grey[200],
                        child: Row(
                          children: [OrderPaginationWidget(), const Spacer()],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 50,
                          color: primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.selectedTabIndex == 0) ...[
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Order NO',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Created',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Created By',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 5,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Order Amount',
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins_Regular',
                                          fontSize: 12,
                                          textAlign: TextAlign.center,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Payment Status',
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Status',
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        ' ',
                                        style: TextStyle(
                                            fontFamily: 'Poppins_Regular',
                                            fontStyle: FontStyle.normal,
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                if (widget.selectedTabIndex != 0) ...[
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Order Details',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Process Date',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Order Amount',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Payment Status',
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 4,
                                    child: Center(
                                      child: CustomText(
                                          content: 'Status',
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        ' ',
                                        style: TextStyle(
                                            fontFamily: 'Poppins_Regular',
                                            fontStyle: FontStyle.normal,
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (widget.orderController.orderDataList == null) ...[
                          const Text("Record not found"),
                        ],
                        if (widget.orderController.orderDataList != null) ...[
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: ClampingScrollPhysics(),
                              itemCount:
                                  widget.orderController.orderDataList.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                OrderData orderData =
                                    widget.orderController.orderDataList[index];
                                if (orderData.cart == null ||
                                    orderData.cart!.isEmpty) {
                                  return Container(
                                    color: index.isEven
                                        ? Colors.white
                                        : Colors.grey[50],
                                    height:
                                        (fullScreenHeight(context) - 242) / 10,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: placeholderWidget()),
                                        Expanded(
                                            flex: 4,
                                            child: placeholderWidget()),
                                        Expanded(
                                            flex: 4,
                                            child: placeholderWidget()),
                                        Expanded(
                                            flex: 5,
                                            child: placeholderWidget()),
                                        Expanded(
                                            flex: 4,
                                            child: placeholderWidget()),
                                        Expanded(
                                            flex: 2,
                                            child: placeholderWidget()),
                                      ],
                                    ),
                                  );
                                }
                                return Container(
                                  color: index.isEven
                                      ? Colors.white
                                      : Colors.grey[50],
                                  height:
                                      (fullScreenHeight(context) - 242) / 10,
                                  child: Row(
                                    children: [
                                      if (widget.selectedTabIndex == 0) ...[
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: orderNumberWidget(
                                              orderData.cart!.first, orderData),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: orderCreatedDateWidget(
                                              orderData.cart!.first, orderData),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child:
                                              orderCreatedByWidget(orderData),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 5,
                                          child:
                                              orderPrice(orderData.cart!.first),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: paymentStatus(
                                              orderData.cart!.first),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: orderStatus(
                                              orderData.cart!.first),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: viewOrder(
                                                widget.orderController,
                                                orderData)),
                                        const SizedBox(width: 5),
                                      ],

                                      // if not received

                                      if (widget.selectedTabIndex != 0) ...[
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: orderNumberWidget(
                                              orderData.cart!.first, orderData),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: orderCreatedDateWidget(
                                              orderData.cart!.first, orderData),
                                        ),
                                        const SizedBox(width: 5),
                                        // Expanded(
                                        //   flex: 4,
                                        //   child:
                                        //       orderCreatedByWidget(orderData),
                                        // ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child:
                                              orderPrice(orderData.cart!.first),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: paymentStatus(
                                              orderData.cart!.first),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 4,
                                          child: orderStatus(
                                              orderData.cart!.first),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: viewOrder(
                                                widget.orderController,
                                                orderData)),
                                        const SizedBox(width: 5),
                                      ]
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            height: 50,
                            color: Colors.grey[200],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget placeholderWidget() {
    return const Center(
      child: MyRegularText(
        label: 'N/A',
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    );
  }

  Widget customerDetailsWidget(CustomerCart orderData) {
    return GestureDetector(
      onTap: () => {},
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(width: 8),
        ClipOval(
          child: Container(
            height: 34,
            width: 34,
            color: Colors.grey[200],
            child: Image.network(
              'http://16.50.232.153:3000/uploads/${orderData.customerDetails!.imageUrl}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 30,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  content: orderData.customerDetails?.businessName ?? 'Unknown',
                  maxLine: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  content: orderData.customerDetails?.mobileno ?? 'Unknown',
                  maxLine: 2,
                  fontSize: 10,
                ),
                MyRegularText(
                  align: TextAlign.start,
                  label: orderData.customerDetails?.email ?? 'Unknown',
                  maxlines: 1,
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
        )
      ]),
    );
  }

  Widget orderNumberWidget(CustomerCart orderData, OrderData orderDetailsData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyRegularText(
            label: orderData.optionOrderData?.orderId ?? 'N/A',
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          if (widget.selectedTabIndex != 0) ...[
            SizedBox(height: 5),
            MyRegularText(
              label:
                  "${orderData.optionOrderData?.generatedDate != null ? NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(orderData.optionOrderData!.generatedDate!)) : 'N/A'} ${orderData.optionOrderData?.generatedDate != null ? NKDateUtils.commonTimeFormat(NKDateUtils.formatStringUTCDateTime(orderData.optionOrderData!.generatedDate!)) : 'N/A'}",
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            MyRegularText(
              label:
                  '${orderDetailsData.fullname} ${orderDetailsData.lastname}',
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ]
        ],
      ),
    );
  }

  Widget orderCreatedDateWidget(
      CustomerCart orderData, OrderData orderDetailsData) {
    return Center(
      child: widget.selectedTabIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyRegularText(
                  label: orderData.optionOrderData?.orderCreatAt != null
                      ? NKDateUtils.commonDayFormat2(
                          NKDateUtils.formatStringUTCDateTime(
                              orderData.optionOrderData!.orderCreatAt!))
                      : 'N/A',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                MyRegularText(
                  label: orderData.optionOrderData?.orderCreatAt != null
                      ? NKDateUtils.commonTimeFormat(
                          NKDateUtils.formatStringUTCDateTime(
                              orderData.optionOrderData!.orderCreatAt!))
                      : 'N/A',
                  fontSize: 12,
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyRegularText(
                  label:
                      "${orderData.optionOrderData?.orderCreatAt != null ? NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(orderData.optionOrderData!.orderCreatAt!)) : 'N/A'} ${orderData.optionOrderData?.orderCreatAt != null ? NKDateUtils.commonTimeFormat(NKDateUtils.formatStringUTCDateTime(orderData.optionOrderData!.orderCreatAt!)) : 'N/A'}",
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                if (widget.selectedTabIndex != 0) ...[
                  MyRegularText(
                    label:
                        '${orderDetailsData.editedFullname} ${orderDetailsData.editedLastname}',
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ]
              ],
            ),
    );
  }

  Widget orderCreatedByWidget(OrderData orderData) {
    return Center(
      child: MyRegularText(
        label: '${orderData.fullname} ${orderData.lastname}',
        fontWeight: FontWeight.w600,
        fontSize: 11,
        maxlines: 2,
      ),
    );
  }

  Widget orderPrice(CustomerCart orderData) {
    return Center(
      child: MyRegularText(
        label: orderData.optionOrderData?.orderTotal != null
            ? formatAmount(orderData.optionOrderData!.orderTotal)
            : 'N/A',
        fontWeight: FontWeight.w600,
        fontSize: 11,
        maxlines: 1,
      ),
    );
  }

  Widget paymentStatus(CustomerCart orderData) {
    Color statusColor;
    switch (orderData.optionOrderData?.paymentStatus) {
      case 0:
        statusColor = Colors.red;
        break;
      case 1:
        statusColor = Colors.green;
        break;
      case 3:
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Center(
      child: CircleAvatar(
        backgroundColor: statusColor,
        radius: 12,
        child: Icon(
          orderData.optionOrderData?.paymentStatus == 0
              ? Icons.close
              : Icons.check,
          size: 20,
          color: white,
        ),
      ),
    );
  }

  Widget orderStatus(CustomerCart orderData) {
    Color statusColor;
    switch (orderData.optionOrderData?.orderStatus) {
      case 11:
        statusColor = const Color.fromARGB(255, 225, 250, 191);
        break;
      case 12:
        statusColor = const Color.fromARGB(255, 255, 222, 168);
        break;
      case 14:
        // statusColor = const Color.fromARGB(255, 192, 226, 254);
        statusColor = const Color.fromARGB(255, 190, 253, 247);
        break;
      case 5:
        statusColor = const Color.fromARGB(255, 190, 253, 247);
        break;
      case 1:
        statusColor = const Color.fromARGB(255, 245, 195, 254);
        break;
      case 2:
        statusColor = const Color.fromARGB(255, 222, 199, 246);
        break;
      case 13:
        statusColor = const Color.fromARGB(255, 246, 199, 199);
        break;
      default:
        statusColor = Colors.grey;
    }

    return
        // orderData.optionOrderData?.orderStatus == 2
        //     ? Center(
        //         child: Padding(
        //           padding: const EdgeInsets.all(0.0),
        //           child: IntrinsicHeight(
        //             child: Container(
        //               padding: const EdgeInsets.all(5.0),
        //               decoration: BoxDecoration(
        //                 color: statusColor,
        //                 borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        //               ),
        //               child: Center(
        //                 child: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [
        //                     CustomText(
        //                       content: orderData.optionOrderData?.orderStatus !=
        //                               null
        //                           ? OrderHandlingClass.fromType(
        //                                   orderData.optionOrderData!.orderStatus!)
        //                               .name
        //                           : 'Unknown',
        //                       fontSize: 11.0,
        //                       fontWeight: FontWeight.w600,
        //                     ),
        //                     if (orderData.optionOrderData!.orderStatus == 2 &&
        //                         orderData.optionOrderData!.deliveryDatetime !=
        //                             null) ...[
        //                       const SizedBox(height: 3),
        //                       CustomText(
        //                         content: NKDateUtils.commonFullDateTimeFormat(
        //                             NKDateUtils.formatStringUTCDateTime(orderData
        //                                 .optionOrderData!.deliveryDatetime
        //                                 .toString())),
        //                         textAlign: TextAlign.center,
        //                         maxLine: 2,
        //                         fontSize: 9,
        //                         fontWeight: FontWeight.w400,
        //                       ),
        //                     ]
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       )
        //     :
        orderData.optionOrderData?.orderStatus == 14
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: IntrinsicHeight(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              content:
                                  orderData.optionOrderData?.orderStatus != null
                                      ? OrderHandlingClass.fromType(orderData
                                              .optionOrderData!.orderStatus!)
                                          .name
                                      : 'Unknown',
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                            ),
                            if (orderData.optionOrderData?.orderStatus ==
                                14) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                        color: Colors.blue,
                                        child: const Center(
                                          child: Text(
                                            'Quick Sale',
                                            style: TextStyle(
                                                color: white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                          ),
                                        )),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: orderData.optionOrderData?.orderStatus != null
                            ? statusColor
                            : Colors.grey,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Center(
                        child: CustomText(
                          content: orderData.optionOrderData?.orderStatus !=
                                  null
                              ? OrderHandlingClass.fromType(
                                      orderData.optionOrderData!.orderStatus!)
                                  .name
                              : 'Unknown',
                          fontSize: 11,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  Widget viewOrder(OrderController orderController, OrderData orderData) {
    return Center(
      child: IconButton(
        onPressed: () async {
          if (orderController.selectedTabIndex.value == 0) {
            try {
              await orderController.loadSpecificOrderInvoiceData(
                orderId: orderData.orderId!,
              );
              Get.back();
              if (orderController.orderProcessInvoiceData != null) {
                Get.dialog(
                  OrderProcessInvoiceDialog(
                    specificData: orderController.fetchSpecificOrderData,
                    selectedTabIndex: orderController.selectedTabIndex.value,
                    orderController: orderController,
                  ),
                  barrierDismissible: true,
                );
              } else {
                throw Exception('No invoice data available');
              }
            } catch (e) {
              Get.back();
              Get.snackbar('Error', e.toString());
            }
          } else if (orderController.selectedTabIndex.value == 1) {
            try {
              await orderController.loadOrderApprovalInvoiceData(
                orderId: orderData.orderId!,
              );
              Get.back();
              if (orderController.orderProcessInvoiceData != null) {
                Get.dialog(
                  OrderProcessInvoiceDialog(
                    invoiceData: orderController.orderProcessInvoiceData,
                    selectedTabIndex: orderController.selectedTabIndex.value,
                    orderController: orderController,
                  ),
                  barrierDismissible: true,
                );
              } else {
                throw Exception('No invoice data available');
              }
            } catch (e) {
              Get.back();
              Get.snackbar('Error', e.toString());
            }
          } else if (orderController.selectedTabIndex >= 1) {
            try {
              await orderController.loadOrderProcessInvoiceData(
                orderId: orderData.orderId!,
                orderStatus: orderData.orderStatus!,
              );
              Get.back();
              if (orderController.orderProcessInvoiceData != null) {
                Get.dialog(
                  OrderProcessInvoiceDialog(
                    invoiceData: orderController.orderProcessInvoiceData,
                    selectedTabIndex: orderController.selectedTabIndex.value,
                    orderController: orderController,
                  ),
                  barrierDismissible: true,
                );
              } else {
                throw Exception('No invoice data available');
              }
            } catch (e) {
              Get.back();
              Get.snackbar('Error', e.toString());
            }
          }
        },
        icon: const Icon(Icons.visibility, size: 16),
      ),
    );
  }
}
