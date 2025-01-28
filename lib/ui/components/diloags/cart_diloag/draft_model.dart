import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:hive/hive.dart';
part 'draft_model.g.dart';

@HiveType(typeId: 7) 
class Draft extends HiveObject {
  @HiveField(0)
  final String customerId;

  @HiveField(1)
  final List<CartItem> items;

  @HiveField(2)
  final String cartId;

  Draft({
    required this.customerId,
    required this.items,
    required this.cartId,
  });
  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      customerId: json['customerId'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      cartId: json['cart_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'cart_id': cartId,
    };
  }
}
