



import 'dart:convert';
import 'dart:io';

/// ---------------------------------------------------------------------------
///  Helper
/// ---------------------------------------------------------------------------
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null; // unknown type
}

/// ---------------------------------------------------------------------------
///  ProductReturn (root wrapper)
/// ---------------------------------------------------------------------------
class ProductReturn {
  int? statusCode;
  bool? status;
  List<ProductReturnData>? data;
  int? count;
  String? message;

  ProductReturn({
    this.statusCode,
    this.status,
    this.data,
    this.count,
    this.message,
  });

  factory ProductReturn.fromJson(Map<String, dynamic> json) => ProductReturn(
        statusCode: json['status_code'] as int?,
        status: json['status'] as bool?,
        data: (json['data'] as List<dynamic>?)
            ?.map((e) => ProductReturnData.fromJson(e as Map<String, dynamic>))
            .toList(),
        count: json['count'] as int?,
        message: json['message'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'status_code': statusCode,
        'status': status,
        'data': data?.map((e) => e.toJson()).toList(),
        'count': count,
        'message': message,
      };
}

/// ---------------------------------------------------------------------------
///  ProductReturnData (order level)
/// ---------------------------------------------------------------------------
class ProductReturnData {
  int? id;
  String? orderId;
  String? customerId;
  String? salesmanId;
  int? paymentStatus;
  int? paymentType;
  String? paymentDetail;
  int? orderStatus;
  String? cartId;
  DateTime? generatedDate;
  DateTime? orderCreatAt;
  String? statusChanged;

  // ---- monetary fields ----------------------------------------------------
  double? orderTotal;      // <-- double
  double? receivedAmount;  // <-- double

  DateTime? receivedAmountDate;
  DateTime? checkDueDate;
  int? checkNumber;
  DateTime? transactionDate;
  String? transactionDetails;
  String? rejectionReason;
  dynamic rejectedDate;
  int? receivableAmount;
  DateTime? deliveryDatetime;
  int? notificationStatus;
  dynamic orderCreatedStored;
  int? companyId;

  // ---- customer info ------------------------------------------------------
  String? mobileno;
  String? salesmanName;
  String? fullname;
  String? imageUrl;
  String? businessName;
  String? email;
  String? address;

  List<Cart>? cart;
  List<Invoice>? invoice;
  List<TaxItem>? tax; // <-- a tiny model for the tax array (optional)

  ProductReturnData({
    this.id,
    this.orderId,
    this.customerId,
    this.salesmanId,
    this.paymentStatus,
    this.paymentType,
    this.paymentDetail,
    this.orderStatus,
    this.cartId,
    this.generatedDate,
    this.orderCreatAt,
    this.statusChanged,
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
    this.mobileno,
    this.salesmanName,
    this.fullname,
    this.imageUrl,
    this.businessName,
    this.email,
    this.address,
    this.cart,
    this.invoice,
    this.tax,
  });

