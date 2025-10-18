//cart_model

import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:hive_flutter/adapters.dart';
part 'cart_model.g.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  final Detail detail;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  double totalPrice;

  @HiveField(3)
  final bool? isPack;

  @HiveField(4)
  int? count;

  @HiveField(5)
  String? customerId;

  @HiveField(6)
  String? cartId;

  @HiveField(7)
  String? draftId;

  @HiveField(8)
  bool? isChecked;

  @HiveField(9)
  num? draftTotal;

  @HiveField(10)
  String? salesmanId;

  @HiveField(11)
  bool? boxType;

  @HiveField(12)
  int? catId;

  @HiveField(13)
  bool? isPromo;

  @HiveField(14)
  String? promoCode;

  @HiveField(15)
  String? promoMsg;

  @HiveField(16)
  List<BundleItem>? bundleItems;

  @HiveField(17)
  String? title;

  @HiveField(18)
  String? bundlePrice;

  CartItem({
    required this.detail,
    required this.productName,
    required this.totalPrice,
    this.isPack,
    this.count,
    this.customerId,
    this.cartId,
    this.draftId,
    this.isChecked = true,
    this.draftTotal,
    this.salesmanId,
    this.boxType,
    this.catId,
    this.isPromo,
    this.promoCode,
    this.promoMsg,
    this.bundleItems,
    this.title,
    this.bundlePrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      detail: Detail.fromJson(json['detail'] ?? {}),
      productName: json['productName'] ?? '',
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      isPack: json['isPack'] as bool?,
      count: json['count'] as int?,
      customerId: json['customer_id'] as String?,
      cartId: json['cart_id'] as String?,
      draftId: json['id'].toString(),
      isChecked: json['isChecked'] as bool? ?? true,
      draftTotal: json['order_total'] as num? ?? 0,
      salesmanId: json['salesman_id'] as String?,
      boxType: json['boxType'],
      catId: json['categories_id'],
      isPromo: json['is_promo'] == 1 ? true : false,
      promoCode: json['promo_code'],
      promoMsg: json['promo_msg'],
      bundleItems: json['bundle_items'],
      title: json['title'],
      bundlePrice: json['bundle_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail.toJson(),
      'productName': productName,
      'totalPrice': totalPrice,
      'isPack': isPack,
      'count': count,
      'customer_id': customerId,
      'cart_id': cartId,
      'id': draftId,
      'isChecked': isChecked,
      'order_total': draftTotal,
      'salesman_id': salesmanId,
      'boxType': boxType,
      'categories_id': catId,
      'is_promo': isPromo,
      'promo_code': promoCode,
      'promo_msg': promoMsg,
      'bundle_items': bundleItems,
      'title': title,
      'bundle_price': bundlePrice
    };
  }

  CartItem copyWith({
    Detail? detail,
    String? productName,
    double? totalPrice,
    bool? isPack,
    int? count,
    String? customerId,
    String? cartId,
    String? draftId,
    bool? isChcked,
    num? draftTotal,
    String? salesmanId,
    bool? boxType,
    int? catId,
    bool? isPromo,
    String? promoCode,
    String? promoMsg,
    List<BundleItem>? bundleItems,
    String? title,
    String? bundlePrice,
  }) {
    return CartItem(
      detail: detail ?? this.detail,
      productName: productName ?? this.productName,
      totalPrice: totalPrice ?? this.totalPrice,
      isPack: isPack ?? this.isPack,
      count: count ?? this.count,
      customerId: customerId ?? this.customerId,
      cartId: cartId ?? this.cartId,
      draftId: draftId ?? this.draftId,
      isChecked: isChcked ?? isChecked,
      draftTotal: draftTotal ?? this.draftTotal,
      salesmanId: salesmanId ?? this.salesmanId,
      boxType: boxType ?? this.boxType,
      catId: catId ?? this.catId,
      isPromo: isPromo ?? this.isPromo,
      promoCode: promoCode ?? this.promoCode,
      promoMsg: promoMsg ?? this.promoMsg,
      bundleItems: bundleItems ?? this.bundleItems,
      title: title ?? this.title,
      bundlePrice: bundlePrice ?? this.bundlePrice,
    );
  }
}

class BundleItem {
  String? productId;
  String? variantId;
  String? bundleItemUnitType;
  int? quantity;
  String? variationName;
  String? unitType;
  String? productName;
  num? unitPrice;
  num? totalPrice;

  BundleItem({
    this.productId,
    this.variantId,
    this.bundleItemUnitType,
    this.quantity,
    this.variationName,
    this.unitType,
    this.productName,
    this.unitPrice,
    this.totalPrice,
  });

  factory BundleItem.fromJson(Map<String, dynamic> json) => BundleItem(
        productId: json["product_id"],
        variantId: json["variant_id"],
        bundleItemUnitType: json["unit_type"],
        quantity: json["quantity"],
        variationName: json["variation_name"],
        unitType: json["unitType"],
        unitPrice: json['unit_price'],
        totalPrice: json['total_price'],
        productName: json['product_name'],
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "variant_id": variantId,
        "unit_type": bundleItemUnitType,
        "quantity": quantity,
        "variation_name": variationName,
        "unitType": unitType,
        "unit_price": unitPrice,
        "total_price": totalPrice,
        "product_name": productName,
      };
}
