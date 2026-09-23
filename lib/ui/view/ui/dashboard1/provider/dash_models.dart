import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:intl/intl.dart';

class Category {
  String? category;

  Category({this.category});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'] is List
          ? (json['category'].isNotEmpty ? json['category'][0] : null)
          : json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
    };
  }
}

class Salesmann {
  String? fullname;
  String? salesmanId;
  int? projectionTarget;
  double? projectionPrice;
  double? actualPrice;

  Salesmann({
    this.fullname,
    this.salesmanId,
    this.projectionTarget,
    this.projectionPrice,
    this.actualPrice,
  });

  factory Salesmann.fromJson(Map<String, dynamic> json) {
    return Salesmann(
      fullname: json['fullname'],
      salesmanId: json['salesman_id'],
      projectionTarget: json['projection_target'],
      projectionPrice: json['projection_price'].toDouble(),
      actualPrice: json['actual_price'] != null
          ? double.tryParse(json['actual_price'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'salesman_id': salesmanId,
      'projection_target': projectionTarget,
      'projection_price': projectionPrice,
      'actual_price': actualPrice,
    };
  }
}

class CategoryPerformancee {
  final int? cid;
  final String? category;
  final num? actualProjection;
  final num? actualTarget;
  final num? actualSales;
  final List<Salesmann>? salesman;

  CategoryPerformancee({
    this.cid,
    this.category,
    this.actualProjection,
    this.actualTarget,
    this.actualSales,
    this.salesman,
  });

  factory CategoryPerformancee.fromJson(Map<String, dynamic> json) {
    var salesmanList = json['salesman'] as List? ?? [];
    List<Salesmann> salesman =
        salesmanList.map((i) => Salesmann.fromJson(i)).toList();

    return CategoryPerformancee(
      cid: json['cid'] as int?,
      category: json['category'] is List
          ? (json['category'].isNotEmpty
              ? json['category'][0]?.toString()
              : null)
          : json['category']?.toString(),
      actualProjection: num.tryParse(json['actual_projection'].toString()) ?? 0,
      actualTarget: num.tryParse(json['actual_target'].toString()) ?? 0,
      actualSales: num.tryParse(json['actual_sales'].toString()) ?? 0,
      salesman: salesman.isNotEmpty ? salesman : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'category': category,
      'actual_projection': actualProjection,
      'actual_target': actualTarget,
      'actual_sales': actualSales,
      'salesman': salesman?.map((e) => e.toJson()).toList(),
    };
  }
}

class MonthlyPerformancee {
  final String? cid;
  final num? actualProjection;
  final num? actualTarget;
  final num? actualSales;
  final int? year;
  final String? month;
  final String? week;
  final String? barType;

  MonthlyPerformancee({
    this.cid,
    this.actualProjection,
    this.actualTarget,
    this.actualSales,
    this.year,
    this.month,
    this.week,
    this.barType,
  });

  factory MonthlyPerformancee.fromJson(Map<String, dynamic> json) {
    return MonthlyPerformancee(
      cid: json['cid'] is List
          ? (json['cid'].isNotEmpty ? json['cid'][0]?.toString() : null)
          : json['cid']?.toString(),
      actualProjection: num.tryParse(json['actual_projection'].toString()) ?? 0,
      actualTarget: num.tryParse(json['actual_target'].toString()) ?? 0,
      actualSales: num.tryParse(json['actual_sales'].toString()) ?? 0,
      year: json['year'] as int?,
      month: json['month'] as String?,
      week: json['week'] as String?,
      barType: json['bar_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'actual_projection': actualProjection,
      'actual_target': actualTarget,
      'actual_sales': actualSales,
      'year': year,
      'month': month,
      'week': week,
      'bar_type': barType,
    };
  }
}

class ResponseModelCp {
  final int? statusCode;
  final bool? status;
  final String? message;
  final List<Salesmanvn>? data;

  ResponseModelCp({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  factory ResponseModelCp.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Salesmanvn> dataList =
        list.map((i) => Salesmanvn.fromJson(i)).toList();

    return ResponseModelCp(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: dataList,
    );
  }
}

class Salesmanvn {
  final int? id;
  final String salesmanId;
  final String fullname;
  final String lastname;
  final String orderTotal;
  final int? targetTotal;
  final int? projectionTotal;

  Salesmanvn({
    this.id,
    required this.salesmanId,
    required this.fullname,
    required this.lastname,
    required this.orderTotal,
    this.targetTotal,
    this.projectionTotal,
  });

  factory Salesmanvn.fromJson(Map<String, dynamic> json) {
    return Salesmanvn(
      id: json['id'] ?? 0,
      salesmanId: json['salesman_id'] ?? '',
      fullname: json['fullname'] ?? '',
      lastname: json['lastname'] ?? '',
      orderTotal: json['order_total']?.toString() ?? '0.000',
      targetTotal: int.tryParse(json['target_total']?.toString() ?? '0') ?? 0,
      projectionTotal:
          int.tryParse(json['projection_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class Revenuee {
  List<BookingRevenueDatum>? bookingRevenueData;
  List<OrderRevenueDatum>? orderRevenueData;

  Revenuee({
    this.bookingRevenueData,
    this.orderRevenueData,
  });

  factory Revenuee.fromJson(Map<String, dynamic> json) => Revenuee(
        bookingRevenueData: List<BookingRevenueDatum>.from(
            json["booking_revenueData"]
                .map((x) => BookingRevenueDatum.fromJson(x))),
        orderRevenueData: List<OrderRevenueDatum>.from(json["order_revenueData"]
            .map((x) => OrderRevenueDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "booking_revenueData":
            List<dynamic>.from(bookingRevenueData!.map((x) => x.toJson())),
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
  int? total;
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
  int? receivedAmount;
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
  DateTime? orderGnerateAt;

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
    this.orderGnerateAt,
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
        orderGnerateAt: DateTime.parse(json["generated_date"]),
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
        "generated_date": orderGnerateAt!.toIso8601String(),
      };
}

class OrderRevenueDatum {
  num? orderTotal;
  DateTime? orderCreatAt;
  String? orderId;
  num? orderStatus;
  num? totalOrderRevenue;
  DateTime? orderGeneratedDate;

  OrderRevenueDatum({
    this.orderTotal,
    this.orderCreatAt,
    this.orderId,
    this.orderStatus,
    this.totalOrderRevenue,
    this.orderGeneratedDate,
  });

  factory OrderRevenueDatum.fromJson(Map<String, dynamic> json) =>
      OrderRevenueDatum(
        orderTotal: json["order_total"],
        orderCreatAt: json["order_creat_at"] != null ? DateTime.tryParse(json["order_creat_at"].toString()) : null,
        orderId: json["order_id"],
        orderStatus: json["order_status"],
        totalOrderRevenue: json["total_order_revenue"],
        orderGeneratedDate: json["generated_date"] != null ? DateTime.tryParse(json["generated_date"].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        "order_total": orderTotal,
        "order_creat_at": orderCreatAt!.toIso8601String(),
        "order_id": orderId,
        "order_status": orderStatus,
        "total_order_revenue": totalOrderRevenue,
        "generated_date": orderGeneratedDate!.toIso8601String(),
      };
}

class ResponseModell {
  final int? statusCode;
  final bool? status;
  final String? message;
  final List<Category>? allCategory;
  final List<CategoryPerformancee>? categoryPerformance;
  final List<MonthlyPerformancee>? monthlyPerformance;
  final Revenuee? revenue;
  final Collection? collection;
  final Delivery? delivery;
  final List<TopSellingProductA>? topSellingProducts;
  final OrderCountListt? orderCountList;

  ResponseModell({
    this.statusCode,
    this.status,
    this.message,
    this.allCategory,
    this.categoryPerformance,
    this.monthlyPerformance,
    this.revenue,
    this.collection,
    this.delivery,
    this.topSellingProducts,
    this.orderCountList,
  });

  factory ResponseModell.fromJson(Map<String, dynamic> json) {
    var categoryList = (json['data']?['all_category'] as List?) ?? [];
    List<Category> allCategory =
        categoryList.map((e) => Category.fromJson(e)).toList();

    var performanceList =
        (json['data']?['category_performance'] as List?) ?? [];
    List<CategoryPerformancee> categoryPerformance =
        performanceList.map((e) => CategoryPerformancee.fromJson(e)).toList();

    var monthPerformanceList =
        (json['data']?['monthly_performance'] as List?) ?? [];
    List<MonthlyPerformancee> monthlyPerformance = monthPerformanceList
        .map((e) => MonthlyPerformancee.fromJson(e))
        .toList();

    var topSellingList = (json['data']?['top_selling_product'] as List?) ?? [];
    List<TopSellingProductA> topSellingProducts =
        topSellingList.map((e) => TopSellingProductA.fromJson(e)).toList();

    return ResponseModell(
      statusCode: json['status_code'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      allCategory: allCategory,
      categoryPerformance: categoryPerformance,
      monthlyPerformance: monthlyPerformance,
      revenue: json['data']?['revenu'] != null
          ? Revenuee.fromJson(json['data']?['revenu'])
          : null,
      collection: json['data']?['collection'] != null
          ? Collection.fromJson(json['data']?['collection'])
          : null,
      delivery: json['data']?['delivery'] != null
          ? Delivery.fromJson(json['data']?['delivery'])
          : null,
      topSellingProducts:
          topSellingProducts.isNotEmpty ? topSellingProducts : null,
      orderCountList: json['data']?['order_count_list'] != null
          ? OrderCountListt.fromJson(json['data']?['order_count_list'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': {
        'all_category': allCategory?.map((e) => e.toJson()).toList(),
        'category_performance':
            categoryPerformance?.map((e) => e.toJson()).toList(),
        'monthly_performance':
            monthlyPerformance?.map((e) => e.toJson()).toList(),
        'revenu': revenue?.toJson(),
        'collection': collection?.toJson(),
        'delivery': delivery?.toJson(),
        'top_selling_product':
            topSellingProducts?.map((e) => e.toJson()).toList() ?? [],
        'order_count_list': orderCountList?.toJson(),
      },
    };
  }
}

class OrderCountListt {
  int? totalOrder;
  int? estimateOrder;
  int? estimateFilterOrder;
  int? preorderOrder;
  int? preorderFilterOrder;
  int? draftOrder;
  int? draftFilteredCount;
  int? cancelOrder;

  OrderCountListt({
    this.totalOrder,
    this.estimateOrder,
    this.estimateFilterOrder,
    this.preorderOrder,
    this.preorderFilterOrder,
    this.draftOrder,
    this.draftFilteredCount,
    this.cancelOrder,
  });

  factory OrderCountListt.fromJson(Map<String, dynamic> json) {
    return OrderCountListt(
      totalOrder: int.tryParse(json['total_order'].toString()) ?? 0,
      estimateOrder: int.tryParse(json['estimate_order'].toString()) ?? 0,
      estimateFilterOrder:
          int.tryParse(json['estimate_Filterorder'].toString()) ?? 0,
      preorderOrder: int.tryParse(json['preorder_order'].toString()) ?? 0,
      preorderFilterOrder:
          int.tryParse(json['preorder_Filterorder'].toString()) ?? 0,
      draftOrder: int.tryParse(json['draft_order'].toString()) ?? 0,
      draftFilteredCount:
          int.tryParse(json['draft_FilteredCount'].toString()) ?? 0,
      cancelOrder: int.tryParse(json['cancel_order'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_order': totalOrder,
      'estimate_order': estimateOrder,
      'estimate_Filterorder': estimateFilterOrder,
      'preorder_order': preorderOrder,
      'preorder_Filterorder': preorderFilterOrder,
      'draft_order': draftOrder,
      'draft_FilteredCount': draftFilteredCount,
      'cancel_order': cancelOrder,
    };
  }
}

// ignore: constant_identifier_names
enum EventDays { EMPTY, FRIDAY, MONDAY }

// ignore: constant_identifier_names
enum SalesmanName { B, N, RP, SALES6 }

class TopSellingProductA {
  String? cartIds;
  String? orderIds;
  String? eachPrice;
  String? variationId;
  String? variationName;
  String? price;
  String? productName;
  String? inNo;
  String? inclTax;
  String? tax;
  DateTime? createdAt;
  List<TopSellingCustomer>? customer;
  List<TopSellingQuantityList>? quantityList;
  String? topSellingProductATotalPrice;
  List<TopSellingTotalPrice>? totalPrice;
  num? totalAmount;
  int? quantity;
  String? buyquantity;
  List<TopSellingGetTimesDatum>? getTimesData;

  TopSellingProductA({
    this.cartIds,
    this.orderIds,
    this.eachPrice,
    this.variationId,
    this.variationName,
    this.price,
    this.productName,
    this.inNo,
    this.inclTax,
    this.tax,
    this.createdAt,
    this.customer,
    this.quantityList,
    this.topSellingProductATotalPrice,
    this.totalPrice,
    this.quantity,
    this.totalAmount,
    this.buyquantity,
    this.getTimesData,
  });

  factory TopSellingProductA.fromJson(Map<String, dynamic> json) {
    final getTimesDataList = List<TopSellingGetTimesDatum>.from(
      json["getTimesData"].map((x) => TopSellingGetTimesDatum.fromJson(x)),
    );
    final totalAmountSum = getTimesDataList.fold<double>(
      0.0,
      (sum, item) => sum + (item.totalAmount ?? 0.0),
    );
    return TopSellingProductA(
      cartIds: json["cart_ids"],
      orderIds: json["order_ids"],
      eachPrice: json["each_price"],
      variationId: json["variation_id"],
      variationName: json["variation_name"],
      price: json["price"],
      productName: json["product_name"],
      inNo: json["in_no"],
      inclTax: json["incl_tax"],
      tax: json["tax"],
      createdAt: DateTime.parse(json["created_at"]),
      customer: List<TopSellingCustomer>.from(
          json["customer"].map((x) => TopSellingCustomer.fromJson(x))),
      quantityList: List<TopSellingQuantityList>.from(
          json["quantityList"].map((x) => TopSellingQuantityList.fromJson(x))),
      topSellingProductATotalPrice: json["total_price"],
      totalAmount: totalAmountSum,
      totalPrice: List<TopSellingTotalPrice>.from(
          json["totalPrice"].map((x) => TopSellingTotalPrice.fromJson(x))),
      quantity: json["quantity"],
      buyquantity: json["buyquantity"],
      getTimesData: List<TopSellingGetTimesDatum>.from(
          json["getTimesData"].map((x) => TopSellingGetTimesDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "cart_ids": cartIds,
        "order_ids": orderIds,
        "each_price": eachPrice,
        "variation_id": variationId,
        "variation_name": variationName,
        "price": price,
        "product_name": productName,
        "in_no": inNo,
        "incl_tax": inclTax,
        "tax": tax,
        "created_at": createdAt!.toIso8601String(),
        "customer": List<dynamic>.from(customer!.map((x) => x.toJson())),
        "quantityList":
            List<dynamic>.from(quantityList!.map((x) => x.toJson())),
        "total_price": topSellingProductATotalPrice,
        "totalPrice": List<dynamic>.from(totalPrice!.map((x) => x.toJson())),
        "quantity": quantity,
        "total_amount": totalAmount,
        "buyquantity": buyquantity,
        "getTimesData":
            List<dynamic>.from(getTimesData!.map((x) => x.toJson())),
      };
}

class TopSellingCustomer {
  String? cartId;
  String? customerId;

  TopSellingCustomer({
    this.cartId,
    this.customerId,
  });

  factory TopSellingCustomer.fromJson(Map<String, dynamic> json) =>
      TopSellingCustomer(
        cartId: json["cart_id"],
        customerId: json["customer_id"],
      );

  Map<String, dynamic> toJson() => {
        "cart_id": cartId,
        "customer_id": customerId,
      };
}

class TopSellingGetTimesDatum {
  String? businessName;
  String? totalPrice;
  DateTime? createdAt;
  int? quantity;
  String? price;
  String? inclTax;
  String? orderId;
  String? cartId;
  num? tax;
  num? totalAmount;

  TopSellingGetTimesDatum({
    this.businessName,
    this.totalPrice,
    this.createdAt,
    this.quantity,
    this.price,
    this.inclTax,
    this.orderId,
    this.cartId,
    this.tax,
    this.totalAmount,
  });

  factory TopSellingGetTimesDatum.fromJson(Map<String, dynamic> json) =>
      TopSellingGetTimesDatum(
        businessName: json["business_name"],
        totalPrice: json["total_price"],
        createdAt: DateTime.parse(json["created_at"]),
        quantity: json["quantity"],
        price: json["price"],
        inclTax: json["incl_tax"],
        orderId: json["order_id"],
        cartId: json["cart_id"],
        tax: num.tryParse(json["tax"].toString()) ?? 0,
        totalAmount: num.tryParse(json["total_amount"].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "business_name": businessName,
        "total_price": totalPrice,
        "created_at": createdAt!.toIso8601String(),
        "quantity": quantity,
        "price": price,
        "incl_tax": inclTax,
        "order_id": orderId,
        "cart_id": cartId,
        "tax": tax,
        "total_amount": totalAmount,
      };
}

class TopSellingQuantityList {
  String? variationName;
  int? quantity;
  String? vprice;
  DateTime? createdAt;

  TopSellingQuantityList({
    this.variationName,
    this.quantity,
    this.vprice,
    this.createdAt,
  });

  factory TopSellingQuantityList.fromJson(Map<String, dynamic> json) =>
      TopSellingQuantityList(
        variationName: json["variation_name"],
        quantity: json["quantity"],
        vprice: json["vprice"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "variation_name": variationName,
        "quantity": quantity,
        "vprice": vprice,
        "created_at": createdAt!.toIso8601String(),
      };
}

class TopSellingTotalPrice {
  int? id;
  String? cartId;
  String? productId;
  String? variationId;
  String? price;
  String? reason;
  String? quantity;
  int? pieces;
  String? packType;
  String? totalPrice;
  int? status;
  int? orderPlaceStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? companyId;
  String? inNo;
  String? barcode;
  String? variationName;
  String? unitType;
  String? sellPrice;
  String? tax;
  String? packtype;
  int? stock;
  int? lowstock;
  int? fullstock;
  String? imageUrl;
  int? vStatus;
  int? times;

  TopSellingTotalPrice({
    this.id,
    this.cartId,
    this.productId,
    this.variationId,
    this.price,
    this.reason,
    this.quantity,
    this.pieces,
    this.packType,
    this.totalPrice,
    this.status,
    this.orderPlaceStatus,
    this.createdAt,
    this.updatedAt,
    this.companyId,
    this.inNo,
    this.barcode,
    this.variationName,
    this.unitType,
    this.sellPrice,
    this.tax,
    this.packtype,
    this.stock,
    this.lowstock,
    this.fullstock,
    this.imageUrl,
    this.vStatus,
    this.times,
  });

  factory TopSellingTotalPrice.fromJson(Map<String, dynamic> json) =>
      TopSellingTotalPrice(
        id: json["id"],
        cartId: json["cart_id"],
        productId: json["product_id"],
        variationId: json["variation_id"],
        price: json["price"],
        reason: json["reason"],
        quantity: json["quantity"],
        pieces: json["pieces"],
        packType: json["packType"],
        totalPrice: json["total_price"],
        status: json["status"],
        orderPlaceStatus: json["order_place_status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        companyId: json["company_id"],
        inNo: json["in_no"],
        barcode: json["barcode"],
        variationName: json["variation_name"],
        unitType: json["unitType"],
        sellPrice: json["sell_price"],
        tax: json["tax"],
        packtype: json["packtype"],
        stock: json["stock"],
        lowstock: json["lowstock"],
        fullstock: json["fullstock"],
        imageUrl: json["image_url"],
        vStatus: json["v_status"],
        times: json["times"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cart_id": cartId,
        "product_id": productId,
        "variation_id": variationId,
        "price": price,
        "reason": reason,
        "quantity": quantity,
        "pieces": pieces,
        "packType": packType,
        "total_price": totalPrice,
        "status": status,
        "order_place_status": orderPlaceStatus,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "company_id": companyId,
        "in_no": inNo,
        "barcode": barcode,
        "variation_name": variationName,
        "unitType": unitType,
        "sell_price": sellPrice,
        "tax": tax,
        "packtype": packtype,
        "stock": stock,
        "lowstock": lowstock,
        "fullstock": fullstock,
        "image_url": imageUrl,
        "v_status": vStatus,
        "times": times,
      };
}

class Customer {
  dynamic cartId;
  String? customerId;
  int? id;
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
  SalesmanName? salesmanId;
  int? status;
  DateTime? createAt;
  SalesmanName? salesmanName;
  String? discount;
  int? eventType;
  EventDays? eventDays;
  int? creditPeriod;

  Customer({
    this.cartId,
    this.customerId,
    this.id,
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
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cartId: json['cart_id'],
      customerId: json['customer_id'],
      id: _parseInt(json['id']),
      fullname: json['fullname'],
      mobileno: json['mobileno'],
      email: json['email'],
      town: json['town'],
      state: json['state'],
      zipcode: _parseInt(json['zipcode']),
      address: json['address'],
      businessName: json['business_name'],
      businessNo: json['business_no'],
      remark: json['remark'],
      imageUrl: json['image_url'],
      salesmanId: _parseSalesmanName(json['salesman_id']),
      status: _parseInt(json['status']),
      createAt:
          json['create_at'] != null ? DateTime.parse(json['create_at']) : null,
      salesmanName: _parseSalesmanName(json['salesman_name']),
      discount: json['discount'],
      eventType: _parseInt(json['event_type']),
      eventDays: json['event_days'] != null
          ? EventDays.values[_parseInt(json['event_days']) ?? 0]
          : null,
      creditPeriod: _parseInt(json['credit_period']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'customer_id': customerId,
      'id': id,
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
      'salesman_id': salesmanId?.toString().split('.').last,
      'status': status,
      'create_at': createAt?.toIso8601String(),
      'salesman_name': salesmanName?.toString().split('.').last,
      'discount': discount,
      'event_type': eventType,
      'event_days': eventDays?.index,
      'credit_period': creditPeriod,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  static SalesmanName? _parseSalesmanName(dynamic value) {
    if (value is String) {
      try {
        return SalesmanName.values.firstWhere((e) =>
            e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
      } catch (_) {
        return null;
      }
    } else {
      return value as SalesmanName?;
    }
  }
}

class QuantityList {
  int? id;
  String? cartId;
  String? productId;
  String? variationId;
  dynamic price;
  String? reason;
  int? quantity;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? customerId;
  SalesmanName? salesmanId;
  int? total;
  String? discount;
  String? variationName;
  String? unitType;
  String? tax;
  String? packtype;
  int? pieces;
  int? stock;
  int? lowstock;
  int? fullstock;
  String? imageUrl;

  QuantityList({
    this.id,
    this.cartId,
    this.productId,
    this.variationId,
    this.price,
    this.reason,
    this.quantity,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.customerId,
    this.salesmanId,
    this.total,
    this.discount,
    this.variationName,
    this.unitType,
    this.tax,
    this.packtype,
    this.pieces,
    this.stock,
    this.lowstock,
    this.fullstock,
    this.imageUrl,
  });

  factory QuantityList.fromJson(Map<String, dynamic> json) {
    return QuantityList(
      id: _parseInt(json['id']),
      cartId: json['cart_id'],
      productId: json['product_id'],
      variationId: json['variation_id'],
      price: json['vprice'],
      reason: json['reason'],
      quantity: _parseInt(json['quantity']),
      status: _parseInt(json['status']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      customerId: json['customer_id'],
      salesmanId: _parseSalesmanName(json['salesman_id']),
      total: _parseInt(json['total']),
      discount: json['discount'],
      variationName: json['variation_name'],
      unitType: json['unitType'],
      tax: json['tax'],
      packtype: json['packtype'],
      pieces: _parseInt(json['pieces']),
      stock: _parseInt(json['stock']),
      lowstock: _parseInt(json['lowstock']),
      fullstock: _parseInt(json['fullstock']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'variation_id': variationId,
      'price': price,
      'reason': reason,
      'quantity': quantity,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'customer_id': customerId,
      'salesman_id': salesmanId?.toString().split('.').last,
      'total': total,
      'discount': discount,
      'variation_name': variationName,
      'unitType': unitType,
      'tax': tax,
      'packtype': packtype,
      'pieces': pieces,
      'stock': stock,
      'lowstock': lowstock,
      'fullstock': fullstock,
      'image_url': imageUrl,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }

  static SalesmanName? _parseSalesmanName(dynamic value) {
    if (value is String) {
      try {
        return SalesmanName.values.firstWhere((e) =>
            e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
      } catch (_) {
        return null;
      }
    } else {
      return value as SalesmanName?;
    }
  }
}

class Delivery {
  OrderA? order;
  DeliveryOrder? deliveryOrder;

  Delivery({
    this.order,
    this.deliveryOrder,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      order: OrderA.fromJson(json['order'] ?? {}),
      deliveryOrder: DeliveryOrder.fromJson(json['delivery_order'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'delivery_order': deliveryOrder?.toJson(),
    };
  }
}

class OrderA {
  List<OrderDetails>? totalOrders;

  OrderA({
    this.totalOrders,
  });

  factory OrderA.fromJson(Map<String, dynamic> json) {
    var orderList = json['total_orders'] as List? ?? [];
    List<OrderDetails> totalOrders = orderList.isNotEmpty
        ? orderList.map((i) => OrderDetails.fromJson(i)).toList()
        : [];

    return OrderA(
      totalOrders: totalOrders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders?.map((e) => e.toJson()).toList(),
    };
  }
}

class DeliveryOrder {
  int? count;
  String? percentage;

  DeliveryOrder({
    this.count,
    this.percentage,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      count: json['count'] ?? 0,
      percentage: json['percentage']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'percentage': percentage,
    };
  }
}

class OrderDetails {
  num? orderTotal;
  DateTime? orderCreatAt;
  String? orderId;
  int? orderStatus;
  String? businessName;
  String? invoiceId;
  num? orderProcessing;
  num? packedForDelivery;
  num? deliverd;
  num? outForDelivery;

  OrderDetails({
    this.orderTotal,
    this.orderCreatAt,
    this.orderId,
    this.orderStatus,
    this.businessName,
    this.invoiceId,
    this.orderProcessing,
    this.packedForDelivery,
    this.deliverd,
    this.outForDelivery,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
        orderTotal: json["order_total"],
        orderCreatAt: DateTime.parse(json["order_creat_at"]),
        orderId: json["order_id"],
        orderStatus: json["order_status"],
        businessName: json["business_name"],
        invoiceId: json["invoice_id"],
        orderProcessing: json["order_processing"],
        packedForDelivery: json["packed_for_delivery"],
        deliverd: json["deliverd"],
        outForDelivery: json["outForDelivery"],
      );

  Map<String, dynamic> toJson() => {
        "order_total": orderTotal,
        "order_creat_at": orderCreatAt!.toIso8601String(),
        "order_id": orderId,
        "order_status": orderStatus,
        "business_name": businessName,
        "invoice_id": invoiceId,
        "order_processing": orderProcessing,
        "packed_for_delivery": packedForDelivery,
        "deliverd": deliverd,
        "outForDelivery": outForDelivery,
      };
}

class Collection {
  final OrderCollection? order;
  final PaymentCollection? payment;
  final DueCollection? due;
  final OverdueCollection? overdue;

  Collection({
    this.order,
    this.payment,
    this.due,
    this.overdue,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      order: json['order'] != null
          ? OrderCollection.fromJson(json['order'])
          : null,
      payment: json['payment'] != null
          ? PaymentCollection.fromJson(json['payment'])
          : null,
      due: json['due'] != null ? DueCollection.fromJson(json['due']) : null,
      overdue: json['overdue'] != null
          ? OverdueCollection.fromJson(json['overdue'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'payment': payment?.toJson(),
      'due': due?.toJson(),
      'overdue': overdue?.toJson(),
    };
  }
}

class OrderCollection {
  final List<PendingAmount>? pendingAmount;

  OrderCollection({this.pendingAmount});

  factory OrderCollection.fromJson(Map<String, dynamic> json) {
    var list = json['pending_amount'] as List?;
    List<PendingAmount> pendingAmountList = list != null
        ? list.map((item) => PendingAmount.fromJson(item)).toList()
        : [];
    return OrderCollection(pendingAmount: pendingAmountList);
  }

  Map<String, dynamic> toJson() {
    return {
      'pending_amount': pendingAmount?.map((e) => e.toJson()).toList(),
    };
  }
}

class PendingAmount {
  final String? orderCreatAt;
  final String? orderId;
  final String? invoiceId;
  final String? businessName;
  final int? orderStatus;
  final num? orderTotal;
  num? receivedAmount;
  final num? receivableAmount;
  int? paymentStatus;
  final int? creditPeriod;
  final int? count;
  final String? percentage;
  final int? amountEdited;
  final num? pendingAmount;
  final num? amount;
  final num? dueAmount;
  final num? overDue;
  final List<dynamic>? dueDate;

  PendingAmount({
    this.orderCreatAt,
    this.orderId,
    this.invoiceId,
    this.businessName,
    this.orderStatus,
    this.orderTotal,
    this.receivedAmount,
    this.receivableAmount,
    this.paymentStatus,
    this.creditPeriod,
    this.count,
    this.percentage,
    this.amountEdited,
    this.pendingAmount,
    this.amount,
    this.dueAmount,
    this.overDue,
    this.dueDate,
  });

  factory PendingAmount.fromJson(Map<String, dynamic> json) {
    return PendingAmount(
      orderCreatAt: json['order_creat_at'],
      orderId: json['order_id'],
      invoiceId: json['invoice_id'],
      businessName: json['business_name'],
      orderStatus: json['order_status'],
      orderTotal: json['order_total'],
      receivedAmount: json['received_amount'],
      receivableAmount: json['receivable_amount'],
      paymentStatus: json['payment_status'],
      creditPeriod: json['credit_period'],
      count: json['count'],
      percentage: json['percentage'],
      amountEdited: json['amount_edited'],
      pendingAmount: json['pending_amount'],
      amount: json['amount'],
      dueAmount: json['due_amount'],
      overDue: json['over_due'],
      dueDate: json['due_date'] != null
          ? List<dynamic>.from(json['due_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_creat_at': orderCreatAt,
      'order_id': orderId,
      'invoice_id': invoiceId,
      'business_name': businessName,
      'order_status': orderStatus,
      'order_total': orderTotal,
      'received_amount': receivedAmount,
      'receivable_amount': receivableAmount,
      'payment_status': paymentStatus,
      'credit_period': creditPeriod,
      'count': count,
      'percentage': percentage,
      'amount_edited': amountEdited,
      'pending_amount': pendingAmount,
      'amount': amount,
      'due_amount': dueAmount,
      'over_due': overDue,
      'due_date': dueDate,
    };
  }
}

class PaymentCollection {
  final num? payedAmount;
  final List<CompletedOrder>? completedOrders;

  PaymentCollection({this.payedAmount, this.completedOrders});

  factory PaymentCollection.fromJson(Map<String, dynamic> json) {
    var list = json['completed_orders'] as List?;
    List<CompletedOrder> completedOrdersList = list != null
        ? list.map((item) => CompletedOrder.fromJson(item)).toList()
        : [];
    return PaymentCollection(
      payedAmount: json['payed_amount'],
      completedOrders: completedOrdersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payed_amount': payedAmount,
      'completed_orders': completedOrders?.map((e) => e.toJson()).toList(),
    };
  }
}

class CompletedOrder {
  int? id;
  String? orderId;
  String? customerId;
  String? salesmanId;
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
  DateTime? rejectedDate;
  int? receivableAmount;
  DateTime? deliveryDatetime;
  int? notificationStatus;
  dynamic orderCreatedStored;
  int? companyId;
  String? fullname;
  String? mobileno;
  String? email;
  String? town;
  String? state;
  int? zipcode;
  String? address;
  String? latitude;
  String? longitude;
  String? businessName;
  String? businessNo;
  String? tfn;
  String? addressCheckbox;
  String? deliveryAddress;
  String? deliveryTown;
  String? deliveryState;
  int? deliveryZipcode;
  String? remark;
  String? imageUrl;
  int? status;
  DateTime? createAt;
  String? createdBy;
  String? salesmanName;
  String? discount;
  int? eventType;
  String? eventDays;
  int? creditPeriod;
  String? invoiceId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? count;

  CompletedOrder({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
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
    this.notificationStatus,
    this.orderCreatedStored,
    this.companyId,
    this.fullname,
    this.mobileno,
    this.email,
    this.town,
    this.state,
    this.zipcode,
    this.address,
    this.latitude,
    this.longitude,
    this.businessName,
    this.businessNo,
    this.tfn,
    this.addressCheckbox,
    this.deliveryAddress,
    this.deliveryTown,
    this.deliveryState,
    this.deliveryZipcode,
    this.remark,
    this.imageUrl,
    this.status,
    this.createAt,
    this.createdBy,
    this.salesmanName,
    this.discount,
    this.eventType,
    this.eventDays,
    this.creditPeriod,
    this.invoiceId,
    this.createdAt,
    this.updatedAt,
    this.count,
  });

  factory CompletedOrder.fromJson(Map<String, dynamic> json) => CompletedOrder(
        id: json["id"] as int?,
        orderId: json["order_id"] as String?,
        customerId: json["customer_id"] as String?,
        salesmanId: json["salesman_id"] as String?,
        paymentStatus: json["payment_status"] as int?,
        paymentType: json["payment_type"] as int?,
        paymentDetail: json["payment_detail"] as String?,
        orderStatus: json["order_status"] as int?,
        cartId: json["cart_id"] as String?,
        orderCreatAt: json["order_creat_at"] != null
            ? DateTime.tryParse(json["order_creat_at"])
            : null,
        orderTotal: json["order_total"] as num?,
        receivedAmount: json["received_amount"] as num?,
        receivedAmountDate: json["received_amount_date"] != null
            ? DateTime.tryParse(json["received_amount_date"])
            : null,
        checkDueDate: json["check_due_date"] != null
            ? DateTime.tryParse(json["check_due_date"])
            : null,
        checkNumber: json["check_number"] as int?,
        transactionDate: json["transaction_date"] != null
            ? DateTime.tryParse(json["transaction_date"])
            : null,
        transactionDetails: json["transaction_details"] as String?,
        rejectionReason: json["rejection_reason"] as String?,
        rejectedDate: json["rejected_date"] != null
            ? DateTime.tryParse(json["rejected_date"])
            : null,
        receivableAmount: json["receivable_amount"] as int?,
        deliveryDatetime: json["delivery_datetime"] != null
            ? DateTime.tryParse(json["delivery_datetime"])
            : null,
        notificationStatus: json["notification_status"] as int?,
        orderCreatedStored: json["order_created_stored"],
        companyId: json["company_id"] as int?,
        fullname: json["fullname"] as String?,
        mobileno: json["mobileno"] as String?,
        email: json["email"] as String?,
        town: json["town"] as String?,
        state: json["state"] as String?,
        zipcode: json["zipcode"] as int?,
        address: json["address"] as String?,
        latitude: json["latitude"] as String?,
        longitude: json["longitude"] as String?,
        businessName: json["business_name"] as String?,
        businessNo: json["business_no"] as String?,
        tfn: json["tfn"] as String?,
        addressCheckbox: json["addressCheckbox"] as String?,
        deliveryAddress: json["delivery_address"] as String?,
        deliveryTown: json["delivery_town"] as String?,
        deliveryState: json["delivery_state"] as String?,
        deliveryZipcode: json["delivery_zipcode"] as int?,
        remark: json["remark"] as String?,
        imageUrl: json["image_url"] as String?,
        status: json["status"] as int?,
        createAt: json["create_at"] != null
            ? DateTime.tryParse(json["create_at"])
            : null,
        createdBy: json["created_by"] as String?,
        salesmanName: json["salesman_name"] as String?,
        discount: json["discount"] as String?,
        eventType: json["event_type"] as int?,
        eventDays: json["event_days"] as String?,
        creditPeriod: json["credit_period"] as int?,
        invoiceId: json["invoice_id"] as String?,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
        count: json["count"] as int?,
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
        "order_creat_at": orderCreatAt!.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate!.toIso8601String(),
        "check_due_date": checkDueDate!.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate!.toIso8601String(),
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate!.toIso8601String(),
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime!.toIso8601String(),
        "notification_status": notificationStatus,
        "order_created_stored": orderCreatedStored,
        "company_id": companyId,
        "fullname": fullname,
        "mobileno": mobileno,
        "email": email,
        "town": town,
        "state": state,
        "zipcode": zipcode,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "business_name": businessName,
        "business_no": businessNo,
        "tfn": tfn,
        "addressCheckbox": addressCheckbox,
        "delivery_address": deliveryAddress,
        "delivery_town": deliveryTown,
        "delivery_state": deliveryState,
        "delivery_zipcode": deliveryZipcode,
        "remark": remark,
        "image_url": imageUrl,
        "status": status,
        "create_at": createAt!.toIso8601String(),
        "created_by": createdBy,
        "salesman_name": salesmanName,
        "discount": discount,
        "event_type": eventType,
        "event_days": eventDays,
        "credit_period": creditPeriod,
        "invoice_id": invoiceId,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "count": count,
      };
}

class DueCollection {
  final List<PendingAmount>? dueAmount;

  DueCollection({this.dueAmount});

  factory DueCollection.fromJson(Map<String, dynamic> json) {
    var list = json['due_amount'] as List?;
    List<PendingAmount> dueAmountList = list != null
        ? list.map((item) => PendingAmount.fromJson(item)).toList()
        : [];
    return DueCollection(dueAmount: dueAmountList);
  }

  Map<String, dynamic> toJson() {
    return {
      'due_amount': dueAmount?.map((e) => e.toJson()).toList(),
    };
  }
}

class OverdueCollection {
  final List<PendingAmount>? overdueAmount;

  OverdueCollection({this.overdueAmount});

  factory OverdueCollection.fromJson(Map<String, dynamic> json) {
    var list = json['overdue_amount'] as List?;
    List<PendingAmount> overdueAmountList = list != null
        ? list.map((item) => PendingAmount.fromJson(item)).toList()
        : [];
    return OverdueCollection(overdueAmount: overdueAmountList);
  }

  Map<String, dynamic> toJson() {
    return {
      'overdue_amount': overdueAmount?.map((e) => e.toJson()).toList(),
    };
  }
}

String getFormattedOrderCreatAt(dynamic value) {
  if (value == null || value.toString().isEmpty) {
    return '';
  }

  try {
    if (value is DateTime) {
      return DateFormat('dd-MM-yyyy').format(value);
    }
    DateTime parsedDate = DateTime.parse(value.toString());
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return '';
  }
}

class SalesmenResponse {
  int statusCode;
  bool status;
  String message;
  List<List<SalesmanChat>> data;

  SalesmenResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory SalesmenResponse.fromJson(Map<String, dynamic> json) {
    var dataList = (json['data'] as List)
        .map((salesmen) => (salesmen as List)
            .map((salesman) =>
                SalesmanChat.fromJson(salesman as Map<String, dynamic>))
            .toList())
        .toList();

    return SalesmenResponse(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: dataList,
    );
  }
}

class SalesmanChat {
  final int id;
  final String chatSenderId;
  final String chatId;
  final String message;
  final String? imageUrl; // Nullable field
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String salesmanId;
  final String fullname;
  final String mobileNo;
  final String email;
  final String password;
  final String town;
  final String state;
  final int zipcode;
  final String address;
  final String idImagePath;
  final String imagePath;
  final DateTime createAt;
  final String token;
  final dynamic events;
  final dynamic schedule;
  final dynamic creditPoint;
  final dynamic cancelEventReason;
  final int projectionPrice;
  final int projectionTarget;

  SalesmanChat({
    required this.id,
    required this.chatSenderId,
    required this.chatId,
    required this.message,
    this.imageUrl, // Nullable field
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.salesmanId,
    required this.fullname,
    required this.mobileNo,
    required this.email,
    required this.password,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    required this.idImagePath,
    required this.imagePath,
    required this.createAt,
    required this.token,
    required this.events,
    required this.schedule,
    required this.creditPoint,
    required this.cancelEventReason,
    required this.projectionPrice,
    required this.projectionTarget,
  });
  factory SalesmanChat.fromJson(Map<String, dynamic> json) {
    return SalesmanChat(
      id: json['id'] ?? 0,
      chatSenderId: json['chat_sender_id'] ?? '',
      chatId: json['chat_id'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['image_url'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      salesmanId: json['salesman_id'] ?? '',
      fullname: json['fullname'] ?? '',
      mobileNo: json['mobileno'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      town: json['town'] ?? '',
      state: json['state'] ?? '',
      zipcode: json['zipcode'] ?? 0,
      address: json['address'] ?? '',
      idImagePath: json['idimage_path'] ?? '',
      imagePath: json['image_path'] ?? '',
      createAt: json['create_at'] != null
          ? DateTime.tryParse(json['create_at']) ?? DateTime.now()
          : DateTime.now(),
      token: json['token'] ?? '',
      events: json['events'],
      schedule: json['schedule'],
      creditPoint: json['credit_point'],
      cancelEventReason: json['cancel_event_reason'],
      projectionPrice: json['projection_price'] ?? 0,
      projectionTarget: json['projection_target'] ?? 0,
    );
  }
}

class Messages {
  final String? message;
  final String? image;
  final String source;
  final String salesman;
  final dynamic updatedAt;
  final dynamic createdAt;

  Messages({
    this.message,
    this.image,
    required this.source,
    required this.salesman,
    this.updatedAt,
    this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'image': image,
      'source': source,
      'salesman': salesman,
      'updated_at': updatedAt!,
      'created_at': createdAt!,
    };
  }

  String? get getMessage => message;
  String? get getImage => image;
  String get getSource => source;
  String get getSalesman => salesman;
  DateTime? get getUpdatedAt => updatedAt;
  DateTime? get getCreatedAt => createdAt;

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
      message: json['message'] ?? '',
      image: json['image_url'] ?? '',
      source: json['source'] ?? '',
      salesman: json['salesman'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class MessagesResponse {
  final int? statusCode;
  final bool? status;
  final String? message;
  final List<Messages> data;

  MessagesResponse({
    this.statusCode,
    this.status,
    this.message,
    required this.data,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    var messagesList = json['data'] as List;
    List<Messages> messages = messagesList
        .map((messageJson) => Messages.fromJson(messageJson))
        .toList();

    return MessagesResponse(
      statusCode: json['status_code'],
      status: json['status'],
      message: json['message'],
      data: messages,
    );
  }
}

class AdminMessageRequest {
  final String salesmanId;
  final String message;

  AdminMessageRequest({
    required this.salesmanId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'salesman_id': salesmanId,
      'message': message,
    };
  }
}

class OrdersDash {
  final int id;
  final String orderId;
  final String customerId;
  final String salesmanId;
  final int paymentStatus;
  final int paymentType;
  final String paymentDetail;
  final int orderStatus;
  final String cartId;
  final DateTime orderCreatedAt;
  final dynamic orderTotal;
  final dynamic receivedAmount;
  final DateTime? receivedAmountDate;
  final DateTime? deliveryDate;
  final DateTime checkDueDate;
  final int checkNumber;
  final DateTime? transactionDate;
  final String transactionDetails;
  final String fullname;
  final String lastname;
  final List<Cart> cart;
  final List<CustomerDash> customer;
  final List<InvoiceDash> invoice;
  final DateTime? generatedAt;

  OrdersDash({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.salesmanId,
    required this.paymentStatus,
    required this.paymentType,
    required this.paymentDetail,
    required this.orderStatus,
    required this.cartId,
    required this.orderCreatedAt,
    required this.orderTotal,
    required this.receivedAmount,
    this.receivedAmountDate,
    this.deliveryDate,
    required this.checkDueDate,
    required this.checkNumber,
    this.transactionDate,
    required this.transactionDetails,
    required this.fullname,
    required this.lastname,
    required this.cart,
    required this.customer,
    required this.invoice,
    this.generatedAt,
  });
  OrdersDash copyWith({
    int? id,
    String? orderId,
    String? customerId,
    String? salesmanId,
    int? paymentStatus,
    int? paymentType,
    String? paymentDetail,
    int? orderStatus,
    String? cartId,
    DateTime? orderCreatedAt,
    dynamic orderTotal,
    dynamic receivedAmount,
    DateTime? receivedAmountDate,
    DateTime? deliveryDate,
    DateTime? checkDueDate,
    int? checkNumber,
    DateTime? transactionDate,
    String? transactionDetails,
    String? fullname,
    String? lastname,
    List<Cart>? cart,
    List<CustomerDash>? customer,
    List<InvoiceDash>? invoice,
    DateTime? generatedAt,
  }) {
    return OrdersDash(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      salesmanId: salesmanId ?? this.salesmanId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentType: paymentType ?? this.paymentType,
      paymentDetail: paymentDetail ?? this.paymentDetail,
      orderStatus: orderStatus ?? this.orderStatus,
      cartId: cartId ?? this.cartId,
      orderCreatedAt: orderCreatedAt ?? this.orderCreatedAt,
      orderTotal: orderTotal ?? this.orderTotal,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      receivedAmountDate: receivedAmountDate ?? this.receivedAmountDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      checkDueDate: checkDueDate ?? this.checkDueDate,
      checkNumber: checkNumber ?? this.checkNumber,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionDetails: transactionDetails ?? this.transactionDetails,
      fullname: fullname ?? this.fullname,
      lastname: lastname ?? this.lastname,
      cart: cart ?? this.cart,
      customer: customer ?? this.customer,
      invoice: invoice ?? this.invoice,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  factory OrdersDash.fromJson(Map<String, dynamic> json) {
    return OrdersDash(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      salesmanId: json['salesman_id'] ?? '',
      paymentStatus: json['payment_status'] ?? 0,
      paymentType: json['payment_type'] ?? 0,
      paymentDetail: json['payment_detail'] ?? '',
      orderStatus: json['order_status'] ?? 0,
      cartId: json['cart_id'] ?? '',
      orderCreatedAt: _parseDateTime(json['order_creat_at']),
      orderTotal: json['order_total'] ?? 0,
      receivedAmount: json['received_amount'] ?? 0,
      receivedAmountDate: _parseNullableDateTime(json['received_amount_date']),
      deliveryDate: _parseNullableDateTime(json['delivery_datetime']),
      checkDueDate: _parseDateTime(json['check_due_date']),
      checkNumber: json['check_number'] ?? 0,
      transactionDate: _parseNullableDateTime(json['transaction_date']),
      transactionDetails: json['transaction_details'] ?? '',
      fullname: json['fullname'] ?? '',
      lastname: json['lastname'] ?? '',
      cart: (json['cart'] as List? ?? [])
          .map((item) => Cart.fromJson(ensureStringKeyedMap(item)))
          .toList(),
      customer: (json['customer'] as List? ?? [])
          .map((item) => CustomerDash.fromJson(ensureStringKeyedMap(item)))
          .toList(),
      invoice: (json['invoice'] as List? ?? [])
          .map((item) => InvoiceDash.fromJson(ensureStringKeyedMap(item)))
          .toList(),
      generatedAt: _parseNullableDateTime(json['generated_date']),
    );
  }
  static DateTime _parseDateTime(String? dateString) {
    try {
      if (dateString != null && dateString.isNotEmpty) {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      //
    }
    return DateTime(1970, 1, 1);
  }

  static DateTime? _parseNullableDateTime(String? dateString) {
    try {
      if (dateString != null && dateString.isNotEmpty) {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      //
    }
    return null;
  }
}

class Cart {
  final int id;
  final String productId;
  final String brandName;
  final String productName;
  final String description;
  final String? reasonBySalesman;
  final String imageUrl;
  final int status;
  final String scid;
  final String variationId;
  final String variationName;
  final String unitType;
  final double price;
  final double tax;
  final String packType;
  final int pieces;
  final int stock;
  final int lowStock;
  final int fullStock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String cartId;
  final String? reason;
  final int quantity;

  Cart({
    required this.id,
    required this.productId,
    required this.brandName,
    required this.productName,
    required this.description,
    required this.reasonBySalesman,
    required this.imageUrl,
    required this.status,
    required this.scid,
    required this.variationId,
    required this.variationName,
    required this.unitType,
    required this.price,
    required this.tax,
    required this.packType,
    required this.pieces,
    required this.stock,
    required this.lowStock,
    required this.fullStock,
    required this.createdAt,
    required this.updatedAt,
    required this.cartId,
    required this.reason,
    required this.quantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? '',
      brandName: json['brandname'] ?? '',
      productName: json['product_name'] ?? '',
      description: json['description'] ?? '',
      reasonBySalesman: json['reason_by_salesman'],
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 0,
      scid: json['scid'] ?? '',
      variationId: json['variation_id'] ?? '',
      variationName: json['variation_name'] ?? '',
      unitType: json['unitType'] ?? '',
      price: parseDouble(json['price']),
      tax: parseDouble(json['tax']),
      packType: json['packtype'] ?? '',
      pieces: json['pieces'] ?? 0,
      stock: json['stock'] ?? 0,
      lowStock: json['lowstock'] ?? 0,
      fullStock: json['fullstock'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? '1970-01-01'),
      updatedAt: DateTime.parse(json['updated_at'] ?? '1970-01-01'),
      cartId: json['cart_id'] ?? '',
      reason: json['reason'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}

class Invoice {
  final int id;
  final String invoiceId;
  final String cartId;
  final String orderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceId,
    required this.cartId,
    required this.orderId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create an Invoice object from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? '',
      cartId: json['cart_id'] ?? '',
      orderId: json['order_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // Method to convert Invoice object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'cart_id': cartId,
      'order_id': orderId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CustomerDash {
  final int id;
  final String customerId;
  final String cartId;
  final String fullName;
  final String mobileNo;
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
  final DateTime createAt;
  final String salesmanName;
  final String discount;
  final int eventType;
  final String eventDays;
  final int creditPeriod;

  CustomerDash({
    required this.id,
    required this.customerId,
    required this.cartId,
    required this.fullName,
    required this.mobileNo,
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

  factory CustomerDash.fromJson(Map<String, dynamic> json) {
    return CustomerDash(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? '',
      cartId: json['cart_id'] ?? '',
      fullName: json['fullname'] ?? '',
      mobileNo: json['mobileno'] ?? '',
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
      createAt: DateTime.parse(json['create_at'] ?? '1970-01-01'),
      salesmanName: json['salesman_name'] ?? '',
      discount: json['discount'] ?? '',
      eventType: json['event_type'] ?? 0,
      eventDays: json['event_days'] ?? '',
      creditPeriod: json['credit_period'] ?? 0,
    );
  }
}

class InvoiceDash {
  final int id;
  final String invoiceId;
  final String cartId;
  final String orderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceDash({
    required this.id,
    required this.invoiceId,
    required this.cartId,
    required this.orderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceDash.fromJson(Map<String, dynamic> json) {
    return InvoiceDash(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? '',
      cartId: json['cart_id'] ?? '',
      orderId: json['order_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? '1970-01-01'),
      updatedAt: DateTime.parse(json['updated_at'] ?? '1970-01-01'),
    );
  }
}

class OrderResponse {
  final int statusCode;
  final bool status;
  final String message;
  final List<OrdersDash> data;
  final Pagination pagination;

  OrderResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      statusCode: json['status_code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] != null && json['data'] is List)
          ? (json['data'] as List)
              .map((item) => OrdersDash.fromJson(item))
              .toList()
          : [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Pagination {
  final int totalRecord;
  final int totalPages;
  final int perPage;

  Pagination({
    required this.totalRecord,
    required this.totalPages,
    required this.perPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalRecord: json['total_record'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      perPage: json['per_page'] ?? 0,
    );
  }
}

double parseDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  } else {
    return 0.0;
  }
}

class SalesmanData {
  final int? id;
  final int? companyId;
  final String salesmanId;
  final String fullname;
  final String lastname;
  final String department;
  final String portfolio;
  final String mobileno;
  final String email;
  final String? password;
  final String town;
  final String state;
  final int zipcode;
  final String address;
  final String? idImagePath;
  final String? imagePath;
  final DateTime? createAt;
  final String token;
  final int? projectionPrice;
  final int? projectionTarget;
  final String? cancelEventReason;
  final int? appStatus;
  final String usertype;
  final int status;

  SalesmanData({
    this.id,
    this.companyId,
    required this.salesmanId,
    required this.fullname,
    required this.lastname,
    required this.department,
    required this.portfolio,
    required this.mobileno,
    required this.email,
    this.password,
    required this.town,
    required this.state,
    required this.zipcode,
    required this.address,
    this.idImagePath,
    this.imagePath,
    this.createAt,
    required this.token,
    this.projectionPrice,
    this.projectionTarget,
    this.cancelEventReason,
    this.appStatus,
    required this.usertype,
    required this.status,
  });

  factory SalesmanData.fromJson(Map<String, dynamic> json) {
    return SalesmanData(
      id: json['id'],
      companyId: json['company_id'],
      salesmanId: json['salesman_id'] ?? '',
      fullname: json['fullname'] ?? '',
      lastname: json['lastname'] ?? '',
      department: json['department'] ?? '',
      portfolio: json['portfolio'] ?? '',
      mobileno: json['mobileno'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      town: json['town'] ?? '',
      state: json['state'] ?? '',
      zipcode: json['zipcode'] ?? 0,
      address: json['address'] ?? '',
      idImagePath: json['idimage_path'],
      imagePath: json['image_path'],
      createAt: json['create_at'] != null
          ? DateTime.tryParse(json['create_at'])
          : null,
      token: json['token'] ?? '',
      projectionPrice: json['projection_price'],
      projectionTarget: json['projection_target'],
      cancelEventReason: json['cancel_event_reason'],
      appStatus: json['app_status'],
      usertype: json['usertype'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'salesman_id': salesmanId,
      'fullname': fullname,
      'lastname': lastname,
      'department': department,
      'portfolio': portfolio,
      'mobileno': mobileno,
      'email': email,
      'password': password,
      'town': town,
      'state': state,
      'zipcode': zipcode,
      'address': address,
      'idimage_path': idImagePath,
      'image_path': imagePath,
      'create_at': createAt?.toIso8601String(),
      'token': token,
      'projection_price': projectionPrice,
      'projection_target': projectionTarget,
      'cancel_event_reason': cancelEventReason,
      'app_status': appStatus,
      'usertype': usertype,
      'status': status,
    };
  }
}

class SalesmanResponse {
  int statusCode;
  bool status;
  String message;
  List<SalesmanData> data;

  SalesmanResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory SalesmanResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<SalesmanData> adminList =
        list.map((i) => SalesmanData.fromJson(i)).toList();

    return SalesmanResponse(
      statusCode: json['status_code'],
      status: json['status'],
      message: json['message'],
      data: adminList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'status': status,
      'message': message,
      'data': data.map((admin) => admin.toJson()).toList(),
    };
  }
}

class FetchSpecificOrderInvoice {
  int statusCode;
  bool status;
  String message;
  SpecificOrderData? data;

  FetchSpecificOrderInvoice({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory FetchSpecificOrderInvoice.fromJson(Map<String, dynamic> json) =>
      FetchSpecificOrderInvoice(
        statusCode: json["status_code"],
        status: json["status"],
        message: json["message"],
        data: SpecificOrderData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status_code": statusCode,
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

class SpecificOrderData {
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
  String? latitude;
  String? longitude;
  String? businessName;
  String? businessNo;
  String? tfn;
  String? addressCheckbox;
  String? deliveryAddress;
  String? deliveryTown;
  String? deliveryState;
  int? deliveryZipcode;
  String? remark;
  String? imageUrl;
  String? salesmanId;
  int? status;
  DateTime? createAt;
  String? createdBy;
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
  int? notificationStatus;
  dynamic orderCreatedStored;
  List<SpecificOrderCart>? cart;
  List<Invoice>? invoice;
  List<SpecificTax>? tax;
  String? orderSource;
  DateTime? generateAt;
  num? amount;

  SpecificOrderData({
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
    this.latitude,
    this.longitude,
    this.businessName,
    this.businessNo,
    this.tfn,
    this.addressCheckbox,
    this.deliveryAddress,
    this.deliveryTown,
    this.deliveryState,
    this.deliveryZipcode,
    this.remark,
    this.imageUrl,
    this.salesmanId,
    this.status,
    this.createAt,
    this.createdBy,
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
    this.notificationStatus,
    this.orderCreatedStored,
    this.cart,
    this.invoice,
    this.tax,
    this.orderSource,
    this.generateAt,
    this.amount,
  });

  factory SpecificOrderData.fromJson(Map<String, dynamic> json) =>
      SpecificOrderData(
        id: json["id"] as int?,
        customerId: json["customer_id"]?.toString() ?? '',
        cartId: json["cart_id"]?.toString() ?? '',
        fullname: json["fullname"]?.toString() ?? '',
        mobileno: json["mobileno"]?.toString() ?? '',
        email: json["email"]?.toString() ?? '',
        town: json["town"]?.toString() ?? '',
        state: json["state"]?.toString() ?? '',
        zipcode: json["zipcode"] as int?,
        address: json["address"]?.toString() ?? '',
        latitude: json["latitude"]?.toString() ?? '',
        longitude: json["longitude"]?.toString() ?? '',
        businessName: json["business_name"]?.toString() ?? '',
        businessNo: json["business_no"]?.toString() ?? '',
        tfn: json["tfn"]?.toString() ?? '',
        addressCheckbox: json["addressCheckbox"]?.toString() ?? '',
        deliveryAddress: json["delivery_address"]?.toString() ?? '',
        deliveryTown: json["delivery_town"]?.toString() ?? '',
        deliveryState: json["delivery_state"]?.toString() ?? '',
        deliveryZipcode: json["delivery_zipcode"] as int?,
        remark: json["remark"]?.toString() ?? '',
        imageUrl: json["image_url"]?.toString(),
        salesmanId: json["salesman_id"]?.toString() ?? '',
        status: json["status"] as int?,
        createAt: json["create_at"] != null
            ? DateTime.tryParse(json["create_at"])
            : null,
        createdBy: json["created_by"]?.toString() ?? '',
        salesmanName: json["salesman_name"]?.toString() ?? '',
        discount: json["discount"]?.toString() ?? '',
        eventType: json["event_type"] as int?,
        eventDays: json["event_days"] as String?,
        creditPeriod: json["credit_period"] as int?,
        companyId: json["company_id"] as int?,
        orderId: json["order_id"]?.toString() ?? '',
        paymentStatus: json["payment_status"] as int?,
        paymentType: json["payment_type"] as int?,
        paymentDetail: json["payment_detail"]?.toString() ?? '',
        orderStatus: json["order_status"] as int?,
        orderCreatAt: json["order_creat_at"] != null
            ? DateTime.tryParse(json["order_creat_at"])
            : null,
        orderTotal: json["order_total"] as num?,
        receivedAmount: json["received_amount"] as num?,
        receivedAmountDate: json["received_amount_date"] != null
            ? DateTime.tryParse(json["received_amount_date"])
            : null,
        checkDueDate: json["check_due_date"] != null
            ? DateTime.tryParse(json["check_due_date"])
            : null,
        checkNumber: json["check_number"] as int?,
        transactionDate: json["transaction_date"] != null
            ? DateTime.tryParse(json["transaction_date"])
            : null,
        transactionDetails: json["transaction_details"]?.toString() ?? '',
        rejectionReason: json["rejection_reason"]?.toString() ?? '',
        rejectedDate: json["rejected_date"],
        receivableAmount: json["receivable_amount"],
        deliveryDatetime: json["delivery_datetime"] != null
            ? DateTime.tryParse(json["delivery_datetime"])
            : null,
        notificationStatus: json["notification_status"] as int?,
        orderCreatedStored: json["order_created_stored"],
        cart: (json["cart"] as List<dynamic>?)
            ?.map((e) => SpecificOrderCart.fromJson(e))
            .toList(),
        invoice: (json["invoice"] as List<dynamic>?)
            ?.map((e) => Invoice.fromJson(e))
            .toList(),
        tax: (json["tax"] as List<dynamic>?)
            ?.map((e) => SpecificTax.fromJson(e))
            .toList(),
        orderSource: json["order_source"]?.toString(),
        generateAt: json["generated_date"] != null
            ? DateTime.tryParse(json["generated_date"])
            : null,
        amount: json["amount"] != null ? num.tryParse(json["amount"].toString()) : null,
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
        "latitude": latitude,
        "longitude": longitude,
        "business_name": businessName,
        "business_no": businessNo,
        "tfn": tfn,
        "addressCheckbox": addressCheckbox,
        "delivery_address": deliveryAddress,
        "delivery_town": deliveryTown,
        "delivery_state": deliveryState,
        "delivery_zipcode": deliveryZipcode,
        "remark": remark,
        "image_url": imageUrl,
        "salesman_id": salesmanId,
        "status": status,
        "create_at": createAt!.toIso8601String(),
        "created_by": createdBy,
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
        "order_creat_at": orderCreatAt!.toIso8601String(),
        "order_total": orderTotal,
        "received_amount": receivedAmount,
        "received_amount_date": receivedAmountDate!.toIso8601String(),
        "check_due_date": checkDueDate!.toIso8601String(),
        "check_number": checkNumber,
        "transaction_date": transactionDate!.toIso8601String(),
        "transaction_details": transactionDetails,
        "rejection_reason": rejectionReason,
        "rejected_date": rejectedDate,
        "receivable_amount": receivableAmount,
        "delivery_datetime": deliveryDatetime!.toIso8601String(),
        "notification_status": notificationStatus,
        "order_created_stored": orderCreatedStored,
        "cart": List<dynamic>.from(cart!.map((x) => x.toJson())),
        "invoice": List<dynamic>.from(invoice!.map((x) => x.toJson())),
        "tax": List<dynamic>.from(tax!.map((x) => x.toJson())),
        "order_source": orderSource,
        "generated_date": generateAt?.toIso8601String(),
        "amount": amount,
      };
}

class SpecificOrderCart {
  int? id;
  String? cartId;
  String? productId;
  String? variationId;
  num? price;
  dynamic reason;
  int? quantity;
  int? pieces;
  String? packType;
  num? totalPrice;
  int? status;
  int? orderPlaceStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? variationName;
  String? productName;
  int? catId;
  dynamic taxName;
  num? tax;
  num? discountValue;
  num? discountPer;
  num? discount;
  List<TaxDatum>? taxData;
  String? inclTax;
  String? discountAmount;
  String? unitPrice;

  SpecificOrderCart({
    this.id,
    this.cartId,
    this.productId,
    this.variationId,
    this.price,
    this.reason,
    this.quantity,
    this.pieces,
    this.packType,
    this.totalPrice,
    this.status,
    this.orderPlaceStatus,
    this.createdAt,
    this.updatedAt,
    this.variationName,
    this.productName,
    this.catId,
    this.taxName,
    this.tax,
    this.discountValue,
    this.discountPer,
    this.discount,
    this.taxData,
    this.inclTax,
    this.discountAmount,
    this.unitPrice,
  });

  factory SpecificOrderCart.fromJson(Map<String, dynamic> json) =>
      SpecificOrderCart(
        id: json["id"],
        cartId: json["cart_id"],
        productId: json["product_id"],
        variationId: json["variation_id"],
        price: json["price"],
        reason: json["reason"],
        quantity: json["quantity"],
        pieces: json["pieces"],
        packType: json["packType"],
        totalPrice: json["total_price"],
        status: json["status"],
        orderPlaceStatus: json["order_place_status"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
        variationName: json["variation_name"],
        productName: json["product_name"],
        catId: json["catId"],
        taxName: json["tax_name"],
        tax: num.tryParse(json["tax"].toString()) ?? 0,
        discountValue: json["discount_value"],
        discountPer: json["discount_per"],
        discount: json["discount"],
        taxData: json["taxData"] != null
            ? List<TaxDatum>.from(
                json["taxData"].map((x) => TaxDatum.fromJson(x)))
            : [],
        inclTax: json["incl_tax"],
        discountAmount: json["discount_amount"]?.toString(),
        unitPrice: json["unit_price"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cart_id": cartId,
        "product_id": productId,
        "variation_id": variationId,
        "price": price,
        "reason": reason,
        "quantity": quantity,
        "pieces": pieces,
        "packType": packType,
        "total_price": totalPrice,
        "status": status,
        "order_place_status": orderPlaceStatus,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "variation_name": variationName,
        "product_name": productName,
        "catId": catId,
        "tax_name": taxName,
        "tax": tax,
        "discount_value": discountValue,
        "discount_per": discountPer,
        "discount": discount,
        "taxData": taxData != null
            ? List<dynamic>.from(taxData!.map((x) => x.toJson()))
            : [],
        "incl_tax": inclTax,
        "discount_amount": discountAmount,
        "unit_price": unitPrice,
      };
}

class TaxDatum {
  String taxName;
  int tax;

  TaxDatum({
    required this.taxName,
    required this.tax,
  });

  factory TaxDatum.fromJson(Map<String, dynamic> json) => TaxDatum(
        taxName: json["tax_name"],
        tax: json["tax"],
      );

  Map<String, dynamic> toJson() => {
        "tax_name": taxName,
        "tax": tax,
      };
}

class SpecificTax {
  String? taxName;
  int? tax;
  String? taxableValues;
  num? taxAmount;

  SpecificTax({
    this.taxName,
    this.tax,
    this.taxableValues,
    this.taxAmount,
  });

  factory SpecificTax.fromJson(Map<String, dynamic> json) => SpecificTax(
        taxName: json["tax_name"],
        tax: json["tax"],
        taxableValues: json["taxable_value"],
        taxAmount: json["tax_amount"],
      );

  Map<String, dynamic> toJson() => {
        "tax_name": taxName,
        "tax": tax,
        "taxable_value": taxableValues,
        "tax_amount": taxAmount,
      };
}
