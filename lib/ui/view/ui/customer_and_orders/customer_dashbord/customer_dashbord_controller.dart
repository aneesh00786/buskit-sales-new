import 'dart:convert';
import 'dart:math';

import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_total_sale_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum PaymentStatus {
  paid,
  pending,
  unpaid,
}

class CustomerDashbordController extends GetxController {
  Rx<CustomerAndOrderData> customerAndOrderData = CustomerAndOrderData().obs;

  RxInt selectedPaymentCollectIndex = (-1).obs;

  TextEditingController paymentDetailsController = TextEditingController();
  GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();

  RxList<String> recentordersHeadingList = [
    "Orders & Payments",
    "Value",
    "Invoice No.",
    "Status",
    "Payment",
    "Collect"
  ].obs;

  Rx<Data> customerDashboardData = Data().obs;
  Rx<CustomerDashboardTotalSaleData> customerDashboardTotalSaleData =
      CustomerDashboardTotalSaleData().obs;
  RxInt selectYearIndex = 0.obs;

  RxList<String> paymentOption = ["Cash", "Cheque", "Bank Transfer"].obs;

  RxList<Map<String, dynamic>> recentOrderData = [
    {
      'Recent Orders': NKDateUtils.apiDayFormat(DateTime.now()),
      'Value': Random().nextInt(1000).toString(),
      'Invoice No.': 'INV122',
      'Status': Random().nextInt(4).toString(),
      'Payment': Random().nextInt(4).toString(),
      'Collect': false,
    },
    {
      'Recent Orders': NKDateUtils.apiDayFormat(DateTime.now()),
      'Value': Random().nextInt(1000).toString(),
      'Invoice No.': 'INV126',
      'Status': Random().nextInt(4).toString(),
      'Payment': Random().nextInt(4).toString(),
      'Collect': false,
    },
    {
      'Recent Orders': NKDateUtils.apiDayFormat(DateTime.now()),
      'Value': Random().nextInt(1000).toString(),
      'Invoice No.': 'INV13',
      'Status': Random().nextInt(4).toString(),
      'Payment': Random().nextInt(4).toString(),
      'Collect': true,
    },
    {
      'Recent Orders': NKDateUtils.apiDayFormat(DateTime.now()),
      'Value': Random().nextInt(1000).toString(),
      'Invoice No.': 'INV129',
      'Status': Random().nextInt(4).toString(),
      'Payment': Random().nextInt(4).toString(),
      'Collect': true,
    },
    {
      'Recent Orders': NKDateUtils.apiDayFormat(DateTime.now()),
      'Value': Random().nextInt(1000).toString(),
      'Invoice No.': 'INV127',
      'Status': Random().nextInt(4).toString(),
      'Payment': Random().nextInt(4).toString(),
      'Collect': false,
    },
  ].obs;
  Map<String, dynamic> purchaseProductSendData(
      List<Map<String, dynamic>> data) {
    return {
      "customer_id": customerAndOrderData.value.customerId,
      "product_id": SessionHelper.loginSavedData?.salesmanId?.toString(),
      "payment_status": "pending",
      "order_status": "pending",
      "order_list": data.map((e) => jsonEncode(e)).toList()
    };
  }

  PaymentStatus convertIntTypeToPaymentStatus(int value) {
    switch (value) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.paid;
      case 2:
        return PaymentStatus.unpaid;
      default:
        return PaymentStatus.pending;
    }
  }

  Widget checkBoxWidget(bool value, {void Function(bool?)? onChanged}) {
    return Checkbox.adaptive(
      value: value,
      onChanged: onChanged,
    );
  }

  updateWidget() {
    refresh();
  }

  Widget paymentStatusWidget(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Container(
          decoration:
              const ShapeDecoration(shape: OvalBorder(), color: switchColor),
          child: Icon(
            Icons.check,
            color: secondaryIconColor,
            size: NkGeneralSize.nkIconSize() - 10,
          ),
        );
      case PaymentStatus.unpaid:
        return Container(
          decoration:
              const ShapeDecoration(shape: OvalBorder(), color: errorColor),
          child: Icon(
            Icons.close,
            color: secondaryIconColor,
            size: NkGeneralSize.nkIconSize() - 10,
          ),
        );

      default:
        return Container(
          decoration:
              const ShapeDecoration(shape: OvalBorder(), color: errorColor),
          child: Icon(
            Icons.close,
            color: secondaryIconColor,
            size: NkGeneralSize.nkIconSize() - 10,
          ),
        );
    }
  }

  List<CartesianSeries<dynamic, dynamic>> getCustomerDashbordData(
      List<CategoryPerformance> categoryData) {
  
    return [
      for (var item in categoryData) ...[
        StackedLine100Series<Month, String>(
            dataSource: item.month,
            xValueMapper: (Month sales, number) => NKDateUtils.months[number],
            yValueMapper: (Month sales, number) => sales.totalCount,
            name: item.category,
            markerSettings: const MarkerSettings(isVisible: true))
      ]
    ];
  }
}
