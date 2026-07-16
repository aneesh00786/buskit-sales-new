// Utils.dart
import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Utils {
  double calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        double sellingPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        num tax = item.detail.inclTax == "N.A" ? 0 : (item.detail.tax ?? 0);
        if ((item.detail.discount ?? 0) > 0) {
          final num discountPercentage = item.detail.discount!;
          sellingPrice -= (sellingPrice * discountPercentage / 100);
          tax -= (tax * discountPercentage / 100);
        }
        int pieces = item.detail.pieces?.toInt() ?? 1;
        double count = item.detail.count.toDouble();
        double totalCount = item.isPack == true ? count * pieces : count;
        sellingPrice = (item.detail.inclTax == "incl_tax" || item.detail.inclTax == "N.A")
            ? sellingPrice
            : sellingPrice + tax;
        double itemTotal = sellingPrice * totalCount;
        return sum + itemTotal;
      }
      return sum;
    });
  }

  double calculateTotalDiscount(List<CartItem> items) {
    return items.fold(0.0, (sum, item) {
      if (item.isChecked == true) {
        final double sellPrice =
            double.tryParse(item.detail.sellPrice?.toString() ?? '0') ?? 0.0;
        final double discountPercentage =
            (double.tryParse(item.detail.discount?.toString() ?? '0') ?? 0.0) /
                100;
        final double? maxDiscount = item.detail.maxDiscount?.toDouble();

        final double count = item.isPack == true
            ? (item.detail.pieces?.toDouble() ?? 1) *
                item.detail.count.toDouble()
            : item.detail.count.toDouble();

        // Calculate total base price and uncapped discount
        final double totalBasePrice = sellPrice * count;
        double uncappedDiscountAmount = totalBasePrice * discountPercentage;

        // Apply max discount cap if available
        double actualDiscountAmount = uncappedDiscountAmount;
        if (maxDiscount != null &&
            maxDiscount > 0 &&
            uncappedDiscountAmount > maxDiscount) {
          actualDiscountAmount = maxDiscount;
        }

        return sum + actualDiscountAmount;
      }
      return sum;
    });
  }
  double calculateTotalTax(List<CartItem> items) {
  return items.fold(0.0, (sum, item) {
    // Only add tax if the item is selected/checked
    if (item.isChecked == true) {
      // Use the pre-calculated taxAmount, defaulting to 0.0 if null
      return sum + (item.taxAmount?.toDouble() ?? 0.0);
    }
    return sum;
  });
}

  // double calculateTotalTax(List<CartItem> items) {
  //   return items.fold(0.0, (sum, item) {
  //     if (item.isChecked == true) {
  //       double tax = item.detail.tax?.toDouble() ?? 0.0;
  //       print('item deatail taxxxx:$tax');
  //       int multiplier =
  //           (item.isPack == true ? (item.detail.pieces!.toInt()) : 1);
  //       return sum + (tax * multiplier * item.detail.count.toDouble());
  //     }
  //     return sum;
  //   });
  // }

   

  double calculateTotalPrice(CartItem cartItem, int localCount) {
    final discountBox = Hive.box<CustomerDiscountModel>('discounts');
    CustomerDiscountModel? discountData;

    if (!(cartItem.isPromo ?? false)) {
      discountData = discountBox.values.firstWhere(
        (discount) => discount.customerId == cartItem.customerId,
        orElse: () => CustomerDiscountModel(),
      );
    }

    if (cartItem.isChecked == true) {
      double effectiveSellingPrice =
          double.tryParse(cartItem.detail.sellPrice ?? '0') ?? 0;
      int pieces = cartItem.detail.pieces?.toInt() ?? 1;
      num count = cartItem.detail.count;
      num tax = cartItem.detail.inclTax == "N.A" ? 0 : (cartItem.detail.tax ?? 0);

      double calculatedSellPrice = cartItem.isPack == true
          ? effectiveSellingPrice * pieces
          : effectiveSellingPrice;

      final double totalPriceForComparison = calculatedSellPrice * localCount;

      double appliedDiscountPercentage = 0.0;

      if (cartItem.isPromo ?? false) {
        // Use discount already passed in cartItem.detail.discount
        appliedDiscountPercentage = cartItem.detail.discount?.toDouble() ?? 0;
        if (appliedDiscountPercentage > 0) {
          // Get the base price for discount calculation
          double basePrice = effectiveSellingPrice;

          // Calculate the total quantity
          int pieces = cartItem.detail.pieces?.toInt() ?? 1;
          num count = cartItem.detail.count;
          num totalCount = cartItem.isPack == true ? count * pieces : count;

          // Calculate the total price before discount
          double totalBasePrice = basePrice * totalCount.toDouble();

          // Calculate the discount amount on the total price
          double totalDiscountAmount =
              totalBasePrice * appliedDiscountPercentage / 100;

          // Check if there's a max discount limit

          if (cartItem.detail.maxDiscount != null &&
              cartItem.detail.maxDiscount! > 0) {
            double maxDiscountValue = cartItem.detail.maxDiscount!.toDouble();

            // If discount amount exceeds max discount, cap it

            if (totalDiscountAmount > maxDiscountValue) {
              totalDiscountAmount = maxDiscountValue;

              // Recalculate the effective discount percentage for display
              double effectiveDiscountPercentage =
                  (totalDiscountAmount / totalBasePrice) * 100;
              cartItem.detail.discount = effectiveDiscountPercentage;
              appliedDiscountPercentage = effectiveDiscountPercentage;

              // Show notification that max discount was applied
            }
          }

          // Calculate the discount amount per unit
          double discountAmountPerUnit =
              totalDiscountAmount / totalCount.toDouble();

          // Apply the (potentially capped) discount per unit
          effectiveSellingPrice -= discountAmountPerUnit;
          tax -= (tax * appliedDiscountPercentage / 100);

          log('[PROMO] Promo discount applied: $appliedDiscountPercentage%. '
              'Updated Effective Selling Price: $effectiveSellingPrice, Tax: $tax');
        } else {
        }
      } else if (discountData?.customerId == cartItem.customerId) {
        final applicableDiscount = discountData?.discounts?.firstWhere(
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

          log('[PROMO] Customer discount applied: $appliedDiscountPercentage%. '
              'Updated Effective Selling Price: $effectiveSellingPrice, Tax: $tax');
        } else {
        }
      } else {
      }

      cartItem.detail.discount = appliedDiscountPercentage;

      num totalCount = cartItem.isPack == true ? count * pieces : count;
      double priceWithTax = (cartItem.detail.inclTax == "incl_tax" || cartItem.detail.inclTax == "N.A")
          ? effectiveSellingPrice
          : effectiveSellingPrice + tax;

      double totalPrice = priceWithTax * totalCount;

      return totalPrice;
    } else {
      return 0.0;
    }
  }
}
