// ignore_for_file: unused_local_variable, avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/backup_data_fun.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/dialog/dialogs.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: implementation_imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'product_ui/product_responce/product_responce_temp.dart';
import 'package:provider/provider.dart';

class ProductsController extends GetxController {
  final ApiWorker _apiWorker = Get.put(ApiWorker());
  var optionName = ''.obs;
  TextEditingController searchCustomerController = TextEditingController();
  Rx<CategoryModel> categoryData = CategoryModel().obs;
  RxList<ProductList> productListBackup = <ProductList>[].obs;
  RxList<ProductList> productList = <ProductList>[].obs;
  Rx<ProductResponceTemp> productListTemp = ProductResponceTemp().obs;
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<CustomerAndOrderData> customerAndOrderData = CustomerAndOrderData().obs;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;
  RxList<SearchData> searchData = <SearchData>[].obs;
  RxList<String> productVariantColumnNames = [
    "Unit",
    "Pack",
    "Price",
    "Stock",
  ].obs;
  RxString selectedSubCategoryId = "".obs;
  RxString selectedCategoryId = "".obs;
  RxBool isReached = false.obs;
  RxInt selectedSubCategoryIndex = 0.obs;
  RxString selectedSubCategoryName = "".obs;
  RxInt selectedCategoryIndex = 0.obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxBool isLoading = false.obs;
  RxString selectedCustomerName = "".obs;
  RxString selectedCustomerImageUrl = "".obs;
  RxString selectedCustomerEmail = "".obs;
  RxString selectedCustomerMobileNo = "".obs;
  RxString selectedCustomerId = "".obs;
  var finalAmount = 0.0.obs;
  var showDialog = false.obs;
  void closeDialog() {
    showDialog.value = false;
  }

  List<CartItem> cartItems = [];
  List<CartItem> orderItems = [];
  List<CartItem> preorderItems = [];

  void clearCartItemsInController() {
    log("[clearCartItemsInController]");
    cartItems.clear();
    orderItems.clear();
    preorderItems.clear();
  }

  // Future<void> handleBackNavigation({
  //   required BuildContext context,
  //   required bool isDirectDialogue,
  //   required String customerId,
  //   required HomeController homeController,
  // }) async {
  //   final toDash = isDirectDialogue;

  //   log('🚗 handleBackNavigation START');
  //   log('→ Cart Items Count: ${CartDatabaseManager().cartItems.length}');
  //   log('→ Customer ID: $customerId');
  //   log('→ Navigation Target: ${toDash ? 'Dashboard' : 'Pop Back'}');

  //   if (CartDatabaseManager().cartItems.isNotEmpty && customerId.isNotEmpty) {
  //     log('🛒 Cart detected, initiating processing...');
  //     Get.dialog(const Center(child: CircularProgressIndicator()));

  //     final wasOnline = await processCartBeforeNavigation(
  //       context: context,
  //       customerId: customerId,
  //     );

  //     // if (Navigator.canPop(context)) Navigator.pop(context);

  //     if (toDash) {
  //       await Future.delayed(const Duration(milliseconds: 300));
  //       log('✅ Going back to Customer Dashboard after processing');

  //       if (wasOnline) {
  //         log('✅ Draft saved online');
  //         showSuccessFullDialog(
  //           context: context,
  //           imagePath: 'assets/images/Animation - 1726906882515.json',
  //           message: 'Your order has been successfully saved as Draft',
  //         );
  //       } else {
  //         log('📴 Offline mode triggered - draft saved offline');
  //         offlineDialog(context);
  //       }

  //       await Future.delayed(const Duration(milliseconds: 300));
  //       log('🔙 Popping back to Customer Dashboard');
  //       Navigator.pop(
  //           context); // Just go back one screen instead of jumping to dashboard
  //     } else {
  //       if (!wasOnline) {
  //         log('📴 Offline mode - returning without dashboard');
  //         offlineMode1(context);
  //       }
  //       log('🔙 Just popping back (not dashboard)');
  //       Navigator.pop(context);
  //     }
  //   } else if (toDash) {
  //     log('🧹 No cart items but going back to Customer Dashboard');
  //     log('→ Clearing cart for customerId: $customerId');
  //     CartDatabaseManager().cartItems.clear();
  //     CartDatabaseManager().clearCart(customerId: customerId);
  //     Navigator.pop(context); // Same here — pop back
  //   } else {
  //     log('🔙 No cart items, just popping back');
  //     CartDatabaseManager().cartItems.clear();
  //     log('🧹 Cleared in-memory cart');
  //     Navigator.pop(context);
  //   }

