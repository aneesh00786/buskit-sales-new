//Connectivity Plus

import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:intl/intl.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' as getx;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isSyncing = false;
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;
  Future<bool> isConnected() async {
    var result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isOnline() async {
    bool hasNetwork = await isConnected();
    if (!hasNetwork) {
      return false;
    }

    bool hasInternetAccess = await hasInternet();
    return hasInternetAccess;
  }

  Future<bool> isConnectedToNetwork() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void startListening(
      void Function(List<ConnectivityResult>) onConnectivityChanged) {
    _connectivity.onConnectivityChanged.listen((connectivityResults) {
      onConnectivityChanged(connectivityResults);
    });
  }

  void stopListening() {
    _connectivity.onConnectivityChanged.drain();
  }

  // Future<void> syncOfflineOrders({VoidCallback? onOrderSynced}) async {
  //   if (_isSyncing) {
  //     log('[syncOfflineOrders] Sync is already in progress.');
  //     return;
  //   }
  //   _isSyncing = true;
  //   Set<String> processedCartIds = {};
  //   try {
  //     var offlineOrdersBox = await Hive.openBox('offlineOrders');
  //     if (offlineOrdersBox.isEmpty) {
  //       log('[syncOfflineOrders] No offline orders to sync.');
  //       return;
  //     }
  //     var orders = offlineOrdersBox.values.toList();
  //     for (var order in orders) {
  //       try {
  //         if (processedCartIds.contains(order['cart_id'])) {
  //           log('[syncOfflineOrders] Skipping already processed cart ID: ${order['cart_id']}');
  //           continue;
  //         }
  //         log('[syncOfflineOrders] Processing offline order: $order');
  //         final String customerId = order['customer_id'] ?? '';
  //         var draftDetails =
  //             await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
  //         final firstDraft =
  //             draftDetails.isNotEmpty ? draftDetails.last : {'draft_id': ''};
  //         final String existingDraftId = firstDraft['draft_id'] ?? '';
  //         log('Associated Cart ID for Customer $customerId: $existingDraftId');
  //         final AddToCartModel productBYData = AddToCartModel(
  //           customerId: customerId,
  //           salesmanId: order['salesman_id'] ?? '',
  //           cartId: '',
  //           cartList: (order['cart_list'] as List).map((e) {
  //             return SendCartData(
  //               productId: e['product_id'] ?? '',
  //               variantId: e['variant_id'] ?? '',
  //               pack: e['pack']?.toString() ?? '0',
  //               price: e['price']?.toString() ?? '0.0',
  //               packType: e['packType'] ?? 'Pack',
  //               discount: num.tryParse(e['discount']?.toString() ?? '0') ?? 0,
  //               quantity: e['quantity'] ?? 0,
  //               variantName: e['variant_name'] ?? '',
  //             );
  //           }).toList(),
  //           total: order['order_price']?.toString() ?? '0.0',
  //         );
  //         log('[syncOfflineOrders] Sending API request with payload: ${productBYData.toJson()}');
  //         final CartOrderModel? cartOrder =
  //             await ApiWorker().addToCart(productBYData.toJson());
  //         if (cartOrder != null) {
  //           processedCartIds.add(cartOrder.cartId);
  //           log('[syncOfflineOrders] Order added to cart successfully: ${cartOrder.cartId}');
  //           final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  //           const int orderStatus = 11;
  //           final CartOrderModel orderPayload = CartOrderModel(
  //             customerId: customerId,
  //             salesmanId: order['salesman_id'] ?? '',
  //             cartId: cartOrder.cartId,
  //             draftId: existingDraftId,
  //             orderStatus: orderStatus,
  //             orderPrice: order['order_price'] ?? 0.0,
  //             paymentType: order['paymentType']?.toString() ?? 'Cash',
  //             companyId: companyId,
  //             paymentDetail: order['paymentDetail'] ?? '',
  //             transactionNumber: order['transactionNumber'] ?? '',
  //             transactionDate: order['transactionDate'] ?? '',
  //           );
  //           log('[syncOfflineOrders] Sending Place Order payload: ${orderPayload.toJson()}');
  //           await ApiWorker().placeOrder(orderPayload,
  //               (statusCode, message, response) async {
  //             if (statusCode == 200) {
  //               showSyncSnackbar(
  //                   "Your order has been successfully placed", "Placed Order");
  //               log('[syncOfflineOrders] Order synced successfully: ${orderPayload.cartId}');
  //               await offlineOrdersBox.delete(order['order_id']);
  //               // Update offline order count and list in controller after each deletion
  //               try {
  //                 final orderController =
  //                     getx.Get.isRegistered<OrderController>()
  //                         ? getx.Get.find<OrderController>()
  //                         : null;
  //                 if (orderController != null) {
  //                   await orderController.loadOfflineOrders();
  //                 }
  //               } catch (e) {
  //                 log('OrderController not found or error updating offline orders: $e');
  //               }
  //               onOrderSynced?.call();
  //             } else {
  //               log('[syncOfflineOrders] Failed to sync order: $message');
  //             }
  //           });
  //         }
  //       } catch (e) {
  //         log('[syncOfflineOrders] Error syncing order: $e');
  //       }
  //     }
  //     if (offlineOrdersBox.isEmpty) {
  //       log('[syncOfflineOrders] All offline orders have been synced and the box is now empty.');
  //     }
  //   } catch (e) {
  //     log('[syncOfflineOrders] General error: $e');
  //   } finally {
  //     _isSyncing = false;
  //   }
  // }

  Future<void> syncOfflineOrders({VoidCallback? onOrderSynced}) async {
    if (_isSyncing) {
      log('[syncOfflineOrders] Sync is already in progress.');
      return;
    }
    _isSyncing = true;
    Set<String> processedCartIds = {};
    try {
      var offlineOrdersBox = await Hive.openBox('offlineOrders');
      if (offlineOrdersBox.isEmpty) {
        log('[syncOfflineOrders] No offline orders to sync.');
        return;
      }
      var orders = offlineOrdersBox.values.toList();
      for (var order in orders) {
        try {
          if (processedCartIds.contains(order['cart_id'])) {
            log('[syncOfflineOrders] Skipping already processed cart ID: ${order['cart_id']}');
            continue;
          }
          log('[syncOfflineOrders] Processing offline order: $order');
          final String customerId = order['customer_id'] ?? '';
          var draftDetails =
              await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
          final firstDraft =
              draftDetails.isNotEmpty ? draftDetails.last : {'draft_id': ''};
          final String existingDraftId = firstDraft['draft_id'] ?? '';
          log('Associated Cart ID for Customer $customerId: $existingDraftId');

          final AddToCartModel productBYData = AddToCartModel(
            customerId: customerId,
            salesmanId: order['salesman_id'] ?? '',
            cartId: '',
            cartList: (order['cart_list'] as List).map((e) {
              return SendCartData(
                productId: e['product_id'] ?? '',
                variantId: e['variant_id'] ?? '',
                pack: e['pack']?.toString() ?? '0',
                price: e['price']?.toString() ?? '0.0',
                packType: e['packType'] ?? 'Pack',
                discount: num.tryParse(e['discount']?.toString() ?? '0') ?? 0,
                quantity: e['quantity'] ?? 0,
                variantName: e['variant_name'] ?? '',
              );
            }).toList(),
            total: order['order_price']?.toString() ?? '0.0',
          );

          List<String> varientIdsPass = [];
          for (var item in order['cart_list']) {
            varientIdsPass.add(item['variant_id'] ?? '');
          }

          log("VARIENT IDS : $varientIdsPass");

          log('[syncOfflineOrders] Sending API request with payload: ${productBYData.toJson()}');
          final CartOrderModel? cartOrder =
              await ApiWorker().addToCart(productBYData.toJson());
          if (cartOrder != null) {
            processedCartIds.add(cartOrder.cartId);
            log('[syncOfflineOrders] Order added to cart successfully: ${cartOrder.cartId}');
            final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
            // const int orderStatus = 11;
            final CartOrderModel orderPayload = CartOrderModel(
              customerId: customerId,
              salesmanId: order['salesman_id'] ?? '',
              cartId: cartOrder.cartId,
              draftId: existingDraftId,
              orderStatus: order['order_status'],
              orderPrice: order['order_price'] ?? 0.0,
              paymentType: order['paymentType']?.toString() ?? 'Cash',
              companyId: companyId,
              paymentDetail: order['paymentDetail'] ?? '',
              transactionNumber: order['transactionNumber'] ?? '',
              transactionDate: order['transactionDate'] ?? '',
              varientIds: varientIdsPass,
            );

            log('[syncOfflineOrders] Sending Place Order payload: ${orderPayload.toJson()}');
            await ApiWorker().placeOrder(orderPayload,
                (statusCode, message, response) async {
              if (statusCode == 200) {
                showSyncSnackbar(
                    "Your order has been successfully placed", "Placed Order");
                log('[syncOfflineOrders] Order synced successfully: ${orderPayload.cartId}');

                // Update cached drafts after successful sync
                try {
                  final apiService = ApiService();
                  final customerId = order['customer_id'] ?? '';
                  final salesmanId =
                      SessionHelper.loginSavedData?.salesmanId ?? '';

                  final now = DateTime.now();
                  final startDate = DateTime(now.year, 1, 1);
                  final endDate = DateTime(now.year, 12 + 1, 0);

                  final formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                  final formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);

                  // Determine order type based on order status
                  String orderType;
                  switch (orderPayload.orderStatus) {
                    case 11:
                      orderType = 'sale_order';
                      break;
                    case 0:
                      orderType = 'booking';
                      break;
                    case 7:
                      orderType = 'estimate';
                      break;
                    case 14:
                      orderType = 'quick_sale';
                      break;
                    default:
                      orderType = 'draft';
                  }

                  await apiService.updateCachedDraftsAfterSaveAndSend(
                    null,
                    customerId: customerId,
                    draftId: existingDraftId,
                    salesmanId: salesmanId,
                    startDate: formattedStartDate,
                    endDate: formattedEndDate,
                    orderType: orderType,
                    sentCartIds: [
                      orderPayload.cartId
                    ],
                    sentAmount: orderPayload.orderPrice ?? 0.0,
                  );

                  log('[syncOfflineOrders] Successfully updated cached drafts after order sync');
                } catch (e) {
                  log('[syncOfflineOrders] Error updating cached drafts: $e');
                  // Don't show error to user as this is a background operation
                }

                await offlineOrdersBox.delete(order['order_id']);
                // Update offline order count and list in controller after each deletion
                try {
                  final orderController =
                      getx.Get.isRegistered<OrderController>()
                          ? getx.Get.find<OrderController>()
                          : null;
                  if (orderController != null) {
                    await orderController.loadOfflineOrders();
                  }
                } catch (e) {
                  log('OrderController not found or error updating offline orders: $e');
                }
                onOrderSynced?.call();
              } else {
                log('[syncOfflineOrders] Failed to sync order: $message');
              }
            });
          }
        } catch (e) {
          log('[syncOfflineOrders] Error syncing order: $e');
        }
      }

      if (offlineOrdersBox.isEmpty) {
        log('[syncOfflineOrders] All offline orders have been synced and the box is now empty.');
      }
    } catch (e) {
      log('[syncOfflineOrders] General error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncOfflineDrafts({VoidCallback? onDraftsSynced}) async {
    int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    if (companyId != 0) {
      if (_isSyncing) {
        log('[syncOfflineDrafts] Sync is already in progress.');
        return;
      }
      _isSyncing = true;

      try {
        var offlineDraftsBox = await Hive.openBox('offlineDrafts');
        List<dynamic> drafts =
            offlineDraftsBox.get('drafts', defaultValue: []) as List<dynamic>;

        if (drafts.isEmpty) {
          log('[syncOfflineDrafts] No offline drafts to sync.');
          return;
        }
        for (var draft in drafts) {
          try {
            log('[syncOfflineDrafts] Processing offline draft: $draft');
            final customerId = draft['customer_id'] ?? '';
            final cartDetails = await CartDatabaseManager()
                .getDraftAndCartIdsFromApi(customerId);
            await Future.delayed(const Duration(seconds: 1));
            final firstOrder = cartDetails.isNotEmpty
                ? cartDetails.last
                : {'cart_id': '', 'draft_id': ''};
            final existingCartId = firstOrder['cart_id'] ?? '';
            final existingDraftId = firstOrder['draft_id'] ?? '';
            log('Existing cart ID $existingCartId');
            log('Existing Draft ID $existingDraftId');

            final customerDraftItems = CartDatabaseManager()
                .draftBox
                .values
                .where((item) => item.customerId == customerId)
                .toList();

            log("[customerDraftItems] : ${customerDraftItems.map((e) => e.toJson()).toList()}");
            final draftConvertedList = customerDraftItems.map((item) {
              final detail = item.detail;

              return SendCartData(
                productId: detail.productId ?? '',
                variantId: detail.variationId ?? '',
                pack: detail.saleBy == 'Pack'
                    ? detail.pieces?.toString() ?? '0'
                    : detail.count?.toString() ?? '0',
                price: detail.sellPrice?.toString() ?? '0.0',
                packType: detail.saleBy ?? 'Pack',
                discount: detail.discount ?? 0,
                quantity: detail.count?.toInt() ?? 0,
                variantName: detail.variationName ?? '',
              );
            }).toList();

            final preCartList = (draft['details'] as List?)?.map((e) {
                  return SendCartData(
                    productId: e['product_id'] ?? '',
                    variantId: e['variant_id'] ?? '',
                    pack: e['pack']?.toString() ?? '0',
                    price: e['price']?.toString() ?? '0.0',
                    packType: e['packType'] ?? 'Pack',
                    discount:
                        num.tryParse(e['discount']?.toString() ?? '0') ?? 0,
                    quantity: e['quantity'] ?? 0,
                    variantName: e['variant_name'] ?? '',
                  );
                }).toList() ??
                [];

            log('[syncOfflineDrafts] preCartList (${preCartList.length} items):');
            for (var item in preCartList) {
              log('[preCartList] ${item.toJson()}');
            }

            log('[syncOfflineDrafts] draftConvertedList (${draftConvertedList.length} items):');
            for (var item in draftConvertedList) {
              log('[draftConvertedList] ${item.toJson()}');
            }

            final Map<String, SendCartData> itemMap = {};

            for (var item in draftConvertedList) {
              final key = item.variantId;
              itemMap[key] = item;
            }

            preCartList.forEach((item) {
              final key = item.variantId;
              if (!itemMap.containsKey(key)) {
                itemMap[key] = item;
              }
            });

            final combinedCartList = itemMap.values.toList();

            List<String> varientIdsPass = [];
            for (var item in combinedCartList) {
              varientIdsPass.add(item.variantId);
            }

            log("VARIENT IDS : $varientIdsPass");

            log('[syncOfflineDrafts] combinedCartList (${combinedCartList.length} items):');
            for (var item in combinedCartList) {
              log('[combinedCartList] ${item.toJson()}');
            }

            final AddToCartModel draftData = AddToCartModel(
              customerId: draft['customer_id'] ?? '',
              salesmanId: draft['salesman_id'] ?? '',
              cartId: existingCartId.isNotEmpty ? existingCartId : '',
              cartList: combinedCartList,
              total: draft['total_amount']?.toString() ?? '0.0',
            );
            log('[syncOfflineDrafts] Sending API request to save draft with payload: ${draftData.toJson()}');
            final CartOrderModel? savedDraft =
                await ApiWorker().addToDraft(draftData.toJson());
            if (savedDraft != null) {
              log('[syncOfflineDrafts] Draft synced successfully: ${savedDraft.draftId}');
              final int companyId =
                  SessionHelper.loginSavedData?.company_id ?? 0;
              const int orderStatus = 4;
              final CartOrderModel orderPayload = CartOrderModel(
                customerId: draft['customer_id'] ?? '',
                salesmanId: draft['salesman_id'] ?? '',
                cartId: existingCartId.isNotEmpty
                    ? existingCartId
                    : savedDraft.cartId,
                draftId: existingDraftId.isNotEmpty
                    ? existingDraftId
                    : savedDraft.draftId,
                orderStatus: orderStatus,
                orderPrice: draft['total_amount'] ?? 0.0,
                paymentType: draft['paymentType']?.toString() ?? 'Cash',
                companyId: companyId,
                paymentDetail: draft['paymentDetail'] ?? '',
                transactionNumber: draft['transactionNumber'] ?? '',
                transactionDate: draft['transactionDate'] ?? '',
                varientIds: varientIdsPass,
              );
              log('[syncOfflineDrafts] Sending Place Order payload: ${orderPayload.toJson()}');

              {
                final customerCartItems = CartDatabaseManager()
                    .cartBox
                    .values
                    .where((item) => item.customerId == customerId)
                    .toList();
                final customerDraftItems = CartDatabaseManager()
                    .draftBox
                    .values
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

                final combinedItems = itemMap.values.toList();

                log('[CartDB] getCartItems returning customerCartItems : ${customerCartItems.map((e) => e.toJson()).toList()}');
                log('[CartDB] getCartItems returning customerDraftItems : ${customerDraftItems.map((e) => e.toJson()).toList()}');
                log('[CartDB] getCartItems returning ${combinedItems.length} combined items');
              }

              await ApiWorker().placeOrder(orderPayload,
                  (statusCode, message, response) async {
                if (statusCode == 200) {
                  showSyncSnackbar(
                      "Your order has been successfully saved as Draft",
                      "Saved Draft");
                  log('[syncOfflineDrafts] Order placed successfully: ${orderPayload.cartId}');

                  final cartBox = CartDatabaseManager().cartBox;

                  // Find all keys where the CartItem's customerId matches
                  final keysToDelete = cartBox.keys.where((key) {
                    final item = cartBox.get(key);
                    return item?.customerId == customerId;
                  }).toList();

                  if (keysToDelete.isNotEmpty) {
                    await cartBox.deleteAll(keysToDelete);
                    log('[syncOfflineDrafts] Deleted ${keysToDelete.length} cartBox item(s) for customerId $customerId');
                  } else {
                    log('[syncOfflineDrafts] No cartBox items found for customerId $customerId');
                  }

                  final draftBox = CartDatabaseManager().draftBox;

                  // Find all keys where the CartItem's customerId matches
                  final draftKeysToDelete = draftBox.keys.where((key) {
                    final item = draftBox.get(key);
                    return item?.customerId == customerId;
                  }).toList();

                  if (draftKeysToDelete.isNotEmpty) {
                    await draftBox.deleteAll(draftKeysToDelete);
                    log('[syncOfflineDrafts] Deleted ${draftKeysToDelete.length} draftBox item(s) for customerId $customerId');
                  } else {
                    log('[syncOfflineDrafts] No draftBox items found for customerId $customerId');
                  }
                }
              });
              drafts.remove(draft);
              await offlineDraftsBox.put('drafts', drafts);
            } else {
              log('[syncOfflineDrafts] Failed to sync draft.');
            }
          } catch (e) {
            log('[syncOfflineDrafts] Error syncing draft: $e');
          }
        }

        if (drafts.isEmpty) {
          log('[syncOfflineDrafts] All offline drafts have been synced and the list is now empty.');
        }
      } catch (e) {
        log('[syncOfflineDrafts] General error: $e');
      } finally {
        _isSyncing = false;
      }
    }
  }

  Future<void> retryOfflineRequests() async {
    dio.Dio dio1 = dio.Dio();
    var box = await Hive.openBox('offlineRequests');
    if (box.isEmpty) {
      log("No offline requests to retry.");
      return;
    }
    log("Retrying ${box.length} offline requests...");
    for (int i = 0; i < box.length; i++) {
      final request = box.getAt(i);
      if (request == null) continue;
      try {
        final payload = castToStringDynamic(request['payload']);
        final response = await dio1.post(
          request['url'],
          data: dio.FormData.fromMap(payload),
        );
        if (response.statusCode == 200) {
          log("✅ Offline request sent successfully: ${request['url']}");
          await box.deleteAt(i);
        } else {
          log("❌ Failed to retry request: ${response.statusCode}");
        }
      } catch (e) {
        log("❌ Error retrying request: $e");
      }
    }
  }

  Map<String, dynamic> castToStringDynamic(Map<dynamic, dynamic> input) {
    return input.map((key, value) {
      final newKey = key is String ? key : key.toString();
      final newValue = value is Map
          ? castToStringDynamic(Map<dynamic, dynamic>.from(value))
          : (value is List
              ? value
                  .map((e) => e is Map
                      ? castToStringDynamic(Map<dynamic, dynamic>.from(e))
                      : e)
                  .toList()
              : value);
      return MapEntry(newKey, newValue);
    });
  }
}

void showSyncSnackbar(String message, String title) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 5),
  );
}
