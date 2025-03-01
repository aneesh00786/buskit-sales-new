//Cart Database

import 'dart:developer';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CartDatabaseManager {
  static final CartDatabaseManager _instance = CartDatabaseManager._internal();
  factory CartDatabaseManager() => _instance;
  CartDatabaseManager._internal();
  final Box<CartItem> cartBox = Hive.box<CartItem>('cartBox');
  final Box<CartItem> draftBox = Hive.box<CartItem>('draftBox');
  final List<VoidCallback> _listeners = [];
  List<CartItem> get cartItems => cartBox.values.toList();
  Future<List<CartItem>> getDraftItems() async {
    final dio = Dio();
    final apiUrl = 'http://16.50.232.153:3000/fetch_all_order';
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? '',
      "customer_id": "",
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "order_type": 4,
      "payment_type": 1,
      "start_date":
          "${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}",
      "end_date":
          "${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}",
      "limit": 1000,
      "page": 1,
    };

    log('Request Body of FetchAll Order $requestBody');
    final List<CartItem> fetchedItems = [];

    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();

      if (isOnline) {
        final response = await dio.post(apiUrl, data: requestBody);
        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData['status'] == true) {
            final List<dynamic> orders = responseData['data'] ?? [];
            await draftBox.clear();
            for (var order in orders) {
              final List<dynamic> carts = order['cart'] ?? [];
              for (var cart in carts) {
                final detail = Detail(
                  productId: cart['product_id'] as String? ?? '',
                  variationId: cart['variation_id'] as String? ?? '',
                  price: cart['price']?.toString() ?? '0',
                  tax: num.tryParse(cart['tax']?.toString() ?? '0') ?? 0,
                  packtype: cart['packtype'] as String? ?? '',
                  pieces: num.tryParse(cart['pieces']?.toString() ?? '0') ?? 0,
                  count: num.tryParse(cart['quantity']?.toString() ?? '0') ?? 0,
                  sellPrice: cart['sell_price']?.toString() ?? '0',
                  inclTax: cart['incl_tax'] as String? ?? '',
                  inNo: cart['in_no'] as String? ?? '',
                  barcode: cart['barcode'] as String? ?? '',
                  variationName: cart['variation_name'] as String? ?? '',
                  unitType: cart['unitType'] as String? ?? '',
                  stock: num.tryParse(cart['stock']?.toString() ?? '0') ?? 0,
                  lowstock:
                      num.tryParse(cart['lowstock']?.toString() ?? '0') ?? 0,
                  fullstock:
                      num.tryParse(cart['fullstock']?.toString() ?? '0') ?? 0,
                  saleBy: cart['packtype'] as String? ?? '',
                  unitTax:
                      num.tryParse(cart['unit_tax']?.toString() ?? '0') ?? 0,
                );
                final cartItem = CartItem(
                  detail: detail,
                  productName: cart['product_name'] as String? ?? '',
                  totalPrice:
                      double.tryParse(cart['total_price']?.toString() ?? '0') ??
                          0.0,
                  customerId: order['customer_id'] as String? ?? '',
                  cartId: cart['cart_id'] as String? ?? '',
                  draftId: order['order_id'] as String? ?? '',
                  isPack: (cart['packtype'] as String? ?? '') == "Pack",
                );

                log('Draft ID : ${cartItem.draftId}');
                log('Cart Items JSON ${cartItem.toJson()}');
                await draftBox.add(cartItem);
                fetchedItems.add(cartItem);
              }
            }
          } else {
            log('API response status is false: ${responseData['message']}');
          }
        } else {
          log('Error fetching draft items from API: ${response.statusCode} ${response.data}');
        }
      } else {
        log('No internet connection. Skipping API fetch.');
      }
      return fetchedItems;
    } catch (e) {
      log('Error fetching draft items: $e');
      return [];
    }
  }

  Future<List<CartItem>> getCartItems(String customerId) async {
    try {
      final customerCartItems = cartBox.values
          .where((item) => item.customerId == customerId)
          .toList();
      final customerDraftItems = draftBox.values
          .where((item) => item.customerId == customerId)
          .toList();
      log('Customer Cart Items:');
      for (var item in customerCartItems) {
        log('Cart Item: ${item.toJson()}');
      }
      log('Customer Draft Items:');
      for (var item in customerDraftItems) {
        log('Draft Item: ${item.toJson()}');
      }
      final combinedItems = [...customerCartItems, ...customerDraftItems];
      log('Combined Cart and Draft Items:');
      log('combinedItems length:${combinedItems.length}');
      for (var item in combinedItems) {
        log('Combined Item: ${item.toJson()}');
      }

      return Future.value(combinedItems);
    } catch (e) {
      log('Error retrieving combined items for customer $customerId: $e');
      return Future.value([]);
    }
  }

  Future<List<Map<String, String?>>> getDraftAndCartIdsFromApi(
      String customerId) async {
    final dio = Dio();
    final apiUrl = 'http://16.50.232.153:3000/fetch_all_order';
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "customer_id": customerId,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "order_type": 4,
      "payment_type": 1,
      "start_date":
          "${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}",
      "end_date":
          "${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}",
      "limit": 1000,
      "page": 1,
    };
    log('Request Body of FetchAll Order: $requestBody');

    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();

      if (isOnline) {
        log('Fetching draft and cart IDs from API for customer ID: $customerId');
        final response = await dio.post(apiUrl, data: requestBody);
        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData['status'] == true) {
            final List<dynamic> orders = responseData['data'] ?? [];
            List<Map<String, String?>> draftAndCartIds = [];
            for (var order in orders) {
              draftAndCartIds.add({
                'cart_id': order['cart_id'] as String?,
                'draft_id': order['order_id'] as String?,
              });
            }
            log('Draft and Cart IDs fetched from API: $draftAndCartIds');
            return draftAndCartIds;
          } else {
            log('API response status is false: ${responseData['message']}');
          }
        } else {
          log('Error fetching draft and cart IDs from API: ${response.statusCode} ${response.data}');
        }
      } else {
        log('No internet connection.');
      }
    } catch (e) {
      log('Error fetching draft and cart IDs: $e');
    }
    return [];
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
    required String inclTax,
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
      final double price = double.tryParse(detail.sellPrice ?? '0') ?? 0;
      final num tax = detail.tax ?? 0;
      final double effectivePrice = inclTax != "incl_tax" ? price + tax : price;
      final computedTotalAmount = isPack
          ? (localCount * (detail.pieces ?? 1) * effectivePrice)
          : (localCount * effectivePrice);
      log('Incl Tax $inclTax');
      detail.count += localCount.toDouble();
      detail.inclTax = inclTax;
      final newCartItem = CartItem(
        detail: detail,
        productName: productName,
        totalPrice: computedTotalAmount.toDouble(),
        isPack: isPack,
        customerId: customerId,
        count: localCount,
        boxType: false,
      );
      await cartBox.add(newCartItem);
      log('New product added to cart: ${newCartItem.detail.variationName}, '
          'Count: ${newCartItem.detail.count}, Total Price: ${newCartItem.totalPrice}');
    }
    _notifyListeners();
  }

  Future<void> moveCartItemsToDraft(String customerId) async {
    final List<CartItem> cartItems =
        cartBox.values.where((item) => item.customerId == customerId).toList();
    for (final CartItem cartItem in cartItems) {
      final CartItem draftItem = CartItem(
        detail: cartItem.detail,
        productName: cartItem.productName,
        totalPrice: cartItem.totalPrice,
        isPack: cartItem.isPack,
        count: cartItem.count,
        customerId: cartItem.customerId,
        cartId: cartItem.cartId,
        isChecked: cartItem.isChecked,
        draftTotal: cartItem.draftTotal,
        salesmanId: cartItem.salesmanId,
        boxType: true,
      );
      await draftBox.add(draftItem);
    }
    final List<int> indicesToRemove = cartBox.keys
        .where((key) => cartBox.get(key)?.customerId == customerId)
        .cast<int>()
        .toList();

    for (final int index in indicesToRemove) {
      await cartBox.delete(index);
    }

    log('Cart items moved to draftBox and cartBox cleared for customer: $customerId');
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
    if (updatedItem.boxType == false) {
      await cartBox.put(updatedItem.key, updatedItem);
    } else {
      await draftBox.put(updatedItem.key, updatedItem);
    }
    _notifyListeners();
  }

  void deleteCartItem(CartItem item) {
    final key = item.key;
    if (item.boxType == false) {
      if (cartBox.containsKey(key)) {
        log('Item found with key: $key, proceeding to delete');
        cartBox.delete(key);
      } else {
        log('Item with key: $key does not exist in cartBox');
      }
    } else {
      if (draftBox.containsKey(key)) {
        log('Item found with key: $key, proceeding to delete');
        draftBox.delete(key);
      } else {
        log('Item with key: $key does not exist in cartBox');
      }
    }
    _notifyListeners();
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

  Future<void> clearCart() async {
    
    await cartBox.clear();
    await draftBox.clear();
    _notifyListeners();
  }
}
