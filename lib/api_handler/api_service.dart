// ignore_for_file: library_prefixes

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
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
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
  final Dio dio = Dio();
  final companyId = SessionHelper.loginSavedData?.company_id ?? 0;

  Future<ResponseModell> fetchDashboardData({
  String? fetchType,
  String? startDate,
  String? endDate,
  String? selectedDay,
  List<String>? selectedMonths,
  List<String>? selectedWeeks,
  int? year,
}) async {
  final String jsonString = await SessionManager.getStringValue(SpString.spLogin);
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  final String createdToken = jsonMap['createdToken'];

  // 1. Prepare dynamic variable for selected_range (can be List or String)
  dynamic sendData;
  // 2. Prepare time_range variable to handle the lowercase "year" case
  String timeRangePayload = fetchType ?? "Month"; 

  switch (fetchType) {
    case "Month":
      sendData = selectedMonths; // List<String>
      break;
    case "Week":
      sendData = selectedWeeks; // List<String>
      break;
    case "Day":
      // Payload requires List: ["2026-01-14"]
      sendData = selectedDay != null ? [selectedDay] : []; 
      break;
    case "Year":
    case "year":
      // Payload requires String: "2026" AND time_range must be lowercase "year"
      timeRangePayload = "year"; 
      sendData = year.toString(); 
      break;
    case "Range":
      sendData = [startDate, endDate]; // List<String>
      break;
    default:
      sendData = selectedMonths;
  }

  // 3. Construct the Body
  final url = Uri.parse('$_baseUrl/Get_dashboard_list');
  final Map<String, dynamic> requestBody = {
    "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
    "selected_range": sendData,
    "time_range": timeRangePayload,
    "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    // Ensure we send the selected year, or fallback to current year
    "year": year ?? DateTime.now().year, 
  };
print('dashboard list body:$requestBody');
  final dashboardBox = await getHiveBoxSafely('dashboardBox');
  
  try {
    final bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      NkCommonFunction.showErrorSnakBar(
          'No Internet Connection. Please check your network');

      final cachedData = dashboardBox.get('dashboardData');
      if (cachedData != null) {
        try {
          final safeMap = ensureStringKeyedMap(cachedData);
          return _mapJsonToResponseModel(safeMap);
        } catch (e) {
          throw Exception(
              'Failed to process cached data due to type mismatch.');
        }
      } else {
        throw Exception('No cached data available.');
      }
    }
    
    final response = await Dio().post(
      url.toString(),
      options: Options(
        headers: {'Authorization': 'Bearer $createdToken'},
      ),
      data: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      await dashboardBox.put(
          'dashboardData', Map<String, dynamic>.from(jsonResponse));
      return _mapJsonToResponseModel(ensureStringKeyedMap(jsonResponse));
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      _handleTokenExpiration();
      throw Exception('Session expired');
    } else {
      throw Exception(
          'Failed to load data with status code:  [${response.statusCode}');
    }
  } on DioError catch (e) {
    handleHttpResponseError(
        statusCode: e.response?.statusCode ?? 0,
        showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
        message: 'Dashboard');
    final cachedData = dashboardBox.get('dashboardData');
    if (cachedData != null) {
      try {
        final safeCachedData = ensureStringKeyedMap(cachedData);
        return _mapJsonToResponseModel(safeCachedData);
      } catch (e) {
        throw Exception(
            'Failed to process cached data due to type mismatch.');
      }
    } else {
      throw Exception('No cached data available.');
    }
  }
}

  // Future<ResponseModell> fetchDashboardData({
  //   String? fetchType,
  //   String? startDate,
  //   String? endDate,
  //   String? selectedDay,
  //   List<String>? selectedMonths,
  //   List<String>? selectedWeeks,
  //   int? year,
  // }) async {
  //   final String jsonString =
  //       await SessionManager.getStringValue(SpString.spLogin);
  //   final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  //   final String createdToken = jsonMap['createdToken'];

  //   dynamic sendData;

  //   switch (fetchType) {
  //     case "Month":
  //       sendData = selectedMonths;
  //       break;
  //     case "Week":
  //       sendData = selectedWeeks;
  //       break;
  //     case "Day":
  //       sendData = [selectedDay];
  //       break;
  //     case "Year":
  //       sendData = year.toString();
  //       break;
  //     case "Range":
  //       sendData = [startDate, endDate];
  //       break;
  //     default:
  //       sendData = selectedMonths;
  //   }
  //   final url = Uri.parse('$_baseUrl/Get_dashboard_list');
  //   final Map<String, dynamic> requestBody = {
  //     "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
  //     "selected_range": sendData,
  //     "time_range": fetchType == "Year" ? "year" : fetchType,
  //     "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //     "year": fetchType == "Year" ? year : DateTime.now().year,
  //   };
  //   final dashboardBox = await getHiveBoxSafely('dashboardBox');
  //   try {
  //     final bool isOnline = await ConnectivityService().isOnline();
  //     if (!isOnline) {
  //       NkCommonFunction.showErrorSnakBar(
  //           'No Internet Connection. Please check your network');

  //       final cachedData = dashboardBox.get('dashboardData');
  //       if (cachedData != null) {
  //         try {
  //           final safeMap = ensureStringKeyedMap(cachedData);
  //           return _mapJsonToResponseModel(safeMap);
  //         } catch (e) {
  //           throw Exception(
  //               'Failed to process cached data due to type mismatch.');
  //         }
  //       } else {
  //         throw Exception('No cached data available.');
  //       }
  //     }
  //     final response = await Dio().post(
  //       url.toString(),
  //       options: Options(
  //         headers: {'Authorization': 'Bearer $createdToken'},
  //       ),
  //       data: jsonEncode(requestBody),
  //     );
  //     if (response.statusCode == 200) {
  //       final jsonResponse = response.data;
  //       await dashboardBox.put(
  //           'dashboardData', Map<String, dynamic>.from(jsonResponse));
  //       return _mapJsonToResponseModel(ensureStringKeyedMap(jsonResponse));
  //     } else if (response.statusCode == 400 || response.statusCode == 401) {
  //       _handleTokenExpiration();
  //       throw Exception('Session expired');
  //     } else {
  //       throw Exception(
  //           'Failed to load data with status code:  [${response.statusCode}');
  //     }
  //   } on DioException catch (e) {
  //     handleHttpResponseError(
  //         statusCode: e.response?.statusCode ?? 0,
  //         showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
  //         message: 'Dashboard');
  //     final cachedData = dashboardBox.get('dashboardData');
  //     if (cachedData != null) {
  //       try {
  //         final safeCachedData = ensureStringKeyedMap(cachedData);
  //         return _mapJsonToResponseModel(safeCachedData);
  //       } catch (e) {
  //         throw Exception(
  //             'Failed to process cached data due to type mismatch.');
  //       }
  //     } else {
  //       throw Exception('No cached data available.');
  //     }
  //   }
  // }

  ResponseModell _mapJsonToResponseModel(Map<String, dynamic> jsonResponse) {
    var allCategoryList = jsonResponse['data']['all_category'] as List;
    List<Category> allCategory =
        allCategoryList.map((json) => Category.fromJson(json)).toList();

    var performanceList = jsonResponse['data']['category_performance'] as List;
    List<CategoryPerformancee> categoryPerformance = performanceList
        .map((json) => CategoryPerformancee.fromJson(json))
        .toList();

    var monthPerformanceList =
        jsonResponse['data']['monthly_performance'] as List;
    List<MonthlyPerformancee> montlyPerformance = monthPerformanceList
        .map((json) => MonthlyPerformancee.fromJson(json))
        .toList();

    final revenueJson =
        jsonResponse['data']['revenu'] as Map<String, dynamic>? ?? {};
    final Revenuee revenue = Revenuee.fromJson(revenueJson);

    var collectionJson = jsonResponse['data']['collection'];
    Collection collection = Collection.fromJson(collectionJson ?? {});

    var deliveryJson = jsonResponse['data']['delivery'];
    Delivery delivery = Delivery.fromJson(deliveryJson ?? {});

    var topSellingList = jsonResponse['data']['top_selling_product'] as List;
    List<TopSellingProductA> topSellingProducts = topSellingList
        .map((json) => TopSellingProductA.fromJson(json))
        .toList();

    var orderCountListJson = jsonResponse['data']['order_count_list'];
    OrderCountListt orderCountList =
        OrderCountListt.fromJson(orderCountListJson ?? {});

    return ResponseModell(
      statusCode: jsonResponse['status_code'] ?? 0,
      status: jsonResponse['status'] ?? false,
      message: jsonResponse['message'] ?? '',
      allCategory: allCategory,
      categoryPerformance: categoryPerformance,
      monthlyPerformance: montlyPerformance,
      revenue: revenue,
      collection: collection,
      delivery: delivery,
      topSellingProducts: topSellingProducts,
      orderCountList: orderCountList,
    );
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
  required String fetchType, // e.g., "Month", "Week", "Day", "year", "Range"
  required int year,         // The integer year (e.g., 2026)
  String? startDate,
  String? endDate,
  String? selectedDay,
  List<String>? selectedMonths,
  List<String>? selectedWeeks,
}) async {
  dynamic selectedRangeData;

  // Logic to determine what goes into 'selected_range' based on your payloads
  switch (fetchType) {
    case "Month":
      selectedRangeData = selectedMonths; // ["January"]
      break;
    case "Week":
      selectedRangeData = selectedWeeks; // ["week3"]
      break;
    case "Day":
      // Payload requires a List for Day: ["2026-01-14"]
      selectedRangeData = selectedDay != null ? [selectedDay] : [];
      break;
    case "year": // Note: Lowercase 'year' based on your payload example
      // Payload requires a String for Year: "2026"
      selectedRangeData = year.toString(); 
      break;
    case "Range":
      // Payload requires List: ["2026-01-07", "2026-01-14"]
      selectedRangeData = [startDate, endDate];
      break;
    default:
      selectedRangeData = [];
  }

  final requestBody = {
    "catId": catId,
    "time_range": fetchType, // "Month", "Week", "Day", "year", "Range"
    "selected_range": selectedRangeData,
    "salesman_id":SessionHelper.loginSavedData?.salesmanId ?? '',
    "year": year, // Dynamic year, not hardcoded 2025
    "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  };

  try {
    final response = await responsePostMethod(
      endPoint: ApiConstants.fetchCategoryPerformance,
      requestData: requestBody,
    );

    final jsonResponse =
        response.data is String ? jsonDecode(response.data) : response.data;

    if (response.statusCode == 200) {
      var allCategoryList = jsonResponse['data'] as List;
      List<Salesmanvn> allCategory =
          allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();

      return ResponseModelCp(
        statusCode: jsonResponse['status_code'] ?? 0,
        status: jsonResponse['status'] ?? false,
        message: jsonResponse['message'] ?? '',
        data: allCategory,
      );
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    throw Exception('Failed to fetch data: $e');
  }
}


  // Future<ResponseModelCp> fetchDashboardCategoruPerformenceData({
  //   required int catId,
  //   String? fetchType,
  //   String? startDate,
  //   String? endDate,
  //   String? selectedDay,
  //   List<String>? selectedMonths,
  //   List<String>? selectedWeeks,
  //   int? year,
  // }) async {
  //   Object? sendData;

  //   switch (fetchType) {
  //     case "Month":
  //       sendData = selectedMonths;
  //       break;
  //     case "Week":
  //       sendData = selectedWeeks;
  //       break;
  //     case "Day":
  //       sendData = [selectedDay];
  //       break;
  //     case "Year":
  //       sendData = year;
  //       break;
  //     case "Range":
  //       sendData = [startDate, endDate];
  //       break;
  //     default:
  //       sendData = selectedMonths;
  //   }
  //   final requestBody = {
  //     "catId": catId,
  //     "time_range": fetchType,
  //     "selected_range": sendData,
  //     "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
  //     "year": DateTime.now().year,
  //     "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //   };

  //   try {
  //     final response = await responsePostMethod(
  //       requestData: requestBody,
  //       endPoint: "fetchCategoryPerformance",
  //       options: Options(
  //         headers: {'Content-Type': 'application/json'},
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       var jsonResponse = response.data;
  //       var allCategoryList = jsonResponse['data'] as List;
  //       List<Salesmanvn> allCategory =
  //           allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();
  //       return ResponseModelCp(
  //           statusCode: jsonResponse['status_code'] ?? 0,
  //           status: jsonResponse['status'] ?? false,
  //           message: jsonResponse['message'] ?? '',
  //           data: allCategory);
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         response: error.response,
  //         apiName: "category perfromance",
  //         error: error);
  //     throw Exception('Failed to fetch data: $error');
  //   }
  // }

  Future<ResponseModelCp> fetchDashboardValuePerformanceData({
  required String month,
  required String timeRange,
  required String selectedRange,
  required int year,
  String salesmanId = "",
}) async {
  
  // New Payload Structure
  final requestBody = {
    "month": month,            // e.g., "February"
    "time_range": timeRange,   // e.g., "year"
    "selected_range": selectedRange, // e.g., "2025" (Filter Year)
    "year": year,              // e.g., 2026 (Current Year)
    "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
    "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  };

  try {
    final response = await responsePostMethod(
      endPoint: ApiConstants.fetchValuePerformance,
      requestData: requestBody,
    );

    final jsonResponse =
        response.data is String ? jsonDecode(response.data) : response.data;

    if (response.statusCode == 200) {
      var allCategoryList = jsonResponse['data'] as List;
      List<Salesmanvn> allCategory =
          allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();

      return ResponseModelCp(
        statusCode: jsonResponse['status_code'] ?? 0,
        status: jsonResponse['status'] ?? false,
        message: jsonResponse['message'] ?? '',
        data: allCategory,
      );
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    throw Exception('Failed to fetch data: $e');
  }
}


  // Future<ResponseModelCp> fetchDashboardValuePerformanceData({
  //   required String catId,
  //   String? fetchType,
  //   String? startDate,
  //   String? endDate,
  //   String? selectedDay,
  //   List<String>? selectedMonths,
  //   List<String>? selectedWeeks,
  //   int? year,
  // }) async {
  //   final requestBody = {
  //     "month": catId,
  //     "time_range": "Month",
  //     "year": DateTime.now().year,
  //     "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
  //     "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //   };
  //   try {
  //     final response = await responsePostMethod(
  //         requestData: requestBody,
  //         endPoint: ApiConstants.fetchValuePerformance,
  //         options: Options(
  //           headers: {'Content-Type': 'application/json'},
  //         ));
  //     if (response.statusCode == 200) {
  //       var jsonResponse = response.data;
  //       var allCategoryList = jsonResponse['data'] as List;
  //       List<Salesmanvn> allCategory =
  //           allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();
  //       return ResponseModelCp(
  //           statusCode: jsonResponse['status_code'] ?? 0,
  //           status: jsonResponse['status'] ?? false,
  //           message: jsonResponse['message'] ?? '',
  //           data: allCategory);
  //     } else {
  //       handleExceptionMessage(
  //           response: response, apiName: "value perfromance");
  //       throw Exception('Failed to load data');
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         response: error.response, apiName: "value perfromance", error: error);
  //     throw Exception('Failed to fetch data: $error');
  //   }
  // }
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
    
    // 1. Updated Logic: Year is a single value, others are lists
    switch (fetchType) {
      case "Month":
        sendData = selectedMonths; // List
        break;
      case "Week":
        sendData = selectedWeeks; // List
        break;
      case "Day":
        sendData = selectedDay != null ? [selectedDay] : null; // List
        break;
      case "Year":
      case "year":
        // ✅ CHANGE: Send as single value (String), not inside a list
        sendData = year?.toString(); 
        break;
      case "Range":
        sendData = (startDate != null && endDate != null) 
            ? [startDate, endDate] // List
            : null;
        break;
      default:
        sendData = selectedMonths;
    }

    final requestBody = {
      "categories_id": catId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "customer_id": "",
      // Use parameter salesmanId if provided, otherwise session
      "salesman_id": salesmanId ?? SessionHelper.loginSavedData?.salesmanId ?? '',
      "bar_type": fetchType,
      "range_type": fetchType,
      "selected_range": sendData, // String for Year, List for others
      "year": year?.toString() ?? DateTime.now().year.toString(),
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

  // Future<List<orderResponseModel.OrderData>> fetchChartSalesmanOrderData({
  //   required dynamic catId,
  //   String? salesmanId,
  //   String? fetchType,
  //   String? startDate,
  //   String? endDate,
  //   String? selectedDay,
  //   List<String>? selectedMonths,
  //   List<String>? selectedWeeks,
  //   int? year,
  // }) async {
  //   Object? sendData;
  //   switch (fetchType) {
  //     case "Month":
  //       sendData = selectedMonths;
  //       break;
  //     case "Week":
  //       sendData = selectedWeeks;
  //       break;
  //     case "Day":
  //       sendData = [selectedDay];
  //       break;
  //     case "Year":
  //       sendData = year;
  //       break;
  //     case "Range":
  //       sendData = [startDate, endDate];
  //       break;
  //     default:
  //       sendData = selectedMonths;
  //   }
  //   final requestBody = {
  //     "categories_id": catId,
  //     "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //     "customer_id": "",
  //     "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
  //     "bar_type": fetchType,
  //     "range_type": fetchType,
  //     "selected_range": sendData,
  //     "year": fetchType == "Year" ? year : DateTime.now().year.toString(),
  //     "limit": 1000,
  //     "page": 1
  //   };
  //   try {
  //     final response = await responsePostMethod(
  //         requestData: requestBody,
  //         endPoint: ApiConstants.fetchOrderByRange,
  //         options: Options(
  //           headers: {'Content-Type': 'application/json'},
  //         ));
  //     if (response.statusCode == 200) {
  //       var jsonResponse = response.data;
  //       var returnResponse = jsonResponse['data'] as List;
  //       List<orderResponseModel.OrderData> orderData = returnResponse
  //           .map((e) => orderResponseModel.OrderData.fromJson(e))
  //           .toList();

  //       return orderData;
  //     } else {
  //       handleExceptionMessage(
  //           response: response, apiName: "chart salesman order data");
  //       throw Exception('Failed to load data');
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         response: error.response,
  //         apiName: "chart salesman order data",
  //         error: error);
  //     throw Exception('Failed to fetch data: $error');
  //   }
  // }
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

  // 1. Updated Logic: Handle "Year" as String, others as List
  switch (fetchType) {
    case "Month":
      sendData = selectedMonths; // List
      break;
    case "Week":
      sendData = selectedWeeks; // List
      break;
    case "Day":
      sendData = selectedDay != null ? [selectedDay] : null; // List
      break;
    case "Year":
    case "year": // Added lowercase check just in case
      // ✅ CHANGE HERE: Pass as String, not List
      sendData = year?.toString(); 
      break;
    case "Range":
      sendData = (startDate != null && endDate != null)
          ? [startDate, endDate] // List
          : null;
      break;
    default:
      sendData = null;
  }

  // 2. Updated Request Body
  final requestBody = {
    "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    // Use the passed salesmanId if it exists, otherwise fallback to session
    "salesman_id": salesmanId ?? SessionHelper.loginSavedData?.salesmanId ?? '',
    "bar_type": "Month", 
    "time_range": fetchType, // "Week", "Year", etc.
    "selected_range": sendData, // Dynamic: String for Year, List for others
    "CatId": catId.toString(), // Kept as CatId based on your first payload
    "year": year?.toString() ?? DateTime.now().year.toString(),
  };

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
          response: response, apiName: "salesman target by category");
      throw Exception('Failed to load data');
    }
  } on DioException catch (error) {
    handleExceptionMessage(
        response: error.response,
        apiName: "salesman target by category",
        error: error);
    throw Exception('Failed to fetch data: $error');
  }
}

  // Future<List<TargetDatum>> fetchSalesmanTargetByCategory({
  //   required int catId,
  //   String? salesmanId,
  //   String? fetchType,
  //   String? startDate,
  //   String? endDate,
  //   String? selectedDay,
  //   List<String>? selectedMonths,
  //   List<String>? selectedWeeks,
  //   int? year,
  // }) async {
  //   dynamic sendData;
  //   switch (fetchType) {
  //     case "Month":
  //       sendData = selectedMonths;
  //       break;
  //     case "Week":
  //       sendData = selectedWeeks;
  //       break;
  //     case "Day":
  //       sendData = selectedDay != null ? [selectedDay] : null;
  //       break;
  //     case "Year":
  //       sendData = year != null ? [year.toString()] : null;
  //       break;
  //     case "Range":
  //       sendData = (startDate != null && endDate != null)
  //           ? [startDate, endDate]
  //           : null;
  //       break;
  //     default:
  //       sendData = null;
  //   }

  //   final requestBody = {
  //     "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //     "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
  //     "bar_type": "Month",
  //     "time_range": fetchType,
  //     "selected_range": sendData,
  //     "CatId": catId.toString(),
  //     "year": fetchType == "Year"
  //         ? year?.toString()
  //         : DateTime.now().year.toString(),
  //   };
  //   try {
  //     final response = await responsePostMethod(
  //       requestData: requestBody,
  //       options: Options(
  //         headers: {'Content-Type': 'application/json'},
  //       ),
  //       endPoint: ApiConstants.fetchSalesmanTargetByCategory,
  //     );
  //     if (response.statusCode == 200) {
  //       var jsonResponse = response.data;
  //       var parsedData = SalesmanTargetByCatId.fromJson(jsonResponse);
  //       return parsedData.targetData ?? [];
  //     } else {
  //       handleExceptionMessage(
  //           response: response, apiName: "salesman terget by category");
  //       throw Exception('Failed to load data');
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         response: error.response,
  //         apiName: "salesman terget by category",
  //         error: error);
  //     throw Exception('Failed to fetch data: $error');
  //   }
  // }

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
        final cachedData = chatBox.get(cacheKey);
        return localStorage.storedChatData(cachedData, cacheKey);
      }
      final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.fetchIndividualChat,
          options: Options(headers: {'Content-Type': 'application/json'}));
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
  bool checkDate = false,
}) async {
  print('fetch fetchAllOrders apio called');
  
  // --- 1. PREPARE VARIABLES (Like in fetchDashboardData) ---
  dynamic sendData;
  // Default to the provided fetchType, or "Month" if null
  String timeRangePayload = fetchType ?? "Month";
  
  // Normalize checking (handle both "Year" and "year")
  // You can use .toLowerCase() for the switch, or just add cases.
  // Using the exact logic from your dashboard example:
  
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
      
    // --- FIX: Handle "Year" casing correctly ---
    case "Year":
    case "year": // Add this just in case
      timeRangePayload = "year"; // API requires lowercase "year"
      sendData = year.toString(); // API requires "2025" (String)
      break;
      
    case "Range":
      sendData = [startDate, endDate];
      break;
    default:
      sendData = selectedMonths;
  }
