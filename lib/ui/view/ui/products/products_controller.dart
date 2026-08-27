// ignore_for_file: unused_local_variable, avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/backup_data_fun.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/model/bulk_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/dialog/dialogs.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_responce/product_frequency_model.dart';
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
  RxDouble totalOrderTax = 0.0.obs;
  var showDialog = false.obs;
  void closeDialog() {
    showDialog.value = false;
  }

  RxBool isCartModified = false.obs;
  RxDouble allItemsTotalSave = 0.0.obs;
List<BulkData> storedBulkList = [];
  // Fixed flat discount per customer (cart-level), applied at display time in cart UI
  final Map<String, double> flatDiscountByCustomer = {};

  List<CartItem> cartItems = [];
  List<CartItem> orderItems = [];
  List<CartItem> preorderItems = [];

  void clearCartItemsInController() {
    cartItems.clear();
    orderItems.clear();
    preorderItems.clear();
  }

  void clearCartItemsInControllerAndHive(String customerId) async {
    await CartDatabaseManager().clearCartOnlyForCustomer(customerId);
    cartItems.clear();
    orderItems.clear();
    preorderItems.clear();
  }
  Future<void> fetchBulkData() async {
    try {
      // Call your API function here
      final bulkResponse = await ApiWorker().getBulkVolumes();
      
      // Save the data to the controller variable
      if (bulkResponse.data != null) {
        storedBulkList = bulkResponse.data!;
        
        print('Bulk data stored in Controller: ${storedBulkList.length} items');
      }
    } catch (e) {
      print("Error fetching bulk data: $e");
    }
  }

  bool onReached(bool reached) {
    isReached.value = reached;
    return isReached.value;
  }

  Future<void> handleBackNavigation({
  required BuildContext context,
  required bool isDirectDialogue,
  required bool isFromOrder,
  required bool isFromCalender,
  required String customerId,
  required HomeController homeController,
}) async {
  final toDash = isDirectDialogue && (!isFromOrder || !isFromCalender);

  print('toDash: $toDash, isDirectDialogue: $isDirectDialogue, isFromOrder: $isFromOrder, isFromCalender: $isFromCalender');

  if ((CartDatabaseManager().cartItems.isNotEmpty ||
          CartDatabaseManager().draftBox.isNotEmpty) &&
      customerId.isNotEmpty &&
      isCartModified.value) {

    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      barrierDismissible: false,
    );

    if (storedBulkList.isEmpty) {
      print('handleBackNavigation: Bulk list is empty. Fetching API now...');
      await fetchBulkData();
    }

    print('Processing navigation with ${storedBulkList.length} bulk items.');

    final wasSuccessful = await processCartBeforeNavigation(
      context: context,
      customerId: customerId,
      bulkDataList: storedBulkList,
    );

    print('wasSuccessful: $wasSuccessful'); // <-- ADD THIS to debug

    // ✅ ALWAYS close loading dialog first
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // ✅ Show success OUTSIDE toDash check — always show if API returned 200
    if (wasSuccessful) {
      showSuccessFullDialog(
        context: context,
        imagePath: 'assets/images/Animation - 1726906882515.json',
        message: 'Your order has been successfully saved as Draft',
      );
      await Future.delayed(const Duration(milliseconds: 1500));
    } else if (!wasSuccessful && toDash) {
      // offline case only when going to dash
      offlineDialog(context);
    }

    Navigator.pop(context);

  } else if (toDash) {
    CartDatabaseManager().cartItems.clear();
    CartDatabaseManager().clearCart(customerId: customerId);
    Navigator.pop(context);
  } else {
    CartDatabaseManager().cartItems.clear();
    Navigator.pop(context);
  }

  await Provider.of<CustomersProvider>(context, listen: false)
      .fetchOrdersForCustomDash(OrderStatus.draft, customerId);
  CartDatabaseManager().getDraftItems();
  isCartModified.value = false;
}
//   Future<void> handleBackNavigation({
//   required BuildContext context,
//   required bool isDirectDialogue,
//   required bool isFromOrder,
//   required bool isFromCalender,
//   required String customerId,
//   required HomeController homeController,
// }) async {
//   final toDash = isDirectDialogue && (!isFromOrder || !isFromCalender);

//   if ((CartDatabaseManager().cartItems.isNotEmpty ||
//           CartDatabaseManager().draftBox.isNotEmpty) &&
//       customerId.isNotEmpty &&
//       isCartModified.value) {

//     Get.dialog(
//       const PopScope(
//         canPop: false,
//         child: Center(child: CircularProgressIndicator()),
//       ),
//       barrierDismissible: false,
//     );

//     if (storedBulkList.isEmpty) {
//       print('handleBackNavigation: Bulk list is empty. Fetching API now...');
//       await fetchBulkData();
//     }

//     print('Processing navigation with ${storedBulkList.length} bulk items.');

//     final wasSuccessful = await processCartBeforeNavigation(
//       context: context,
//       customerId: customerId,
//       bulkDataList: storedBulkList,
//     );

//     // ✅ ALWAYS close loading dialog first before doing anything else
//     if (Get.isDialogOpen ?? false) {
//       Get.back();
//     }

//     // Small delay to let the dialog fully close before opening another
//     await Future.delayed(const Duration(milliseconds: 200));

//     if (toDash) {
//       if (wasSuccessful) {
//         // ✅ Only show success when API actually returned 200
//         showSuccessFullDialog(
//           context: context,
//           imagePath: 'assets/images/Animation - 1726906882515.json',
//           message: 'Your order has been successfully saved as Draft',
//         );
//         await Future.delayed(const Duration(milliseconds: 1500));
//       }
//       if (toDash) {
//   Navigator.pop(context);
// } else {
//   if (!wasSuccessful) {
//     // only show offline dialog if it failed and not already shown inside processCart
//   }
//   Navigator.pop(context);
// }
//       // If !wasSuccessful: either offline (already handled inside process fn)
//       // or cart was empty — just navigate back silently
//       // Navigator.pop(context);
//     } else {
//       Navigator.pop(context);
//     }
//   } else if (toDash) {
//     CartDatabaseManager().cartItems.clear();
//     CartDatabaseManager().clearCart(customerId: customerId);
//     Navigator.pop(context);
//   } else {
//     CartDatabaseManager().cartItems.clear();
//     Navigator.pop(context);
//   }

