import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

class Utils {
  double getTotalPrice(List<CartItem> cartItems,int totalAmount) {
    double totalPrice = 0.0;
    for (var cartItem in cartItems) {
      cartItem.detail.saleBy = 'Pack';
      log('Saleby : ${cartItem.detail.saleBy}');
      if (cartItem.detail.saleBy!='Pack') {
        double price = double.tryParse(totalAmount.toString()) ?? 0.0;
      totalPrice += price * cartItem.detail.count;
      log('Total Price$totalPrice - Price : $price - Cart Item Count ${cartItem.detail.count}');
      }else{
        double price = double.tryParse(totalAmount.toString()) ?? 0.0;
      totalPrice += price *cartItem.detail.pieces!* cartItem.detail.count;
      log('Total Price$totalPrice - Price : $price -Pieces : ${cartItem.detail.pieces!} - Cart Item Count ${cartItem.detail.count}');
      }
    }
    return totalPrice;
  }
  double getFinalAmount(List<CartItem> cartItems) {
  double total = 0.0;
  for (var cartItem in cartItems) {
    double? totalPrice = cartItem.detail.totalPrice;
    total += totalPrice??0.0;
  }
  return total;
}
  double getTotalTax(List<CartItem> cartItems) {
    double totalTax = 0.0;
    for (var cartItem in cartItems) {
      double tax = double.tryParse(cartItem.detail.tax ?? '0.0') ?? 0.0;
      totalTax += tax;
    }
    return totalTax;
  }
}
