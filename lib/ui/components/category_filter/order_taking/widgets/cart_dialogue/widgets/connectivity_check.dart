//Connectivity Plus

import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isSyncing = false; 
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;
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

  void startListening(void Function(List<ConnectivityResult>) onConnectivityChanged) {
    _connectivity.onConnectivityChanged.listen((connectivityResults) {
      onConnectivityChanged(connectivityResults);
    });
  }

  void stopListening() {
    _connectivity.onConnectivityChanged.drain();
  }

Future<void> syncOfflineOrders() async {
  if (_isSyncing) {
    log('[syncOfflineOrders] Sync is already in progress.');
    return;
  }
  _isSyncing = true;
  Set<String> processedCartIds = {}; // Track processed cart IDs
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
          continue; // Skip already processed cart
        }

        log('[syncOfflineOrders] Processing offline order: $order');
        final AddToCartModel productBYData = AddToCartModel(
          customerId: order['customer_id'] ?? '',
          salesmanId: order['salesman_id'] ?? '',
          cartId: '',
          cartList: (order['cart_list'] as List).map((e) {
            return SendCartData(
              productId: e['product_id'] ?? '',
              variantId: e['variant_id'] ?? '',
              pack: e['pack']?.toString() ?? '0',
              price: e['price']?.toString() ?? '0.0',
              packType: e['packType'] ?? 'Pack',
              discount: e['discount'],
              quantity: e['quantity'] ?? 0,
              variantName: e['variant_name'] ?? '',
            );
          }).toList(),
          total: order['order_price']?.toString() ?? '0.0',
          discount: '0',
        );

        log('[syncOfflineOrders] Sending API request with payload: ${productBYData.toJson()}');
        final CartOrderModel? cartOrder =
            await ApiWorker().addToCart(productBYData.toJson());

        if (cartOrder != null) {
          processedCartIds.add(cartOrder.cartId); // Mark cart ID as processed
          log('[syncOfflineOrders] Order added to cart successfully: ${cartOrder.cartId}');
          final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
          final int orderStatus = 11;

          final CartOrderModel orderPayload = CartOrderModel(
            customerId: order['customer_id'] ?? '',
            salesmanId: order['salesman_id'] ?? '',
            cartId: cartOrder.cartId,
            orderStatus: orderStatus,
            orderPrice: order['order_price'] ?? 0.0,
            paymentType: order['paymentType']?.toString() ?? 'Cash',
            companyId: companyId,
            paymentDetail: order['paymentDetail'] ?? '',
            transactionNumber: order['transactionNumber'] ?? '',
            transactionDate: order['transactionDate'] ?? '',
          );
          log('[syncOfflineOrders] Sending Place Order payload: ${orderPayload.toJson()}');
          await placeOrder(orderPayload,
              (statusCode, message, response) async {
            if (statusCode == 200) {
              log('[syncOfflineOrders] Order synced successfully: ${orderPayload.cartId}');
              await offlineOrdersBox.delete(order['order_id']);
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
Future<void> syncOfflineDrafts() async {
  if (_isSyncing) {
    log('[syncOfflineDrafts] Sync is already in progress.');
    return;
  }
  _isSyncing = true;
  Set<String> processedDraftIds = {};
  try {
    var offlineDraftsBox = await Hive.openBox('offlineDrafts');
    if (offlineDraftsBox.isEmpty) {
      log('[syncOfflineDrafts] No offline drafts to sync.');
      return;
    }
    var drafts = offlineDraftsBox.values.toList();
    for (var draft in drafts) {
      try {
        if (processedDraftIds.contains(draft['draft_id'])) {
          log('[syncOfflineDrafts] Skipping already processed draft ID: ${draft['draft_id']}');
          continue; 
        }
        log('[syncOfflineDrafts] Processing offline draft: $draft');
        final AddToCartModel draftData = AddToCartModel(
          customerId: draft['customer_id'] ?? '',
          salesmanId: draft['salesman_id'] ?? '',
          cartId: draft['cart_id'] ?? '',
          cartList: (draft['details'] as List).map((e) {
            return SendCartData(
              productId: e['product_id'] ?? '',
              variantId: e['variant_id'] ?? '',
              pack: e['pack']?.toString() ?? '0',
              price: e['price']?.toString() ?? '0.0',
              packType: e['packType'] ?? 'Pack',
              discount: e['discount'],
              quantity: e['quantity'] ?? 0,
              variantName: e['variant_name'] ?? '',
            );
          }).toList(),
          total: draft['total_amount']?.toString() ?? '0.0',
          discount: '0',
        );

        log('[syncOfflineDrafts] Sending API request to save draft with payload: ${draftData.toJson()}');
        final CartOrderModel? savedDraft =
            await ApiWorker().addToDraft(draftData.toJson());

        if (savedDraft != null) {
          processedDraftIds.add(savedDraft.draftId??''); 
          log('[syncOfflineDrafts] Draft synced successfully: ${savedDraft.draftId}');
          await offlineDraftsBox.delete(draft['order_id']); 
        } else {
          log('[syncOfflineDrafts] Failed to sync draft.');
        }
      } catch (e) {
        log('[syncOfflineDrafts] Error syncing draft: $e');
      }
    }

    if (offlineDraftsBox.isEmpty) {
      log('[syncOfflineDrafts] All offline drafts have been synced and the box is now empty.');
    }
  } catch (e) {
    log('[syncOfflineDrafts] General error: $e');
  } finally {
    _isSyncing = false;
  }
}



}