//   await Provider.of<CustomersProvider>(context, listen: false)
//       .fetchOrdersForCustomDash(OrderStatus.draft, customerId);
//   CartDatabaseManager().getDraftItems();
//   isCartModified.value = false;
// }
  // Future<void> handleBackNavigation({
  //   required BuildContext context,
  //   required bool isDirectDialogue,
  //   required bool isFromOrder,
  //   required bool isFromCalender,
  //   required String customerId,
  //   required HomeController homeController,
  // }) async {
  //   final toDash = isDirectDialogue && (!isFromOrder || !isFromCalender);

  //   if ((CartDatabaseManager().cartItems.isNotEmpty ||
  //           CartDatabaseManager().draftBox.isNotEmpty) &&
  //       customerId.isNotEmpty &&
  //       isCartModified.value) {
      
  //     // 1. Make the dialog non-dismissible so taps won't break the app state
  //     Get.dialog(
  //       const PopScope(
  //         canPop: false, // Prevents back swipe/button
  //         child: Center(child: CircularProgressIndicator()),
  //       ),
  //       barrierDismissible: false, // Prevents screen taps from closing it
  //     );

  //     if (storedBulkList.isEmpty) {
  //       print('handleBackNavigation: Bulk list is empty. Fetching API now...');
  //       await fetchBulkData(); 
  //     }

  //     print('Processing navigation with ${storedBulkList.length} bulk items.');
      
  //     final wasOnline = await processCartBeforeNavigation(
  //       context: context,
  //       customerId: customerId,
  //       bulkDataList: storedBulkList, 
  //     );

  //     // 2. EXPLICITLY CLOSE THE LOADING DIALOG BEFORE PROCEEDING
  //     if (Get.isDialogOpen ?? false) {
  //       Get.back();
  //     }

  //     if (toDash) {
  //       await Future.delayed(const Duration(milliseconds: 300));

  //       // 3. Optional Check: Only show success if items actually existed to save
  //       final hasActiveItems = CartDatabaseManager().cartItems.any((e) => e.customerId == customerId && e.detail.count > 0) || 
  //                              CartDatabaseManager().draftBox.values.any((e) => e.customerId == customerId && e.detail.count > 0);

  //       if (wasOnline && hasActiveItems) {
  //         showSuccessFullDialog(
  //           context: context,
  //           imagePath: 'assets/images/Animation - 1726906882515.json',
  //           message: 'Your order has been successfully saved as Draft',
  //         );
  //       } else if (!wasOnline && hasActiveItems) {
  //         offlineDialog(context);
  //       }

  //       await Future.delayed(const Duration(milliseconds: 300));
  //       Navigator.pop(context);
  //     } else {
  //       if (!wasOnline) {
  //         offlineMode1(context);
  //       }
  //       Navigator.pop(context);
  //     }
  //   } else if (toDash) {
  //     CartDatabaseManager().cartItems.clear();
  //     CartDatabaseManager().clearCart(customerId: customerId);
  //     Navigator.pop(context);
  //   } else {
  //     CartDatabaseManager().cartItems.clear();
  //     Navigator.pop(context);
  //   }
    
  //   await Provider.of<CustomersProvider>(context, listen: false)
  //       .fetchOrdersForCustomDash(
  //     OrderStatus.draft,
  //     customerId,
  //   );
  //   CartDatabaseManager().getDraftItems();
  //   isCartModified.value = false;
  // }
  // Future<void> handleBackNavigation({
  //   required BuildContext context,
  //   required bool isDirectDialogue,
  //   required bool isFromOrder,
  //   required bool isFromCalender,
  //   required String customerId,
  //   required HomeController homeController,
  // }) async {
  //   final toDash = isDirectDialogue && (!isFromOrder || !isFromCalender);

  //   if ((CartDatabaseManager().cartItems.isNotEmpty ||
  //           CartDatabaseManager().draftBox.isNotEmpty) &&
  //       customerId.isNotEmpty &&
  //       isCartModified.value) {
      
  //     Get.dialog(const Center(child: CircularProgressIndicator()));

  //     // -------------------------------------------------------------
  //     // 1. ADD THIS CHECK: Auto-fetch if the list is empty
  //     // -------------------------------------------------------------
  //     if (storedBulkList.isEmpty) {
  //       print('handleBackNavigation: Bulk list is empty. Fetching API now...');
  //       await fetchBulkData(); // Ensure this function is defined in your controller
  //     }

  //     print('Processing navigation with ${storedBulkList.length} bulk items.');
  //     // -------------------------------------------------------------

  //     final wasOnline = await processCartBeforeNavigation(
  //       context: context,
  //       customerId: customerId,
  //       bulkDataList: storedBulkList, // Now this list is guaranteed to have data
  //     );

  //     if (toDash) {
  //       await Future.delayed(const Duration(milliseconds: 300));

  //       if (wasOnline) {
  //         showSuccessFullDialog(
  //           context: context,
  //           imagePath: 'assets/images/Animation - 1726906882515.json',
  //           message: 'Your order has been successfully saved as Draft',
  //         );
  //       } else {
  //         offlineDialog(context);
  //       }

  //       await Future.delayed(const Duration(milliseconds: 300));
  //       Navigator.pop(context);
  //     } else {
  //       if (!wasOnline) {
  //         offlineMode1(context);
  //       }
  //       Navigator.pop(context);
  //     }
  //   } else if (toDash) {
  //     CartDatabaseManager().cartItems.clear();
  //     CartDatabaseManager().clearCart(customerId: customerId);
  //     Navigator.pop(context);
  //   } else {
  //     CartDatabaseManager().cartItems.clear();
  //     Navigator.pop(context);
  //   }
    
  //   await Provider.of<CustomersProvider>(context, listen: false)
  //       .fetchOrdersForCustomDash(
  //     OrderStatus.draft,
  //     customerId,
  //   );
  //   CartDatabaseManager().getDraftItems();
  //   isCartModified.value = false;
  // }

  // Future<void> handleBackNavigation({
  //   required BuildContext context,
  //   required bool isDirectDialogue,
  //   required bool isFromOrder,
  //   required bool isFromCalender,
  //   required String customerId,
  //   required HomeController homeController,
  // }) async {
  //   final toDash = isDirectDialogue && (!isFromOrder || !isFromCalender);
  //   // print('cart items while back${CartDatabaseManager().cartItems}');
  //   // print('draft box while back${CartDatabaseManager().draftBox.isNotEmpty}');
  //   // print('customerId$customerId');
  //   // print('isCartModified${isCartModified.value}');
  //   if ((CartDatabaseManager().cartItems.isNotEmpty ||
  //           CartDatabaseManager().draftBox.isNotEmpty) &&
  //       customerId.isNotEmpty &&
  //       isCartModified.value) {
  //     Get.dialog(const Center(child: CircularProgressIndicator()));

  //     final wasOnline = await processCartBeforeNavigation(
  //       context: context,
  //       customerId: customerId,
  //       bulkDataList: storedBulkList
       
  //     );
  //     if (toDash) {
  //       await Future.delayed(const Duration(milliseconds: 300));

  //       if (wasOnline) {
  //         showSuccessFullDialog(
  //           context: context,
  //           imagePath: 'assets/images/Animation - 1726906882515.json',
  //           message: 'Your order has been successfully saved as Draft',
  //         );
  //       } else {
  //         offlineDialog(context);
  //       }

  //       await Future.delayed(const Duration(milliseconds: 300));
  //       Navigator.pop(context);
  //     } else {
  //       if (!wasOnline) {
  //         offlineMode1(context);
  //       }
  //       Navigator.pop(context);
  //     }
  //   } else if (toDash) {
  //     CartDatabaseManager().cartItems.clear();
  //     CartDatabaseManager().clearCart(customerId: customerId);
  //     Navigator.pop(context);
  //   } else {
  //     CartDatabaseManager().cartItems.clear();
  //     Navigator.pop(context);
  //   }
  //   await Provider.of<CustomersProvider>(context, listen: false)
  //       .fetchOrdersForCustomDash(
  //     OrderStatus.draft,
  //     customerId,
  //   );
  //   CartDatabaseManager().getDraftItems();
  //   isCartModified.value = false;
  // }
  RxString catalogProductSearchQuery = "".obs;
  RxList<ProductModel> catalogSearchedProducts = <ProductModel>[].obs;

  Future<void> searchProductsInCatalog(String query) async {
    catalogProductSearchQuery.value = query;
    if (query.trim().isEmpty) {
      catalogSearchedProducts.clear();
      return;
    }

    final lowerQuery = query.trim().toLowerCase();
    List<ProductModel> allProducts = [];

    // 1. Controller products
    if (products.isNotEmpty) {
      allProducts.addAll(products);
    }

    // 2. scidProductGroups Box
    try {
      if (Hive.isBoxOpen('scidProductGroups')) {
        final box = Hive.box<ScidProductGroup>('scidProductGroups');
        for (final group in box.values) {
          allProducts.addAll(group.products);
        }
      } else {
        final box = await Hive.openBox<ScidProductGroup>('scidProductGroups');
        for (final group in box.values) {
          allProducts.addAll(group.products);
        }
      }
    } catch (_) {}

    // 3. products Box
    try {
      if (Hive.isBoxOpen('products')) {
        final box = Hive.box<ProductModel>('products');
        allProducts.addAll(box.values);
      }
    } catch (_) {}

    final Map<String, ProductModel> uniqueMap = {};
    for (final p in allProducts) {
      final key = p.productId?.toString().isNotEmpty == true
          ? p.productId.toString()
          : (p.id?.toString() ?? p.productName ?? '');
      if (key.isNotEmpty && !uniqueMap.containsKey(key)) {
        uniqueMap[key] = p;
      }
    }

    final filtered = uniqueMap.values.where((p) {
      final name = p.productName?.toLowerCase() ?? '';
      final code = p.productCode?.toLowerCase() ?? '';
      final brand = p.brandname?.toLowerCase() ?? '';
      final hasDetailMatch = p.detail?.any((d) =>
              (d.variationName?.toLowerCase() ?? '').contains(lowerQuery) ||
              (d.barcode?.toLowerCase() ?? '').contains(lowerQuery) ||
              (d.inNo?.toLowerCase() ?? '').contains(lowerQuery)) ??
          false;

      return name.contains(lowerQuery) ||
          code.contains(lowerQuery) ||
          brand.contains(lowerQuery) ||
          hasDetailMatch;
    }).toList();

    catalogSearchedProducts.value = filtered;
  }

  void clearCatalogProductSearch() {
    catalogProductSearchQuery.value = "";
    catalogSearchedProducts.clear();
  }

  Future<bool> processCartBeforeNavigation({
  required BuildContext context,
  required String customerId,
  List<BulkData>? bulkDataList,
}) async {
  print('process navigation started');

  final connectivityService = ConnectivityService();
  final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

  final Map<String, CartItem> itemMap = {};

  final draftItems = CartDatabaseManager()
      .draftBox
      .values
      .where((e) => e.customerId == customerId)
      .toList();
  final cartItems = CartDatabaseManager()
      .cartItems
      .where((e) => e.customerId == customerId)
      .toList();

  for (var item in draftItems) {
    if (item.detail.count <= 0) continue;
    final key = "${item.detail.variationId}_${item.isPromo ?? false}_${item.isPack ?? false}";
    itemMap[key] = item;
  }

  for (var item in cartItems) {
    if (item.detail.count <= 0) continue;
    final key = "${item.detail.variationId}_${item.isPromo ?? false}_${item.isPack ?? false}";
    if (!itemMap.containsKey(key)) {
      itemMap[key] = item;
    }
  }

  final allItems = itemMap.values.toList();

  if (allItems.isEmpty) {
    print("Cart is empty, nothing to save to draft.");
    CartDatabaseManager().cartItems.clear();
    CartDatabaseManager().clearCart(customerId: customerId);
    return false;
  }

  allItemsTotalSave.value = Utils().calculateSubtotal(allItems);

  final List<Detail> detail = allItems.map((e) {
    final d = e.detail;
    if (d.productName == null || d.productName!.isEmpty) {
      d.productName = e.productName;
    }
    return d;
  }).toList();
  await CartDatabaseManager().saveDraftOffline(
    customerId: customerId,
    salesmanId: currentSalesmanId,
    totalAmount: finalAmount.value,
    details: detail,
    customerName: selectedCustomerName.value,
    customerMobile: selectedCustomerMobileNo.value,
    customerEmail: selectedCustomerEmail.value,
    customerImageUrl: selectedCustomerImageUrl.value,
    allItemsTotal: allItemsTotalSave.value,
  );

  final isOnline = await connectivityService.isOnline();

  if (!isOnline) {
    CartDatabaseManager().clearCart(customerId: customerId);
    return false;
  } else {
    final cartDetails =
        await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
    await Future.delayed(const Duration(seconds: 1));

    final firstOrder = cartDetails.isNotEmpty
        ? cartDetails.last
        : {'cart_id': '', 'draft_id': ''};

    final existingCartId = firstOrder['cart_id'] ?? '';
    final existingDraftId = firstOrder['draft_id'] ?? '';

    final productBYData = AddToCartModel(
      customerId: customerId,
      salesmanId: currentSalesmanId,
      cartId: existingCartId,
      cartList: await Future.wait(allItems.map((item) async {
        final e = item.detail;
        print('bulk discount amount in the controller:${e.bulkDiscountAmount}');
        print('full detailssssss:${e.toJson()}');

        String packValue;
        if (e.bulkId != null && e.bulkId!.isNotEmpty) {
          packValue = e.pieces.toString();
        } else {
          packValue =
              e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();
        }

        final bool isBulk = (e.bulkId != null && e.bulkId!.isNotEmpty) ||
            (e.packtype == 'Bulk') ||
            (item.isPack == true && e.bulkDiscount != null && e.bulkDiscount! > 0) ||
            (e.bulkDiscountAmount != null && e.bulkDiscountAmount! > 0);

        final bool isPromoItem = (item.isPromo == true) && !isBulk;

        final double combinedDiscount =
            (item.totalDiscountAmount ?? 0).toDouble() +
                (isPromoItem ? (item.flatDiscount ?? 0).toDouble() : 0.0) +
                (isPromoItem ? (item.bogoDiscount ?? 0).toDouble() : 0.0) +
                (e.bulkDiscountAmount ?? 0).toDouble();
        final num combinedPromoDiscount = isPromoItem
            ? ((item.tieredDiscount ?? 0) +
                (item.flatDiscount ?? 0) +
                (item.bogoDiscount ?? 0))
            : 0;

        final String origUnitPrice = (e.sellPrice != null &&
                e.sellPrice.toString().trim().isNotEmpty &&
                e.sellPrice.toString() != 'null')
            ? e.sellPrice.toString()
            : (e.price?.toString() ?? '0.0');

        final String origPackPrice = (() {
          final double? apiSPP =
              double.tryParse(e.sellingPackPrice?.toString() ?? '');
          if (apiSPP != null && apiSPP > 0) return apiSPP.toStringAsFixed(2);
          final double? apiPP =
              double.tryParse(e.packPrice?.toString() ?? '');
          if (apiPP != null && apiPP > 0) return apiPP.toStringAsFixed(2);
          final double uP = double.tryParse(origUnitPrice) ?? 0.0;
          final int pcs = (e.pieces?.toInt() ?? 1);
          return (uP * (pcs > 0 ? pcs : 1)).toStringAsFixed(2);
        })();

        final String effectivePackPrice = (() {
          if (e.displayPrice != null &&
              (e.packtype == 'Pack' ||
                  item.isPack == true ||
                  e.saleBy == 'Pack')) {
            final double uP = double.tryParse(e.displayPrice!) ??
                (double.tryParse(origUnitPrice) ?? 0.0);
            final int pcs = (e.pieces?.toInt() ?? 1);
            return (uP * (pcs > 0 ? pcs : 1)).toStringAsFixed(2);
          }
          return origPackPrice;
        })();

        final String effectiveUnitPrice = e.displayPrice ?? origUnitPrice;

        if (item.isPromo == true) {
          bool isBundle =
              item.promoMsg != null && item.promoMsg!.startsWith("Bundle");

          if (isBundle) {
            print('isbundle');
            return SendCartData(
              productId: e.productId ?? '',
              variantId: e.variationId ?? '',
              pack: packValue,
              price: effectiveUnitPrice,
              packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
              discount: combinedDiscount,
              quantity: e.count.toInt(),
              variantName: e.variationName ?? '',
              maxDiscount: e.maxDiscount?.toInt(),
              isPromo: true,
              promoCode: item.promoCode ?? '',
              promoMsg: "Bundle: ${e.variationName}",
              isBundle: isBundle,
              bundleDetails: isBundle ? "Bundle: ${e.variationName}" : null,
              customerDiscount: item.CustomerDiscount,
              promoDiscount: combinedPromoDiscount,
              initialCount: e.initialCount,
              taxAmount: item.taxAmount,
              unitPrice: effectiveUnitPrice,
              originalUnitPrice: origUnitPrice,
              originalPackPrice: origPackPrice,
              editedAmount: 0.0,
              customerDiscountPercentage: item.CustomerDiscount,
              isBulk: false,
            );
          } else {
            return SendCartData(
              productId: e.productId ?? '',
              variantId: e.variationId ?? '',
              pack: packValue,
              price: effectiveUnitPrice,
              packType: e.saleBy != 'Pcs' ? 'Pack' : 'Pcs',
              discount: combinedDiscount,
              quantity: e.count.toInt(),
              variantName: e.variationName ?? '',
              maxDiscount: e.maxDiscount?.toInt(),
              isPromo: true,
              promoCode: item.promoCode ?? '',
              promoMsg: item.promoMsg ?? '',
              customerDiscount: item.CustomerDiscount,
              promoDiscount: combinedPromoDiscount,
              initialCount: e.initialCount,
              taxAmount: item.taxAmount,
              unitPrice: effectiveUnitPrice,
              originalUnitPrice: origUnitPrice,
              originalPackPrice: origPackPrice,
              editedAmount: 0.0,
              customerDiscountPercentage: item.CustomerDiscount,
              isBulk: false,
            );
          }
        } else {
          print('bulk part check called');

          bool isBulkItem = false;
          String? currentBulkId = e.bulkId;
          String? idToSendToBackend = currentBulkId;
          String finalPrice = effectiveUnitPrice;

          if (currentBulkId != null && currentBulkId.isNotEmpty) {
            isBulkItem = true;
            if (bulkDataList != null) {
              try {
                final matchingBulk = bulkDataList.firstWhere(
                  (element) => element.bulkId == currentBulkId,
                );
                idToSendToBackend =
                    matchingBulk.id?.toString() ?? currentBulkId;
                if (matchingBulk.volumePrice != null &&
                    matchingBulk.volumePrice!.isNotEmpty) {
                  finalPrice = matchingBulk.volumePrice!;
                }
              } catch (err) {
                print(
                    'Bulk ID $currentBulkId found but not matched in BulkData list: $err');
              }
            }
          }

          double editPriceDiscountAmt = 0.0;
          if (e.displayPrice != null) {
            final double origPrice =
                double.tryParse(origUnitPrice) ?? 0.0;
            final double newPrice =
                double.tryParse(e.displayPrice!) ?? origPrice;
            final int itemQtyFactor =
                (e.packtype == 'Pack' || item.isPack == true || e.saleBy == 'Pack')
                    ? (e.pieces?.toInt() ?? 1)
                    : 1;
            final double priceDiff = origPrice - newPrice;
            if (priceDiff > 0) {
              editPriceDiscountAmt =
                  priceDiff * itemQtyFactor * e.count.toDouble();
            }
          }
          final double totalCombinedDiscount =
              combinedDiscount + editPriceDiscountAmt;

          return SendCartData(
            productId: e.productId ?? '',
            variantId: e.variationId ?? '',
            pack: packValue,
            price: finalPrice,
            packType: isBulkItem
                ? 'Bulk'
                : (e.saleBy == 'Pack' ? 'Pack' : 'Pcs'),
            discount: totalCombinedDiscount,
            quantity: e.count.toInt(),
            variantName: e.variationName ?? '',
            customerDiscount: item.CustomerDiscount,
            promoDiscount: combinedPromoDiscount,
            isBulk: isBulkItem,
            bulkId: idToSendToBackend,
            initialCount: e.initialCount,
            taxAmount: item.taxAmount,
            itemNumbers: isBulkItem ? e.pieces?.toInt() : null,
            unitPrice: effectiveUnitPrice,
            bulkDiscountAmount: e.bulkDiscountAmount,
            originalUnitPrice: origUnitPrice,
            originalPackPrice: origPackPrice,
            editedAmount: editPriceDiscountAmt,
            customerDiscountPercentage: item.CustomerDiscount,
          );
        }
      }).toList()),
      total: finalAmount.value.toStringAsFixed(0),
    );

    List<String> variantIdsPass = [];
    final RegExp variantIdRegex = RegExp(r'Variant Id:\s*(\S+)');

    for (var item in allItems) {
      final variantId = item.detail.variationId ?? '';
      if (variantId.isNotEmpty && !variantId.contains("BUNDLE")) {
        variantIdsPass.add(variantId);
      }
      if (item.isPromo == true &&
          (item.promoMsg?.startsWith('Bundle') ?? false)) {
        final promoMsg = item.promoMsg ?? '';
        for (final m in variantIdRegex.allMatches(promoMsg)) {
          final extracted = m.group(1);
          if (extracted != null && extracted.isNotEmpty) {
            variantIdsPass.add(extracted);
          }
        }
      }
    }

    variantIdsPass = variantIdsPass.toSet().toList();

    final cartOrder = await ApiWorker().addToDraft(productBYData.toJson());
    print('add to draft datasssss:${productBYData.toJson()}');

    bool orderPlacedSuccessfully = false; // <-- TRACK success here

    if (cartOrder != null) {
      final order = CartOrderModel(
        customerId: customerId,
        salesmanId: currentSalesmanId,
        cartId:
            existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
        orderStatus: 4,
        draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
        selctedItemCount: 1,
        varientIds: variantIdsPass,
      );
      final completer = Completer<bool>();

      // REMOVED showSuccessFullDialogCtrl from here — handled in handleBackNavigation
      await ApiWorker().placeOrder(order, (statusCode, message, response) {
        print(
            'place order response: $statusCode, message: $message, response: $response');
        if (statusCode == 200) {
          completer.complete(true);
          // orderPlacedSuccessfully = true; 
      
          // showSuccessFullDialogCtrl(context: context);
        } else {
          showFaledDialogCtrl(context: context, customerId: customerId);
           completer.complete(false);
        }
      });
       orderPlacedSuccessfully = await completer.future;
    }

    CartDatabaseManager().cartItems.clear();
    CartDatabaseManager().clearCart(customerId: customerId);
    return orderPlacedSuccessfully; // <-- true only if API returned 200
  }
}

