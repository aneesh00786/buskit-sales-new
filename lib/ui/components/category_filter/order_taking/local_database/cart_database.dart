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
  final Box<CartItem> cartBox = Hive.box<CartItem>('cartBox');
  final Box<Draft> draftBox = Hive.box<Draft>('draftBox');
  final List<VoidCallback> _listeners = [];
  List<CartItem> get cartItems => cartBox.values.toList();
  List<CartItem> getCartItems(String customerId) {
    try {
      final customerCartItems = cartBox.values
          .where((item) => item.customerId == customerId)
          .toList();
      log('Cart items retrieved for customer $customerId: ${customerCartItems.length}');
      return customerCartItems;
    } catch (e) {
      log('Error retrieving cart items for customer $customerId: $e');
      return [];
    }
  }

  // Future<List<CartItem>> getDraftItems(String customerId) async {
  //   final dio = Dio();
  //   final apiUrl = 'http://16.50.232.153:3000/fetch_all_order';

  //   // Request body
  //   final requestBody = {
  //     "companyId": 1,
  //     "customer_id": customerId,
  //     "salesman_id": "",
  //     "order_type": 4,
  //     "payment_type": 1,
  //     "start_date": "2025-02-01",
  //     "end_date": "2025-02-28",
  //     "limit": 1000,
  //     "page": 1,
  //   };

  //   try {
  //     final connectivityService = ConnectivityService();
  //     final isOnline = await connectivityService.isOnline();

  //     if (isOnline) {
  //       log('Fetching draft items from API for customer ID: $customerId');
  //       final response = await dio.post(apiUrl, data: requestBody);

  //       if (response.statusCode == 200) {
  //         final responseData = response.data;

  //         if (responseData['status'] == true) {
  //           final List<dynamic> orders = responseData['data'] ?? [];

  //           List<CartItem> draftItems = [];
  //           for (var order in orders) {
  //             final List<dynamic> carts = order['cart'] ?? [];
  //             for (var cart in carts) {
  //               final detail = Detail(
  //                 id: cart['id'],
  //                 productId: cart['product_id'],
  //                 variationId: cart['variation_id'],
  //                 inNo: cart['in_no'],
  //                 barcode: cart['barcode'],
  //                 variationName: cart['variation_name'],
  //                 unitType: cart['unitType'],
  //                 price: cart['price'],
  //                 sellPrice: cart['sell_price'],
  //                 tax: cart['tax'],
  //                 packtype: cart['packtype'],
  //                 pieces: cart['pieces'],
  //                 stock: cart['stock'],
  //                 lowstock: cart['lowstock'],
  //                 fullstock: cart['fullstock'],
  //                 imageUrl: cart['image_url'],
  //                 status: cart['status'],
  //                 createdAt: cart['created_at'],
  //                 updatedAt: cart['updated_at'],
  //                 count: cart['quantity'],
  //                 saleBy: cart['packType'],
  //                 totalPrice: cart['total_price'],
  //                 sellingPrice: cart['sell_price'],
  //               );
  //               final cartItem = CartItem(
  //                 detail: detail,
  //                 productName: cart['product_name'],
  //                 totalPrice: double.tryParse(cart['total_price']) ?? 0.0,
  //                 isPack: cart['packType'] == 'Pack',
  //                 count: cart['quantity'],
  //                 customerId: order['customer_id'],
  //                 cartId: cart['cart_id'],
  //                 draftId: order['order_id'],
  //               );
  //               draftItems.add(cartItem);
  //             }
  //           }

  //           log('Draft items fetched from API: ${draftItems.length}');
  //           return draftItems;
  //         } else {
  //           log('API response status is false: ${responseData['message']}');
  //         }
  //       } else {
  //         log('Error fetching draft items from API: ${response.statusCode} ${response.data}');
  //       }
  //     } else {
  //       log('No internet connection. Falling back to local data.');
  //     }

  //     // Fallback to local data
  //     final allItems = CartDatabaseManager().cartBox.values.toList();
  //     final draftItems = allItems
  //         .where((item) =>
  //             item.customerId == customerId &&
  //             item.draftId != null &&
  //             item.draftId!.isNotEmpty)
  //         .toList();
  //     log('Draft items retrieved from local storage: ${draftItems.length}');
  //     return draftItems;
  //   } catch (e) {
  //     log('Error fetching draft items: $e');
  //     return [];
  //   }
  // }

