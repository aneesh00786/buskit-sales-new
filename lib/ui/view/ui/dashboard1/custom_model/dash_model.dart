// To parse this JSON data, do
//
//     final dashboardResponse2 = dashboardResponse2FromJson(jsonString);

// ignore_for_file: constant_identifier_names

import 'dart:convert';

DashboardResponse2 dashboardResponse2FromJson(String str) =>
    DashboardResponse2.fromJson(json.decode(str));

String dashboardResponse2ToJson(DashboardResponse2 data) =>
    json.encode(data.toJson());

class DashboardResponse2 {
  int statusCode;
  bool status;
  String message;
  Data data;

  DashboardResponse2({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory DashboardResponse2.fromJson(Map<String, dynamic> json) =>
      DashboardResponse2(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  List<AllCategory> allCategory;
  List<CategoryPerformance> categoryPerformance;
  Revenu revenu;
  Collection collection;
  Delivery delivery;
  List<TopSellingProduct> topSellingProduct;
  OrderCountList orderCountList;

  Data({
    required this.allCategory,
    required this.categoryPerformance,
    required this.revenu,
    required this.collection,
    required this.delivery,
    required this.topSellingProduct,
    required this.orderCountList,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        allCategory: List<AllCategory>.from(
            json["all_category"].map((x) => AllCategory.fromJson(x))),
        categoryPerformance: List<CategoryPerformance>.from(
            json["category_performance"]
                .map((x) => CategoryPerformance.fromJson(x))),
        revenu: Revenu.fromJson(json["revenu"]),
        collection: Collection.fromJson(json["collection"]),
        delivery: Delivery.fromJson(json["delivery"]),
        topSellingProduct: List<TopSellingProduct>.from(
            json["top_selling_product"]
                .map((x) => TopSellingProduct.fromJson(x))),
        orderCountList: OrderCountList.fromJson(json["order_count_list"]),
      );

  Map<String, dynamic> toJson() => {
        "all_category": List<dynamic>.from(allCategory.map((x) => x.toJson())),
        "category_performance":
            List<dynamic>.from(categoryPerformance.map((x) => x.toJson())),
        "revenu": revenu.toJson(),
        "collection": collection.toJson(),
        "delivery": delivery.toJson(),
        "top_selling_product":
            List<dynamic>.from(topSellingProduct.map((x) => x.toJson())),
        "order_count_list": orderCountList.toJson(),
      };
}

class AllCategory {
  String category;

  AllCategory({
    required this.category,
  });

  factory AllCategory.fromJson(Map<String, dynamic> json) => AllCategory(
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
      };
}

class CategoryPerformance {
  SalesmanId salesmanId;
  int cid;
  String category;
  int count;
  String actualProjection;
  List<Salesman> salesman;

  CategoryPerformance({
    required this.salesmanId,
    required this.cid,
    required this.category,
    required this.count,
    required this.actualProjection,
    required this.salesman,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) =>
      CategoryPerformance(
        salesmanId: salesmanIdValues.map[json["salesman_id"]]!,
        cid: json["cid"],
        category: json["category"],
        count: json["count"],
        actualProjection: json["actual_projection"],
        salesman: List<Salesman>.from(
            json["salesman"].map((x) => Salesman.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "salesman_id": salesmanIdValues.reverse[salesmanId],
        "cid": cid,
        "category": category,
        "count": count,
        "actual_projection": actualProjection,
        "salesman": List<dynamic>.from(salesman.map((x) => x.toJson())),
      };
}

class Salesman {
  String fullname;
  String salesmanId;
  int projectionTarget;
  int projectionPrice;
  dynamic actualPrice;

  Salesman({
    required this.fullname,
    required this.salesmanId,
    required this.projectionTarget,
    required this.projectionPrice,
    required this.actualPrice,
  });

  factory Salesman.fromJson(Map<String, dynamic> json) => Salesman(
        fullname: json["fullname"],
        salesmanId: json["salesman_id"],
        projectionTarget: json["projection_target"],
        projectionPrice: json["projection_price"],
        actualPrice: json["actual_price"],
      );

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "salesman_id": salesmanId,
        "projection_target": projectionTarget,
        "projection_price": projectionPrice,
        "actual_price": actualPrice,
      };
}

enum SalesmanId { SALES1, SALES3, SALES6, SALES7 }

final salesmanIdValues = EnumValues({
  "SALES1": SalesmanId.SALES1,
  "SALES3": SalesmanId.SALES3,
  "SALES6": SalesmanId.SALES6,
  "SALES7": SalesmanId.SALES7
});

class Collection {
  CollectionOrder order;
  Payment payment;
  Due due;
  Overdue overdue;

  Collection({
    required this.order,
    required this.payment,
    required this.due,
    required this.overdue,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        order: CollectionOrder.fromJson(json["order"]),
        payment: Payment.fromJson(json["payment"]),
        due: Due.fromJson(json["due"]),
        overdue: Overdue.fromJson(json["overdue"]),
      );

  Map<String, dynamic> toJson() => {
        "order": order.toJson(),
        "payment": payment.toJson(),
        "due": due.toJson(),
        "overdue": overdue.toJson(),
      };
}

class Due {
  List<dynamic> dueAmount;

  Due({
    required this.dueAmount,
  });

  factory Due.fromJson(Map<String, dynamic> json) => Due(
        dueAmount: List<dynamic>.from(json["due_amount"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "due_amount": List<dynamic>.from(dueAmount.map((x) => x)),
      };
}

class CollectionOrder {
  List<PendingAmount> pendingAmount;

  CollectionOrder({
    required this.pendingAmount,
  });

  factory CollectionOrder.fromJson(Map<String, dynamic> json) =>
      CollectionOrder(
        pendingAmount: List<PendingAmount>.from(
            json["pending_amount"].map((x) => PendingAmount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pending_amount":
            List<dynamic>.from(pendingAmount.map((x) => x.toJson())),
      };
}

class PendingAmount {
  int id;
  String orderId;
  String customerId;
  SalesmanId salesmanId;
  int paymentStatus;
  int paymentType;
  String paymentDetail;
  int orderStatus;
  String cartId;
  DateTime orderCreatAt;
  int orderTotal;
  int receivedAmount;
  DateTime? receivedAmountDate;
  DateTime checkDueDate;
  int checkNumber;
  DateTime? transactionDate;
  String transactionDetails;
  int? creditPeriod;
  int? count;
  String? percentage;
  int? amount;
  int? dueAmount;
  int? overDue;
  List<dynamic>? dueDate;
  int? orderProcessing;
  int? packedForDelivery;
  int? deliverd;
  int? outForDelivery;

  PendingAmount({
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
    this.creditPeriod,
    this.count,
    this.percentage,
    this.amount,
    this.dueAmount,
    this.overDue,
    this.dueDate,
    this.orderProcessing,
    this.packedForDelivery,
    this.deliverd,
    this.outForDelivery,
  });

  factory PendingAmount.fromJson(Map<String, dynamic> json) => PendingAmount(
        id: json["id"],
        orderId: json["order_id"],
        customerId: json["customer_id"],
        salesmanId: salesmanIdValues.map[json["salesman_id"]]!,
        paymentStatus: json["payment_status"],
        paymentType: json["payment_type"],
        paymentDetail: json["payment_detail"],
        orderStatus: json["order_status"],
        cartId: json["cart_id"],
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        orderTotal: json["order_total"],
        receivedAmount: json["received_amount"],
        receivedAmountDate: json["received_amount_date"] == null
            ? null
            : DateTime.parse(json["received_amount_date"]),
        checkDueDate: DateTime.parse(json["check_due_date"]),
        checkNumber: json["check_number"],
        transactionDate: json["transaction_date"] == null
            ? null
            : DateTime.parse(json["transaction_date"]),
        transactionDetails: json["transaction_details"],
        creditPeriod: json["credit_period"],
        count: json["count"],
        percentage: json["percentage"],
        amount: json["amount"],
        dueAmount: json["due_amount"],
        overDue: json["over_due"],
        dueDate: json["due_date"] == null
            ? []
            : List<dynamic>.from(json["due_date"]!.map((x) => x)),
        orderProcessing: json["order_processing"],
        packedForDelivery: json["packed_for_delivery"],
        deliverd: json["deliverd"],
        outForDelivery: json["outForDelivery"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "customer_id": customerId,
        "salesman_id": salesmanIdValues.reverse[salesmanId],
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "cart_id": cartId,
        "order_creat_at": orderCreatAt.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate?.toIso8601String(),
        "check_due_date": checkDueDate.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate?.toIso8601String(),
        "transaction_details": transactionDetails,
        "credit_period": creditPeriod,
        "count": count,
        "percentage": percentage,
        "amount": amount,
        "due_amount": dueAmount,
        "over_due": overDue,
        "due_date":
            dueDate == null ? [] : List<dynamic>.from(dueDate!.map((x) => x)),
        "order_processing": orderProcessing,
        "packed_for_delivery": packedForDelivery,
        "deliverd": deliverd,
        "outForDelivery": outForDelivery,
      };
}

class Overdue {
  List<PendingAmount> overdueAmount;

  Overdue({
    required this.overdueAmount,
  });

  factory Overdue.fromJson(Map<String, dynamic> json) => Overdue(
        overdueAmount: List<PendingAmount>.from(
            json["overdue_amount"].map((x) => PendingAmount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "overdue_amount":
            List<dynamic>.from(overdueAmount.map((x) => x.toJson())),
      };
}

class Payment {
  int payedAmount;
  List<PendingAmount> completedOrders;

  Payment({
    required this.payedAmount,
    required this.completedOrders,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        payedAmount: json["payed_amount"],
        completedOrders: List<PendingAmount>.from(
            json["completed_orders"].map((x) => PendingAmount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "payed_amount": payedAmount,
        "completed_orders":
            List<dynamic>.from(completedOrders.map((x) => x.toJson())),
      };
}

class Delivery {
  DeliveryOrder order;
  DeliveryOrderClass deliveryOrder;

  Delivery({
    required this.order,
    required this.deliveryOrder,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
        order: DeliveryOrder.fromJson(json["order"]),
        deliveryOrder: DeliveryOrderClass.fromJson(json["delivery_order"]),
      );

  Map<String, dynamic> toJson() => {
        "order": order.toJson(),
        "delivery_order": deliveryOrder.toJson(),
      };
}

class DeliveryOrderClass {
  int count;
  String percentage;

  DeliveryOrderClass({
    required this.count,
    required this.percentage,
  });

  factory DeliveryOrderClass.fromJson(Map<String, dynamic> json) =>
      DeliveryOrderClass(
        count: json["count"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "percentage": percentage,
      };
}

class DeliveryOrder {
  List<PendingAmount> totalOrders;

  DeliveryOrder({
    required this.totalOrders,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) => DeliveryOrder(
        totalOrders: List<PendingAmount>.from(
            json["total_orders"].map((x) => PendingAmount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_orders": List<dynamic>.from(totalOrders.map((x) => x.toJson())),
      };
}

class OrderCountList {
  int totalOrder;
  int estimateOrder;
  int preorderOrder;
  int draftOrder;
  int cancelOrder;

  OrderCountList({
    required this.totalOrder,
    required this.estimateOrder,
    required this.preorderOrder,
    required this.draftOrder,
    required this.cancelOrder,
  });

  factory OrderCountList.fromJson(Map<String, dynamic> json) => OrderCountList(
        totalOrder: json["total_order"],
        estimateOrder: json["estimate_order"],
        preorderOrder: json["preorder_order"],
        draftOrder: json["draft_order"],
        cancelOrder: json["cancel_order"],
      );

  Map<String, dynamic> toJson() => {
        "total_order": totalOrder,
        "estimate_order": estimateOrder,
        "preorder_order": preorderOrder,
        "draft_order": draftOrder,
        "cancel_order": cancelOrder,
      };
}

class Revenu {
  List<dynamic> bookingRevenueData;
  List<OrderRevenueDatum> orderRevenueData;
  Sell totalSell;
  Sell sell;
  Map<String, int?> order;

  Revenu({
    required this.bookingRevenueData,
    required this.orderRevenueData,
    required this.totalSell,
    required this.sell,
    required this.order,
  });

  factory Revenu.fromJson(Map<String, dynamic> json) => Revenu(
        bookingRevenueData:
            List<dynamic>.from(json["booking_revenueData"].map((x) => x)),
        orderRevenueData: List<OrderRevenueDatum>.from(json["order_revenueData"]
            .map((x) => OrderRevenueDatum.fromJson(x))),
        totalSell: Sell.fromJson(json["total_sell"]),
        sell: Sell.fromJson(json["sell"]),
        order:
            Map.from(json["order"]).map((k, v) => MapEntry<String, int?>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "booking_revenueData":
            List<dynamic>.from(bookingRevenueData.map((x) => x)),
        "order_revenueData":
            List<dynamic>.from(orderRevenueData.map((x) => x.toJson())),
        "total_sell": totalSell.toJson(),
        "sell": sell.toJson(),
        "order": Map.from(order).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class OrderRevenueDatum {
  int id;
  String cartId;
  String customerId;
  SalesmanId salesmanId;
  int total;
  String discount;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  String orderId;
  int paymentStatus;
  int paymentType;
  String paymentDetail;
  int orderStatus;
  DateTime orderCreatAt;
  int orderTotal;
  int receivedAmount;
  DateTime? receivedAmountDate;
  DateTime checkDueDate;
  int checkNumber;
  DateTime transactionDate;
  String transactionDetails;
  int totalOrderRevenue;

  OrderRevenueDatum({
    required this.id,
    required this.cartId,
    required this.customerId,
    required this.salesmanId,
    required this.total,
    required this.discount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.orderId,
    required this.paymentStatus,
    required this.paymentType,
    required this.paymentDetail,
    required this.orderStatus,
    required this.orderCreatAt,
    required this.orderTotal,
    required this.receivedAmount,
    required this.receivedAmountDate,
    required this.checkDueDate,
    required this.checkNumber,
    required this.transactionDate,
    required this.transactionDetails,
    required this.totalOrderRevenue,
  });

  factory OrderRevenueDatum.fromJson(Map<String, dynamic> json) =>
      OrderRevenueDatum(
        id: json["id"],
        cartId: json["cart_id"],
        customerId: json["customer_id"],
        salesmanId: salesmanIdValues.map[json["salesman_id"]]!,
        total: json["total"],
        discount: json["discount"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        orderId: json["order_id"],
        paymentStatus: json["payment_status"],
        paymentType: json["payment_type"],
        paymentDetail: json["payment_detail"],
        orderStatus: json["order_status"],
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        orderTotal: json["order_total"],
        receivedAmount: json["received_amount"],
        receivedAmountDate: json["received_amount_date"] == null
            ? null
            : DateTime.parse(json["received_amount_date"]),
        checkDueDate: DateTime.parse(json["check_due_date"]),
        checkNumber: json["check_number"],
        transactionDate: DateTime.parse(json["transaction_date"]),
        transactionDetails: json["transaction_details"],
        totalOrderRevenue: json["total_order_revenue"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cart_id": cartId,
        "customer_id": customerId,
        "salesman_id": salesmanIdValues.reverse[salesmanId],
        "total": total,
        "discount": discount,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "order_id": orderId,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "order_creat_at": orderCreatAt.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate?.toIso8601String(),
        "check_due_date": checkDueDate.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate.toIso8601String(),
        "transaction_details": transactionDetails,
        "total_order_revenue": totalOrderRevenue,
      };
}

class Sell {
  int count;
  dynamic totalPrice;
  int percentage;

  Sell({
    required this.count,
    required this.totalPrice,
    required this.percentage,
  });

  factory Sell.fromJson(Map<String, dynamic> json) => Sell(
        count: json["count"],
        totalPrice: json["total_price"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "total_price": totalPrice,
        "percentage": percentage,
      };
}

class TopSellingProduct {
  String variationId;
  VariationName variationName;
  String price;
  String quantity;
  String totalPrice;
  DateTime createdAt;
  List<Customer> customer;
  List<QuantityList> quantityList;

  TopSellingProduct({
    required this.variationId,
    required this.variationName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    required this.customer,
    required this.quantityList,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) =>
      TopSellingProduct(
        variationId: json["variation_id"],
        variationName: variationNameValues.map[json["variation_name"]]!,
        price: json["price"],
        quantity: json["quantity"],
        totalPrice: json["total_price"],
        createdAt: DateTime.parse(json["created_at"]),
        customer: List<Customer>.from(
            json["customer"].map((x) => Customer.fromJson(x))),
        quantityList: List<QuantityList>.from(
            json["quantityList"].map((x) => QuantityList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "variation_id": variationId,
        "variation_name": variationNameValues.reverse[variationName],
        "price": price,
        "quantity": quantity,
        "total_price": totalPrice,
        "created_at": createdAt.toIso8601String(),
        "customer": List<dynamic>.from(customer.map((x) => x.toJson())),
        "quantityList": List<dynamic>.from(quantityList.map((x) => x.toJson())),
      };
}

class Customer {
  dynamic cartId;
  String customerId;
  int id;
  String fullname;
  String mobileno;
  String email;
  String town;
  String state;
  int zipcode;
  String address;
  String businessName;
  String businessNo;
  String remark;
  String imageUrl;
  SalesmanId salesmanId;
  int status;
  DateTime createAt;
  SalesmanName salesmanName;
  String discount;
  int eventType;
  EventDays? eventDays;
  int creditPeriod;

  Customer({
    required this.cartId,
    required this.customerId,
    required this.id,
    required this.fullname,
    required this.mobileno,
    required this.email,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    required this.businessName,
    required this.businessNo,
    required this.remark,
    required this.imageUrl,
    required this.salesmanId,
    required this.status,
    required this.createAt,
    required this.salesmanName,
    required this.discount,
    required this.eventType,
    required this.eventDays,
    required this.creditPeriod,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        cartId: json["cart_id"],
        customerId: json["customer_id"],
        id: json["id"],
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
        salesmanId: salesmanIdValues.map[json["salesman_id"]]!,
        status: json["status"],
        createAt: DateTime.parse(json["create_at"]),
        salesmanName: salesmanNameValues.map[json["salesman_name"]]!,
        discount: json["discount"],
        eventType: json["event_type"],
        eventDays: eventDaysValues.map[json["event_days"]]!,
        creditPeriod: json["credit_period"],
      );

  Map<String, dynamic> toJson() => {
        "cart_id": cartId,
        "customer_id": customerId,
        "id": id,
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
        "salesman_id": salesmanIdValues.reverse[salesmanId],
        "status": status,
        "create_at": createAt.toIso8601String(),
        "salesman_name": salesmanNameValues.reverse[salesmanName],
        "discount": discount,
        "event_type": eventType,
        "event_days": eventDaysValues.reverse[eventDays],
        "credit_period": creditPeriod,
      };
}

enum EventDays { EMPTY, FRIDAY, MONDAY }

final eventDaysValues = EnumValues({
  "[]": EventDays.EMPTY,
  "[\"friday\"]": EventDays.FRIDAY,
  "[\"monday\"]": EventDays.MONDAY
});

enum SalesmanName { B, N, RP, SALES6 }

final salesmanNameValues = EnumValues({
  "B": SalesmanName.B,
  "N": SalesmanName.N,
  "RP": SalesmanName.RP,
  "SALES6": SalesmanName.SALES6
});

class QuantityList {
  VariationName variationName;
  int quantity;
  DateTime createdAt;

  QuantityList({
    required this.variationName,
    required this.quantity,
    required this.createdAt,
  });

  factory QuantityList.fromJson(Map<String, dynamic> json) => QuantityList(
        variationName: variationNameValues.map[json["variation_name"]]!,
        quantity: json["quantity"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "variation_name": variationNameValues.reverse[variationName],
        "quantity": quantity,
        "created_at": createdAt.toIso8601String(),
      };
}

enum VariationName { LENOVO_THINK_PAD, NEMMM }

final variationNameValues = EnumValues({
  "Lenovo Think Pad": VariationName.LENOVO_THINK_PAD,
  "Nemmm": VariationName.NEMMM
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
