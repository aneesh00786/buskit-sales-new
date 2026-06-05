import 'dart:convert';

PendingPaymentResponse pendingPaymentResponseFromJson(String str) =>
    PendingPaymentResponse.fromJson(json.decode(str));

String pendingPaymentResponseToJson(PendingPaymentResponse data) =>
    json.encode(data.toJson());

class PendingPaymentResponse {
  int statusCode;
  bool status;
  String message;
  List<CustomerData> data;
  ChartDetails chartDetails;
  num totalAmount;
  num nearlydueAmount;
  num dueAmount;
  num overdueAmount;
  Pagination pagination;

  PendingPaymentResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    required this.chartDetails,
    required this.totalAmount,
    required this.nearlydueAmount,
    required this.dueAmount,
    required this.overdueAmount,
    required this.pagination,
  });

  factory PendingPaymentResponse.fromJson(Map<String, dynamic> json) =>
      PendingPaymentResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<CustomerData>.from(
            json["data"].map((x) => CustomerData.fromJson(x))),
        chartDetails: ChartDetails.fromJson(json["chartDetails"]),
        totalAmount: json["total_amount"],
        nearlydueAmount: json["nearlydue_amount"],
        dueAmount: json["due_amount"],
        overdueAmount: json["overdue_amount"],
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "chartDetails": chartDetails.toJson(),
        "total_amount": totalAmount,
        "nearlydue_amount": nearlydueAmount,
        "due_amount": dueAmount,
        "overdue_amount": overdueAmount,
        "pagination": pagination.toJson(),
      };
}

class ChartDetails {
  int nearlyDue;
  int due;
  int all;
  int overdue;

  ChartDetails({
    required this.nearlyDue,
    required this.due,
    required this.all,
    required this.overdue,
  });

  factory ChartDetails.fromJson(Map<String, dynamic> json) => ChartDetails(
        nearlyDue: json["nearlyDue"],
        due: json["due"],
        all: json["all"],
        overdue: json["overdue"],
      );

  Map<String, dynamic> toJson() => {
        "nearlyDue": nearlyDue,
        "due": due,
        "all": all,
        "overdue": overdue,
      };
}

class CustomerData {
  String imageUrl;
  String orderId;
  String customerId;
  DateTime orderCreatAt;
  DateTime? deliveryDate;
  int creditPeriod;
  String fullname;
  String businessName;
  num orderTotal;
  int orderStatus;
  String town;
  String email;
  num receivedAmount;
  String invoiceId;
  String mobileno;
  int hasActiveLink;