Future<List<CartItem>> getDraftItems(String customerId) async {
  try {
    final allItems = CartDatabaseManager().cartBox.values.toList();
    final draftItems = allItems
        .where((item) =>
            item.customerId == customerId &&
            item.draftId != null &&
            item.draftId!.isNotEmpty)
        .toList();
    log('Draft items retrieved for customer ID: $customerId');
    log('Number of Draft Items: ${draftItems.length}');
    return draftItems;
  } catch (e) {
    log('Error fetching draft items: $e');
    return [];
  }
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

  Future<void> addToCart({
    required Detail detail,
    required String productName,
    required bool isPack,
    required int localCount,
    required String customerId,
  }) async {
    if (localCount <= 0) {
      throw ArgumentError("Error: Count must be greater than zero.");
    }
    final existingItemIndex = cartBox.values.toList().indexWhere((item) =>
        item.detail.variationName == detail.variationName &&
        item.detail.sellPrice == detail.sellPrice &&
        item.customerId == customerId);

    if (existingItemIndex != -1) {
      final existingItem = cartBox.getAt(existingItemIndex)!;
      existingItem.detail.count += localCount.toDouble();
      existingItem.totalPrice = existingItem.isPack!
          ? (existingItem.detail.count *
                  (existingItem.detail.pieces ?? 1) *
                  (double.tryParse(existingItem.detail.sellPrice ?? '0') ?? 0))
              .toDouble()
          : (existingItem.detail.count *
                  (double.tryParse(existingItem.detail.sellPrice ?? '0') ?? 0))
              .toDouble();
      await cartBox.putAt(existingItemIndex, existingItem);
      log('Updated product in cart: ${existingItem.detail.variationName}, '
          'New Count: ${existingItem.detail.count}, Total Price: ${existingItem.totalPrice}');
    } else {
      final computedTotalAmount = isPack
          ? (localCount *
              (detail.pieces ?? 1) *
              (double.tryParse(detail.sellPrice ?? '0') ?? 0))
          : (localCount * (double.tryParse(detail.sellPrice ?? '0') ?? 0));
      detail.count += localCount.toDouble();
      final newCartItem = CartItem(
        detail: detail,
        productName: productName,
        totalPrice: computedTotalAmount.toDouble(),
        isPack: isPack,
        customerId: customerId,
        count: localCount,
      );
      await cartBox.add(newCartItem);
      log('New product added to cart: ${newCartItem.detail.variationName}, '
          'Count: ${newCartItem.detail.count}, Total Price: ${newCartItem.totalPrice}');
    }

    _notifyListeners();
  }

  Future<void> updateCartItemCount(Detail detail, int newCount) async {
    if (newCount <= 0) {
      log("Error: Count must be greater than zero.");
      return;
    }
    try {
      CartItem? existingCartItem = cartBox.values.firstWhere(
        (cartItem) =>
            cartItem.detail.variationName == detail.variationName &&
            cartItem.detail.sellPrice == detail.sellPrice,
        orElse: () => CartItem(detail: detail, productName: '', totalPrice: 0),
      );

      existingCartItem.detail.count += newCount.toDouble();
      existingCartItem.totalPrice = existingCartItem.isPack!
          ? (existingCartItem.detail.count *
                  existingCartItem.detail.pieces! *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toDouble()
          : (existingCartItem.detail.count *
                  num.parse(existingCartItem.detail.sellPrice ?? '0'))
              .toDouble();
      await cartBox.put(existingCartItem.key, existingCartItem);
      log('Updated product in cart: ${existingCartItem.detail.variationName}, New Count: ${existingCartItem.detail.count}, Total Price: ${existingCartItem.totalPrice}');
    } catch (e) {
      log('Error updating cart item: $e');
    }
  }

  Future<void> saveCartAsDraft(
    String? customerId,
    String cartId,
    String draftId,
  ) async {
    log("Cart Id: $cartId");
    log("Draft Id: $draftId");
    log("Customer Id: $customerId");
    if (customerId == null || customerId.isEmpty) {
      log('Error: Customer ID is required to save a draft.');
      return;
    }
    try {
      List<CartItem> cartItems = getCartItems(customerId);
      if (cartItems.isEmpty) {
        log('No items in the cart to save as a draft.');
        return;
      }
      List<CartItem>? existingDraft = await getDraftItems(customerId);
      Map<String, CartItem> draftItemMap = {};
      for (var item in existingDraft) {
        final key =
            '${item.detail.variationName ?? ''}_${item.detail.sellPrice ?? ''}';
        draftItemMap[key] = item;
      }
      for (var cartItem in cartItems) {
        final key =
            '${cartItem.detail.variationName ?? ''}_${cartItem.detail.sellPrice ?? ''}';
        if (draftItemMap.containsKey(key)) {
          final existingItem = draftItemMap[key]!;
          log('Updating item: ${existingItem.productName}, current cartId: ${existingItem.cartId}, draftId: ${existingItem.draftId}');
          draftItemMap[key] = existingItem.copyWith(
            count: (existingItem.count ?? 0) + (cartItem.count ?? 0),
            cartId: cartId,
            draftId: draftId,
          );
          log('Cart Box Contents: ${CartDatabaseManager().cartBox.toMap()}');
        } else {
          draftItemMap[key] = cartItem.copyWith(
            cartId: cartId,
            draftId: draftId,
          );
          log('Cart Box Contents: ${CartDatabaseManager().cartBox.toMap()}');
        }
      }

      for (var item in draftItemMap.values) {
        final itemKey =
            '${item.detail.variationName ?? ''}_${item.detail.sellPrice ?? ''}';
        await CartDatabaseManager().cartBox.put(itemKey, item);
      }

      log('Draft saved successfully for customer ID: $customerId, Draft ID: $draftId CartId $cartId');
    } catch (e) {
      log('Error saving cart as draft: $e');
    }
  }

  Future<Map<String, String?>?> getCartAndDraftIds(String customerId) async {
    try {
      final cartItemsa = CartDatabaseManager()
          .cartBox
          .values
          .where((item) => item.customerId == customerId)
          .cast<CartItem>()
          .toList();
      log('Retrieved cart items for customer: ${cartItems.map((item) => item.toJson()).toList()}');
      if (cartItemsa.isNotEmpty) {
        final firstItem = cartItemsa.last;
        log('First Cart ID : ${firstItem.cartId}');
        log('First Draft ID : ${firstItem.draftId}');
        return {
          'cart_id': firstItem.cartId,
          'id': firstItem.draftId,
        };
      }
      log('No saved cart details found for customer ID: $customerId');
      return null;
    } catch (e) {
      log('Error retrieving cart and draft IDs: $e');
      return null;
    }
  }

  Future<void> updateCart(CartItem updatedItem) async {
    await cartBox.put(updatedItem.key, updatedItem);
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
    final key = item.key;
    if (cartBox.containsKey(key)) {
      log('Item found with key: $key, proceeding to delete');
      cartBox.delete(key);
    } else {
      log('Item with key: $key does not exist in cartBox');
    }
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

  Future<void> clearCart(String customerId) async {
    final cartItems = CartDatabaseManager().getCartItems(customerId);
    final draftItems = await CartDatabaseManager().getDraftItems(customerId);
    final Map<String, CartItem> uniqueItems = {};
    for (var item in cartItems + draftItems) {
      final key =
          '${item.detail.variationName ?? ''}_${item.detail.sellPrice ?? ''}';
      uniqueItems[key] = item;
    }
    final itemsToKeep = uniqueItems.values
        .where((item) => item.draftId != null && item.draftId!.isNotEmpty)
        .toList();
    for (var key in CartDatabaseManager().cartBox.keys) {
      final item = CartDatabaseManager().cartBox.get(key);
      if (item!.draftId == null || item.draftId!.isEmpty) {
        CartDatabaseManager().cartBox.delete(key);
      }
    }
    for (var item in itemsToKeep) {
      final itemKey =
          '${item.detail.variationName ?? ''}_${item.detail.sellPrice ?? ''}';
      await CartDatabaseManager().cartBox.put(itemKey, item);
    }
    log('Cart cleared. Items kept: ${itemsToKeep.length}');
    _notifyListeners();
  }

  Future<void> clearCartOnSave(String customerId) async {
    final cartItems = CartDatabaseManager().getCartItems(customerId);
    final draftItems = await CartDatabaseManager().getDraftItems(customerId);
    final Map<String, CartItem> uniqueItems = {};
    for (var item in cartItems + draftItems) {
      final key =
          '${item.detail.variationName ?? ''}_${item.detail.sellPrice ?? ''}';
      uniqueItems[key] = item;
    }
    for (var key in CartDatabaseManager().cartBox.keys) {
      await CartDatabaseManager().cartBox.delete(key);
    }
    for (var draftItem in draftItems) {
      await CartDatabaseManager().cartBox.delete(draftItem.draftId!);
    }
    _notifyListeners();
  }
}