//   Future<bool> processCartBeforeNavigation({
//   required BuildContext context,
//   required String customerId,
//   List<BulkData>? bulkDataList,
// }) async {
//   print('process navigation started');

//   final connectivityService = ConnectivityService();
//   final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

//   final Map<String, CartItem> itemMap = {};

//   final draftItems = CartDatabaseManager()
//       .draftBox
//       .values
//       .where((e) => e.customerId == customerId)
//       .toList();
//   final cartItems = CartDatabaseManager()
//       .cartItems
//       .where((e) => e.customerId == customerId)
//       .toList();

//   for (var item in draftItems) {
//     if(item.detail.count <= 0) continue;

//     final key = "${item.detail.variationId}_${item.isPromo ?? false}";
//     itemMap[key] = item;
//   }

//   for (var item in cartItems) {
//     if(item.detail.count <= 0) continue;
//     final key = "${item.detail.variationId}_${item.isPromo ?? false}";
//     if (!itemMap.containsKey(key)) {
//       itemMap[key] = item;
//     }
//   }

//   final allItems = itemMap.values.toList();
//   if (allItems.isEmpty) {
//      print("Cart is empty, nothing to save to draft.");
     
//      CartDatabaseManager().cartItems.clear();
//      CartDatabaseManager().clearCart(customerId: customerId);
//      return true; 
//   }

