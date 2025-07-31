// ignore_for_file: library_prefixes, empty_catches, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart'
    as orderResponseModel;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl1;
  final LocalStorage localStorage = LocalStorage();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Dio dio = Dio();
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;

  // Future<CustomerRevenueResponse> fetchCustomerRevenueData(
  //   String customerId,
  //   int specifiedYear,
  //   String startDate,
  //   String endDate,
  // ) async {
  //   final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  //   final customerRevenueBox = Hive.box('customerRevenueBox');
  //   final requestBody = {
  //     "companyId": companyId,
  //     "customer_id": customerId,
  //     "end_date": endDate,
  //     "start_date": startDate,
  //     "year": specifiedYear,
  //   };
  //   try {
  //     final bool isOnline = await ConnectivityService().isOnline();
  //     if (!isOnline) {
  //       final cachedData = customerRevenueBox.get(customerId);
  //       return localStorage.storedCustomerRevenueData(cachedData, customerId);
  //     }
  //     final response = await responsePostMethod(
  //       requestData: requestBody,
  //       endPoint: ApiConstants.customerRevenue,
  //       options: Options(
  //         headers: {'Content-Type': 'application/json'},
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       final responseData = response.data;
  //       await customerRevenueBox.put(
  //         customerId,
  //         Map<String, dynamic>.from(responseData),
  //       );
  //       log("Data fetched and stored for customerId: $customerId");
  //       return CustomerRevenueResponse.fromJson(responseData);
  //     } else {
  //       throw Exception(
  //         'Failed to load customer revenue data - Status: ${response.statusCode}',
  //       );
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         apiName: "customer revenue", error: error, response: error.response);
  //     log("Error occurred while fetching revenue data: $error");
  //     final cachedData = customerRevenueBox.get(customerId);
  //     return localStorage.storedCustomerRevenueData(cachedData, customerId);
  //   }
  // }

  Future<ResponseModell> fetchDashboardData({
    String? fetchType,
    String? startDate,
    String? endDate,
    String? selectedDay,
    List<String>? selectedMonths,
    List<String>? selectedWeeks,
    int? year,
    String? salesmanId,
  }) async {
    final String jsonString =
        await SessionManager.getStringValue(SpString.spLogin);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final String createdToken = jsonMap['createdToken'];
    Object? sendData;

    switch (fetchType) {
      case "Month":
        sendData = selectedMonths;
        break;
      case "Week":
        sendData = selectedWeeks;
        break;
      case "Day":
        sendData = [selectedDay];
        break;
      case "Year":
        sendData = year.toString();
        break;
      case "Range":
        sendData = [startDate, endDate];
        break;
      default:
        sendData = selectedMonths;
    }
    final Map<String, dynamic> requestBody = {
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "selected_range": sendData,
      "time_range": fetchType == "Year" ? "year" : fetchType,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "year": fetchType == "Year" ? year : DateTime.now().year,
    };
    final dashboardBox = Hive.box('dashboardBox');
    try {
      bool isOnline = await _connectivityService.isOnline();
      if (!isOnline) {
        errorSnackbar('No Internet Connection. Please check your network');
        final cachedDataString = dashboardBox.get('dashboardData');
        log('Dashboard Cached data : $cachedDataString');
        if (cachedDataString == null) {
          throw Exception('No cached dashboard data found');
        }
        final parsedJson = jsonDecode(cachedDataString);
        return localStorage.mapJsonToResponseModel(parsedJson);
      } else {
        final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.getDashboardList,
          options: Options(
            headers: {'Authorization': 'Bearer $createdToken'},
          ),
        );
        if (response.statusCode == 200) {
          log("The Status code is : ${response.statusCode}");
          final jsonResponse = response.data;
          await dashboardBox.put('dashboardData', jsonEncode(jsonResponse));
          return localStorage.mapJsonToResponseModel(jsonResponse);
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          _handleTokenExpiration();
          throw Exception('Session expired');
        } else {
          throw Exception(
              'Failed to load data. Status code: ${response.statusCode}, Message: ${response.statusMessage}');
        }
      }
    } on DioException catch (error) {
      log("Caught DioException");
      log('Error Response :${error.response}');
      handleExceptionMessage(
          response: error.response, apiName: "dashboard data", error: error);
      final cachedData = dashboardBox.get('dashboardData');
      return localStorage.storedDashboardDatas(cachedData, dashboardBox);
    }
  }

  void _handleTokenExpiration() async {
    if (!Get.isDialogOpen!) {
      await Get.dialog(
        AlertDialog(
          title: const Text("Session Expired"),
          content: const Text("Your session has expired. Please log in again."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () async {
                await SessionHelper().clearAll();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<ResponseModelCp> fetchDashboardCategoruPerformenceData({
    required int catId,
    String? fetchType,
    String? startDate,
    String? endDate,
    String? selectedDay,
    List<String>? selectedMonths,
    List<String>? selectedWeeks,
    int? year,
  }) async {
    Object? sendData;

    switch (fetchType) {
      case "Month":
        sendData = selectedMonths;
        break;
      case "Week":
        sendData = selectedWeeks;
        break;
      case "Day":
        sendData = [selectedDay];
        break;
      case "Year":
        sendData = year;
        break;
      case "Range":
        sendData = [startDate, endDate];
        break;
      default:
        sendData = selectedMonths;
    }
    final requestBody = {
      "catId": catId,
      "time_range": fetchType,
      "selected_range": sendData,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "year": DateTime.now().year,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: "fetchCategoryPerformance",
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        var allCategoryList = jsonResponse['data'] as List;
        List<Salesmanvn> allCategory =
            allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();
        return ResponseModelCp(
            statusCode: jsonResponse['status_code'] ?? 0,
            status: jsonResponse['status'] ?? false,
            message: jsonResponse['message'] ?? '',
            data: allCategory);
      } else {
        throw Exception('Failed to load data');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "category perfromance",
          error: error);
      throw Exception('Failed to fetch data: $error');
    }
  }

  Future<ResponseModelCp> fetchDashboardValuePerformanceData({
    required String catId,
    String? fetchType,
    String? startDate,
    String? endDate,
    String? selectedDay,
    List<String>? selectedMonths,
    List<String>? selectedWeeks,
    int? year,
  }) async {
    final requestBody = {
      "month": catId,
      "time_range": "Month",
      "year": DateTime.now().year,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };
    try {
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        NkCommonFunction.showErrorSnakBar(
            'No internet Connection. Please check your network.');
      }
      final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.fetchValuePerformance,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        var allCategoryList = jsonResponse['data'] as List;
        List<Salesmanvn> allCategory =
            allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();
        return ResponseModelCp(
            statusCode: jsonResponse['status_code'] ?? 0,
            status: jsonResponse['status'] ?? false,
            message: jsonResponse['message'] ?? '',
            data: allCategory);
      } else {
        log('Request failed with status 1: ${response.statusCode}');
        handleExceptionMessage(
            response: response, apiName: "value perfromance");
        throw Exception('Failed to load data');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "value perfromance", error: error);
      throw Exception('Failed to fetch data: $error');
    }
  }

  Future<List<orderResponseModel.OrderData>> fetchChartSalesmanOrderData({
    required dynamic catId,
    String? salesmanId,
    String? fetchType,
    String? startDate,
    String? endDate,
    String? selectedDay,
    List<String>? selectedMonths,
    List<String>? selectedWeeks,
    int? year,
  }) async {
    Object? sendData;
    switch (fetchType) {
      case "Month":
        sendData = selectedMonths;
        break;
      case "Week":
        sendData = selectedWeeks;
        break;
      case "Day":
        sendData = [selectedDay];
        break;
      case "Year":
        sendData = year;
        break;
      case "Range":
        sendData = [startDate, endDate];
        break;
      default:
        sendData = selectedMonths;
    }
    final requestBody = {
      "categories_id": catId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "customer_id": "",
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "bar_type": fetchType,
      "range_type": fetchType,
      "selected_range": sendData,
      "year": fetchType == "Year" ? year : DateTime.now().year.toString(),
      "limit": 1000,
      "page": 1
    };
    try {
      final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.fetchOrderByRange,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        var returnResponse = jsonResponse['data'] as List;
        List<orderResponseModel.OrderData> orderData = returnResponse
            .map((e) => orderResponseModel.OrderData.fromJson(e))
            .toList();

        return orderData;
      } else {
        handleExceptionMessage(
            response: response, apiName: "chart salesman order data");
        throw Exception('Failed to load data');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "chart salesman order data",
          error: error);
      throw Exception('Failed to fetch data: $error');
    }
  }

  Future<List<TargetDatum>> fetchSalesmanTargetByCategory({
    required int catId,
    String? salesmanId,
    String? fetchType,
    String? startDate,
    String? endDate,
    String? selectedDay,
    List<String>? selectedMonths,
    List<String>? selectedWeeks,
    int? year,
  }) async {
    dynamic sendData;
    switch (fetchType) {
      case "Month":
        sendData = selectedMonths;
        break;
      case "Week":
        sendData = selectedWeeks;
        break;
      case "Day":
        sendData = selectedDay != null ? [selectedDay] : null;
        break;
      case "Year":
        sendData = year != null ? [year.toString()] : null;
        break;
      case "Range":
        sendData = (startDate != null && endDate != null)
            ? [startDate, endDate]
            : null;
        break;
      default:
        sendData = null;
    }

    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "bar_type": "Month",
      "time_range": fetchType,
      "selected_range": sendData,
      "CatId": catId.toString(),
      "year": fetchType == "Year"
          ? year?.toString()
          : DateTime.now().year.toString(),
    };
    log("Request Body: $requestBody");
    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        endPoint: ApiConstants.fetchSalesmanTargetByCategory,
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        var parsedData = SalesmanTargetByCatId.fromJson(jsonResponse);
        return parsedData.targetData ?? [];
      } else {
        handleExceptionMessage(
            response: response, apiName: "salesman terget by category");
        log('Request failed: ${response.statusCode} | Response: ${response.data}');
        throw Exception('Failed to load data');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "salesman terget by category",
          error: error);
      throw Exception('Failed to fetch data: $error');
    }
  }

  Future<ProductResponse> fetchCustomerDashboardCartData({
    required dynamic customerId,
    required dynamic catId,
    required dynamic selectedYearCategory,
    required String startDate,
    required String endDate,
  }) async {
    final requestBody = {
      'customerId': customerId,
      'catId': catId,
      'selected_year_category': selectedYearCategory,
      'companyId': SessionHelper.loginSavedData?.company_id ?? 0,
      'last_date': endDate,
      'start_date': startDate,
      "salesman_id": '',
    };
    try {
      final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.customerSaleByCategory,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        var productDetail = jsonResponse['data'] as List;
        List<ProductDetail> allproductDetail =
            productDetail.map((json) => ProductDetail.fromJson(json)).toList();
        return ProductResponse(
            statusCode: jsonResponse['status_code'] ?? 0,
            status: jsonResponse['status'] ?? false,
            message: jsonResponse['message'] ?? '',
            data: allproductDetail);
      } else {
        handleExceptionMessage(
            response: response, apiName: "customer dashboard cart data");
        throw Exception('Failed to load data');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "customer dashboard cart data",
          error: error);
      throw Exception('Failed to fetch data: $error');
    }
  }

  Future<SalesmenResponse> fetchChatData(String salesmanId) async {
    final requestBody = {"salesman_id": salesmanId, "companyId": companyId};
    log('Request Body of Chat: $requestBody');
    try {
      final response = await responsePostMethod(
          requestData: requestBody, endPoint: ApiConstants.fetchChat);
      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['data'];
        List<SalesmanChat> salesmanChats = [];
        for (var chatList in rawData) {
          chatList.forEach((json) {
            salesmanChats.add(SalesmanChat.fromJson(json));
          });
        }
        log('Request Body of Chat: ${response.data}');
        return SalesmenResponse(
          statusCode: response.data['status_code'],
          status: response.data['status'],
          message: response.data['message'],
          data: [salesmanChats],
        );
      } else {
        handleExceptionMessage(response: response, apiName: "fetch chat data");
        throw Exception('Failed to fetch chat data - ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "fetch chat data", error: error);
      throw Exception('Failed to fetch chat data: $error');
    }
  }

  Future<MessagesResponse> fetchIndividualChatApi(
      String chatId, int page) async {
    log('Fetching Individual Chats for Chat ID: $chatId, Page: $page');
    final requestBody = {
      "salesman_id": chatId,
      "limit": 20,
      "page": page,
    };
    final chatBox = Hive.box('chatBox');
    final cacheKey = 'chat_${chatId}_page_$page';
    try {
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        log('No internet connection. Fetching cached data from Hive.');
        final cachedData = chatBox.get(cacheKey);
        return localStorage.storedChatData(cachedData, cacheKey);
      }
      log('Internet available. Fetching data from API.');
      final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.fetchIndividualChat,
          options: Options(headers: {'Content-Type': 'application/json'}));
      log('Request body of Chat: $requestBody');
      log('API Response Data: ${response.data}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            response.data is Map<String, dynamic>
                ? response.data
                : json.decode(response.data);
        final wrappedResponse = {
          'status_code': jsonResponse['status_code'],
          'status': jsonResponse['status'],
          'message': jsonResponse['message'],
          'data': jsonResponse['data'],
        };
        await chatBox.put(
          cacheKey,
          wrappedResponse.map((key, value) => MapEntry(key.toString(), value)),
        );
        return MessagesResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: (jsonResponse['data'] as List)
              .map((messageJson) => Messages.fromJson(messageJson))
              .toList(),
        );
      } else {
        handleExceptionMessage(
          response: response,
          apiName: "chat",
        );
        throw Exception(
            'Failed to fetch individual chat data - ${response.statusCode}');
      }
    } on DioException catch (error) {
      log('Error occurred: $error');
      handleExceptionMessage(
          response: error.response, apiName: "chat", error: error);
      final cachedData = chatBox.get(cacheKey);
      return localStorage.storedChatData(cachedData, cacheKey);
    }
  }

  Future<OrderResponse> fetchAllOrders({
    String? fetchType,
    String? startDate,
    String? endDate,
    String? selectedDay,
    List<String>? selectedMonths,
    List<String>? selectedWeeks,
    int? year,
    OrderStatus? orderStatus,
    required dynamic orderType,
    bool isLogin = false,
  }) async {
    Object? sendData;
    switch (fetchType) {
      case "Month":
        sendData = selectedMonths;
        break;
      case "Week":
        sendData = selectedWeeks;
        break;
      case "Day":
        sendData = [selectedDay];
        break;
      case "Year":
        sendData = year;
        break;
      case "Range":
        sendData = [startDate, endDate];
        break;
      default:
        sendData = selectedMonths;
    }

    final requestBody = isLogin
        ? {
            "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
            "order_type": orderType,
            "categories_id": "",
            "customer_id": "",
            "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
            "time_range": "Month",
            "selected_range": [DateFormat('MMMM').format(DateTime.now())],
            "payment_type": "",
            "year": DateTime.now().year,
            "limit": 1000,
            "page": 1,
          }
        : {
            "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
            "order_type": orderType,
            "categories_id": "",
            "customer_id": "",
            "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
            "time_range": fetchType,
            "selected_range": sendData,
            "payment_type": "",
            "year": fetchType == "Year" ? year : DateTime.now().year,
            "limit": 1000,
            "page": 1,
          };

    log("Request Body: $requestBody");
    final cacheKey =
        '${SessionHelper.loginSavedData?.company_id ?? -1}_orders_$orderType';
    final orderBox = Hive.box('fetchAllOrdersBox');
    try {
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        log("Retrieving data from cache with key: $cacheKey");
        final cachedData = orderBox.get(cacheKey);
        if (cachedData != null) {
          log("Cached data found: $cachedData");
          final castedData = LocalStorage()
              .castToStringDynamic(Map<dynamic, dynamic>.from(cachedData));
          return OrderResponse.fromJson(castedData);
        }
      }

      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchAllOrderByRange,
        requestData: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        log('Fetch All Orders Response: $jsonResponse');
        await orderBox.put(cacheKey, jsonResponse);
        return OrderResponse.fromJson(Map<String, dynamic>.from(jsonResponse));
      } else {
        throw Exception('Failed to fetch orders - ${response.statusCode}');
      }
    } on SocketException {
      log("Network error, attempting to fetch cached data for key: $cacheKey");
      final cachedData = orderBox.get(cacheKey);
      if (cachedData != null) {
        log("Using cached data after network failure: $cachedData");
        final castedData = LocalStorage()
            .castToStringDynamic(Map<dynamic, dynamic>.from(cachedData));
        return OrderResponse.fromJson(castedData);
      } else {
        throw Exception('Network error, and no cached data is available.');
      }
    } catch (e) {
      log('Unexpected error occurred: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<OrderResponse> fetchCustomerDashOrders({
    required String cusId,
    required String salesmanId,
    required String startDate,
    required String endDate,
    required dynamic orderType,
    OrderStatus? orderStatus,
  }) async {
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "customer_id": cusId,
      "salesman_id": '',
      "order_type": orderType,
      "payment_type": "1",
      "start_date": startDate,
      "end_date": endDate,
      "limit": 1000,
      "page": 1,
    };

    log("Request Body Of fetchCustomerDashOrders: $requestBody");

    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final cacheKey = '${companyId}_${cusId}_$orderType';
    // '${companyId}_${cusId}_${salesmanId}_${startDate}_${endDate}_${orderType}';
    final customerDashOrdersBox = await Hive.openBox('customerDashOrdersBox');

    try {
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerDashOrdersBox.get(cacheKey);
        if (cachedData != null) {
          log('[CACHE-HIT] Loaded orders from Hive for key: $cacheKey');
          return OrderResponse.fromJson(Map<String, dynamic>.from(cachedData));
        } else {
          log('[CACHE-MISS] No cached data for key: $cacheKey');
        }
      }

      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchAllOrders,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        log('Fetch All Orders Response: $jsonResponse');

        Pagination pagination =
            Pagination.fromJson(jsonResponse['pagination'] ?? {});
        List<dynamic>? orderData = jsonResponse['data'] as List<dynamic>?;

        log('Fetch All Orders Customer Pagination: [${pagination.totalRecord}]');

        List<OrdersDash> orders = [];
        if (orderData != null) {
          orders = orderData
              .map((json) => OrdersDash.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        // Cache the result
        await customerDashOrdersBox.put(
            cacheKey, Map<String, dynamic>.from(jsonResponse));
        log('[CACHE-SAVE] Saving orders to Hive for key: $cacheKey');

        return OrderResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: orders,
          pagination: pagination,
        );
      } else {
        handleExceptionMessage(response: response, apiName: "fetch all orders");
        throw Exception('Failed to fetch orders - [${response.statusCode}]');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "fetch all orders", error: error);

      final cachedData = customerDashOrdersBox.get(cacheKey);
      if (cachedData != null) {
        log('[CACHE-HIT] Loaded cached orders after error for key: $cacheKey');
        log('[CACHE-HIT] Loaded cached orders : ${OrderResponse.fromJson(Map<String, dynamic>.from(cachedData))}');
        return OrderResponse.fromJson(Map<String, dynamic>.from(cachedData));
      }

      throw Exception('Failed to fetch orders: $error');
    }
  }

  Future<SalesmanResponse> fetchSalesmanDetails({required String token}) async {
    final requestBody = {
      "sales_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "company_id": SessionHelper.loginSavedData?.company_id ?? 0
    };
    log('The Token $token');
    const hiveKey = 'salesmanDetails';
    final adminBox = await Hive.openBox('adminBox');
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      try {
        final response = await responsePostMethod(
          requestData: requestBody,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
          endPoint: ApiConstants.fetchSalesStaffDetails,
        );
        if (response.statusCode == 200) {
          var jsonResponse = response.data;
          List<SalesmanData> adminDetails = (jsonResponse['data'] as List)
              .map((json) => SalesmanData.fromJson(json))
              .toList();
          await adminBox.put(
            hiveKey,
            adminDetails.map((admin) => admin.toJson()).toList(),
          );
          return SalesmanResponse(
            statusCode: jsonResponse['status_code'],
            status: jsonResponse['status'],
            message: jsonResponse['message'],
            data: adminDetails,
          );
        } else {
          handleExceptionMessage(response: response, apiName: "admin on popup");
          throw Exception('Failed to load admin details');
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "admin on popup", error: error);
      }
    }
    try {
      final cachedData = adminBox.get(hiveKey);
      if (cachedData is List) {
        List<SalesmanData> adminDetails = cachedData
            .map((data) => SalesmanData.fromJson(
                  LocalStorage().castToStringDynamic(data),
                ))
            .toList();

        return SalesmanResponse(
          statusCode: 200,
          status: true,
          message: 'Fetched from cache',
          data: adminDetails,
        );
      }
    } catch (e) {}

    throw Exception('Failed to fetch admin details from API and Hive.');
  }

  Future<CustomerResponseModelxx> fetchCustomer({
    required String salesmanId,
    required String customerName,
    required String startDate,
    required String endDate,
    required int limit,
    required int page,
    required dynamic valueFromDw,
  }) async {
    log("valueFromDw: $valueFromDw");

    dynamic value;
    if (valueFromDw == 'This Month') {
      value = 'This Month';
    } else if (valueFromDw == 'Today') {
      value = 'Today';
    } else if (valueFromDw == 'This Week') {
      value = 'This Week';
    } else if (valueFromDw == 'This Year') {
      value = 'This Year';
    } else if (valueFromDw.toString().contains('Range')) {
      value = valueFromDw;
    }

    final requestBody = {
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "business_name": customerName,
      "start_date": startDate,
      "end_date": endDate,
      "limit": limit,
      "page": page,
      "valueFromDw": value,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    final customerBox = Hive.box('customerBox');

    final cacheKey =
        '${SessionHelper.loginSavedData?.company_id ?? -1}_customer_list_$page';

    log('[fetchCustomer] Requesting page: $page, cacheKey: $cacheKey');

    try {
      log('API URL: ${ApiConstants.fetchCustomer}');
      log('Customer Request Body: $requestBody');

      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchCustomer,
        requestData: requestBody,
      );

      log('fetchCustomer : ${response.statusCode}');
      log('fetchCustomer Body: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        if (jsonResponse['status'] != true) {
          throw Exception('API returned error: ${jsonResponse['message']}');
        }

        final customers = (jsonResponse['data'] as List?)
                ?.where((json) => json != null)
                .map((json) => CustomerModelxx.fromJson(json))
                .toList() ??
            [];

        final orderTotal = (jsonResponse['orderTotal'] as List?)
                ?.where((json) => json != null)
                .map((json) => OrderTotalxx.fromJson(json))
                .toList() ??
            [];

        final yearList = (jsonResponse['years_list_of_all'] as List?)
                ?.where((json) => json != null)
                .map((json) => YearsListOfAll.fromJson(json))
                .toList() ??
            [];

        await customerBox.put(cacheKey, jsonResponse);
        log('Customer List Length: ${customers.length}');

        return CustomerResponseModelxx(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: customers,
          orderTotal: orderTotal,
          pagination: Paginationxx.fromJson(jsonResponse['pagination'] ?? {}),
          yearsListOfAll: yearList,
        );
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('Customer Exception: $e');

      handleHttpResponseError(
        statusCode: e is http.Response ? e.statusCode : 0,
        showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
        message: 'Customer',
      );

      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) log('Using cached data due to offline mode');

      final cachedData = customerBox.get(cacheKey);

      if (cachedData != null) {
        final castedData = castToStringDynamic(cachedData);

        final customers = (castedData['data'] as List?)
                ?.where((json) => json != null)
                .map((json) => CustomerModelxx.fromJson(json))
                .toList() ??
            [];

        final orderTotal = (castedData['orderTotal'] as List?)
                ?.where((json) => json != null)
                .map((json) => OrderTotalxx.fromJson(json))
                .toList() ??
            [];

        final yearList = (castedData['years_list_of_all'] as List?)
                ?.where((json) => json != null)
                .map((json) => YearsListOfAll.fromJson(json))
                .toList() ??
            [];

        return CustomerResponseModelxx(
          statusCode: castedData['status_code'] ?? 0,
          status: castedData['status'] ?? false,
          message: castedData['message'] ?? '',
          data: customers,
          orderTotal: orderTotal,
          pagination: Paginationxx.fromJson(castedData['pagination'] ?? {}),
          yearsListOfAll: yearList,
        );
      } else {
        handleHttpResponseError(
          statusCode: 0,
          showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
          message: 'No cached data available',
        );
        throw Exception('No cached data available');
      }
    }
  }

  // Future<bool> addEvent(
  //     String customerId, int eventStatus, List<String> daysList) async {
  //   final String daysJson = jsonEncode(daysList);
  //   final url = Uri.parse('$_baseUrl/add_events');
  //   final bodyMap = {
  //     'customer_id': customerId,
  //     'event_status': eventStatus,
  //     'days_list': daysJson,
  //     'companyId': SessionHelper.loginSavedData?.company_id ?? 0,
  //   };

  //   final body = jsonEncode(bodyMap);

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: body,
  //     );
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<AddEvent> addEvent(
    String customerId,
    int eventStatus,
    List<String> daysList,
    String period,
    BuildContext context,
  ) async {
    final String daysJson = jsonEncode(daysList);

    final bodyMap = {
      'customer_id': customerId,
      'event_status': eventStatus.toString(),
      'days_list': daysJson,
      'period': period,
      'companyId': SessionHelper.loginSavedData?.company_id ?? 0,
    };

    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.addEvents,
        requestData: bodyMap,
      );

      final AddEvent result = AddEvent.fromJson(response.data);
      result.statusCode = response.statusCode ?? 0;

      if (response.statusCode != 200) {
        showCustomToastDisplay(
          context,
          result.message,
          red,
          Icons.close,
        );
        await Future.delayed(const Duration(seconds: 3));
      }

      return result;
    } catch (e) {
      log('🔥 Exception in addEvent: $e');

      showCustomToastDisplay(
        context,
        "Please Assign Staff",
        red,
        Icons.close,
      );

      await Future.delayed(const Duration(seconds: 3));
      rethrow;
    }
  }

  Future<Box> getHiveBoxSafely(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Map<String, dynamic> ensureStringKeyedMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Recursively process all values
      return data.map((key, value) => MapEntry(key, _convertValue(value)));
    }
    if (data is Map) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        final newKey = key is String ? key : key.toString();
        result[newKey] = _convertValue(value);
      });
      return result;
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return ensureStringKeyedMap(decoded);
      }
      throw Exception('Decoded string is not a Map: ${data.runtimeType}');
    }
    throw Exception('Unsupported cached data format:  [${data.runtimeType}]');
  }

  // Helper for recursive value conversion
  // Handles nested maps and lists
  // (kept private to this file)
  dynamic _convertValue(dynamic value) {
    if (value is Map) {
      return ensureStringKeyedMap(value);
    } else if (value is List) {
      return value.map(_convertValue).toList();
    } else {
      return value;
    }
  }

  Future<ApiResponseModel> fetchCustomerDashboardDataa(String customerId,
      int specifiedYear, String startDate, String endDate) async {
    final customerDashboardBox = await getHiveBoxSafely('customerdashboardBox');
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "customer_id": customerId,
      "end_date": endDate,
      "specifiedYear": specifiedYear,
      "start_date": startDate,
    };

    log("customer dash request : $requestBody");
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerDashboardBox.get(customerId);
        if (cachedData != null) {
          log("Full cachedData for customerId $customerId: ${jsonEncode(ensureStringKeyedMap(cachedData))}");
          log("Returning cached dashboard data for customerId: $customerId");
          final safeMap = ensureStringKeyedMap(cachedData);
          return ApiResponseModel.fromJson(safeMap);
        } else {
          log("No cachedData found for customerId $customerId");
          throw Exception(
              'No cached data available for customerId: $customerId');
        }
      }
      final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.customerDashboardList,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ));
      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        await customerDashboardBox.put(
          customerId,
          Map<String, dynamic>.from(jsonResponse),
        );
        log("Data fetched and stored for customerId: $customerId");
        return ApiResponseModel.fromJson(ensureStringKeyedMap(jsonResponse));
      } else {
        handleExceptionMessage(
          response: response,
          apiName: "customer dashboard data",
        );
        throw Exception(
          'Failed to fetch customer dashboard data - Status: ${response.statusCode}',
        );
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "customer dashboard data",
          error: error);
      final cachedData = customerDashboardBox.get(customerId);
      if (cachedData != null) {
        log("Full cachedData for customerId $customerId (after error): ${jsonEncode(ensureStringKeyedMap(cachedData))}");
        log("Returning cached dashboard data after error for customerId: $customerId");
        final safeMap = ensureStringKeyedMap(cachedData);
        return ApiResponseModel.fromJson(safeMap);
      } else {
        log("No cachedData found for customerId $customerId (after error)");
        throw Exception('No cached data available for customerId: $customerId');
      }
    }
  }

  Future<CustomerTotalSaleResponse> fetchCustomerTotalSale(
      String customerId, int year) async {
    final customerTotalSaleBox = await getHiveBoxSafely('customerTotalSaleBox');
    final requestBody = {
      "customer_id": customerId,
      "year": year,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };
    log("customer dash request total sale : $requestBody");
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cacheKey =
            '${SessionHelper.loginSavedData?.company_id ?? -1}_${customerId}_$year';
        final cachedData = customerTotalSaleBox.get(cacheKey);
        if (cachedData != null) {
          log("Returning cached total sale data for customerId: $customerId, year: $year");
          final safeMap = ensureStringKeyedMap(cachedData);
          log("Using cached total sale data for customerId: $customerId, year: $year");
          return CustomerTotalSaleResponse.fromJson(safeMap);
        } else {
          throw Exception(
              'No cached data available for customerId: $customerId, year: $year');
        }
      }
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.customerTotalSale,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      log('API Response: ${response.data}');
      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        log('Parsed JSON: $jsonResponse');
        PaymentCompleted paymentCompleted = PaymentCompleted.fromJson(
            jsonResponse['data']['total_sale']['payment_completed']);
        PaymentRemaining paymentRemaining = PaymentRemaining.fromJson(
            jsonResponse['data']['total_sale']['payment_remaning']);
        List<DiscountData> discountData = [];
        if (jsonResponse['data']['discount_data'] != null) {
          discountData = (jsonResponse['data']['discount_data'] as List)
              .map((json) => DiscountData.fromJson(json))
              .toList();
        }
        final cacheKey =
            '${SessionHelper.loginSavedData?.company_id ?? -1}_${customerId}_$year';
        await customerTotalSaleBox.put(
          cacheKey,
          Map<String, dynamic>.from(jsonResponse),
        );
        log("Data stored in Hive for customerId: $customerId, year: $year");

        return CustomerTotalSaleResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: Datas(
            totalSale: TotalSale(
              paymentCompleted: paymentCompleted,
              paymentRemaining: paymentRemaining,
            ),
            discountData: discountData,
          ),
        );
      } else {
        log('Error Response: ${response.data}');
        throw Exception(
            'Failed to fetch customer total sale data - ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "customer total sale",
          error: error);
      final cacheKey =
          '${SessionHelper.loginSavedData?.company_id ?? -1}_${customerId}_$year';
      final cachedData = customerTotalSaleBox.get(cacheKey);
      if (cachedData != null) {
        log("Returning cached total sale data after error for customerId: $customerId, year: $year");
        final safeMap = ensureStringKeyedMap(cachedData);
        log("Using cached total sale data after error for customerId: $customerId, year: $year");
        return CustomerTotalSaleResponse.fromJson(safeMap);
      } else {
        throw Exception(
            'No cached data available for customerId: $customerId, year: $year');
      }
    }
  }

  Future<CustomerRevenueResponse> fetchCustomerRevenueData(String customerId,
      int specifiedYear, String startDate, String endDate) async {
    final customerRevenueBox = await getHiveBoxSafely('customerRevenueBox');
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "customer_id": customerId,
      "end_date": endDate,
      "start_date": startDate,
      "year": specifiedYear,
    };

    log("customer dash request revenue : $requestBody");
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerRevenueBox.get(customerId);
        if (cachedData != null) {
          final safeMap = ensureStringKeyedMap(cachedData);
          log("Using cached revenue data for customerId: $customerId");
          return LocalStorage().storedCustomerRevenueData(safeMap, customerId);
        } else {
          throw Exception(
              'No cached data available for customerId: $customerId');
        }
      }
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.customerRevenue,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        await customerRevenueBox.put(
          customerId,
          Map<String, dynamic>.from(responseData),
        );
        log("Data fetched and stored for customerId: $customerId");
        return CustomerRevenueResponse.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to load customer revenue data - Status: ${response.statusCode}',
        );
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: "customer revenue", error: error, response: error.response);
      log("Error occurred while fetching revenue data: $error");
      final cachedData = customerRevenueBox.get(customerId);
      if (cachedData != null) {
        final safeMap = ensureStringKeyedMap(cachedData);
        log("Using cached revenue data after error for customerId: $customerId");
        return LocalStorage().storedCustomerRevenueData(safeMap, customerId);
      } else {
        throw Exception('No cached data available for customerId: $customerId');
      }
    }
  }

  Future<ApiResponsees> fetchOrderCount(
    String customerId,
    String startDate,
    String endDate,
  ) async {
    final orderCountBox = await getHiveBoxSafely('orderCountBox');
    final cacheKey =
        // '${SessionHelper.loginSavedData?.company_id ?? -1}_${customerId}_$startDate$endDate';
        '${SessionHelper.loginSavedData?.company_id ?? -1}_$customerId';

    log("ORDER COUNT GET CACHE KEY : $cacheKey");

    final requestBody = {
      "salesman_id": SessionHelper.loginSavedData?.salesmanId,
      "customer_id": customerId,
      "start_date": startDate,
      "end_date": endDate,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    log("Count Request Body: $requestBody");

    try {
      final bool isOnline = await ConnectivityService().isOnline();

      if (!isOnline) {
        final cachedData = orderCountBox.get(cacheKey);
        if (cachedData != null) {
          final safeMap = ensureStringKeyedMap(cachedData);
          log("📦 Using cached order count data (offline)");
          log("safeMap type: ${safeMap.runtimeType}");
          log("safeMap['data'] type: ${safeMap['data'].runtimeType}");
          return ApiResponsees.fromJson(safeMap);
        } else {
          throw Exception('No cached data available for order count.');
        }
      }

      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchOrderCount,
        requestData: requestBody,
      );

      log('📨 Order Count Response: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        // Cache data
        await orderCountBox.put(
            cacheKey, Map<String, dynamic>.from(jsonResponse));
        log("✅ Cached order count data for $cacheKey");

        return ApiResponsees.fromJson(ensureStringKeyedMap(jsonResponse));
      } else {
        throw Exception('Failed to fetch order count - ${response.statusCode}');
      }
    } catch (e) {
      log('🔥 Exception: $e');
      final cachedData = orderCountBox.get(cacheKey);
      if (cachedData != null) {
        final safeMap = ensureStringKeyedMap(cachedData);
        log("📦 Using cached order count data after error");
        log("safeMap type: ${safeMap.runtimeType}");
        log("safeMap['data'] type: ${safeMap['data'].runtimeType}");
        return ApiResponsees.fromJson(safeMap);
      } else {
        throw Exception('No cached data available for order count.');
      }
    }
  }

  Future<CustomerResponse> fetchOneCustomer(String customerId) async {
    final requestBody = {"customer_id": customerId, "companyId": companyId};
    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchOneCustomer,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        List<CustomerDashMo> customers = [];
        if (jsonResponse['data'] != null) {
          customers = (jsonResponse['data'] as List)
              .map((json) => CustomerDashMo.fromJson(json))
              .toList();
        }

        return CustomerResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: customers,
        );
      } else {
        throw Exception(
            'Failed to fetch customer data from fetchOneCustomer- ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: "fetch one customer",
          error: error,
          response: error.response);
      throw Exception(
          'Failed to fetch customer data fetchOneCustomer exception: $error');
    }
  }

  Future<void> updateCustomerDashDetails({
    required CustomerDashMo model,
    required File adminProfilePicture,
    required String customerId,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.updateCustomer}');
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    try {
      var request = http.MultipartRequest('PATCH', url);
      request.fields['fullname'] = model.fullname;
      request.fields['email'] = model.email;
      request.fields['mobileno'] = model.mobileno;
      request.fields['town'] = model.town;
      request.fields['address'] = model.address;
      request.fields['zipcode'] = model.zipcode.toString();
      request.fields['state'] = model.state;
      request.fields['businessname'] = model.businessName;
      request.fields['businesscontact'] = model.businessNo.toString();
      request.fields['remark'] = model.remark.toString();
      request.fields['oldimage_url'] = 'a';
      request.fields['customer_id'] = customerId;
      request.fields['companyId'] = companyId.toString();
      var fileStream = http.ByteStream(adminProfilePicture.openRead());
      var length = await adminProfilePicture.length();
      var multipartFile = http.MultipartFile(
        'cutomerpicture',
        fileStream,
        length,
        filename: adminProfilePicture.path.split('/').last,
      );
      request.files.add(multipartFile);
      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update admin details');
      }
    } catch (e) {
      throw Exception('Failed to update admin details: $e');
    }
  }

  Future<void> addCustomer(
      {required Map<String, dynamic> model,
      required File adminProfilePicture,
      required String salesmanId}) async {
    ApiWorker().addCustomer2(
        model: model,
        adminProfilePicture: adminProfilePicture,
        salesmanId: salesmanId);
  }

  Future<void> addLead({
    required CustomerDashMo model,
    required File adminProfilePicture,
    required String salesmanId,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.addCustomer}');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['fullname'] = model.fullname;
      request.fields['email'] = model.email;
      request.fields['mobileno'] = model.mobileno;
      request.fields['town'] = model.town;
      request.fields['address'] = model.address;
      request.fields['zipcode'] = model.zipcode.toString();
      request.fields['state'] = model.state;
      request.fields['businessname'] = model.businessName;
      request.fields['businesscontact'] = model.businessNo.toString();
      request.fields['remark'] = model.remark.toString();
      request.fields['oldimage_url'] = 'a';
      request.fields['salesman_id'] = salesmanId;
      request.fields['status_type'] = '3';
      var fileStream = http.ByteStream(adminProfilePicture.openRead());
      var length = await adminProfilePicture.length();
      var multipartFile = http.MultipartFile(
        'cutomerpicture',
        fileStream,
        length,
        filename: adminProfilePicture.path.split('/').last,
      );
      request.files.add(multipartFile);
      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update admin details');
      }
    } catch (e) {
      throw Exception('Failed to update admin details: $e');
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

  /// Updates the cached drafts in customerDashOrdersBox and fetchAllOrdersBox after items are saved and sent
  /// This method removes the sent items from the cached drafts and updates the totals
  Future<void> updateCachedDraftsAfterSaveAndSend(
    BuildContext? context, {
    required String customerId,
    required String draftId,
    required String salesmanId,
    required String startDate,
    required String endDate,
    required dynamic orderType,
    required List<String> sentCartIds,
    required double sentAmount,
  }) async {
    try {
      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      final cacheKey = '${companyId}_${customerId}_4';
      final cacheKeyDash = '${companyId}_orders_4';
      // '${companyId}_${customerId}_${salesmanId}_${startDate}_${endDate}_$orderType';
      final customerDashOrdersBox = await Hive.openBox('customerDashOrdersBox');
      final orderBox = await Hive.openBox('fetchAllOrdersBox');

      // Get the current cached data
      final cachedData = customerDashOrdersBox.get(cacheKey);
      if (cachedData == null) {
        log('[updateCachedDraftsAfterSaveAndSend] No cached data found for key: $cacheKey');
        return;
      }
      final cachedDataDash = orderBox.get(cacheKeyDash);
      if (cachedDataDash == null) {
        log('[updateCachedDraftsDashboardAfterSaveAndSend] No cached data found for key: $cacheKeyDash');
        return;
      }

      final Map<String, dynamic> cachedMap =
          Map<String, dynamic>.from(cachedData);
      final List<dynamic>? orderData = cachedMap['data'] as List<dynamic>?;

      final Map<String, dynamic> cachedMapDash =
          Map<String, dynamic>.from(cachedDataDash);
      final List<dynamic>? orderDataDash =
          cachedMapDash['data'] as List<dynamic>?;

      if (orderData == null) {
        return;
      }

      if (orderData.isNotEmpty) {
        final targetOrder = Map<String, dynamic>.from(orderData[0]);
        final targetIndex = 0;

        if (targetIndex >= 0) {
          final currentTotal = (targetOrder['order_total'] ?? 0.0).toDouble();
          final newTotal = currentTotal - sentAmount;

          final finalTotal =
              newTotal > 0 ? double.parse(newTotal.toStringAsFixed(2)) : 0.0;

          if (finalTotal == 0.0) {
            await customerDashOrdersBox.delete(cacheKey);

            // Update fetchAllOrdersBox - remove draft for this customer
            if (orderDataDash != null && orderDataDash.isNotEmpty) {
              // Find and remove drafts for this specific customer
              final updatedOrderDataDash = <dynamic>[];
              for (var order in orderDataDash) {
                final orderMap = Map<String, dynamic>.from(order);
                final orderCustomerId = orderMap['customer_id']?.toString();

                // Keep orders that don't match this customer
                if (orderCustomerId != customerId) {
                  updatedOrderDataDash.add(order);
                } else {
                  // For this customer, check if order total becomes 0 after subtracting sentAmount
                  final currentOrderTotal =
                      (orderMap['order_total'] ?? 0.0).toDouble();
                  final newOrderTotal = currentOrderTotal - sentAmount;
                  final finalOrderTotal = newOrderTotal > 0
                      ? double.parse(newOrderTotal.toStringAsFixed(2))
                      : 0.0;

                  // Only keep the order if the final total is greater than 0
                  if (finalOrderTotal > 0) {
                    orderMap['order_total'] = finalOrderTotal;
                    updatedOrderDataDash.add(orderMap);
                    log('[updateCachedDraftsAfterSaveAndSend] Updated order total for customer $customerId in fetchAllOrdersBox: $finalOrderTotal');
                  } else {
                    log('[updateCachedDraftsAfterSaveAndSend] Removed draft for customer $customerId from fetchAllOrdersBox (total became 0)');
                  }
                }
              }

              final updatedCachedDataDash = {
                ...cachedMapDash,
                'data': updatedOrderDataDash,
              };
              await orderBox.put(cacheKeyDash, updatedCachedDataDash);
              log('[updateCachedDraftsAfterSaveAndSend] Updated fetchAllOrdersBox for customer $customerId');
            }

            {
              ApiResponsees dataToBeModified;
              final orderCountBox = await getHiveBoxSafely('orderCountBox');
              final cacheKey =
                  '${SessionHelper.loginSavedData?.company_id ?? -1}_$customerId';

              final cachedData = orderCountBox.get(cacheKey);
              if (cachedData != null) {
                final safeMap = ensureStringKeyedMap(cachedData);
                dataToBeModified = ApiResponsees.fromJson(safeMap);
                dataToBeModified.data.draftOrder = 0;
                await orderCountBox.put(cacheKey, dataToBeModified.toJson());
              } else {
                log("[COUNT_REMOVE] ❌ No cached data found for key: $cacheKey");
              }
            }

            // Update dashboard data - decrement draftOrder count
            {
              final dashboardBox = Hive.box('dashboardBox');
              final cachedDashboardData = dashboardBox.get('dashboardData');
              if (cachedDashboardData != null) {
                try {
                  final dashboardJson = jsonDecode(cachedDashboardData);
                  final Map<String, dynamic> dashboardMap =
                      Map<String, dynamic>.from(dashboardJson);

                  // Navigate to the orderCountList and update draftOrder
                  if (dashboardMap['data'] != null &&
                      dashboardMap['data']['order_count_list'] != null) {
                    final orderCountList = dashboardMap['data']
                        ['order_count_list'] as Map<String, dynamic>;

                    // Handle the draft_order value which might be a string or int
                    final currentDraftCountRaw =
                        orderCountList['draft_order'] ?? 0;
                    final currentDraftCount = currentDraftCountRaw is String
                        ? int.tryParse(currentDraftCountRaw) ?? 0
                        : (currentDraftCountRaw as int? ?? 0);

                    final newDraftCount = currentDraftCount - 1;

                    // Ensure the count doesn't go below 0
                    orderCountList['draft_order'] =
                        newDraftCount >= 0 ? newDraftCount.toString() : "0";

                    // Update the dashboard data
                    await dashboardBox.put(
                        'dashboardData', jsonEncode(dashboardMap));
                    log('[updateCachedDraftsAfterSaveAndSend] Updated dashboard draftOrder count: $newDraftCount');
                  } else {
                    log('[updateCachedDraftsAfterSaveAndSend] Could not find orderCountList in dashboard data');
                  }
                } catch (e) {
                  log('[updateCachedDraftsAfterSaveAndSend] Error updating dashboard data: $e');
                }
              } else {
                log('[updateCachedDraftsAfterSaveAndSend] No cached dashboard data found');
              }
            }

            final cusProvider =
                Provider.of<CustomersProvider>(context!, listen: false);
            cusProvider.fetchCustomerDashboardCountData(customerId);

            return;
          }

          targetOrder['order_total'] = finalTotal;

          if (targetOrder['cart'] != null && targetOrder['cart'] is List) {
            List<dynamic> cartItems = List.from(targetOrder['cart']);
            log("[updateCachedDraftsAfterSaveAndSend] Cart items before update: ${cartItems.length}");
            targetOrder['cart'] = cartItems;
          }

          orderData[targetIndex] = targetOrder;

          final updatedCachedData = {
            ...cachedMap,
            'data': orderData,
          };

          await customerDashOrdersBox.put(cacheKey, updatedCachedData);

          // Update fetchAllOrdersBox - modify order total for this customer
          if (orderDataDash != null && orderDataDash.isNotEmpty) {
            final updatedOrderDataDash = <dynamic>[];
            for (var order in orderDataDash) {
              final orderMap = Map<String, dynamic>.from(order);
              final orderCustomerId = orderMap['customer_id']?.toString();

              if (orderCustomerId == customerId) {
                // Update the order total for this customer
                final currentOrderTotal =
                    (orderMap['order_total'] ?? 0.0).toDouble();
                final newOrderTotal = currentOrderTotal - sentAmount;
                final finalOrderTotal = newOrderTotal > 0
                    ? double.parse(newOrderTotal.toStringAsFixed(2))
                    : 0.0;

                orderMap['order_total'] = finalOrderTotal;
                log('[updateCachedDraftsAfterSaveAndSend] Updated order total for customer $customerId in fetchAllOrdersBox: $finalOrderTotal');
              }
              updatedOrderDataDash.add(orderMap);
            }

            final updatedCachedDataDash = {
              ...cachedMapDash,
              'data': updatedOrderDataDash,
            };
            await orderBox.put(cacheKeyDash, updatedCachedDataDash);
          }
        } else {
          log('[updateCachedDraftsAfterSaveAndSend] No matching draft found for draftId: $draftId or cartIds: $sentCartIds');
        }
      } else {
        log('[updateCachedDraftsAfterSaveAndSend] No orders found in cached data');
      }
    } catch (e) {
      log('[updateCachedDraftsAfterSaveAndSend] Error updating cached drafts: $e');
    }
  }
}
