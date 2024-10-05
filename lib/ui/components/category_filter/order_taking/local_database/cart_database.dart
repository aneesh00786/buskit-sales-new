import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:hive/hive.dart';

class CartDatabaseManager {
  static final CartDatabaseManager _instance = CartDatabaseManager._internal();
  factory CartDatabaseManager() => _instance;
  CartDatabaseManager._internal();
  final Box<CartItem> _cartBox = Hive.box<CartItem>('cartBox');
  List<VoidCallback> _listeners = [];
  

  List<CartItem> get cartItems => _cartBox.values.toList();
  List<CartItem> getCartItems() {
    return _cartBox.values.toList();
  }
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
void addToCart(Detail detail, String productName, int totalAmount, bool isPack) async {
  CartItem? existingCartItem;
  
  try {
    // Check if the product with the same variationId exists in the cart
    existingCartItem = _cartBox.values.firstWhere(
      (cartItem) => cartItem.detail.variationId == detail.variationId,
    );
  } catch (e) {
    existingCartItem = null;
  }

  if (existingCartItem != null) {
    // Instead of using detail.count, get the quantity to add (totalAmount / unit price)
    double currentCount = existingCartItem.detail.count; // existing count from the cart
    double additionalCount = totalAmount / num.parse(detail.sellPrice??''); // Calculate how many units to add based on the total amount
    double updatedCount = currentCount + additionalCount;

    // Update the count and total price
    existingCartItem.detail.count = updatedCount;
    existingCartItem.totalPrice += totalAmount;

    // Update the item in the cart box
    await _cartBox.put(existingCartItem.key, existingCartItem);
  } else {
    // Add new item to the cart if not found
    final cartItem = CartItem(
      detail: detail,
      productName: productName,
      totalPrice: totalAmount,
      isPack: isPack,
    );

    await _cartBox.add(cartItem);
  }

  _notifyListeners();
}


void updateCart(CartItem updatedItem) {
  _cartBox.put(updatedItem.key, updatedItem);
  _notifyListeners();
}



  void deleteCartItem(CartItem item) {
    final box = Hive.box<CartItem>('cartBox');
    box.delete(item.key);
    _notifyListeners();
  }

  void clearCart(List<CartItem> index) {
    final box = Hive.box<CartItem>('cartBox');
    box.deleteAll(index);
    box.clear();
    _notifyListeners();
  }
}
