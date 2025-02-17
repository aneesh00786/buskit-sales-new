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
  Future<List<CartItem>> getCartItems(String customerId) async {
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
    const apiUrl = 'http://16.50.232.153:3000/fetch_all_order';
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id,
      "customer_id": customerId,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId,
      "order_type": 4,
      "payment_type": 1,
      "start_date": "2025-02-01",
      "end_date": "2025-02-28",
      "limit": 1000,
      "page": 1
    };

    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();
      if (isOnline) {
        log('Fetching draft items from API for customer ID: $customerId');
        final response = await dio.post(apiUrl, data: requestBody);
        log('Response received from API: ${response.data}');
        if (response.statusCode == 200) {
          final responseData = response.data;
          log('API Response Status: ${responseData['status']}');
          if (responseData['status'] == true) {
            final List<dynamic> orders = responseData['data'] ?? [];
            log('Orders fetched: ${orders.length}');
            List<CartItem> draftItems = [];
            for (var order in orders) {
              final List<dynamic> carts = order['cart'] ?? [];
              log('Processing order with ${carts.length} cart items.');
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
                  createdAt: cart['created_at'] as String?,
                  updatedAt: cart['updated_at'] as String?,
                  count: cart['quantity'] ?? 0,
                  saleBy: cart['packType'] as String?,
                  totalPrice:
                      num.tryParse(cart['total_price']?.toString() ?? '0'),
                  sellingPrice:
                      num.tryParse(cart['sell_price']?.toString() ?? '0'),
                );
                final cartItem = CartItem(
                  detail: detail,
                  productName: cart['product_name'] as String? ?? '',
                  totalPrice: double.tryParse(
                          cart['total_price']?.toString() ?? '0.0') ??
                      0.0,
                  isPack: (cart['packType'] as String?) == 'Pack',
                  count: cart['quantity'] as int?,
                  customerId: order['customer_id'] as String?,
                  cartId: cart['cart_id'] as String?,
                  draftId: order['order_id'] as String?,
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

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  clearCart() async{
  await cartBox.clear();  
    _notifyListeners();
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
        item.detail.price == detail.price &&
        item.customerId == customerId);

    if (existingItemIndex != -1) {
      final existingItem = cartBox.getAt(existingItemIndex)!;
      existingItem.detail.count += localCount.toDouble();
      existingItem.totalPrice = existingItem.isPack!
          ? (existingItem.detail.count *
                  (existingItem.detail.pieces ?? 1) *
                  (double.tryParse(existingItem.detail.price ?? '0') ?? 0))
              .toDouble()
          : (existingItem.detail.count *
                  (double.tryParse(existingItem.detail.price ?? '0') ?? 0))
              .toDouble();
      await cartBox.putAt(existingItemIndex, existingItem);
      log('Updated product in cart: ${existingItem.detail.variationName}, '
          'New Count: ${existingItem.detail.count}, Total Price: ${existingItem.totalPrice}');
    } else {
      final double sellPrice = double.tryParse(detail.price ?? '0') ?? 0;
      final num tax = detail.tax ?? 0;
      final double effectivePrice =
          inclTax != "incl_tax" ? sellPrice + tax : sellPrice;
      final computedTotalAmount = isPack
          ? (localCount * (detail.pieces ?? 1) * effectivePrice)
          : (localCount * effectivePrice);

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

  Future<void> updateCart(CartItem updatedItem) async {
    await cartBox.put(updatedItem.key, updatedItem);
    _notifyListeners();
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
}
