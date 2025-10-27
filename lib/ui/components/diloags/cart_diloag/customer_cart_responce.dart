import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';

class CustomerCartResponce {
  int? statusCode;
  bool? status;
  String? message;
  List<CustomerCartData>? data;

  CustomerCartResponce({
    this.statusCode,
    this.status,
    this.message,
    this.data,
  });

  CustomerCartResponce.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'] as int?;
    status = json['status'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as List?)
        ?.map(
            (dynamic e) => CustomerCartData.fromJson(e as Map<String, dynamic>))
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

class CustomerCartData {
  int? id;
  String? cartId;
  String? customerId;
  String? salesmanId;
  int? total;
  String? discount;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<CustomerCart>? cart;
  CustomerDetails? customerDetails;

  CustomerCartData(
      {this.id,
      this.cartId,
      this.customerId,
      this.salesmanId,
      this.total,
      this.discount,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.cart,
      this.customerDetails});

  CustomerCartData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    cartId = json['cart_id'] as String?;
    customerId = json['customer_id'] as String?;
    salesmanId = json['salesman_id'] as String?;
    total = json['total'] as int?;
    discount = json['discount'] as String?;
    status = json['status'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    cart = (json['cart'] as List?)
        ?.map((dynamic e) => CustomerCart.fromJson(e as Map<String, dynamic>,
            discountPrice: json['discount'] as String?,

            setOrderId: json['cart_id'] as String?,
            setCustomerDetails: json['customer'] != null
                ? CustomerDetails.fromJson((json['customer'] as List).first)
                : null))
        .toList();
    customerDetails = json['customer'] != null
        ? CustomerDetails.fromJson((json['customer'] as List).first)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['cart_id'] = cartId;
    json['customer_id'] = customerId;
    json['salesman_id'] = salesmanId;
    json['total'] = total;
    json['discount'] = discount;
    json['status'] = status;
    json['created_at'] = createdAt;
    json['updated_at'] = updatedAt;
    json['cart'] = cart?.map((e) => e.toJson()).toList();
    return json;
  }
}

class CustomerCart {
  int? id;
  String? productId;
  String? brandname;
  String? productName;
  String? description;
  dynamic reasonBySalesman;
  String? imageUrl;
  int? status;
  String? scid;
  String? variationId;
  String? variationName;
  String? unitType;
  dynamic price;
  num? tax;
  dynamic taxName;
  String? packtype;
  String? packType;
  int? pieces;
  int? stock;
  int? lowstock;
  int? fullstock;
  String? createdAt;
  String? updatedAt;
  String? cartId;
  int? quantity;
  String? discount;
  String? discountAmount;
  dynamic total;
  dynamic totalAmount;
  CustomerDetails? customerDetails;
  String? orderId;
  OptionOrderData? optionOrderData;
  String? salesmanReason;
  String? inclTax;

  CustomerCart({
    this.id,
    this.productId,
    this.brandname,
    this.productName,
    this.description,
    this.reasonBySalesman,
    this.imageUrl,
    this.status,
    this.scid,
    this.variationId,
    this.variationName,
    this.unitType,
    this.price,
    this.tax,
    this.taxName,
    this.packtype,
    this.packType,
    this.pieces,
    this.stock,
    this.lowstock,
    this.fullstock,
    this.createdAt,
    this.updatedAt,
    this.cartId,
    this.salesmanReason,
    this.quantity,
    this.discount,
    this.discountAmount,
    this.total,
    this.totalAmount,
    this.orderId,
    this.customerDetails,
    this.inclTax,
  });