  //   log('🚗 handleBackNavigation END');
  // }

  // Future<bool> processCartBeforeNavigation({
  //   required BuildContext context,
  //   required String customerId,
  // }) async {
  //   log('🛠️ processCartBeforeNavigation START for customerId: $customerId');

  //   final connectivityService = ConnectivityService();
  //   final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  //   log('→ Salesman ID: $currentSalesmanId');

  //   final draftItems = CartDatabaseManager()
  //       .draftBox
  //       .values
  //       .where((e) => e.customerId == customerId)
  //       .toList();
  //   final cartItems = CartDatabaseManager()
  //       .cartItems
  //       .where((e) =>
  //           e.customerId == customerId && e.salesmanId == currentSalesmanId)
  //       .toList();

  //   final allItems = [...cartItems, ...draftItems];
  //   log('🧾 Total items to process: ${allItems.length}');

  //   final Map<String, Detail> dedupedDetails = {};
  //   for (final item in allItems) {
  //     final key = item.detail.variationId ?? '';
  //     if (dedupedDetails.containsKey(key)) {
  //       dedupedDetails[key]!.count += item.detail.count;
  //     } else {
  //       dedupedDetails[key] = item.detail;
  //     }
  //   }

  //   final detail = dedupedDetails.values.toList();
  //   log('✅ Deduplicated item count: ${detail.length}');

  //   final isOnline = await connectivityService.isOnline();
  //   log('🌐 Connectivity: ${isOnline ? "Online" : "Offline"}');

  //   if (!isOnline) {
  //     log('💾 Saving as offline draft...');
  //     await CartDatabaseManager().saveDraftOffline(
  //       customerId: customerId,
  //       salesmanId: currentSalesmanId,
  //       totalAmount: finalAmount.value,
  //       details: detail,
  //     );
  //     CartDatabaseManager().cartItems.clear();
  //     CartDatabaseManager().clearCart(customerId: customerId);
  //     log('🧹 Cleared cart after offline save');
  //     return false;
  //   }

  //   log('📡 Fetching existing cart/draft IDs from API...');
  //   final cartDetails =
  //       await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
  //   await Future.delayed(const Duration(seconds: 1));

  //   final firstOrder = cartDetails.isNotEmpty
  //       ? cartDetails.last
  //       : {'cart_id': '', 'draft_id': ''};

  //   final existingCartId = firstOrder['cart_id'] ?? '';
  //   final existingDraftId = firstOrder['draft_id'] ?? '';

  //   log('→ Existing cart ID: $existingCartId');
  //   log('→ Existing draft ID: $existingDraftId');

  //   final productBYData = AddToCartModel(
  //     customerId: customerId,
  //     salesmanId: currentSalesmanId,
  //     cartId: existingCartId,
  //     cartList: detail
  //         .map((e) => SendCartData(
  //               productId: e.productId ?? '',
  //               variantId: e.variationId ?? '',
  //               pack: e.saleBy == 'Pack'
  //                   ? e.pieces.toString()
  //                   : e.count.toString(),
  //               packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
  //               price: e.sellPrice.toString(),
  //               discount: e.discount ?? 0,
  //               quantity: e.count.toInt(),
  //               variantName: e.variationName ?? '',
  //             ))
  //         .toList(),
  //     total: finalAmount.value.toStringAsFixed(0),
  //   );

  //   log('📤 Sending addToDraft API...');
  //   final cartOrder = await ApiWorker().addToDraft(productBYData.toJson());

  //   if (cartOrder != null) {
  //     log('✅ addToDraft succeeded. Sending placeOrder...');
  //     final order = CartOrderModel(
  //       customerId: customerId,
  //       salesmanId: currentSalesmanId,
  //       cartId: existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
  //       orderStatus: 4,
  //       draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
  //       selctedItemCount: 1,
  //     );

  //     await ApiWorker().placeOrder(order, (statusCode, message, response) {
  //       log('→ placeOrder statusCode: $statusCode');
  //       if (statusCode == 200) {
  //         log('✅ Order placed successfully');
  //         showSuccessFullDialogCtrl(context: context);
  //       } else {
  //         log('❌ Failed to place order: $message');
  //         showFaledDialogCtrl(context: context, customerId: customerId);
  //       }
  //     });
  //   } else {
  //     log('❌ addToDraft failed or returned null');
  //   }

