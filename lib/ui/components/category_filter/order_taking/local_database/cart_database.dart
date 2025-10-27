//Cart Database

// ignore_for_file: avoid_print

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
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
  // List<CartItem> cartItems = cartBox.values.toList();
  List<CartItem> get cartItems => cartBox.values.toList();

  /// Get cart items that don't have a customer ID assigned
  List<CartItem> get orphanedCartItems => cartBox.values
      .where((item) => item.customerId == null || item.customerId!.isEmpty)
      .toList();

  List<CartItem> getDraftItemsForCustomer(String customerId) {
    final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId;
    return draftBox.values
        .where((item) =>
            item.customerId == customerId &&
            item.salesmanId == currentSalesmanId)
        .toList();
  }

  Future<List<CartItem>> getDraftItems() async {
    final dio = Dio();
    const apiUrl = '${ApiConstants.baseUrl}fetch_all_order';
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final companyId = SessionHelper.loginSavedData?.company_id ?? '';
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    final requestBody = {
      "companyId": companyId,
      "customer_id": "",
      "salesman_id": salesmanId,
      "order_type": 4,
      "payment_type": 1,
      "start_date":
          "${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}",
      "end_date":
          "${endOfMonth.year}-${endOfMonth.month.toString().padLeft(2, '0')}-${endOfMonth.day.toString().padLeft(2, '0')}",
      "limit": 1000,
      "page": 1,
    };

    final List<CartItem> fetchedItems = [];
    // Caching logic
    final cacheKey = '${companyId}_$salesmanId';
    final draftItemsBox = await Hive.openBox('draftItemsBox');
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
                  variationName: cart['is_bundle'] == true
                      ? cart['title']
                      : cart['variation_name'] as String? ?? '',
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
                  productName: cart['is_bundle'] == true
                      ? cart['title']
                      : cart['product_name'] as String? ?? '',
                  maxDiscount:
                      cart['max_discount'] != null || cart['max_discount'] != ""
                          ? num.tryParse(cart['max_discount'].toString())
                          : null,
                );
                final cartItem = CartItem(
                  detail: detail,
                  productName: cart['is_bundle'] == true
                      ? cart['title']
                      : cart['product_name'] as String? ?? '',
                  totalPrice: (discountedSellPrice *
                          (detail.packtype == 'Pack'
                              ? (detail.pieces ?? 1) *
                                  (num.tryParse(cart['quantity'].toString()) ??
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
                  catId: cart['catId'] as int? ?? 0,
                  salesmanId: order['salesman_id'] as String? ?? '',
                  isPromo: cart['is_promo'] == 1,
                  promoCode: (cart['promo_code'] != null &&
                          cart['promo_code'].toString().isNotEmpty)
                      ? cart['promo_code'].toString()
                      : null,
                  promoMsg: cart['is_bundle'] == true
                      ? _buildBundlePromoMsg(cart)
                      : (cart['promo_msg'] != null &&
                              cart['promo_msg'].toString().isNotEmpty)
                          ? cart['promo_msg'].toString()
                          : null,
                );

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'cartId', cart['cart_id'] as String? ?? '');
                await prefs.setString(
                    'draftId', order['order_id'] as String? ?? '');
                await draftBox.add(cartItem);
                fetchedItems.add(cartItem);
              }
            }
            await draftItemsBox.put(
                cacheKey, fetchedItems.map((e) => e.toJson()).toList());
          }
        }
      }
      final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId;
      return fetchedItems
          .where((item) => item.salesmanId == currentSalesmanId)
          .toList();
    } on DioException {
      final cachedData = draftItemsBox.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        return List<Map<String, dynamic>>.from(cachedData)
            .map((e) => CartItem.fromJson(e))
            .toList();
      }
      return [];
    }
  }

  String _buildBundlePromoMsg(Map<String, dynamic> cart) {
    String bundleDetailsMsg = "Bundle: ${cart['title'] ?? 'Bundle'}\n\n      ";

    final bundleItems = cart['bundle_items'];
    // final products = cart.prod; // optional

    if (bundleItems != null && bundleItems is List && bundleItems.isNotEmpty) {
      bundleDetailsMsg += "Items included:\n";

      for (final bundleItem in bundleItems) {
        String productName = bundleItem['product_name'] ?? 'Unknown';
        String variationName = bundleItem['variation_name'] ?? '';
        String unitType = bundleItem['unitType'] ?? '';
        final qty = bundleItem['quantity'] ?? 1;
        String variationId = bundleItem['variant_id'] ?? '';

        double unitPrice =
            double.tryParse(bundleItem['unit_price'].toString()) ?? 0;

        final totalPrice = unitPrice * qty;

        bundleDetailsMsg +=
            "      • $productName (${variationName.trim().isNotEmpty ? variationName : ''})\n";
        bundleDetailsMsg += "        Qty: $qty $unitType\n";
        bundleDetailsMsg +=
            "        Price: ${formatAmount(unitPrice.toString())} each\n";
        bundleDetailsMsg +=
            "        Total: ${formatAmount(totalPrice.toString())}\n";
        bundleDetailsMsg += "        Variant Id: $variationId\n\n";
      }

      bundleDetailsMsg +=
          "Bundle Price: ${formatAmount(cart['bundle_price']?.toString() ?? '0')}";
    }

    return bundleDetailsMsg;
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

  Future<List<CartItem>> getCartItems(String customerId,
      {bool draftsOnly = false}) async {
    try {
      if (draftsOnly) {
        final customerDraftItems = draftBox.values
            .where((item) => item.customerId == customerId)
            .toList();
        final Map<String, CartItem> deduped = {};
        for (var item in customerDraftItems) {
          final key = item.detail.variationId ?? '';
          if (deduped.containsKey(key)) {
            deduped[key]!.detail.count += item.detail.count;
          } else {
            final clonedItem = CartItem.fromJson(item.toJson());
            deduped[key] = clonedItem;
          }
        }
        final result = deduped.values.toList();
        return Future.value(result);
      } else {
        List<CartItem> customerOfflineDraftItems = [];
        var offlineDraftsBox = await Hive.openBox('offlineDrafts');
        List<dynamic> drafts =
            offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
        final draft = drafts.firstWhere(
          (d) => d['customer_id'] == customerId,
          orElse: () => null,
        );
        if (draft != null) {
          final List details = draft['details'];
          final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
          for (var detail in details) {
            final cartItem = CartItem(
              detail: Detail(
                productId: detail['product_id'],
                variationId: detail['variant_id'],
                sellPrice: detail['price'],
                discount: detail['discount'],
                count: (detail['quantity'] as num?)?.toDouble() ?? 0,
                pieces: int.tryParse(detail['pack'] ?? '0'),
                variationName: detail['variant_name'],
                saleBy: detail['packType'],
                stock: detail['stock'] ?? 0,
                unitType: detail['unitType'],
                packtype: detail['packType'],
                productName: detail['product_name'],
                tax: detail['tax'],
                inclTax: detail['incl_tax'],
              ),
              productName: detail['product_name'],
              totalPrice:
                  double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
              isPack: detail['packType'] == 'Pack',
              customerId: customerId,
              salesmanId: salesmanId,
              catId: 0,
              isPromo: draft['is_promo'] == 1 ? true : false,
              promoCode:
                  draft['promo_code'] == null || draft['promo_code'] == ""
                      ? draft['promo_code']
                      : null,
              promoMsg: draft['title'] == null || draft['title'] == ""
                  ? draft['title']
                  : null,
            );
            customerOfflineDraftItems.add(cartItem);
          }
        }

        final customerCartItems = cartBox.values
            .where((item) => item.customerId == customerId)
            .toList();

        final customerDraftItems = draftBox.values
            .where((item) => item.customerId == customerId)
            .toList();

        final Map<String, CartItem> itemMap = {};

        for (var item in customerCartItems) {
          final key = item.detail.variationId ?? '';
          itemMap[key] = item;
        }

        for (var item in customerDraftItems) {
          final key = item.detail.variationId ?? '';
          if (!itemMap.containsKey(key)) {
            itemMap[key] = item;
          }
        }

        for (var item in customerOfflineDraftItems) {
          final key = item.detail.variationId ?? '';
          if (!itemMap.containsKey(key)) {
            itemMap[key] = item;
          }
        }

        final combinedItems = itemMap.values.toList();
        return Future.value(combinedItems);
      }
    } catch (e) {
      return Future.value([]);
    }
  }

  Future<List<Map<String, String?>>> getDraftAndCartIdsFromApi(
      String customerId) async {
    final dio = Dio();
    const apiUrl = '${ApiConstants.baseUrl1}/fetch_all_order';
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

    try {
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();

      if (isOnline) {
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
            return draftAndCartIds;
          }
        }
      }
    } catch (e) {
      //
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

    if (discountData != null && discountData.customerId == customerId) {
      final applicableDiscount = discountData.discounts?.firstWhere(
        (discount) {
          return discount.categoriesId == catId.toString() &&
              discountSellingPrice * localCount >
                  (double.tryParse(discount.value ?? '0') ?? 0);
        },
        orElse: () {
          return DiscountModel();
        },
      );

      if (applicableDiscount != null) {
        final double discountPercentage =
            double.tryParse(applicableDiscount.discount ?? '0') ?? 0;
        effectiveSellingPrice -=
            (effectiveSellingPrice * discountPercentage / 100);
        detail.discount = discountPercentage;
      } else {
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
      } else {
        final double priceWithTax = inclTax != "incl_tax"
            ? effectiveSellingPrice + discountedTax
            : effectiveSellingPrice;
        final computedTotalAmount = isPack
            ? (localCount * (detail.pieces ?? 1) * priceWithTax)
            : (localCount * priceWithTax);
        final newDetail = Detail.fromJson(detail.toJson());
        newDetail.count = localCount.toDouble();
        newDetail.inclTax = inclTax;
        final newCartItem = CartItem(
          detail: newDetail,
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
      }
    }
  }

  Future<void> addToCartPromo({
    required Detail detail,
    required String productName,
    required bool isPack,
    required int localCount,
    required String customerId,
    required String inclTax,
    required bool isChcked,
    required int catId,
    String? promoCode,
    String? promoMsg,
  }) async {
    if (localCount <= 0) {
      throw ArgumentError("[PROMO] Error: Count must be greater than zero.");
    }

    double effectiveSellingPrice = calculateEffectivePrice(
      detail: detail,
      isPack: isPack,
      catId: catId,
      customerId: customerId,
      discountData: null,
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
    } else {
      final existingCartItemIndex = cartBox.values.toList().indexWhere((item) =>
          item.detail.variationName == detail.variationName &&
          item.detail.sellPrice == detail.sellPrice &&
          item.customerId == customerId);

      if (existingCartItemIndex != -1) {
        final existingCartItem = cartBox.getAt(existingCartItemIndex)!;
        final double priceWithTax = inclTax != "incl_tax"
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
      } else {
        final double priceWithTax = inclTax != "incl_tax"
            ? effectiveSellingPrice + discountedTax
            : effectiveSellingPrice;
        final computedTotalAmount = isPack
            ? (localCount * (detail.pieces ?? 1) * priceWithTax)
            : (localCount * priceWithTax);

        final newDetail = Detail.fromJson(detail.toJson());
        newDetail.count = localCount.toDouble();
        newDetail.inclTax = inclTax;

        final newCartItem = CartItem(
          detail: newDetail,
          productName: productName,
          totalPrice: computedTotalAmount.toDouble(),
          isPack: isPack,
          customerId: customerId,
          count: localCount,
          boxType: false,
          isChecked: isChcked,
          catId: catId,
          isPromo: true,
          promoCode: promoCode,
          promoMsg: promoMsg,
        );

        await cartBox.add(newCartItem);
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
  }

  Future<void> updateCartItemCount(Detail detail, int newCount) async {
    if (newCount <= 0) {
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
    } catch (e) {
      //
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
      if (cartItemsa.isNotEmpty) {
        final firstItem = cartItemsa.last;
        return {
          'cart_id': firstItem.cartId,
          'id': firstItem.draftId,
        };
      }
      return null;
    } catch (e) {
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
        cartBox.delete(key);
      }
    } else {
      if (draftBox.containsKey(key)) {
        draftBox.delete(key);
      }
    }
  }

  Future<void> clearCart({required String customerId}) async {
    try {
      List<CartItem> remainingCartItems = cartBox.values
          .where((item) => item.customerId != customerId)
          .toList();
      List<CartItem> remainingDraftItems = draftBox.values
          .where((item) => item.customerId != customerId)
          .toList();
      await cartBox.clear();
      await draftBox.clear();
      await cartBox.addAll(remainingCartItems);
      await draftBox.addAll(remainingDraftItems);
      getCartItems(customerId);
    } catch (e) {
      //
    }
  }

  Future<void> clearCartBoxForCustomer({required String customerId}) async {
    try {
      List<CartItem> remainingCartItems = cartBox.values
          .where((item) => item.customerId != customerId)
          .toList();
      await cartBox.clear();
      await cartBox.addAll(remainingCartItems);
    } catch (e) {
      //
    }
  }

  Future<void> clearDraftBoxForCustomer({required String customerId}) async {
    try {
      List<CartItem> remainingCartItems = draftBox.values
          .where((item) => item.customerId != customerId)
          .toList();
      await draftBox.clear();
      await draftBox.addAll(remainingCartItems);
    } catch (e) {
      //
    }
  }

  Future<void> clearCartOnlyForCustomer(String customerId) async {
    try {
      final keysToRemoveCart = cartBox.keys.where((key) {
        final item = cartBox.get(key);
        return item != null && item.customerId == customerId;
      }).toList();
      for (var key in keysToRemoveCart) {
        await cartBox.delete(key);
      }
    } catch (e) {
      //
    }
  }

  Future<void> clearCompleteCart() async {
    await cartBox.clear();
    await draftBox.clear();
  }

  Future<void> clearAllItemsForCustomer(String customerId) async {
    try {
      final keysToRemoveCart = cartBox.keys.where((key) {
        final item = cartBox.get(key);
        return item != null && item.customerId == customerId;
      }).toList();
      for (var key in keysToRemoveCart) {
        await cartBox.delete(key);
      }
      final keysToRemoveDraft = draftBox.keys.where((key) {
        final item = draftBox.get(key);
        return item != null && item.customerId == customerId;
      }).toList();
      for (var key in keysToRemoveDraft) {
        await draftBox.delete(key);
      }
    } catch (e) {
      //
    }
  }

  Future<void> handleCartPersistenceOnRestart(
      String? selectedCustomerId) async {
    try {
      final cartItems = this.cartItems;
      if (cartItems.isNotEmpty) {
        if (selectedCustomerId != null && selectedCustomerId.isNotEmpty) {
          await moveCartItemsToDraft(selectedCustomerId);
        } else {
          await clearCompleteCart();
        }
      }
    } catch (e) {
      //
    }
  }

  Future<void> saveDraftOffline({
    required String customerId,
    required String salesmanId,
    required double totalAmount,
    required List<Detail> details,
    required String customerName,
    required String customerMobile,
    required String customerEmail,
    required String customerImageUrl,
    required double allItemsTotal,
  }) async {
    try {
      var offlineDraftsBox = await Hive.openBox('offlineDrafts');
      List<dynamic> drafts =
          offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;
      int existingDraftIndex =
          drafts.indexWhere((draft) => draft['customer_id'] == customerId);

      if (existingDraftIndex != -1) {
        var existingDraft = drafts[existingDraftIndex];
        drafts[existingDraftIndex]['displayData'] = {
          'customerId': customerId,
          'customerName': customerName,
          'mobileNo': customerMobile,
          'email': customerEmail,
          'imageUrl': customerImageUrl,
          'displayTotal': allItemsTotal,
          'createdDate': DateTime.now().toIso8601String(),
        };
        List<dynamic> existingDetails = existingDraft['details'];
        for (var detail in details) {
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
            'stock': detail.stock ?? 0,
            'unitType': detail.unitType,
            'product_name': detail.productName ?? '',
            'tax': detail.tax ?? 0.0,
            'pieces': detail.pieces ?? 0.0,
            'incl_tax': detail.inclTax ?? '',
          });
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
              'unitType': e.unitType,
              'stock': e.stock,
              'product_name': e.productName ?? '',
              'tax': e.tax ?? 0.0,
              'pieces': e.pieces ?? 0.0,
              'incl_tax': e.inclTax ?? '',
            };
          }).toList(),
          'displayData': {
            'customerId': customerId,
            'customerName': customerName,
            'mobileNo': customerMobile,
            'email': customerEmail,
            'imageUrl': customerImageUrl,
            'displayTotal': allItemsTotal,
            'createdDate': DateTime.now().toIso8601String(),
          },
        };
        drafts.add(newDraft);
      }

      await offlineDraftsBox.put('drafts', drafts);
    } catch (e) {
      //
    }
  }
}