final int yearToSend = (year != null && year != 0) 
      ? year 
      : DateTime.now().year;
 
  // final int yearToSend = (timeRangePayload == "year" && year != null) 
  //     ? year 
  //     : DateTime.now().year;

  final requestBody = isLogin
      ? {
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
          "check_date": checkDate,
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
          "check_date": checkDate,
          "order_type": orderType,
          "categories_id": "",
          "customer_id": "",
          "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
          
          // Use the calculated payload variables
          "time_range": timeRangePayload, 
          "selected_range": sendData, 
          
          "payment_type": "",
          
          // Use the calculated year
          "year": yearToSend, 
          
          "limit": 1000,
          "page": 1,
        };

  final cacheKey =
      '${SessionHelper.loginSavedData?.company_id ?? -1}_orders_$orderType${checkDate ? '_true' : ''}';

  final orderBox = await getHiveBoxSafely('fetchAllOrdersBox');

  try {
    final isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      final cachedData = orderBox.get(cacheKey);
      if (cachedData != null) {
        Map<String, dynamic> safeMap = ensureStringKeyedMap(cachedData);
        return OrderResponse.fromJson(safeMap);
      }
    }
    
    print('API REQUEST BODY: $requestBody');

    final response = await responsePostMethod(
      endPoint: ApiConstants.fetchAllOrderByRange,
      requestData: requestBody,
    );
    log('response of all orders: ${response.data}');

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      // print('response from orders api:$jsonResponse');
      await orderBox.put(cacheKey, Map<String, dynamic>.from(jsonResponse));

      return OrderResponse.fromJson(ensureStringKeyedMap(jsonResponse));
    } else {
      throw Exception('Failed to fetch orders - ${response.statusCode}');
    }
  } on SocketException {
    final cachedData = orderBox.get(cacheKey);
    if (cachedData != null) {
      Map<String, dynamic> safeMap = ensureStringKeyedMap(cachedData);
      return OrderResponse.fromJson(safeMap);
    } else {
      throw Exception('Network error, and no cached data is available.');
    }
  } catch (e) {
    final cachedData = orderBox.get(cacheKey);
    if (cachedData != null) {
      Map<String, dynamic> safeMap = ensureStringKeyedMap(cachedData);
      return OrderResponse.fromJson(safeMap);
    } else {
      throw Exception('Unexpected error occurred: $e');
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
    bool checkDate = false,
  }) async {
    print('order dash api called');
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "check_date": checkDate,
      "customer_id": cusId,
      "salesman_id": '',
      "order_type": orderType,
      "payment_type": "1",
      "start_date": startDate,
      "end_date": endDate,
      "limit": 1000,
      "page": 1,
    };

    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final cacheKey =
        '${companyId}_${cusId}_$orderType${checkDate ? '_true' : ''}';
    final customerDashOrdersBox = await Hive.openBox('customerDashOrdersBox');

    try {
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerDashOrdersBox.get(cacheKey);
        if (cachedData != null) {
          return OrderResponse.fromJson(Map<String, dynamic>.from(cachedData));
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

        Pagination pagination =
            Pagination.fromJson(jsonResponse['pagination'] ?? {});
        List<dynamic>? orderData = jsonResponse['data'] as List<dynamic>?;

        List<OrdersDash> orders = [];
        if (orderData != null) {
          orders = orderData
              .map((json) => OrdersDash.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        await customerDashOrdersBox.put(
            cacheKey, Map<String, dynamic>.from(jsonResponse));

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
    required int limit,
    required int page,
    required String valueFromDw,
    List<String> selectedRange = const [],
    String startDate = "",
    String endDate = "",
    int? year, // <--- ADDED YEAR PARAMETER
  }) async {
    // If year is not passed, fallback to current year
    final int finalYear = year ?? DateTime.now().year;

    // Construct the payload based on the new backend requirement
    final requestBody = {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": salesmanId,
      "business_name": customerName,
      "limit": limit,
      "page": page,
      "valueFromDw": valueFromDw, 
      "selected_range": selectedRange, 
      "start_date": startDate, 
      "end_date": endDate,
      "previous_year_of_sales": finalYear.toString(), // <--- ADDED TO MATCH WEB PAYLOAD
    };

    final customerBox = Hive.box('customerBox');
    final cacheKey = '${SessionHelper.loginSavedData?.company_id ?? -1}_customer_list_$page';

    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchCustomer,
        requestData: requestBody,
      );
      print('request body of fetch customer: $requestBody'); // Debug print
      log('response of fetch customer: ${response.data}');

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        if (jsonResponse['status'] != true) {
          throw Exception('API returned error: ${jsonResponse['message']}');
        }

        final customers = (jsonResponse['data'] as List?)
                ?.where((json) => json != null)
                .map((json) => CustomerModelxx.fromJson(json))
                .toList() ?? [];

        final orderTotal = (jsonResponse['orderTotal'] as List?)
                ?.where((json) => json != null)
                .map((json) => OrderTotalxx.fromJson(json))
                .toList() ?? [];

        final yearList = (jsonResponse['years_list_of_all'] as List?)
                ?.where((json) => json != null)
                .map((json) => YearsListOfAll.fromJson(json))
                .toList() ?? [];

        await customerBox.put(cacheKey, jsonResponse);

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
    } catch  (e) {
      handleHttpResponseError(
        statusCode: e is http.Response ? e.statusCode : 0,
        showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
        message: 'Customer',
      );

      // Offline Fallback Logic
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) log('Using cached data due to offline mode');

      final cachedData = customerBox.get(cacheKey);

      if (cachedData != null) {
        final castedData = ensureStringKeyedMap(cachedData);
        // ... (Existing offline mapping logic remains the same)
        final customers = (castedData['data'] as List?)
                ?.where((json) => json != null)
                .map((json) => CustomerModelxx.fromJson(json))
                .toList() ?? [];
                

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

        await customerBox.put(cacheKey, castedData);
         // ... map other fields ...

        return CustomerResponseModelxx(
          statusCode: castedData['status_code'] ?? 0,
          status: castedData['status'] ?? false,
          message: castedData['message'] ?? '',
          data: customers,
          orderTotal: [], // Handle empty or cached totals
          pagination: Paginationxx.fromJson(castedData['pagination'] ?? {}),
          yearsListOfAll: [],
        );
      } else {
        throw Exception('No cached data available');
      }
    }
  }

