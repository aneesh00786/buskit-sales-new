// Utils.dart
import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

class Utils {
  double calculateSubtotal(List<CartItem> items) {
    log('Cart Subtotal');
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        double sellingPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        log('Item Selling Price: $sellingPrice');
        int pieces = item.detail.pieces?.toInt() ?? 1;
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
          double.tryParse(cartItem.detail.sellPrice?.toString() ?? '0') ??
              0.0;
      int pieces = cartItem.detail.pieces?.toInt() ?? 1;
      double count = cartItem.detail.count.toDouble();
      num tax = cartItem.detail.tax??0;
      log('Tax Amount = $tax');
      double totalCount =  cartItem.isPack == true ? count * pieces : count;
      sellingPrice = cartItem.detail.inclTax=="incl_tax"?sellingPrice:sellingPrice+tax;
      return sellingPrice * totalCount;
    } else {
      return 0.0;
    }
  }

}
