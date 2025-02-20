// Utils.dart
import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

class Utils {
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
        double sellingPrice = item.draftId?.isEmpty ?? true
            ? double.tryParse(item.detail.sellPrice?.toString() ?? '0') ??
                0.0
            : double.tryParse(item.detail.sellPrice?.toString() ?? '') ??
                0.0;
        int pieces = item.detail.pieces?.toInt() ?? 1;
        double count = item.detail.count.toDouble();
        double totalCount = item.isPack == true ? count * pieces : count;
        if (item.detail.inclTax != 'incl_tax') {
          double tax =
              double.tryParse(item.detail.tax?.toString() ?? '0') ?? 0.0;
          sellingPrice += tax;
        }
        return sum + (sellingPrice * totalCount);
      }
      return sum;
    });
  }

  // double calculateTotalTax(List<CartItem> items) {
  //   return items.fold(0.0, (sum, item) {
  //     int pieces = item.detail.pieces?.toInt() ?? 1;
  //     double count = item.detail.count.toDouble();
  //     if (item.isChecked == true) {
  //       double tax = item.detail.tax?.toDouble() ?? 0.0;
  //       int multiplier =
  //           ((item.isPack == true||item.detail.packtype=='Pack') ? count.toInt() * pieces : count.toInt());
  //       return item.draftId?.isEmpty ?? true
  //           ? sum + (tax * multiplier )
  //           : sum + tax * count.toDouble();
  //     }
  //     log('Count for Tax : ${count.toDouble()}');
  //     return sum;
  //   });
  // }

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

  // double calculateTotalPrice(CartItem cartItem) {
  //   if (cartItem.isChecked == true) {
  //     double sellingPrice = cartItem.isPack ?? false
  //         ? double.tryParse(
  //                 cartItem.detail.sellingPackPrice?.toString() ?? '0') ??
  //             0.0
  //         : double.tryParse(cartItem.detail.sellingPrice?.toString() ?? '0') ??
  //             0.0;
  //     int pieces = cartItem.detail.pieces?.toInt() ?? 1;
  //     double count = cartItem.detail.count.toDouble();
  //     double totalCount = cartItem.isPack == true ? count * pieces : count;
  //     return sellingPrice * totalCount;
  //   }
  //   return 0.0;
  // }
}
