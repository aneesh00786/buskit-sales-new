// ignore_for_file: unused_local_variable, avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/backup_data_fun.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: implementation_imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'product_ui/product_responce/product_responce_temp.dart';

class InitialSubcategoryInfo {
  final String id;
  final String name;
  InitialSubcategoryInfo({required this.id, required this.name});
}

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
    log('Fetched stock value ${fetchedProducts.first.stock ?? ''}');
    log('Fetched detail stock value ${fetchedProducts.first.detail?.map(
          (e) => e.stock,
        ) ?? ''}');
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
  // Future<res.Response> deleteCartItem(
  //     String customerId, String cartId, String variationId) async {
  //   return await ApiWorker().deleteCartItem(cartId, variationId);
  // }

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
