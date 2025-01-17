import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';

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
  String? deliveryDatetime;
  int? orderTotal;
  String? fullname;
  String? lastname;
  List<CustomerCart>? cart;
  List<CustomerDetails>? customer;
  List<CustomerAssignedSalesman>? salesman;
  List<OrderInvoice>? invoice;
  // int? receivableAmount;

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
    this.cart,
    this.salesman,
    // this.receivableAmount,
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
    orderTotal = json['order_total'] as int?;
    fullname = json['fullname'] as String?;
    lastname = json['lastname'] as String?;
    invoice = (json['invoice'] as List?)
        ?.map((dynamic e) => OrderInvoice.fromJson(e as Map<String, dynamic>))
        .toList();
    cart = (json['cart'] as List?)
        ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>,
            setOptionOrderData: OptionOrderData(
              customerId: json['customer_id'] as String?,
              salesmanId: json['salesman_id'] as String?,
              cartId: json['cart_id'] as String?,
              orderTotal: json['order_total'] as int?,
              orderStatus: json['order_status'] as int?,
              orderCreatAt: json['order_creat_at'] as String?,
              deliveryDatetime: json['delivery_datetime'] as String?,
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
    // receivableAmount = json['receivable_amount'] as int?;
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
    json['cart'] = cart?.map((e) => e.toJson()).toList();
    json['salesman'] = salesman?.map((e) => e.toJson()).toList();
    json['customer'] = customer?.map((e) => e.toJson()).toList();
    json['invoice'] = invoice?.map((e) => e.toJson()).toList();
    // json['receivable_amount'] = receivableAmount;
    return json;
  }
}
// class OrderData {
//   int? id;
//   String? orderId;
//   String? customerId;
//   String? salesmanId;
//   int? paymentStatus;
//   int? orderStatus;
//   String? cartId;
//   String? orderCreatAt;
//   int? orderTotal;
//   List<CustomerCart>? cart;
//   List<CustomerDetails>? customer;
//   List<CustomerAssignedSalesman>? salesman;
//   List<OrderInvoice>? invoice;
//   // int? receivableAmount;

//   OrderData({
//     this.id,
//     this.orderId,
//     this.customerId,
//     this.salesmanId,
//     this.paymentStatus,
//     this.orderStatus,
//     this.cartId,
//     this.orderCreatAt,
//     this.orderTotal,
//     this.cart,
//     this.salesman,
//     // this.receivableAmount,
//   });

//   OrderData.fromJson(Map<String, dynamic> json) {
//     id = json['id'] as int?;
//     orderId = json['order_id'] as String?;
//     customerId = json['customer_id'] as String?;
//     salesmanId = json['salesman_id'] as String?;
//     paymentStatus = json['payment_status'] as int?;
//     orderStatus = json['order_status'] as int?;
//     cartId = json['cart_id'] as String?;
//     orderCreatAt = json['order_creat_at'] as String?;
//     orderTotal = json['order_total'] as int?;
//     invoice = (json['invoice'] as List?)
//         ?.map((dynamic e) => OrderInvoice.fromJson(e as Map<String, dynamic>))
//         .toList();
//     cart = (json['cart'] as List?)
//         ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>,
//             setOptionOrderData: OptionOrderData(
//               customerId: json['customer_id'] as String?,
//               salesmanId: json['salesman_id'] as String?,
//               cartId: json['cart_id'] as String?,
//               orderTotal: json['order_total'] as int?,
//               orderStatus: json['order_status'] as int?,
//               orderCreatAt: json['order_creat_at'] as String?,
//               paymentStatus: json['payment_status'] as int?,
//               orderId: json['order_id'] as String?,
//               id: json['id'] as int?,
//             ),
//             setCustomerDetails: (json['customer'] as List?)
//                 ?.map((dynamic e) =>
//                     CustomerDetails.fromJson(e as Map<String, dynamic>))
//                 .toList()
//                 .first))
//         .toList();

