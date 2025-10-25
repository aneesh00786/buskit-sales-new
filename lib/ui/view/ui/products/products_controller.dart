// ignore_for_file: unused_local_variable, avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/backup_data_fun.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/utils/utils.dart';
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
  var showDialog = false.obs;
  void closeDialog() {
    showDialog.value = false;
  }

  RxBool isCartModified = false.obs;
  RxDouble allItemsTotalSave = 0.0.obs;

  // Fixed flat discount per customer (cart-level), applied at display time in cart UI
  final Map<String, double> flatDiscountByCustomer = {};

  List<CartItem> cartItems = [];
  List<CartItem> orderItems = [];
  List<CartItem> preorderItems = [];

  void clearCartItemsInController() {
    log("[clearCartItemsInController]");
    cartItems.clear();
    orderItems.clear();
    preorderItems.clear();
  }

  void clearCartItemsInControllerAndHive(String customerId) async {
    log('[ProductsController] clearCartItemsInControllerAndHive called for customerId=$customerId');
    await CartDatabaseManager().clearCartOnlyForCustomer(customerId);
    cartItems.clear();
    orderItems.clear();
    preorderItems.clear();
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

    if ((CartDatabaseManager().cartItems.isNotEmpty ||
            CartDatabaseManager().draftBox.isNotEmpty) &&
        customerId.isNotEmpty &&
        isCartModified.value) {
      Get.dialog(const Center(child: CircularProgressIndicator()));

      final wasOnline = await processCartBeforeNavigation(
        context: context,
        customerId: customerId,
      );
      if (toDash) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (wasOnline) {
          showSuccessFullDialog(
            context: context,
            imagePath: 'assets/images/Animation - 1726906882515.json',
            message: 'Your order has been successfully saved as Draft',
          );
        } else {
          offlineDialog(context);
        }

        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pop(context);
      } else {
        if (!wasOnline) {
          offlineMode1(context);
        }
        Navigator.pop(context);
      }
    } else if (toDash) {
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
      Navigator.pop(context);
    } else {
      CartDatabaseManager().cartItems.clear();
      Navigator.pop(context);
    }
    await Provider.of<CustomersProvider>(context, listen: false)
        .fetchOrdersForCustomDash(
      OrderStatus.draft,
      customerId,
    );
    CartDatabaseManager().getDraftItems();
    isCartModified.value = false;
  }

  Future<bool> processCartBeforeNavigation({
    required BuildContext context,
    required String customerId,
  }) async {

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
      final key = item.detail.variationId ?? '';
      itemMap[key] = item;
    }

    for (var item in cartItems) {
      final key = item.detail.variationId ?? '';
      if (!itemMap.containsKey(key)) {
        itemMap[key] = item;
      }
    }

    final allItems = itemMap.values.toList();

    allItemsTotalSave.value = Utils().calculateSubtotal(allItems);

    final Map<String, Detail> dedupedDetails = {};

    for (final item in allItems) {
      final key = item.detail.variationId ?? '';
      if (dedupedDetails.containsKey(key)) {
        dedupedDetails[key]!.count += item.detail.count;
      } else {
        dedupedDetails[key] = item.detail;
      }
    }

    final detail = dedupedDetails.values.toList();

    final isOnline = await connectivityService.isOnline();

    if (!isOnline) {
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

          final packValue =
              e.saleBy == 'Pack' ? e.pieces.toString() : e.count.toString();

          if (item.isPromo == true) {
            bool isBundle =
                item.promoMsg != null && item.promoMsg!.startsWith("Bundle");

            if (isBundle) {
              return SendCartData(
                productId: e.productId ?? '',
                variantId: e.variationId ?? '',
                pack: packValue,
                price: e.sellPrice.toString(),
                packType: e.saleBy == 'Pack' ? 'Pack' : 'Pcs',
                discount: e.discount ?? 0,
                quantity: e.count.toInt(),
                variantName: e.variationName ?? '',
                maxDiscount: e.maxDiscount?.toInt(),
                isPromo: true,
                promoCode: item.promoCode ?? '',
                promoMsg: "Bundle: ${e.variationName}",
                isBundle: isBundle,
                bundleDetails: isBundle ? "Bundle: ${e.variationName}" : null,
              );
            } else {
              return SendCartData(
                productId: e.productId ?? '',
                variantId: e.variationId ?? '',
                pack: packValue,
                price: e.sellPrice.toString(),
                packType: e.saleBy != 'Pcs' ? 'Pack' : 'Pcs',
                discount: e.discount ?? 0,
                quantity: e.count.toInt(),
                variantName: e.variationName ?? '',
                maxDiscount: e.maxDiscount?.toInt(),
                isPromo: true,
                promoCode: item.promoCode ?? '',
                promoMsg: item.promoMsg ?? '',
              );
            }
          } else {
            // ✅ Normal items
            return SendCartData(
              productId: e.productId ?? '',
              variantId: e.variationId ?? '',
              pack: packValue,
              price: e.sellPrice.toString(),
              packType: e.saleBy != 'Pcs' ? 'Pack' : 'Pcs',
              discount: e.discount ?? 0,
              quantity: e.count.toInt(),
              variantName: e.variationName ?? '',
            );
          }
        }).toList()),
        total: finalAmount.value.toStringAsFixed(0),
      );

      List<String> variantIdsPass = [];

// pattern to catch lines like “Variant Id: VARIATION31”
      final RegExp variantIdRegex = RegExp(r'Variant Id:\s*(\S+)');

      for (var item in allItems) {
        final variantId = item.detail.variationId ?? '';
        if (variantId.isNotEmpty && !variantId.contains("BUNDLE")) {
          variantIdsPass.add(variantId);
        }

        // also add any ids listed inside a bundle promoMsg
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

      if (cartOrder != null) {
        final order = CartOrderModel(
          customerId: customerId,
          salesmanId: currentSalesmanId,
          cartId: existingCartId.isNotEmpty ? existingCartId : cartOrder.cartId,
          orderStatus: 4,
          draftId: existingDraftId.isNotEmpty ? existingDraftId : '',
          selctedItemCount: 1,
          varientIds: variantIdsPass,
        );

        await ApiWorker().placeOrder(order, (statusCode, message, response) {
          if (statusCode == 200) {
            showSuccessFullDialogCtrl(context: context);
          } else {
            showFaledDialogCtrl(context: context, customerId: customerId);
          }
        });
      }

      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
      return true;
    }
  }

  void updateSelectedCustomer(
      {required String name, required String imageUrl, required String id}) {
    selectedCustomerName.value = name;
    selectedCustomerImageUrl.value = imageUrl;
    selectedCustomerId.value = id;
  }

  Future<List<ProductModel>> fetchProducts(String subCatId) async {
    try {

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
      log('clearProductsForSubCategory: Error occurred: $e');
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
      log('Error loading categories and default products: $e');
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
      log('refreshProducts: Error refreshing products: $e');
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
      log('Error checking cache status: $e');
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
      log("Error loading Product Frequency: $error");
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
      log('Error fetching promotions: $e');
      promotions.clear();
    } finally {
      isPromotionLoading.value = false;
    }
  }

  void selectPromotion(PromotionReponse promo) {
    selectedPromotion.value = promo;
  }
}
