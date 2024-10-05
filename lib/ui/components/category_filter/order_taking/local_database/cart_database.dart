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

void addToCart(Detail detail, String productName, int totalAmount, bool isPack) {
  CartItem? existingCartItem;
  try {
    existingCartItem = _cartBox.values.firstWhere(
      (cartItem) => cartItem.detail.variationId == detail.variationId,
    );
  } catch (e) {
    existingCartItem = null;
  }

  if (existingCartItem != null) {
    existingCartItem.detail.count += detail.count; 
    existingCartItem.totalPrice += totalAmount;
    _cartBox.put(existingCartItem.key, existingCartItem);
  } else {
    final cartItem = CartItem(
      detail: detail,
      productName: productName,
      totalPrice: totalAmount,
      isPack: isPack,
    );
    _cartBox.add(cartItem);
  }
  
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