//     Future<CustomerResponseModelxx> fetchCustomer({
//     required String salesmanId,
//     required String customerName,
//     required int limit,
//     required int page,
//     // Changed params to match new payload structure
//     required String valueFromDw, 
//      List<String> selectedRange = const [], 
//     String startDate = "",
//     String endDate = "",
//   }) async {
    
//     // Construct the payload based on the new backend requirement
//     final requestBody = {
//       "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
//       "salesman_id":SessionHelper.loginSavedData?.salesmanId ?? '',
//       "business_name": customerName,
//       "limit": limit,
//       "page": page,
//       "valueFromDw": valueFromDw, // e.g., "Month", "Week", "Range"
//       "selected_range": selectedRange, // e.g., ["January", "February"]
//       "start_date": startDate, // Keep empty if not needed, or use for Range/Day
//       "end_date": endDate,
//     };

//     final customerBox = Hive.box('customerBox');
//     final cacheKey =
//         '${SessionHelper.loginSavedData?.company_id ?? -1}_customer_list_$page';

//     try {
//       final response = await responsePostMethod(
//         endPoint: ApiConstants.fetchCustomer,
//         requestData: requestBody,
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = response.data;
// log('response of the fetchCustomer API :${response.data}');
//         if (jsonResponse['status'] != true) {
//           throw Exception('API returned error: ${jsonResponse['message']}');
//         }

