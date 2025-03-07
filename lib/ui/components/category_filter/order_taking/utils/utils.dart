// Utils.dart
import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';

class Utils {
  double calculateSubtotal(List<CartItem> items) {
    log('Calculating Cart Subtotal');
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        double sellingPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        if ((item.detail.discount ?? 0) > 0) {
          final num discountPercentage = item.detail.discount!;
          sellingPrice -= (sellingPrice * discountPercentage / 100);
          log('Applying discount of $discountPercentage% to selling price.');
          log('Discounted Selling Price: $sellingPrice');
        }

        int pieces = item.detail.pieces?.toInt() ?? 1;
        double count = item.detail.count.toDouble();
        num tax = item.detail.tax ?? 0;
        log('Tax Amount: $tax');
        double totalCount = item.isPack == true ? count * pieces : count;
        sellingPrice = item.detail.inclTax == "incl_tax"
            ? sellingPrice
            : sellingPrice + tax;
        double itemTotal = sellingPrice * totalCount;
        log('Item Total (after tax and discount): $itemTotal');
        return sum + itemTotal;
      }
      return sum;
    });
  }

  double calculateDraftSubtotal(List<CartItem> items) {
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
        double unitTax =
            (double.tryParse(item.detail.unitTax?.toString() ?? '0') ?? 0.0);
        num tax = item.isPack == true ? unitTax * count : unitTax;
        log('Tax: $tax');
        double itemTotal = sellingPrice * totalCount;
        log('Item Total: $itemTotal');
        return sum +
            itemTotal +
            (item.detail.inclTax == "incl_tax" ? 0 : (unitTax * count));
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

  double calculateDraftTotalTax(List<CartItem> items) {
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        double tax = item.detail.unitTax?.toDouble() ?? 0.0;
        int multiplier =
            (item.isPack == true ? (item.detail.pieces!.toInt()) : 1);
        return sum + (tax * item.detail.count.toDouble());
      }
      return sum;
    });
  }

  double calculateTotalPrice(CartItem cartItem) {
    log('Calculating total price for cart item');
    if (cartItem.isChecked == true) {
      double sellingPrice =
          double.tryParse(cartItem.detail.sellPrice?.toString() ?? '0') ?? 0.0;
      if ((cartItem.detail.discount ?? 0) > 0) {
        final num discountPercentage = cartItem.detail.discount!;
        sellingPrice -= (sellingPrice * discountPercentage / 100);
        log('Applying discount of $discountPercentage% to selling price.');
        log('Discounted Selling Price: $sellingPrice');
      }
      int pieces = cartItem.detail.pieces?.toInt() ?? 1;
      double count = cartItem.detail.count.toDouble();
      num tax = cartItem.detail.tax ?? 0;
      log('Tax Amount: $tax');
      double totalCount = cartItem.isPack == true ? count * pieces : count;
      sellingPrice = cartItem.detail.inclTax == "incl_tax"
          ? sellingPrice
          : sellingPrice + tax;
      double totalPrice = sellingPrice * totalCount;
      log('Total Price (after tax and discount): $totalPrice');
      return totalPrice;
    } else {
      return 0.0;
    }
  }

  double calculateDraftTotalPrice(CartItem cartItem) {
    log('This Works2');
    if (cartItem.isChecked == true) {
      double sellingPrice =
          double.tryParse(cartItem.detail.sellPrice?.toString() ?? '0') ?? 0.0;
      if ((cartItem.detail.discount ?? 0) > 0) {
        final num discountPercentage = cartItem.detail.discount!;
        sellingPrice -= (sellingPrice * discountPercentage / 100);
        log('Applying discount of $discountPercentage% to selling price.');
        log('Discounted Selling Price: $sellingPrice');
      }
      int pieces = cartItem.detail.pieces?.toInt() ?? 1;
      int? count = cartItem.detail.count.toInt() ?? 0;
      num tax = cartItem.detail.unitTax ?? 0;
      log('Discount on Calculation ${cartItem.detail.discount}');
      log('Selling Price: $sellingPrice');
      log('Pieces per Pack: $pieces');
      log('Count: $count');
      log('Unit Tax: ${tax * count}');
      int totalCount =
          cartItem.detail.packtype == "Pack" ? (count * pieces) : count;
      log("Calculated total amount ${cartItem.detail.inclTax == "incl_tax" ? (sellingPrice * totalCount) : ((sellingPrice * totalCount))}");
      return cartItem.detail.inclTax == "incl_tax"
          ? (sellingPrice * totalCount)
          : ((sellingPrice * totalCount));
    } else {
      return 0.0;
    }
  }
}
