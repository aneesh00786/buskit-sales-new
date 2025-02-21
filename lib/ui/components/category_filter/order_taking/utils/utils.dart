// Utils.dart
import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

class Utils {
  double getFinalAmount(List<CartItem> cartItems) {
    double total = 0.0;
    for (var cartItem in cartItems) {
      double totalPrice = cartItem.totalPrice.toDouble();
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

  // double calculateSubtotal(List<CartItem> items) {
  //   return items.fold(0.0, (sum, item) {
  //     if (item.isChecked == true) {
  //       double sellingPrice = item.draftId?.isEmpty ?? true
  //           ? double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0
  //           : double.tryParse(item.detail.sellPrice?.toString() ?? '')! *item.detail.count;
  //       int pieces = item.detail.pieces?.toInt() ?? 1;
  //       num count = item.detail.count;
  //       num totalCount = item.isPack == true ? count * pieces : count;
  //       if (item.detail.inclTax != 'incl_tax') {
  //         double tax = item.draftId?.isEmpty ?? true?
  //         double.tryParse(item.detail.tax?.toString() ?? '0') ?? 0.0:
  //           (double.tryParse(item.detail.unitTax?.toString() ?? '0') ?? 0.0) * (item.detail.packtype=="Pack" ? pieces : 1);
  //         sellingPrice += tax;
  //       }
  //       return sum + (sellingPrice * totalCount);
  //     }
  //     return sum;
  //   });
  // }

  double calculateSubtotal(List<CartItem> items) {
    log('Cart Subtotal');
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        double sellingPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        log('Item Selling Price: $sellingPrice');
        int pieces = item.detail.pieces?.toInt() ?? 1;
        log('Item Pieces: $pieces');
        num count = item.detail.count;
        log('Item Count: $count');
        num totalCount = item.isPack == true ? count * pieces : count;
        log('Total Count (with pack consideration): $totalCount');
        double tax =
            (double.tryParse(item.detail.tax?.toString() ?? '0') ?? 0.0);
        log('Tax: $tax');
        if (item.detail.inclTax != 'incl_tax') {
          sellingPrice += tax;
          log('Updated Selling Price with Tax: $sellingPrice');
        }
        double itemTotal = sellingPrice * totalCount;
        log('Item Total: $itemTotal');
        return sum + itemTotal;
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
    log('This Works');
    if (cartItem.isChecked == true) {
      double sellingPrice =
          double.tryParse(cartItem.detail.sellingPrice?.toString() ?? '0') ??
              0.0;
      int pieces = cartItem.detail.pieces?.toInt() ?? 1;
      double count = cartItem.detail.count.toDouble();
      double totalCount = cartItem.isPack == true ? count * pieces : count;
      return sellingPrice * totalCount;
    } else {
      return 0.0;
    }
  }

  double calculateDraftTotalPrice(CartItem cartItem) {
    if (cartItem.isChecked == true) {
      double totalTax = cartItem.detail.tax?.toDouble() ?? 0.0;
      num initialCount = cartItem.detail.initialQuantity ?? 1;
      double fixedPerItemTax = totalTax / initialCount;
      double totalTaxToAdd =
          (cartItem.detail.inclTax == '') ? fixedPerItemTax : 0.0;
      double sellPrice = cartItem.detail.packtype == "Pack"
          ? double.parse(cartItem.detail.sellPrice ?? '') *
              cartItem.detail.pieces!
          : double.parse(cartItem.detail.sellPrice ?? '');
      double baseTotalPrice = cartItem.totalPrice?.toDouble() ?? 0;
      double finalTotalPrice = baseTotalPrice + sellPrice + totalTaxToAdd;
      return finalTotalPrice;
    } else {
      log('Item is not checked.');
      return 0.0;
    }
  }

  double decreaseDraftTotalPrice(CartItem cartItem) {
    if (cartItem.isChecked == true) {
      double totalTax = cartItem.detail.tax?.toDouble() ?? 0.0;
      num initialCount = cartItem.detail.initialQuantity ?? 1;
      double fixedPerItemTax = totalTax / initialCount;
      double sellPrice = cartItem.detail.packtype == "Pack"
          ? double.parse(cartItem.detail.sellPrice ?? '0') *
              cartItem.detail.pieces!
          : double.parse(cartItem.detail.sellPrice ?? '');
      double baseTotalPrice = cartItem.totalPrice.toDouble();
      double taxToSubtract =
          (cartItem.detail.inclTax == '') ? fixedPerItemTax : 0.0;
      double updatedTotalPrice = baseTotalPrice - (sellPrice + taxToSubtract);
      return updatedTotalPrice >= 0 ? updatedTotalPrice : 0.0;
    } else {
      log('Item is not checked.');
      return 0.0;
    }
  }
}
