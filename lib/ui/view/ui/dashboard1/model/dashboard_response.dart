class DashboardResponse {
  final int? statusCode;
  final bool? status;
  final String? message;
  final Data? data;

  DashboardResponse({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  DashboardResponse.fromJson(Map<String, dynamic> json)
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
//  final List<CategoryPerformance>? categoryPerformance;
  final Revenu? revenu;
  final Collection? collection;
  final Delivery? delivery;
  final List<TopSellingProduct>? topSellingProduct;
  final OrderCountList? orderCountList;

  Data({
  //  this.categoryPerformance,
    this.revenu,
    this.collection,
    this.delivery,
    this.topSellingProduct,
    this.orderCountList,
  });

  Data.fromJson(Map<String, dynamic> json)
      : 
        revenu = (json['revenu'] as Map<String, dynamic>?) != null
            ? Revenu.fromJson(json['revenu'] as Map<String, dynamic>)
            : null,
        collection = (json['collection'] as Map<String, dynamic>?) != null
            ? Collection.fromJson(json['collection'] as Map<String, dynamic>)
            : null,
        delivery = (json['delivery'] as Map<String, dynamic>?) != null
            ? Delivery.fromJson(json['delivery'] as Map<String, dynamic>)
            : null,
        topSellingProduct = (json['top_selling_product'] as List?)
            ?.map((dynamic e) =>
                TopSellingProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
        orderCountList =
            (json['order_count_list'] as Map<String, dynamic>?) != null
                ? OrderCountList.fromJson(
                    json['order_count_list'] as Map<String, dynamic>)
                : null;

  Map<String, dynamic> toJson() => {
    
        'revenu': revenu?.toJson(),
        'collection': collection?.toJson(),
        'delivery': delivery?.toJson(),
        'top_selling_product':
            topSellingProduct?.map((e) => e.toJson()).toList(),
        'order_count_list': orderCountList?.toJson()
      };
}

// class CategoryPerformance {
//   final int? cid;
//   final String? category;
//   final int? count;
//   final List<Month>? month;

//   CategoryPerformance({
//     this.cid,
//     this.category,
//     this.count,
//     this.month,
//   });

//   CategoryPerformance.fromJson(Map<String, dynamic> json)
//       : cid = json['cid'] as int?,
//         category = json['category'] as String?,
//         count = json['count'] as int?,
//         month = (json['month'] as List?)
//             ?.map((dynamic e) => Month.fromJson(e as Map<String, dynamic>))
//             .toList();

//   Map<String, dynamic> toJson() => {
//         'cid': cid,
//         'category': category,
//         'count': count,
//         'month': month?.map((e) => e.toJson()).toList()
//       };
// }

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

class Revenu {
  final TotalSell? totalSell;
  final Sell? sell;
  final Order? order;

  Revenu({
    this.totalSell,
    this.sell,
    this.order,
  });

  Revenu.fromJson(Map<String, dynamic> json)
      : totalSell = (json['total_sell'] as Map<String, dynamic>?) != null
            ? TotalSell.fromJson(json['total_sell'] as Map<String, dynamic>)
            : null,
        sell = (json['sell'] as Map<String, dynamic>?) != null
            ? Sell.fromJson(json['sell'] as Map<String, dynamic>)
            : null,
        order = (json['order'] as Map<String, dynamic>?) != null
            ? Order.fromJson(json['order'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        'total_sell': totalSell?.toJson(),
        'sell': sell?.toJson(),
        'order': order?.toJson()
      };
}

class TotalSell {
  final int? count;
  final String? totalPrice;
  final int? percentage;

  TotalSell({
    this.count,
    this.totalPrice,
    this.percentage,
  });

  TotalSell.fromJson(Map<String, dynamic> json)
      : count = json['count'] as int?,
        totalPrice = json['total_price'] as String?,
        percentage = json['percentage'] as int?;

  Map<String, dynamic> toJson() =>
      {'count': count, 'total_price': totalPrice, 'percentage': percentage};
}

class Sell {
  final int? count;
  final String? totalPrice;
  final int? percentage;

  Sell({
    this.count,
    this.totalPrice,
    this.percentage,
  });

  Sell.fromJson(Map<String, dynamic> json)
      : count = json['count'] as int?,
        totalPrice = json['total_price'] as String?,
        percentage = json['percentage'] as int?;

  Map<String, dynamic> toJson() =>
      {'count': count, 'total_price': totalPrice, 'percentage': percentage};
}

// class Order {
//   final int? count;
//   final String? totalPrice;
//   final int? percentage;
//
//   Order({
//     this.count,
//     this.totalPrice,
//     this.percentage,
//   });
//
//   Order.fromJson(Map<String, dynamic> json)
//       : count = json['count'] as int?,
//         totalPrice = json['total_price'] as String?,
//         percentage = json['percentage'] as int?;
//
//   Map<String, dynamic> toJson() =>
//       {'count': count, 'total_price': totalPrice, 'percentage': percentage};
// }

class Collection {
  final Order? order;
  final Payment? payment;

  Collection({
    this.order,
    this.payment,
  });

  Collection.fromJson(Map<String, dynamic> json)
      : order = (json['order'] as Map<String, dynamic>?) != null
            ? Order.fromJson(json['order'] as Map<String, dynamic>)
            : null,
        payment = (json['payment'] as Map<String, dynamic>?) != null
            ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() =>
      {'order': order?.toJson(), 'payment': payment?.toJson()};
}

class Order {
  final int? count;
  dynamic percentage;

  Order({
    this.count,
    this.percentage,
  });

  Order.fromJson(Map<String, dynamic> json)
      : count = json['count'] as int?,
        percentage = json['percentage'];

  Map<String, dynamic> toJson() => {'count': count, 'percentage': percentage};
}

class Payment {
  final int? count;
  dynamic percentage;

  Payment({
    this.count,
    this.percentage,
  });

  Payment.fromJson(Map<String, dynamic> json)
      : count = json['count'] as int?,
        percentage = json['percentage'];

  Map<String, dynamic> toJson() => {'count': count, 'percentage': percentage};
}

class Delivery {
  final Order? order;
  final DeliveryOrder? deliveryOrder;

  Delivery({
    this.order,
    this.deliveryOrder,
  });

  Delivery.fromJson(Map<String, dynamic> json)
      : order = (json['order'] as Map<String, dynamic>?) != null
            ? Order.fromJson(json['order'] as Map<String, dynamic>)
            : null,
        deliveryOrder =
            (json['delivery_order'] as Map<String, dynamic>?) != null
                ? DeliveryOrder.fromJson(
                    json['delivery_order'] as Map<String, dynamic>)
                : null;

  Map<String, dynamic> toJson() =>
      {'order': order?.toJson(), 'delivery_order': deliveryOrder?.toJson()};
}

/*class Order {
  final int? count;
  final String? percentage;

  Order({
    this.count,
    this.percentage,
  });

  Order.fromJson(Map<String, dynamic> json)
      : count = json['count'] as int?,
        percentage = json['percentage'] as String?;

  Map<String, dynamic> toJson() => {
    'count' : count,
    'percentage' : percentage
  };
}*/

class DeliveryOrder {
  final int? count;
  dynamic percentage;

  DeliveryOrder({
    this.count,
    this.percentage,
  });

  DeliveryOrder.fromJson(Map<String, dynamic> json)
      : count = json['count'] as int?,
        percentage = json['percentage'];

  Map<String, dynamic> toJson() => {'count': count, 'percentage': percentage};
}

class TopSellingProduct {
  final String? variationId;
  final String? variationName;
  final String? price;
  final String? quantity;
  final String? totalPrice;
  final String? createdAt;
  final List<Customer>? customer;
  final List<QuantityList>? quantityList;

  TopSellingProduct({
    this.variationId,
    this.variationName,
    this.price,
    this.quantity,
    this.totalPrice,
    this.createdAt,
    this.customer,
    this.quantityList,
  });

  TopSellingProduct.fromJson(Map<String, dynamic> json)
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

class OrderCountList {
  final int? totalOrder;
  final int? estimateOrder;
  final int? preorderOrder;
  final int? draftOrder;

  OrderCountList({
    this.totalOrder,
    this.estimateOrder,
    this.preorderOrder,
    this.draftOrder,
  });

  OrderCountList.fromJson(Map<String, dynamic> json)
      : totalOrder = json['total_order'] as int?,
        estimateOrder = json['estimate_order'] as int?,
        preorderOrder = json['preorder_order'] as int?,
        draftOrder = json['draft_order'] as int?;

  Map<String, dynamic> toJson() => {
        'total_order': totalOrder,
        'estimate_order': estimateOrder,
        'preorder_order': preorderOrder,
        'draft_order': draftOrder
      };
}