//   allItemsTotalSave.value = Utils().calculateSubtotal(allItems);

//   final isOnline = await connectivityService.isOnline();

//   if (!isOnline) {
//     final List<Detail> detail = allItems.map((e) => e.detail).toList();
//     await CartDatabaseManager().saveDraftOffline(
//       customerId: customerId,
//       salesmanId: currentSalesmanId,
//       totalAmount: finalAmount.value,
//       details: detail,
//       customerName: selectedCustomerName.value,
//       customerMobile: selectedCustomerMobileNo.value,
//       customerEmail: selectedCustomerEmail.value,
//       customerImageUrl: selectedCustomerImageUrl.value,
//       allItemsTotal: allItemsTotalSave.value,
//     );

//     CartDatabaseManager().clearCart(customerId: customerId);
//     return false;
//   } else {
//     final cartDetails =
//         await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
//     await Future.delayed(const Duration(seconds: 1));

//     final firstOrder = cartDetails.isNotEmpty
//         ? cartDetails.last
//         : {'cart_id': '', 'draft_id': ''};

//     final existingCartId = firstOrder['cart_id'] ?? '';
//     final existingDraftId = firstOrder['draft_id'] ?? '';

//     final productBYData = AddToCartModel(
//       customerId: customerId,
//       salesmanId: currentSalesmanId,
//       cartId: existingCartId,
//       cartList: await Future.wait(allItems.map((item) async {
//         final e = item.detail;
//         print('full detailssssss:${e.toJson()}');
        
