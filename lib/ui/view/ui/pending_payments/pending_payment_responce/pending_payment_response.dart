// To parse this JSON data, do
//
//     final pendingPaymentResponse = pendingPaymentResponseFromJson(jsonString);

import 'dart:convert';

PendingPaymentResponse pendingPaymentResponseFromJson(String str) => PendingPaymentResponse.fromJson(json.decode(str));

String pendingPaymentResponseToJson(PendingPaymentResponse data) => json.encode(data.toJson());

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

    factory PendingPaymentResponse.fromJson(Map<String, dynamic> json) => PendingPaymentResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: List<CustomerData>.from(json["data"].map((x) => CustomerData.fromJson(x))),
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
        orderTotal: json["order_total"],
        orderStatus: json["order_status"],
        town: json["town"],
        email: json["email"],
        receivedAmount: json["received_amount"],
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

///~~~~~~~~~~~~~~~~~~~~~~~~~ GET ALL PENDING PAYMENT INDIVIDUAL~~~~~~~~~~~~~
IndividualPendingPaymentResponse individualPendingPaymentResponseFromJson(String str) => IndividualPendingPaymentResponse.fromJson(json.decode(str));

String individualPendingPaymentResponseToJson(IndividualPendingPaymentResponse data) => json.encode(data.toJson());

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

    factory IndividualPendingPaymentResponse.fromJson(Map<String, dynamic> json) => IndividualPendingPaymentResponse(
        statusCode: json["status_code"],
        status: json["status"],
        data: List<IndividualPendingData>.from(json["data"].map((x) => IndividualPendingData.fromJson(x))),
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
    int receivedAmount;
    DateTime? receivedAmountDate;
    String orderId;
    DateTime orderCreatAt;
    int orderTotal;
    int orderStatus;
    int paymentStatus;
    String customerId;
    int? receivableAmount;

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
    });

    factory IndividualPendingData.fromJson(Map<String, dynamic> json) => IndividualPendingData(
        paymentType: json["payment_type"],
        creditPeriod: json["credit_period"],
        receivedAmount: json["received_amount"],
        receivedAmountDate: json["received_amount_date"] == null ? null : DateTime.parse(json["received_amount_date"]),
        orderId: json["order_id"],
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        orderTotal: json["order_total"],
        orderStatus: json["order_status"],
        paymentStatus: json["payment_status"],
        customerId: json["customer_id"],
        receivableAmount: json["receivable_amount"],
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
    };
}