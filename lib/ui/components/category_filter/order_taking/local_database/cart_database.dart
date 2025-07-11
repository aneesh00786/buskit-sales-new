//Cart Database

import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CartDatabaseManager {
  static final CartDatabaseManager _instance = CartDatabaseManager._internal();
  factory CartDatabaseManager() => _instance;
  CartDatabaseManager._internal();
  final Box<CartItem> cartBox = Hive.box<CartItem>('cartBox');
  final Box<CartItem> draftBox = Hive.box<CartItem>('draftBox');
  final List<VoidCallback> _listeners = [];
  List<CartItem> get cartItems => cartBox.values.toList();
  
  /// Get cart items that don't have a customer ID assigned
  List<CartItem> get orphanedCartItems => cartBox.values
      .where((item) => item.customerId == null || item.customerId!.isEmpty)
      .toList();
      
  List<CartItem> getDraftItemsForCustomer(String customerId) {
    return draftBox.values
        .where((item) => item.customerId == customerId)
        .toList();
  }

  Future<List<CartItem>> getDraftItems() async {
    final dio = Dio();
    const apiUrl = '${ApiConstants.baseUrl}fetch_all_order';
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? '',
      "customer_id": "",
      "salesman_id": '',
      "order_type": 4,
      "payment_type": 1,
      "start_date":
          "${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}",
      "end_date":
          "${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}",
      "limit": 1000,
      "page": 1,
    };

    log('Request Body of FetchAll Order draft :$requestBody');
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
                final double discountPercentage =
                    (num.tryParse(cart['discount']?.toString() ?? '0') ?? 0) /
                        100;
                final double discountedSellPrice =
                    (num.tryParse(cart['sell_price']?.toString() ?? '0') ?? 0) *
                        (1 - discountPercentage);
                final num totalTax =
                    num.tryParse(cart['total_tax'].toString()) ?? 0;
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
                  totaltax:
                      num.tryParse(cart['total_tax']?.toString() ?? '0') ?? 0,
                  unitType: cart['unitType'] as String? ?? '',
                  stock: num.tryParse(cart['stock']?.toString() ?? '0') ?? 0,
                  lowstock:
                      num.tryParse(cart['lowstock']?.toString() ?? '0') ?? 0,
                  fullstock:
                      num.tryParse(cart['fullstock']?.toString() ?? '0') ?? 0,
                  saleBy: cart['packtype'] as String? ?? '',
                  unitTax:
                      num.tryParse(cart['unit_tax']?.toString() ?? '0') ?? 0,
                  discount: num.tryParse(cart['discount'].toString()) ?? 0,
                );
                final cartItem = CartItem(
                    detail: detail,
                    productName: cart['product_name'] as String? ?? '',
                    totalPrice: (discountedSellPrice *
                            (detail.packtype == 'Pack'
                                ? (detail.pieces ?? 1) *
                                    (num.tryParse(
                                            cart['quantity'].toString()) ??
                                        0)
                                : (num.tryParse(cart['quantity'].toString()) ??
                                    0))) +
                        (cart['incl_tax'] == "" || cart['incl_tax'] == null
                            ? totalTax
                            : 0),
                    customerId: order['customer_id'] as String? ?? '',
                    cartId: cart['cart_id'] as String? ?? '',
                    draftId: order['order_id'] as String? ?? '',
                    isPack: (cart['packtype'] as String? ?? '') == "Pack",
                    catId: cart['catId'] as int? ?? 0);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'cartId', cart['cart_id'] as String? ?? '');
                await prefs.setString(
                    'draftId', order['order_id'] as String? ?? '');
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
    } on DioException catch (e) {
      log('Error fetching draft items: $e');
      // handleExceptionMessage(
      //       response: e.response, apiName: "draft");
      return [];
    }
  }

  Future<Map<String, String>> getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getString('cartId') ?? '';
    final draftId = prefs.getString('draftId') ?? '';
    return {
      'cartId': cartId,
      'draftId': draftId,
    };
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
    const apiUrl = '${ApiConstants.baseUrl}fetch_all_order';
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

  double calculateEffectivePrice({
    required Detail detail,
    required bool isPack,
    required int catId,
    required String customerId,
    required CustomerDiscountModel? discountData,
    required int localCount,
  }) {
    double effectiveSellingPrice =
        double.tryParse(detail.sellPrice ?? '0') ?? 0;
    num itemCount = detail.count > 0 ? detail.count : 1;
    double discountSellingPrice = isPack
        ? (effectiveSellingPrice * (detail.pieces ?? 1) * itemCount)
        : (effectiveSellingPrice * itemCount);

    log('Discount Selling Price== $discountSellingPrice');
    log('Effective Selling Price== $effectiveSellingPrice');

    if (discountData != null && discountData.customerId == customerId) {
      log('Checking applicable discounts for catId: $catId against customer discount categories: ${discountData.discounts?.map((discount) => discount.categoriesId).toList()}');
      final applicableDiscount = discountData.discounts?.firstWhere(
        (discount) {
          log('Evaluating discount: ${discount.categoriesId}, '
              'Effective Selling Price: $effectiveSellingPrice, '
              'Discount Value: ${discount.value}');
          return discount.categoriesId == catId.toString() &&
              discountSellingPrice * localCount >
                  (double.tryParse(discount.value ?? '0') ?? 0);
        },
        orElse: () {
          log('No matching discount found for catId: $catId or discount selling price is less than discount value.');
          return DiscountModel();
        },
      );

      if (applicableDiscount != null) {
        final double discountPercentage =
            double.tryParse(applicableDiscount.discount ?? '0') ?? 0;
        effectiveSellingPrice -=
            (effectiveSellingPrice * discountPercentage / 100);
        log('Applied discount of $discountPercentage% to product in category ${applicableDiscount.categoriesId}. '
            'New Selling Price: $effectiveSellingPrice');
        log('Discount Amount: $discountPercentage');
        detail.discount = discountPercentage;
      } else {
        log('No applicable discount found for category ID: $catId or discount selling price is less than discount value.');
        detail.discount = 0;
      }
    }

    return effectiveSellingPrice;
  }

  Future<void> addToCart({
    required Detail detail,
    required String productName,
    required bool isPack,
    required int localCount,
    required String customerId,
    required String inclTax,
    required bool isChcked,
    required int catId,
  }) async {
    if (localCount <= 0) {
      throw ArgumentError("Error: Count must be greater than zero.");
    }
    final discountBox = await Hive.openBox<CustomerDiscountModel>('discounts');
    CustomerDiscountModel? discountData;
    discountData = discountBox.values.firstWhere(
      (discount) => discount.customerId == customerId,
      orElse: () => CustomerDiscountModel(),
    );

    double effectiveSellingPrice = calculateEffectivePrice(
      detail: detail,
      isPack: isPack,
      catId: catId,
      customerId: customerId,
      discountData: discountData,
      localCount: localCount,
    );

    double discountPercentage =
        double.tryParse(detail.discount?.toString() ?? '0') ?? 0.0;
    double discountedTax = detail.tax != null
        ? detail.tax! - (detail.tax! * discountPercentage / 100)
        : 0.0;

    final existingDraftItemIndex = draftBox.values.toList().indexWhere((item) =>
        item.detail.variationName == detail.variationName &&
        item.detail.sellPrice == detail.sellPrice &&
        item.customerId == customerId);
    if (existingDraftItemIndex != -1) {
      final existingDraftItem = draftBox.getAt(existingDraftItemIndex)!;
      existingDraftItem.detail.count += localCount.toDouble();
      existingDraftItem.totalPrice = existingDraftItem.isPack!
          ? (existingDraftItem.detail.count *
                  (existingDraftItem.detail.pieces ?? 1) *
                  effectiveSellingPrice)
              .toDouble()
          : (existingDraftItem.detail.count * effectiveSellingPrice).toDouble();
      await draftBox.putAt(existingDraftItemIndex, existingDraftItem);
      log('Updated product in draft: ${existingDraftItem.detail.variationName}, '
          'New Count: ${existingDraftItem.detail.count}, Total Price: ${existingDraftItem.totalPrice}');
    } else {
      final existingCartItemIndex = cartBox.values.toList().indexWhere((item) =>
          item.detail.variationName == detail.variationName &&
          item.detail.sellPrice == detail.sellPrice &&
          item.customerId == customerId);
      if (existingCartItemIndex != -1) {
        final existingCartItem = cartBox.getAt(existingCartItemIndex)!;
        final double priceWithTax =
            existingCartItem.detail.inclTax != "incl_tax"
                ? effectiveSellingPrice + discountedTax
                : effectiveSellingPrice;
        existingCartItem.detail.count += localCount.toDouble();
        existingCartItem.totalPrice = existingCartItem.isPack!
            ? (existingCartItem.detail.count *
                    (existingCartItem.detail.pieces ?? 1) *
                    priceWithTax)
                .toDouble()
            : (existingCartItem.detail.count * priceWithTax).toDouble();
        await cartBox.putAt(existingCartItemIndex, existingCartItem);
        log('Updated product in cart: ${existingCartItem.detail.variationName}, '
            'New Count: ${existingCartItem.detail.count}, Total Price: ${existingCartItem.totalPrice}');
      } else {
        final double priceWithTax = inclTax != "incl_tax"
            ? effectiveSellingPrice + discountedTax
            : effectiveSellingPrice;
        final computedTotalAmount = isPack
            ? (localCount * (detail.pieces ?? 1) * priceWithTax)
            : (localCount * priceWithTax);
        log('Incl Tax: $inclTax');
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
          isChecked: isChcked,
          catId: catId,
        );
        await cartBox.add(newCartItem);
        log('New product added to cart: ${newCartItem.detail.variationName}, '
            'Count: ${newCartItem.detail.count}, Total Price: ${newCartItem.totalPrice}');
      }
    }
  }

  Future<void> moveCartItemsToDraft(String customerId) async {
    final List<CartItem> cartItemsToMove =
        cartBox.values.where((item) => item.customerId == customerId).toList();
    for (final CartItem cartItem in cartItemsToMove) {
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
        catId: cartItem.catId,
        boxType: true,
      );
      await draftBox.add(draftItem);
    }
    await cartBox.clear();
    await getCartItems(customerId);
    log('Unchecked cart items moved to draftBox, and checked items removed for customer: $customerId');
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
  }

  Future<void> clearCart({required String customerId}) async {
    try {
      List<CartItem> remainingCartItems = cartBox.values
          .where(
              (item) => item.customerId == customerId && item.isChecked != true)
          .toList();

      List<CartItem> remainingDraftItems = draftBox.values
          .where(
              (item) => item.customerId == customerId && item.isChecked != true)
          .toList();
      log('Remaining Cart Items for Customer $customerId: ${remainingCartItems.map((e) => e.toJson()).toList()}');
      log('Remaining Draft Items for Customer $customerId: ${remainingDraftItems.map((e) => e.toJson()).toList()}');
      await cartBox.clear();
      await draftBox.clear();
      await cartBox.putAll(
        {
          for (var e in remainingCartItems)
            '${e.customerId}-${e.detail.variationId}': e
        },
      );
      await draftBox.putAll(
        {
          for (var e in remainingDraftItems)
            '${e.customerId}-${e.detail.variationId}': e
        },
      );

      log('Cart and Draft cleared for customer $customerId while retaining unchecked items.');
      getCartItems(customerId);
    } catch (e) {
      log('Error in clearCart for customer $customerId: $e');
    }
  }

  Future<void> clearCompleteCart() async {
    await cartBox.clear();
    await draftBox.clear();
  }

  /// Handles cart persistence when the app is restarted
  /// If cart has items and productsController.selectedCustomerId is present, saves as draft
  /// If no customer ID is present, clears the cart items
  Future<void> handleCartPersistenceOnRestart(String? selectedCustomerId) async {
    try {
      log('=== Cart Persistence on Restart ===');
      log('Checking cart persistence on app restart...');
      
      // Check if there are any cart items
      final cartItems = this.cartItems;
      final orphanedItems = this.orphanedCartItems;
      log('Total cart items found on restart: ${cartItems.length}');
      log('Orphaned cart items (no customer ID): ${orphanedItems.length}');
      
      if (cartItems.isNotEmpty) {
        log('Cart items details:');
        for (int i = 0; i < cartItems.length; i++) {
          final item = cartItems[i];
          log('  Item $i: ${item.productName} - Customer: ${item.customerId ?? 'null'} - Count: ${item.count}');
        }
        
        if (selectedCustomerId != null && selectedCustomerId.isNotEmpty) {
          log('Customer ID present: $selectedCustomerId. Moving cart items to draft...');
          
          // Move cart items to draft for the selected customer
          await moveCartItemsToDraft(selectedCustomerId);
          log('Cart items successfully moved to draft for customer: $selectedCustomerId');
        } else {
          log('No customer ID present. Clearing cart items...');
          
          // Clear all cart items if no customer ID is present
          await clearCompleteCart();
          log('Cart items cleared due to no customer ID');
        }
      } else {
        log('No cart items found on app restart');
      }
      log('=== Cart Persistence Complete ===');
    } catch (e) {
      log('Error handling cart persistence on restart: $e');
      log('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> saveDraftOffline({
    required String customerId,
    required String salesmanId,
    required double totalAmount,
    required List<Detail> details,
  }) async {
    try {
      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
      int existingDraftIndex =
          drafts.indexWhere((draft) => draft['customer_id'] == customerId);
      if (existingDraftIndex != -1) {
        var existingDraft = drafts[existingDraftIndex];
        List<dynamic> existingDetails = existingDraft['details'];
        for (var detail in details) {
          int existingVariantIndex = existingDetails.indexWhere(
            (d) => d['variant_id'] == detail.variationId,
          );
          if (existingVariantIndex != -1) {
            existingDetails[existingVariantIndex]['quantity'] +=
                detail.count.toInt();
          } else {
            existingDetails.add({
              'product_id': detail.productId ?? '',
              'variant_id': detail.variationId ?? '',
              'pack': detail.saleBy == 'Pack'
                  ? detail.pieces.toString()
                  : detail.count.toString(),
              'packType': detail.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              'price': detail.sellPrice.toString(),
              'discount': detail.discount,
              'quantity': detail.count.toInt(),
              'variant_name': detail.variationName ?? '',
            });
          }
        }
      } else {
        final orderId = DateTime.now().millisecondsSinceEpoch.toString();
        final newDraft = {
          'order_id': orderId,
          'customer_id': customerId,
          'salesman_id': salesmanId,
          'total_amount': totalAmount,
          'details': details.map((e) {
            return {
              'product_id': e.productId ?? '',
              'variant_id': e.variationId ?? '',
              'pack':
                  e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString(),
              'packType': e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              'price': e.sellPrice.toString(),
              'discount': e.discount,
              'quantity': e.count.toInt(),
              'variant_name': e.variationName ?? '',
            };
          }).toList(),
        };
        drafts.add(newDraft);
      }
      await offlineDraftsBox.put('drafts', drafts);
      log('[saveDraftOffline] All drafts after saving: $drafts');
    } catch (e) {
      log('[saveDraftOffline] Error saving draft locally: $e');
    }
  }
}
