import 'package:hive/hive.dart';

part 'discount_model.g.dart';

@HiveType(typeId: 10)
class CustomerDiscountModel extends HiveObject {
  @HiveField(0)
  String? customerId;

  @HiveField(1)
  List<DiscountModel>? discounts;

  CustomerDiscountModel({this.customerId, this.discounts});

factory CustomerDiscountModel.fromJson(Map<String, dynamic> json) {
  return CustomerDiscountModel(
    customerId: json['customer_id'] ?? '', 
    discounts: (json['discounts'] as List<dynamic>?) 
        ?.map((discount) =>
            DiscountModel.fromJson(discount as Map<String, dynamic>)) 
        .toList(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'discounts': discounts?.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 11)
class DiscountModel extends HiveObject {
  @HiveField(0)
  String? categoriesId;

  @HiveField(1)
  String? value;

  @HiveField(2)
  String? discount;

  DiscountModel({this.categoriesId, this.value, this.discount});

factory DiscountModel.fromJson(Map<String, dynamic> json) {
  return DiscountModel(
    categoriesId: json['categories_id'] as String?, 
    value: json['value'] as String?, 
    discount: json['discount'] as String?, 
  );
}


  Map<String, dynamic> toJson() {
    return {
      'categories_id': categoriesId,
      'value': value,
      'discount': discount,
    };
  }
}
