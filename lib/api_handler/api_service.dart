import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart'
    as orderResponseModel;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl1;
  final LocalStorage localStorage = LocalStorage();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Dio dio = Dio();
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;

  ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final jsonString =
            await SessionManager.getStringValue(SpString.spLogin);
        if (jsonString.isNotEmpty) {
          Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          String createdToken = jsonMap['createdToken'];
          options.headers["Authorization"] = "Bearer $createdToken";
          log('Authorization Header Set: Bearer $createdToken');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 ||
            error.response?.statusCode == 400) {
          _handleTokenExpiration();
        }
        return handler.next(error);
      },
    ));
  }
  Future<CustomerRevenueResponse> fetchCustomerRevenueData(
    String customerId,
    int specifiedYear,
    String startDate,
    String endDate,
  ) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final customerRevenueBox = Hive.box('customerRevenueBox');
    final requestBody = {
      "companyId": companyId,
      "customer_id": customerId,
      "end_date": endDate,
      "start_date": startDate,
      "year": specifiedYear,
    };
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerRevenueBox.get(customerId);
        return localStorage.storedCustomerRevenueData(cachedData, customerId);
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
      return localStorage.storedCustomerRevenueData(cachedData, customerId);
    }
  }

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
        // log("GET_DASHBOARD_LIST response: ${response.data}");
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
      "year": 2025,
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
      "year": 2025,
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
    bool isLogin = true,
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
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "order_type": orderType,
      "categories_id": "",
      "customer_id": "",
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "time_range": fetchType,
      "selected_range": sendData,
      "payment_type": "",
      "year": 2025,
      "limit": 1000,
      "page": 1
    };
    log("Fetch All Orders Request : $requestBody");
    final cacheKey = 'orders_$orderType';
    final orderBox = Hive.box('fetchAllOrdersBox');
    try {
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        log("Retrieving data from cache with key: $cacheKey");
        final cachedData = orderBox.get(cacheKey);
        if (cachedData != null) {
          log("Cached data found: $cachedData");
          final convertedData = localStorage
              .castToStringDynamic(cachedData as Map<dynamic, dynamic>);
          log("Converted cached data: $convertedData");
          return OrderResponse.fromJson(convertedData);
        }
      }
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchAllOrderByRange,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        log('Fetch All Orders Response: $jsonResponse');
        await orderBox.put(cacheKey, jsonResponse);
        return OrderResponse.fromJson(jsonResponse);
      } else {
        handleExceptionMessage(
            response: response, apiName: "fetch all order by range");
        throw Exception('Failed to fetch orders - ${response.statusCode}');
      }
    } on SocketException {
      errorSnackbar("Socket Error: Failed to fetch chat");
      log("Network error, attempting to fetch cached data for key: $cacheKey");

      final cachedData = orderBox.get(cacheKey);
      if (cachedData != null) {
        final convertedData = localStorage
            .castToStringDynamic(cachedData as Map<dynamic, dynamic>);
        log("Using cached data after network failure: $convertedData");
        return OrderResponse.fromJson(convertedData);
      } else {
        throw Exception('Network error, and no cached data is available.');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "fetch all order by range",
          error: error);
      log('Unexpected error occurred: $error');
      final cachedData = orderBox.get(cacheKey);
      if (cachedData != null) {
        final convertedData = localStorage
            .castToStringDynamic(cachedData as Map<dynamic, dynamic>);
        log("Using cached data after network failure: $convertedData");
        return OrderResponse.fromJson(convertedData);
      } else {
        throw Exception('Network error, and no cached data is available.');
      }
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
    log("Request Body Of fetchCustomerDashOrders $requestBody");
    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchAllOrders,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        log('Fetch All Orders Response: $jsonResponse');
        Pagination pagination =
            Pagination.fromJson(jsonResponse['pagination'] ?? {});
        List<dynamic>? orderData = jsonResponse['data'] as List<dynamic>?;
        log('Fetch All Orders Customer Pagination: ${pagination.totalRecord}');
        List<OrdersDash> orders = [];
        if (orderData != null) {
          orders = orderData
              .map((json) => OrdersDash.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return OrderResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: orders,
          pagination: pagination,
        );
      } else {
        handleExceptionMessage(response: response, apiName: "fetch all orders");
        throw Exception('Failed to fetch orders - ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "fetch all orders", error: error);
      throw Exception('Failed to fetch orders: $error');
    }
  }

  Future<OrderResponse> fetchCustomerDashOrderstoCart({
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
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "order_type": orderType,
      "payment_type": "1",
      "start_date": startDate,
      "end_date": endDate,
      "limit": 1000,
      "page": 1,
    };
    log("Request Body Of fetchCustomerDashOrderstoCart $requestBody");
    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchAllOrders,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        log('Fetch All Orders Response: $jsonResponse');
        Pagination pagination =
            Pagination.fromJson(jsonResponse['pagination'] ?? {});
        List<dynamic>? orderData = jsonResponse['data'] as List<dynamic>?;
        log('Fetch All Orders Customer Pagination: ${pagination.totalRecord}');

        List<OrdersDash> orders = [];
        if (orderData != null) {
          orders = orderData
              .map((json) => OrdersDash.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return OrderResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: orders,
          pagination: pagination,
        );
      } else {
        handleExceptionMessage(response: response, apiName: "fetch all order");
        throw Exception('Failed to fetch orders - ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "fetch all order", error: error);
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
    String value;
    switch (valueFromDw) {
      case 'Month':
        value = 'This Month';
        break;
      case 'Day':
        value = 'Today';
        break;
      case 'Week':
        value = 'This Week';
        break;
      case 'Year':
        value = 'This Year';
        break;
      case 'Range':
        value = 'Range';
        break;
      default:
        value = "This Month";
        break;
    }
    final requestBody = {
      "salesman_id": salesmanId,
      "business_name": customerName,
      "start_date": startDate,
      "end_date": endDate,
      "limit": limit,
      "page": page,
      "valueFromDw": value,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };
    final customerBox = Hive.box('customerBox');

    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchCustomer,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['status'] != true) {
          throw Exception('API returned error: ${jsonResponse['message']}');
        }
        List<CustomerModelxx> customers = [];
        List<OrderTotalxx> orderTotal = [];
        List<YearsListOfAll> yearList = [];
        if (jsonResponse['data'] is List) {
          customers = (jsonResponse['data'] as List)
              .map((json) => CustomerModelxx.fromJson(json))
              .toList();
        }
        if (jsonResponse['orderTotal'] is List) {
          orderTotal = (jsonResponse['orderTotal'] as List)
              .map((json) => OrderTotalxx.fromJson(json))
              .toList();
        }
        if (jsonResponse['years_list_of_all'] is List) {
          yearList = (jsonResponse['years_list_of_all'] as List)
              .map((json) => YearsListOfAll.fromJson(json))
              .toList();
        }
        await customerBox.put('fetchCustomerData', jsonResponse);
        log('Saved customer data to Hive.');
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
        handleExceptionMessage(
          response: response,
          apiName: "fetch customer",
        );
        return localStorage.storedCustomerData(customerBox);
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "fetch customer", error: error);
      log('DioException: $error');
      return localStorage.storedCustomerData(customerBox);
    } catch (e) {
      log('General Exception: $e');
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        log('Using cached data due to offline mode.');
        return localStorage.storedCustomerData(customerBox);
      }
      throw Exception('Failed to fetch data: $e');
    }
  }
  Future<bool> addEvent(
      String customerId, int eventStatus, List<String> daysList) async {
    final String daysJson = jsonEncode(daysList);
    final url = Uri.parse('$_baseUrl/add_events');
    final bodyMap = {
      'customer_id': customerId,
      'event_status': eventStatus,
      'days_list': daysJson,
      'companyId': SessionHelper.loginSavedData?.company_id ?? 0,
    };

    final body = jsonEncode(bodyMap);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<ApiResponseModel> fetchCustomerDashboardDataa(
    String customerId,
    int specifiedYear,
    String startDate,
    String endDate,
  ) async {
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final int companyId = jsonMap['company_id'];
    final customerDashboardBox = Hive.box('customerdashboardBox');
    final requestBody = {
      "companyId": companyId,
      "customer_id": customerId,
      "end_date": endDate,
      "specifiedYear": specifiedYear,
      "start_date": startDate,
    };
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerDashboardBox.get(customerId);
        if (cachedData != null) {
          log("Returning cached dashboard data for customerId: $customerId");
          if (cachedData is Map<String, dynamic>) {
            return localStorage.customerdashboardResponse(cachedData);
          } else {
            throw Exception(
                'Invalid cached data format for customerId: $customerId');
          }
        } else {
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
        return localStorage.customerdashboardResponse(jsonResponse);
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
        log("Returning cached dashboard data after error for customerId: $customerId");
        if (cachedData is Map<String, dynamic>) {
          return localStorage.customerdashboardResponse(cachedData);
        } else {
          throw Exception(
              'Invalid cached data format for customerId: $customerId');
        }
      } else {
        throw Exception('No cached data available for customerId: $customerId');
      }
    }
  }

  Future<CustomerTotalSaleResponse> fetchCustomerTotalSale(
      String customerId, int year) async {
    final customerTotalSaleBox = Hive.box('customerTotalSaleBox');
    final requestBody = {
      "customer_id": customerId,
      "year": year,
      "companyId": companyId,
    };
    log('Request Body for fetchCustomerTotalSale: $requestBody');
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cacheKey = '${customerId}_$year';
        final cachedData = customerTotalSaleBox.get(cacheKey);
        if (cachedData != null) {
          log("Returning cached total sale data for customerId: $customerId, year: $year");
          if (cachedData is Map<String, dynamic>) {
            return CustomerTotalSaleResponse.fromJson(cachedData);
          } else {
            throw Exception(
                'Invalid cached data format for customerId: $customerId, year: $year');
          }
        } else {
          throw Exception(
              'No cached data available for customerId: $customerId, year: $year');
        }
      }
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.customeTotalSale,
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
        final cacheKey = '${customerId}_$year';
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
      final cacheKey = '${customerId}_$year';
      final cachedData = customerTotalSaleBox.get(cacheKey);
      if (cachedData != null) {
        log("Returning cached total sale data after error for customerId: $customerId, year: $year");
        if (cachedData is Map<String, dynamic>) {
          return CustomerTotalSaleResponse.fromJson(cachedData);
        } else {
          throw Exception(
              'Invalid cached data format for customerId: $customerId, year: $year');
        }
      } else {
        throw Exception(
            'No cached data available for customerId: $customerId, year: $year');
      }
    }
  }

  Future<ApiResponsees> fetchOrderCount(
    String customerId,
    String startDate,
    String endDate,
  ) async {
    final orderCountBox = Hive.box('orderCountBox');
    final requestBody = {
      "salesman_id": SessionHelper.loginSavedData?.salesmanId,
      "customer_id": customerId,
      "start_date": startDate,
      "end_date": endDate,
      "companyId": companyId,
    };
    log("Count Request Body : $requestBody");
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cacheKey = '${customerId}_$startDate$endDate';
        final cachedData = orderCountBox.get(cacheKey);
        if (cachedData != null) {
          log("Returning cached order count data for customerId: $customerId, startDate: $startDate, endDate: $endDate");
          if (cachedData is Map<String, dynamic>) {
            OrderDataas orderData = OrderDataas.fromJson(cachedData['data']);
            return ApiResponsees(
              statusCode: cachedData['status_code'] ?? 0,
              status: cachedData['status'] ?? false,
              message: cachedData['message'] ?? '',
              data: orderData,
            );
          } else {
            throw Exception('Invalid cached data format for order count.');
          }
        } else {
          throw Exception('No cached data available for order count.');
        }
      }
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.fetchOrderCount,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      log('Count Response : ${response.data}');

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        OrderDataas orderData = OrderDataas.fromJson(jsonResponse['data']);
        final cacheKey = '${customerId}_$startDate$endDate';
        await orderCountBox.put(
          cacheKey,
          Map<String, dynamic>.from(jsonResponse),
        );
        log("Data stored in Hive for order count with customerId: $customerId, startDate: $startDate, endDate: $endDate");
        return ApiResponsees(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: orderData,
        );
      } else {
        throw Exception('Failed to fetch order count - ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: "fetch order count", error: error, response: error.response);
      log('Exception: $error');
      final cacheKey = '${customerId}_$startDate$endDate';
      final cachedData = orderCountBox.get(cacheKey);
      if (cachedData != null) {
        log("Returning cached order count data after error for customerId: $customerId, startDate: $startDate, endDate: $endDate");
        if (cachedData is Map<String, dynamic>) {
          OrderDataas orderData = OrderDataas.fromJson(cachedData['data']);
          return ApiResponsees(
            statusCode: cachedData['status_code'] ?? 0,
            status: cachedData['status'] ?? false,
            message: cachedData['message'] ?? '',
            data: orderData,
          );
        } else {
          throw Exception('Invalid cached data format for order count.');
        }
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
      {required CustomerDashMo model,
      required File adminProfilePicture,
      required String salesmanId}) async {
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
      request.fields['status_type'] = '1';
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
}