  CustomerData({
    required this.imageUrl,
    required this.orderId,
    required this.customerId,
    required this.orderCreatAt,
    this.deliveryDate,
    required this.creditPeriod,
    required this.fullname,
    required this.businessName,
    required this.orderTotal,
    required this.orderStatus,
    required this.town,
    required this.email,
    required this.receivedAmount,
    required this.invoiceId,
    this.mobileno = '',
    this.hasActiveLink = 0,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
        imageUrl: json["image_url"],
        orderId: json["order_id"],
        customerId: json["customer_id"],
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        deliveryDate: json["delivery_datetime"] != null
            ? DateTime.parse(json["delivery_datetime"])
            : null,
        creditPeriod: json["credit_period"],
        fullname: json["fullname"],
        businessName: json["business_name"],
        orderTotal: num.tryParse(json["order_total"].toString()) ?? 0,
        orderStatus: json["order_status"],
        town: json["town"],
        email: json["email"],
        invoiceId: json["invoice_id"],
        receivedAmount: num.tryParse(json["received_amount"].toString()) ?? 0,
        mobileno: json["mobileno"] ?? '',
        hasActiveLink: json["has_active_link"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "image_url": imageUrl,
        "order_id": orderId,
        "customer_id": customerId,
        "order_creat_at": orderCreatAt.toIso8601String(),
        "delivery_datetime": deliveryDate?.toIso8601String(),
        "credit_period": creditPeriod,
        "fullname": fullname,
        "business_name": businessName,
        "order_total": orderTotal,
        "order_status": orderStatus,
        "town": town,
        "email": email,
        "received_amount": receivedAmount,
        "invoice_id": invoiceId,
        "mobileno": mobileno,
        "has_active_link": hasActiveLink,
      };
}

class Pagination {
  int totalRecord;
  int totalPages;
  String perPage;

  Pagination({
    required this.totalRecord,
    required this.totalPages,
    required this.perPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalRecord: json["total_record"],
        totalPages: json["total_pages"],
        perPage: json["per_page"],
      );

  Map<String, dynamic> toJson() => {
        "total_record": totalRecord,
        "total_pages": totalPages,
        "per_page": perPage,
      };
}

IndividualPendingPaymentResponse individualPendingPaymentResponseFromJson(
        String str) =>
    IndividualPendingPaymentResponse.fromJson(json.decode(str));

String individualPendingPaymentResponseToJson(
        IndividualPendingPaymentResponse data) =>
    json.encode(data.toJson());

class IndividualPendingPaymentResponse {
  int statusCode;
  bool status;
  List<IndividualPendingData> data;
  String message;

  IndividualPendingPaymentResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.message,
  });

  factory IndividualPendingPaymentResponse.fromJson(
          Map<String, dynamic> json) =>
      IndividualPendingPaymentResponse(
        statusCode: json["status_code"],
        status: json["status"],
        data: List<IndividualPendingData>.from(
            json["data"].map((x) => IndividualPendingData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class IndividualPendingData {
  int paymentType;
  int creditPeriod;
  num receivedAmount;
  DateTime? receivedAmountDate;
  String orderId;
  DateTime orderCreatAt;
  num orderTotal;
  int orderStatus;
  int paymentStatus;
  String customerId;
  String invoiceId;
  num? receivableAmount;
  final num? amountEdited;
  num? pendingAmount;
  int hasActiveLink;

  IndividualPendingData({
    required this.paymentType,
    required this.creditPeriod,
    required this.receivedAmount,
    required this.receivedAmountDate,
    required this.orderId,
    required this.orderCreatAt,
    required this.orderTotal,
    required this.orderStatus,
    required this.paymentStatus,
    required this.customerId,
    required this.receivableAmount,
    required this.amountEdited,
    required this.invoiceId,
    required this.pendingAmount,
    this.hasActiveLink = 0,
  });

  factory IndividualPendingData.fromJson(Map<String, dynamic> json) =>
      IndividualPendingData(
        paymentType: json["payment_type"] ?? 0,
        creditPeriod: json["credit_period"] ?? 0,
        receivedAmount: num.tryParse(json["received_amount"].toString()) ?? 0,
        receivedAmountDate: json["received_amount_date"] == null
            ? null
            : DateTime.parse(json["received_amount_date"]),
        orderId: json["order_id"] ?? '',
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        orderTotal: num.tryParse(json["order_total"].toString()) ?? 0,
        orderStatus: json["order_status"] ?? 0,
        paymentStatus: json["payment_status"] ?? 0,
        customerId: json["customer_id"] ?? '',
        receivableAmount:
            num.tryParse(json["receivable_amount"].toString()) ?? 0,
        amountEdited: num.tryParse(json['amount_edited'].toString()) ?? 0,
        pendingAmount: num.tryParse(json['pending_amount'].toString()) ?? 0,
        invoiceId: json['invoice_id'] ?? '',
        hasActiveLink: json["has_active_link"] ?? 0,
        
      );

  Map<String, dynamic> toJson() => {
        "payment_type": paymentType,
        "credit_period": creditPeriod,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate?.toIso8601String(),
        "order_id": orderId,
        "order_creat_at": orderCreatAt.toIso8601String(),
        "order_total": orderTotal,
        "order_status": orderStatus,
        "payment_status": paymentStatus,
        "customer_id": customerId,
        "receivable_amount": receivableAmount,
        "amount_edited": amountEdited,
        "pending_amount": pendingAmount,
        "invoice_id": invoiceId,
        "has_active_link": hasActiveLink,
      };
}