//         final customers = (jsonResponse['data'] as List?)
//                 ?.where((json) => json != null)
//                 .map((json) => CustomerModelxx.fromJson(json))
//                 .toList() ??
//             [];

//         final orderTotal = (jsonResponse['orderTotal'] as List?)
//                 ?.where((json) => json != null)
//                 .map((json) => OrderTotalxx.fromJson(json))
//                 .toList() ??
//             [];

//         final yearList = (jsonResponse['years_list_of_all'] as List?)
//                 ?.where((json) => json != null)
//                 .map((json) => YearsListOfAll.fromJson(json))
//                 .toList() ??
//             [];

//         // You might want to update how you cache given the complex filters, 
//         // but keeping it simple for now:
//         await customerBox.put(cacheKey, jsonResponse);

//         return CustomerResponseModelxx(
//           statusCode: jsonResponse['status_code'] ?? 0,
//           status: jsonResponse['status'] ?? false,
//           message: jsonResponse['message'] ?? '',
//           data: customers,
//           orderTotal: orderTotal,
//           pagination: Paginationxx.fromJson(jsonResponse['pagination'] ?? {}),
//           yearsListOfAll: yearList,
//         );
//       } else {
//         throw Exception('Request failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       handleHttpResponseError(
//         statusCode: e is http.Response ? e.statusCode : 0,
//         showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
//         message: 'Customer',
//       );

