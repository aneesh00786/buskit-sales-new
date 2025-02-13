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
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      detail: Detail.fromJson(json['detail']),
      productName: json['productName'] as String,
      totalPrice: json['totalPrice'] as double,
      isPack: json['isPack'] as bool?,
      count: json['count'] as int?,
      customerId: json['customer_id'] as String?,
      cartId: json['cart_id'] as String?,
      draftId: json['id'] as String?,
      isChecked: json['isChecked'],
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
      'isChecked': isChecked
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
        isChecked: isChcked ?? this.isChecked);
  }
}
