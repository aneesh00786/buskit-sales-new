import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/draft_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartDatabaseManager {
  static final CartDatabaseManager _instance = CartDatabaseManager._internal();
  factory CartDatabaseManager() => _instance;
  CartDatabaseManager._internal();

  final Box<CartItem> _cartBox = Hive.box<CartItem>('cartBox');
  final Box<CartItem> _cartPreorderBox = Hive.box<CartItem>('cartPreorderBox');
  final Box<Draft> draftBox = Hive.box<Draft>('draftBox');

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
  String customerId,
) async {
  if (localCount <= 0) {
    log("Error: Count must be greater than zero.");
    return;
  }
  final totalAmount = isPack
      ? (localCount * detail.pieces! * num.parse(detail.sellPrice ?? '0'))
          .toDouble()
      : (localCount * num.parse(detail.sellPrice ?? '0')).toDouble();
  detail.count += localCount.toDouble();

  final existingDraft = CartDatabaseManager().draftBox.get(customerId);
    final draftItemMap = {
      for (var item in existingDraft?.items??[])
        '${item.detail.variationName}_${item.detail.sellPrice}': item
    };
    final key = '${detail.variationName}_${detail.sellPrice}';
  if (existingDraft != null &&draftItemMap.containsKey(key)) {
    if (draftItemMap.containsKey(key)) {
      final existingItem = draftItemMap[key]!;
      existingItem.detail.count += localCount.toDouble();
      existingItem.totalPrice = isPack
          ? (existingItem.detail.count *
                  existingItem.detail.pieces! *
                  num.parse(existingItem.detail.sellPrice ?? '0'))
              .toDouble()
          : (existingItem.detail.count *
                  num.parse(existingItem.detail.sellPrice ?? '0'))
              .toDouble();
      log('Updated draft item: ${existingItem.detail.variationName}, New Count: ${existingItem.detail.count}, Total Price: ${existingItem.totalPrice}');
    } else {
      final newCartItem = CartItem(
        detail: detail,
        productName: productName,
        totalPrice: totalAmount,
        isPack: isPack,
      );
      existingDraft.items.add(newCartItem);
      log('Added new item to draft: ${detail.variationName}, Count: ${detail.count}, Total Price: ${newCartItem.totalPrice}');
    }

    await CartDatabaseManager().draftBox.put(customerId, existingDraft);
  } else {
    final newCartItem = CartItem(
      detail: detail,
      productName: productName,
      totalPrice: totalAmount,
      isPack: isPack,
    );
    await _cartBox.add(newCartItem);
    log('New product added to cart: ${newCartItem.detail.variationName}, Count: ${newCartItem.detail.count}, Total Price: ${newCartItem.totalPrice}');
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
      existingCartItem.detail.count =
          (existingCartItem.detail.count + localCount).toDouble();
      existingCartItem.totalPrice = isPack
          ? (existingCartItem.detail.count *
                  existingCartItem.detail.pieces! *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toDouble()
          : (existingCartItem.detail.count *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toDouble();

      await _cartPreorderBox.put(existingCartItem.key, existingCartItem);
      log('Updated product in cart: ${existingCartItem.detail.variationName}, New count: ${existingCartItem.detail.count}, New total price: ${existingCartItem.totalPrice}');
    } else {
      final totalAmount = isPack
          ? (localCount * detail.pieces! * num.parse(detail.sellPrice ?? '0'))
              .toDouble()
          : (localCount * num.parse(detail.sellPrice ?? '0')).toDouble();
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
  
Future<void> updateCartItemCount(Detail detail, int newCount) async {
  if (newCount <= 0) {
    log("Error: Count must be greater than zero.");
    return;
  }
  try {
    CartItem? existingCartItem = _cartBox.values.firstWhere(
      (cartItem) =>
          cartItem.detail.variationName == detail.variationName &&
          cartItem.detail.sellPrice == detail.sellPrice,
      orElse: () => CartItem(detail: detail, productName: '', totalPrice: 0),
    );

    if (existingCartItem != null) {
      existingCartItem.detail.count += newCount.toDouble();
      existingCartItem.totalPrice = existingCartItem.isPack!
          ? (existingCartItem.detail.count *
                  existingCartItem.detail.pieces! *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toDouble()
          : (existingCartItem.detail.count *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toDouble();
      await _cartBox.put(existingCartItem.key, existingCartItem);
      log('Updated product in cart: ${existingCartItem.detail.variationName}, New Count: ${existingCartItem.detail.count}, Total Price: ${existingCartItem.totalPrice}');
    } else {
      log("Error: Item not found in cart for update.");
    }
  } catch (e) {
    log('Error updating cart item: $e');
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
                .toDouble()
            : (existingPreorderItem.detail.count *
                    num.parse(existingPreorderItem.detail.sellPrice ?? '0'))
                .toDouble();
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

  Future<void> saveCartAsDraft(
      String customerId, String cartId, String draftId) async {
    if (customerId.isEmpty) {
      log('Error: Customer ID is required to save a draft.');
      return;
    }
    try {
      List<CartItem> cartItems = CartDatabaseManager().cartItems;
      if (cartItems.isEmpty) {
        log('No items in the cart to save as a draft.');
        return;
      }
      final existingDraft = CartDatabaseManager().draftBox.get(customerId);
      List<CartItem> updatedDraftItems = [];
      if (existingDraft != null) {
        final draftItemMap = {
          for (var item in existingDraft.items)
            '${item.detail.variationName}_${item.detail.sellPrice}': item
        };
        for (var cartItem in cartItems) {
          final key =
              '${cartItem.detail.variationName}_${cartItem.detail.sellPrice}';
          if (draftItemMap.containsKey(key)) {
            final existingItem = draftItemMap[key]!;
            existingItem.detail.count += cartItem.detail.count;
            existingItem.totalPrice = existingItem.isPack!
                ? (existingItem.detail.count *
                        existingItem.detail.pieces! *
                        num.parse(existingItem.detail.sellPrice ?? '0'))
                    .toDouble()
                : (existingItem.detail.count *
                        num.parse(existingItem.detail.sellPrice ?? '0'))
                    .toDouble();
          } else {
            draftItemMap[key] = cartItem;
          }
        }
        updatedDraftItems = draftItemMap.values.toList();
      } else {
        updatedDraftItems = cartItems;
      }
      final draft = Draft(
        customerId: customerId,
        cartId: cartId,
        items: updatedDraftItems,
        draftId: draftId,
      );
      log('Draft : ${draft.cartId}');
      await CartDatabaseManager().draftBox.put(customerId, draft);
      log('Draft saved successfully for customer ID: $customerId');
    } catch (e) {
      log('Error saving cart as draft: $e');
    }
  }

  Map<String, String?>? getSavedCartData(String customerId) {
    final draft = draftBox.get(customerId);
    if (draft != null) {
      return {
        'cart_id': draft.cartId,
        'id': draft.draftId,
      };
    }
    return null;
  }

  Future<void> updateCart(CartItem updatedItem) async {
    await _cartBox.put(updatedItem.key, updatedItem);
    _notifyListeners();
  }

  Future<void> updatePreorderCart(CartItem updatedItem) async {
    await _cartPreorderBox.put(updatedItem.key, updatedItem);
    _notifyListeners();
  }

  Future<void> updateDraftItem(
      String customerId, CartItem updatedCartItem) async {
    try {
      final existingDraft = draftBox.get(customerId);

      if (existingDraft != null) {
        final updatedItems = existingDraft.items.map((item) {
          if (item.key == updatedCartItem.key) {
            return updatedCartItem;
          }
          return item;
        }).toList();
        final updatedDraft = Draft(
          customerId: existingDraft.customerId,
          items: updatedItems,
          cartId: '',
          draftId: '',
        );
        await draftBox.put(customerId, updatedDraft);
        log('Draft updated successfully for customer ID: $customerId');
        _notifyListeners();
      } else {
        log('Draft not found for customer ID: $customerId');
      }
    } catch (e) {
      log('Error updating draft for customer ID: $customerId, Error: $e');
    }
  }

  void deleteCartItem(CartItem item) {
    _cartBox.delete(item.key);
    _notifyListeners();
  }

  void deletePreorderCartItem(CartItem item) {
    _cartPreorderBox.delete(item.key);
    _notifyListeners();
  }

  void deleteDraftItems(String customerId, CartItem item) {
    final existingDraft = draftBox.get(customerId);
    if (existingDraft != null) {
      final updatedItems = existingDraft.items
          .where((draftItem) => draftItem.key != item.key)
          .toList();
      final updatedDraft = Draft(
          customerId: existingDraft.customerId,
          items: updatedItems,
          cartId: '',
          draftId: '');
      draftBox.put(customerId, updatedDraft);
      log('Draft item deleted for customer ID: $customerId');
      _notifyListeners();
    } else {
      log('No draft found for customer ID: $customerId to delete item.');
    }
  }

  void deleteDraftItem(String customerId, String variationId) {
    final existingDraft = draftBox.get(customerId);
    if (existingDraft != null) {
      final updatedItems = existingDraft.items
          .where((draftItem) => draftItem.detail.variationId != variationId)
          .toList();
      final updatedDraft = Draft(
        customerId: existingDraft.customerId,
        items: updatedItems,
        cartId: '',
        draftId: '',
      );

      draftBox.put(customerId, updatedDraft);
      log('Draft item with variationId: $variationId deleted for customer ID: $customerId');
      _notifyListeners();
    } else {
      log('No draft found for customer ID: $customerId to delete item.');
    }
  }

  void clearDraftForCustomer(String customerId) {
    if (draftBox.containsKey(customerId)) {
      draftBox.delete(customerId);
      log('All draft items cleared for customer ID: $customerId');
      _notifyListeners();
    } else {
      log('No draft found for customer ID: $customerId to clear.');
    }
  }

  void clearAllDrafts() {
    draftBox.clear();
    log('All drafts cleared.');
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