//         String packValue;
//         if (e.bulkId != null && e.bulkId!.isNotEmpty) {
//           packValue = e.pieces.toString(); 
//         } else {
//           packValue = e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();
//         }

//         // --- CALCULATE COMBINED DISCOUNTS HERE ---
//         final double combinedDiscount = (item.totalDiscountAmount ?? 0).toDouble() + (item.flatDiscount ?? 0).toDouble() + (item.bogoDiscount ?? 0).toDouble();
//         final num combinedPromoDiscount = (item.tieredDiscount ?? 0) + (item.flatDiscount ?? 0) + (item.bogoDiscount ?? 0);

//         if (item.isPromo == true) {
//           bool isBundle =
//               item.promoMsg != null && item.promoMsg!.startsWith("Bundle");

//           if (isBundle) {
//             print('isbundle');
//             return SendCartData(
//                 productId: e.productId ?? '',
//                 variantId: e.variationId ?? '',
//                 pack: packValue,
//                 price: e.sellPrice.toString(),
//                 packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
//                 discount: combinedDiscount, // <-- Combined Discount
//                 quantity: e.count.toInt(),
//                 variantName: e.variationName ?? '',
//                 maxDiscount: e.maxDiscount?.toInt(),
//                 isPromo: true,
//                 promoCode: item.promoCode ?? '',
//                 promoMsg: "Bundle: ${e.variationName}",
//                 isBundle: isBundle,
//                 bundleDetails: isBundle ? "Bundle: ${e.variationName}" : null,
//                 customerDiscount: item.CustomerDiscount,
//                 promoDiscount: combinedPromoDiscount, // <-- Combined Promo Discount
//                 initialCount: e.initialCount,
//                 taxAmount: item.taxAmount,
//                 unitPrice: e.sellPrice.toString(),
//             );
//           } else {
//             return SendCartData(
//                 productId: e.productId ?? '',
//                 variantId: e.variationId ?? '',
//                 pack: packValue,
//                 price: e.sellPrice.toString(),
//                 packType: e.saleBy != 'Pcs' ? 'Pack' : 'Pcs',
//                 discount: combinedDiscount, // <-- Combined Discount
//                 quantity: e.count.toInt(),
//                 variantName: e.variationName ?? '',
//                 maxDiscount: e.maxDiscount?.toInt(),
//                 isPromo: true,
//                 promoCode: item.promoCode ?? '',
//                 promoMsg: item.promoMsg ?? '',
//                 customerDiscount: item.CustomerDiscount,
//                 promoDiscount: combinedPromoDiscount, // <-- Combined Promo Discount
//                 initialCount: e.initialCount,
//                 taxAmount: item.taxAmount,
//                 unitPrice: e.sellPrice.toString(),
//             );
//           }
//         } 
//         else {
//           print('bulk part check called');
          
