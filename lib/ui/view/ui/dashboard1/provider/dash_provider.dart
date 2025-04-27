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
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_controller.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart'
    as orderResponseModel;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'dash_models.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
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
        NkCommonFunction.showErrorSnakBar(
            'No Internet Connection. Please check your network');
        final cachedData = dashboardBox.get('dashboardData');
        if (cachedData != null) {
          log("Cached data found. Processing...");
          try {
            final safeData = localStorage
                .castToStringDynamic(Map<dynamic, dynamic>.from(cachedData));
            if (safeData is Map<String, dynamic>) {
              log("Successfully parsed cached data.");
              return localStorage.mapJsonToResponseModel(safeData);
            } else if (safeData is List<dynamic>) {
              log("Successfully parsed cached list data.");
              return localStorage.mapJsonToResponseModel({'data': safeData});
            } else {
              throw FormatException('Invalid cached data format.');
            }
          } catch (e) {
            log("Error parsing cached data: $e");
            await dashboardBox.delete('dashboardData');
            NkCommonFunction.showErrorSnakBar(
                'Cached data is corrupted. Please connect to the internet.');
            throw Exception('Invalid cached data format. Cache cleared.');
          }
        } else {
          throw Exception('No cached data available.');
        }
      }
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.getDashboardList,
        options: Options(
          headers: {'Authorization': 'Bearer $createdToken'},
        ),
      );
      log("GET_DASHBOARD_LIST response: ${response.data}");

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        await dashboardBox.put('dashboardData', jsonResponse);
        return localStorage.mapJsonToResponseModel(jsonResponse);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        _handleTokenExpiration();
        throw Exception('Session expired');
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}, Message: ${response.statusMessage}');
      }
    } on DioException catch (error) {
      log("Caught DioException");
      handleExceptionMessage(
          response: error.response, apiName: "dashboard data", error: error);
      final cachedData = dashboardBox.get('dashboardData');
      if (cachedData != null) {
        try {
          final safeData = localStorage
              .castToStringDynamic(Map<dynamic, dynamic>.from(cachedData));
          if (safeData is Map<String, dynamic>) {
            return localStorage.mapJsonToResponseModel(safeData);
          } else if (safeData is List<dynamic>) {
            return localStorage.mapJsonToResponseModel({'data': safeData});
          } else {
            throw FormatException('Invalid cached data format.');
          }
        } catch (e) {
          log("Error processing cached data after exception: $e");
          await dashboardBox.delete('dashboardData');
          throw Exception('Failed to process cached data after exception.');
        }
      } else {
        throw Exception('No cached data available.');
      }
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
    var sendData;

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
        print('Request failed with status 1: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "category perfromance",
          error: error);
      print('Exception occurred 1: $error');
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
    var sendData;
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
        print('Request failed with status 1: ${response.statusCode}');
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
  }) async {
    var sendData;
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

  Future<AdminResponse> fetchSalesmanDetails({required String token}) async {
    final requestBody = {"token": token};
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
          endPoint: ApiConstants.adminOnPopUp,
        );
        if (response.statusCode == 200) {
          var jsonResponse = response.data;
          List<AdminData> adminDetails = (jsonResponse['data'] as List)
              .map((json) => AdminData.fromJson(json))
              .toList();
          await adminBox.put(
            hiveKey,
            adminDetails.map((admin) => admin.toJson()).toList(),
          );
          return AdminResponse(
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
        List<AdminData> adminDetails = cachedData
            .map((data) => AdminData.fromJson(
                  LocalStorage().castToStringDynamic(data),
                ))
            .toList();

        return AdminResponse(
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

    final url = '$_baseUrl${ApiConstants.fetchCustomer}';
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
    const url = '$_baseUrl${ApiConstants.addEvent}';
    final body = {
      'customer_id': customerId,
      'event_status': eventStatus,
      'days_list': daysJson,
    };

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: body,
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
    final url = '$_baseUrl${ApiConstants.customeTotalSale}';
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

  // Future<CategoryResponse> fetchCategories() async {
  //   const String url = '${ApiConstants.baseUrl}fetch_categories?company_id=1';
  //   // '$_baseUrl/fetch_categories?company_id=1';

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     // Check for a successful response
  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

  //       // Convert JSON to CategoryResponse object
  //       return CategoryResponse.fromJson(jsonResponse);
  //     } else {
  //       throw Exception('Failed to load categories');
  //     }
  //   } catch (e) {
  //     // Handle any errors
  //     //this is the error we get
  //     throw Exception('Error fetching categories: $e');
  //   }
  // }

  // Future<ApiResponseModel> fetchProductData() async {
  //   // const String url = '$_baseUrl/fetch_product?company_id=1';
  //   const String url = '${ApiConstants.baseUrl}fetch_products?company_id=1';
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       return ApiResponseModel.fromJson(jsonResponse);
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load data: $e');
  //   }
  // }
}

class DashboardProvider with ChangeNotifier {
  Future<ResponseModell>? _futureResponseModel;
  Future<SalesmenResponse>? _salesmenResponse;
  Future<MessagesResponse>? _individualChatResponse;

  List<String> _selectedFilterMonths = [];
  List<String> get selectedFilterMonths => _selectedFilterMonths;

  List<orderResponseModel.OrderData> _chartOrderData = [];
  List<orderResponseModel.OrderData> get chartOrderData => _chartOrderData;

  List<TargetDatum> _salesmanTargetByCategory = [];
  List<TargetDatum> get salesmanTargetByCategory => _salesmanTargetByCategory;

  void updateSelectedMonths(List<String> months) {
    _selectedFilterMonths = months;
    notifyListeners();
  }

  List<String> _selectedFilterWeeks = [];
  List<String> get selectedFilterWeeks => _selectedFilterWeeks;

  void updateSelectedWeeks(List<String> Weeks) {
    _selectedFilterWeeks = Weeks;
    notifyListeners();
  }

  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;
  void updateSelectedYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  String _selectedDate = '';
  String get selectedDate => _selectedDate;
  void updateSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  FilterDateEnum _selectedFilter = FilterDateEnum.thisMonth;
  FilterDateEnum _selectedFilterTemp = FilterDateEnum.thisMonth;
  String _selectedFilterName = "Month";
  String _selectedFilterNameTemp = "Month";
  String _selectedStartDate = '';
  String _selectedEndDate = '';

  final ApiService _apiService;
  final Logger _logger;
  bool _dataFetched = false;
  bool get dataFetched => _dataFetched;

  DashboardProvider({required ApiService apiService, required Logger logger})
      : _apiService = apiService,
        _logger = logger {
    fetchData();
    fetchChatData(SessionHelper.loginSavedData?.salesmanId ?? '');
    fetchSalesmanData();
  }

  OrderStatus selectedOrderStatus = OrderStatus.preOrder;

  void selectedOrderStatusd(OrderStatus status) {
    selectedOrderStatus = status;
    notifyListeners(); // Notify listeners when the state changes
  }

  List<String> allCategories = []; // Master list of all categories

  Future<OrderResponse>? _orderResponse;

  Future<OrderResponse>? get orderResponse => _orderResponse;

  Future<AdminResponse>? _adminResponsee;

  Future<AdminResponse>? get adminResponse => _adminResponsee;

  Future<ResponseModelCp>? _responseModelCp;

  Future<ResponseModelCp>? get responseModelCp => _responseModelCp;

  Future<ResponseModelCp>? _responseModelNewCp;
  Future<ResponseModelCp>? get responseModelNewCp => _responseModelNewCp;

  void resetProvider() {
    _futureResponseModel = null;
    _salesmenResponse = null;
    _individualChatResponse = null;
    _selectedFilter = FilterDateEnum.thisMonth;
    _selectedFilterTemp = FilterDateEnum.thisMonth;
    _selectedFilterName = "Month";
    _selectedFilterNameTemp = "Month";
    _selectedStartDate = '';
    _selectedEndDate = '';
  }

  void resetFilter() {
    _selectedFilter = FilterDateEnum.thisMonth;
    _selectedFilterTemp = FilterDateEnum.thisMonth;
    _selectedFilterName = "Month";
    _selectedFilterNameTemp = "Month";
    _selectedStartDate = '';
    _selectedEndDate = '';
  }

  // Future<void> fetchchartCategoryPerformmenc(dynamic catId) async {
  //   try {
  //     final now = DateTime.now();
  //     String startDate;
  //     String endDate;
  //     for (OrderStatus status in OrderStatus.values) {
  //       _selectedStatus = status;

  //       switch (_selectedFilter) {
  //         case FilterDateEnum.thisMonth:
  //           startDate = DateTime(now.year, now.month, 1)
  //               .toIso8601String()
  //               .substring(0, 10);
  //           endDate = DateTime(now.year, now.month + 1, 0)
  //               .toIso8601String()
  //               .substring(0, 10);
  //           break;
  //         case FilterDateEnum.today:
  //           startDate = DateTime(now.year, now.month, now.day)
  //               .toIso8601String()
  //               .substring(0, 10);
  //           endDate = startDate;
  //           break;
  //         case FilterDateEnum.thisWeek:
  //           final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  //           startDate = startOfWeek.toIso8601String().substring(0, 10);
  //           endDate = now.toIso8601String().substring(0, 10);
  //           break;
  //         case FilterDateEnum.thisYear:
  //           startDate =
  //               DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
  //           endDate =
  //               DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
  //           break;
  //         case FilterDateEnum.range:
  //           startDate = _selectedStartDate;
  //           endDate = _selectedEndDate;
  //           break;
  //       }

  //       if (_selectedFilter == FilterDateEnum.range &&
  //           (startDate.isEmpty || endDate.isEmpty)) {
  //         throw Exception('Select both start and end dates');
  //       }
  //       _responseModelCp =
  //           Future.delayed(const Duration(milliseconds: 300), () {
  //         return _apiService.fetchDashboardCategoruPerformenceData(
  //           catId: catId,
  //           startDate: startDate,
  //           endDate: endDate,
  //         );
  //       });
  //       log("Fetching orders for status: $_selectedStatus");
  //     }
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }

  Future<void> fetchchartCategoryPerformmenc(dynamic catId) async {
    try {
      _responseModelCp = Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchDashboardCategoruPerformenceData(
          catId: catId,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchchartValuePerformance(
      String month, String timeRange) async {
    try {
      _responseModelNewCp =
          Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchDashboardValuePerformanceData(
          catId: month,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchChartOrderData(
      String salesmanId, dynamic categoryId) async {
    try {
      _chartOrderData =
          await Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchChartSalesmanOrderData(
          catId: categoryId,
          salesmanId: salesmanId,
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> loadSalesmanTargetByCategory(
      String salesmanId, int categoryId) async {
    try {
      _salesmanTargetByCategory =
          await Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchSalesmanTargetByCategory(
          catId: categoryId,
          salesmanId: salesmanId,
          startDate: _selectedFilter == FilterDateEnum.range
              ? _selectedStartDate
              : null,
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : null,
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : null,
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : null,
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : null,
          year:
              _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : null,
        );
      });

      log("Response: $_salesmanTargetByCategory");
    } catch (e, stackTrace) {
      _logger.e('Error fetching salesman targets',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<SalesmenResponse>? get salesmenResponse => _salesmenResponse;
  Future<ResponseModell>? get futureResponseModel => _futureResponseModel;
  Future<MessagesResponse>? get individualChatResponse =>
      _individualChatResponse;
  FilterDateEnum get selectedFilter => _selectedFilter;
  FilterDateEnum get selectedFilterTemp => _selectedFilterTemp;
  String get selectedStartDate => _selectedStartDate;
  String get selectedEndDate => _selectedEndDate;
  SalesmanChat? selectedChat;
  final salesmanId = SessionHelper.loginSavedData!.salesmanId!;

  Future<void> fetchOrdersSabik(OrderStatus s) async {
    try {
      var orderType;

      switch (s) {
        case OrderStatus.delivered:
          orderType = '';
        case OrderStatus.estimates:
          orderType = 7;
        case OrderStatus.preOrder:
          orderType = 0;
        case OrderStatus.draft:
          orderType = 4;
        case OrderStatus.cancelled:
          orderType = 3;
        default:
          orderType = '';
      }

      _orderResponse = Future.delayed(const Duration(milliseconds: 300), () {
        return _apiService.fetchAllOrders(
          startDate:
              _selectedFilter == FilterDateEnum.range ? _selectedStartDate : '',
          endDate:
              _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
          orderStatus: s,
          orderType: orderType,
          fetchType: _selectedFilterName,
          selectedDay:
              _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
          selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
              ? _selectedFilterMonths
              : [],
          selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
              ? _selectedFilterWeeks
              : [],
          year: _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
        );
      });

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  void onFilterChanged(FilterDateEnum? selectedFilterTemp) async {
    bool isOnline = await ConnectivityService().isOnline();
    switch (selectedFilterTemp) {
      case FilterDateEnum.today:
        selectedFilters(isOnline, "Day");
        break;
      case FilterDateEnum.thisWeek:
        selectedFilters(isOnline, "Week");
        break;
      case FilterDateEnum.thisYear:
        selectedFilters(isOnline, "Year");
        break;
      case FilterDateEnum.thisMonth:
        selectedFilters(isOnline, "Month");
        break;
      case FilterDateEnum.range:
        selectedFilters(isOnline, "Range");
        break;
      default:
        selectedFilters(isOnline, "Month");
        break;
    }

    log('on filter changed');
    if (selectedFilterTemp != null) {
      _selectedFilterTemp = selectedFilterTemp;
      notifyListeners();
    }
  }

  selectedFilters(bool isOnline, String filterName) {
    if (isOnline) {
      _selectedFilterNameTemp = filterName;
    } else {
      NkCommonFunction.showErrorSnakBar(
          'No internet connection. Please check your network');
    }
  }

  Future<void> setTempToFilter() async {
    _selectedFilter = _selectedFilterTemp;
    _selectedFilterName = _selectedFilterNameTemp;
  }

  void selectAllChats(List<SalesmanChat> chatData) {
    selectedChats = List.from(chatData);
    notifyListeners();
  }

  void clearAllSelections() {
    selectedChats.clear();
    notifyListeners();
  }

  Future<void> refreshChatData(String salesmanId) async {
    await fetchChatData(salesmanId);
    notifyListeners();
  }

  Future<void> fetchData() async {
    NotificationController notificationController =
        Get.find<NotificationController>();
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
    try {
      final now = DateTime.now();
      String startDate =
          DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
      String endDate = DateTime(now.year, now.month + 1, 0)
          .toIso8601String()
          .substring(0, 10);
      _futureResponseModel = Future.delayed(const Duration(seconds: 2), () {
        Future<ResponseModell> api = _apiService.fetchDashboardData(
            fetchType: _selectedFilterName,
            startDate: _selectedFilter == FilterDateEnum.range
                ? _selectedStartDate
                : '',
            endDate:
                _selectedFilter == FilterDateEnum.range ? _selectedEndDate : '',
            selectedDay:
                _selectedFilter == FilterDateEnum.today ? _selectedDate : '',
            selectedMonths: _selectedFilter == FilterDateEnum.thisMonth
                ? _selectedFilterMonths
                : [],
            selectedWeeks: _selectedFilter == FilterDateEnum.thisWeek
                ? _selectedFilterWeeks
                : [],
            year:
                _selectedFilter == FilterDateEnum.thisYear ? _selectedYear : 0,
            salesmanId: salesmanId);
        return api;
      });

      notificationController.loadNotificationData(startDate, endDate);
      await CartDatabaseManager().getDraftItems();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_selectedStartDate.isNotEmpty
              ? DateTime.parse(_selectedStartDate)
              : DateTime.now())
          : (_selectedEndDate.isNotEmpty
              ? DateTime.parse(_selectedEndDate)
              : DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (isStartDate) {
        _selectedStartDate = formattedDate;
      } else {
        _selectedEndDate = formattedDate;
      }

      if (_selectedFilter == FilterDateEnum.range &&
          _selectedStartDate.isNotEmpty &&
          _selectedEndDate.isNotEmpty) {}
      notifyListeners();
    }
  }

  Future<SalesmenResponse> fetchChatData(String salesmanId) async {
    try {
      Future<SalesmenResponse> chatData = _apiService.fetchChatData(salesmanId);
      _salesmenResponse = chatData as Future<SalesmenResponse>?;
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching chat data', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch chat data: $e');
    }
  }

  List<Messages>? _individualChatMessages = [];
  List<Messages>? get individualChatMessages => _individualChatMessages;
  bool _noMoreData = false;
  bool get noMoreData => _noMoreData;
  List<SalesmanChat> selectedChats = [];

  void resetNoMoreData() {
    _noMoreData = false;
    notifyListeners();
  }

  // ignore: non_constant_identifier_names
  Future<MessagesResponse> fetch_individual_chat(
      String chatId, int page) async {
    try {
      if (_noMoreData && page > 1) return MessagesResponse(data: []);
      final chatData = await _apiService.fetchIndividualChatApi(chatId, page);

      if (chatData.data.isEmpty && page > 1) {
        _noMoreData = true;
      } else {
        _individualChatMessages ??= [];
        if (page == 1) {
          // ignore: prefer_collection_literals
          _individualChatMessages = [
            ...chatData.data,
            ..._individualChatMessages!,
          ].toSet().toList();
        } else {
          _individualChatMessages!.addAll(chatData.data);
          _individualChatMessages = _individualChatMessages!.toSet().toList();
        }
      }
      notifyListeners();
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching individual chat data',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch individual chat data: $e');
    }
  }

  void addMessages(List<Messages> newMessages) {
    _individualChatMessages ??= [];
    // ignore: prefer_collection_literals
    _individualChatMessages = [
      ...newMessages,
      ..._individualChatMessages!,
    ].toSet().toList();
    notifyListeners();
  }

  void clearSelectedChat() {
    selectedChat = null;
    notifyListeners();
  }

  void toggleChatSelection(SalesmanChat chat) {
    if (selectedChats.contains(chat)) {
      selectedChats.remove(chat);
    } else {
      selectedChats.add(chat);
    }
    notifyListeners();
  }

  Future<AdminResponse> fetchSalesmanData() async {
    try {
      final chatData =
          await _apiService.fetchSalesmanDetails(token: 'AAAAAAAAA');
      _adminResponsee = Future.value(chatData);
      notifyListeners();
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching individual chat data',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch individual chat data: $e');
    }
  }

  OrderStatus _selectedOrderStatuss = OrderStatus.pending;

  OrderStatus get selectedOrderStatuss => _selectedOrderStatuss;

  void setSelectedOrderStatus(OrderStatus status) {
    if (status != _selectedOrderStatuss) {
      _selectedOrderStatuss = status;
      notifyListeners();
    }
  }
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  File? get imageFile => _imageFile;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  final ImagePicker _pickerC = ImagePicker();

  File? get imageFileC => _imageFile;

  Future<void> pickImageCommuni() async {
    final pickedFile = await _pickerC.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      notifyListeners();
    }
  }

  void clearImage() {
    _imageFile = null;
    notifyListeners();
  }

  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  void scrollLeft() {
    if (_scrollController.position.pixels > 0) {
      _scrollController.jumpTo((_scrollController.position.pixels - 100)
          .clamp(0.0, _scrollController.position.maxScrollExtent));
      notifyListeners();
    }
  }

  void scrollRight() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent) {
      _scrollController.jumpTo((_scrollController.position.pixels + 100)
          .clamp(0.0, _scrollController.position.maxScrollExtent));
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
