//Cart Database 

import 'dart:developer';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/draft_model.dart';
import 'package:dio/dio.dart';
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

  Future<List<CartItem>> getDraftItems(String customerId) async {
    final dio = Dio();
    final apiUrl = 'http://16.50.232.153:3000/fetch_all_order';

    // Request body
    final requestBody = {
      "companyId": 1,
      "customer_id": customerId,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId??'',
      "order_type": 4,
      "payment_type": 1,
      "start_date": "2025-02-01",
      "end_date": "2025-02-28",
      "limit": 1000,
      "page": 1,
    };
    log('Request Body of FetchAll Order $requestBody');
    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();

      if (isOnline) {
        log('Fetching draft items from API for customer ID: $customerId');
        final response = await dio.post(apiUrl, data: requestBody);

        if (response.statusCode == 200) {
          final responseData = response.data;

          if (responseData['status'] == true) {
            final List<dynamic> orders = responseData['data'] ?? [];
            List<CartItem> draftItems = [];
            for (var order in orders) {
              final List<dynamic> carts = order['cart'] ?? [];
              for (var cart in carts) {
                final detail = Detail(
                  id: cart['id'] as int?,
                  productId: cart['product_id'] as String?,
                  variationId: cart['variation_id'] as String?,
                  inNo: cart['in_no'] as String?,
                  barcode: cart['barcode'] as String?,
                  variationName: cart['variation_name'] as String?,
                  unitType: cart['unitType'] as String?,
                  price: cart['price']?.toString(),
                  sellPrice: cart['sell_price']?.toString(),
                  tax: num.tryParse(cart['tax']?.toString() ?? '0'),
                  packtype: cart['packtype'] as String?,
                  pieces: num.tryParse(cart['pieces']?.toString() ?? '0'),
                  stock: num.tryParse(cart['stock']?.toString() ?? '0'),
                  lowstock: num.tryParse(cart['lowstock']?.toString() ?? '0'),
                  fullstock: num.tryParse(cart['fullstock']?.toString() ?? '0'),
                  imageUrl: cart['image_url'] as String?,
                  status: cart['status'] as int?,
                  count: cart['quantity'] ?? 0,
                  saleBy: cart['packtype'] as String?,
                  totalPrice:
                      num.tryParse(cart['total_price']?.toString() ?? '0'),
                  sellingPrice:
                      num.tryParse(cart['sell_price']?.toString() ?? '0'),
                  inclTax: cart['incl_tax'],
                  initialQuantity: cart['quantity']
                );
                final cartItem = CartItem(
                  detail: detail,
                  productName: cart['product_name'],
                  totalPrice:
                  // cart['packtype'] == 'pack' ? double.tryParse(cart['selling_pack_price']) ?? 0.0 : double.tryParse(cart['selling_price']) ?? 0.0,
                  double.tryParse(cart['total_price']) ?? 0.0,
                  count: cart['quantity'],
                  customerId: order['customer_id'],
                  cartId: cart['cart_id'],
                  draftId: order['order_id'],
                  draftTotal: order['order_total']
                );
                draftItems.add(cartItem);
              }
            }

            log('Draft items fetched from API: ${draftItems.length}');
            return draftItems;
          } else {
            log('API response status is false: ${responseData['message']}');
          }
        } else {
          log('Error fetching draft items from API: ${response.statusCode} ${response.data}');
        }
      } else {
        log('No internet connection. Falling back to local data.');
      }

      // Fallback to local data
      final allItems = CartDatabaseManager().cartBox.values.toList();
      final draftItems = allItems
          .where((item) =>
              item.customerId == customerId &&
              item.draftId != null &&
              item.draftId!.isNotEmpty)
          .toList();
      log('Draft items retrieved from local storage: ${draftItems.length}');
      return draftItems;
    } catch (e) {
      log('Error fetching draft items: $e');
      return [];
    }
  }

  // Future<List<CartItem>> getDraftItems(String customerId) async {
  //   try {
  //     final allItems = CartDatabaseManager().cartBox.values.toList();
  //     final draftItems = allItems
  //         .where((item) =>
  //             item.customerId == customerId &&
  //             item.draftId != null &&
  //             item.draftId!.isNotEmpty)
  //         .toList();
  //     log('Draft items retrieved for customer ID: $customerId');
  //     log('Number of Draft Items: ${draftItems.length}');
  //     return draftItems;
  //   } catch (e) {
  //     log('Error fetching draft items: $e');
  //     return [];
  //   }
  // }
  Future<List<CartItem>> getAllDraftItems() async {
    try {
      final allItems = CartDatabaseManager().cartBox.values.toList();
      final draftItems = allItems
          .where((item) =>
              item.draftId != null &&
              item.draftId!.isNotEmpty)
          .toList();
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
      final double effectivePrice =
          inclTax != "incl_tax" ? price + tax : price;
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
  await cartBox.clear();
  log('All Cart cleared.');
 _notifyListeners();
}
Future<void> clearCartOnSave(String customerId) async {
  final cartItems = CartDatabaseManager().getCartItems(customerId);
  final draftItems = await CartDatabaseManager().getDraftItems(customerId);

  final Map<String, CartItem> uniqueItems = {};
  for (var item in cartItems + draftItems) {
    final key =
        '${item.detail.variationName ?? ''}_${item.detail.sellPrice ?? ''}';
    if (item.isChecked!) {
      uniqueItems[key] = item;
    }
  }

  for (var key in CartDatabaseManager().cartBox.keys) {
    final item = CartDatabaseManager().cartBox.get(key);
    if (item != null && item.isChecked!) {
      await CartDatabaseManager().cartBox.delete(key);
    }
  }

  for (var draftItem in draftItems) {
    if (draftItem.isChecked!) {
      await CartDatabaseManager().cartBox.delete(draftItem.draftId!);
    }
  }

  log('Checked items cleared on save. Remaining items: ${uniqueItems.length}');
  _notifyListeners();
}

}


