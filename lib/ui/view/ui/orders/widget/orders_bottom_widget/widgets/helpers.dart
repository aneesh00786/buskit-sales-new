import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_invoice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            '${ApiConstants.baseUrl}uploads/${orderData.customerDetails!.imageUrl}',
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

Widget orderNumberWidget(
    CustomerCart orderData, OrderData orderDetailsData, int selectedTabIndex) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyRegularText(
          label: orderData.optionOrderData?.orderId ?? 'N/A',
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        if (selectedTabIndex != 0) ...[
          const SizedBox(height: 5),
          MyRegularText(
            label: orderDetailsData.generatedDate != null
                ? "${NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(orderDetailsData.generatedDate ?? ''))} ${NKDateUtils.commonTimeOnlyFormat(NKDateUtils.formatStringUTCDateTime(orderDetailsData.generatedDate ?? ''))}"
                : "N/A",
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          MyRegularText(
            label: '${orderDetailsData.fullname} ${orderDetailsData.lastname}',
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ]
      ],
    ),
  );
}

Widget orderCreatedDateWidget(
    CustomerCart orderData, OrderData orderDetailsData, int selectedTabIndex) {
  return Center(
    child: selectedTabIndex == 0
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
                    ? NKDateUtils.commonTimeOnlyFormat(
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
                    "${orderData.optionOrderData?.orderCreatAt != null ? NKDateUtils.commonDayFormat2(NKDateUtils.formatStringUTCDateTime(orderData.optionOrderData!.orderCreatAt!)) : 'N/A'} ${orderData.optionOrderData?.orderCreatAt != null ? NKDateUtils.commonTimeOnlyFormat(NKDateUtils.formatStringUTCDateTime(orderData.optionOrderData!.orderCreatAt!)) : 'N/A'}",
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              if (selectedTabIndex != 0) ...[
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

  return orderData.optionOrderData?.orderStatus == 14
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: IntrinsicHeight(
              child: Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        content: orderData.optionOrderData?.orderStatus != null
                            ? OrderHandlingClass.fromType(
                                    orderData.optionOrderData!.orderStatus!)
                                .name
                            : 'Unknown',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                      if (orderData.optionOrderData?.orderStatus == 14) ...[
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
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Center(
                  child: CustomText(
                    content: orderData.optionOrderData?.orderStatus != null
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

Widget viewOrder(OrderController orderController, OrderData orderData,
    BuildContext context) {
  int selectedTabIndex = orderController.hasOfflineOrders.value
      ? orderController.selectedTabIndex.value - 1
      : orderController.selectedTabIndex.value;
  return Center(
    child: IconButton(
      onPressed: () async {
        log('Order ID :${orderData.orderId ?? ''}');
        log('Selected Tab Index :${selectedTabIndex}');
        if (selectedTabIndex == 0) {
          try {
            await orderController.loadOrderProcessInvoiceData(
              orderId: orderData.orderId!,
              orderStatus: orderData.orderStatus!,
            );
            Get.back();
            // ignore: unnecessary_null_comparison
            if (orderController.orderProcessInvoiceData != null) {
              Get.dialog(
                OrderProcessInvoiceDialog(
                  invoiceData: orderController.orderProcessInvoiceData,
                  selectedTabIndex: selectedTabIndex,
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
        } else if (selectedTabIndex >= 1 &&
            selectedTabIndex != 4 &&
            selectedTabIndex != 5) {
          try {
            await orderController.loadOrderProcessInvoiceData(
              orderId: orderData.orderId!,
              orderStatus: orderData.orderStatus!,
            );
            Get.back();
            // ignore: unnecessary_null_comparison
            if (orderController.orderProcessInvoiceData != null) {
              Get.dialog(
                OrderProcessInvoiceDialog(
                  invoiceData: orderController.orderProcessInvoiceData,
                  selectedTabIndex: selectedTabIndex,
                  orderController: orderController,
                ),
                barrierDismissible: true,
              );
            } else {
              throw Exception('No invoice data available');
            }
          } catch (e) {
            Get.back();
            // Get.snackbar('Error', e.toString());
          }
        } else if (selectedTabIndex == 4 || selectedTabIndex == 5) {
          showDialog(
            context: context,
            builder: (context) {
              return InvoicePreview(
                orderId: orderData.orderId ?? '',
              );
            },
          );
        }
      },
      icon: const Icon(Icons.visibility, size: 16),
    ),
  );
}
