//Cart Database

// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/widgets/variant_dialogue.dart';
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
    print('getdraft function called');
    final dio = Dio();
    const apiUrl = '${ApiConstants.baseUrl}fetch_all_order';
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final companyId = SessionHelper.loginSavedData?.company_id ?? '';
    const salesmanId = '';
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
        print('isonline in draft function');
        final response = await dio.post(apiUrl, data: requestBody);
        if (response.statusCode == 200) {
          final responseData = response.data;
          if (responseData['status'] == true) {
            final List<dynamic> orders = responseData['data'] ?? [];
            // await draftBox.clear();
            log('response from fetch all orders:$orders');
            await draftBox.clear();
            // final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId;
            for (var order in orders) {
              // Only process drafts for the current salesman
              // if (order['salesman_id'] != currentSalesmanId) continue;
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
                final String promoType = cart['promo_type'] as String? ?? '';
                final double parsedPromoDiscount =
                    (num.tryParse(cart['promo_discount']?.toString() ?? '0') ??
                            0)
                        .toDouble();
                final String packTypeStr = (cart['packtype'] ?? cart['packType'] ?? cart['pack_type'] ?? '') as String;
                final detail = Detail(
                  productId: cart['product_id'] as String? ?? '',
                  variationId: cart['variation_id'] as String? ?? '',
                  price: cart['price']?.toString() ?? '0',
                  tax: num.tryParse(cart['tax']?.toString() ?? '0') ?? 0,
                  packtype: packTypeStr,
                  pieces: num.tryParse(cart['pieces']?.toString() ?? '0') ?? 0,
                  count: num.tryParse(cart['quantity']?.toString() ?? '0') ?? 0,
                  // If it's a Bulk item, use unit_price. Otherwise, fall back to sell_price.
                  sellPrice: (packTypeStr == 'Bulk')
                      ? cart['unit_price']?.toString() ?? '0'
                      : cart['sell_price']?.toString() ?? '0',
                  // sellPrice: cart['sell_price']?.toString() ?? '0',
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
                  saleBy: packTypeStr,
                  unitTax:
                      num.tryParse(cart['unit_tax']?.toString() ?? '0') ?? 0,

                  discount:
                      num.tryParse(cart['discount_amount'].toString()) ?? 0,
                  productName: cart['product_name'] as String? ?? '',
                  initialCount:
                      num.tryParse(cart['quantity']?.toString() ?? '0') ?? 0,
                  // bulkDiscountAmount:   num.tryParse(cart['discount_amount'].toString()) ?? 0,

                  bulkDiscountAmount: (packTypeStr == 'Bulk')
                      ? (num.tryParse(
                              cart['discount_amount']?.toString() ?? '0') ??
                          0)
                      : 0,
                  bulkDiscount: (packTypeStr == 'Bulk')
                      ? (num.tryParse(cart['discount']?.toString() ?? '0') ?? 0)
                      : 0,
                  bulkTax: (packTypeStr == 'Bulk')
                      ? (num.tryParse(cart['tax']?.toString() ?? '0') ?? 0)
                      : 0,
                );
                final bool isBulkDraft = (packTypeStr == 'Bulk') ||
                    (cart['bulk_id'] != null &&
                        cart['bulk_id'].toString().isNotEmpty &&
                        cart['bulk_id'].toString() != 'null');
                final bool isPromoDraft =
                    (cart['is_promo'] == 1 || cart['is_promo'] == true || cart['is_promo'] == '1') &&
                        !isBulkDraft;

                final cartItem = CartItem(
                  detail: detail,
                  productName: cart['product_name'] as String? ?? '',
                  totalPrice:
                      // (num.tryParse(cart['total_amount']?.toString() ?? '0') ?? 0)
                      //         .toDouble(),
                      (discountedSellPrice *
                              (detail.packtype == 'Pack'
                                  ? (detail.pieces ?? 1) *
                                      (num.tryParse(
                                              cart['quantity'].toString()) ??
                                          0)
                                  : (num.tryParse(
                                          cart['quantity'].toString()) ??
                                      0))) +
                          (cart['incl_tax'] == "" || cart['incl_tax'] == null
                              ? totalTax
                              : 0),
                  customerId: order['customer_id'] as String? ?? '',
                  cartId: cart['cart_id'] as String? ?? '',
                  draftId: order['order_id'] as String? ?? '',
                  // Treat both 'Pack' and 'Bulk' as packed items
                  isPack: packTypeStr == "Pack" || packTypeStr == "Bulk",
                  catId: cart['catId'] as int? ?? 0,
                  salesmanId: order['salesman_id'] as String? ?? '',
                  isPromo: isPromoDraft,
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
                  CustomerDiscount: isBulkDraft
                      ? 0.0
                      : (num.tryParse(cart['discount']?.toString() ?? '0') ?? 0)
                          .toDouble(),
                  totalDiscountAmount: (num.tryParse(
                              cart['discount_amount']?.toString() ?? '0') ??
                          0)
                      .toDouble(),

                  // tieredDiscount: (num.tryParse(
                  //             cart['promo_discount']?.toString() ?? '0') ??
                  //         0)
                  //     .toDouble(),
                  taxAmount:
                      (num.tryParse(cart['total_tax']?.toString() ?? '') ??
                              num.tryParse(cart['tax']?.toString() ?? '') ??
                              0)
                          .toDouble(),
                  catTax: () {
                    double parsed =
                        (num.tryParse(cart['cat_tax']?.toString() ?? '') ?? 0)
                            .toDouble();
                    if (parsed == 0 && cart['product_id'] != null) {
                      parsed =
                          getStoredTaxFromCache(cart['product_id'].toString());
                    }
                    return parsed > 0 ? parsed : null;
                  }(),
                  tieredDiscount: isPromoDraft
                      ? (promoType == 'flat_discount' ? 0.0 : parsedPromoDiscount)
                      : 0.0,
                  flatDiscount: isPromoDraft
                      ? (promoType == 'flat_discount' ? parsedPromoDiscount : 0.0)
                      : 0.0,
                );
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'cartId', cart['cart_id'] as String? ?? '');
                await prefs.setString(
                    'draftId', order['order_id'] as String? ?? '');
                // log('Draft ID : ${cartItem.draftId}');
                // log('Cart Items JSON ${cartItem.toJson()}');
                await draftBox.add(cartItem);
                fetchedItems.add(cartItem);
              }
            }
            // Cache the result
            await draftItemsBox.put(
                cacheKey, fetchedItems.map((e) => e.toJson()).toList());
          } else {}
        } else {}
      } else {}
      // Only return drafts for the current salesman
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
  }  Future<List<CartItem>> getCartItems(String customerId,
      {bool draftsOnly = false}) async {
    try {
      print('get cart called');
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
          final String packTypeStr = (detail['packType'] ??
              detail['packtype'] ??
              detail['pack_type'] ??
              '') as String;
          double parsedCatTax =
              (num.tryParse(detail['cat_tax']?.toString() ?? '') ?? 0)
                  .toDouble();
          if (parsedCatTax == 0 && detail['product_id'] != null) {
            parsedCatTax =
                getStoredTaxFromCache(detail['product_id'].toString());
          }
          final double taxAmt = (num.tryParse(
                      detail['tax_amount']?.toString() ?? '') ??
                  num.tryParse(detail['total_tax']?.toString() ?? '') ??
                  num.tryParse(detail['tax']?.toString() ?? '') ??
                  0)
              .toDouble();
          final cartItem = CartItem(
            detail: Detail(
              productId: detail['product_id'],
              variationId: detail['variant_id'],
              sellPrice: detail['price'],
              discount: detail['discount'],
              count: (detail['quantity'] as num?)?.toDouble() ?? 0,
              pieces: int.tryParse(detail['pack']?.toString() ?? '0'),
              variationName: detail['variant_name'],
              saleBy: packTypeStr,
              stock: detail['stock'] ?? 0,
              unitType: detail['unitType'],
              packtype: packTypeStr,
              productName: detail['product_name'],
              tax: detail['tax'],
              inclTax: detail['incl_tax'],
              totaltax: taxAmt,
              unitTax:
                  (num.tryParse(detail['unit_tax']?.toString() ?? '0') ?? 0),
            ),
            productName: detail['product_name'],
            totalPrice:
                double.tryParse(detail['price']?.toString() ?? '0') ?? 0,
            isPack: packTypeStr == 'Pack' || packTypeStr == 'Bulk',
            customerId: customerId,
            salesmanId: salesmanId,
            catId: detail['cat_id'] as int? ?? 0,
            isPromo: draft['is_promo'] == 1 ? true : false,
            promoCode:
                draft['promo_code'] == null || draft['promo_code'] == ""
                    ? draft['promo_code']
                    : null,
            promoMsg: draft['title'] == null || draft['title'] == ""
                ? draft['title']
                : null,
            taxAmount: taxAmt,
            catTax: parsedCatTax > 0 ? parsedCatTax : null,
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
        final key =
            "${item.detail.variationId}_${item.isPromo ?? false}_${item.isPack ?? false}";
        itemMap[key] = item;
      }

      for (var item in customerDraftItems) {
        final key =
            "${item.detail.variationId}_${item.isPromo ?? false}_${item.isPack ?? false}";
        if (!itemMap.containsKey(key)) {
          itemMap[key] = item;
        }
      }

      for (var item in customerOfflineDraftItems) {
        final key =
            "${item.detail.variationId}_${item.isPromo ?? false}_${item.isPack ?? false}";
        if (!itemMap.containsKey(key)) {
          itemMap[key] = item;
        }
      }

      final combinedItems = itemMap.values.toList();
      return Future.value(combinedItems);
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

    final bool isBulk = (detail.bulkId != null && detail.bulkId!.isNotEmpty) ||
        (detail.packtype == 'Bulk');

    if (!isBulk && discountData != null && discountData.customerId == customerId) {
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
    double? catTax,
    String? bulkId, // <--- 1. Add this optional parameter
  }) async {
    print('add to cart called');
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
    print('discount percentage when add to cart:$discountPercentage');

    double discountedTax = (inclTax == "N.A" || detail.tax == null)
        ? 0.0
        : detail.tax! - (detail.tax! * discountPercentage / 100);

    // --- DRAFT BOX CHECK ---
    final existingDraftItemIndex = draftBox.values.toList().indexWhere((item) =>
        item.detail.variationName == detail.variationName &&
        item.detail.sellPrice == detail.sellPrice &&
        item.customerId == customerId &&
        item.isPack == isPack &&
        // Check if bulk IDs match (handle nulls safely)
        (item.detail.bulkId == bulkId) &&
        (item.isPromo == false || item.isPromo == null));

    if (existingDraftItemIndex != -1) {
      final existingDraftItem = draftBox.getAt(existingDraftItemIndex)!;

      // update existing draft item
      existingDraftItem.detail.count += localCount.toDouble();
      existingDraftItem.totalPrice = existingDraftItem.isPack!
          ? (existingDraftItem.detail.count *
                  (existingDraftItem.detail.pieces ?? 1) *
                  effectiveSellingPrice)
              .toDouble()
          : (existingDraftItem.detail.count * effectiveSellingPrice).toDouble();

      await draftBox.putAt(existingDraftItemIndex, existingDraftItem);
      print('update existing item');
    } else {
      // --- CART BOX CHECK ---
      final existingCartItemIndex = cartBox.values.toList().indexWhere(
            (item) =>
                // 2. Ensure we check bulkId to prevent merging Bulk items with Regular items
                (item.detail.bulkId == bulkId) &&
                isSameCartRow(
                  item,
                  detail: detail,
                  customerId: customerId,
                  isPromo: false,
                  isPack: isPack,
                ),
          );

      if (existingCartItemIndex != -1) {
        final existingCartItem = cartBox.getAt(existingCartItemIndex)!;

        // Update existing cart item
        existingCartItem.detail.count += localCount.toDouble();
        final double priceWithTax =
            (existingCartItem.detail.inclTax != "incl_tax" &&
                    existingCartItem.detail.inclTax != "N.A")
                ? effectiveSellingPrice + discountedTax
                : effectiveSellingPrice;

        existingCartItem.totalPrice = existingCartItem.isPack!
            ? (existingCartItem.detail.count *
                    (existingCartItem.detail.pieces ?? 1) *
                    priceWithTax)
                .toDouble()
            : (existingCartItem.detail.count * priceWithTax).toDouble();

        await cartBox.putAt(existingCartItemIndex, existingCartItem);
      } else {
        // --- NEW ITEM CREATION ---
        final double priceWithTax = (inclTax != "incl_tax" && inclTax != "N.A")
            ? effectiveSellingPrice + discountedTax
            : effectiveSellingPrice;

        final computedTotalAmount = isPack
            ? (localCount * (detail.pieces ?? 1) * priceWithTax)
            : (localCount * priceWithTax);

        // Clone the detail object
        final newDetail = Detail.fromJson(detail.toJson());
        newDetail.count = localCount.toDouble();
        newDetail.inclTax = inclTax;

        // 3. SET THE BULK ID HERE
        newDetail.bulkId = bulkId ?? detail.bulkId;

        if (newDetail.initialCount == null) {
          newDetail.initialCount = localCount.toDouble();
          print(
              'NEW ITEM: Set initialCount to $localCount for ${newDetail.productName}');
        }

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
            isPromo: false,
            CustomerDiscount: discountPercentage,
            catTax: catTax);

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
    double? CustomerDiscount,
    double? tieredDiscount,
    double? catTax,
    double? flatDiscount,
    double? bogoDiscount,
  }) async {
    if (localCount <= 0) {
      throw ArgumentError("[PROMO] Error: Count must be greater than zero.");
    }

    final discountBox = await Hive.openBox<CustomerDiscountModel>('discounts');
    CustomerDiscountModel? discountData = discountBox.values.firstWhere(
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

    double discountedTax = (inclTax == "N.A" || detail.tax == null)
        ? 0.0
        : detail.tax! - (detail.tax! * discountPercentage / 100);

    // Check for existing promo item in draftBox
    final existingDraftItemIndex = draftBox.values.toList().indexWhere((item) =>
        item.detail.variationName == detail.variationName &&
        item.detail.sellPrice == detail.sellPrice &&
        item.customerId == customerId &&
        item.isPack == isPack &&
        item.isPromo == true);

    if (existingDraftItemIndex != -1) {
      // UPDATE EXISTING DRAFT ITEM (promo)
      final existingDraftItem = draftBox.getAt(existingDraftItemIndex)!;
      existingDraftItem.detail.count += localCount.toDouble();

      existingDraftItem.totalPrice = existingDraftItem.isPack!
          ? (existingDraftItem.detail.count *
                  (existingDraftItem.detail.pieces ?? 1) *
                  effectiveSellingPrice)
              .toDouble()
          : (existingDraftItem.detail.count * effectiveSellingPrice).toDouble();

      await draftBox.putAt(existingDraftItemIndex, existingDraftItem);
      print(
          'Updated existing promo draft item - new count: ${existingDraftItem.detail.count}');
    } else {
      // Check for existing promo item in cartBox
      final existingCartItemIndex = cartBox.values.toList().indexWhere(
            (item) => isSameCartRow(
              item,
              detail: detail,
              customerId: customerId,
              isPromo: true,
              isPack: isPack,
              promoCode: promoCode,
            ),
          );

      if (existingCartItemIndex != -1) {
        // UPDATE EXISTING CART ITEM (promo)
        final existingCartItem = cartBox.getAt(existingCartItemIndex)!;
        existingCartItem.detail.count += localCount.toDouble();

        final double priceWithTax = (inclTax != "incl_tax" && inclTax != "N.A")
            ? effectiveSellingPrice + discountedTax
            : effectiveSellingPrice;

        existingCartItem.totalPrice = existingCartItem.isPack!
            ? (existingCartItem.detail.count *
                    (existingCartItem.detail.pieces ?? 1) *
                    priceWithTax)
                .toDouble()
            : (existingCartItem.detail.count * priceWithTax).toDouble();

        await cartBox.putAt(existingCartItemIndex, existingCartItem);
        print(
            'Updated existing promo cart item - new count: ${existingCartItem.detail.count}');
      } else {
        // NEW PROMO ITEM → Create fresh Detail and set initialCount
        final double priceWithTax = (inclTax != "incl_tax" && inclTax != "N.A")
            ? effectiveSellingPrice + discountedTax
            : effectiveSellingPrice;

        final computedTotalAmount = isPack
            ? (localCount * (detail.pieces ?? 1) * priceWithTax)
            : (localCount * priceWithTax);

        // Create new Detail instance
        final newDetail = Detail(
          variationId: detail.variationId,
          productId: detail.productId,
          variationName: detail.variationName,
          unitType: detail.unitType,
          price: detail.price,
          sellPrice: detail.sellPrice,
          tax: detail.tax,
          packtype: detail.packtype,
          pieces: detail.pieces,
          stock: detail.stock,
          lowstock: detail.lowstock,
          fullstock: detail.fullstock,
          imageUrl: detail.imageUrl,
          productName: detail.productName,
          discount: detail.discount,
          inclTax: detail.inclTax,
        );

        // Set current count
        newDetail.count = localCount.toDouble();
        newDetail.inclTax = inclTax;

        // SET initialCount ONLY ONCE (for new items)
        if (newDetail.initialCount == null) {
          newDetail.initialCount = localCount.toDouble();
          print(
              'NEW PROMO ITEM: Set initialCount = $localCount for ${newDetail.productName}');
        }

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
          CustomerDiscount: CustomerDiscount,
          tieredDiscount: tieredDiscount,
          catTax: catTax,
          flatDiscount: flatDiscount,
          bogoDiscount: bogoDiscount,
        );

        await cartBox.add(newCartItem);
        print(
            'New promo item added to cart - initialCount: ${newDetail.initialCount}, current count: ${newDetail.count}');
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

  Future<void> deleteCartItem(CartItem cartItem) async {
    try {
      final cartKeysToRemove = cartBox.keys.where((key) {
        final item = cartBox.get(key);
        return item != null &&
            (item.customerId == cartItem.customerId ||
                cartItem.customerId == null ||
                cartItem.customerId == '') &&
            (item.detail.variationId == cartItem.detail.variationId ||
                (item.productName == cartItem.productName &&
                    item.detail.variationName ==
                        cartItem.detail.variationName)) &&
            item.isPromo == cartItem.isPromo &&
            item.isPack == cartItem.isPack;
      }).toList();
      for (var key in cartKeysToRemove) {
        await cartBox.delete(key);
      }

      final draftKeysToRemove = draftBox.keys.where((key) {
        final item = draftBox.get(key);
        return item != null &&
            (item.customerId == cartItem.customerId ||
                cartItem.customerId == null ||
                cartItem.customerId == '') &&
            (item.detail.variationId == cartItem.detail.variationId ||
                (item.productName == cartItem.productName &&
                    item.detail.variationName ==
                        cartItem.detail.variationName)) &&
            item.isPromo == cartItem.isPromo &&
            item.isPack == cartItem.isPack;
      }).toList();
      for (var key in draftKeysToRemove) {
        await draftBox.delete(key);
      }

      // Also remove from offlineDrafts box
      if (Hive.isBoxOpen('offlineDrafts') ||
          (await Hive.openBox('offlineDrafts')).isOpen) {
        var offlineDraftsBox = await Hive.openBox('offlineDrafts');
        List<dynamic> drafts = List<dynamic>.from(
            offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>);
        int draftIndex =
            drafts.indexWhere((d) => d['customer_id'] == cartItem.customerId);
        if (draftIndex != -1) {
          Map<String, dynamic> draftMap =
              Map<String, dynamic>.from(drafts[draftIndex] as Map);
          List<dynamic> details = List<dynamic>.from(draftMap['details'] ?? []);
          details.removeWhere((detail) {
            final String packTypeStr = (detail['packType'] ??
                detail['packtype'] ??
                detail['pack_type'] ??
                '') as String;
            final bool isPack = packTypeStr == 'Pack' || packTypeStr == 'Bulk';
            return (detail['variant_id'] == cartItem.detail.variationId ||
                    detail['product_name'] == cartItem.productName) &&
                isPack == (cartItem.isPack ?? false);
          });
          if (details.isEmpty) {
            drafts.removeAt(draftIndex);
          } else {
            draftMap['details'] = details;
            drafts[draftIndex] = draftMap;
          }
          await offlineDraftsBox.put('drafts', drafts);
        }
      }
    } catch (e) {
      print('Error deleting cart item: $e');
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

      // Also remove from offlineDrafts box
      if (Hive.isBoxOpen('offlineDrafts') ||
          (await Hive.openBox('offlineDrafts')).isOpen) {
        var offlineDraftsBox = await Hive.openBox('offlineDrafts');
        List<dynamic> drafts = List<dynamic>.from(
            offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>);
        drafts.removeWhere((d) => d['customer_id'] == customerId);
        await offlineDraftsBox.put('drafts', drafts);
      }

      await getCartItems(customerId);
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
        drafts[existingDraftIndex]['total_amount'] = totalAmount;
        drafts[existingDraftIndex]['displayData'] = {
          'customerId': customerId,
          'customerName': customerName,
          'mobileNo': customerMobile,
          'email': customerEmail,
          'imageUrl': customerImageUrl,
          'displayTotal': allItemsTotal,
          'createdDate': DateTime.now().toIso8601String(),
        };
        drafts[existingDraftIndex]['details'] = details.map((detail) {
          return {
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
            'cat_tax': getStoredTaxFromCache(detail.productId ?? ''),
            'tax_amount': detail.tax ?? 0.0,
            'total_tax': detail.totaltax ?? 0.0,
            'unit_tax': detail.unitTax ?? 0.0,
            'cat_id': 0,
          };
        }).toList();
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
              'cat_tax': getStoredTaxFromCache(e.productId ?? ''),
              'tax_amount': e.tax ?? 0.0,
              'total_tax': e.totaltax ?? 0.0,
              'unit_tax': e.unitTax ?? 0.0,
              'cat_id': 0,
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

bool isSameCartRow(
  CartItem item, {
  required Detail detail,
  required String customerId,
  required bool isPromo,
  required bool isPack,
  String? promoCode,
}) {
  return item.detail.variationId == detail.variationId &&
      item.customerId == customerId &&
      item.isPromo == isPromo &&
      item.isPack == isPack &&
      item.promoCode ==
          promoCode; // Ensuring different promos don't merge either
}
