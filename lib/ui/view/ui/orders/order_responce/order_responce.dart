import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';

class OrderResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<OrderData>? data;

  OrderResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  OrderResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => OrderData.fromJson(e as Map<String, dynamic>))
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

class OrderData {
  int? id;
  String? orderId;
  String? customerId;
  String? salesmanId;
  int? paymentStatus;
  int? orderStatus;
  String? cartId;
  String? orderCreatAt;
  int? orderTotal;
  List<CustomerCart>? cart;
  List<CustomerDetails>? customer;
  List<CustomerAssignedSalesman>? salesman;

  OrderData({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
    this.paymentStatus,
    this.orderStatus,
    this.cartId,
    this.orderCreatAt,
    this.orderTotal,
    this.cart,
    this.salesman,
  });

  OrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    orderId = json['order_id'] as String?;
    customerId = json['customer_id'] as String?;
    salesmanId = json['salesman_id'] as String?;
    paymentStatus = json['payment_status'] as int?;
    orderStatus = json['order_status'] as int?;
    cartId = json['cart_id'] as String?;
    orderCreatAt = json['order_creat_at'] as String?;
    orderTotal = json['order_total'] as int?;
    cart = (json['cart'] as List?)
        ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>,
            setOptionOrderData: OptionOrderData(
              customerId: json['customer_id'] as String?,
              salesmanId: json['salesman_id'] as String?,
              cartId: json['cart_id'] as String?,
              orderTotal: json['order_total'] as int?,
              orderStatus: json['order_status'] as int?,
              orderCreatAt: json['order_creat_at'] as String?,
              paymentStatus: json['payment_status'] as int?,
              orderId: json['order_id'] as String?,
              id: json['id'] as int?,
            ),
            setCustomerDetails: (json['customer'] as List?)
                ?.map((dynamic e) =>
                    CustomerDetails.fromJson(e as Map<String, dynamic>))
                .toList()
                .first))
        .toList();

    salesman = (json['salesman'] as List?)
        ?.map((dynamic e) =>
            CustomerAssignedSalesman.fromJson(e as Map<String, dynamic>))
        .toList();
    customer = (json['customer'] as List?)
        ?.map(
            (dynamic e) => CustomerDetails.fromJson(e as Map<String, dynamic>))
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
    json['order_total'] = orderTotal;
    json['cart'] = cart?.map((e) => e.toJson()).toList();
    json['salesman'] = salesman?.map((e) => e.toJson()).toList();
    json['customer'] = customer?.map((e) => e.toJson()).toList();
    return json;
  }
}
