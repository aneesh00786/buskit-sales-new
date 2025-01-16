import 'dart:async';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (widget.orderController.orderDataList.isEmpty) {
          return const LoadingToNoDataWidget();
        }
        return NkWidgetExceptionHandel(
          onRetryPressed: () => {},
          data: widget.orderController.orderDataList,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  color: primaryColor,
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: CustomText(
                                content: 'Customer List',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: CustomText(
                                content: 'Order NO',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: CustomText(
                                content: 'Created',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: CustomText(
                                content: 'Order Price',
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins_Regular',
                                fontSize: 13,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: CustomText(
                                content: 'Status',
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 60,
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
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                if (widget.orderController.orderDataList == null) ...[
                  Text("Record not found"),
                ],
                if (widget.orderController.orderDataList != null) ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.orderController.orderDataList.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (BuildContext context, int index) {
                        OrderData orderData =
                            widget.orderController.orderDataList[index];
                        if (orderData.cart == null || orderData.cart!.isEmpty) {
                          return Container(
                            color:
                                index.isEven ? Colors.white : Colors.grey[50],
                            height: 60,
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: placeholderWidget()),
                                Expanded(flex: 1, child: placeholderWidget()),
                                Expanded(flex: 1, child: placeholderWidget()),
                                Expanded(flex: 1, child: placeholderWidget()),
                                Expanded(flex: 1, child: placeholderWidget()),
                                Expanded(flex: 1, child: placeholderWidget()),
                              ],
                            ),
                          );
                        }
                        return Container(
                          color: index.isEven ? Colors.white : Colors.grey[50],
                          height: MediaQuery.of(context).size.height / 11.5,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: customerDetailsWidget(
                                    orderData.cart!.first),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: orderNumberWidget(orderData.cart!.first),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: orderCreatedDateWidget(
                                    orderData.cart!.first),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: orderPrice(orderData.cart!.first),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: orderStatus(orderData.cart!.first),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                  width: 60,
                                  child: viewOrder(
                                      widget.orderController, orderData)),
                              SizedBox(width: 10),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget placeholderWidget() {
    return Center(
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
        SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 40,
          child: ClipOval(
            child: orderData.customerDetails?.imageUrl?.isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: orderData.customerDetails!.imageUrl.toString(),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyRegularText(
                  label: orderData.customerDetails?.fullname ?? 'Unknown',
                  maxlines: 2,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                MyRegularText(
                  label: orderData.customerDetails?.mobileno ?? 'Unknown',
                  maxlines: 2,
                  fontSize: 11,
                ),
                SizedBox(
                  child: MyRegularText(
                    align: TextAlign.start,
                    label: (orderData.customerDetails?.email ?? 'Unknown')
                                .length >
                            20
                        ? '${(orderData.customerDetails?.email ?? 'Unknown').substring(0, 15)}...'
                        : orderData.customerDetails?.email ?? 'Unknown',
                    maxlines: 2,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
        )
      ]),
    );
  }

  Widget orderNumberWidget(CustomerCart orderData) {
    return Center(
      child: MyRegularText(
        label: orderData.optionOrderData?.orderId ?? 'N/A',
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget orderCreatedDateWidget(CustomerCart orderData) {
    return Center(
      child: Column(
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
      ),
    );
  }

  Widget orderPrice(CustomerCart orderData) {
    return Center(
      child: MyRegularText(
        label: orderData.optionOrderData?.orderTotal != null
            ? formatAmount(orderData.optionOrderData!.orderTotal) ?? ''
            : 'N/A',
        fontWeight: FontWeight.w600,
        fontSize: 12,
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
        statusColor = const Color.fromARGB(255, 192, 226, 254);
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
            child: MyRegularText(
              label: orderData.optionOrderData?.orderStatus != null
                  ? OrderHandlingClass.fromType(
                          orderData.optionOrderData!.orderStatus!)
                      .name
                  : 'Unknown',
              fontSize: 11,
              align: TextAlign.center,
              fontWeight: FontWeight.w600,
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
          Get.dialog(
            Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );
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
                throw Exception('Data');
              }
            } catch (e) {
              Get.back();
              Get.snackbar('Error', e.toString());
            }
          }
        },
        icon: Icon(Icons.visibility, size: 16),
      ),
    );
  }
}
