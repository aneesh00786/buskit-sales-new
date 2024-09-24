class DraftOrderResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<Data>? data;

  DraftOrderResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  DraftOrderResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => Data.fromJson(e as Map<String, dynamic>))
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

class Data {
  int? id;
  String? orderId;
  String? customerId;
  String? salesmanId;
  String? paymentStatus;
  String? orderStatus;
  List<dynamic>? orderList;
  String? orderCreatAt;
  int? orderTotal;
  String? fullname;
  String? mobileno;
  String? email;
  String? imageUrl;

  Data({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
    this.paymentStatus,
    this.orderStatus,
    this.orderList,
    this.orderCreatAt,
    this.orderTotal,
    this.fullname,
    this.mobileno,
    this.email,
    this.imageUrl,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    orderId = json['order_id'] as String?;
    customerId = json['customer_id'] as String?;
    salesmanId = json['salesman_id'] as String?;
    paymentStatus = json['payment_status'] as String?;
    orderStatus = json['order_status'] as String?;
    orderList = json['order_list'] as List?;
    orderCreatAt = json['order_creat_at'] as String?;
    orderTotal = json['order_total'] as int?;
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    imageUrl = json['image_url'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['order_id'] = orderId;
    json['customer_id'] = customerId;
    json['salesman_id'] = salesmanId;
    json['payment_status'] = paymentStatus;
    json['order_status'] = orderStatus;
    json['order_list'] = orderList;
    json['order_creat_at'] = orderCreatAt;
    json['order_total'] = orderTotal;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['image_url'] = imageUrl;
    return json;
  }
}
