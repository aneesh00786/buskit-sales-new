// ignore_for_file: unused_local_variable, avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/backup_data_fun.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_diloag_screen.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/response.dart' as res;
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
  //final ApiWorker _apiWorker = Get.find();
  var optionName = ''.obs;
  TextEditingController searchCustomerController = TextEditingController();
  Rx<CategoryModel> categoryData = CategoryModel().obs;
  RxList<ProductList> productListBackup = <ProductList>[].obs;
  RxList<ProductList> productList = <ProductList>[].obs;
  Rx<ProductResponceTemp> productListTemp = ProductResponceTemp().obs;
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// SINGLE [customerAndOrderData] CUSTOMER DATA
  Rx<CustomerAndOrderData> customerAndOrderData = CustomerAndOrderData().obs;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  /// SEARCH CUSTOMER
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
  @override
  onInit() {
    super.onInit();
    fetchCategoryData();
  }

  void closeDialog() {
    showDialog.value = false;
  }

  bool onReached(bool reached) {
    isReached.value = reached;
    return isReached.value;
  }

  void updateSelectedCustomer(
      {required String name, required String imageUrl, required String id}) {
    selectedCustomerName.value = name;
    selectedCustomerImageUrl.value = imageUrl;
    selectedCategoryId.value = id;
    log('Selected Customer Updated: $name, $imageUrl, $id');
  }

  void clearSelectedCustomer() {
    selectedCustomerName.value = '';
    selectedCustomerImageUrl.value = '';
    selectedCategoryId.value = '';
    log('Selected Customer Cleared');
  }

  String getFormattedCustomerName(String? fullname) {
    if (fullname == null || fullname.isEmpty) {
      return '';
    }
    return fullname.length > 15 ? '${fullname.substring(0, 15)}...' : fullname;
  }

  Future<List<ProductModel>> fetchProducts(String subCatId) async {
    isLoading.value = true;
    List<ProductModel> fetchedProducts =
        await ApiWorker().getTempProduct(subCatId);
    log('Fetched stock value ${fetchedProducts.first.stock??''}');
    log('Fetched detail stock value ${fetchedProducts.first.detail?.map((e) => e.stock,)??''}');
    products.value = fetchedProducts;
    isLoading.value = false;
    log('Final Products Length: ${products.length}');
    return fetchedProducts;
  }

  void updateFinalAmount(double amount) {
    finalAmount.value = amount;
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
        var firstSubcategory = firstCategory.subCategoryItem?.first;

        log("Fetching initial subcategory ID: ${firstSubcategory?.id}");
        log("Fetching initial subcategory name: ${firstSubcategory?.subCategory}");

        return firstSubcategory;
      }
      return null;
    } catch (e) {
      print("Error fetching initial subcategory details: $e");
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
        final convertedData = ApiService().castToStringDynamic(
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
  void updateProductList(List<ProductList> newData,
      {bool isBackupUpdate = false}) {
    if (isBackupUpdate) {
      productListBackup.clear();
      productListBackup.addAll(newData);
    }
    productList.clear();
    productList.addAll(loadAlredyAddedInCartProductCount(
        newData.map((e) => e).toSet().toList()));

    log("Product List ⬆⬆⬆⬆⬆⬆⬆ ${productList.length} ---- ${productListBackup.length}");
    log("Product List ⬆⬆⬆⬆⬆⬆⬆ ${productList.map((element) => element.variant?.map((e) => e.toJson()["quantity"]))} --BACKUP--> ${productListBackup.map((element) => element.variant?.map((e) => e.toJson()["quantity"]))}");

    refresh();
  }
  updateVariantData(int productListIndex, int variantIndex) {
    refresh();
  }
  changeCrossFadeState(CrossFadeState state) {
    crossFadeState = state;
    refresh();
  }

  get clearAllData {
    searchCustomerController.clear();
    categoryData.value = BackupDataFunction.getCategoryAndProductBackup!;
    customerAndOrderData.value = CustomerAndOrderData();
    refresh();
  }

  List<ProductList> loadAlredyAddedInCartProductCount(
      List<ProductList> newList) {
    List<ProductList> listConverted = [];
    log("ENterddddddddddd ${newList.length}");
    log("ENterddddddddddd ${customerAndOrderData.value.customerId}");

    if (customerAndOrderData.value.cart != null &&
        customerAndOrderData.value.cart!.isNotEmpty &&
        newList.isNotEmpty) {
      for (var product in newList) {
        for (var variant in product.variant!) {
          var cartItem = customerAndOrderData.value.cart?.firstWhere(
            (e) => e.variationId == variant.variationId,
            orElse: () => CustomerCart(),
          );
          variant.quntity = cartItem?.quantity ?? 0;
          log("Trueeeeeeee ${variant.quntity}");
          log("DATTATTAATA ${variant.productId}----${cartItem?.variationId}");
        }
        listConverted.add(product);
      }
      refresh();
    }
    log("💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨💨   ${newList.length}------${listConverted.length}");

    return listConverted.isNotEmpty ? listConverted : newList;
  }

  void updateCustomerAndOrderData(CustomerAndOrderData newData) {
    productList.clear();
    productListBackup.clear();
    categoryData.value = CategoryModel();
    customerAndOrderData.value = newData;
    categoryData.value =
        BackupDataFunction.getCategoryAndProductBackup ?? CategoryModel();
    refresh();
  }

  Future<CustomerCartData?> getCustomerCartData(String customerId) async {
    var data = await ApiWorker().getCustomerCart(customerId: customerId);
    if (data.data != null && data.data!.isNotEmpty) {
      return data.data!.first;
    }
    return null;
  }

  Future<OrderResponce?> getSingleCustomerOrderHistory(
      String customerId) async {
    var data =
        await ApiWorker().getSingleCustomerOrderHistory(customerId: customerId);
    if (data.data != null && data.data!.isNotEmpty) {
      return data;
    }
    return null;
  }

  Future<void> placeOrder(CartOrderModel cartOrder) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    cartOrder.companyId = companyId;

    try {
      log('Assigned companyId: ${cartOrder.companyId}');
      log('Place Order Payloadssss: ${cartOrder.toJson()}');

      final response = await Dio().post(
        "http://16.50.232.153:3000/place_order",
        data: cartOrder.toJson(),
      );

      log('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        log('Order placed successfully: ${response.data}');
      } else {
        log('Failed to place order: ${response.data}');
      }
    } catch (e) {
      log('Error placing order: $e');
    }
  }

  // purchasePruduct(CartOrderModel cartOrder) async {
  //   await _apiWorker
  //       .buyProduct(cartOrder.toJson())
  //       .then((value) {
  //     if (value.statusCode == 200) {
  //       NkCommonFunction.showSimpleToast(
  //           value.data["message"] ?? orderPlacedSuccessfully,
  //           color: Colors.lightGreen);
  //       log('The Purchase Product Has veen Sucessfull');
  //     }
  //   }).onError((error, stackTrace) {
  //     return Future.error(error.toString());
  //   });
  //   Get.back();
  // }
  sendDraftPruduct(BuyProductResponce buyProductResponce) async {
    await ApiWorker()
        .saveAsDraftProduct(
            purchaseProductSendData(buyProductResponce, isDraft: true))
        .then((value) {
      if (value.statusCode == 200) {
        NkCommonFunction.showSimpleToast(
            value.data["message"] ?? orderAddedInDraft,
            color: Colors.lightGreen);
      }
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });

    Get.back();
  }

  setUpdatePruductPrise(
      {required String productId,
      required String variationId,
      required String cartId,
      required String price,
      required String reason}) async {
    await ApiWorker()
        .setUpdateProductPrice(updateProductPriceMap(
            productId: productId,
            variationId: variationId,
            cartId: cartId,
            price: price,
            reason: reason))
        .then((value) {
      if (value.statusCode == 200) {
        NkCommonFunction.showSimpleToast(
            value.data["message"] ?? orderAddedInDraft,
            color: Colors.lightGreen);
      }
    }).onError((error, stackTrace) {
      return Future.error(error.toString());
    });
  }

  Map<String, dynamic> purchaseProductSendData(
      BuyProductResponce buyProductResponce,
      {bool isDraft = false}) {
    if (isDraft == false) {
      return buyProductResponce.toJson();
    } else {
      return buyProductResponce.toJson();
    }
  }

  Map<String, dynamic> updateProductPriceMap(
      {required String productId,
      required String variationId,
      required String cartId,
      required String price,
      required String reason}) {
    return {
      "product_id": productId,
      "variation_id": variationId,
      "cart_id": cartId,
      "price": price,
      "reason": reason,
    };
  }

  Future<res.Response> deleteCartItem(
      String customerId, String cartId, String variationId) async {
    return await ApiWorker().deleteCartItem(cartId, variationId);
  }

  // Future<List<ProductList>> loadDataOfProduct() async {
  //   var data = await _apiWorker.getTempProduct();
  //   productListTemp.value = data;
  //   log('loadDataOfProduct${data}');
  //   log('Product List Length: ${productList.length}');
  //   for (var category in categoryData.value.data!) {
  //     if (category.subCategoryItem != null) {
  //       for (var subCategory in category.subCategoryItem!) {
  //         data.newarray!.forEach((element) {
  //           if (subCategory.id == element.scid) {
  //             subCategory.productList = element.productList;
  //           }
  //         });
  //       }
  //     }
  //   }
  //   BackupDataFunction.categoryAndProductBackup = categoryData.value;
  //   updateProductList(
  //       categoryData.value.data![selectedCategoryIndex.value]
  //               .subCategoryItem?[selectedSubCategoryIndex.value].productList ??
  //           [],
  //       isBackupUpdate: true);

  //   refresh();

  //   return productList;
  // }

  addTOServerCart(AddToCartModel data) async {
    await ApiWorker().addToCart(data.toJson());
    //  .then((value) async {
    // if (value?.statusCode == 200) {
    //  // await productsController.loadSelectedCustomer(customerID);
    //     log('Data added Success');
    //   // log("Past Changed List ${productList.length}");
    //   // log("Past Bakup Changed List ${productListBackup.length}");
    //   // updateProductList(productsController.productListBackup);
    //   // log("Current Changed List ${productList.length}");
    //   // log("Current Bakup Changed List ${productListBackup.length}");

    //   //productsController.btnController.success();
    //   //  NkCommonFunction.showSuccessSnakBar(res.data["message"] ?? "Success");

    //   // if (isChatDiloagShow) {
    //   //   Get.dialog(CartDiloagScreen(productsController: productsController))
    //   //       .then((value) async {
    //   //     //await productsController.loadSelectedCustomer(customerID);
    //   //   });
    //   // } else {
    //   //   Get.back();
    //   // }
    // }
    // }).catchError((error) {
    //   log("Response ${error}");
    // });

    /* catch (error) {
      productsController.btnController.error();
      productsController.btnController.reset();
      return Future.error(error.toString());
    }*/
  }

  Future addProductToCart(
      AddToCartModel savedData, ProductsController productsController) async {
    log("SubCategory with match  ${productsController.selectedSubCategoryId.value}");
    return await addTOServerCart(
      //customerAndOrderData.value.customerId!,
      savedData,
      //productsController
    );
  }

  Future<CustomerAndOrderData> loadSelectedCustomer(String customerId) async {
    var data = await ApiWorker()
        .getSingleCustomer(customerId)
        .onError((error, stackTrace) {
      return Future.error(error.toString());
    });
    updateCustomerAndOrderData(data);
    //var listData = await loadDataOfProduct();

    //refresh();
    return data;
  }

  /* Future<List<ProductBuyData>> get loadDataForOfflineDataBase async {
    var listData =
        await DatabaseHelper.getAllData(collumName: SqlDatabaseKey.buyProduct);
    cartAddedList.assignAll(listData
        .map((e) => ProductBuyData.fromJson(jsonDecode(jsonEncode(e))))
        .toList());
    log("CHART DATA ${cartAddedList.map((element) => element.toJson()).toList()}");
    return cartAddedList;
  }*/

  Future searchCustomer(String search) async {
    var data =
        await ApiWorker().searchCustomer(search).onError((error, stackTrace) {
      return Future.error(error.toString());
    });
    searchData.assignAll(data.data!);
  }

  Widget searchCustomerWidget(SearchData customerSearchData) {
    return Row(children: [
      ClipOval(
        child: MyNetworkImage(
          imageUrl: customerSearchData.imageUrl ?? '',
          height: AppDimensions.instance!.height * 0.06,
          width: AppDimensions.instance!.height * 0.06,
        ),
      ),
      nkSmallSizeBox(),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyRegularText(
              label: customerSearchData.fullname ?? '',
            ),
            MyRegularText(
              label: customerSearchData.mobileno ?? '',
            ),
            MyRegularText(
              label: customerSearchData.email ?? '',
            ),
          ])
    ]);
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
