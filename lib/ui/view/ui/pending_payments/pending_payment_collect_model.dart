// To parse this JSON data, do
//
//     final pendingCollectIndividual = pendingCollectIndividualFromJson(jsonString);

// import 'dart:convert';

// PendingCollectIndividual pendingCollectIndividualFromJson(String str) => PendingCollectIndividual.fromJson(json.decode(str));

// String pendingCollectIndividualToJson(PendingCollectIndividual data) => json.encode(data.toJson());

// class PendingCollectIndividual {
//     int statusCode;
//     bool status;
//     List<PendingIndividualData> data;
//     String message;

//     PendingCollectIndividual({
//         required this.statusCode,
//         required this.status,
//         required this.data,
//         required this.message,
//     });

//     factory PendingCollectIndividual.fromJson(Map<String, dynamic> json) => PendingCollectIndividual(
//         statusCode: json["status_code"],
//         status: json["status"],
//         data: List<PendingIndividualData>.from(json["data"].map((x) => PendingIndividualData.fromJson(x))),
//         message: json["message"],
//     );

//     Map<String, dynamic> toJson() => {
//         "status_code": statusCode,
//         "status": status,
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//         "message": message,
//     };
// }

// class PendingIndividualData {
//     int paymentType;
//     int creditPeriod;
//     int receivedAmount;
//     DateTime? receivedAmountDate;
//     String orderId;
//     DateTime orderCreatAt;
//     int orderTotal;
//     int orderStatus;
//     int paymentStatus;
//     String customerId;
//     int? receivableAmount;

//     PendingIndividualData({
//         required this.paymentType,
//         required this.creditPeriod,
//         required this.receivedAmount,
//         required this.receivedAmountDate,
//         required this.orderId,
//         required this.orderCreatAt,
//         required this.orderTotal,
//         required this.orderStatus,
//         required this.paymentStatus,
//         required this.customerId,
//         required this.receivableAmount,
//     });

//     factory PendingIndividualData.fromJson(Map<String, dynamic> json) => PendingIndividualData(
//         paymentType: json["payment_type"],
//         creditPeriod: json["credit_period"],
//         receivedAmount: json["received_amount"],
//         receivedAmountDate: json["received_amount_date"] == null ? null : DateTime.parse(json["received_amount_date"]),
//         orderId: json["order_id"],
//         orderCreatAt: DateTime.parse(json["order_creat_at"]),
//         orderTotal: json["order_total"],
//         orderStatus: json["order_status"],
//         paymentStatus: json["payment_status"],
//         customerId: json["customer_id"],
//         receivableAmount: json["receivable_amount"],
//     );

//     Map<String, dynamic> toJson() => {
//         "payment_type": paymentType,
//         "credit_period": creditPeriod,
//         "received_amount": receivedAmount,
//         "received_amount_date": receivedAmountDate?.toIso8601String(),
//         "order_id": orderId,
//         "order_creat_at": orderCreatAt.toIso8601String(),
//         "order_total": orderTotal,
//         "order_status": orderStatus,
//         "payment_status": paymentStatus,
//         "customer_id": customerId,
//         "receivable_amount": receivableAmount,
//     };
// }
