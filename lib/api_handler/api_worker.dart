import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/today_tasks_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_total_sale_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_action_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../common/pagination_model.dart';
import '../ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import '../ui/view/ui/auth/auth_model/login_responce.dart';

class ApiWorker with ApiConstants {
  late DioClient dio;
  Dio dio1 = Dio();
  ApiWorker() {
    dio = DioClient();
  }
  final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  final targetType = SessionHelper.settingsData
          ?.firstWhere(
            (setting) => setting.key == 'targetType',
            orElse: () => AllCompanySettingsData(
              key: 'targetType',
              value: '',
            ),
          )
          .value ??
      '';

  Future<LoginResponce?> loginApi(String email, String password) async {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };
    try {
      final response = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.login}',
        data: data,
      );
      log("Request Data: $data");
      log("Response Data: ${response.data}");
      if (response.data != null) {
        final status = response.data['status'];
        final message = response.data['message'] ?? 'No message available';
        final statusCode = response.data['status_code'];
        if (status == false) {
          log("Login Failed: $message");
          return LoginResponce(
            status: false,
            message: message,
            statusCode: statusCode,
          );
        }
        log("Login Successful: $message");
        return LoginResponce.fromJson(response.data);
      } else {
        log("Error: Invalid response data");
        return null;
      }
    } on DioException catch (error) {
      log("DioError: ${error.message}");
      log("DioError Response Data: ${error.response?.data}");
      log("DioError Status Code: ${error.response?.statusCode}");
      final errorData = error.response?.data;
      final statusCode = error.response?.statusCode;
      final message = errorData?['message'] ?? error.message;
      return LoginResponce(
        status: false,
        message: message,
        statusCode: statusCode,
      );
    } catch (e) {
      log("General Error: $e");
      return LoginResponce(
        status: false,
        message: 'An unexpected error occurred.',
        statusCode: null,
      );
    }
  }

  Future<List<Currency>> getCurrencyList() async {
    log(companyId.toString());
    try {
      final response = await dio
          .getbycustom('http://16.50.232.153:3000/api/get_currencylist')
          .onError((DioError error, stackTrace) {
        log(error.toString());
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      List<dynamic> data = response.data;
      List<Currency> currencyList =
          data.map((json) => Currency.fromJson(json)).toList();

      return currencyList;
    } catch (e) {
      log("Error fetching currency list: $e");
      rethrow;
    }
  }

  Future<LeadsCountData> fetchLeadsCount() async {
    final Map<String, dynamic> requestData = {
      'companyId': companyId,
      'salesman_id': salesmanId,
    };

    final response = await dio
        .postbycustom(
      ApiConstants.fetchLeadsCount,
      data: requestData,
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return LeadsCountData.fromJson(response.data);
  }

  Future<List<AllCompanySettingsData>?> fetchAllSettings(int company_Id) async {
    try {
      log('Fetching settings for company ID: $company_Id');
      final response = await dio1.post(
        "${ApiConstants.baseUrl}${ApiConstants.fetchAllSetting}",
        data: {
          "compay_id": "$company_Id",
        },
      );
      log("Fetch Settings URL : ${ApiConstants.baseUrl}${ApiConstants.fetchAllSetting}");
      log("CompanyId in Settings Function : $company_Id");
      List<dynamic> dataList = response.data['data'] ?? [];
      List<AllCompanySettingsData> settingsList = dataList
          .map((item) => AllCompanySettingsData.fromJson(item))
          .toList();
      await SessionHelper().setSettingsData(settingsList);
      log('Settings fetched and saved: $settingsList');
      return settingsList;
    } on DioException catch (dioError) {
      log("Dio error of Settings: ${dioError.response?.data}");
      return Future.error(DioExceptionHandler.fromDioError(dioError));
    } catch (e) {
      log("Error fetching settings: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchSalesmanTopBarData(
      String monthName, int tabStatus) async {
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}${ApiConstants.salesman_dash_navcontents}';
      log('API URL of TopTab: $apiUrl');

      final requestPayload = {
        "companyId": companyId,
        "salesman_id": salesmanId,
        "year": 2024,
        "month": monthName,
        "status_of_tile": tabStatus,
      };

      Response response = await dio1.post(apiUrl, data: requestPayload);

      if (response.statusCode == 200) {
        log('Response Data: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        log("Failed to fetch data. Status: ${response.statusCode}, Message: ${response.statusMessage}");
        return null;
      }
    } on DioException catch (dioError) {
      final requestPayloadss = {
        "companyId": companyId,
        "salesman_id": salesmanId,
        "year": 2024,
        "month": monthName,
        "status_of_tile": tabStatus,
      };

      log('Request Body : $requestPayloadss');
      log("Dio Error: ${dioError.response?.data ?? dioError.message}");
      return null;
    } catch (e) {
      log("Unexpected Error: $e");
      return null;
    }
  }

Future<PerformanceData?> fetchSalesmanPerformanceData({
  required String monthName,
  required int year,
  int? compId,
  String? salesId,
  required bool isfromLogin,
}) async {
  const apiUrl = '${ApiConstants.baseUrl}${ApiConstants.salesman_dashview}';
  final requestPayload = {
    "companyId": isfromLogin ? compId : companyId,
    "salesman_id": isfromLogin ? salesId : salesmanId,
    "year": year,
    "month": monthName,
    "targetType": targetType,
  };
  final cacheKey = 'performance_data_${salesmanId}_${year}_$monthName';
  final performanceBox = Hive.box('performanceBox');
  log('Api URL for performance: $apiUrl');
  log('Request body fetchSalesmanPerformance: $requestPayload');
  try {
    Response response = await dio1.post(
      apiUrl,
      data: requestPayload,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data['data'];
      log('Performance Response: $jsonData');
      await performanceBox.put(cacheKey, jsonData);

      return PerformanceData.fromJson(jsonData);
    } else {
      log("Failed to load data: ${response.statusCode} ${response.statusMessage}");
      final cachedData = performanceBox.get(cacheKey);
      if (cachedData != null) {
        log('Using cached data for key: $cacheKey');
        final castedData = ApiService().castToStringDynamic(cachedData);
        return PerformanceData.fromJson(castedData);
      } else {
        log("No cached data available.");
        return null;
      }
    }
  } on DioException catch (dioError) {
    log("Dio error occurred: ${dioError.message}");
    if (dioError.response != null) {
      log("Dio error response: ${dioError.response?.data}");
      log("Dio error status code: ${dioError.response?.statusCode}");
    }
    final cachedData = performanceBox.get(cacheKey);
    if (cachedData != null) {
      log('Using cached data after API failure for key: $cacheKey');
      final castedData = ApiService().castToStringDynamic(cachedData);
      return PerformanceData.fromJson(castedData);
    } else {
      log("No cached data available.");
      return null;
    }
  } catch (e) {
    log("Error fetching salesman Performance: $e");
    return null;
  }
}

  Future<Response> updateCategoryTargetValue(
    String salesmanId,
    String month,
    String year,
    Map<dynamic, String> categoryData,
    Map<dynamic, String> weeklyTarget,
  ) async {
    log(companyId.toString());
    final response = await dio
        .postbycustom(ApiConstants.update_CategorytargetValue,
            data: ({
              "categories": categoryData,
              "weekly_target": weeklyTarget,
              "sales_id": salesmanId,
              "year": year,
              "month": month,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  /// ************************ DASHBOARD SECTION ***************** ///

  Future<DashboardResponse> dashboardData() async {
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    String createdToken = jsonMap['createdToken'];

    Map<String, dynamic> data = {
      'salesman_id': salesmanId,
      'start_date': "2024-09-30",
      'end_date': "2024-09-01",
    };

    Map<String, dynamic> headers = {
      'Authorization': 'Bearer $createdToken',
    };

    log('Created Token: $createdToken');
    log('Salesman ID: $salesmanId');

    try {
      final response = await dio.postbycustom(
        ApiConstants.dashboard_list,
        data: data,
        options: Options(headers: headers),
      );

      log('Dashboard API Response: ${response.data}');
      if (response.data['status_code'] == 400) {
        await SessionHelper().clearAll();
        Get.offAllNamed(AppRoutes.login);
        await Future.delayed(Duration(milliseconds: 500));
        _handleTokenExpiration();
        throw Exception('Session expired');
      }

      return DashboardResponse.fromJson(response.data);
    } catch (e) {
      log('Error fetching dashboard data: $e');
      rethrow;
    }
  }

  void _handleTokenExpiration() async {
    if (!Get.isDialogOpen!) {
      await Get.dialog(
        AlertDialog(
          title: Text("Session Expired"),
          content: Text("Your session has expired. Please log in again."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                Get.back();
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<FetchSpecificOrderInvoice> fetchSpecificOrderInvoice(
      String orderId) async {
    final response = await dio
        .postbycustom(ApiConstants.fetch_specific_order,
            data: FormData.fromMap({
              "order_id": orderId,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return FetchSpecificOrderInvoice.fromJson(response.data);
  }

  /// ************************ COMMON SEARCH SECTION ***************** ///

  Future<SearchResponce> searchCustomer(String searchText) async {
    Map<String, dynamic> data = {
      'customer_name': searchText,
    };
    final response = await dio
        .postbycustom(
      ApiConstants.search_customer,
      data: data,
    )
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return SearchResponce.fromJson(response.data);
  }

  /// ************************ CUSTOMER AND ORDER SECTION ***************** ///
  Future<CustomerAndOrderResponce> getCustomer() async {
    try {
      // Check for internet connectivity
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      bool hasInternet = !connectivityResult.contains(ConnectivityResult.none);

      if (hasInternet) {
        // If connected to the internet, fetch data from the API
        final response = await dio.postbycustom(
          ApiConstants.fetchcustomer,
          data: FormData.fromMap({
            "company_id": companyId,
            "salesman_id": salesmanId,
          }),
        );
        log('Company Id === $companyId');
        final customerData = CustomerAndOrderResponce.fromJson(response.data);
        await storeCustomerData(
            customerData); // Ensure to store this data in Hive
        return customerData;
      } else {
        log('No internet, fetching customer data from Hive...');
        final customerData = await retrieveCustomerData();
        if (customerData != null) {
          log('Loaded customer data from Hive');
          return customerData;
        } else {
          throw Exception('No customer data available offline');
        }
      }
    } catch (error) {
      return Future.error(
          'Failed to fetch customer data From API Worker: $error');
    }
  }

  Future<void> storeCustomerData(CustomerAndOrderResponce customerData) async {
    final box = await Hive.openBox('customerBox');
    await box.put('customerData', customerData.toJson());
    log('Customer data stored in Hive');
  }

  Future<CustomerAndOrderResponce?> retrieveCustomerData() async {
    final box = await Hive.openBox('customerBox');
    final jsonString = box.get('customerData');

    if (jsonString != null) {
      try {
        final convertedData = ApiService()
            .castToStringDynamic(Map<String, dynamic>.from(jsonString));
        return CustomerAndOrderResponce.fromJson(convertedData);
      } catch (e) {
        log("Error converting customer data: $e");
        return null;
      }
    }
    return null;
  }

  Future<RecentOrderCountResponse> fetchRecentOrderCount({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> requestData = {
      'companyId': companyId,
      "salesman_id": salesmanId,
    };
    log('Request Data : $requestData');
    if (startDate != null) {
      requestData['start_date'] = startDate;
    }
    if (endDate != null) {
      requestData['end_date'] = endDate;
    }

    final response = await dio
        .postbycustom(
      ApiConstants.recent_order_count,
      data: requestData,
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return RecentOrderCountResponse.fromJson(response.data);
  }

  Future<CustomerDashboardResponse> getCustomerDashboard(
    String customerId,
  ) async {
    final response = await dio
        .postbycustom(ApiConstants.customer_dashboard_list,
            data: FormData.fromMap(
                {"customer_id": customerId, "companyId": companyId}))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return CustomerDashboardResponse.fromJson(response.data);
  }

  Future<CustomerDashboardTotalSaleResponse> getCustomerDashboardTotalSale(
    String customerId,
    String year,
  ) async {
    final response = await dio
        .postbycustom(ApiConstants.customer_total_sale,
            data: FormData.fromMap({
              "customer_id": customerId,
              "year": year,
            }))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return CustomerDashboardTotalSaleResponse.fromJson(response.data);
  }
  Future<Response> buyProduct(Map<String, dynamic> sendData) async {
    final response = await dio
        .postbycustom(ApiConstants.place_order,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<CartOrderModel?> addToCart(Map<String, dynamic> sendData) async {
    sendData['companyId'] = companyId;
    log('Send Data with companyId: $sendData');

    try {
      final response = await dio
          .postbycustom(
        '${ApiConstants.add_to_cart}',
        data: FormData.fromMap(sendData),
      )
          .onError((DioError error, stackTrace) {
        log('Error: ${error.response?.data}');
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      if (response.statusCode == 200) {
        if (response.data['cart_id'] == null) {
          log('Cart ID is null in response.');
          return null;
        }
        log('Response Data: ${response.data}');
        return CartOrderModel.fromJson(response.data);
      } else {
        log('Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception in addToCart: $e');
      return null;
    }
  }

  Future<Response> deleteCartItem(String cartId, String variationId) async {
    final response = await dio
        .postbycustom(ApiConstants.cart_delete,
            data: FormData.fromMap(
                {"cart_id": cartId, "variation_id": variationId}))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> deleteCustomer(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.delete_customer,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<CustomerCartResponce> getCustomerCart({String? customerId}) async {
    log("Send DATA: ${FormData.fromMap({"customer_id": customerId}).fields}");
    final response = await dio
        .postbycustom(ApiConstants.fetch_cart,
            data: FormData.fromMap(
                {"customer_id": customerId, "companyId": companyId}))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return CustomerCartResponce.fromJson(response.data);
  }

  Future<OrderResponce> getSingleCustomerOrderHistory(
      {String? customerId}) async {
    log("Send DATA: ${FormData.fromMap({"customer_id": customerId}).fields}");
    final response = await dio
        .postbycustom(ApiConstants.customer_order_history,
            data: FormData.fromMap(
                {"customer_id": customerId, "companyId": companyId}))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderResponce.fromJson(response.data);
  }

  Future<Response> setUpdateProductPrice(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.update_product_price,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<CustomerAndOrderData> getSingleCustomer(String customerId) async {
    Map<String, dynamic> data = {
      'customer_id': customerId,
    };
    final response = await dio
        .postbycustom(
      ApiConstants.fetch_one_customer,
      data: data,
    )
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return CustomerAndOrderData.fromJson(
        (response.data["data"] as List).first as Map<String, dynamic>);
  }

  Future<Response> saveAsDraftProduct(Map<String, dynamic> sendData) async {
    log("Send DATA: ${sendData}");
    sendData['companyId'] = companyId;
    final response = await dio
        .postbycustom(ApiConstants.add_order_draft,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> assignVisit(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.add_events, data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  /// ************************ CATEGORY SECTION ***************** ///
  Future<CategoryModel> getCategory() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final box = await Hive.openBox('categoriesBox');
      final savedCategory = box.get('categoryItem');
      if (savedCategory != null) {
        try {
          final convertedData = ApiService()
              .castToStringDynamic(Map<String, dynamic>.from(savedCategory));
          return CategoryModel.fromJson(convertedData);
        } catch (e) {
          log("Error converting category data: $e");
          throw Exception('Failed to convert offline data');
        }
      } else {
        throw Exception('No data available offline');
      }
    } else {
      log('$companyId');
      final response = await dio.getbycustom(
        ApiConstants.fetchcategories,
        queryParameters: {"company_id": companyId},
      ).onError((DioError error, stackTrace) {
        log(error.toString());
        return Future.error(DioExceptionHandler.fromDioError(error));
      });
      final category = CategoryModel.fromJson(response.data);
      final box = await Hive.openBox('categoriesBox');
      await box.put('categoryItem', category.toJson());
      log('Category Data : $category');
      return category;
    }
  }

  /// ************************ PRODUCT SECTION ***************** ///
Future<List<ProductModel>> getTempProduct(String subCatId) async {
  log('=== getTempProduct called ===');
  List<ProductModel> allProducts = [];

  final connectivityResult = await Connectivity().checkConnectivity();
  bool hasNetwork = connectivityResult != ConnectivityResult.none;
  bool hasInternet = hasNetwork && await isInternetAvailable();
  log('Has Internet: $hasInternet');

  if (hasInternet) {
    try {
      final response = await dio.getbycustom(
        ApiConstants.fetchproduct,
        queryParameters: {"company_id": companyId},
      );

      if (response.statusCode == 200 && response.data['data'] is List) {
        for (var item in response.data['data']) {
          if (item['product'] is List) {
            allProducts.addAll((item['product'] as List)
                .map((productJson) => ProductModel.fromJson(productJson))
                .toList());
          }
        }
        log('Fetched Products from API: ${allProducts.length}');
        var productBox = await Hive.openBox('productBox');
        await productBox.put(
          'products',
          allProducts.map((product) => product.toJson()).toList(),
        );
        log('Products saved to Hive.');
      }
    } catch (e) {
      log('Error fetching products from API: $e');
    }
  } else {
    log('No internet. Fetching from Hive...');
  }

  try {
    var productBox = await Hive.openBox('productBox');
    var rawProductList = productBox.get('products');
    log('Raw Hive Data: $rawProductList');
    if (rawProductList is List) {
      allProducts = rawProductList
          .map((productJson) {
            if (productJson is Map) {
              return ProductModel.fromJson(ApiService().castToStringDynamic(productJson));
            }
            return null;
          })
          .whereType<ProductModel>()
          .toList();
    }
    log('Fetched Products from Hive: ${allProducts.length}');
  } catch (e) {
    log('Error fetching from Hive: $e');
  }

  List<ProductModel> filteredProducts = allProducts.where((product) {
    return product.scid == subCatId;
  }).toList();

  log('Filtered Products: ${filteredProducts.length}');
  return filteredProducts;
}


  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ************************ LEADS SECTION ***************** ///
  Future<Response> addCustomer(Map<String, dynamic> sendData) async {
    final response = await dio
        .postbycustom(ApiConstants.add_customer,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> updateCustomer(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.update_customer,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<LeadResponce> getLeadsData(String salesManId,
      {PaginationModel? paginationModel}) async {
    final requestData = FormData.fromMap({
      "page": paginationModel?.currentPage ?? "",
      "limit": paginationModel?.limit ?? '',
      "salesman_id": salesManId,
      "companyId": companyId,
    });

    log('Request Body FetchData: ${requestData.fields}');
    final cacheKey =
        'leads_data_${salesManId}_${paginationModel?.currentPage ?? ''}';
    final leadsBox = Hive.box('leadsBox');
    try {
      final cachedData = leadsBox.get(cacheKey);
      if (cachedData != null) {
        log('Using cached data for key: $cacheKey');
        final castedData = ApiService().castToStringDynamic(cachedData);
        return LeadResponce.fromJson(castedData);
      }
      final response = await dio.postbycustom(
        ApiConstants.fetch_leads,
        data: requestData,
      );
      log('Response Body Fetch Leads: ${response.data}');
      await leadsBox.put(cacheKey, response.data);
      return LeadResponce.fromJson(response.data);
    } on DioError catch (error) {
      log('DioError: $error');
      final cachedData = leadsBox.get(cacheKey);
      if (cachedData != null) {
        log('Using cached data after API failure for key: $cacheKey');
        final castedData = ApiService().castToStringDynamic(cachedData);
        return LeadResponce.fromJson(castedData);
      } else {
        throw Exception('Failed to fetch data and no cached data available.');
      }
    }
  }

  Future<LeadResponce> getLeadsRejectedData(
      {PaginationModel? paginationModel}) async {
    final response = await dio
        .postbycustom(ApiConstants.fetch_leads_reject,
            data: FormData.fromMap({
              "page": paginationModel?.currentPage ?? "",
              "limit": paginationModel?.limit ?? '',
              "salesman_id": salesmanId,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return LeadResponce.fromJson(response.data);
  }

  /// ******************** CALENDAR SECTION ******************/
  Future<List<EventData>> getCalendarEvents(
      Map<String, dynamic> sendData) async {
    sendData['companyId'] = SessionHelper.loginSavedData?.company_id;
    log('Request Data to Calender :$sendData');
    final response = await dio
        .postbycustom(ApiConstants.get_event, data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    if (response.data is Map<String, dynamic> &&
        response.data['data'] is List) {
      List<dynamic> eventsJson = response.data['data'];
      return eventsJson
          .map((event) => EventData.fromJson(event as Map<String, dynamic>))
          .toList();
    } else {
      log('Unexpected response format: ${response.data}');
      return [];
    }
  }

  Future<Response> handleLeadStatus(
      int? customerId, String? statusResponce) async {
    final response = await dio
        .postbycustom(ApiConstants.handle_lead,
            data: FormData.fromMap({
              "customer_id": customerId,
              "status": statusResponce,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    print(response);
    return response;
  }

  Future<TodayTasksResponse> getTodaySchedule(
      Map<String, dynamic> sendData) async {
    final response = await dio
        .postbycustom(ApiConstants.fetch_schedule_customer,
            showErrorSnakBar: false, data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error,
          showErrorSnakBar: false));
    });
    return TodayTasksResponse.fromJson(response.data);
  }

  Future<Response> updateSchedule(Map<String, dynamic> sendData) async {
    log("Send DATA: ${sendData}");
    final response = await dio
        .postbycustom(ApiConstants.schedule_customer,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(
        error,
      ));
    });
    return response;
  }

  Future<Response> updateEvent(Map<String, dynamic> sendData) async {
    log("Send DATA: ${sendData}");
    final response = await dio
        .postbycustom(ApiConstants.update_events,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(
        error,
      ));
    });
    return response;
  }

  /// ************************ ORDER SECTION *****************
  Future<OrderResponce> getOrdersData(
      {String? customerId,
      String? salesmanId,
      SearchModel? searchModel,
      PaginationModel? paginationModel}) async {
    print(
        "startDate++123++${searchModel?.startDate ?? ''}:${searchModel?.endDate ?? ''}");
    print(
        "data post ++ ++${salesmanId} : ${customerId ?? ''} : ${searchModel?.startDate} : ${searchModel?.endDate} : ${paginationModel?.limit.toString()} : ${paginationModel?.currentPage.toString()}");

    final response = await dio
        .postbycustom(
      ApiConstants.fetch_order,
      data: FormData.fromMap({
        "salesman_id": salesmanId,
        "customer_id": customerId ?? '',
        "start_date": searchModel?.startDate ?? '',
        "end_date": searchModel?.endDate ?? '',
        "limit": paginationModel?.limit.toString() ?? '',
        "page": paginationModel?.currentPage.toString() ?? ''
      }),
    )
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderResponce.fromJson(response.data);
  }

  Future<OptionOrderResponce> getAllOrderByStatus(
      {String? customerId,
      String? salesmanId,
      PaginationModel? paginationModel,
      SearchModel? searchModel,
      required String orderType}) async {
    final response = await dio
        .postbycustom(
      ApiConstants.fetch_all_order,
      data: FormData.fromMap({
        "salesman_id": salesmanId ?? '',
        "customer_id": customerId ?? '',
        "order_type": orderType,
        "limit": paginationModel?.limit.toString() ??
            PaginationModel().limit.toString(),
        "page": paginationModel?.currentPage.toString() ??
            PaginationModel().currentPage.toString(),
        "start_date": searchModel?.startDate ?? '',
        "end_date": searchModel?.endDate ?? '',
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OptionOrderResponce.fromJson(response.data);
  }

  /// ******************** PENDING PAYMENT ******************/
  Future<PendingPaymentResponse> getPendingPaymentData({
    SearchModel? searchModel,
    PaginationModel? paginationModel,
    required int chartIndex,
    String? salesmanId,
    int? compId,
  }) async {
    final requestData = {
      "chart_index": chartIndex,
      "start_date": searchModel?.startDate ?? '',
      "end_date": searchModel?.endDate ?? '',
      "limit": paginationModel?.limit.toString(),
      "page": paginationModel?.currentPage.toString(),
      "salesman_id": salesmanId ?? '',
      "companyId": compId,
    };
    log('Request Body of fetch Payment :$requestData');
    final cacheKey =
        'pending_payment_${chartIndex}_${salesmanId ?? ''}_${paginationModel?.currentPage ?? ''}';
    final pendingPaymentBox = Hive.box('pendingPaymentBox');

    try {
      log("Retrieving data from cache with key: $cacheKey");
      final cachedData = pendingPaymentBox.get(cacheKey);
      if (cachedData != null) {
        log("Cached data found: $cachedData");
        return PendingPaymentResponse.fromJson(
            ApiService().castToStringDynamic(cachedData));
      }
      final response = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.fetch_pending_payments}',
        data: FormData.fromMap(requestData),
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      log("API Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        log("Caching data with key: $cacheKey");
        await pendingPaymentBox.put(cacheKey, response.data);
        return PendingPaymentResponse.fromJson(response.data);
      } else {
        throw Exception(
            "Failed to fetch pending payment data. StatusCode: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      log("DioException occurred: $dioError");
      if (dioError.type == DioErrorType.connectionError ||
          dioError.type == DioErrorType.unknown) {
        log("Connection failed, attempting to fetch cached data for key: $cacheKey");
        final cachedData = pendingPaymentBox.get(cacheKey);
        if (cachedData != null) {
          log("Using cached data after connection failure: $cachedData");
          return PendingPaymentResponse.fromJson(
              ApiService().castToStringDynamic(cachedData));
        } else {
          throw Exception(
              'Connection failed, and no cached data is available.');
        }
      } else {
        throw dioError;
      }
    } catch (e) {
      log("Unexpected error occurred: $e");
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<IndividualPendingPaymentResponse> getAllPendingPaymentIndividual(
      {String? customerId}) async {
    final response = await dio
        .postbycustom(
      ApiConstants.get_all_pending_payment_individual,
      data: FormData.fromMap({
        "customer_id": customerId,
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return IndividualPendingPaymentResponse.fromJson(response.data);
  }

  //************************ RECENT ORDERS **************/
  Future<OrderCountResponse> getOrderCountData({
    SearchModel? searchModel,
  }) async {
    log("startDate++1234++Order count : ${searchModel?.startDate ?? ''}:${searchModel?.endDate ?? ''}");
    final response = await dio
        .postbycustom(
      ApiConstants.orders_count_get,
      data: FormData.fromMap({
        "start_date": searchModel?.startDate,
        "end_date": searchModel?.endDate,
        "companyId": companyId,
        "salesman_id": salesmanId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderCountResponse.fromJson(response.data);
  }

  // Future<OrderResponce> getRecentOrdersData({
  //   SearchModel? searchModel,
  //   int? order_status,
  // }) async {
  //   final requestBody = {
  //     "order_status": order_status,
  //     "start_date": searchModel?.startDate,
  //     "end_date": searchModel?.endDate,
  //     "companyId": companyId,
  //     "page": 1,
  //     "limit": 1000,
  //     "salesman_id": salesmanId,
  //   };
  //   log("Request Body: $requestBody");
  //   log("StartDate : ${searchModel?.startDate ?? ''}:${searchModel?.endDate ?? ''} :${order_status}:${companyId}");
  //   var hiveBox = await Hive.openBox('recentOrders');
  //   final isConnected = await ConnectivityService().isOnline();
  //   if (isConnected) {
  //     try {
  //       final response = await dio.postbycustom(
  //         ApiConstants.get_recent_order,
  //         data: FormData.fromMap(requestBody),
  //       );
  //       log("Response Data: ${response.data}");
  //       OrderResponce orderResponce = OrderResponce.fromJson(response.data);
  //       await hiveBox.put('recentOrders', response.data);
  //       log("Data saved to Hive.");

  //       return orderResponce;
  //     } on DioException catch (error, stackTrace) {
  //       log("DioException: ${error.toString()}");
  //       return Future.error(DioExceptionHandler.fromDioError(error));
  //     }
  //   } else {
  //     if (hiveBox.containsKey('recentOrders')) {
  //       log("Fetching data from Hive as there is no internet.");
  //       final cachedData = hiveBox.get('recentOrders');
  //       return OrderResponce.fromJson(cachedData);
  //     } else {
  //       log("No internet and no cached data available.");
  //       throw Exception("No internet connection and no cached data available.");
  //     }
  //   }
  // }

    Future<OrderResponce> getRecentOrdersData({
    SearchModel? searchModel,
    int? orderStatus,
  }) async {
    log(companyId.toString());
    final start = searchModel?.startDate?.isNotEmpty == true
        ? searchModel?.startDate
        : null; 
    final end =
        searchModel?.endDate?.isNotEmpty == true ? searchModel?.endDate : null;

    final response = await dio.postbycustom(
      ApiConstants.get_recent_order,
      data: {
        "order_status": orderStatus,
        "start_date": start,
        "end_date": end,
        "limit": 100,
        "page": 1,
        "companyId": companyId,
        "salesman_id": salesmanId
      },
    ).onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderResponce.fromJson(response.data);
  }


  Future<OrderProcessInvoice> getOrderProcessInvoiceData({
    String? orderId,
    int? orderStatus,
  }) async {
    final response = await dio
        .postbycustom(
      ApiConstants.order_process_invoice,
      data: FormData.fromMap({
        "order_id": orderId,
        "order_status": orderStatus,
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderProcessInvoice.fromJson(response.data);
  }

  Future<FetchSpecificOrder> fetchSpecificOrder({
    String? orderId,
  }) async {
    final response = await dio
        .postbycustom(
      ApiConstants.fetch_specific_order,
      data: FormData.fromMap({
        "order_id": orderId,
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return FetchSpecificOrder.fromJson(response.data);
  }

  Future<OrderProcessInvoice> loadWaitingForApproval({
    String? orderId,
  }) async {
    final response = await dio
        .postbycustom(
      ApiConstants.waiting_for_approval,
      data: FormData.fromMap({
        "order_id": orderId,
        "updatedOrders": [],
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderProcessInvoice.fromJson(response.data);
  }

  Future<ButtonAction> orderReject({
    String? orderId,
    String? rejectReason,
  }) async {
    final response = await dio
        .postbycustom(
      'http://16.50.232.153:3000/order_reject',
      data: FormData.fromMap({
        "order_id": orderId,
        "rejection_reason": rejectReason,
        //added
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return ButtonAction.fromJson(response.data);
  }

  Future<ButtonAction> orderAccept({
    String? orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      final response = await dio
          .postbycustom(
        'http://16.50.232.153:3000/order_accept_direct',
        data: {
          "order_id": orderId,
          "updatedOrders": updatedOrders,
          "companyId": companyId,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      )
          .onError((DioException error, stackTrace) {
        log(error.toString());
        return Future.error(throw DioExceptionHandler.fromDioError(error));
      });

      return ButtonAction.fromJson(response.data);
    } catch (e) {
      log('Error accepting order: $e');
      rethrow;
    }
  }

  Future<Response> sendMail({
    String? orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      final response = await dio
          .postbycustom(
        'http://16.50.232.153:3000/send_mail',
        data: {
          "order_id": orderId,
          "updatedOrders": updatedOrders,
          //added
          "companyId": companyId,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      )
          .onError((DioException error, stackTrace) {
        log(error.toString());
        return Future.error(throw DioExceptionHandler.fromDioError(error));
      });

      return response;
    } catch (e) {
      log('Error Sending mail : $e');
      rethrow;
    }
  }

  Future<Response> packedAndReadyAdd({
    String? cartId,
    String? orderId,
  }) async {
    final response = await dio
        .postbycustom(
      "http://16.50.232.153:3000/add_invoice",
      data: FormData.fromMap({
        "cart_id": cartId,
        "order_id": orderId,
        //added
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return response;
  }

  Future<ButtonAction> orderDeliver({
    String? orderId,
  }) async {
    final response = await dio
        .postbycustom(
      'http://16.50.232.153:3000/order_delivered',
      data: FormData.fromMap({
        "order_id": orderId,
        //added
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return ButtonAction.fromJson(response.data);
  }
}
