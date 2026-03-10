import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

void calculateItemDiscounts(CartItem item) {
  // Skip calculation if totalDiscountAmount is already set from backend
  if (item.totalDiscountAmount != null && item.totalDiscountAmount! > 0) {
    print('Discount already set from backend: ${item.totalDiscountAmount}');
    item.finalPrice = item.totalPrice - item.totalDiscountAmount!;
    return; // Exit early
  }

  // Only calculate if not already set (for new items added in the UI)
  final double quantity =
      (item.isPack == true || item.detail.packtype == 'Pack')
          ? (item.detail.pieces?.toDouble() ?? 1) * item.detail.count.toDouble()
          : item.detail.count.toDouble();
  
  final double totalPrice = item.totalPrice;
  final double customerDiscount = item.CustomerDiscount ?? 0.0;
  print('customer discount form the calculate file:$customerDiscount');
  final tieredDiscount = item.tieredDiscount ?? 0.0;
  print('tiered discount in calculations:$tieredDiscount');
  final double totalDiscountPercent = customerDiscount + tieredDiscount;
  final double totalDiscountAmount = totalPrice * (totalDiscountPercent / 100);
  
  
  item.totalDiscountAmount = totalDiscountAmount;
  item.finalPrice = totalPrice - totalDiscountAmount;
}