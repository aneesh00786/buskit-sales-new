import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
class OrderResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<OrderData>? data;
  OrderPagination? pagination;

  OrderResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.pagination,
  });

  OrderResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map((dynamic e) => OrderData.fromJson(e as Map<String, dynamic>))
        .toList();
    pagination = OrderPagination.fromJson(json["pagination"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status_code'] = statusCode;
    json['status'] = status;
    json['message'] = message;
    json['data'] = data?.map((e) => e.toJson()).toList();
    json['pagination'] = pagination?.toJson();
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
  String? deliveryDatetime;
  num? orderTotal;
  String? fullname;
  String? lastname;
  String? editedFullname;
  String? editedLastname;
  String? generatedDate;
  String? orderSource;

  List<CustomerCart>? cart;
  List<CustomerDetails>? customer;
  List<CustomerAssignedSalesman>? salesman;
  List<OrderInvoice>? invoice;

  OrderData({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
    this.paymentStatus,
    this.orderStatus,
    this.cartId,
    this.orderCreatAt,
    this.deliveryDatetime,
    this.orderTotal,
    this.fullname,
    this.lastname,
    this.editedFullname,
    this.editedLastname,
    this.generatedDate,
    this.cart,
    this.salesman,
    this.orderSource

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
    deliveryDatetime = json['delivery_datetime'] as String?;
    orderTotal = num.tryParse(json['order_total'].toString()) ?? 0;
    fullname = json['fullname'] as String?;
    lastname = json['lastname'] as String?;
    editedFullname = json['edited_fullname'] as String?;
    editedLastname = json['edited_lastname'] as String?;

    generatedDate = json['generated_date'] as String?;
     invoice = json['invoice'] != null
        ? [
            OrderInvoice.fromJson(
              ensureStringKeyedMap(json['invoice']),
            )
          ]
        : [];
    cart = (json['cart'] as List?)
        ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>,
            setOptionOrderData: OptionOrderData(
              customerId: json['customer_id'] as String?,
              salesmanId: json['salesman_id'] as String?,
              cartId: json['cart_id'] as String?,
              orderTotal: json['order_total'] as num?,
              orderStatus: json['order_status'] as int?,
              orderCreatAt: json['order_creat_at'] as String?,
              deliveryDatetime: json['delivery_datetime'] as String?,
              generatedDate: json['generated_date'] as String?,
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
        orderSource = json['order_source'] as String?;

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
    json['delivery_datetime'] = deliveryDatetime;
    json['order_total'] = orderTotal;
    json['fullname'] = fullname;
    json['lastname'] = lastname;
    json['edited_fullname'] = editedFullname;
    json['edited_lastname'] = editedLastname;
    json['generated_date'] = generatedDate;
    json['cart'] = cart?.map((e) => e.toJson()).toList();
    json['salesman'] = salesman?.map((e) => e.toJson()).toList();
    json['customer'] = customer?.map((e) => e.toJson()).toList();
    json['invoice'] = invoice?.map((e) => e.toJson()).toList();
    json['order_source'] = orderSource;

    return json;
  }
}

class OrderPagination {
  int? totalRecord;
  int? totalPages;
  int? currentPage;
  int? perPage;

  OrderPagination({
    this.totalRecord,
    this.totalPages,
    this.currentPage,
    this.perPage,
  });

  factory OrderPagination.fromJson(Map<String, dynamic> json) =>
      OrderPagination(
        totalRecord: json["total_record"],
        totalPages: json["total_pages"],
        currentPage: json["current_page"],
        perPage: json["per_page"],
      );

  Map<String, dynamic> toJson() => {
        "total_record": totalRecord,
        "total_pages": totalPages,
        "current_page": currentPage,
        "per_page": perPage,
      };
}
class OrderCountResponse {
  int statusCode;
  bool status;
  List<OrderCountData> data;
  String message;

  OrderCountResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.message,
  });

  factory OrderCountResponse.fromJson(Map<String, dynamic> json) {
    return OrderCountResponse(
      statusCode: json['status_code'],
      status: json['status'],
      data: List<OrderCountData>.from(
          json['data'].map((item) => OrderCountData.fromJson(item))),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'data': List<dynamic>.from(data.map((item) => item.toJson())),
      'message': message,
    };
  }
}

class OrderCountData {
  int count;
  String status;

  OrderCountData({required this.count, required this.status});

  factory OrderCountData.fromJson(Map<String, dynamic> json) {
    return OrderCountData(
      count: json.values.first,
      status: json.keys.first,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      status: count,
    };
  }
}

class OrderProcessInvoice {
  int statusCode;
  bool status;
  List<OrderProcessInvoiceData> data;
  int count;
  String message;

  OrderProcessInvoice({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.count,
    required this.message,
  });

  factory OrderProcessInvoice.fromJson(Map<String, dynamic> json) =>
      OrderProcessInvoice(
        statusCode: json["status_code"],
        status: json["status"],
        data: List<OrderProcessInvoiceData>.from(
            json["data"].map((x) => OrderProcessInvoiceData.fromJson(x))),
        count: json["count"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "count": count,
        "message": message,
      };
}

class OrderProcessInvoiceData {
  int? id;
  String? orderId;
  String? customerId;
  String? salesmanId;
  String? salesmanName;
  int? paymentStatus;
  int? paymentType;
  String? paymentDetail;
  int? orderStatus;
  String? cartId;
  DateTime? orderCreatAt;
  num? orderTotal;
  num? receivedAmount;
  DateTime? receivedAmountDate;
  DateTime? checkDueDate;
  int? checkNumber;
  DateTime? transactionDate;
  String? transactionDetails;
  String? rejectionReason;
  dynamic rejectedDate;
  dynamic receivableAmount;
  DateTime? deliveryDatetime;
  String? fullname;
  String? businessName;
  String? mobileNo;
  String? email;
  String? address;
  List<CustomerCart>? cart;
  List<OrderInvoice>? invoice;
  List<SpecificTax>? tax;
  String? imageUrl;
  String? orderSource;

  OrderProcessInvoiceData({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
    this.salesmanName,
    this.paymentStatus,
    this.paymentType,
    this.paymentDetail,
    this.orderStatus,
    this.cartId,
    this.orderCreatAt,
    this.orderTotal,
    this.receivedAmount,
    this.receivedAmountDate,
    this.checkDueDate,
    this.checkNumber,
    this.transactionDate,
    this.transactionDetails,
    this.rejectionReason,
    this.rejectedDate,
    this.receivableAmount,
    this.deliveryDatetime,
    this.fullname,
    this.businessName,
    this.mobileNo,
    this.email,
    this.address,
    this.cart,
    this.invoice,
    this.tax,
    this.imageUrl,
    this.orderSource
  });

  factory OrderProcessInvoiceData.fromJson(Map<String, dynamic> json) =>
      OrderProcessInvoiceData(
        id: json["id"],
        orderId: json["order_id"],
        customerId: json["customer_id"],
        salesmanId: json["salesman_id"],
        salesmanName: json["salesman_name"],
        paymentStatus: json["payment_status"],
        paymentType: json["payment_type"],
        paymentDetail: json["payment_detail"],
        orderStatus: json["order_status"],
        cartId: json["cart_id"],
        orderCreatAt: json["order_creat_at"] != null
            ? DateTime.parse(json["order_creat_at"])
            : null,
        orderTotal: num.tryParse(json["order_total"].toString()) ?? 0,
        receivedAmount: num.tryParse(json["received_amount"].toString()) ?? 0,
        receivedAmountDate: json["received_amount_date"] != null
            ? DateTime.parse(json["received_amount_date"])
            : null,
        checkDueDate: json["check_due_date"] != null
            ? DateTime.parse(json["check_due_date"])
            : null,
        checkNumber: json["check_number"],
        transactionDate: json["transaction_date"] != null
            ? DateTime.parse(json["transaction_date"])
            : null,
        transactionDetails: json["transaction_details"],
        rejectionReason: json["rejection_reason"],
        rejectedDate: json["rejected_date"],
        receivableAmount: json["receivable_amount"],
        deliveryDatetime: json["delivery_datetime"] != null
            ? DateTime.parse(json["delivery_datetime"])
            : null,
        fullname: json["fullname"],
        businessName: json["business_name"],
        email: json["email"],
        address: json["address"],
        mobileNo: json["mobileno"],
        cart: json["cart"] != null
            ? List<CustomerCart>.from(
                json["cart"].map((x) => CustomerCart.fromJson(x)))
            : null,
        invoice: json["invoice"] != null
            ? List<OrderInvoice>.from(
                json["invoice"].map((x) => OrderInvoice.fromJson(x)))
            : null,
        tax: json["tax"] != null
            ? List<SpecificTax>.from(
                json["tax"].map((x) => SpecificTax.fromJson(x)))
            : null,
         imageUrl: json["image_url"]?.toString(),
        orderSource: json['order_source'] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "customer_id": customerId,
        "salesman_id": salesmanId,
        "salesman_name": salesmanName,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "cart_id": cartId,
        "order_creat_at": orderCreatAt?.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate?.toIso8601String(),
        "check_due_date": checkDueDate?.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate?.toIso8601String(),
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate,
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime?.toIso8601String(),
        "fullname": fullname,
        "business_name": businessName,
        "email": email,
        "mobileno": mobileNo,
        "address": address,
        "cart": cart != null
            ? List<dynamic>.from(cart!.map((x) => x.toJson()))
            : null,
        "invoice": invoice != null
            ? List<dynamic>.from(invoice!.map((x) => x.toJson()))
            : null,
        "tax": tax != null
            ? List<dynamic>.from(tax!.map((x) => x.toJson()))
            : null,
        "image_url": imageUrl,
        "order_source": orderSource,
      };
}class SalesmanTargetByCatId {
  int statusCode;
  bool status;
  String message;
  List<TargetDatum>? targetData;

  SalesmanTargetByCatId({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.targetData,
  });

  factory SalesmanTargetByCatId.fromJson(Map<String, dynamic> json) =>
      SalesmanTargetByCatId(
        statusCode: json["status_code"] ?? 0,
        status: json["status"] ?? false,
        message: json["message"] ?? "No message",
        targetData: (json["TargetData"] as List<dynamic>?)
            ?.map((x) => TargetDatum.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "TargetData": targetData?.map((x) => x.toJson()).toList() ?? [],
      };
}

class TargetDatum {
  int? id;
  int? companyId;
  int? categoryId;
  int? target;
  int? projection;
  String? salesId;
  String? month;
  String? year;
  String? weeklyTarget;
  String? weeklyProjection;

  TargetDatum({
    this.id,
    this.companyId,
    this.categoryId,
    this.target,
    this.projection,
    this.salesId,
    this.month,
    this.year,
    this.weeklyTarget,
    this.weeklyProjection,
  });

  factory TargetDatum.fromJson(Map<String, dynamic> json) => TargetDatum(
        id: json["id"],
        companyId: json["company_id"],
        categoryId: json["category_id"],
        target: json["target"],
        projection: json["projection"],
        salesId: json["sales_id"],
        month: json["month"],
        year: json["year"],
        weeklyTarget: json["weekly_target"],
        weeklyProjection: json["weekly_projection"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "category_id": categoryId,
        "target": target,
        "projection": projection,
        "sales_id": salesId,
        "month": month,
        "year": year,
        "weekly_target": weeklyTarget,
        "weekly_projection": weeklyProjection,
      };
}