//           bool isBulkItem = false;
//           String? currentBulkId = e.bulkId; 
//           String? idToSendToBackend = currentBulkId; 
//           String finalPrice = e.sellPrice.toString(); 

//           if (currentBulkId != null && currentBulkId.isNotEmpty) {
//             isBulkItem = true;
//             if (bulkDataList != null) {
//               try {
//                 final matchingBulk = bulkDataList.firstWhere(
//                   (element) => element.bulkId == currentBulkId, 
//                 );

//                 idToSendToBackend = matchingBulk.id?.toString() ?? currentBulkId;

//                 if (matchingBulk.volumePrice != null &&
//                     matchingBulk.volumePrice!.isNotEmpty) {
//                   finalPrice = matchingBulk.volumePrice!;
//                 }
//               } catch (err) {
//                 print('Bulk ID $currentBulkId found but not matched in BulkData list: $err');
//               }
//             }
//           }

//           return SendCartData(
//               productId: e.productId ?? '',
//               variantId: e.variationId ?? '',
//               pack: packValue,
//               price: finalPrice, 
//               packType: isBulkItem
//                   ? 'Bulk'
//                   : (e.saleBy == 'Pack' ? 'Pack' : 'Pcs'),
//               discount: combinedDiscount, // <-- Combined Discount
//               quantity: e.count.toInt(),
//               variantName: e.variationName ?? '',
//               customerDiscount: item.CustomerDiscount,
//               promoDiscount: combinedPromoDiscount, // <-- Combined Promo Discount
//               isBulk: isBulkItem,
//               bulkId: idToSendToBackend, 
//               initialCount: e.initialCount,
//               taxAmount: item.taxAmount,
//               itemNumbers: isBulkItem ? e.pieces?.toInt() : null,
//               unitPrice: e.sellPrice.toString(),
//           );
//         }
   
//       }).toList()),
//       total: finalAmount.value.toStringAsFixed(0),
//     );

//     List<String> variantIdsPass = [];

//     final RegExp variantIdRegex = RegExp(r'Variant Id:\s*(\S+)');

//     for (var item in allItems) {
//       final variantId = item.detail.variationId ?? '';
//       if (variantId.isNotEmpty && !variantId.contains("BUNDLE")) {
//         variantIdsPass.add(variantId);
//       }

//       if (item.isPromo == true &&
//           (item.promoMsg?.startsWith('Bundle') ?? false)) {
//         final promoMsg = item.promoMsg ?? '';
//         for (final m in variantIdRegex.allMatches(promoMsg)) {
//           final extracted = m.group(1);
//           if (extracted != null && extracted.isNotEmpty) {
//             variantIdsPass.add(extracted);
//           }
//         }
//       }
//     }

//     variantIdsPass = variantIdsPass.toSet().toList();

//     final cartOrder = await ApiWorker().addToDraft(productBYData.toJson());
//     print('add to draft datasssss:${productBYData.toJson()}');

//     if (cartOrder != null) {
//       final order = CartOrderModel(
//         customerId: customerId,
//         salesmanId: currentSalesmanId,
//         cartId: existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
//         orderStatus: 4,
//         draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
//         selctedItemCount: 1,
//         varientIds: variantIdsPass,
//       );

//       await ApiWorker().placeOrder(order, (statusCode, message, response) {
//         print(' place order response: $statusCode, message: $message, response: $response');
//         if (statusCode == 200) {
//           showSuccessFullDialogCtrl(context: context);
//         } else {
//           showFaledDialogCtrl(context: context, customerId: customerId);
//         }
//       });
//     }

//     CartDatabaseManager().cartItems.clear();
//     CartDatabaseManager().clearCart(customerId: customerId);
//     return true;
//   }
// }



// Future<bool> processCartBeforeNavigation({
//   required BuildContext context,
//   required String customerId,
//   List<BulkData>? bulkDataList,
// }) async {
//   print('process navigation started');

//   final connectivityService = ConnectivityService();
//   final currentSalesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

//   final Map<String, CartItem> itemMap = {};

//   final draftItems = CartDatabaseManager()
//       .draftBox
//       .values
//       .where((e) => e.customerId == customerId)
//       .toList();
//   final cartItems = CartDatabaseManager()
//       .cartItems
//       .where((e) => e.customerId == customerId)
//       .toList();

//   for (var item in draftItems) {
//     final key = "${item.detail.variationId}_${item.isPromo ?? false}";
//     itemMap[key] = item;
//   }

//   for (var item in cartItems) {
//     final key = "${item.detail.variationId}_${item.isPromo ?? false}";
//     if (!itemMap.containsKey(key)) {
//       itemMap[key] = item;
//     }
//   }

//   final allItems = itemMap.values.toList();

//   allItemsTotalSave.value = Utils().calculateSubtotal(allItems);

//   final isOnline = await connectivityService.isOnline();

//   if (!isOnline) {
//     final List<Detail> detail = allItems.map((e) => e.detail).toList();
//     await CartDatabaseManager().saveDraftOffline(
//       customerId: customerId,
//       salesmanId: currentSalesmanId,
//       totalAmount: finalAmount.value,
//       details: detail,
//       customerName: selectedCustomerName.value,
//       customerMobile: selectedCustomerMobileNo.value,
//       customerEmail: selectedCustomerEmail.value,
//       customerImageUrl: selectedCustomerImageUrl.value,
//       allItemsTotal: allItemsTotalSave.value,
//     );

//     CartDatabaseManager().clearCart(customerId: customerId);
//     return false;
//   } else {
//     final cartDetails =
//         await CartDatabaseManager().getDraftAndCartIdsFromApi(customerId);
//     await Future.delayed(const Duration(seconds: 1));

//     final firstOrder = cartDetails.isNotEmpty
//         ? cartDetails.last
//         : {'cart_id': '', 'draft_id': ''};

//     final existingCartId = firstOrder['cart_id'] ?? '';
//     final existingDraftId = firstOrder['draft_id'] ?? '';

