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
  int totalPrice;

  @HiveField(3)
  final bool? isPack;

  @HiveField(4)
  int? count;

  CartItem({
    required this.detail,
    required this.productName,
    required this.totalPrice,
    this.isPack,
    this.count,
  });

  /// Convert JSON to `CartItem`
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      detail: Detail.fromJson(json['detail']), // Assuming `Detail` has `fromJson`
      productName: json['productName'] as String,
      totalPrice: json['totalPrice'] as int,
      isPack: json['isPack'] as bool?,
      count: json['count'] as int?,
    );
  }

  /// Convert `CartItem` to JSON
  Map<String, dynamic> toJson() {
    return {
      'detail': detail.toJson(), // Assuming `Detail` has `toJson`
      'productName': productName,
      'totalPrice': totalPrice,
      'isPack': isPack,
      'count': count,
    };
  }
}

