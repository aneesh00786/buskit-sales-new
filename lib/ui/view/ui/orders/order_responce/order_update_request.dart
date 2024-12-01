// import 'dart:convert';

// UpdateRequest updatedOrdersFromJson(String str) => UpdateRequest.fromJson(json.decode(str));

// String updatedOrdersToJson(UpdateRequest data) => json.encode(data.toJson());

// class UpdateRequest {
//     String orderId;
//     List<UpdatedOrder> updatedOrders;

//     UpdateRequest({
//         required this.orderId,
//         required this.updatedOrders,
//     });

//     factory UpdateRequest.fromJson(Map<String, dynamic> json) => UpdateRequest(
//         orderId: json["order_id"],
//         updatedOrders: List<UpdatedOrder>.from(json["updatedOrders"].map((x) => UpdatedOrder.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "order_id": orderId,
//         "updatedOrders": List<dynamic>.from(updatedOrders.map((x) => x.toJson())),
//     };
// }

// class UpdatedOrder {
//     int? id;
//     String? customerId;
//     String? cartId;
//     String? fullname;
//     String? mobileno;
//     String? email;
//     String? town;
//     String? state;
//     int? zipcode;
//     String? address;
//     String? businessName;
//     String? businessNo;
//     String? remark;
//     String? imageUrl;
//     String? salesmanId;
//     int? status;
//     String? createAt;
//     String? salesmanName;
//     String? discount;
//     int? eventType;
//     String? eventDays;
//     int? creditPeriod;
//     int? companyId;
//     String? orderId;
//     int? paymentStatus;
//     int? paymentType;
//     String? paymentDetail;
//     int? orderStatus;
//     String? orderCreatAt;
//     int? orderTotal;
//     int? receivedAmount;
//     dynamic receivedAmountDate;
//     String? checkDueDate;
//     int? checkNumber;
//     String? transactionDate;
//     String? transactionDetails;
//     String? rejectionReason;
//     String? rejectedDate;
//     int? receivableAmount;
//     String? deliveryDatetime;
//     List<UpdateCart> cart;
//     List<dynamic> invoice;

//     UpdatedOrder({
//       this.id,
//       this.customerId,
//       this.cartId,
//       this.fullname,
//       this.mobileno,
//       this.email,
//       this.town,
//       this.state,
//       this.zipcode,
//       this.address,
//       this.businessName,
//       this.businessNo,
//       this.remark,
//       this.imageUrl,
//       this.salesmanId,
//       this.status,
//       this.createAt,
//       this.salesmanName,
//       this.discount,
//       this.eventType,
//       this.eventDays,
//       this.creditPeriod,
//       this.companyId,
//       this.orderId,
//       this.paymentStatus,
//       this.paymentType,
//       this.paymentDetail,
//       this.orderStatus,
//       this.orderCreatAt,
//       this.orderTotal,
//       this.receivedAmount,
//       this.receivedAmountDate,
//       this.checkDueDate,
//       this.checkNumber,
//       this.transactionDate,
//       this.transactionDetails,
//       this.rejectionReason,
//       this.rejectedDate,
//       this.receivableAmount,
//       this.deliveryDatetime,
//       this.cart,
//       this.invoice,
//     });