  //   CartDatabaseManager().cartItems.clear();
  //   CartDatabaseManager().clearCart(customerId: customerId);
  //   log('🧹 Cleared cart after online draft handling');

  //   log('🛠️ processCartBeforeNavigation END');
  //   return true;
  // }

  Future<void> handleBackNavigation({
    required BuildContext context,
    required bool isDirectDialogue,
    required bool isFromOrder,
    required bool isFromCalender,
    required String customerId,
    required HomeController homeController,
  }) async {
    final connectivityService = ConnectivityService();
    final toDash = isDirectDialogue && (!isFromOrder || !isFromCalender);
    log('Cart Items Count: ${CartDatabaseManager().cartItems.length}');

    log("handle back nav customerID 3 : $customerId");

    if (CartDatabaseManager().cartItems.isNotEmpty &&
        customerId.isNotEmpty &&
        !toDash) {
      Get.dialog(Center(
        child: CircularProgressIndicator(),
      ));
      log('Log 1');
      log('To Dash $toDash');
      List<Detail> detail = [
        ...CartDatabaseManager().cartItems.map((e) => e.detail),
        ...CartDatabaseManager()
            .getDraftItemsForCustomer(customerId)
            .map((e) => e.detail),
      ];
      bool isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        log('[saveDraftOffline] Device is offline. Saving draft locally...');
        await CartDatabaseManager().saveDraftOffline(
          customerId: customerId,
          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
          totalAmount: finalAmount.value,
          details: detail,
        );
        // Update cart/draft count before navigating back
        await Provider.of<CustomersProvider>(context, listen: false)
            .getCartItemCounts(customerId);
        offlineMode1(context);
        CartDatabaseManager().cartItems.clear();
        CartDatabaseManager().clearCart(customerId: customerId);
        CartDatabaseManager().clearAllItemsForCustomer(customerId);
        clearCartItemsInController();
        Navigator.pop(context);
        return;
      }

      final cartDetails =
          await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
      await Future.delayed(const Duration(seconds: 1));
      final firstOrder = cartDetails.isNotEmpty
          ? cartDetails.last
          : {'cart_id': '', 'draft_id': ''};
      final existingCartId = firstOrder['cart_id'] ?? '';
      final existingDraftId = firstOrder['draft_id'] ?? '';
      log('Existing cart ID $existingCartId');
      log('Existing Draft ID $existingDraftId');
      final productBYData = AddToCartModel(
        customerId: customerId,
        salesmanId: SessionHelper.loginSavedData!.salesmanId!,
        cartId: existingCartId.isNotEmpty ? existingCartId : '',
        cartList: detail
            .map((e) => SendCartData(
                productId: e.productId ?? selectedCustomerId.value,
                variantId: e.variationId ?? '',
                pack: e.saleBy == 'Pack'
                    ? e.pieces.toString()
                    : e.count.toString(),
                packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                price: e.sellPrice.toString(),
                discount: e.discount ?? 0,
                quantity: e.count.toInt(),
                variantName: e.variationName ?? ''))
            .toList(),
        total: finalAmount.value.toStringAsFixed(0),
      );
      CartOrderModel? cartOrder =
          await ApiWorker().addToDraft(productBYData.toJson());
      log('Add to Draft Datas : ${productBYData.toJson()}');
      if (cartOrder != null) {
        int orderStatus = 4;
        CartOrderModel order = CartOrderModel(
          customerId: customerId,
          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
          cartId: existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
          orderStatus: orderStatus,
          draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
        );
        await ApiWorker().placeOrder(order,
            (statusCode, message, response) async {
          CartDatabaseManager().moveCartItemsToDraft(customerId);
          // Update cart/draft count before navigating back
          await Provider.of<CustomersProvider>(context, listen: false)
              .getCartItemCounts(customerId);
          Navigator.pop(context);
          if (statusCode == 200) {
            showSuccessFullDialogCtrl(
              context: context,
            );
            CartDatabaseManager().cartItems.clear();
            CartDatabaseManager().clearCart(customerId: customerId);
            CartDatabaseManager().clearAllItemsForCustomer(customerId);
            clearCartItemsInController();
          } else {
            showFaledDialogCtrl(context: context, customerId: customerId);
          }
        });
      }
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
      CartDatabaseManager().clearAllItemsForCustomer(customerId);
      clearCartItemsInController();
      // Update cart/draft count before navigating back
      await Provider.of<CustomersProvider>(context, listen: false)
          .getCartItemCounts(customerId);
    } else if (CartDatabaseManager().cartItems.isNotEmpty &&
        customerId.isNotEmpty &&
        toDash) {
      log('Log 2');
      log('Log NO : 4 : Simply popping back');
      List<Detail> detail = [
        ...CartDatabaseManager().cartItems.map((e) => e.detail),
        ...CartDatabaseManager()
            .getDraftItemsForCustomer(customerId)
            .map((e) => e.detail),
      ];
      bool isOnline = await connectivityService.isOnline();
      if (!isOnline) {
        log('[saveDraftOffline] Device is offline. Saving draft locally...');
        await CartDatabaseManager().saveDraftOffline(
          customerId: customerId,
          salesmanId: SessionHelper.loginSavedData!.salesmanId!,
          totalAmount: finalAmount.value,
          details: detail,
        );
        // Update cart/draft count before navigating back
        await Provider.of<CustomersProvider>(context, listen: false)
            .getCartItemCounts(customerId);
        offlineDialog(context);
        Future.delayed(const Duration(milliseconds: 300), () {
          homeController.sidebarXController.selectIndex(0);
          homeController.selectedIndex.value = 0;
          Get.toNamed(AppRoutes.dashboard, id: 2);
          // selectedCustomerName.value = '';
          // selectedCustomerImageUrl.value = '';
        });
        CartDatabaseManager().cartItems.clear();
        CartDatabaseManager().clearCart(customerId: customerId);
        CartDatabaseManager().clearAllItemsForCustomer(customerId);
        clearCartItemsInController();
        return;
      }
      final cartDetails =
          await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
      await Future.delayed(const Duration(seconds: 1));
      final firstOrder = cartDetails.isNotEmpty
          ? cartDetails.first
          : {'cart_id': '', 'draft_id': ''};
      final existingCartId = firstOrder['cart_id'] ?? '';
      final existingDraftId = firstOrder['draft_id'] ?? '';
      log('Existing cart ID $existingCartId');
      log('Existing Draft ID $existingDraftId');
      final productBYData = AddToCartModel(
        customerId: customerId,
        salesmanId: SessionHelper.loginSavedData!.salesmanId!,
        cartId: existingCartId.isNotEmpty ? existingCartId : '',
        cartList: detail
            .map((e) => SendCartData(
                productId: e.productId ?? selectedCustomerId.value,
                variantId: e.variationId ?? '',
                pack: e.saleBy == 'Pack'
                    ? e.pieces.toString()
                    : e.count.toString(),
                packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                price: e.sellPrice.toString(),
                discount: e.discount ?? 0,
                quantity: e.count.toInt(),
                variantName: e.variationName ?? ''))
            .toList(),
        total: finalAmount.value.toStringAsFixed(0),
      );
      CartOrderModel? cartOrder =
          await ApiWorker().addToDraft(productBYData.toJson());
      if (cartOrder != null) {
        int orderStatus = 4;
        CartOrderModel order = CartOrderModel(
            customerId: customerId,
            salesmanId: SessionHelper.loginSavedData!.salesmanId!,
            cartId:
                existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
            orderStatus: orderStatus,
            draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
            selctedItemCount: 1);
        await ApiWorker().placeOrder(order, (statusCode, message, response) {
          // Update cart/draft count before navigating back
          Provider.of<CustomersProvider>(context, listen: false)
              .getCartItemCounts(customerId);
          if (statusCode == 200) {
            showSuccessFullDialog(
                context: context,
                imagePath: 'assets/images/Animation - 1726906882515.json',
                message: 'Your order has been successfully saved as Draft');
          } else {
            showSuccessFullDialog(
                context: context,
                imagePath: 'assets/images/Warning_animation.json',
                message: "Couldn't save the order as draft please try again.");
          }
        });
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        homeController.sidebarXController.selectIndex(0);
        homeController.selectedIndex.value = 0;
        Get.toNamed(AppRoutes.dashboard, id: 2);
        // selectedCustomerName.value = '';
        // selectedCustomerImageUrl.value = '';
      });
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
      CartDatabaseManager().clearAllItemsForCustomer(customerId);
      clearCartItemsInController();
      // Update cart/draft count before navigating back
      await Provider.of<CustomersProvider>(context, listen: false)
          .getCartItemCounts(customerId);
    } else if (toDash) {
      log('Log 3');
      // Future.delayed(const Duration(milliseconds: 300), () {
      //   homeController.sidebarXController.selectIndex(0);
      //   homeController.selectedIndex.value = 0;
      //   Get.toNamed(AppRoutes.dashboard, id: 2);
      //   selectedCustomerName.value = '';
      //   selectedCustomerImageUrl.value = '';
      // });
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
      CartDatabaseManager().clearAllItemsForCustomer(customerId);
      clearCartItemsInController();
      // Update cart/draft count before navigating back
      await Provider.of<CustomersProvider>(context, listen: false)
          .getCartItemCounts(customerId);
      Navigator.pop(context);
    } else {
      log('Log 4');
      Navigator.pop(context);
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearAllItemsForCustomer(customerId);
      clearCartItemsInController();
      // Update cart/draft count before navigating back
      await Provider.of<CustomersProvider>(context, listen: false)
          .getCartItemCounts(customerId);
    }
    CartDatabaseManager().getDraftItems();
  }

  void updateSelectedCustomer(
      {required String name, required String imageUrl, required String id}) {
    selectedCustomerName.value = name;
    selectedCustomerImageUrl.value = imageUrl;
    selectedCustomerId.value = id;
    log('Selected Customer Updated: $name, $imageUrl, $id');
  }

  Future<List<ProductModel>> fetchProducts(String subCatId) async {
    try {
      log('fetchProducts: Starting with subCatId: $subCatId');

      if (subCatId.isEmpty) {
        log('fetchProducts: ERROR - subCatId is empty');
        isLoading.value = false;
        products.clear();
        return [];
      }

      // Validate that subCatId is a valid number or string
      if (subCatId.trim().isEmpty) {
        log('fetchProducts: ERROR - subCatId is empty after trimming');
        isLoading.value = false;
        products.clear();
        return [];
      }

      log('fetchProducts: Valid subCatId: $subCatId');
      isLoading.value = true;
      log('fetchProducts: Fetching products from API...');

      List<ProductModel> fetchedProducts = await _apiWorker.getTempProduct(
        subCatId,
        companyid: SessionHelper.loginSavedData?.company_id ?? 0,
      );

      log('fetchProducts: API response received. Products count: ${fetchedProducts.length}');
      log('fetchProducts: Product SCIDs in response: ${fetchedProducts.map((p) => p.scid).toSet().toList()}');
      log('fetchProducts: Expected SCID: $subCatId');
      log('fetchProducts: Product names: ${fetchedProducts.map((p) => p.productName).toList()}');

      // Clear existing products and set new ones (no deduplication)
      products.clear();
      products.addAll(fetchedProducts);
      isLoading.value = false;

      log('fetchProducts: Final products length: ${products.length}');
      log('fetchProducts: Final product SCIDs: ${products.map((p) => p.scid).toSet().toList()}');
      log('fetchProducts: Products: ${fetchedProducts.map((p) => '${p.productName} (SCID: ${p.scid}, ${p.detail?.length ?? 0} variants)').toList()}');

      // Debug the product list to check for duplicates
      debugProductList();

      return fetchedProducts;
    } catch (e) {
      log('fetchProducts: Error occurred: $e');
      log('fetchProducts: Stack trace: ${StackTrace.current}');
      isLoading.value = false;
      products.clear();
      return [];
    }
  }

  // Method to clear products for a specific subcategory
  Future<void> clearProductsForSubCategory(String subCatId) async {
    try {
      log('clearProductsForSubCategory: Clearing products for subcategory: $subCatId');

      // Clear from memory
      products.clear();

      // Clear from cache
      await _apiWorker.clearProductsForSubCategory(subCatId);

      log('clearProductsForSubCategory: Products cleared successfully');
    } catch (e) {
      log('clearProductsForSubCategory: Error occurred: $e');
    }
  }

  // Method to clear all products
  void clearAllProducts() {
    log('clearAllProducts: Clearing all products from memory');
    products.clear();
    isLoading.value = false;
  }

  // Method to clear cache and reload products for a specific subcategory
  Future<List<ProductModel>> reloadProductsForSubCategory(
      String subCatId) async {
    log('reloadProductsForSubCategory: Reloading products for subcategory: $subCatId');

    try {
      // Clear cache for this subcategory
      await _apiWorker.clearProductsForSubCategory(subCatId);

      // Fetch fresh products
      return await fetchProducts(subCatId);
    } catch (e) {
      log('reloadProductsForSubCategory: Error occurred: $e');
      return [];
    }
  }

  // Method to debug product list
  void debugProductList() {
    log('debugProductList: Current products count: ${products.length}');
    log('debugProductList: Product IDs: ${products.map((p) => p.productId).toList()}');
    log('debugProductList: Product names: ${products.map((p) => p.productName).toList()}');

    // Check for duplicates
    final productIds =
        products.map((p) => p.productId).where((id) => id != null).toList();
    final uniqueIds = productIds.toSet();
    if (productIds.length != uniqueIds.length) {
      log('debugProductList: WARNING - Found ${productIds.length - uniqueIds.length} duplicate product IDs');
      final duplicates = <String>[];
      for (var id in uniqueIds) {
        if (productIds.where((pid) => pid == id).length > 1) {
          duplicates.add(id!);
        }
      }
      log('debugProductList: Duplicate IDs: $duplicates');
    }
  }

  Future<void> fetchCategoryData() async {
    try {
      log('fetchCategoryData: Starting...');
      CategoryModel? categoryModel;

      final List<ConnectivityResult> connectivityResult =
          await Connectivity().checkConnectivity();
      log('fetchCategoryData: Connectivity result: $connectivityResult');

      // if (connectivityResult.contains(ConnectivityResult.none)) {
      //   categoryModel = await retrieveCategoryData();
      //   log('Retrieved from Hive : ${categoryModel?.data?.length}');
      // } else {
      log('fetchCategoryData: Fetching from API...');
      categoryModel = await _apiWorker.getCategory(
        companyid: SessionHelper.loginSavedData?.company_id ?? 0,
      );
      log('fetchCategoryData: API response received. Data length: ${categoryModel.data?.length ?? 0}');

      await storeCategoryData(categoryModel);
      log('DataStored in Hive : ${categoryModel.data?.length}');
      // }

      log('fetchCategoryData: Setting categoryData.value...');
      categoryData.value = categoryModel;
      log('fetchCategoryData: categoryData.value set. Length: ${categoryData.value.data?.length ?? 0}');
    } catch (e) {
      log('fetchCategoryData: Error occurred: $e');
      log('fetchCategoryData: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  SubCategoryItem? getInitialSubCategoryIdAndName() {
    try {
      if (categoryData.value.data != null &&
          categoryData.value.data!.isNotEmpty) {
        var firstCategory = categoryData.value.data!.first;

        // Check if subCategoryItem exists and is not empty
        if (firstCategory.subCategoryItem != null &&
            firstCategory.subCategoryItem!.isNotEmpty) {
          var firstSubcategory = firstCategory.subCategoryItem!.first;

          log("Fetching initial subcategory ID: ${firstSubcategory?.id}");
          log("Fetching initial subcategory name: ${firstSubcategory?.subCategory}");

          selectedSubCategoryId.value = "${firstSubcategory?.id}";
          log("getInitialSubCategoryIdAndName : selectedSubCategoryId.value : ${selectedSubCategoryId.value}");

          return firstSubcategory;
        } else {
          log("No subcategories found in the first category: ${firstCategory.categoryName}");
          return null;
        }
      }
      log("No categories found in categoryData");
      return null;
    } catch (e) {
      log("Error fetching initial subcategory details: $e");
      return null;
    }
  }

  Future<void> storeCategoryData(CategoryModel categoryModel) async {
    final box = await Hive.openBox('categoriesBox');
    await box.put('categoryData', categoryModel.toJson());
  }

  Future<CategoryModel?> retrieveCategoryData() async {
    final box = await Hive.openBox('categoriesBox');
    final jsonString = box.get('categoryData');
    if (jsonString != null) {
      return CategoryModel.fromJson(jsonString);
    }
    return null;
  }

  Future<CategoryModel> loadDataOfCategories() async {
    try {
      final categoryModel = await _apiWorker.getCategory(
        companyid: SessionHelper.loginSavedData?.company_id ?? 0,
      );
      await storeCategoryData(categoryModel);
      return categoryModel;
    } catch (e) {
      log('Error fetching data from API: $e');
      final categoryModel = await retrieveCategoryData();
      if (categoryModel != null) {
        return categoryModel;
      }
      throw Exception('No category data available');
    }
  }

  /// Check if categories and default products are ready
  bool get isCategoriesAndProductsReady {
    return categoryData.value.data != null &&
        categoryData.value.data!.isNotEmpty &&
        selectedSubCategoryId.value.isNotEmpty &&
        selectedSubCategoryName.value.isNotEmpty;
  }

  /// Loads categories and automatically loads products for the first subcategory
  Future<void> loadCategoriesAndDefaultProducts() async {
    try {
      log('Starting loadCategoriesAndDefaultProducts...');
      debugCategoryData();

      // Check if we already have categories and products loaded
      if (isCategoriesAndProductsReady && products.isNotEmpty) {
        log('Categories and default products already loaded. Skipping...');
        log('Current product count: ${products.length}');
        log('Current selected subcategory: ${selectedSubCategoryName.value}');
        return;
      }

      // First, fetch categories
      log('Fetching category data...');
      await fetchCategoryData();
      log('Categories loaded successfully. Category count: ${categoryData.value.data?.length ?? 0}');
      debugCategoryData();

      // Debug: Check if categories were actually loaded
      if (categoryData.value.data == null || categoryData.value.data!.isEmpty) {
        log('ERROR: No categories loaded after fetchCategoryData()');
        log('categoryData.value: ${categoryData.value}');
        return;
      }

      // Then, get the initial subcategory and load its products
      log('Getting initial subcategory...');
      SubCategoryItem? initialSubCategory = getInitialSubCategoryIdAndName();
      if (initialSubCategory != null && initialSubCategory.id != null) {
        log('Loading default products for subcategory: ${initialSubCategory.subCategory} (ID: ${initialSubCategory.id})');

        // Set the selected subcategory name for UI immediately
        selectedSubCategoryName.value = initialSubCategory.subCategory ?? '';

        // Load products
        await fetchProducts(initialSubCategory.id.toString());

        // Set category tax if available
        if (categoryData.value.data != null &&
            categoryData.value.data!.isNotEmpty) {
          var firstCategory = categoryData.value.data!.first;
          // selectedCategoryTax.value = firstCategory.categoryTax ?? [];
          // calculateTotalTax();
          // log('Category tax set. Tax count: ${selectedCategoryTax.length}');
        }

        log('Default products loaded successfully. Product count: ${products.length}');
        log('Selected subcategory name: ${selectedSubCategoryName.value}');
        log('Selected subcategory ID: ${selectedSubCategoryId.value}');
        debugCategoryData();
      } else {
        log('No initial subcategory found or subcategory ID is null');
        log('Category data: ${categoryData.value.data?.map((e) => '${e.categoryName}: ${e.subCategoryItem?.length ?? 0} subcategories')}');
      }
    } catch (e) {
      log('Error loading categories and default products: $e');
      log('Stack trace: ${StackTrace.current}');
      // Don't throw the error to avoid breaking the login flow
    }
  }

  addTOServerCart(AddToCartModel data) async {
    await ApiWorker().addToCart(data.toJson());
  }

  Future addProductToCart(
      AddToCartModel savedData, ProductsController productsController) async {
    log("SubCategory with match  ${productsController.selectedSubCategoryId.value}");
    return await addTOServerCart(
      savedData,
    );
  }

  (Widget widget, bool isStockAvlableWidget) isStockAvlableWidget(num stock) {
    if (stock == 0) {
      var widget = Container(
        decoration:
            const ShapeDecoration(shape: OvalBorder(), color: errorColor),
        child: Icon(
          Icons.close,
          color: secondaryIconColor,
          size: NkGeneralSize.nkIconSize() - 10,
        ),
      );
      return (widget, false);
    } else {
      var widgets = Container(
        decoration:
            const ShapeDecoration(shape: OvalBorder(), color: switchColor),
        child: Icon(
          Icons.check,
          color: secondaryIconColor,
          size: NkGeneralSize.nkIconSize() - 10,
        ),
      );
      return (widgets, true);
    }
  }

  Widget emptyProductWidget({void Function()? onPressed}) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyRegularText(
            label: noProductAvailable,
            fontSize: 16.0,
          ),
        ],
      ),
    );
  }

  void debugCategoryData() {
    log('=== Category Data Debug ===');
    log('categoryData.value.data: ${categoryData.value.data}');
    log('categoryData.value.data?.length: ${categoryData.value.data?.length ?? 0}');
    if (categoryData.value.data != null &&
        categoryData.value.data!.isNotEmpty) {
      log('First category: ${categoryData.value.data!.first.categoryName}');
      log('First category subcategories: ${categoryData.value.data!.first.subCategoryItem?.length ?? 0}');
      if (categoryData.value.data!.first.subCategoryItem != null &&
          categoryData.value.data!.first.subCategoryItem!.isNotEmpty) {
        log('First subcategory: ${categoryData.value.data!.first.subCategoryItem!.first.subCategory}');
        log('First subcategory ID: ${categoryData.value.data!.first.subCategoryItem!.first.id}');
      }
    }
    log('selectedSubCategoryId.value: ${selectedSubCategoryId.value}');
    log('selectedSubCategoryName.value: ${selectedSubCategoryName.value}');
    log('products.length: ${products.length}');
    log('==========================');
  }

  /// Force refresh products for the current subcategory
  Future<void> refreshProducts() async {
    try {
      log('refreshProducts: Starting...');
      if (selectedSubCategoryId.value.isNotEmpty) {
        log('refreshProducts: Refreshing products for subcategory: ${selectedSubCategoryName.value} (ID: ${selectedSubCategoryId.value})');
        await fetchProducts(selectedSubCategoryId.value);
      } else {
        log('refreshProducts: No subcategory selected, cannot refresh products');
      }
    } catch (e) {
      log('refreshProducts: Error refreshing products: $e');
    }
  }

  /// Wait for categories to be loaded (useful for UI widgets)
  Future<bool> waitForCategories({int maxAttempts = 20}) async {
    int attempts = 0;
    while (!isCategoriesAndProductsReady && attempts < maxAttempts) {
      log('waitForCategories: Waiting... attempt ${attempts + 1}');
      await Future.delayed(const Duration(milliseconds: 250));
      attempts++;
    }

    bool ready = isCategoriesAndProductsReady;
    log('waitForCategories: Categories ready: $ready after $attempts attempts');
    return ready;
  }

  /// Check cache status for debugging
  Future<void> checkCacheStatus() async {
    log('=== checkCacheStatus START ===');
    try {
      late Box<ScidProductGroup> scidGroupBox;
      late Box<ProductModel> productBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (Hive.isBoxOpen('products')) {
        productBox = Hive.box<ProductModel>('products');
      } else {
        productBox = await Hive.openBox<ProductModel>('products');
      }

      log('Cache Status:');
      log('- ScidProductGroups box: ${scidGroupBox.length} entries');
      log('- Products box: ${productBox.length} entries');
      log('- Available scid keys: ${scidGroupBox.keys.toList()}');
      log('- Current selectedSubCategoryId: ${selectedSubCategoryId.value}');
      log('- Current selectedSubCategoryName: ${selectedSubCategoryName.value}');

      if (scidGroupBox.isNotEmpty) {
        for (var key in scidGroupBox.keys) {
          final group = scidGroupBox.get(key);
          log('- Scid group $key: ${group?.products.length ?? 0} products');
        }
      }

      if (productBox.isNotEmpty) {
        final allScids = productBox.values.map((p) => p.scid).toSet().toList();
        log('- All scids in legacy cache: $allScids');
      }

      log('=== checkCacheStatus END ===');
    } catch (e) {
      log('Error checking cache status: $e');
      log('=== checkCacheStatus END (Error) ===');
    }
  }

  /// Select a subcategory and load its products
  Future<void> selectSubCategory(
      String subCategoryId, String subCategoryName) async {
    try {
      log('selectSubCategory: Selecting subcategory: $subCategoryName (ID: $subCategoryId)');

      if (subCategoryId.isEmpty) {
        log('selectSubCategory: ERROR - subCategoryId is empty');
        return;
      }

      if (subCategoryName.isEmpty) {
        log('selectSubCategory: ERROR - subCategoryName is empty');
        return;
      }

      selectedSubCategoryId.value = subCategoryId;
      selectedSubCategoryName.value = subCategoryName;

      log('selectSubCategory: Loading products for subcategory: $subCategoryName');
      await fetchProducts(subCategoryId);

      log('selectSubCategory: Products loaded successfully. Count: ${products.length}');
    } catch (e) {
      log('selectSubCategory: Error selecting subcategory: $e');
    }
  }

  void updateCustomerAndOrderData(CustomerAndOrderData newData) {
    productList.clear();
    productListBackup.clear();
    categoryData.value = CategoryModel();
    customerAndOrderData.value = newData;
    categoryData.value =
        BackupDataFunction.getCategoryAndProductBackup ?? CategoryModel();
    refresh();
    //log('CHANGEDDDDDD: ${categoryData.value.data?.map((e) => e.subCategoryItem?.map((e) => e.productList?.map((e) => e.variant?.map((e) => e.toJson()))))}');

    if (categoryData.value.data != null) {
      // updateProductList(
      //     categoryData
      //             .value
      //             .data![selectedCategoryIndex.value]
      //             .subCategoryItem?[selectedSubCategoryIndex.value]
      //             .productList ??
      //         [],
      //     isBackupUpdate: true
      //     );
    }
    refresh();
  }
}