  factory ProductReturnData.fromJson(Map<String, dynamic> json) {
    return ProductReturnData(
      id: json['id'] as int?,
      orderId: json['order_id'] as String?,
      customerId: json['customer_id'] as String?,
      salesmanId: json['salesman_id'] as String?,
      paymentStatus: json['payment_status'] as int?,
      paymentType: json['payment_type'] as int?,
      paymentDetail: json['payment_detail'] as String?,
      orderStatus: json['order_status'] as int?,
      cartId: json['cart_id'] as String?,
      generatedDate: json['generated_date'] == null
          ? null
          : DateTime.parse(json['generated_date'] as String),
      orderCreatAt: json['order_creat_at'] == null
          ? null
          : DateTime.parse(json['order_creat_at'] as String),
      statusChanged: json['status_changed'] as String?,
      orderTotal: _toDouble(json['order_total']),
      receivedAmount: _toDouble(json['received_amount']),
      receivedAmountDate: json['received_amount_date'] == null
          ? null
          : DateTime.parse(json['received_amount_date'] as String),
      checkDueDate: json['check_due_date'] == null
          ? null
          : DateTime.parse(json['check_due_date'] as String),
      checkNumber: json['check_number'] as int?,
      transactionDate: json['transaction_date'] == null
          ? null
          : DateTime.parse(json['transaction_date'] as String),
      transactionDetails: json['transaction_details'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      rejectedDate: json['rejected_date'],
      receivableAmount: json['receivable_amount'] as int?,
      deliveryDatetime: json['delivery_datetime'] == null
          ? null
          : DateTime.parse(json['delivery_datetime'] as String),
      notificationStatus: json['notification_status'] as int?,
      orderCreatedStored: json['order_created_stored'],
      companyId: json['company_id'] as int?,
      mobileno: json['mobileno'] as String?,
      salesmanName: json['salesman_name'] as String?,
      fullname: json['fullname'] as String?,
      imageUrl: json['image_url'] as String?,
      businessName: json['business_name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      cart: (json['cart'] as List<dynamic>?)
          ?.map((e) => Cart.fromJson(e as Map<String, dynamic>))
          .toList(),
      invoice: (json['invoice'] as List<dynamic>?)
          ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      tax: (json['tax'] as List<dynamic>?)
          ?.map((e) => TaxItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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
        'generated_date': generatedDate?.toIso8601String(),
        'order_creat_at': orderCreatAt?.toIso8601String(),
        'status_changed': statusChanged,
        'order_total': orderTotal,
        'received_amount': receivedAmount,
        'received_amount_date': receivedAmountDate?.toIso8601String(),
        'check_due_date': checkDueDate?.toIso8601String(),
        'check_number': checkNumber,
        'transaction_date': transactionDate?.toIso8601String(),
        'transaction_details': transactionDetails,
        'rejection_reason': rejectionReason,
        'rejected_date': rejectedDate,
        'receivable_amount': receivableAmount,
        'delivery_datetime': deliveryDatetime?.toIso8601String(),
        'notification_status': notificationStatus,
        'order_created_stored': orderCreatedStored,
        'company_id': companyId,
        'mobileno': mobileno,
        'salesman_name': salesmanName,
        'fullname': fullname,
        'image_url': imageUrl,
        'business_name': businessName,
        'email': email,
        'address': address,
        'cart': cart?.map((e) => e.toJson()).toList(),
        'invoice': invoice?.map((e) => e.toJson()).toList(),
        'tax': tax?.map((e) => e.toJson()).toList(),
      };
}

/// ---------------------------------------------------------------------------
///  Cart (order line item)
/// ---------------------------------------------------------------------------
class Cart {
  int? id;
  String? cartId;
  String? productId;
  String? variationId;

  double? price;        // <-- double
  dynamic reason;
  int? quantity;
  int? pieces;
  String? packType;
  String? discount;
  String? discountAmount;

  double? totalPrice;   // <-- double
  double? tax;          // <-- double

  String? inclTax;
  int? isPromo;
  int? isBundle;
  String? promoCode;
  int? status;
  int? orderPlaceStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? companyId;
  String? variationName;
  String? productName;
  int? catId;

  int damageQty = 0;
  int returnQty = 0;
  File? image;
  String itemReason = '';
  int? suppliedQty;

  Cart({
    this.id,
    this.cartId,
    this.productId,
    this.variationId,
    this.price,
    this.reason,
    this.quantity,
    this.pieces,
    this.packType,
    this.discount,
    this.discountAmount,
    this.totalPrice,
    this.tax,
    this.inclTax,
    this.isPromo,
    this.isBundle,
    this.promoCode,
    this.status,
    this.orderPlaceStatus,
    this.createdAt,
    this.updatedAt,
    this.companyId,
    this.variationName,
    this.productName,
    this.catId,

    this.damageQty = 0,
    this.returnQty = 0,
    this.image,
    this.itemReason = '',
    this.suppliedQty,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id'] as int?,
        cartId: json['cart_id'] as String?,
        productId: json['product_id'] as String?,
        variationId: json['variation_id'] as String?,
        price: _toDouble(json['price']),
        reason: json['reason'],
        quantity: json['quantity'] as int?,
        pieces: json['pieces'] as int?,
        packType: json['packType'] as String?,
        discount: json['discount'] as String?,
        discountAmount: json['discount_amount'] as String?,
        totalPrice: _toDouble(json['total_price']),
        tax: _toDouble(json['tax']),
        inclTax: json['incl_tax'] as String?,
        isPromo: json['is_promo'] as int?,
        isBundle: json['is_bundle'] as int?,
        promoCode: json['promo_code'] as String?,
        status: json['status'] as int?,
        orderPlaceStatus: json['order_place_status'] as int?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
        companyId: json['company_id'] as int?,
        variationName: json['variation_name'] as String?,
        productName: json['product_name'] as String?,
        catId: json['catId'] as int?,
        damageQty: 0,
        returnQty: 0,
        image: null,
        itemReason: '',
        suppliedQty: json['supplied_qty'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cart_id': cartId,
        'product_id': productId,
        'variation_id': variationId,
        'price': price,
        'reason': reason,
        'quantity': quantity,
        'pieces': pieces,
        'packType': packType,
        'discount': discount,
        'discount_amount': discountAmount,
        'total_price': totalPrice,
        'tax': tax,
        'incl_tax': inclTax,
        'is_promo': isPromo,
        'is_bundle': isBundle,
        'promo_code': promoCode,
        'status': status,
        'order_place_status': orderPlaceStatus,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'company_id': companyId,
        'variation_name': variationName,
        'product_name': productName,
        'catId': catId,
        'supplied_qty': suppliedQty,
      };
}

/// ---------------------------------------------------------------------------
///  Invoice
/// ---------------------------------------------------------------------------
class Invoice {
  int? id;
  int? companyId;
  String? customerId;
  String? invoiceId;
  String? cartId;
  String? orderId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Invoice({
    this.id,
    this.companyId,
    this.customerId,
    this.invoiceId,
    this.cartId,
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as int?,
        companyId: json['company_id'] as int?,
        customerId: json['customer_id'] as String?,
        invoiceId: json['invoice_id'] as String?,
        cartId: json['cart_id'] as String?,
        orderId: json['order_id'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'customer_id': customerId,
        'invoice_id': invoiceId,
        'cart_id': cartId,
        'order_id': orderId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

/// ---------------------------------------------------------------------------
///  TaxItem (the array that comes under "tax")
/// ---------------------------------------------------------------------------
class TaxItem {
  String? taxName;
  int? tax;          // percentage (always int in the sample)
  double? taxAmount; // <-- double

  TaxItem({this.taxName, this.tax, this.taxAmount});

  factory TaxItem.fromJson(Map<String, dynamic> json) => TaxItem(
        taxName: json['tax_name'] as String?,
        tax: json['tax'] as int?,
        taxAmount: _toDouble(json['tax_amount']),
      );

  Map<String, dynamic> toJson() => {
        'tax_name': taxName,
        'tax': tax,
        'tax_amount': taxAmount,
      };
}