//     salesman = (json['salesman'] as List?)
//         ?.map((dynamic e) =>
//             CustomerAssignedSalesman.fromJson(e as Map<String, dynamic>))
//         .toList();
//     customer = (json['customer'] as List?)
//         ?.map(
//             (dynamic e) => CustomerDetails.fromJson(e as Map<String, dynamic>))
//         .toList();
//     // receivableAmount = json['receivable_amount'] as int?;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> json = <String, dynamic>{};
//     json['id'] = id;
//     json['order_id'] = orderId;
//     json['customer_id'] = customerId;
//     json['salesman_id'] = salesmanId;
//     json['payment_status'] = paymentStatus;
//     json['order_status'] = orderStatus;
//     json['cart_id'] = cartId;
//     json['order_creat_at'] = orderCreatAt;
//     json['order_total'] = orderTotal;
//     json['cart'] = cart?.map((e) => e.toJson()).toList();
//     json['salesman'] = salesman?.map((e) => e.toJson()).toList();
//     json['customer'] = customer?.map((e) => e.toJson()).toList();
//     json['invoice'] = invoice?.map((e) => e.toJson()).toList();
//     // json['receivable_amount'] = receivableAmount;
//     return json;
//   }
// }

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
  int? orderTotal;
  int? receivedAmount;
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
        orderTotal: json["order_total"],
        receivedAmount: json["received_amount"],
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
      };
}

class FetchSpecificOrder {
  int? statusCode;
  bool? status;
  String? message;
  FetchSpecificOrderData? data;