//     final productBYData = AddToCartModel(
//       customerId: customerId,
//       salesmanId: currentSalesmanId,
//       cartId: existingCartId,
//       cartList: await Future.wait(allItems.map((item) async {
//         final e = item.detail;
//         print('full detailssssss:${e.toJson()}');
//         String packValue;
// if (e.bulkId != null && e.bulkId!.isNotEmpty) {
//   // If it's a bulk item, ALWAYS use pieces (e.g., 100), never count (1)
//   packValue = e.pieces.toString(); 
// } else {
//   packValue = e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();
// }

//         // final packValue =
//         //     e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();

//         if (item.isPromo == true) {
//           bool isBundle =
//               item.promoMsg != null && item.promoMsg!.startsWith("Bundle");

//           if (isBundle) {
//             print('isbundle');
//             return SendCartData(
//                 productId: e.productId ?? '',
//                 variantId: e.variationId ?? '',
//                 pack: packValue,
//                 price: e.sellPrice.toString(),
//                 packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
//                 discount: (item.totalDiscountAmount ?? 0).toDouble(),
//                 quantity: e.count.toInt(),
//                 variantName: e.variationName ?? '',
//                 maxDiscount: e.maxDiscount?.toInt(),
//                 isPromo: true,
//                 promoCode: item.promoCode ?? '',
//                 promoMsg: "Bundle: ${e.variationName}",
//                 isBundle: isBundle,
//                 bundleDetails: isBundle ? "Bundle: ${e.variationName}" : null,
//                 customerDiscount: item.CustomerDiscount,
//                 promoDiscount: item.tieredDiscount,
//                 initialCount: e.initialCount,
//                 taxAmount: item.taxAmount,
//                 flatDiscount: item.flatDiscount,
//                 );
//           } else {
//             return SendCartData(
//                 productId: e.productId ?? '',
//                 variantId: e.variationId ?? '',
//                 pack: packValue,
//                 price: e.sellPrice.toString(),
//                 packType: e.saleBy != 'Pcs' ? 'Pack' : 'Pcs',
//                 discount: (item.totalDiscountAmount ?? 0).toDouble(),
//                 quantity: e.count.toInt(),
//                 variantName: e.variationName ?? '',
//                 maxDiscount: e.maxDiscount?.toInt(),
//                 isPromo: true,
//                 promoCode: item.promoCode ?? '',
//                 promoMsg: item.promoMsg ?? '',
//                 customerDiscount: item.CustomerDiscount,
//                 promoDiscount: item.tieredDiscount,
//                 initialCount: e.initialCount,
//                 taxAmount: item.taxAmount,
//                 flatDiscount: item.flatDiscount,
//                 );
//           }
//         } 
//         else {
//           print('bulk part check called');
          
//           bool isBulkItem = false;
//           String? currentBulkId = e.bulkId; // e.g., "BULK_5"
//           String? idToSendToBackend = currentBulkId; 
//           String finalPrice = e.sellPrice.toString(); 

//           if (currentBulkId != null && currentBulkId.isNotEmpty) {
//             isBulkItem = true;
//             if (bulkDataList != null) {
//               try {
//                 final matchingBulk = bulkDataList.firstWhere(
//                   (element) => element.bulkId == currentBulkId, 
//                 );

//                 // --- THE FIX IS HERE ---
//                 // Grab the integer 'id' (e.g. 5) instead of 'bulkId' (e.g. "BULK_5")
//                 idToSendToBackend = matchingBulk.id?.toString() ?? currentBulkId;

//                 if (matchingBulk.volumePrice != null &&
//                     matchingBulk.volumePrice!.isNotEmpty) {
//                   finalPrice = matchingBulk.volumePrice!;
//                 }
//               } catch (err) {
//                 print('Bulk ID $currentBulkId found but not matched in BulkData list: $err');
//               }
//             }
//           }

//           return SendCartData(
//               productId: e.productId ?? '',
//               variantId: e.variationId ?? '',
//               pack: packValue,
//               price: finalPrice, 
//               packType: isBulkItem
//                   ? 'Bulk'
//                   : (e.saleBy == 'Pack' ? 'Pack' : 'Pcs'),
//               discount: (item.totalDiscountAmount ?? 0).toDouble(),
//               quantity: e.count.toInt(),
//               variantName: e.variationName ?? '',
//               customerDiscount: item.CustomerDiscount,
//               promoDiscount: item.tieredDiscount,
//               isBulk: isBulkItem,
//               bulkId: idToSendToBackend, // <-- Sending '5' instead of 'BULK_5'
//               initialCount: e.initialCount,
//               taxAmount: item.taxAmount,
//                itemNumbers: isBulkItem ? e.pieces?.toInt() : null,
//                     flatDiscount: item.flatDiscount,
//           );
//         }
   
//       }).toList()),
//       total: finalAmount.value.toStringAsFixed(0),
//     );

//     List<String> variantIdsPass = [];

//     final RegExp variantIdRegex = RegExp(r'Variant Id:\s*(\S+)');

//     for (var item in allItems) {
//       final variantId = item.detail.variationId ?? '';
//       if (variantId.isNotEmpty && !variantId.contains("BUNDLE")) {
//         variantIdsPass.add(variantId);
//       }

//       if (item.isPromo == true &&
//           (item.promoMsg?.startsWith('Bundle') ?? false)) {
//         final promoMsg = item.promoMsg ?? '';
//         for (final m in variantIdRegex.allMatches(promoMsg)) {
//           final extracted = m.group(1);
//           if (extracted != null && extracted.isNotEmpty) {
//             variantIdsPass.add(extracted);
//           }
//         }
//       }
//     }

//     variantIdsPass = variantIdsPass.toSet().toList();

//     final cartOrder = await ApiWorker().addToDraft(productBYData.toJson());
//     print('add to draft datasssss:${productBYData.toJson()}');

//     if (cartOrder != null) {
//       final order = CartOrderModel(
//         customerId: customerId,
//         salesmanId: currentSalesmanId,
//         cartId: existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
//         orderStatus: 4,
//         draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
//         selctedItemCount: 1,
//         varientIds: variantIdsPass,
//       );

//       await ApiWorker().placeOrder(order, (statusCode, message, response) {
//         if (statusCode == 200) {
//           showSuccessFullDialogCtrl(context: context);
//         } else {
//           showFaledDialogCtrl(context: context, customerId: customerId);
//         }
//       });
//     }

