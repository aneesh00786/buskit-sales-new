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
      totalPrice += price * cartItem.detail.count.toDouble();
      log('Total Price$totalPrice - Price : $price - Cart Item Count ${cartItem.detail.count}');
      }else{
        double price = double.tryParse(totalAmount.toString()) ?? 0.0;
      totalPrice += price *cartItem.detail.pieces!* cartItem.detail.count.toDouble();
      log('Total Price$totalPrice - Price : $price -Pieces : ${cartItem.detail.pieces!} - Cart Item Count ${cartItem.detail.count}');
      }
    }
    return totalPrice;
  }
double getFinalAmount(List<CartItem> cartItems) {
  double total = 0.0;
  for (var cartItem in cartItems) {
    double? totalPrice = cartItem.totalPrice.toDouble();
    total += totalPrice;
  }
  return total;
}

double getTotalTax(List<CartItem> cartItems) {
  double totalTax = 0.0;
  for (var cartItem in cartItems) {
    double itemTax = cartItem.detail.tax?.toDouble() ?? 0.0; // Tax per item
    totalTax += itemTax * cartItem.detail.count.toDouble();
  }
  return totalTax;
}
}