  FetchSpecificOrder({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory FetchSpecificOrder.fromJson(Map<String, dynamic> json) =>
      FetchSpecificOrder(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: FetchSpecificOrderData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

class FetchSpecificOrderData {
  int? id;
  String? customerId;
  String? cartId;
  String? fullname;
  String? mobileno;
  String? email;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? businessName;
  String? businessNo;
  String? remark;
  String? imageUrl;
  String? salesmanId;
  int? status;
  String? createAt;
  String? salesmanName;
  String? discount;
  int? eventType;
  String? eventDays;
  int? creditPeriod;
  int? companyId;
  String? orderId;
  int? paymentStatus;
  int? paymentType;
  String? paymentDetail;
  int? orderStatus;
  String? orderCreatAt;
  int? orderTotal;
  int? receivedAmount;
  dynamic receivedAmountDate;
  String? checkDueDate;
  int? checkNumber;
  String? transactionDate;
  String? transactionDetails;
  String? rejectionReason;
  String? rejectedDate;
  int? receivableAmount;
  String? deliveryDatetime;
  List<CartSpecificData>? cart;
  List<OrderInvoice>? invoice;
  List<SpecificTax>? tax;

  FetchSpecificOrderData({
    this.id,
    this.customerId,
    this.cartId,
    this.fullname,
    this.mobileno,
    this.email,
    this.town,
    this.state,
    this.zipcode,
    this.address,
    this.businessName,
    this.businessNo,
    this.remark,
    this.imageUrl,
    this.salesmanId,
    this.status,
    this.createAt,
    this.salesmanName,
    this.discount,
    this.eventType,
    this.eventDays,
    this.creditPeriod,
    this.companyId,
    this.orderId,
    this.paymentStatus,
    this.paymentType,
    this.paymentDetail,
    this.orderStatus,
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
    this.cart,
    this.invoice,
    this.tax,
  });

  factory FetchSpecificOrderData.fromJson(Map<String, dynamic> json) =>
      FetchSpecificOrderData(
        id: json["id"],
        customerId: json["customer_id"],
        cartId: json["cart_id"],
        fullname: json["fullname"],
        mobileno: json["mobileno"],
        email: json["email"],
        town: json["town"],
        state: json["state"],
        zipcode: json["zipcode"],
        address: json["address"],
        businessName: json["business_name"],
        businessNo: json["business_no"],
        remark: json["remark"],
        imageUrl: json["image_url"],
        salesmanId: json["salesman_id"],
        status: json["status"],
        createAt: json["create_at"] != null ? json["create_at"] : '',
        salesmanName: json["salesman_name"],
        discount: json["discount"],
        eventType: json["event_type"],
        eventDays: json["event_days"],
        creditPeriod: json["credit_period"],
        companyId: json["company_id"],
        orderId: json["order_id"],
        paymentStatus: json["payment_status"],
        paymentType: json["payment_type"],
        paymentDetail: json["payment_detail"],
        orderStatus: json["order_status"],
        orderCreatAt:
            json["order_creat_at"] != null ? json["order_creat_at"] : '',
        orderTotal: json["order_total"],
        receivedAmount: json["received_amount"],
        receivedAmountDate: json["received_amount_date"] ?? '',
        checkDueDate:
            json["check_due_date"] != null ? json["check_due_date"] : '',
        checkNumber: json["check_number"] ?? 0,
        transactionDate: json["transaction_date"] ?? '',
        transactionDetails: json["transaction_details"],
        rejectionReason: json["rejection_reason"] ?? '',
        rejectedDate: json["rejected_date"] ?? '',
        receivableAmount: json["receivable_amount"] ?? 0,
        deliveryDatetime: json["delivery_datetime"] != null
            ? json["delivery_datetime"]
            : 'null',
        cart: json["cart"] != null
            ? List<CartSpecificData>.from(
                json["cart"].map((x) => CartSpecificData.fromJson(x)))
            : [],
        invoice: json["invoice"] != null
            ? List<OrderInvoice>.from(
                json["invoice"].map((x) => OrderInvoice.fromJson(x)))
            : [],
        tax: json["tax"] != null
            ? List<SpecificTax>.from(
                json["tax"].map((x) => SpecificTax.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "cart_id": cartId,
        "fullname": fullname,
        "mobileno": mobileno,
        "email": email,
        "town": town,
        "state": state,
        "zipcode": zipcode,
        "address": address,
        "business_name": businessName,
        "business_no": businessNo,
        "remark": remark,
        "image_url": imageUrl,
        "salesman_id": salesmanId,
        "status": status,
        "create_at": createAt,
        "salesman_name": salesmanName,
        "discount": discount,
        "event_type": eventType,
        "event_days": eventDays,
        "credit_period": creditPeriod,
        "company_id": companyId,
        "order_id": orderId,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "order_creat_at": orderCreatAt,
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate,
        "check_due_date": checkDueDate,
        "check_number": checkNumber,
        "transaction_date": transactionDate,
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate,
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime,
        "cart": cart != null
            ? List<dynamic>.from(cart!.map((x) => x.toJson()))
            : [],
        "invoice": invoice != null
            ? List<dynamic>.from(invoice!.map((x) => x.toJson()))
            : [],
        "tax": tax != null
            ? List<dynamic>.from(tax!.map((x) => x.toJson()))
            : [],
      };
}

class CartSpecificData {
  int? id;
  String? cartId;
  String? productId;
  String? variationId;
  String? price;
  String? reason;
  int? quantity;
  int? totalPrice;
  int? status;
  int? orderPlaceStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? variationName;
  String? productName;
  dynamic taxName;
  dynamic tax;

  CartSpecificData({
    this.id,
    this.cartId,
    this.productId,
    this.variationId,
    this.price,
    this.reason,
    this.quantity,
    this.totalPrice,
    this.status,
    this.orderPlaceStatus,
    this.createdAt,
    this.updatedAt,
    this.variationName,
    this.productName,
    this.taxName,
    this.tax,
  });

  factory CartSpecificData.fromJson(Map<String, dynamic> json) =>
      CartSpecificData(
        id: json["id"] as int?,
        cartId: json["cart_id"] as String?,
        productId: json["product_id"] as String?,
        variationId: json["variation_id"] as String?,
        price: json["price"] as String?,
        reason: json["reason"] ?? '',
        quantity: json["quantity"] as int?,
        totalPrice: json["total_price"] as int?,
        status: json["status"] as int?,
        orderPlaceStatus: json["order_place_status"] as int?,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        variationName: json["variation_name"] as String?,
        productName: json["product_name"] as String?,
        taxName: json["tax_name"] != null ? json["tax_name"] : null,
        tax: json["tax"] != null ? json["tax"] : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cart_id": cartId,
        "product_id": productId,
        "variation_id": variationId,
        "price": price,
        "reason": reason,
        "quantity": quantity,
        "total_price": totalPrice,
        "status": status,
        "order_place_status": orderPlaceStatus,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "variation_name": variationName,
        "product_name": productName,
        "tax_name": taxName,
        "tax": tax,
      };
}