//     CartDatabaseManager().cartItems.clear();
//     CartDatabaseManager().clearCart(customerId: customerId);
//     return true;
//   }
// }



  void updateSelectedCustomer(
      {required String name, required String imageUrl, required String id}) {
    selectedCustomerName.value = name;
    selectedCustomerImageUrl.value = imageUrl;
    selectedCustomerId.value = id;
  }

  Future<List<ProductModel>> fetchProducts(String subCatId) async {
    try {
  print('fetch product called');
      if (subCatId.isEmpty) {
        isLoading.value = false;
        products.clear();
        return [];
      }

      if (subCatId.trim().isEmpty) {
        isLoading.value = false;
        products.clear();
        return [];
      }

      isLoading.value = true;

      List<ProductModel> fetchedProducts = await _apiWorker.getTempProduct(
        subCatId,
        companyid: SessionHelper.loginSavedData?.company_id ?? 0,
      );

      products.clear();
      products.addAll(fetchedProducts);
      isLoading.value = false;

      debugProductList();

      return fetchedProducts;
    } catch (e) {
      isLoading.value = false;
      products.clear();
      return [];
    }
  }

  Future<void> clearProductsForSubCategory(String subCatId) async {
    try {

      products.clear();

      await _apiWorker.clearProductsForSubCategory(subCatId);

    } catch (e) {
      //
    }
  }

  void clearAllProducts() {
    products.clear();
    isLoading.value = false;
  }

  Future<List<ProductModel>> reloadProductsForSubCategory(
      String subCatId) async {

    try {
      await _apiWorker.clearProductsForSubCategory(subCatId);

      return await fetchProducts(subCatId);
    } catch (e) {
      return [];
    }
  }

  // Method to debug product list
  void debugProductList() {
    final productIds =
        products.map((p) => p.productId).where((id) => id != null).toList();
    final uniqueIds = productIds.toSet();
    if (productIds.length != uniqueIds.length) {
      final duplicates = <String>[];
      for (var id in uniqueIds) {
        if (productIds.where((pid) => pid == id).length > 1) {
          duplicates.add(id!);
        }
      }
    }
  }

  Future<void> fetchCategoryData() async {
    try {
      CategoryModel? categoryModel;

      final List<ConnectivityResult> connectivityResult =
          await Connectivity().checkConnectivity();

      categoryModel = await _apiWorker.getCategory(
        companyid: SessionHelper.loginSavedData?.company_id ?? 0,
      );

      await storeCategoryData(categoryModel);

      categoryData.value = categoryModel;
    } catch (e) {
      rethrow;
    }
  }

  SubCategoryItem? getInitialSubCategoryIdAndName() {
    try {
      if (categoryData.value.data != null &&
          categoryData.value.data!.isNotEmpty) {
        var firstCategory = categoryData.value.data!.first;

        if (firstCategory.subCategoryItem != null &&
            firstCategory.subCategoryItem!.isNotEmpty) {
          var firstSubcategory = firstCategory.subCategoryItem!.first;

          selectedSubCategoryId.value = "${firstSubcategory.id}";

          return firstSubcategory;
        } else {
          return null;
        }
      }
      return null;
    } catch (e) {
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
      final categoryModel = await retrieveCategoryData();
      if (categoryModel != null) {
        return categoryModel;
      }
      throw Exception('No category data available');
    }
  }

  bool get isCategoriesAndProductsReady {
    return categoryData.value.data != null &&
        categoryData.value.data!.isNotEmpty &&
        selectedSubCategoryId.value.isNotEmpty &&
        selectedSubCategoryName.value.isNotEmpty;
  }

  Future<void> loadCategoriesAndDefaultProducts() async {
    try {
      debugCategoryData();

      if (isCategoriesAndProductsReady && products.isNotEmpty) {
        return;
      }

      await fetchCategoryData();
      debugCategoryData();

      if (categoryData.value.data == null || categoryData.value.data!.isEmpty) {
        return;
      }

      SubCategoryItem? initialSubCategory = getInitialSubCategoryIdAndName();
      if (initialSubCategory != null && initialSubCategory.id != null) {

        selectedSubCategoryName.value = initialSubCategory.subCategory ?? '';

        await fetchProducts(initialSubCategory.id.toString());

        if (categoryData.value.data != null &&
            categoryData.value.data!.isNotEmpty) {
          var firstCategory = categoryData.value.data!.first;
        }

        debugCategoryData();
      } else {
      }
    } catch (e) {
      //
    }
  }

  addTOServerCart(AddToCartModel data) async {
    await ApiWorker().addToCart(data.toJson());
  }

  Future addProductToCart(
      AddToCartModel savedData, ProductsController productsController) async {
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
    if (categoryData.value.data != null &&
        categoryData.value.data!.isNotEmpty) {
      if (categoryData.value.data!.first.subCategoryItem != null &&
          categoryData.value.data!.first.subCategoryItem!.isNotEmpty) {
      }
    }
  }

  Future<void> refreshProducts() async {
    try {
      if (selectedSubCategoryId.value.isNotEmpty) {
        await fetchProducts(selectedSubCategoryId.value);
      } else {
      }
    } catch (e) {
      //
    }
  }

  Future<bool> waitForCategories({int maxAttempts = 20}) async {
    int attempts = 0;
    while (!isCategoriesAndProductsReady && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 250));
      attempts++;
    }

    bool ready = isCategoriesAndProductsReady;
    return ready;
  }

  Future<void> checkCacheStatus() async {
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

      if (scidGroupBox.isNotEmpty) {
        for (var key in scidGroupBox.keys) {
          final group = scidGroupBox.get(key);
        }
      }

      if (productBox.isNotEmpty) {
        final allScids = productBox.values.map((p) => p.scid).toSet().toList();
      }

    } catch (e) {
      //
    }
  }

  Future<void> selectSubCategory(
      String subCategoryId, String subCategoryName) async {
    try {

      if (subCategoryId.isEmpty) {
        return;
      }

      if (subCategoryName.isEmpty) {
        return;
      }

      selectedSubCategoryId.value = subCategoryId;
      selectedSubCategoryName.value = subCategoryName;

      await fetchProducts(subCategoryId);

    } catch (e) {
      //
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

    if (categoryData.value.data != null) {
    }
    refresh();
  }

  RxList<ProductFrequencyData> productFrequencyList =
      <ProductFrequencyData>[].obs;

  Future<List<ProductFrequencyData>> loadProductFrequency() async {
    try {
      var response = await ApiWorker().getProductFrequency();
      if (response.data != null) {
        productFrequencyList.assignAll(response.data!);

      } else {
        productFrequencyList.clear();
      }
      refresh();
    } catch (error) {
      //
    }
    return productFrequencyList;
  }

  // FETCH PROMOTIONS
  final promotions = <PromotionReponse>[].obs;
  final isPromotionLoading = false.obs;

  Rx<PromotionReponse?> selectedPromotion = Rx<PromotionReponse?>(null);

  Future<void> fetchPromotions() async {
    try {
      isPromotionLoading.value = true;

      final result = await ApiWorker().getPromotions();

      promotions.assignAll(result);
    } catch (e) {
      promotions.clear();
    } finally {
      isPromotionLoading.value = false;
    }
  }

  void selectPromotion(PromotionReponse promo) {
    selectedPromotion.value = promo;
  }
}
