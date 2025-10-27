class CustomerDashboardResponse {
  final int? statusCode;
  final bool? status;
  final String? message;
  final Data? data;

  CustomerDashboardResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  CustomerDashboardResponse.fromJson(Map<String, dynamic> json)
      : statusCode = json['status_code'] as int?,
        status = json['status'] as bool?,
        message = json['message'] as String?,
        data = (json['data'] as Map<String, dynamic>?) != null
            ? Data.fromJson(json['data'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status': status,
        'message': message,
        'data': data?.toJson()
      };
}

class Data {
  final List<CategoryPerformance>? categoryPerformance;
  final List<RecentOrders>? recentOrders;
  final List<FrequantliyProductLists>? frequantliyProductLists;
  final List<YearList>? yearList;

  Data({
    this.categoryPerformance,
    this.recentOrders,
    this.frequantliyProductLists,
    this.yearList,
  });

  Data.fromJson(Map<String, dynamic> json)
      : categoryPerformance = (json['category_performance'] as List?)
            ?.map((dynamic e) =>
                CategoryPerformance.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentOrders = (json['recent_orders'] as List?)
            ?.map(
                (dynamic e) => RecentOrders.fromJson(e as Map<String, dynamic>))
            .toList(),
        frequantliyProductLists = (json['frequantliy_product_lists'] as List?)
            ?.map((dynamic e) =>
                FrequantliyProductLists.fromJson(e as Map<String, dynamic>))
            .toList(),
        yearList = (json['year_list'] as List?)
            ?.map((dynamic e) => YearList.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'category_performance':
            categoryPerformance?.map((e) => e.toJson()).toList(),
        'recent_orders': recentOrders?.map((e) => e.toJson()).toList(),
        'frequantliy_product_lists':
            frequantliyProductLists?.map((e) => e.toJson()).toList(),
        'year_list': yearList?.map((e) => e.toJson()).toList()
      };
}

class CategoryPerformance {
  final int? cid;
  final String? category;
  final int? count;
  final List<Month>? month;

  CategoryPerformance({
    this.cid,
    this.category,
    this.count,
    this.month,
  });

  CategoryPerformance.fromJson(Map<String, dynamic> json)
      : cid = json['cid'] as int?,
        category = json['category'] as String?,
        count = json['count'] as int?,
        month = (json['month'] as List?)
            ?.map((dynamic e) => Month.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'category': category,
        'count': count,
        'month': month?.map((e) => e.toJson()).toList()
      };
}

class Month {
  final String? month;
  final int? totalCount;

  Month({
    this.month,
    this.totalCount,
  });

  Month.fromJson(Map<String, dynamic> json)
      : month = json['month'] as String?,
        totalCount = json['total_count'] as int?;

  Map<String, dynamic> toJson() => {'month': month, 'total_count': totalCount};
}

class RecentOrders {
  final String? orderId;
  final String? orderCreatAt;
  final int? orderTotal;
  final int? orderStatus;
  final int? paymentStatus;

  RecentOrders({
    this.orderId,
    this.orderCreatAt,
    this.orderTotal,
    this.orderStatus,
    this.paymentStatus,
  });

  RecentOrders.fromJson(Map<String, dynamic> json)
      : orderId = json['order_id'] as String?,
        orderCreatAt = json['order_creat_at'] as String?,
        orderTotal = json['order_total'] as int?,
        orderStatus = json['order_status'] as int?,
        paymentStatus = json['payment_status'] as int?;

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'order_creat_at': orderCreatAt,
        'order_total': orderTotal,
        'order_status': orderStatus,
        'payment_status': paymentStatus
      };
}

class FrequantliyProductLists {
  final String? variationId;
  final String? variationName;
  final String? price;
  final String? quantity;
  final String? totalPrice;
  final String? createdAt;
  final List<Customer>? customer;
  final List<QuantityList>? quantityList;

  FrequantliyProductLists({
    this.variationId,
    this.variationName,
    this.price,
    this.quantity,
    this.totalPrice,
    this.createdAt,
    this.customer,
    this.quantityList,
  });

  FrequantliyProductLists.fromJson(Map<String, dynamic> json)
      : variationId = json['variation_id'] as String?,
        variationName = json['variation_name'] as String?,
        price = json['price'] as String?,
        quantity = json['quantity'] as String?,
        totalPrice = json['total_price'] as String?,
        createdAt = json['created_at'] as String?,
        customer = (json['customer'] as List?)
            ?.map((dynamic e) => Customer.fromJson(e as Map<String, dynamic>))
            .toList(),
        quantityList = (json['quantityList'] as List?)
            ?.map(
                (dynamic e) => QuantityList.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'variation_id': variationId,
        'variation_name': variationName,
        'price': price,
        'quantity': quantity,
        'total_price': totalPrice,
        'created_at': createdAt,
        'customer': customer?.map((e) => e.toJson()).toList(),
        'quantityList': quantityList?.map((e) => e.toJson()).toList()
      };
}

class Customer {
  final dynamic cartId;
  final String? customerId;
  final int? id;
  final String? fullname;
  final String? mobileno;
  final String? email;
  final String? town;
  final String? state;
  final int? zipcode;
  final String? address;
  final String? businessName;
  final String? businessNo;
  final String? remark;
  final String? imageUrl;
  final String? salesmanId;
  final int? status;
  final String? createAt;
  final String? salesmanName;
  final String? discount;
  final int? eventType;
  final String? eventDays;

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
  });

  Customer.fromJson(Map<String, dynamic> json)
      : cartId = json['cart_id'],
        customerId = json['customer_id'] as String?,
        id = json['id'] as int?,
        fullname = json['fullname'] as String?,
        mobileno = json['mobileno'] as String?,
        email = json['email'] as String?,
        town = json['town'] as String?,
        state = json['state'] as String?,
        zipcode = json['zipcode'] as int?,
        address = json['address'] as String?,
        businessName = json['business_name'] as String?,
        businessNo = json['business_no'] as String?,
        remark = json['remark'] as String?,
        imageUrl = json['image_url'] as String?,
        salesmanId = json['salesman_id'] as String?,
        status = json['status'] as int?,
        createAt = json['create_at'] as String?,
        salesmanName = json['salesman_name'] as String?,
        discount = json['discount'] as String?,
        eventType = json['event_type'] as int?,
        eventDays = json['event_days'] as String?;

  Map<String, dynamic> toJson() => {
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
        'salesman_id': salesmanId,
        'status': status,
        'create_at': createAt,
        'salesman_name': salesmanName,
        'discount': discount,
        'event_type': eventType,
        'event_days': eventDays
      };
}

class QuantityList {
  final int? quantity;
  final String? createdAt;

  QuantityList({
    this.quantity,
    this.createdAt,
  });

  QuantityList.fromJson(Map<String, dynamic> json)
      : quantity = json['quantity'] as int?,
        createdAt = json['created_at'] as String?;

  Map<String, dynamic> toJson() =>
      {'quantity': quantity, 'created_at': createdAt};
}

class YearList {
  final int? year;

  YearList({
    this.year,
  });

  YearList.fromJson(Map<String, dynamic> json) : year = json['year'] as int?;

  Map<String, dynamic> toJson() => {'year': year};
}
