class ButtonAction {
    int? statusCode;
    bool? status;
    List<ButtonActionData>? data;
    int? count;
    String? message;

    ButtonAction({
        this.statusCode,
        this.status,
        this.data,
        this.count,
        this.message,
    });

    factory ButtonAction.fromJson(Map<String, dynamic> json) => ButtonAction(
        statusCode: json["status_code"],
        status: json["status"],
        data: List<ButtonActionData>.from(json["data"].map((x) => ButtonActionData.fromJson(x))),
        count: json["count"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "count": count,
        "message": message,
    };
}

class ButtonActionData {
    int id;
    String orderId;
    String customerId;
    String salesmanId;
    int paymentStatus;
    int paymentType;
    String paymentDetail;
    int orderStatus;
    String cartId;
    DateTime orderCreatAt;
    num orderTotal;
    num receivedAmount;
    dynamic receivedAmountDate;
    DateTime checkDueDate;
    dynamic checkNumber;
    dynamic transactionDate;
    String transactionDetails;
    String rejectionReason;
    DateTime rejectedDate;
    dynamic receivableAmount;
    dynamic deliveryDatetime;

    ButtonActionData({
        required this.id,
        required this.orderId,
        required this.customerId,
        required this.salesmanId,
        required this.paymentStatus,
        required this.paymentType,
        required this.paymentDetail,
        required this.orderStatus,
        required this.cartId,
        required this.orderCreatAt,
        required this.orderTotal,
        required this.receivedAmount,
        required this.receivedAmountDate,
        required this.checkDueDate,
        required this.checkNumber,
        required this.transactionDate,
        required this.transactionDetails,
        required this.rejectionReason,
        required this.rejectedDate,
        required this.receivableAmount,
        required this.deliveryDatetime,
    });

    factory ButtonActionData.fromJson(Map<String, dynamic> json) =>
      ButtonActionData(
        id: json["id"] ?? "",
        orderId: json["order_id"] ?? "",
        customerId: json["customer_id"] ?? "",
        salesmanId: json["salesman_id"] ?? "",
        paymentStatus: json["payment_status"] ?? "",
        paymentType: json["payment_type"] ?? "",
        paymentDetail: json["payment_detail"] ?? "",
        orderStatus: json["order_status"] ?? "",
        cartId: json["cart_id"] ?? "",
        orderCreatAt: json["order_creat_at"] != null
            ? DateTime.parse(json["order_creat_at"])
            : DateTime.now(),
        orderTotal: num.tryParse(json["order_total"]?.toString() ?? "0") ?? 0,
        receivedAmount:
            num.tryParse(json["received_amount"]?.toString() ?? "0") ?? 0,
        receivedAmountDate: json["received_amount_date"] ?? "",
        checkDueDate: json["check_due_date"] != null
            ? DateTime.parse(json["check_due_date"])
            : DateTime.now(),
        checkNumber: json["check_number"] ?? "",
        transactionDate: json["transaction_date"] ?? "",
        transactionDetails: json["transaction_details"] ?? "",
        rejectionReason: json["rejection_reason"] ?? "",
        rejectedDate: json["rejected_date"] != null
            ? DateTime.parse(json["rejected_date"])
            : DateTime.now(),
        receivableAmount: json["receivable_amount"] ?? 0,
        deliveryDatetime: json["delivery_datetime"] ?? "",
      );

    Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "customer_id": customerId,
        "salesman_id": salesmanId,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "cart_id": cartId,
        "order_creat_at": orderCreatAt.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate,
        "check_due_date": checkDueDate.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate,
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate.toIso8601String(),
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime,
    };
}