//       // Offline Fallback Logic
//       final isOnline = await ConnectivityService().isOnline();
//       if (!isOnline) log('Using cached data due to offline mode');

//       final cachedData = customerBox.get(cacheKey);

//       if (cachedData != null) {
//         final castedData = ensureStringKeyedMap(cachedData);
//         // ... (Existing offline mapping logic remains the same)
//         final customers = (castedData['data'] as List?)
//                 ?.where((json) => json != null)
//                 .map((json) => CustomerModelxx.fromJson(json))
//                 .toList() ?? [];
                

//                 final orderTotal = (castedData['orderTotal'] as List?)
//                 ?.where((json) => json != null)
//                 .map((json) => OrderTotalxx.fromJson(json))
//                 .toList() ??
//             [];

//         final yearList = (castedData['years_list_of_all'] as List?)
//                 ?.where((json) => json != null)
//                 .map((json) => YearsListOfAll.fromJson(json))
//                 .toList() ??
//             [];

//         await customerBox.put(cacheKey, castedData);
//          // ... map other fields ...

//         return CustomerResponseModelxx(
//           statusCode: castedData['status_code'] ?? 0,
//           status: castedData['status'] ?? false,
//           message: castedData['message'] ?? '',
//           data: customers,
//           orderTotal: [], // Handle empty or cached totals
//           pagination: Paginationxx.fromJson(castedData['pagination'] ?? {}),
//           yearsListOfAll: [],
//         );
//       } else {
//         throw Exception('No cached data available');
//       }
//     }
//   }



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
      showCustomToastDisplay(
        context,
        "Please Assign Staff".tr,
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

    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerDashboardBox.get(customerId);
        if (cachedData != null) {
          final safeMap = ensureStringKeyedMap(cachedData);
          return ApiResponseModel.fromJson(safeMap);
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
        final safeMap = ensureStringKeyedMap(cachedData);
        return ApiResponseModel.fromJson(safeMap);
      } else {
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
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cacheKey =
            '${SessionHelper.loginSavedData?.company_id ?? -1}_${customerId}_$year';
        final cachedData = customerTotalSaleBox.get(cacheKey);
        if (cachedData != null) {
          final safeMap = ensureStringKeyedMap(cachedData);
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
      if (response.statusCode == 200) {
        final jsonResponse = response.data;
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
        final safeMap = ensureStringKeyedMap(cachedData);
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

    try {
      final bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final cachedData = customerRevenueBox.get(customerId);
        if (cachedData != null) {
          final safeMap = ensureStringKeyedMap(cachedData);
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
        return CustomerRevenueResponse.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to load customer revenue data - Status: ${response.statusCode}',
        );
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: "customer revenue", error: error, response: error.response);
      final cachedData = customerRevenueBox.get(customerId);
      if (cachedData != null) {
        final safeMap = ensureStringKeyedMap(cachedData);
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
        '${SessionHelper.loginSavedData?.company_id ?? -1}_$customerId';

    final requestBody = {
      "salesman_id": SessionHelper.loginSavedData?.salesmanId,
      "customer_id": customerId,
      "start_date": startDate,
      "end_date": endDate,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    try {
      final bool isOnline = await ConnectivityService().isOnline();

      if (!isOnline) {
        final cachedData = orderCountBox.get(cacheKey);
        if (cachedData != null) {
          final safeMap = ensureStringKeyedMap(cachedData);
          return ApiResponsees.fromJson(safeMap);
        } else {
          throw Exception('No cached data available for order count.');
        }
      }

      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchOrderCount,
        requestData: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        await orderCountBox.put(
            cacheKey, Map<String, dynamic>.from(jsonResponse));

        return ApiResponsees.fromJson(ensureStringKeyedMap(jsonResponse));
      } else {
        throw Exception('Failed to fetch order count - ${response.statusCode}');
      }
    } catch (e) {
      final cachedData = orderCountBox.get(cacheKey);
      if (cachedData != null) {
        final safeMap = ensureStringKeyedMap(cachedData);
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
  log('reponse of fetch one customer api:${response.data}');
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
  Future<CustomerResponse> updateDeliveryAddress({
    required String customerId,
    required int companyId,
    required String address,
    required String town,
    required String state,
    required String zipcode,
    required String contact,
    // "updated_by" is required by backend. 
    // We can pass it here or grab it from session inside the function.
    required String updatedBy, 
  }) async {
    
    // STRICTLY using the parameters requested by backend team
    final requestBody = {
      "customer_id": customerId,
      "company_id":companyId,
      "delivery_address": address,
      "delivery_town": town,
      "delivery_state": state,
      "delivery_zipcode": zipcode,
      "delivery_contact": contact,
      "updated_by": updatedBy, // Valid ID of the user performing the update
    };

    try {
      final response = await responsePostMethod(
        requestData: requestBody,
        endPoint: ApiConstants.updatedeliveryaddress, // Ensure this endpoint path is correct
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        log('response of update customer api:${response.data}');

        return CustomerResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? 'Update Successful',
          data: [], 
        );
      } else {
        throw Exception(
            'Failed to update customer - Status: ${response.statusCode}');
      }
    } on DioException catch (error) {
       // Log the actual response data from server to see WHY it failed
       log("Update API Error Data: ${error.response?.data}");
       
      handleExceptionMessage(
          apiName: "update customer",
          error: error,
          response: error.response);
      throw Exception(
          'Failed to update customer: ${error.message}');
    }
  }

  
  // Future<CustomerResponse> updateDeliveryAddress({
  //   required String customerId,
  //   required int companyId,
  //   required String address,
  //   required String town,
  //   required String state,
  //   required String zipcode,
  //   required String contact,
  //   required String remark,
  // }) async {
    
  //   final requestBody = {
  //     "customer_id": customerId,
  //     "companyId": companyId, 
  //     "delivery_address": address,
  //     "delivery_town": town,
  //     "delivery_state": state,
  //     "delivery_zipcode": zipcode,
  //     "delivery_contact": contact,
  //     "remark": remark,
  //   };

  //   try {
  //     print('request body:$requestBody');
  //     // Make sure to add 'updateCustomer' to your ApiConstants
  //     final response = await responsePostMethod(
  //       requestData: requestBody,
  //       endPoint: ApiConstants.updatedeliveryaddress, 
  //       options: Options(
  //         headers: {'Content-Type': 'application/json'},
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       var jsonResponse = response.data;
  //       log('response of update customer api:${response.data}');
        
  //       // We reuse CustomerResponse wrapper to keep it consistent
  //       // Note: The 'data' list might be empty on update depending on your backend
  //       return CustomerResponse(
  //         statusCode: jsonResponse['status_code'] ?? 0,
  //         status: jsonResponse['status'] ?? false,
  //         message: jsonResponse['message'] ?? '',
  //         data: [], // Usually updates return success message, not a list of customers
  //       );
  //     } else {
  //       throw Exception(
  //           'Failed to update customer data from updateCustomer- ${response.statusCode}');
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         apiName: "update customer",
  //         error: error,
  //         response: error.response);
  //     throw Exception(
  //         'Failed to update customer data updateCustomer exception: $error');
  //   }
  // }

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
  Future<dynamic> addCustomer(
      {required Map<String, dynamic> model,
      File? adminProfilePicture,
      required String salesmanId}) async {
    return await ApiWorker().addCustomer2(
        model: model,
        adminProfilePicture: adminProfilePicture,
        salesmanId: salesmanId);
  }
  // Future<void> addCustomer(
  //     {required Map<String, dynamic> model,
  //     required File adminProfilePicture,
  //     required String salesmanId}) async {
  //   ApiWorker().addCustomer2(
  //       model: model,
  //       adminProfilePicture: adminProfilePicture,
  //       salesmanId: salesmanId);
  // }

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
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final cacheKey = '${companyId}_${customerId}_4';
    final cacheKeyDash = '${companyId}_orders_4';

    bool deletedFromCustomerDashOrders = false;
    bool deletedFromFetchAllOrders = false;

    try {
      final customerDashOrdersBox = await Hive.openBox('customerDashOrdersBox');
      final cachedData = customerDashOrdersBox.get(cacheKey);
      if (cachedData == null) {
      } else {
        final cachedMap = safeMapFrom(cachedData);
        final orderData = cachedMap?['data'] as List<dynamic>?;
        if (orderData != null && orderData.isNotEmpty) {
          final targetOrder = Map<String, dynamic>.from(orderData[0]);
          final currentTotal = (targetOrder['order_total'] ?? 0.0).toDouble();
          final newTotal = currentTotal - sentAmount;

          if (newTotal <= 0) {
            await customerDashOrdersBox.delete(cacheKey);
            deletedFromCustomerDashOrders = true;
          } else {
            targetOrder['order_total'] =
                double.parse(newTotal.toStringAsFixed(2));
            orderData[0] = targetOrder;
            await customerDashOrdersBox
                .put(cacheKey, {...cachedMap!, 'data': orderData});
          }
        }
      }
    } catch (e) {
    }

    try {
      final orderBox = await Hive.openBox('fetchAllOrdersBox');
      final cachedDataDash = orderBox.get(cacheKeyDash);
      if (cachedDataDash == null) {
      } else {
        final cachedMapDash = safeMapFrom(cachedDataDash);
        final orderDataDash = cachedMapDash?['data'] as List<dynamic>?;
        if (orderDataDash != null && orderDataDash.isNotEmpty) {
          final updated = <Map<String, dynamic>>[];
          bool deleted = false;

          for (var order in orderDataDash) {
            final map = Map<String, dynamic>.from(order);
            if (map['customer_id']?.toString() == customerId) {
              final currentTotal = (map['order_total'] ?? 0.0).toDouble();
              final newTotal = currentTotal - sentAmount;

              if (newTotal <= 0) {
                deleted = true;
                deletedFromFetchAllOrders = true;
                continue;
              } else {
                map['order_total'] = double.parse(newTotal.toStringAsFixed(2));
              }
            }
            updated.add(map);
          }

          if (deleted && updated.isEmpty) {
            await orderBox.delete(cacheKeyDash);
          } else {
            await orderBox
                .put(cacheKeyDash, {...cachedMapDash!, 'data': updated});
          }
        }
      }
    } catch (e) {
    }

    if (deletedFromCustomerDashOrders) {
      try {
        final orderCountBox = await getHiveBoxSafely('orderCountBox');
        final countKey = '${companyId}_$customerId';
        final cachedCount = orderCountBox.get(countKey);
        if (cachedCount != null) {
          final safeMap = ensureStringKeyedMap(cachedCount);
          final dataToBeModified = ApiResponsees.fromJson(safeMap);
          dataToBeModified.data.draftOrder = 0;
          await orderCountBox.put(countKey, dataToBeModified.toJson());
        }
      } catch (e) {
      }
    }

    if (deletedFromFetchAllOrders) {
      try {
        final dashboardBox = Hive.box('dashboardBox');
        final cachedDashboardData = dashboardBox.get('dashboardData');
        if (cachedDashboardData != null) {
          Map<String, dynamic> dashboardMap;
          if (cachedDashboardData is String) {
            dashboardMap =
                Map<String, dynamic>.from(jsonDecode(cachedDashboardData));
          } else if (cachedDashboardData is Map) {
            dashboardMap = ensureStringKeyedMap(cachedDashboardData);
          } else {
            return;
          }

          final orderCountList = dashboardMap['data']?['order_count_list']
              as Map<String, dynamic>?;
          if (orderCountList != null) {
            final currentDraftCount =
                int.tryParse(orderCountList['draft_order'].toString()) ?? 0;
            final currentFilteredDraftCount = int.tryParse(
                    orderCountList['draft_FilteredCount'].toString()) ??
                0;
            final newDraftCount =
                (currentDraftCount - 1).clamp(0, double.infinity).toInt();
            final newFilteredDraftCount = (currentFilteredDraftCount - 1)
                .clamp(0, double.infinity)
                .toInt();

            orderCountList['draft_order'] = newDraftCount.toString();
            orderCountList['draft_FilteredCount'] =
                newFilteredDraftCount.toString();

            if (cachedDashboardData is String) {
              await dashboardBox.put('dashboardData', jsonEncode(dashboardMap));
            } else {
              await dashboardBox.put('dashboardData', dashboardMap);
            }
          }
        }
      } catch (e) {
      }
    }

    if (context != null) {
      try {
        Provider.of<CustomersProvider>(context, listen: false)
            .fetchCustomerDashboardCountData(customerId);

        final dashboardProvider =
            Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetchData();
      } catch (e) {}
    }
  }

  Map<String, dynamic>? safeMapFrom(dynamic source) {
    if (source is Map) {
      return Map<String, dynamic>.from(source);
    }
    return null;
  }
}

Map<String, dynamic> ensureStringKeyedMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      final newKey = key is String ? key : key.toString();
      if (value is Map) {
        result[newKey] = ensureStringKeyedMap(value);
      } else if (value is List) {
        result[newKey] =
            value.map((e) => e is Map ? ensureStringKeyedMap(e) : e).toList();
      } else {
        result[newKey] = value;
      }
    });
    return result;
  }
  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is Map) {
      return ensureStringKeyedMap(decoded);
    }
    return Map<String, dynamic>.from(decoded);
  }
  throw Exception('Unsupported cached data format: ${data.runtimeType}');
}
