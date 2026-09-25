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

  @HiveField(14)
  double? customerDiscount;


  @HiveField(15)
  num? promoDiscount;


  @HiveField(16)
  bool? isBulk;


  @HiveField(17)
  String? bulkId;

  @HiveField(18)
  num? initialCount;

  @HiveField(19) 
  double? catTax;


  @HiveField(20)  
  double? taxAmount;

  @HiveField(21) 
  int? itemNumbers;

  @HiveField(22) 
  num? flatDiscount;

  @HiveField(23)
  String? unitPrice; 

  @HiveField(24)
  num? bulkDiscountAmount;

  @HiveField(25)
  String? originalUnitPrice;

  @HiveField(26)
  String? originalPackPrice;

  @HiveField(27)
  double? editedAmount;

  @HiveField(28)
  double? customerDiscountPercentage;

<<<<<<< HEAD
  @HiveField(29)
  String? packPrice;

=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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
    this.customerDiscount,
    this.promoDiscount,
    this.isBulk,
    this.bulkId,
    this.initialCount,
    this.catTax,
    this.taxAmount,
    this.itemNumbers,
    this.flatDiscount,
    this.unitPrice,
    this.bulkDiscountAmount,
    this.originalUnitPrice,
    this.originalPackPrice,
    this.editedAmount,
    this.customerDiscountPercentage,
<<<<<<< HEAD
    this.packPrice,
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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
      'is_promo': isPromo ?? false,
      'promo_code': promoCode ?? "",
      'promo_msg': promoMsg,
       'customer_discount': customerDiscount,
      'promo_discount': promoDiscount,
      'is_bulk': isBulk,
      'bulk_id': bulkId,
      'initial_count': initialCount,
      'cat_tax': catTax,
      'taxAmount': taxAmount,
      'item_numbers': itemNumbers,
      'flat_discount': flatDiscount,
      'unit_price': unitPrice,
      'bulk_discount_amount': bulkDiscountAmount,
      'original_unit_price': originalUnitPrice,
      'original_pack_price': originalPackPrice,
      'edited_amount': editedAmount,
      'customer_discount_percentage': customerDiscountPercentage,
<<<<<<< HEAD
      'pack_price': packPrice,
=======
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
    };

    if (isBundle == true) {
      json['is_bundle'] = true;
      json['bundle_details'] = bundleDetails;
    }

    return json;
  }
}
