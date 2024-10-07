import 'dart:developer';

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

  // Retrieve all cart items
  List<CartItem> getCartItems() {
    return _cartBox.values.toList();
  }

  // Listener management for UI updates
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
  Future<void> addToCart(
      Detail detail, String productName, int totalAmount, bool isPack) async {
    CartItem? existingCartItem;
    try {
      existingCartItem = _cartBox.values.firstWhere(
        (cartItem) =>
            cartItem.detail.variationName == detail.variationName &&
            cartItem.detail.sellPrice == detail.sellPrice,
      );
    } catch (e) {
      existingCartItem = null;
    }

    double additionalCount = detail.count;
    if (existingCartItem != null) {
      existingCartItem.detail.count += additionalCount;
      if (isPack) {
        existingCartItem.totalPrice = (existingCartItem.detail.count *
                existingCartItem.detail.pieces! *
                num.parse(existingCartItem.detail.sellPrice ?? '0'))
            .toInt();
      } else {
        existingCartItem.totalPrice = (existingCartItem.detail.count *
                num.parse(existingCartItem.detail.sellPrice ?? '0'))
            .toInt();
      }
      await _cartBox.put(existingCartItem.key, existingCartItem);
      log('Updated product in cart: ${existingCartItem.detail.variationName}, New count: ${existingCartItem.detail.count}, New total price: ${existingCartItem.totalPrice}');
    } else {
      final totalAmount = isPack
          ? (detail.count * detail.pieces! * num.parse(detail.sellPrice ?? '0'))
              .toInt()
          : (detail.count * num.parse(detail.sellPrice ?? '0')).toInt();

      final cartItem = CartItem(
        detail: detail,
        productName: productName,
        totalPrice: totalAmount,
        isPack: isPack,
      );
      log('Adding item to cart: ${detail.variationName}, Count: ${detail.count}');
      log('Total items in cart: ${_cartBox.values.length}');

      await _cartBox.add(cartItem);
      log('New product added to cart: ${cartItem.detail.variationName}, Count: ${cartItem.detail.count}, Total price: ${cartItem.totalPrice}');
    }

    _notifyListeners();
  }
  Future<void> updateCart(CartItem updatedItem) async {
    await _cartBox.put(updatedItem.key, updatedItem);
    _notifyListeners();
  }
  void deleteCartItem(CartItem item) {
    _cartBox.delete(item.key);
    _notifyListeners();
  }
  void clearCart() {
    _cartBox.clear();
    _notifyListeners();
  }
}
