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
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: implementation_imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'product_ui/product_responce/product_responce_temp.dart';

class ProductsController extends GetxController {
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
  RxString selectedCustomerId = "".obs;
  var finalAmount = 0.0.obs;
  var showDialog = false.obs;
  void closeDialog() {
    showDialog.value = false;
  }

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
        offlineMode1(context);
        CartDatabaseManager().cartItems.clear();
        CartDatabaseManager().clearCart(customerId: customerId);
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
          Navigator.pop(context);
          if (statusCode == 200) {
            showSuccessFullDialogCtrl(
              context: context,
            );
            CartDatabaseManager().cartItems.clear();
            CartDatabaseManager().clearCart(customerId: customerId);
          } else {
            showFaledDialogCtrl(context: context, customerId: customerId);
          }
        });
      }
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
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
        offlineDialog(context);
        Future.delayed(const Duration(milliseconds: 300), () {
          homeController.sidebarXController.selectIndex(0);
          homeController.selectedIndex.value = 0;
          Get.toNamed(AppRoutes.dashboard, id: 2);
          selectedCustomerName.value = '';
          selectedCustomerImageUrl.value = '';
        });
        CartDatabaseManager().cartItems.clear();
        CartDatabaseManager().clearCart(customerId: customerId);
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
        selectedCustomerName.value = '';
        selectedCustomerImageUrl.value = '';
      });
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
    } else if (toDash) {
      log('Log 3');
      Future.delayed(const Duration(milliseconds: 300), () {
        homeController.sidebarXController.selectIndex(0);
        homeController.selectedIndex.value = 0;
        Get.toNamed(AppRoutes.dashboard, id: 2);
        selectedCustomerName.value = '';
        selectedCustomerImageUrl.value = '';
      });
      CartDatabaseManager().cartItems.clear();
      CartDatabaseManager().clearCart(customerId: customerId);
      Navigator.pop(context);
    } else {
      log('Log 4');
      Navigator.pop(context);
      CartDatabaseManager().cartItems.clear();
    }
  }

  void updateSelectedCustomer(
      {required String name, required String imageUrl, required String id}) {
    selectedCustomerName.value = name;
    selectedCustomerImageUrl.value = imageUrl;
    selectedCustomerId.value = id;
    log('Selected Customer Updated: $name, $imageUrl, $id');
  }

  Future<List<ProductModel>> fetchProducts(String subCatId) async {
    isLoading.value = true;
    List<ProductModel> fetchedProducts =
        await ApiWorker().getTempProduct(subCatId);

    if (fetchedProducts.isNotEmpty) {
      log('Fetched stock value ${fetchedProducts.first.stock ?? ''}');
      log('Fetched detail stock value ${fetchedProducts.first.detail?.map(
        (e) => e.stock,
      )}');
    } else {
      log('Fetched products list is empty.');
    }

    products.value = fetchedProducts;
    isLoading.value = false;
    log('Final Products Length: ${products.length}');
    return fetchedProducts;
  }

  Future<void> fetchCategoryData() async {
    CategoryModel? categoryModel;
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      categoryModel = await retrieveCategoryData();
      log('Retrieved from Hive : ${categoryModel?.data?.length}');
    } else {
      categoryModel = await ApiWorker().getCategory();
      await storeCategoryData(categoryModel);
      log('DataStored in Hive : ${categoryModel.data?.length}');
    }
    if (categoryModel != null) {
      categoryData.value = categoryModel;
    } else {
      log('No data available to display');
      throw Exception('No data available');
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
          log("Fetching initial subcategory ID: ${firstSubcategory.id}");
          log("Fetching initial subcategory name: ${firstSubcategory.subCategory}");
          return firstSubcategory;
        }
      }
      log("No subcategory found. Returning null.");
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
      try {
        final convertedData = LocalStorage().castToStringDynamic(
          Map<String, dynamic>.from(jsonString),
        );
        return CategoryModel.fromJson(convertedData);
      } catch (e) {
        log("Error converting category data: $e");
        return null;
      }
    }
    return null;
  }

  Future<CategoryModel> loadDataOfCategories() async {
    try {
      final categoryModel = await ApiWorker().getCategory();
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

  Future<Set<CategoryModel>> get loadDataOfCategory async => {
        categoryData.value = await ApiWorker().getCategory(),
      };
  void updateCustomerAndOrderData(CustomerAndOrderData newData) {
    productList.clear();
    productListBackup.clear();
    categoryData.value = CategoryModel();
    customerAndOrderData.value = newData;
    categoryData.value =
        BackupDataFunction.getCategoryAndProductBackup ?? CategoryModel();
    refresh();
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
}