  CustomerCart.fromJson(
    Map<String, dynamic> json, {

    String? discountPrice,
    String? discountAmount,
    String? setOrderId,
    CustomerDetails? setCustomerDetails,
    OptionOrderData? setOptionOrderData,
  }) {
    id = json['id'];
    productId = json['product_id'];
    brandname = json['brandname'];
    productName = json['product_name'];
    description = json['description'];
    reasonBySalesman = json['reason_by_salesman'];
    imageUrl = json['image_url'];
    status = json['status'];
    scid = json['scid'];
    variationId = json['variation_id'];
    variationName = json['variation_name'];
    unitType = json['unitType'];
    price = json['price'];

    tax = num.tryParse(json['tax'].toString()) ?? 0;
    taxName = json['tax_name'];
    packtype = json['packtype'];
    packType = json['packType'];
    pieces = json['pieces'];
    stock = json['stock'];
    lowstock = json['lowstock'];
    fullstock = json['fullstock'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cartId = json['cart_id'];
    quantity = json['quantity'];
    salesmanReason = json['reason'] ?? '';
    discount = discountPrice;
    discountAmount = discountAmount;

    total = json['total_price'];
    totalAmount = json['total_amount'];

    customerDetails = setCustomerDetails;
    orderId = setOrderId;
    optionOrderData = setOptionOrderData;
    inclTax = json['incl_tax'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['product_id'] = productId;
    json['brandname'] = brandname;
    json['product_name'] = productName;
    json['description'] = description;
    json['reason_by_salesman'] = reasonBySalesman;
    json['image_url'] = imageUrl;
    json['status'] = status;
    json['scid'] = scid;
    json['variation_id'] = variationId;
    json['variation_name'] = variationName;
    json['unitType'] = unitType;
    json['price'] = price;
    json['tax'] = tax;
    json['tax_name'] = taxName;
    json['packtype'] = packtype;
    json['packType'] = packType;
    json['pieces'] = pieces;
    json['stock'] = stock;
    json['lowstock'] = lowstock;
    json['fullstock'] = fullstock;
    json['created_at'] = createdAt;
    json['updated_at'] = updatedAt;
    json['cart_id'] = cartId;
    json['quantity'] = quantity;
    json['total_price'] = total;
    json['total_amount'] = totalAmount;
    json['incl_tax'] = inclTax;
    return json;
  }
}

class CustomerDetails {
  int? id;
  String? customerId;
  String? eventId;
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
  bool isSelected = true;

  CustomerDetails({
    this.id,
    this.customerId,
    this.cartId,
    this.fullname,
    this.mobileno,
    this.email,
    this.town,
    this.state,
    this.zipcode,
    this.eventId,
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
  });

  CustomerDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    customerId = json['customer_id'] as String?;
    cartId = json['cart_id'] as String?;
    fullname = json['fullname'] as String?;
    mobileno = json['mobileno'] as String?;
    email = json['email'] as String?;
    town = json['town'] as String?;
    state = json['state'] as String?;
    zipcode = json['zipcode'] as int?;
    address = json['address'] as String?;
    businessName = json['business_name'] as String?;
    businessNo = json['business_no'] as String?;
    remark = json['remark'] as String?;
    imageUrl = json['image_url'] as String?;
    salesmanId = json['salesman_id'] as String?;
    status = json['status'] as int?;
    createAt = json['create_at'] as String?;
    salesmanName = json['salesman_name'] as String?;
    discount = json['discount'] as String?;
    eventType = json['event_type'] as int?;
    eventId = json['event_id'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['customer_id'] = customerId;
    json['cart_id'] = cartId;
    json['fullname'] = fullname;
    json['mobileno'] = mobileno;
    json['email'] = email;
    json['town'] = town;
    json['state'] = state;
    json['zipcode'] = zipcode;
    json['address'] = address;
    json['business_name'] = businessName;
    json['business_no'] = businessNo;
    json['remark'] = remark;
    json['image_url'] = imageUrl;
    json['salesman_id'] = salesmanId;
    json['status'] = status;
    json['create_at'] = createAt;
    json['salesman_name'] = salesmanName;
    json['discount'] = discount;
    json['event_type'] = eventType;
    json['event_id'] = eventId;
    return json;
  }
}

class CartOrderModel {
  String? customerId;
  String? salesmanId;
  String cartId;
  int? orderStatus;
  int? companyId;
  String? paymentType;
  double? orderPrice;
  String? transactionNumber;
  String? transactionDate;
  String? paymentDetail;
  String? draftId;
  int? selctedItemCount;
  List<String>? varientIds;

  CartOrderModel({
    this.customerId,
    this.salesmanId,
    required this.cartId,
    this.orderStatus,
    this.companyId,
    this.paymentType,
    this.orderPrice,
    this.transactionNumber,
    this.transactionDate,
    this.paymentDetail,
    this.draftId,
    this.selctedItemCount,
    this.varientIds,
  });

  factory CartOrderModel.fromJson(Map<String, dynamic> json) {
    return CartOrderModel(
      customerId: json['customer_id'],
      salesmanId: json['salesman_id'],
      cartId: json['cart_id'],
      orderStatus: json['order_status'],
      companyId: json['companyId'],
      paymentType: json['payment_type'],
      orderPrice: json['order_price']?.toDouble(),
      transactionNumber: json['cheque_number'] ?? json['transaction_number'],
      transactionDate: json['cheque_date'] ?? json['transaction_date'],
      paymentDetail: json['payment_detail'],
      draftId: json['draft_id'],
      selctedItemCount: json['item_count'],
      varientIds: json['varient_ids'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'salesman_id': salesmanId,
      'cart_id': cartId,
      'order_status': orderStatus,
      'companyId': companyId,
      'payment_type': paymentType,
      'order_price': orderPrice,
      if (transactionNumber != null)
        paymentType == "1" ? 'cheque_number' : 'transaction_number':
            transactionNumber,
      if (transactionDate != null)
        paymentType == "1" ? 'cheque_date' : 'transaction_date':
            transactionDate,
      'payment_detail': paymentDetail,
      'draft_id': draftId,
      'item_count': selctedItemCount,
      'varient_ids': varientIds,
    };
  }
}

class BuyProductResponce {
  String customerId;
  String salesmanId;
  int paymentStatus;
  int orderStatus;
  String cartId;
  String orderPrice;
  String orderId;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['customer_id'] = customerId;
    json['salesman_id'] = salesmanId;
    json['payment_status'] = paymentStatus;
    json['order_status'] = orderStatus;
    json['cart_id'] = cartId;
    json['order_price'] = orderPrice;
    json['order_id'] = orderId;
    return json;
  }

  BuyProductResponce(
      {required this.customerId,
      required this.salesmanId,
      required this.paymentStatus,
      required this.orderStatus,
      required this.cartId,
      required this.orderPrice,
      required this.orderId});
}
