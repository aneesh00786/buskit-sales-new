import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:flutter/material.dart';
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
    existingCartItem = _cartBox.values.firstWhere(
      (cartItem) => cartItem.detail.variationName == detail.variationName && cartItem.detail.sellPrice == detail.sellPrice,
    );
  } catch (e) {
    existingCartItem = null;
  }
  double additionalCount = detail.count;

  if (existingCartItem != null) {
    existingCartItem.detail.count += additionalCount;
    existingCartItem.totalPrice = (existingCartItem.detail.count * num.parse(detail.sellPrice ?? '0')).toInt();
    await _cartBox.put(existingCartItem.key, existingCartItem);
  } else {
    final cartItem = CartItem(
      detail: detail,
      productName: productName,
      totalPrice: (detail.count * num.parse(detail.sellPrice ?? '0')).toInt(),  // Calculate initial total price
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
