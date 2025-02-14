import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

class Utils {
  double getTotalPrice(List<CartItem> cartItems, int totalAmount) {
    double totalPrice = 0.0;
    for (var cartItem in cartItems) {
      log('SaleBy: ${cartItem.detail.saleBy}');
      double price = double.tryParse(totalAmount.toString()) ?? 0.0;
      if (cartItem.detail.saleBy != 'Pack') {
        totalPrice += price * cartItem.detail.count.toDouble();
        log('Total Price: $totalPrice | Price: $price | Count: ${cartItem.detail.count}');
      } else {
        int pieces = cartItem.detail.pieces?.toInt() ?? 1;
        totalPrice += price * pieces * cartItem.detail.count.toDouble();
        log('Total Price: $totalPrice | Price: $price | Pieces: $pieces | Count: ${cartItem.detail.count}');
      }
    }

    return totalPrice;
  }

  double getFinalAmount(List<CartItem> cartItems) {
    double total = 0.0;

    for (var cartItem in cartItems) {
      double totalPrice = cartItem.totalPrice?.toDouble() ?? 0.0;
      total += totalPrice;
    }

    return total;
  }

  double getTotalTax(List<CartItem> cartItems) {
    double totalTax = 0.0;

    for (var cartItem in cartItems) {
      double itemTax = cartItem.detail.tax?.toDouble() ?? 0.0;
      totalTax += itemTax * cartItem.detail.count.toDouble();
    }

    return totalTax;
  }

double calculateSubtotal(List<CartItem> items) {
  return items.fold(0.0, (sum, item) {
    if (item.isChecked == true) {
      double sellingPrice =
          double.tryParse(item.detail.sellingPrice?.toString() ?? '0') ?? 0.0;
      int pieces = item.detail.pieces?.toInt() ?? 1;
      double count = item.detail.count.toDouble();
      double totalCount = item.isPack == true ? count * pieces : count;
      return sum + (sellingPrice * totalCount);
    }
    return sum;
  });
}

double calculateTotalTax(List<CartItem> items) {
  return items.fold(0.0, (sum, item) {
    if (item.isChecked == true) {
      double tax = item.detail.tax?.toDouble() ?? 0.0;
      int multiplier =
          (item.isPack == true ? (item.detail.pieces!.toInt()) : 1);
      return sum + (tax * multiplier * item.detail.count.toDouble());
    }
    return sum;
  });
}

double calculateTotalPrice(CartItem cartItem) {
  if (cartItem.isChecked == true) {
    double sellingPrice =
        double.tryParse(cartItem.detail.sellingPrice?.toString() ?? '0') ?? 0.0;
    int pieces = cartItem.detail.pieces?.toInt() ?? 1;
    double count = cartItem.detail.count.toDouble();
    double totalCount = cartItem.isPack == true ? count * pieces : count;
    return sellingPrice * totalCount;
  }
  return 0.0;
}

}
