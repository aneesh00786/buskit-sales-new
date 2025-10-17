import 'package:hive/hive.dart';

part 'cart_data_model.g.dart';

@HiveType(typeId: 8)
class AddToCartModel extends HiveObject {
  @HiveField(0)
  String customerId;

  @HiveField(1)
  String salesmanId;

  @HiveField(2)
  String total;

  @HiveField(4)
  String cartId;

  @HiveField(5)
  List<SendCartData> cartList;

  AddToCartModel({
    required this.customerId,
    required this.salesmanId,
    required this.total,
    required this.cartId,
    required this.cartList,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'salesman_id': salesmanId,
      'total': total,
      'cart_id': cartId,
      'cart_list': cartList.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 9)
class SendCartData extends HiveObject {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String variantId;

  @HiveField(2)
  String pack;

  @HiveField(3)
  String packType;

  @HiveField(4)
  String price;

  @HiveField(5)
  num discount;

  @HiveField(6)
  int quantity;

  @HiveField(7)
  String variantName;

  @HiveField(8)
  int? maxDiscount;

  @HiveField(9)
  bool? isPromo;

  @HiveField(10)
  String? promoCode;

  @HiveField(11)
  String? promoMsg;

  @HiveField(12)
  bool? isBundle;

  @HiveField(13)
  String? bundleDetails;

  SendCartData({
    required this.productId,
    required this.variantId,
    required this.pack,
    required this.packType,
    required this.price,
    required this.discount,
    required this.quantity,
    required this.variantName,
    this.maxDiscount,
    this.isPromo,
    this.promoCode,
    this.promoMsg,
    this.isBundle,
    this.bundleDetails,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'product_id': productId,
      'Varient': variantId,
      'Pack': pack,
      'packType': packType,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'variant_name': variantName,
      'max_discount': maxDiscount,
      'is_promo': isPromo,
      'promo_code': promoCode,
      'promo_msg': promoMsg,
    };

    // Add bundle-specific fields if this is a bundle
    if (isBundle == true) {
      json['is_bundle'] = true;
      json['bundle_details'] = bundleDetails;
    }

    return json;
  }
}
