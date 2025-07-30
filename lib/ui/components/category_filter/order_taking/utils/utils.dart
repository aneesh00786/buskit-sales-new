// Utils.dart
import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Utils {
  double calculateSubtotal(List<CartItem> items) {
    log('Calculating Cart Subtotal');
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        double sellingPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        num tax = item.detail.tax ?? 0;
        if ((item.detail.discount ?? 0) > 0) {
          final num discountPercentage = item.detail.discount!;
          sellingPrice -= (sellingPrice * discountPercentage / 100);
          tax -= (tax * discountPercentage / 100);
          log('Applying discount of $discountPercentage% to selling price.');
          log('Discounted Selling Price: $sellingPrice');
        }
        int pieces = item.detail.pieces?.toInt() ?? 1;
        double count = item.detail.count.toDouble();
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

  double calculateTotalDiscount(List<CartItem> items) {
    log('Calculating Total Discount');
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        final double sellPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        final double discountPercentage =
            (double.tryParse(item.detail.discount?.toString() ?? '0') ?? 0.0) /
                100;
        final double count = item.isPack == true
            ? (item.detail.pieces?.toDouble() ?? 1) *
                item.detail.count.toDouble()
            : item.detail.count.toDouble();
        final double discountPrice = sellPrice * discountPercentage * count;
        log('Discount for item: $discountPrice');
        return sum + discountPrice;
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

  double calculateTotalPrice(CartItem cartItem, int localCount) {
    log('Calculating total price for cart item');
    final discountBox = Hive.box<CustomerDiscountModel>('discounts');
    CustomerDiscountModel? discountData;
    discountData = discountBox.values.firstWhere(
      (discount) => discount.customerId == cartItem.customerId,
      orElse: () => CustomerDiscountModel(),
    );
    if (cartItem.isChecked == true) {
      double effectiveSellingPrice =
          double.tryParse(cartItem.detail.sellPrice ?? '0') ?? 0;
      int pieces = cartItem.detail.pieces?.toInt() ?? 1;
      num count = cartItem.detail.count;
      num tax = cartItem.detail.tax ?? 0;
      log('Initial Effective Selling Price: $effectiveSellingPrice, Tax: $tax');
      double calculatedSellPrice = cartItem.isPack == true
          ? effectiveSellingPrice * pieces
          : effectiveSellingPrice;
      final double totalPriceForComparison = cartItem.isPack == true
          ? calculatedSellPrice * localCount
          : calculatedSellPrice * localCount;
      log('Calculated Selling Price for Discount Check: $totalPriceForComparison');
      double appliedDiscountPercentage = 0.0;
      if (discountData.customerId == cartItem.customerId) {
        final applicableDiscount = discountData.discounts?.firstWhere(
          (discount) =>
              discount.categoriesId == cartItem.catId.toString() &&
              totalPriceForComparison >
                  (double.tryParse(discount.value ?? '0') ?? 0),
          orElse: () => DiscountModel(),
        );
        if (applicableDiscount != null &&
            applicableDiscount.discount != null &&
            applicableDiscount.discount!.isNotEmpty) {
          appliedDiscountPercentage =
              double.tryParse(applicableDiscount.discount ?? '0') ?? 0;
          effectiveSellingPrice -=
              (effectiveSellingPrice * appliedDiscountPercentage / 100);
          tax -= (tax * appliedDiscountPercentage / 100);

          log('Applied discount of $appliedDiscountPercentage%. '
              'Updated Effective Selling Price: $effectiveSellingPrice, Tax: $tax');
        } else {
          log('No applicable discount found.');
        }
      } else {
        log('No discount data found for customer ID: ${cartItem.customerId}');
      }
      cartItem.detail.discount = appliedDiscountPercentage;
      num totalCount = cartItem.isPack == true ? count * pieces : count;
      double priceWithTax = cartItem.detail.inclTax == "incl_tax"
          ? effectiveSellingPrice
          : effectiveSellingPrice + tax;
      log('Price with Tax: $priceWithTax');
      double totalPrice = priceWithTax * totalCount;
      log('Final Total Price (after tax and discount): $totalPrice');

      return totalPrice;
    } else {
      log('Item is not checked; returning price as 0.0');
      return 0.0;
    }
  }
}
