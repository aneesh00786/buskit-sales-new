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
  final Box<CartItem> _cartPreorderBox = Hive.box<CartItem>('cartPreorderBox');

  List<VoidCallback> _listeners = [];

  List<CartItem> get cartItems => _cartBox.values.toList();
  List<CartItem> get cartPreorderItems => _cartPreorderBox.values.toList();

  List<CartItem> getCartItems() {
    return _cartBox.values.toList();
  }

  List<CartItem> getCartPreorderItems() {
    return _cartPreorderBox.values.toList();
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

Future<void> addToCart(
    Detail detail,
    String productName,
    int totalAmount,
    bool isPack,
    int localCount,
  ) async {
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
    if (existingCartItem != null) {
      existingCartItem.detail.count += localCount;
      existingCartItem.totalPrice = isPack
          ? (existingCartItem.detail.count *
                  existingCartItem.detail.pieces! *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toInt()
          : (existingCartItem.detail.count *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toInt();

      await _cartBox.put(existingCartItem.key, existingCartItem);
      log('Updated product in cart: ${existingCartItem.detail.variationName}, New count: ${existingCartItem.detail.count}, New total price: ${existingCartItem.totalPrice}');
    } else {
      final totalAmount = isPack
          ? (localCount * detail.pieces! * num.parse(detail.sellPrice ?? '0'))
              .toInt()
          : (localCount * num.parse(detail.sellPrice ?? '0')).toInt();
      detail.count = localCount.toDouble();

      final cartItem = CartItem(
        detail: detail,
        productName: productName,
        totalPrice: totalAmount,
        isPack: isPack,
      );

      log('Adding item to cart: ${detail.variationName}, Count: ${localCount}');
      await _cartBox.add(cartItem);
      log('New product added to cart: ${cartItem.detail.variationName}, Count: ${cartItem.detail.count}, Total price: ${cartItem.totalPrice}');
    }

    _notifyListeners();
  }

  Future<void> addToPreorderCart(
    Detail detail,
    String productName,
    int totalAmount,
    bool isPack,
    int localCount,
  ) async {
    CartItem? existingCartItem;
    try {
      existingCartItem = _cartPreorderBox.values.firstWhere(
        (cartPreorderItem) =>
            cartPreorderItem.detail.variationName == detail.variationName &&
            cartPreorderItem.detail.sellPrice == detail.sellPrice,
      );
    } catch (e) {
      existingCartItem = null;
    }
    if (existingCartItem != null) {
      existingCartItem.detail.count += localCount;
      existingCartItem.totalPrice = isPack
          ? (existingCartItem.detail.count *
                  existingCartItem.detail.pieces! *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toInt()
          : (existingCartItem.detail.count *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toInt();

      await _cartPreorderBox.put(existingCartItem.key, existingCartItem);
      log('Updated product in cart: ${existingCartItem.detail.variationName}, New count: ${existingCartItem.detail.count}, New total price: ${existingCartItem.totalPrice}');
    } else {
      final totalAmount = isPack
          ? (localCount * detail.pieces! * num.parse(detail.sellPrice ?? '0'))
              .toInt()
          : (localCount * num.parse(detail.sellPrice ?? '0')).toInt();
      detail.count = localCount.toDouble();

      final cartPreorderItem = CartItem(
        detail: detail,
        productName: productName,
        totalPrice: totalAmount,
        isPack: isPack,
      );

      log('Adding item to cart: ${detail.variationName}, Count: $localCount');
      await _cartPreorderBox.add(cartPreorderItem);
      log('New product added to cart: ${cartPreorderItem.detail.variationName}, Count: ${cartPreorderItem.detail.count}, Total price: ${cartPreorderItem.totalPrice}');
    }

    _notifyListeners();
  }


Future<void> updateCartItemCount(Detail detail, int countToAdd) async {
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
    if (existingCartItem != null) {
      if (countToAdd > 0) {
        existingCartItem.detail.count += countToAdd;
        existingCartItem.totalPrice = existingCartItem.isPack!
            ? (existingCartItem.detail.count *
                    existingCartItem.detail.pieces! *
                    num.parse(existingCartItem.detail.sellPrice ?? '0'))
                .toInt()
            : (existingCartItem.detail.count *
                    num.parse(existingCartItem.detail.sellPrice ?? '0'))
                .toInt();
        await _cartBox.put(existingCartItem.key, existingCartItem);
        log('Updated product in cart: ${existingCartItem.detail.variationName}, New count: ${existingCartItem.detail.count}, New total price: ${existingCartItem.totalPrice}');
      } else {
        log('Cannot update count to a value less than or equal to zero for product: ${detail.variationId}');
      }
    } else {
      log('No existing cart item found to update for product ID: ${detail.variationId}');
    }
  }

  Future<void> updatePreorderCartItemCount(
      Detail detail, int countToAdd) async {
    CartItem? existingPreorderItem;
    try {
      existingPreorderItem = _cartPreorderBox.values.firstWhere(
        (cartItem) =>
            cartItem.detail.variationName == detail.variationName &&
            cartItem.detail.sellPrice == detail.sellPrice,
      );
    } catch (e) {
      existingPreorderItem = null;
    }

    if (existingPreorderItem != null) {
      if (countToAdd > 0) {
        existingPreorderItem.detail.count += countToAdd;
        existingPreorderItem.totalPrice = existingPreorderItem.isPack!
            ? (existingPreorderItem.detail.count *
                    existingPreorderItem.detail.pieces! *
                    num.parse(existingPreorderItem.detail.sellPrice ?? '0'))
                .toInt()
            : (existingPreorderItem.detail.count *
                    num.parse(existingPreorderItem.detail.sellPrice ?? '0'))
                .toInt();
        await _cartPreorderBox.put(
            existingPreorderItem.key, existingPreorderItem);
        log('Updated product in pre-order cart: ${existingPreorderItem.detail.variationName}, New count: ${existingPreorderItem.detail.count}, New total price: ${existingPreorderItem.totalPrice}');
      } else {
        log('Cannot update count to a value less than or equal to zero for pre-order product: ${detail.variationId}');
      }
    } else {
      log('No existing pre-order item found to update for product ID: ${detail.variationId}');
    }
  }



  Future<void> updateCart(CartItem updatedItem) async {
    await _cartBox.put(updatedItem.key, updatedItem);
    _notifyListeners();
  }

  Future<void> updatePreorderCart(CartItem updatedItem) async {
    await _cartPreorderBox.put(updatedItem.key, updatedItem);
    _notifyListeners();
  }

  void deleteCartItem(CartItem item) {
    _cartBox.delete(item.key);
    _notifyListeners();
  }

  void deletePreorderCartItem(CartItem item) {
    _cartPreorderBox.delete(item.key);
    _notifyListeners();
  }

  void clearCart() {
    _cartBox.clear();
    _notifyListeners();
  }

  void clearPreorderCart() {
    _cartPreorderBox.clear();
    _notifyListeners();
  }
}
