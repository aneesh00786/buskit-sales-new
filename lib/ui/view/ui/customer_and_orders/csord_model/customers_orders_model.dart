import 'dart:convert';

import '../../dashboard1/provider/dash_models.dart';

CustomerResponseModelxx customerResponseModelFromJson(String str) =>
    CustomerResponseModelxx.fromJson(json.decode(str));

String customerResponseModelToJson(CustomerResponseModelxx data) =>
    json.encode(data.toJson());

class CustomerResponseModelxx {
  final int statusCode;
  final bool status;
  final String message;
  final Paginationxx pagination;
  final List<CustomerModelxx> data;
  final List<OrderTotalxx> orderTotal;
  final List<YearsListOfAll> yearsListOfAll;

  CustomerResponseModelxx({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.pagination,
    required this.data,
    required this.orderTotal,
    required this.yearsListOfAll,
  });

  factory CustomerResponseModelxx.fromJson(Map<String, dynamic> json) =>
      CustomerResponseModelxx(
        statusCode: json['statusCode'] ?? 0,
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        pagination: Paginationxx.fromJson(
            json['pagination'] ?? {}),
        data: List<CustomerModelxx>.from(
            (json['data'] ?? []).map((x) => CustomerModelxx.fromJson(x))),
        orderTotal: List<OrderTotalxx>.from(
            (json['orderTotal'] ?? []).map((x) => OrderTotalxx.fromJson(x))),
        yearsListOfAll: List<YearsListOfAll>.from(
            (json['years_list_of_all'] ?? []).map((x) => YearsListOfAll.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'status': status,
        'message': message,
        'pagination': pagination.toJson(),
        'data': data.map((x) => x.toJson()).toList(),
        'orderTotal': orderTotal.map((x) => x.toJson()).toList(),
        "years_list_of_all": yearsListOfAll.map((x) => x.toJson()).toList(),
      };
}

class CustomerModelxx {
  final int id;
  final String customerId;
  final String cartId;
  final String fullname;
  final String mobileno;
  final String email;
  final String town;
  final String state;
  final int zipcode;
  final String address;
  final String businessName;
  final String businessNo;
  final String remark;
  final String imageUrl;
  final String salesmanId;
  final int status;
  final DateTime createdAt;
  final String salesmanName;
  final String discount;
  final int eventType;
  final List<String> eventDays;
  final List<CreditPeriodxx> creditPeriod;
  final int companyId;
  final num? previousYearSales;
  final num? totalSales;
  final num sales;
  final num? salesPrice;
  final num delivery;
  final num? deliveryPrice;
  final num payment;
  final num? paymentPrice;
  final num estimates;
  final num? estimatesPrice;
  final num preOrder;
  final num? preOrderPrice;
  final num drafts;
  final num cancelled;
  final List<Salesmanxx> salesman;
  final OrderDataxx orderData;

  CustomerModelxx({
    required this.id,
    required this.customerId,
    required this.cartId,
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
    required this.createdAt,
    required this.salesmanName,
    required this.discount,
    required this.eventType,
    required this.eventDays,
    required this.creditPeriod,
    required this.companyId,
    required this.previousYearSales,
    required this.totalSales,
    required this.sales,
    required this.salesPrice,
    required this.delivery,
    required this.deliveryPrice,
    required this.payment,
    required this.paymentPrice,
    required this.estimates,
    required this.estimatesPrice,
    required this.preOrder,
    required this.preOrderPrice,
    required this.drafts,
    required this.cancelled,
    required this.salesman,
    required this.orderData,
  });

  factory CustomerModelxx.fromJson(Map<String, dynamic> json) {
    return CustomerModelxx(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? '',
      cartId: json['cart_id'] ?? '',
      fullname: json['fullname'] ?? '',
      mobileno: json['mobileno'] ?? '',
      email: json['email'] ?? '',
      town: json['town'] ?? '',
      state: json['state'] ?? '',
      zipcode: json['zipcode'] ?? 0,
      address: json['address'] ?? '',
      businessName: json['business_name'] ?? '',
      businessNo: json['business_no'] ?? '',
      remark: json['remark'] ?? '',
      imageUrl: json['image_url'] ?? '',
      salesmanId: json['salesman_id'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['create_at'] ?? '') ?? DateTime.now(),
      salesmanName: json['salesman_name'] ?? '',
      discount: json['discount'] ?? '',
      eventType: json['event_type'] ?? 0,
      eventDays: _parseEventDays(json['event_days']),
      creditPeriod: List<CreditPeriodxx>.from(
          (json['credit_period'] ?? []).map((x) => CreditPeriodxx.fromJson(x))),
      companyId: json['company_id'] ?? 0,
      previousYearSales: json['previous_year_sales'],
      totalSales: json['total_sales'],
      sales: json['sales'] ?? 0,
      salesPrice: _parseToInt(json['sales_price']),
      delivery: json['delivery'] ?? 0,
      deliveryPrice: json['delivery_price'],
      payment: json['payment'] ?? 0,
      paymentPrice: json['payment_price'],
      estimates: json['estimates'] ?? 0,
      estimatesPrice: json['estimates_price'],
      preOrder: json['pre_order'] ?? 0,
      preOrderPrice: json['pre_order_price'],
      drafts: json['drafts'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      salesman: List<Salesmanxx>.from(
          (json['salesman'] ?? []).map((x) => Salesmanxx.fromJson(x))),
      orderData: OrderDataxx.fromJson(json['order_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'cart_id': cartId,
        'fullname': fullname,
        'mobileno': mobileno,
        'email': email,
        'town': town,
        'state': state,
        'zipcode': zipcode,
        'address': address,
        'business_name': businessName,
        'business_no': businessNo,
        'remark': remark,
        'image_url': imageUrl,
        'salesman_id': salesmanId,
        'status': status,
        'create_at': createdAt.toIso8601String(),
        'salesman_name': salesmanName,
        'discount': discount,
        'event_type': eventType,
        'event_days': jsonEncode(eventDays),
        'credit_period': creditPeriod.map((x) => x.toJson()).toList(),
        'company_id': companyId,
        'previous_year_sales': previousYearSales,
        'total_sales': totalSales,
        'sales': sales,
        'sales_price': salesPrice,
        'delivery': delivery,
        'delivery_price': deliveryPrice,
        'payment': payment,
        'payment_price': paymentPrice,
        'estimates': estimates,
        'estimates_price': estimatesPrice,
        'pre_order': preOrder,
        'pre_order_price': preOrderPrice,
        'drafts': drafts,
        'cancelled': cancelled,
        'salesman': salesman.map((x) => x.toJson()).toList(),
        'order_data': orderData.toJson(),
      };

  static int? _parseToInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  static List<String> _parseEventDays(dynamic eventDaysJson) {
    if (eventDaysJson is String) {
      // If it's a string, handle it
      if (eventDaysJson.startsWith('[') && eventDaysJson.endsWith(']')) {
        // Remove outer quotes if present
        final cleanedString =
            eventDaysJson.substring(1, eventDaysJson.length - 1);
        // Split by comma and trim spaces
        return cleanedString
            .split(',')
            .map((day) => day.trim().replaceAll('"', ''))
            .toList();
      }
    } else if (eventDaysJson is List) {
      return List<String>.from(eventDaysJson);
    }
    return [];
  }
}

class CreditPeriodxx {
  final int creditPeriod;

  CreditPeriodxx({
    required this.creditPeriod,
  });

  factory CreditPeriodxx.fromJson(Map<String, dynamic> json) => CreditPeriodxx(
        creditPeriod: json["credit_period"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "credit_period": creditPeriod,
      };
}

class Salesmanxx {
  final int id;
  final String salesmanId;
  final String fullname;
  final String mobileno;
  final String email;
  final String password;
  final String town;
  final String state;
  final int zipcode;
  final String address;
  final String idimagePath;
  final String imagePath;
  final DateTime createAt;
  final String token;
  final String events;
  final int schedule;
  final String creditPoint;
  final String cancelEventReason;
  final String campaignData;
  final int tips;

  Salesmanxx({
    required this.id,
    required this.salesmanId,
    required this.fullname,
    required this.mobileno,
    required this.email,
    required this.password,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    required this.idimagePath,
    required this.imagePath,
    required this.createAt,
    required this.token,
    required this.events,
    required this.schedule,
    required this.creditPoint,
    required this.cancelEventReason,
    required this.campaignData,
    required this.tips,
  });

  factory Salesmanxx.fromJson(Map<String, dynamic> json) => Salesmanxx(
        id: json["id"] ?? 0,
        salesmanId: json["salesman_id"] ?? '',
        fullname: json["fullname"] ?? '',
        mobileno: json["mobileno"] ?? '',
        email: json["email"] ?? '',
        password: json["password"] ?? '',
        town: json["town"] ?? '',
        state: json["state"] ?? '',
        zipcode: json["zipcode"] ?? 0,
        address: json["address"] ?? '',
        idimagePath: json["idimage_path"] ?? '',
        imagePath: json["image_path"] ?? '',
        createAt: DateTime.tryParse(json["create_at"] ?? '') ?? DateTime.now(),
        token: json["token"] ?? '',
        events: json["events"] ?? '',
        schedule: json["schedule"] ?? 0,
        creditPoint: json["credit_point"] ?? '',
        cancelEventReason: json["cancel_event_reason"] ?? '',
        campaignData: json["campaign_data"] ?? '',
        tips: json["tips"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "salesman_id": salesmanId,
        "fullname": fullname,
        "mobileno": mobileno,
        "email": email,
        "password": password,
        "town": town,
        "state": state,
        "zipcode": zipcode,
        "address": address,
        "idimage_path": idimagePath,
        "image_path": imagePath,
        "create_at": createAt.toIso8601String(),
        "token": token,
        "events": events,
        "schedule": schedule,
        "credit_point": creditPoint,
        "cancel_event_reason": cancelEventReason,
        "campaign_data": campaignData,
        "tips": tips,
      };
}

class OrderDataxx {
  final List<Order> totalSales;
  final List<Order> preOrder;
  final List<Order> outOfDiviery;
  final List<Order> cancel;
  final List<Order> draft;
  final List<Order> estimate;
  final List<Order> payment;
  final List<Order> deliver;
  final List<Order> previousYearSales;

  OrderDataxx({
    required this.totalSales,
    required this.preOrder,
    required this.outOfDiviery,
    required this.cancel,
    required this.draft,
    required this.estimate,
    required this.payment,
    required this.deliver,
    required this.previousYearSales,
  });

  factory OrderDataxx.fromJson(Map<String, dynamic> json) => OrderDataxx(
        totalSales: (json['total_sales'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        preOrder: (json['pre_order'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        outOfDiviery: (json['out_of_diviery'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        cancel: (json['cancel'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        draft: (json['draft'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        estimate: (json['estimate'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        payment: (json['payment'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        deliver: (json['deliver'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
        previousYearSales: (json['previous_year_sales'] as List<dynamic>?)
                ?.map((item) => Order.fromJson(item))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'total_sales': totalSales.map((order) => order.toJson()).toList(),
        'pre_order': preOrder.map((order) => order.toJson()).toList(),
        'out_of_diviery': outOfDiviery.map((order) => order.toJson()).toList(),
        'cancel': cancel.map((order) => order.toJson()).toList(),
        'draft': draft.map((order) => order.toJson()).toList(),
        'estimate': estimate.map((order) => order.toJson()).toList(),
        'payment': payment.map((order) => order.toJson()).toList(),
        'deliver': deliver.map((order) => order.toJson()).toList(),
        'previous_year_sales':
            previousYearSales.map((order) => order.toJson()).toList(),
      };
}

class Order {
  final int id;
  final String orderId;
  final String customerId;
  final String salesmanId;
  final int paymentStatus;
  final int paymentType;
  final String paymentDetail;
  final int orderStatus;
  final String cartId;
  final DateTime orderCreatAt;
  final num orderTotal;
  final int receivedAmount;
  final DateTime? receivedAmountDate;
  final DateTime? checkDueDate;
  final DateTime? deliveryDate;
  final int? checkNumber;
  final DateTime? transactionDate;
  final String transactionDetails;
  final String? fullname;
  final String? lastname;
  final String? email;
  final String? mobileNo;
  final String? imageUrl;
  final String? invoiceId;
  // final List<InvoiceDash> invoice;

  Order({
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
    this.receivedAmountDate,
    this.checkDueDate,
    this.deliveryDate,
    this.checkNumber,
    this.transactionDate,
    required this.transactionDetails,
    this.fullname,
    this.lastname,
    this.email,
    this.mobileNo,
    this.imageUrl,
    this.invoiceId,
    // required this.invoice,
    // this.receivableAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] ?? 0,
        orderId: json['order_id'] ?? '',
        customerId: json['customer_id'] ?? '',
        salesmanId: json['salesman_id'] ?? '',
        paymentStatus: json['payment_status'] ?? 0,
        paymentType: json['payment_type'] ?? 0,
        paymentDetail: json['payment_detail'] ?? '',
        orderStatus: json['order_status'] ?? 0,
        cartId: json['cart_id'] ?? '',
        orderCreatAt: DateTime.parse(
            json['order_creat_at'] ?? DateTime.now().toIso8601String()),
        orderTotal: json['order_total'] ?? 0,
        receivedAmount: json['received_amount'] ?? 0,
        receivedAmountDate: json['received_amount_date'] != null
            ? DateTime.parse(json['received_amount_date'])
            : null,
        checkDueDate: json['check_due_date'] != null
            ? DateTime.parse(json['check_due_date'])
            : null,
        deliveryDate: json['delivery_datetime'] != null
            ? DateTime.parse(json['delivery_datetime'])
            : null,
        checkNumber: json['check_number'] ?? 0,
        transactionDate: json['transaction_date'] != null
            ? DateTime.parse(json['transaction_date'])
            : null,
        transactionDetails: json['transaction_details'] ?? '',
        fullname: json['fullname'] ?? '',
        lastname: json['lastname'] ?? '',
        email: json['email'] ?? '',
        mobileNo: json['mobileno'] ?? '',
        imageUrl: json['image_url'] ?? '',
        invoiceId: json['invoice_id'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'customer_id': customerId,
        'salesman_id': salesmanId,
        'payment_status': paymentStatus,
        'payment_type': paymentType,
        'payment_detail': paymentDetail,
        'order_status': orderStatus,
        'cart_id': cartId,
        'order_creat_at': orderCreatAt.toIso8601String(),
        'order_total': orderTotal,
        'received_amount': receivedAmount,
        'received_amount_date': receivedAmountDate?.toIso8601String(),
        'check_due_date': checkDueDate?.toIso8601String(),
        'delivery_datetime': deliveryDate?.toIso8601String(),
        'check_number': checkNumber,
        'transaction_date': transactionDate?.toIso8601String(),
        'transaction_details': transactionDetails,
        'fullname': fullname,
        'lastname': lastname,
        'invoice_id': invoiceId,
        'email': email,
        'image_url': imageUrl,
        'mobileno': mobileNo,

        // 'receivable_amount': receivableAmount,
      };
}
class Paginationxx {
  Paginationxx({
    required this.nextPage,
    required this.prevPage,
    required this.limit,
    required this.totalRecords,
    required this.totalPages,
  });

  final int nextPage;
  final int prevPage;
  final int limit;
  final int totalRecords;
  final int totalPages;

  factory Paginationxx.fromJson(Map<String, dynamic> json) => Paginationxx(
        nextPage: json["next_page"] ?? 0,
        prevPage: json["prev_page"] ?? 0,
        limit: json["limit"] ?? 0,
        totalRecords: json["total_records"] ?? 0,
        totalPages: json["total_pages"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "next_page": nextPage,
        "prev_page": prevPage,
        "limit": limit,
        "total_records": totalRecords,
        "total_pages": totalPages,
      };
}

class OrderTotalxx {
  String? sales;
  String? delivery;
  String? payment;
  String? estimate;
  String? preOrder;
  String? draft;
  String? cancelled;
  String? previousYearSale;


  OrderTotalxx({
    this.sales,
    this.delivery,
    this.payment,
    this.estimate,
    this.preOrder,
    this.draft,
    this.cancelled,
    this.previousYearSale,
  });

  // Factory constructor to create an instance from a JSON map
  factory OrderTotalxx.fromJson(Map<String, dynamic> json) {
    return OrderTotalxx(
      sales: json['sales'] != null ? json['sales'] as String? : '',
      delivery: json['delivery'] != null ? json['delivery'] as String? : '',
      payment: json['payment'] != null ? json['payment'] as String? : '',
      estimate: json['estimate'] != null ? json['estimate'] as String? : '',
      preOrder: json['preOrder'] != null ? json['preOrder'] as String? : '',
      draft: json['draft'] != null ? json['draft'] as String? : '',
      cancelled: json['cancelled'] != null ? json['cancelled'] as String? : '',
      previousYearSale: json['previous_year_sale_price'] != null ? json['previous_year_sale_price'] as String? : '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'sales': sales,
      'delivery': delivery,
      'payment': payment,
      'estimate': estimate,
      'preOrder': preOrder,
      'draft': draft,
      'cancelled': cancelled,
      'previous_year_sale_price': previousYearSale,
    };
  }
}

class YearsListOfAll {
  dynamic orderYears;

  YearsListOfAll({
    this.orderYears,
  });

  factory YearsListOfAll.fromJson(Map<String, dynamic> json) => YearsListOfAll(
        orderYears: json["order_years"],
      );

  Map<String, dynamic> toJson() => {
        "order_years": orderYears,
      };
}


class ApiResponseModel {
  final int statusCode;
  final bool status;
  final String message;
  final Data data;

  ApiResponseModel({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      statusCode: json['status_code'],
      status: json['status'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  final List<CategoryPerformancez> categoryPerformance;
  final List<RecentOrder> recentOrders;
  final List<FrequantliyProductList> frequentProductLists;
  final List<YearList> yearList;
  final List<FullCategory> fullCategory;

  Data({
    required this.categoryPerformance,
    required this.recentOrders,
    required this.frequentProductLists,
    required this.yearList,
    required this.fullCategory,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      categoryPerformance: (json['category_performance'] as List)
          .map((i) => CategoryPerformancez.fromJson(i))
          .toList(),
      recentOrders: (json['recent_orders'] as List)
          .map((i) => RecentOrder.fromJson(i))
          .toList(),
      frequentProductLists: (json['frequantliy_product_lists'] as List)
          .map((i) => FrequantliyProductList.fromJson(i))
          .toList(),
      yearList:
          (json['year_list'] as List).map((i) => YearList.fromJson(i)).toList(),
      fullCategory: (json['fullCategotry'] as List)
          .map((i) => FullCategory.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_performance':
          categoryPerformance.map((e) => e.toJson()).toList(),
      'recent_orders': recentOrders.map((e) => e.toJson()).toList(),
      'frequantliy_product_lists':
          frequentProductLists.map((e) => e.toJson()).toList(),
      'year_list': yearList.map((e) => e.toJson()).toList(),
      'full_category': fullCategory.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryPerformancez {
  int cid;
  String category;
  String totalPrice;

  CategoryPerformancez({
    required this.cid,
    required this.category,
    required this.totalPrice,
  });

  factory CategoryPerformancez.fromJson(Map<String, dynamic> json) =>
      CategoryPerformancez(
        cid: json["cid"] ?? 0,
        category: json["category"] ?? '',
        totalPrice: (json["total_price"] is int)
            ? json["total_price"].toString()
            : json["total_price"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "cid": cid,
        "category": category,
        "total_price": totalPrice,
      };
}

class RecentOrder {
  final int paymentType;
  final int creditPeriod;
  final int receivedAmount;
  final String? receivedAmountDate; // This can remain nullable
  final String orderId;
  final String orderCreatAt;
  final num orderTotal;
  final int orderStatus;
  final int paymentStatus;
  final String customerId;
  List<dynamic>? duedate;
  // final int? receivableAmount;

  RecentOrder({
    required this.paymentType,
    required this.creditPeriod,
    required this.receivedAmount,
    this.receivedAmountDate, // Nullable
    required this.orderId,
    required this.orderCreatAt,
    required this.orderTotal,
    required this.orderStatus,
    required this.paymentStatus,
    required this.customerId,
    this.duedate,
    // this.receivableAmount, // Nullable
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      paymentType: json['payment_type'] as int,
      creditPeriod: json['credit_period'] as int,
      receivedAmount: json['received_amount'] as int,
      receivedAmountDate: json['received_amount_date'] as String?,
      orderId: json['order_id'] as String,
      orderCreatAt: json['order_creat_at'] as String,
      orderTotal: json['order_total'] as int,
      orderStatus: json['order_status'] as int,
      paymentStatus: json['payment_status'] as int,
      customerId: json['customer_id'] as String,
      duedate: List<dynamic>.from(json["duedate"].map((x) => x)),
      // receivableAmount: json['receivable_amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_type': paymentType,
      'credit_period': creditPeriod,
      'received_amount': receivedAmount,
      'received_amount_date': receivedAmountDate,
      'order_id': orderId,
      'order_creat_at': orderCreatAt,
      'order_total': orderTotal,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'customer_id': customerId,
      "duedate": List<dynamic>.from(duedate!.map((x) => x)),
      // 'receivable_amount': receivableAmount,
    };
  }
}

class FrequantliyProductList {
  final String cartId;
  final String variationId;
  final String variationName;
  final double price;
  final int quantity;
  final double totalPrice;
  final String productName;
  final String inNo;
  final DateTime createdAt;
  final List<QuantityList> quantityList;
  final List<Count> count;

  FrequantliyProductList(
      {required this.cartId,
      required this.variationId,
      required this.variationName,
      required this.price,
      required this.quantity,
      required this.totalPrice,
      required this.productName,
      required this.inNo,
      required this.createdAt,
      required this.quantityList,
      required this.count});

  factory FrequantliyProductList.fromJson(Map<String, dynamic> json) {
    return FrequantliyProductList(
      cartId: json['cart_id'] ?? "",
      variationId: json['variation_id'] ?? "",
      variationName: json['variation_name'] ?? "",
      price: double.parse(json['price'] ?? "0"),
      quantity: int.parse(json['quantity'] ?? "0"),
      totalPrice: double.parse(json['total_price'] ?? "0"),
      productName: json["product_name"] ?? "",
      inNo: json["in_no"] ?? "",
      createdAt: DateTime.parse(json["created_at"]),
      quantityList: (json['quantityList'] as List<dynamic>)
          .map((e) => QuantityList.fromJson(e))
          .toList(),
      count: (json['count'] as List<dynamic>)
          .map((e) => Count.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cart_id": cartId,
      "variation_id": variationId,
      "variation_name": variationName,
      "price": price,
      "quantity": quantity,
      "total_price": totalPrice,
      "product_name": productName,
      "in_no": inNo,
      "created_at": createdAt.toIso8601String(),
      'quantityList':
          quantityList.map((customer) => customer.toJson()).toList(),
      'count': count.map((customer) => customer.toJson()).toList(),
    };
  }
}

class Customer {
  final String cartId;
  final String customerId;
  final int id;
  final String fullName;
  final String mobileNo;
  final String email;
  final String town;
  final String state;
  final int zipCode;
  final String address;
  final String businessName;
  final String businessNo;
  final String remark;
  final String imageUrl;
  final String salesmanId;
  final int status;
  final DateTime createAt;
  final String salesmanName;
  final String discount;
  final int eventType;
  final List<String> eventDays;
  final int creditPeriod;
  final int companyId;

  Customer({
    required this.cartId,
    required this.customerId,
    required this.id,
    required this.fullName,
    required this.mobileNo,
    required this.email,
    required this.town,
    required this.state,
    required this.zipCode,
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
    required this.companyId,
  });
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cartId: json['cart_id'] ?? "",
      customerId: json['customer_id'] ?? "",
      id: json['id'] ?? 0,
      fullName: json['fullname'] ?? "",
      mobileNo: json['mobileno'] ?? "",
      email: json['email'] ?? "",
      town: json['town'] ?? "",
      state: json['state'] ?? "",
      zipCode: json['zipcode'] ?? 0,
      address: json['address'] ?? "",
      businessName: json['business_name'] ?? "",
      businessNo: json['business_no'] ?? "",
      remark: json['remark'] ?? "",
      imageUrl: json['image_url'] ?? "",
      salesmanId: json['salesman_id'] ?? "",
      status: json['status'] ?? 0,
      createAt: DateTime.parse(json['create_at'] ?? ""),
      salesmanName: json['salesman_name'] ?? "",
      discount: json['discount'] ?? "",
      eventType: json['event_type'] ?? 0,
      eventDays: _parseEventDays(json['event_days']),
      creditPeriod: json['credit_period'] ?? 0,
      companyId: json['company_id'] ?? 0,
    );
  }

  static List<String> _parseEventDays(dynamic eventDaysJson) {
    if (eventDaysJson is String) {
      // If it's a string, handle it
      if (eventDaysJson.startsWith('[') && eventDaysJson.endsWith(']')) {
        // Remove outer quotes if present
        final cleanedString =
            eventDaysJson.substring(1, eventDaysJson.length - 1);
        // Split by comma and trim spaces
        return cleanedString
            .split(',')
            .map((day) => day.trim().replaceAll('"', ''))
            .toList();
      }
    } else if (eventDaysJson is List) {
      return List<String>.from(eventDaysJson);
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'customer_id': customerId,
      'id': id,
      'fullname': fullName,
      'mobileno': mobileNo,
      'email': email,
      'town': town,
      'state': state,
      'zipcode': zipCode,
      'address': address,
      'business_name': businessName,
      'business_no': businessNo,
      'remark': remark,
      'image_url': imageUrl,
      'salesman_id': salesmanId,
      'status': status,
      'create_at': createAt.toIso8601String(),
      'salesman_name': salesmanName,
      'discount': discount,
      'event_type': eventType,
      'event_days': jsonEncode(eventDays),
      'credit_period': creditPeriod,
      'company_id': companyId,
    };
  }
}

class QuantityList {
  int id;
  String cartId;
  String productId;
  String variationId;
  String price;
  String? reason;
  int quantity;
  String totalPrice;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  String customerId;
  String salesmanId;
  int total;
  String discount;
  String variationName;
  String unitType;
  String tax;
  String packtype;
  int pieces;
  int stock;
  int lowstock;
  int fullstock;
  String imageUrl;
  String vprice;

  QuantityList({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.variationId,
    required this.price,
    required this.reason,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    required this.salesmanId,
    required this.total,
    required this.discount,
    required this.variationName,
    required this.unitType,
    required this.tax,
    required this.packtype,
    required this.pieces,
    required this.stock,
    required this.lowstock,
    required this.fullstock,
    required this.imageUrl,
    required this.vprice,
  });

  factory QuantityList.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      return value is int ? value : int.tryParse(value.toString()) ?? 0;
    }

    String parseString(dynamic value) {
      return value?.toString() ?? '';
    }

    return QuantityList(
      id: parseInt(json["id"]),
      cartId: parseString(json["cart_id"]),
      productId: parseString(json["product_id"]),
      variationId: parseString(json["variation_id"]),
      price: parseString(json["price"]),
      reason: json["reason"],
      quantity: parseInt(json["quantity"]),
      totalPrice: parseString(json["total_price"]),
      status: parseInt(json["status"]),
      createdAt: DateTime.parse(
          json["created_at"] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json["updated_at"] ?? DateTime.now().toIso8601String()),
      customerId: parseString(json["customer_id"]),
      salesmanId: parseString(json["salesman_id"]),
      total: parseInt(json["total"]),
      discount: parseString(json["discount"]),
      variationName: parseString(json["variation_name"]),
      unitType: parseString(json["unitType"]),
      tax: parseString(json["tax"]),
      packtype: parseString(json["packtype"]),
      pieces: parseInt(json["pieces"]),
      stock: parseInt(json["stock"]),
      lowstock: parseInt(json["lowstock"]),
      fullstock: parseInt(json["fullstock"]),
      imageUrl: parseString(json["image_url"]),
      vprice: parseString(json["vprice"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cart_id": cartId,
      "product_id": productId,
      "variation_id": variationId,
      "price": price,
      "reason": reason,
      "quantity": quantity,
      "total_price": totalPrice,
      "status": status,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "customer_id": customerId,
      "salesman_id": salesmanId,
      "total": total,
      "discount": discount,
      "variation_name": variationName,
      "unitType": unitType,
      "tax": tax,
      "packtype": packtype,
      "pieces": pieces,
      "stock": stock,
      "lowstock": lowstock,
      "fullstock": fullstock,
      "image_url": imageUrl,
      "vprice": vprice,
    };
  }
}

class Count {
  String cartId;
  String price;
  int quantity;
  String totalPrice;
  DateTime createdAt;

  Count({
    required this.cartId,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Count.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) {
      return value?.toString() ?? '';
    }

    int parseInt(dynamic value) {
      return value is int ? value : int.tryParse(value.toString()) ?? 0;
    }

    return Count(
      cartId: parseString(json["cart_id"]),
      price: parseString(json["price"]),
      quantity: parseInt(json["quantity"]),
      totalPrice: parseString(json["total_price"]),
      createdAt: DateTime.parse(
          json["created_at"] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
      "total_price": totalPrice,
      "created_at": createdAt.toIso8601String(),
    };
  }
}

class YearList {
  final int year;

  YearList({required this.year});

  factory YearList.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      return value is int ? value : int.tryParse(value.toString()) ?? 0;
    }

    return YearList(
      year: parseInt(json['year']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
    };
  }
}

class FullCategory {
  final String categoryName;

  FullCategory({required this.categoryName});

  factory FullCategory.fromJson(Map<String, dynamic> json) {
    return FullCategory(
      categoryName: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
    };
  }
}

class CustomerTotalSaleResponse {
  final int statusCode;
  final bool status;
  final String message;
  final Datas data;

  CustomerTotalSaleResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerTotalSaleResponse.fromJson(Map<String, dynamic> json) {
    return CustomerTotalSaleResponse(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: Datas.fromJson(json['data'] ?? {}),
    );
  }
}

class Datas {
  final TotalSale totalSale;
  final List<DiscountData> discountData;

  Datas({
    required this.totalSale,
    required this.discountData,
  });

  factory Datas.fromJson(Map<String, dynamic> json) {
    var discountDataList = json['discount_data'] as List? ?? [];
    List<DiscountData> discountData =
        discountDataList.map((i) => DiscountData.fromJson(i)).toList();

    return Datas(
      totalSale: TotalSale.fromJson(json['total_sale'] ?? {}),
      discountData: discountData,
    );
  }
}

class TotalSale {
  final PaymentCompleted paymentCompleted;
  final PaymentRemaining paymentRemaining;

  TotalSale({
    required this.paymentCompleted,
    required this.paymentRemaining,
  });

  factory TotalSale.fromJson(Map<String, dynamic> json) {
    return TotalSale(
      paymentCompleted:
          PaymentCompleted.fromJson(json['payment_completed'] ?? {}),
      paymentRemaining:
          PaymentRemaining.fromJson(json['payment_remaning'] ?? {}),
    );
  }
}

class PaymentCompleted {
  final int count;
  final int percentage;
  final List<OrderDetail> orderDetails;
  final String totalAmount;

  PaymentCompleted({
    required this.count,
    required this.percentage,
    required this.orderDetails,
    required this.totalAmount,
  });

  factory PaymentCompleted.fromJson(Map<String, dynamic> json) {
    var orderDetailsList = json['order_details'] as List? ?? [];
    List<OrderDetail> orderDetails =
        orderDetailsList.map((i) => OrderDetail.fromJson(i)).toList();

    return PaymentCompleted(
      count: json['count'] ?? 0,
      percentage: json['percentage'] ?? 0,
      orderDetails: orderDetails,
      totalAmount: json['total_amount'] ?? '',
    );
  }
}

class PaymentRemaining {
  final int count;
  final int percentage;
  final List<OrderDetail> orderUncompleteDetails;
  final int totalAmount;

  PaymentRemaining({
    required this.count,
    required this.percentage,
    required this.orderUncompleteDetails,
    required this.totalAmount,
  });

  factory PaymentRemaining.fromJson(Map<String, dynamic> json) {
    var orderUncompleteDetailsList =
        json['orderuncomplete_details'] as List? ?? [];
    List<OrderDetail> orderUncompleteDetails =
        orderUncompleteDetailsList.map((i) => OrderDetail.fromJson(i)).toList();

    return PaymentRemaining(
      count: json['count'] ?? 0,
      percentage: json['percentage'] ?? 0,
      orderUncompleteDetails: orderUncompleteDetails,
      totalAmount: json['total_amount'] ?? 0,
    );
  }
}

class OrderDetail {
  final int id;
  final String orderId;
  final String customerId;
  final String salesmanId;
  final int paymentStatus;
  final int paymentType;
  final String paymentDetail;
  final int orderStatus;
  final String cartId;
  final String orderCreatAt;
  final num orderTotal;
  final num receivedAmount;
  final String receivedAmountDate;
  final String checkDueDate;
  final int checkNumber;
  final String transactionDate;
  final String transactionDetails;
  // final int receivableAmount;

  OrderDetail({
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
    // required this.receivableAmount,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      salesmanId: json['salesman_id'] ?? '',
      paymentStatus: json['payment_status'] ?? 0,
      paymentType: json['payment_type'] ?? 0,
      paymentDetail: json['payment_detail'] ?? '',
      orderStatus: json['order_status'] ?? 0,
      cartId: json['cart_id'] ?? '',
      orderCreatAt: json['order_creat_at'] ?? '',
      orderTotal: num.tryParse(json['order_total'].toString()) ?? 0,
      receivedAmount: num.tryParse(json['received_amount'].toString()) ?? 0,
      receivedAmountDate: json['received_amount_date'] ?? '',
      checkDueDate: json['check_due_date'] ?? '',
      checkNumber: json['check_number'] ?? 0,
      transactionDate: json['transaction_date'] ?? '',
      transactionDetails: json['transaction_details'] ?? '',
      // receivableAmount: json['receivable_amount'] ?? 0,
    );
  }
}

class DiscountData {
  final int id;
  final String customerId;
  final String categoriesId;
  final String value;
  final String discount;
  final String createdAt;
  final String updatedAt;
  final String category;

  DiscountData({
    required this.id,
    required this.customerId,
    required this.categoriesId,
    required this.value,
    required this.discount,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory DiscountData.fromJson(Map<String, dynamic> json) {
    return DiscountData(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? '',
      categoriesId: json['categories_id'] ?? '',
      value: json['value'] ?? '',
      discount: json['discount'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

// The root model class
class ApiResponsees {
  final int statusCode;
  final bool status;
  final String message;
  final OrderDataas data;

  ApiResponsees({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  // Convert a JSON map to an ApiResponse object
  factory ApiResponsees.fromJson(Map<String, dynamic> json) {
    return ApiResponsees(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: OrderDataas.fromJson(json['data'] ?? {}),
    );
  }

  // Convert an ApiResponse object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

// The model class for the 'data' field
class OrderDataas {
  final int totalOrder;
  final int estimateOrder;
  final int preorderOrder;
  final int draftOrder;
  final int cancelOrder;

  OrderDataas({
    required this.totalOrder,
    required this.estimateOrder,
    required this.preorderOrder,
    required this.draftOrder,
    required this.cancelOrder,
  });

  // Convert a JSON map to an OrderData object
  factory OrderDataas.fromJson(Map<String, dynamic> json) {
    return OrderDataas(
      totalOrder: json['total_order'] ?? 0,
      estimateOrder: json['estimate_order'] ?? 0,
      preorderOrder: json['preorder_order'] ?? 0,
      draftOrder: json['draft_order'] ?? 0,
      cancelOrder: json['cancel_order'] ?? 0,
    );
  }

  // Convert an OrderData object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'total_order': totalOrder,
      'estimate_order': estimateOrder,
      'preorder_order': preorderOrder,
      'draft_order': draftOrder,
      'cancel_order': cancelOrder,
    };
  }
}

class Cart {
  int id;
  String productId;
  String brandname;
  String productName;
  String description;
  String? reasonBySalesman;
  String imageUrl;
  int status;
  String scid;
  String variationId;
  String variationName;
  String unitType;
  String price;
  String tax;
  String packtype;
  int pieces;
  int stock;
  int lowstock;
  int fullstock;
  String createdAt;
  String updatedAt;
  String cartId;
  String? reason;
  int quantity;

  Cart({
    required this.id,
    required this.productId,
    required this.brandname,
    required this.productName,
    required this.description,
    this.reasonBySalesman,
    required this.imageUrl,
    required this.status,
    required this.scid,
    required this.variationId,
    required this.variationName,
    required this.unitType,
    required this.price,
    required this.tax,
    required this.packtype,
    required this.pieces,
    required this.stock,
    required this.lowstock,
    required this.fullstock,
    required this.createdAt,
    required this.updatedAt,
    required this.cartId,
    this.reason,
    required this.quantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      productId: json['product_id'],
      brandname: json['brandname'],
      productName: json['product_name'],
      description: json['description'],
      reasonBySalesman: json['reason_by_salesman'],
      imageUrl: json['image_url'],
      status: json['status'],
      scid: json['scid'],
      variationId: json['variation_id'],
      variationName: json['variation_name'],
      unitType: json['unitType'],
      price: json['price'],
      tax: json['tax'],
      packtype: json['packtype'],
      pieces: json['pieces'],
      stock: json['stock'],
      lowstock: json['lowstock'],
      fullstock: json['fullstock'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      cartId: json['cart_id'],
      reason: json['reason'],
      quantity: json['quantity'],
    );
  }
}

class Salesman {
  int id;
  String salesmanId;
  String fullname;
  String lastname;
  String mobileno;
  String email;
  String password;
  String town;
  String state;
  int zipcode;
  String address;
  String idimagePath;
  String imagePath;
  String createAt;
  String token;
  String? events;
  String? schedule;
  String? creditPoint;
  String? cancelEventReason;
  int projectionPrice;
  int projectionTarget;

  Salesman({
    required this.id,
    required this.salesmanId,
    required this.fullname,
    required this.lastname,
    required this.mobileno,
    required this.email,
    required this.password,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    required this.idimagePath,
    required this.imagePath,
    required this.createAt,
    required this.token,
    this.events,
    this.schedule,
    this.creditPoint,
    this.cancelEventReason,
    required this.projectionPrice,
    required this.projectionTarget,
  });

  factory Salesman.fromJson(Map<String, dynamic> json) {
    return Salesman(
      id: json['id'],
      salesmanId: json['salesman_id'],
      fullname: json['fullname'],
      lastname: json['lastname'],
      mobileno: json['mobileno'],
      email: json['email'],
      password: json['password'],
      town: json['town'],
      state: json['state'],
      zipcode: json['zipcode'],
      address: json['address'],
      idimagePath: json['idimage_path'],
      imagePath: json['image_path'],
      createAt: json['create_at'],
      token: json['token'],
      events: json['events'],
      schedule: json['schedule'],
      creditPoint: json['credit_point'],
      cancelEventReason: json['cancel_event_reason'],
      projectionPrice: json['projection_price'],
      projectionTarget: json['projection_target'],
    );
  }
}

class CustomerDashMo {
  int? id;
  String? customerId;
  String? cartId; // Nullable
  String fullname;
  String mobileno;
  String email;
  String town;
  String state;
  int zipcode;
  String address;
  String businessName;
  String? businessNo; // Nullable
  String? remark; // Nullable
  String? imageUrl; // Nullable
  String? salesmanId; // Nullable
  int? status; // Nullable
  String? createAt; // Nullable
  String? salesmanName; // Nullable
  String? discount; // Nullable
  int? eventType; // Nullable
  String? eventDays; // Nullable
  int? creditPeriod; // Nullable
  int? companyId; // Nullable
  List<Cart>? cart;
  List<Salesman>? salesman;

  CustomerDashMo({
    this.id,
    this.customerId,
    this.cartId,
    required this.fullname,
    required this.mobileno,
    required this.email,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    required this.businessName,
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
    this.cart,
    this.salesman,
  });

  factory CustomerDashMo.fromJson(Map<String, dynamic> json) {
    var cartList = json['cart'] as List;
    var salesmanList = json['salesman'] as List;

    List<Cart> cartItems = cartList.map((i) => Cart.fromJson(i)).toList();
    List<Salesman> salesmanItems =
        salesmanList.map((i) => Salesman.fromJson(i)).toList();

    return CustomerDashMo(
      id: json['id'],
      customerId: json['customer_id'],
      cartId: json['cart_id'],
      fullname: json['fullname'],
      mobileno: json['mobileno'],
      email: json['email'],
      town: json['town'],
      state: json['state'],
      zipcode: json['zipcode'],
      address: json['address'],
      businessName: json['business_name'],
      businessNo: json['business_no'],
      remark: json['remark'],
      imageUrl: json['image_url'],
      salesmanId: json['salesman_id'],
      status: json['status'],
      createAt: json['create_at'],
      salesmanName: json['salesman_name'],
      discount: json['discount'],
      eventType: json['event_type'],
      eventDays: json['event_days'],
      creditPeriod: json['credit_period'],
      companyId: json['company_id'],
      cart: cartItems,
      salesman: salesmanItems,
    );
  }
}

class CustomerResponse {
  int statusCode;
  bool status;
  String message;
  List<CustomerDashMo> data;

  CustomerResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<CustomerDashMo> customerItems =
        dataList.map((i) => CustomerDashMo.fromJson(i)).toList();

    return CustomerResponse(
      statusCode: json['status_code'],
      status: json['status'],
      message: json['message'],
      data: customerItems,
    );
  }
}

class ProductDetail {
  final String orderId;
  final String productId;
  final String variationId;
  final String price;
  final int quantity;
  final String totalPrice;
  final String variationName;
  final String productName;

  ProductDetail({
    required this.orderId,
    required this.productId,
    required this.variationId,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.variationName,
    required this.productName,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      variationId: json['variation_id']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.0',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0,
      totalPrice: json['total_price']?.toString() ?? '0.0',
      variationName: json['variation_name']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'variation_id': variationId,
      'price': price,
      'quantity': quantity,
      'total_price': totalPrice,
      'variation_name': variationName,
      'product_name': productName,
    };
  }
}

class ProductResponse {
  final int statusCode;
  final bool status;
  final String message;
  final List<ProductDetail> data;

  ProductResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    // Check for 'data' key and convert to a list of ProductDetail
    var dataList = json['data'] as List? ?? [];
    List<ProductDetail> productDetailsList =
        dataList.map((i) => ProductDetail.fromJson(i)).toList();

    return ProductResponse(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: productDetailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': data.map((productDetail) => productDetail.toJson()).toList(),
    };
  }
}

class SamlwEodel {
  int statusCode;
  bool status;
  String message;
  List<Datum> data;
  Pagination pagination;

  SamlwEodel({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });
}

class Datum {
  int id;
  String customerId;
  CartId cartId;
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
  String salesmanId;
  int status;
  DateTime createAt;
  String salesmanName;
  String discount;
  int eventType;
  String? eventDays;
  List<CreditPeriod> creditPeriod;
  int companyId;
  dynamic totalSales;
  int sales;
  dynamic salesPrice;
  int delivery;
  int payment;
  dynamic paymentPrice;
  int estimates;
  dynamic estimatesPrice;
  int preOrder;
  dynamic preOrderPrice;
  int drafts;
  int cancelled;
  List<Salesman> salesman;
  OrderData orderData;

  Datum({
    required this.id,
    required this.customerId,
    required this.cartId,
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
    required this.companyId,
    required this.totalSales,
    required this.sales,
    required this.salesPrice,
    required this.delivery,
    required this.payment,
    required this.paymentPrice,
    required this.estimates,
    required this.estimatesPrice,
    required this.preOrder,
    required this.preOrderPrice,
    required this.drafts,
    required this.cancelled,
    required this.salesman,
    required this.orderData,
  });
}

enum CartId { CART22, CART36, EMPTY }

class CreditPeriod {
  int creditPeriod;

  CreditPeriod({
    required this.creditPeriod,
  });
}

class OrderData {
  List<dynamic> totalSales;
  List<dynamic> preOrder;
  List<dynamic> outOfDiviery;
  List<dynamic> cancel;
  List<dynamic> draft;
  List<dynamic> estimate;
  List<dynamic> payment;
  List<dynamic> deliver;

  OrderData({
    required this.totalSales,
    required this.preOrder,
    required this.outOfDiviery,
    required this.cancel,
    required this.draft,
    required this.estimate,
    required this.payment,
    required this.deliver,
  });
}

class Salesmandddd {
  String fullname;
  String lastname;

  Salesmandddd({
    required this.fullname,
    required this.lastname,
  });
}

class Paginationddd {
  int totalRecord;
  int totalPages;
  int perPage;

  Paginationddd({
    required this.totalRecord,
    required this.totalPages,
    required this.perPage,
  });
}

// NEW REVENUE SECTION

class CustomerRevenueResponse {
  int statusCode;
  bool status;
  String message;
  CustomerRevenueData data;

  CustomerRevenueResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerRevenueResponse.fromJson(Map<String, dynamic> json) =>
      CustomerRevenueResponse(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: CustomerRevenueData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class CustomerRevenueData {
  Revenue revenue;

  CustomerRevenueData({
    required this.revenue,
  });

  factory CustomerRevenueData.fromJson(Map<String, dynamic> json) => CustomerRevenueData(
        revenue: Revenue.fromJson(json["revenue"]),
      );

  Map<String, dynamic> toJson() => {
        "revenue": revenue.toJson(),
      };
}

class Revenue {
  List<BookingRevenueDatum>? bookingRevenueData;
  List<OrderRevenueDatum>? orderRevenueData;

  Revenue({
    this.bookingRevenueData,
    this.orderRevenueData,
  });

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
        bookingRevenueData:
            List<BookingRevenueDatum>.from(
            json["booking_revenueData"]
                .map((x) => BookingRevenueDatum.fromJson(x))),
        orderRevenueData: List<OrderRevenueDatum>.from(json["order_revenueData"]
            .map((x) => OrderRevenueDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "booking_revenueData":
            List<dynamic>.from(bookingRevenueData!.map((x) => x)),
        "order_revenueData":
            List<dynamic>.from(orderRevenueData!.map((x) => x.toJson())),
      };
}

class BookingRevenueDatum {
  int? id;
  int? companyId;
  String? cartId;
  String? customerId;
  String? salesmanId;
  num? total;
  String? discount;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? orderId;
  int? paymentStatus;
  int? paymentType;
  String? paymentDetail;
  int? orderStatus;
  DateTime? orderCreatAt;
  num? orderTotal;
  num? receivedAmount;
  dynamic receivedAmountDate;
  DateTime? checkDueDate;
  dynamic checkNumber;
  dynamic transactionDate;
  String? transactionDetails;
  String? rejectionReason;
  dynamic rejectedDate;
  dynamic receivableAmount;
  dynamic deliveryDatetime;
  int? notificationStatus;
  dynamic orderCreatedStored;
  num? totalBookingRevenue;

  BookingRevenueDatum({
    this.id,
    this.companyId,
    this.cartId,
    this.customerId,
    this.salesmanId,
    this.total,
    this.discount,
    this.status,
    this.createdAt,
    this.updatedAt,
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
    this.notificationStatus,
    this.orderCreatedStored,
    this.totalBookingRevenue,
  });

  factory BookingRevenueDatum.fromJson(Map<String, dynamic> json) =>
      BookingRevenueDatum(
        id: json["id"],
        companyId: json["company_id"],
        cartId: json["cart_id"],
        customerId: json["customer_id"],
        salesmanId: json["salesman_id"],
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
        receivedAmountDate: json["received_amount_date"],
        checkDueDate: DateTime.parse(json["check_due_date"]),
        checkNumber: json["check_number"],
        transactionDate: json["transaction_date"],
        transactionDetails: json["transaction_details"],
        rejectionReason: json["rejection_reason"],
        rejectedDate: json["rejected_date"],
        receivableAmount: json["receivable_amount"],
        deliveryDatetime: json["delivery_datetime"],
        notificationStatus: json["notification_status"],
        orderCreatedStored: json["order_created_stored"],
        totalBookingRevenue: json["total_booking_revenue"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "cart_id": cartId,
        "customer_id": customerId,
        "salesman_id": salesmanId,
        "total": total,
        "discount": discount,
        "status": status,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "order_id": orderId,
        "payment_status": paymentStatus,
        "payment_type": paymentType,
        "payment_detail": paymentDetail,
        "order_status": orderStatus,
        "order_creat_at": orderCreatAt!.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate,
        "check_due_date": checkDueDate!.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate,
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate,
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime,
        "notification_status": notificationStatus,
        "order_created_stored": orderCreatedStored,
        "total_booking_revenue": totalBookingRevenue,
      };
}

class OrderRevenueDatum {
  num? orderTotal;
  DateTime? orderCreatAt;
  String? orderId;
  int? orderStatus;
  num? totalOrderRevenue;

  OrderRevenueDatum({
    this.orderTotal,
    this.orderCreatAt,
    this.orderId,
    this.orderStatus,
    this.totalOrderRevenue,
  });

  factory OrderRevenueDatum.fromJson(Map<String, dynamic> json) =>
      OrderRevenueDatum(
        orderTotal: json["order_total"],
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        orderId: json["order_id"],
        orderStatus: json["order_status"],
        totalOrderRevenue: json["total_order_revenue"],
      );

  Map<String, dynamic> toJson() => {
        "order_total": orderTotal,
        "order_creat_at": orderCreatAt!.toIso8601String(),
        "order_id": orderId,
        "order_status": orderStatus,
        "total_order_revenue": totalOrderRevenue,
      };
}
