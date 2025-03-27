import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/today_tasks_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_total_sale_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_action_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_table_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/pagination_model.dart';
import '../ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import '../ui/components/category_filter/product_list/model/discount_model.dart';
import '../ui/view/ui/auth/auth_model/login_responce.dart';

class ApiWorker with ApiConstants {
  late DioClient dio;
  Dio dio1 = Dio();
  final LocalStorage localStorage = LocalStorage();
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
          .onError((DioException error, stackTrace) {
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

  Future<List<AllCompanySettingsData>?> fetchAllSettings(int companyId) async {
    const cacheKey = 'all_settings_data';
    final settingsBox = Hive.box('settingsBox');
    log('Fetching settings for company ID: $companyId');
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;
    if (isOnline) {
      try {
        final response = await dio1.post(
          "${ApiConstants.baseUrl}${ApiConstants.fetchAllSetting}",
          data: {
            "compay_id": "$companyId",
          },
        );
        log("Fetch Settings URL: ${ApiConstants.baseUrl}${ApiConstants.fetchAllSetting}");
        log("Company ID in Settings Function: $companyId");
        List<dynamic> dataList = response.data['data'] ?? [];
        List<AllCompanySettingsData> settingsList = dataList
            .map((item) => AllCompanySettingsData.fromJson(item))
            .toList();
        log('Settings fetched from API: $settingsList');
        await settingsBox.put(
          cacheKey,
          settingsList.map((setting) => setting.toJson()).toList(),
        );
        log('Settings saved to Hive.');
        await SessionHelper().setSettingsData(settingsList);
        return settingsList;
      } on DioException catch (dioError) {
        log("Dio error of Settings: ${dioError.response?.data}");
        final cachedData = settingsBox.get(cacheKey);
        if (cachedData != null) {
          log('Fetched settings from Hive: $cachedData');
          final settingsList = (cachedData as List<dynamic>)
              .map((item) => AllCompanySettingsData.fromJson(LocalStorage()
                  .castToStringDynamic(Map<dynamic, dynamic>.from(item))))
              .toList();
          return settingsList;
        } else {
          log("No cached settings data available.");
          NkCommonFunction.showErrorSnakBar('No offline data available.');
        }
      } catch (e) {
        log("Error fetching settings: $e");
        NkCommonFunction.showErrorSnakBar(
            'An error occurred while fetching settings.');
      }
    } else {
      log("No internet. Fetching settings from Hive.");
      NkCommonFunction.showErrorSnakBar(
          'No internet connection. Unable to fetch data.');
    }
    try {
      final cachedData = settingsBox.get(cacheKey);
      if (cachedData != null) {
        log('Fetched settings from Hive: $cachedData');
        final settingsList = (cachedData as List<dynamic>)
            .map((item) => AllCompanySettingsData.fromJson(LocalStorage()
                .castToStringDynamic(Map<dynamic, dynamic>.from(item))))
            .toList();
        return settingsList;
      } else {
        log("No cached settings data available.");
        NkCommonFunction.showErrorSnakBar('No offline data available.');
      }
    } catch (e) {
      log('Error fetching settings from Hive: $e');
      NkCommonFunction.showErrorSnakBar(
          'Error accessing offline settings data.');
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchSalesmanTopBarData(
      String monthName, int tabStatus) async {
    try {
      String apiUrl =
          '${ApiConstants.baseUrl}${ApiConstants.salesmanDashNavContent}';
      log('API URL of TopTab: $apiUrl');
      final requestPayload = {
        "companyId": companyId,
        "salesman_id": salesmanId,
        "year": 2025,
        "month": monthName,
        "status_of_tile": tabStatus,
      };
      log('Request  : $requestPayload');

      Response response = await dio1.post(apiUrl, data: requestPayload);
      if (response.statusCode == 200) {
        log('Response Data To Bar: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        log("Failed to fetch data. Status: ${response.statusCode}, Message: ${response.statusMessage}");
        return null;
      }
    } on DioException catch (dioError) {
      final requestPayloadss = {
        "companyId": companyId,
        "salesman_id": salesmanId,
        "year": 2025,
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
    const apiUrl = '${ApiConstants.baseUrl}${ApiConstants.salesmanDashView}';
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
          final castedData = localStorage.castToStringDynamic(cachedData);
          return PerformanceData.fromJson(castedData);
        } else {
          log("No cached data available.");
          return null;
        }
      }
    } on DioException catch (dioError) {
      log("Dio error occurred1: ${dioError.message}");
      if (dioError.response != null) {
        log("Dio error response: ${dioError.response?.data}");
        log("Dio error status code1: ${dioError.response?.statusCode}");
      }
      final cachedData = performanceBox.get(cacheKey);
      if (cachedData != null) {
        log('Using cached data after API failure for key: $cacheKey');
        final castedData = localStorage.castToStringDynamic(cachedData);
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

  Future<FetchSpecificOrderInvoice> fetchSpecificOrderInvoice(
      String orderId) async {
    final response = await dio
        .postbycustom(ApiConstants.fetchSpecificOrder,
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
      ApiConstants.searchCustomer,
      data: data,
    )
        .onError((DioException error, stackTrace) {
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
        await localStorage.storeCustomerData(customerData);
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

  Future<CustomerAndOrderResponce?> retrieveCustomerData() async {
    final box = await Hive.openBox('customerBox');
    final jsonString = box.get('customerData');

    if (jsonString != null) {
      try {
        final convertedData = LocalStorage()
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
      // "start_date":'',
      // "end_date":'',
    };
    log('Request Data : $requestData');
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    bool hasInternet = hasNetwork && await isInternetAvailable();
    log('Has Internet: $hasInternet');
    final cacheKey = 'recent_order_count_${startDate ?? ''}_${endDate ?? ''}';
    if (hasInternet) {
      try {
        final response = await dio.postbycustom(
          ApiConstants.recentOrderCount,
          data: requestData,
        );
        log('Fetched Data from API: ${response.data}');
        var orderCountBox = await Hive.openBox('orderCountBox');
        await orderCountBox.put(cacheKey, response.data);
        log('Recent order count data saved to Hive with key: $cacheKey');

        return RecentOrderCountResponse.fromJson(response.data);
      } on DioException catch (error) {
        log('API Error: ${error.response?.data}');
        return await _getCachedRecentOrderCount(cacheKey);
      }
    } else {
      log('No internet. Fetching from Hive...');
      return await _getCachedRecentOrderCount(cacheKey);
    }
  }

  Future<RecentOrderCountResponse> _getCachedRecentOrderCount(
      String cacheKey) async {
    try {
      var orderCountBox = await Hive.openBox('orderCountBox');
      if (orderCountBox.containsKey(cacheKey)) {
        log('Fetching cached data for key: $cacheKey');
        final cachedData = orderCountBox.get(cacheKey);
        log('Cached Data: $cachedData');
        final parsedData = LocalStorage().castToStringDynamic(cachedData);
        return RecentOrderCountResponse.fromJson(parsedData);
      } else {
        log('No cached data available for key: $cacheKey');
        throw Exception('No cached data available4');
      }
    } catch (e) {
      log('Error fetching from Hive: $e');
      throw Exception('Failed to fetch data from Hive');
    }
  }

  Future<CustomerDashboardResponse> getCustomerDashboard(
    String customerId,
  ) async {
    final response = await dio
        .postbycustom(ApiConstants.customerDashbordList,
            data: FormData.fromMap(
                {"customer_id": customerId, "companyId": companyId}))
        .onError((DioException error, stackTrace) {
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
        .postbycustom(ApiConstants.customerTotalSale,
            data: FormData.fromMap({
              "customer_id": customerId,
              "year": year,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return CustomerDashboardTotalSaleResponse.fromJson(response.data);
  }

  Future<CartOrderModel?> addToCart(Map<String, dynamic> sendData) async {
    sendData['companyId'] = companyId;
    log('[addToCart] Request Data: ${sendData.toString()}');

    try {
      final response = await dio
          .postbycustom(
        ApiConstants.addToCart,
        data: FormData.fromMap(sendData),
      )
          .onError((DioException error, stackTrace) {
        log('[addToCart] DioError occurred.');
        log('[addToCart] Error Type: ${error.type}');
        log('[addToCart] Error Message: ${error.message}');
        log('[addToCart] Error Data: ${error.response?.data}');
        log('[addToCart] Status Code: ${error.response?.statusCode}');
        return Future.error(DioExceptionHandler.fromDioError(error));
      });
      if (response.statusCode == 200) {
        if (response.data['cart_id'] == null) {
          log('[addToCart] Cart ID is null in response.');
          return null;
        }

        log('[addToCart] Response Data: ${response.data}');
        return CartOrderModel.fromJson(response.data);
      } else {
        log('[addToCart] Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('[addToCart] Exception: $e');
      return null;
    }
  }

  Future<CartOrderModel?> addToDraft(Map<String, dynamic> sendData) async {
    sendData['companyId'] = companyId;
    log('[addToDraft] Request Data: ${sendData.toString()}');
    try {
      final response = await dio
          .postbycustom(
        ApiConstants.addToDraft,
        data: FormData.fromMap(sendData),
      )
          .onError((DioException error, stackTrace) {
        log('[addToCart] DioError occurred.');
        log('[addToCart] Error Type: ${error.type}');
        log('[addToCart] Error Message: ${error.message}');
        log('[addToCart] Error Data: ${error.response?.data}');
        log('[addToCart] Status Code: ${error.response?.statusCode}');
        return Future.error(DioExceptionHandler.fromDioError(error));
      });
      if (response.statusCode == 200) {
        if (response.data['cart_id'] == null) {
          log('[addToCart] Cart ID is null in response.');
          return null;
        }

        log('[addToCart] Response Data: ${response.data}');
        return CartOrderModel.fromJson(response.data);
      } else {
        log('[addToCart] Unexpected status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('[addToCart] Exception: $e');
      return null;
    }
  }

  Future<Response> deleteCartItem(String cartId, String variationId) async {
    final response = await dio
        .postbycustom(ApiConstants.cartDelete,
            data: FormData.fromMap(
                {"cart_id": cartId, "variation_id": variationId}))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> deleteCustomer(String id) async {
    // sendData['companyId'] = companyId;
    final response = await dio.postbycustom(ApiConstants.deletCustomer, data: {
      "companyId": companyId,
      "id": id,
    }).onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<CustomerCartResponce> getCustomerCart({String? customerId}) async {
    log("Send DATA: ${FormData.fromMap({"customer_id": customerId}).fields}");
    final response = await dio
        .postbycustom(ApiConstants.fetchCart,
            data: FormData.fromMap(
                {"customer_id": customerId, "companyId": companyId}))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return CustomerCartResponce.fromJson(response.data);
  }

  Future<OrderResponce> getSingleCustomerOrderHistory(
      {String? customerId}) async {
    log("Send DATA: ${FormData.fromMap({"customer_id": customerId}).fields}");
    final response = await dio
        .postbycustom(ApiConstants.customerOrderHistory,
            data: FormData.fromMap(
                {"customer_id": customerId, "companyId": companyId}))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderResponce.fromJson(response.data);
  }

  Future<Response> setUpdateProductPrice(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.updateProductPrice,
            data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
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
      ApiConstants.fetchOneCustomer,
      data: data,
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return CustomerAndOrderData.fromJson(
        (response.data["data"] as List).first as Map<String, dynamic>);
  }

  Future<Response> saveAsDraftProduct(Map<String, dynamic> sendData) async {
    log("Send DATA: $sendData");
    sendData['companyId'] = companyId;
    final response = await dio
        .postbycustom(ApiConstants.addOrderDraft,
            data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> assignVisit(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.addEvents, data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
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
          final convertedData = LocalStorage()
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
      ).onError((DioException error, stackTrace) {
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
    log('Input subCatId: $subCatId');

    List<ProductModel> allProducts = [];
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    bool hasInternet = hasNetwork && await isInternetAvailable();

    log('Network connectivity: $connectivityResult');
    log('Has Internet: $hasInternet');

    if (hasInternet) {
      try {
        final requestParams = {"company_id": companyId};
        log('API Request: ${ApiConstants.fetchproduct}');
        log('Query Parameters: $requestParams');
        final response = await dio1.get(
          '${ApiConstants.baseUrl}${ApiConstants.fetchproduct}',
          queryParameters: requestParams,
        );

        log('API Response Status Code: ${response.statusCode}');
        log('API Response Data: ${response.data}');

        if (response.statusCode == 200 && response.data['data'] is List) {
          for (var item in response.data['data']) {
            if (item['product'] is List) {
              allProducts.addAll((item['product'] as List)
                  .map((productJson) => ProductModel.fromJson(productJson))
                  .toList());
            }
          }
          log('Fetched Products from API: ${allProducts.length}');
          var productBox = Hive.box('productBox');
          await productBox.put(
            'products',
            allProducts.map((product) => product.toJson()).toList(),
          );
          log('Products saved to Hive.');
          log('Products category Id : ${allProducts.map((product) => product.catId).toSet().toList()}');
        } else {
          log('Failed to fetch products from API: ${response.statusCode}');
        }
      } on DioException catch (e) {
        handleHttpResponseError(
            statusCode: e.response?.statusCode ?? 0,
            showErrorSnackBar: NkCommonFunction.showErrorSnakBar);
      }
    } else {
      log('No internet. Fetching from Hive...');
      NkCommonFunction.showErrorSnakBar(
          'No internet connection. Unable to fetch data.');
    }
    try {
      var productBox = Hive.box('productBox');
      var rawProductList = productBox.get('products');
      log('Raw Product List from Hive: $rawProductList');
      if (rawProductList is List) {
        allProducts = rawProductList
            .map((productJson) {
              if (productJson is Map) {
                return ProductModel.fromJson(
                    LocalStorage().castToStringDynamic(productJson));
              }
              return null;
            })
            .whereType<ProductModel>()
            .toList();
      }
      log('Fetched Products from Hive: ${allProducts.length}');
    } catch (e) {
      log('Error fetching from Hive: $e');
      NkCommonFunction.showErrorSnakBar('Error fetching offline data.');
    }
    List<ProductModel> filteredProducts = allProducts.where((product) {
      return product.scid == subCatId;
    }).toList();
    log('Filtered Products: ${filteredProducts.length}');
    log('Filtered Product List: ${filteredProducts.map((e) => e.toJson()).toList()}');
    return filteredProducts;
  }

  Future<void> fetchDiscounts(int companyId, String salesmanId) async {
    const String url = 'http://16.50.232.153:3000/fetch_all_discount';
    try {
      Map<String, dynamic> requestPayload = {
        "companyId": companyId,
        "salesman_id": salesmanId,
      };
      log('Sending POST request to $url with payload: $requestPayload');
      Response response = await dio1.post(url, data: requestPayload);
      log('Response Status Code: ${response.statusCode}');
      log('Response Data: ${response.data}');
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is List<dynamic>) {
          List<dynamic> dataList = response.data['data'];
          List<CustomerDiscountModel> discountList = dataList.map((data) {
            return CustomerDiscountModel.fromJson(data);
          }).toList();
          log('Parsed ${discountList.length} discounts from the API response.');
          final discountBox = Hive.box<CustomerDiscountModel>('discounts');
          await discountBox.clear();
          for (var discount in discountList) {
            await discountBox.add(discount);
          }
          log('Stored ${discountList.length} discounts locally in Hive.');
        } else {
          log('Unexpected response format: ${response.data}');
        }
      } else {
        log('Failed to fetch data: ${response.statusMessage}');
      }
    } catch (e) {
      log('Error occurred while fetching discounts: $e');
    }
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
        .postbycustom(ApiConstants.addCustomer,
            data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> updateCustomer(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.updateCustomer,
            data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
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
    final leadsBox = await Hive.openBox('leadsBox');
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    bool hasInternet = hasNetwork && await isInternetAvailable();
    log('Has Internet: $hasInternet');

    if (hasInternet) {
      try {
        final response = await dio1.post(
          '${ApiConstants.baseUrl}${ApiConstants.fetchLeads}',
          data: requestData,
        );
        if (response.statusCode == 200) {
          log('Response Body Fetch Leads: ${response.data}');
          await leadsBox.put(cacheKey, response.data);
          log('Data saved to Hive for key: $cacheKey');
          return LeadResponce.fromJson(response.data);
        } else {
          handleHttpResponseError(
              statusCode: response.statusCode ?? 0,
              showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
              message: "Leads");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (dioError) {
        handleHttpResponseError(
            statusCode: dioError.response?.statusCode ?? 0,
            showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
            message: "Leads");
        log('Error fetching data from API: ${dioError.response?.statusCode ?? 0}');
        return localStorage.storedLeadsData(leadsBox, cacheKey);
      }
    } else {
      log('No internet. Fetching from Hive...');
      NkCommonFunction.showErrorSnakBar(
          'No internet connection. Unable to fetch data.');
    }
    try {
      return localStorage.storedLeadsData(leadsBox, cacheKey);
    } catch (e) {
      log('Error fetching from Hive: $e');
      throw Exception('Failed to fetch data from API and Hive.');
    }
  }

  Future<LeadResponce> getLeadsRejectedData(
      {PaginationModel? paginationModel}) async {
    final cacheKey = 'leads_rejected_${paginationModel?.currentPage ?? ''}';
    final leadsBox = await Hive.openBox('leadsRejectBox');
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    bool hasInternet = hasNetwork && await isInternetAvailable();
    log('Has Internet: $hasInternet');
    if (hasInternet) {
      try {
        final response = await dio1.post(
          '${ApiConstants.baseUrl}${ApiConstants.fetchRejectedLeads}',
          data: FormData.fromMap({
            "page": paginationModel?.currentPage ?? "",
            "limit": paginationModel?.limit ?? '',
            "salesman_id": salesmanId,
            "companyId": companyId,
          }),
        );

        if (response.statusCode == 200) {
          log('Response Body Fetch Leads Rejected: ${response.data}');
          await leadsBox.put(cacheKey, response.data);
          log('Data saved to Hive for key: $cacheKey');
          return LeadResponce.fromJson(response.data);
        } else {
          handleHttpResponseError(
              statusCode: response.statusCode ?? 0,
              showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
              message: "Rejected Leads");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (dioError) {
        handleHttpResponseError(
            statusCode: dioError.response?.statusCode ?? 0,
            showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
            message: "Rejected Leads");
        log('Error fetching data from API: ${dioError.response?.statusCode ?? 0}');
        return localStorage.storedLeadsData(leadsBox, cacheKey);
      }
    } else {
      log('No internet. Fetching from Hive...');
      
    }
    try {
      final cachedData = leadsBox.get(cacheKey);
      if (cachedData != null) {
        log('Using cached data for key: $cacheKey');
        final castedData = LocalStorage().castToStringDynamic(cachedData);
        return LeadResponce.fromJson(castedData);
      } else {
        throw Exception('No internet and no cached data available.');
      }
    } catch (e) {
      log('Error fetching data from Hive: $e');
      throw Exception('Failed to fetch data from API and Hive.');
    }
  }

  /// ******************** CALENDAR SECTION ******************/
  Future<List<EventData>> getCalendarEvents(
      Map<String, dynamic> sendData) async {
    sendData['companyId'] = SessionHelper.loginSavedData?.company_id;
    final cacheKey =
        'calendar_events_${sendData['companyId']}_${sendData['startDate']}_${sendData['endDate']}';
    log('Request Data to Calendar: $sendData');
    final eventsBox = await Hive.openBox('calendarEventsBox');
    List<EventData> allEvents = [];
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    bool hasInternet = hasNetwork && await isInternetAvailable();
    log('Has Internet: $hasInternet');
    if (hasInternet) {
      try {
        final response = await dio1.post(
          '${ApiConstants.baseUrl}${ApiConstants.getEvent}',
          data: FormData.fromMap(sendData),
        );
        log('Response received from API: ${response.data}');
        final castedResponse =
            LocalStorage().castToStringDynamic(response.data);
        if (castedResponse['data'] is List) {
          List<dynamic> eventsJson = castedResponse['data'];
          await eventsBox.put(cacheKey, eventsJson);
          log('Data successfully cached with key: $cacheKey');
          allEvents = eventsJson
              .map((event) => EventData.fromJson(event as Map<String, dynamic>))
              .toList();
        } else {
          log('Unexpected response format: $castedResponse');
          return [];
        }
      } on DioException catch (e) {
        log('Error fetching data from API: $e');
        handleHttpResponseError(
            statusCode: e.response?.statusCode ?? 0,
            showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
            message: "Calender Event");
      }
    } else {
      NkCommonFunction.showErrorSnakBar(
          'No internet connection. Unable to fetch data.');
      log('No internet connection. Fetching data from Hive...');
    }
    try {
      var cachedData = eventsBox.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        allEvents = cachedData
            .map((eventJson) {
              if (eventJson is Map) {
                return EventData.fromJson(
                    LocalStorage().castToStringDynamic(eventJson));
              }
              return null;
            })
            .whereType<EventData>()
            .toList();
      }
      log('Fetched Events from Hive: ${allEvents.length}');
    } on DioException catch (e) {
      log('Error fetching from Hive: $e');
      handleHttpResponseError(
          statusCode: e.response?.statusCode ?? 0,
          showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
          message: "Calender Event");
    }
    if (allEvents.isEmpty) {
      log('No events found in cache.');
      throw Exception(
          'No events available, and no internet connection to fetch them.');
    }
    return allEvents;
  }

  Future<Response> handleLeadStatus(
      int? customerId, String? statusResponce) async {
    final response = await dio
        .postbycustom(ApiConstants.handleLeads,
            data: FormData.fromMap({
              "customer_id": customerId,
              "status": statusResponce,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<TodayTasksResponse> getTodaySchedule(
      Map<String, dynamic> sendData) async {
    final response = await dio
        .postbycustom(ApiConstants.fetchScheduleCustomer,
            showErrorSnakBar: false, data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error,
          showErrorSnakBar: false));
    });
    return TodayTasksResponse.fromJson(response.data);
  }

  Future<Response> updateSchedule(Map<String, dynamic> sendData) async {
    log("Send DATA: $sendData");
    final response = await dio
        .postbycustom(ApiConstants.scheduleCustomer,
            data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(
        error,
      ));
    });
    return response;
  }

  Future<Response> updateEvent(Map<String, dynamic> sendData) async {
    log("Send DATA: $sendData");
    final response = await dio
        .postbycustom(ApiConstants.updateEvenets,
            data: FormData.fromMap(sendData))
        .onError((DioException error, stackTrace) {
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
    log("startDate++123++${searchModel?.startDate ?? ''}:${searchModel?.endDate ?? ''}");
    log("data post ++ ++$salesmanId : ${customerId ?? ''} : ${searchModel?.startDate} : ${searchModel?.endDate} : ${paginationModel?.limit.toString()} : ${paginationModel?.currentPage.toString()}");

    final response = await dio
        .postbycustom(
      ApiConstants.fetchOrder,
      data: FormData.fromMap({
        "salesman_id": salesmanId,
        "customer_id": customerId ?? '',
        "start_date": searchModel?.startDate ?? '',
        "end_date": searchModel?.endDate ?? '',
        "limit": paginationModel?.limit.toString() ?? '',
        "page": paginationModel?.currentPage.toString() ?? ''
      }),
    )
        .onError((DioException error, stackTrace) {
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
      ApiConstants.fetchAllOrder,
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
    bool? isLogin,
  }) async {
    final requestData = {
      "chart_index": chartIndex,
      "start_date": searchModel?.startDate ?? '',
      "end_date": searchModel?.endDate ?? '',
      "limit": paginationModel?.limit.toString(),
      "page": paginationModel?.currentPage.toString(),
      "salesman_id": salesmanId ?? '',
      "companyId": isLogin == true ? compId : companyId,
    };
    final cacheKey =
        'pending_payment_${chartIndex}_${salesmanId ?? ''}_${paginationModel?.currentPage ?? ''}';
    final pendingPaymentBox = Hive.box('pendingPaymentBox');

    try {
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        NkCommonFunction.showErrorSnakBar(
            'No internet connection. Unable to fetch data.');
        log('Offline mode: Fetching data from cache for key: $cacheKey');
        return localStorage.storedPendingPaymentData(
            pendingPaymentBox, cacheKey);
      }
      final response = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.fetchPendingPayments}',
        data: FormData.fromMap(requestData),
      );
      log("API Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        log('API data received successfully. Caching data with key: $cacheKey');
        await pendingPaymentBox.put(cacheKey, response.data);
        return PendingPaymentResponse.fromJson(response.data);
      } else {
        handleHttpResponseError(
            statusCode: response.statusCode ?? 0,
            showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
            message: "Pending payment");
        log('Fetching cached data due to API error for key: $cacheKey');
        return localStorage.storedPendingPaymentData(
            pendingPaymentBox, cacheKey);
      }
    } on DioException catch (dioError) {
      log("DioException occurred: $dioError");
      handleHttpResponseError(
          statusCode: dioError.response?.statusCode ?? 0,
          showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
          message: "Pending payment");
      log('Fetching cached data due to connection failure for key: $cacheKey');
      return localStorage.storedPendingPaymentData(pendingPaymentBox, cacheKey);
    } catch (e) {
      log("Unexpected error occurred: $e");
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        NkCommonFunction.showErrorSnakBar(
            'No internet connection. Unable to fetch data.');
        log('Using cached data due to offline mode for key: $cacheKey');
        return localStorage.storedPendingPaymentData(
            pendingPaymentBox, cacheKey);
      } else {
        throw Exception('Unexpected error occurred: $e');
      }
    }
  }

  Future<IndividualPendingPaymentResponse> getAllPendingPaymentIndividual(
      {String? customerId}) async {
    final response = await dio
        .postbycustom(
      ApiConstants.getAllPendingPaymentIndividuals,
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
      ApiConstants.ordersCountGet,
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

  Future<OrderResponce> getRecentOrdersData({
    SearchModel? searchModel,
    int? orderStatus,
    String? startDate,
    String? endDate,
    int? page,
    required bool isLogin,
  }) async {
    final start = isLogin
        ? startDate
        : searchModel?.startDate?.isNotEmpty == true
            ? searchModel?.startDate
            : null;
    final end = isLogin
        ? endDate
        : searchModel?.endDate?.isNotEmpty == true
            ? searchModel?.endDate
            : null;
    final cacheKey =
        'recent_orders_${orderStatus ?? ''}_${start ?? ''}_${end ?? ''}';
    final ordersBox = await Hive.openBox('ordersBox');
    log("Preparing request for recent orders. Cache Key: $cacheKey");

    // Check internet connectivity
    final isConnected = await ConnectivityService().isOnline();
    log("Internet connectivity status: ${isConnected ? 'Online' : 'Offline'}");

    // Handle online scenario
    if (isConnected) {
      try {
        final requestData = {
          "order_status": orderStatus,
          "start_date": start ?? '',
          "end_date": end ?? '',
          "limit": 10,
          "page": page,
          "companyId": companyId,
          "salesman_id": salesmanId,
        };
        log('Sending API request for recent orders. Request Body: $requestData');

        final response = await dio1.post(
          '${ApiConstants.baseUrl}${ApiConstants.getRecentOrder}',
          data: requestData,
        );
        log('Response received from API RECENT: ${response.data}');

        // Cache API response
        await ordersBox.put(cacheKey, response.data);
        log('API response successfully cached with key: $cacheKey');

        // Return parsed response
        return OrderResponce.fromJson(response.data);
      } on DioException catch (error) {
        handleHttpResponseError(
          statusCode: error.response?.statusCode ?? 0,
          showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
          message: "Recent Order",
        );
        log('DioException occurred. Status Code: ${error.response?.statusCode}');
        log('Response Data: ${error.response?.data}');
        log('Request Data: ${error.requestOptions.data}');

        // Attempt to fetch from cache
        if (ordersBox.containsKey(cacheKey)) {
          log('Using cached data after API failure for key: $cacheKey');
          final cachedData = ordersBox.get(cacheKey);
          log('Cached Data: $cachedData');

          final castedData = LocalStorage().castToStringDynamic(cachedData);
          return OrderResponce.fromJson(castedData);
        } else {
          log('No cached data available after API failure.');
          throw Exception('Failed to fetch data and no cached data available.');
        }
      }
    }
    log('Offline: Attempting to fetch data from cache.');
    if (ordersBox.containsKey(cacheKey)) {
      final cachedData = ordersBox.get(cacheKey);
      log('Cached Data: $cachedData');

      final castedData = LocalStorage().castToStringDynamic(cachedData);
      return OrderResponce.fromJson(castedData);
    } else {
      log('No cached data available offline for key: $cacheKey');
      NkCommonFunction.showErrorSnakBar(
          'No internet connection and no cached data available.');
      throw Exception("No internet connection and no cached data available.");
    }
  }

  Future<OrderProcessInvoice> getOrderProcessInvoiceData({
    String? orderId,
    int? orderStatus,
  }) async {
    final response = await dio
        .postbycustom(
      ApiConstants.orderProcessInvoice,
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

  Future<FetchSpecificOrderInvoice> fetchSpecificOrder(String orderId) async {
    final response = await dio
        .postbycustom(ApiConstants.fetchSpecificOrder,
            data: FormData.fromMap({
              "order_id": orderId,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    log(response.data.toString());
    return FetchSpecificOrderInvoice.fromJson(response.data);
  }

  Future<OrderProcessInvoice> loadWaitingForApproval({
    String? orderId,
  }) async {
    final response = await dio
        .postbycustom(
      ApiConstants.waitingForApproval,
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
        "companyId": companyId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return ButtonAction.fromJson(response.data);
  }

  Future<ScheduleListResponse> fetchSchedule(
      String endDate, String startDate) async {
    final response = await dio
        .postbycustom(ApiConstants.fetchSchedule,
            data: FormData.fromMap({
              "end_date": endDate,
              "salesman_id": SessionHelper.loginSavedData?.salesmanId,
              "start_date": startDate,
              "company_id": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(
        error,
      ));
    });
    return ScheduleListResponse.fromJson(response.data);
  }

//   Future<String?> getWeeklyType() async {
//     const cacheKey = 'weekly_type_data';
//     final weeklyTypeBox = Hive.box('weeklyTypeBox');

//     // Check network connectivity
//     final connectivityResult = await Connectivity().checkConnectivity();
//     bool isOnline = connectivityResult != ConnectivityResult.none;

//     if (isOnline) {
//       try {
//         // API Call
//         final response = await dio.postbycustom(
//           ApiConstants.getWeekelyType,
//           data: FormData.fromMap({
//             "companyId": companyId,
//           }),
//         );

//         // Validate API response
//         if (response.data is Map<String, dynamic> &&
//             response.data.containsKey('data')) {
//           final weeklyType = response.data['data'].toString();
//           log('API Response for Weekly Type: $weeklyType');

//           // Store the response in Hive
//           await weeklyTypeBox.put(cacheKey, weeklyType);
//           log('Weekly Type data saved to Hive.');

//           return weeklyType;
//         } else {
//           // Unexpected response format
//           NkCommonFunction.showErrorSnakBar('Unexpected API response format.');
//           log('Unexpected API response format.');

//           // Fetch data from Hive as a fallback
//           return _getCachedWeeklyType(weeklyTypeBox, cacheKey);
//         }
//       } catch (error) {
//         // Handle DioException and log error
//         log("DioException occurred: $error");
//         NkCommonFunction.showErrorSnakBar(
//             'Failed to fetch weekly type. Showing offline data.');

//         // Fetch data from Hive as a fallback
//         return _getCachedWeeklyType(weeklyTypeBox, cacheKey);
//       }
//     } else {
//       // Offline mode
//       log("Offline mode: Fetching weekly type from Hive.");
//       NkCommonFunction.showErrorSnakBar(
//           'No internet connection. Showing offline data.');

//       // Fetch data from Hive
//       return _getCachedWeeklyType(weeklyTypeBox, cacheKey);
//     }
//   }

  Future<String?> getWeeklyType() async {
    const cacheKey = 'weekly_type';
    final weeklyTypeBox = Hive.box('weeklyTypeBox');
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOnline = connectivityResult != ConnectivityResult.none;
      if (isOnline) {
        final response = await dio.postbycustom(
          ApiConstants.getWeekelyType,
          data: FormData.fromMap({
            "companyId": companyId,
          }),
        );
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          final weeklyType = response.data['data'].toString();
          log("Weekly Type fetched from API: $weeklyType");
          await weeklyTypeBox.put(cacheKey, weeklyType);
          log("Weekly Type saved to Hive with key: $cacheKey");
          return weeklyType;
        } else {
          log("Unexpected response format: ${response.data}");
          throw Exception("Unexpected response format");
        }
      } else {
        log("Offline mode: Fetching Weekly Type from Hive.");
      }
    } catch (error) {
      log("Error fetching Weekly Type from API: $error");
      if (error is DioException) {
        throw DioExceptionHandler.fromDioError(error);
      }
    }
    try {
      if (weeklyTypeBox.containsKey(cacheKey)) {
        final cachedWeeklyType = weeklyTypeBox.get(cacheKey) as String?;
        log("Weekly Type fetched from Hive: $cachedWeeklyType");
        return cachedWeeklyType;
      } else {
        log("No cached Weekly Type data found for key: $cacheKey");
      }
    } catch (e) {
      log("Error accessing cached Weekly Type data: $e");
    }

    return null;
  }

// // Helper function to fetch cached data from Hive
//   String? _getCachedWeeklyType(Box box, String cacheKey) {
//     try {
//       final cachedData = box.get(cacheKey);
//       if (cachedData != null) {
//         log('Fetched Weekly Type from Hive: $cachedData');
//         return cachedData as String;
//       } else {
//         log('No cached Weekly Type data available.');
//         NkCommonFunction.showErrorSnakBar('No offline data available.');
//         return null;
//       }
//     } catch (e) {
//       log('Error fetching Weekly Type from Hive: $e');
//       NkCommonFunction.showErrorSnakBar('Error accessing offline data.');
//       return null;
//     }
//   }

Future<SalesmanValueTargetResponse?> fetchSalesmanValueTarget(
    String salesmanId, String year, String? month) async {
  final requestPayload = {
    "salesman_id": salesmanId,
    "year": year,
    if (month != null) "month": month,
    "companyId": companyId,
  };

  final cacheKey =
      'salesman_value_target_${salesmanId}_${year}_${month ?? 'all'}';
  final targetBox = Hive.box('salesmanValueTargetBox');

  log("fetchSalesmanValueTarget request: $requestPayload");

  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      // Online Mode: Fetch data from API
      final response = await dio
          .postbycustom(
        ApiConstants.fetchSalesmanValueTarget,
        data: requestPayload,
      )
          .onError((DioException error, stackTrace) {
        log(error.toString());
        throw DioExceptionHandler.fromDioError(error);
      });

      log("Salesman Value Target Response: $response");

      if (response.statusCode == 200) {
        final dynamic jsonData = response.data['data'];
        if (jsonData is Map<String, dynamic>) {
          log("Salesman Value Target Data: $jsonData");
          await targetBox.put(cacheKey, jsonData);
          return SalesmanValueTargetResponse.fromJson(jsonData);
        } else {
          log("Unexpected response format from API");
        }
      } else {
        log(
            "Failed to fetch value target data: ${response.statusCode} ${response.statusMessage}");
      }
    } else {
      log(
          "Offline mode: Fetching value target data from Hive for key: $cacheKey");
    }
  } on DioException catch (dioError) {
    log("Dio error occurred2: ${dioError.message}");
  } catch (e) {
    log("Unexpected error occurred Salesman Value Target: $e");
  }
  try {
    if (targetBox.containsKey(cacheKey)) {
      final cachedData = targetBox.get(cacheKey);
      log("Using cached data for key: $cacheKey");
      if (cachedData is Map<String, dynamic>) {
        return SalesmanValueTargetResponse.fromJson(cachedData);
      } else {
        log("Cached data format is invalid.");
      }
    } else {
      log("No cached data available for key: $cacheKey");
    }
  } catch (e) {
    log("Error accessing cached data: $e");
  }

  return null;
}


Future<SalesmanTargetTableResponse?> fetchSalesmanTarget(
    String salesmanId, String month, String year) async {
  final requestPayload = {
    "salesman_id": salesmanId,
    "year": year,
    "month": month,
    "companyId": companyId,
  };

  final cacheKey = 'salesman_target_${salesmanId}_${year}_$month';
  final targetBox = Hive.box('salesmanTargetBox');

  log("fetchSalesmanTarget request: $requestPayload");

  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      // Online Mode: Fetch data from API
      final response = await dio
          .postbycustom(
        ApiConstants.fetchSalesmanTarget,
        data: requestPayload,
      )
          .onError((DioException error, stackTrace) {
        log(error.toString());
        throw DioExceptionHandler.fromDioError(error);
      });

      log("Salesman Target Response: $response");

      if (response.statusCode == 200) {
        final dynamic jsonData = response.data['data'];
        log("Salesman Target Data: ${response.data}");
        if (jsonData is List) {
          await targetBox.put(cacheKey, jsonData);
          return SalesmanTargetTableResponse.fromJson({"data": jsonData});
        } else if (jsonData is Map<String, dynamic>) {
          // Handle the case where 'data' is a map
          await targetBox.put(cacheKey, jsonData);
          return SalesmanTargetTableResponse.fromJson(jsonData);
        } else {
          log("Unexpected response format for data.");
        }
      } else {
        log("Failed to fetch target data: ${response.statusCode} ${response.statusMessage}");
      }
    } else {
      try {
    if (targetBox.containsKey(cacheKey)) {
      final cachedData = targetBox.get(cacheKey);
      log("Using cached data for key: $cacheKey");
      log("Cached Data Salesman Target: $cachedData");

      if (cachedData is List) {
        return SalesmanTargetTableResponse.fromJson({"data": cachedData});
      } else if (cachedData is Map<String, dynamic>) {
        return SalesmanTargetTableResponse.fromJson(cachedData);
      } else {
        log("Cached data format is invalid.");
      }
    } else {
      log("No cached data available for key: $cacheKey");
    }
  } catch (e) {
    log("Error accessing cached data: $e");
  }
      log("Offline mode: Fetching target data from Hive for key: $cacheKey");
    }
  } on DioException catch (dioError) {
    log("Dio error occurred3: ${dioError.message}");
  } catch (e) {
    log("Unexpected error occurred Salesman target: $e");
  }
  try {
    if (targetBox.containsKey(cacheKey)) {
      final cachedData = targetBox.get(cacheKey);
      log("Using cached data for key: $cacheKey");
      log("Cached Data Salesman Target: $cachedData");

      if (cachedData is List) {
        return SalesmanTargetTableResponse.fromJson({"data": cachedData});
      } else if (cachedData is Map<String, dynamic>) {
        return SalesmanTargetTableResponse.fromJson(cachedData);
      } else {
        log("Cached data format is invalid.");
      }
    } else {
      log("No cached data available for key: $cacheKey");
    }
  } catch (e) {
    log("Error accessing cached data: $e");
  }

  return null;
}


  Future<StaffTimesheetResponse> getTimeSheetData({
    String? startDate,
    String? endDate,
  }) async {
    log("🔍 API Request: startDate=$startDate, endDate=$endDate, id=${SessionHelper.loginSavedData?.id}");

    try {
      final response = await dio.postbycustom(
        ApiConstants.getStaffTimeSheet,
        data: FormData.fromMap({
          "startdate": startDate,
          "enddate": endDate,
          "id": SessionHelper.loginSavedData?.id,
        }),
      );

      log("✅ API Response: ${response.statusMessage}, Data: ${response.data}");
      return StaffTimesheetResponse.fromJson(response.data);
    } on DioException catch (error) {
      log("❌ API Error: ${error.response?.statusCode} - ${error.message}");
      throw DioExceptionHandler.fromDioError(error);
    } catch (e) {
      log("❌ Unknown API Error: $e");
      rethrow;
    }
  }

  Future<bool> loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log('loadSwitchState: ${prefs.getBool('switch_state')}');
    return prefs.getBool('switch_state') ?? false;
  }

  Future<void> saveSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switch_state', value);
    log('saveSwitchSate: $value');
  }

  Future<Response> updateAdminCheckInOut({
    String? date,
    String? time,
    String? direction,
    String? lat,
    String? long,
  }) async {
    var response = await dio
        .postbycustom(ApiConstants.updateCheckinOut,
            data: FormData.fromMap(
              {
                "companyId": companyId,
                "date": date,
                "sales_id": SessionHelper.loginSavedData?.id,
                "time": time,
                "direction": direction,
                "latitude": lat,
                "longitude": long
              },
            ))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> updateValueBasedTargetValue(
    String salesmanId,
    String year,
    String month,
    Map<String, dynamic> monthTarget,
    Map<String, dynamic> weeklyTarget,
  ) async {
    log(monthTarget.toString());

    final request = {
      "sales_id": salesmanId,
      "year": year,
      "month_target": monthTarget,
      "weekly_target": weeklyTarget,
      "month_to_insert": month,
      "companyId": companyId,
    };

    log("request: $request");

    final response = await dio
        .postbycustom(ApiConstants.updateValueBasedTargetValue, data: (request))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<Response> updateCategoryTargetValue(
    String salesmanId,
    String month,
    String year,
    Map<dynamic, dynamic> categoryData,
    Map<dynamic, dynamic> weeklyTarget,
    Map<dynamic, dynamic> weeklyProjection,
  ) async {
    final response = await dio
        .postbycustom(ApiConstants.updateCategoryTargetValue,
            data: ({
              "categories": categoryData,
              "weekly_target": weeklyTarget,
              "weekly_projection": weeklyProjection,
              "sales_id": salesmanId,
              "year": int.parse(year),
              "month": month,
              "companyId": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<LeadResponce> getLeadsCustomerData(String salesManId,
      {PaginationModel? paginationModel}) async {
    final cacheKey =
        'leads_customer_${salesManId}_${paginationModel?.currentPage ?? ''}';
    final leadsBox = await Hive.openBox('leadsCustomerBox');
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    bool hasInternet = hasNetwork && await isInternetAvailable();
    log('Has Internet: $hasInternet');

    if (hasInternet) {
      try {
        final response = await dio1.post(
          '${ApiConstants.baseUrl}${ApiConstants.fetchLeadsCustomer}',
          data: FormData.fromMap({
            "page": paginationModel?.currentPage ?? 1,
            "limit": paginationModel?.limit ?? 10,
            "salesman_id": salesManId,
            "companyId": companyId,
          }),
        );

        if (response.statusCode == 200) {
          log('Response Body Fetch Leads Customer: ${response.data}');
          await leadsBox.put(cacheKey, response.data);
          log('Data saved to Hive for key: $cacheKey');
          return LeadResponce.fromJson(response.data);
        } else {
          handleHttpResponseError(
              statusCode: response.statusCode ?? 0,
              showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
              message: "Leads Customer");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (dioError) {
        handleHttpResponseError(
            statusCode: dioError.response?.statusCode ?? 0,
            showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
            message: "Leads Customer");
        log('Error fetching data from API: ${dioError.response?.statusCode ?? 0}');
        return localStorage.storedLeadsData(leadsBox, cacheKey);
      }
    } else {
      log('No internet. Fetching from Hive...');
    }

    // Fetching data from Hive
    try {
      final cachedData = leadsBox.get(cacheKey);
      if (cachedData != null) {
        log('Using cached data for key: $cacheKey');
        final castedData = LocalStorage().castToStringDynamic(cachedData);
        return LeadResponce.fromJson(castedData);
      } else {
        throw Exception('No internet and no cached data available.');
      }
    } catch (e) {
      log('Error fetching data from Hive: $e');
      throw Exception('Failed to fetch data from API and Hive.');
    }
  }
}