//     factory UpdatedOrder.fromJson(Map<String, dynamic> json) => UpdatedOrder(
//         id: json["id"],
//         customerId: json["customer_id"],
//         cartId: json["cart_id"],
//         fullname: json["fullname"],
//         mobileno: json["mobileno"],
//         email: json["email"],
//         town: json["town"],
//         state: json["state"],
//         zipcode: json["zipcode"],
//         address: json["address"],
//         businessName: json["business_name"],
//         businessNo: json["business_no"],
//         remark: json["remark"],
//         imageUrl: json["image_url"],
//         salesmanId: json["salesman_id"],
//         status: json["status"],
//         createAt: DateTime.parse(json["create_at"]),
//         salesmanName: json["salesman_name"],
//         discount: json["discount"],
//         eventType: json["event_type"],
//         eventDays: List<dynamic>.from(json["event_days"].map((x) => x)),
//         creditPeriod: json["credit_period"],
//         companyId: json["company_id"],
//         orderId: json["order_id"],
//         paymentStatus: json["payment_status"],
//         paymentType: json["payment_type"],
//         paymentDetail: json["payment_detail"],
//         orderStatus: json["order_status"],
//         orderCreatAt: DateTime.parse(json["order_creat_at"]),
//         orderTotal: json["order_total"],
//         receivedAmount: json["received_amount"],
//         receivedAmountDate: json["received_amount_date"],
//         checkDueDate: DateTime.parse(json["check_due_date"]),
//         checkNumber: json["check_number"],
//         transactionDate: json["transaction_date"],
//         transactionDetails: json["transaction_details"],
//         rejectionReason: json["rejection_reason"],
//         rejectedDate: json["rejected_date"],
//         receivableAmount: json["receivable_amount"],
//         deliveryDatetime: json["delivery_datetime"],
//         cart: List<UpdateCart>.from(json["cart"].map((x) => UpdateCart.fromJson(x))),
//         invoice: List<dynamic>.from(json["invoice"].map((x) => x)),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "customer_id": customerId,
//         "cart_id": cartId,
//         "fullname": fullname,
//         "mobileno": mobileno,
//         "email": email,
//         "town": town,
//         "state": state,
//         "zipcode": zipcode,
//         "address": address,
//         "business_name": businessName,
//         "business_no": businessNo,
//         "remark": remark,
//         "image_url": imageUrl,
//         "salesman_id": salesmanId,
//         "status": status,
//         "create_at": createAt.toIso8601String(),
//         "salesman_name": salesmanName,
//         "discount": discount,
//         "event_type": eventType,
//         "event_days": List<dynamic>.from(eventDays.map((x) => x)),
//         "credit_period": creditPeriod,
//         "company_id": companyId,
//         "order_id": orderId,
//         "payment_status": paymentStatus,
//         "payment_type": paymentType,
//         "payment_detail": paymentDetail,
//         "order_status": orderStatus,
//         "order_creat_at": orderCreatAt.toIso8601String(),
//         "order_total": orderTotal,
//         "received_amount": receivedAmount,
//         "received_amount_date": receivedAmountDate,
//         "check_due_date": checkDueDate.toIso8601String(),
//         "check_number": checkNumber,
//         "transaction_date": transactionDate,
//         "transaction_details": transactionDetails,
//         "rejection_reason": rejectionReason,
//         "rejected_date": rejectedDate,
//         "receivable_amount": receivableAmount,
//         "delivery_datetime": deliveryDatetime,
//         "cart": List<dynamic>.from(cart.map((x) => x.toJson())),
//         "invoice": List<dynamic>.from(invoice.map((x) => x)),
//     };
// }

// class UpdateCart {
//     int id;
//     String cartId;
//     String productId;
//     String variationId;
//     dynamic price;
//     dynamic reason;
//     int quantity;
//     String totalPrice;
//     int status;
//     DateTime createdAt;
//     DateTime updatedAt;
//     String variationName;
//     String productName;

//     UpdateCart({
//         required this.id,
//         required this.cartId,
//         required this.productId,
//         required this.variationId,
//         required this.price,
//         required this.reason,
//         required this.quantity,
//         required this.totalPrice,
//         required this.status,
//         required this.createdAt,
//         required this.updatedAt,
//         required this.variationName,
//         required this.productName,
//     });

//     factory UpdateCart.fromJson(Map<String, dynamic> json) => UpdateCart(
//         id: json["id"],
//         cartId: json["cart_id"],
//         productId: json["product_id"],
//         variationId: json["variation_id"],
//         price: json["price"],
//         reason: json["reason"],
//         quantity: json["quantity"],
//         totalPrice: json["total_price"],
//         status: json["status"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//         variationName: json["variation_name"],
//         productName: json["product_name"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "cart_id": cartId,
//         "product_id": productId,
//         "variation_id": variationId,
//         "price": price,
//         "reason": reason,
//         "quantity": quantity,
//         "total_price": totalPrice,
//         "status": status,
//         "created_at": createdAt.toIso8601String(),
//         "updated_at": updatedAt.toIso8601String(),
//         "variation_name": variationName,
//         "product_name": productName,
//     };
// }