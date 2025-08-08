import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:flutter/material.dart';

class OptionOrderResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<OptionOrderData>? data;

  OptionOrderResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  OptionOrderResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map(
            (dynamic e) => OptionOrderData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.map((e) => e.toJson()).toList();
    return json;
  }
}

class OptionOrderData {
  int? id;
  String? orderId;
  String? customerId;
  String? salesmanId;
  int? paymentStatus;
  int? orderStatus;
  String? cartId;
  String? orderCreatAt;
  String? generatedDate;
  String? deliveryDatetime;
  num? orderTotal;
  List<CustomerCart>? cart;
  List<CustomerDetails>? customer;
  List<OrderInvoice>? invoice;

  OptionOrderData({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
    this.paymentStatus,
    this.orderStatus,
    this.cartId,
    this.orderCreatAt,
    this.generatedDate,
    this.deliveryDatetime,
    this.orderTotal,
    this.cart,
    this.customer,
  });

  OptionOrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    orderId = json['order_id'] as String?;
    customerId = json['customer_id'] as String?;
    salesmanId = json['salesman_id'] as String?;
    paymentStatus = json['payment_status'] as int?;
    orderStatus = json['order_status'] as int?;
    cartId = json['cart_id'] as String?;
    orderCreatAt = json['order_creat_at'] as String?;
    generatedDate = json['generated_date'] as String?;
    deliveryDatetime = json['delivery_datetime'] as String?;
    orderTotal = json['order_total'] as num?;
    customer = (json['customer'] as List?)
        ?.map(
            (dynamic e) => CustomerDetails.fromJson(e as Map<String, dynamic>))
        .toList();
    invoice = (json['invoice'] as List?)
        ?.map((dynamic e) => OrderInvoice.fromJson(e as Map<String, dynamic>))
        .toList();
    cart = (json['cart'] as List?)
        ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>,
            setOptionOrderData: OptionOrderData(
              id: json['id'] as int?,
              orderId: json['order_id'] as String?,
              customerId: json['customer_id'] as String?,
              salesmanId: json['salesman_id'] as String?,
              paymentStatus: json['payment_status'] as int?,
              orderStatus: json['order_status'] as int?,
              cartId: json['cart_id'] as String?,
              orderCreatAt: json['order_creat_at'] as String?,
              deliveryDatetime: json['delivery_datetime'] as String?,
              orderTotal: json['order_total'] as num?,
            ),
            setCustomerDetails: json['customer'] != null
                ? CustomerDetails.fromJson((json['customer'] as List)
                    .firstWhere((element) =>
                        element["customer_id"] == json['customer_id']))
                : null))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['order_id'] = orderId;
    json['customer_id'] = customerId;
    json['salesman_id'] = salesmanId;
    json['payment_status'] = paymentStatus;
    json['order_status'] = orderStatus;
    json['cart_id'] = cartId;
    json['order_creat_at'] = orderCreatAt;
    json['generated_date'] = generatedDate;
    json['delivery_datetime'] = deliveryDatetime;
    json['order_total'] = orderTotal;
    json['cart'] = cart?.map((e) => e.toJson()).toList();
    json['customer'] = customer?.map((e) => e.toJson()).toList();
    json['invoice'] = invoice?.map((e) => e.toJson()).toList();
    return json;
  }
}
class OrderInvoice {
  final int? id;
  final String? invoiceId;
  final String? cartId;
  final String? orderId;
  final String? createdAt;
  final String? updatedAt;

  OrderInvoice({
    this.id,
    this.invoiceId,
    this.cartId,
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  OrderInvoice.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        invoiceId = json['invoice_id'] as String?,
        cartId = json['cart_id'] as String?,
        orderId = json['order_id'] as String?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'cart_id': cartId,
        'order_id': orderId,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
class OptionData {
  String title;
  String count;
  String unfilteredCount;
  String svg;
  Color svgBgColor;
  Color? color;
  VoidCallback? onTap;
  VoidCallback? onUnFilterTap;

  OptionData({
    required this.title,
    required this.count,
    required this.unfilteredCount,
    required this.svg,
    required this.svgBgColor,
    this.onTap,
    this.onUnFilterTap,
    this.color,
  });
}