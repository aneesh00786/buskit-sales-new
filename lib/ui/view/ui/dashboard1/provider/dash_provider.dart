import 'dart:convert';
import 'dart:developer';
import 'dart:io';
//import 'package:charts_flutter/flutter.dart';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'dash_models.dart';

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  final Dio dio = Dio();
   ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final jsonString = await SessionManager.getStringValue(SpString.spLogin);
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
      onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 400) {
           _handleTokenExpiration();
        }
        return handler.next(error); 
      },
    ));
  }
  Future<ResponseModell> fetchDashboardData(
      {String? salesmanId,
      String? startDate,
      String? endDate,
      String? createdToken}) async {
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    String createdToken = jsonMap['createdToken'];
    final url = '$_baseUrl${ApiConstants.dashboard_list}';
    final requestBody = {
      "salesman_id": salesmanId,
      "start_date": startDate,
      "end_date": endDate,
    };
    try {
      log('API URL: $url');
      log('Request Body: $requestBody');
      log("Created Token: $createdToken");

      final response = await Dio().post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $createdToken',
          },
        ),
        data: jsonEncode(requestBody),
      );

      log("fetchDashboardData Code: ${response.statusCode}");
      log('fetchDashboardData Body: ${response.data['status']}');

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        //log('Order Count List:++++++++ ${jsonResponse['data']}');
        var allCategoryList = jsonResponse['data']['all_category'] as List;
        List<Category> allCategory =
            allCategoryList.map((json) => Category.fromJson(json)).toList();

        var performanceList =
            jsonResponse['data']['category_performance'] as List;
        List<CategoryPerformancee> categoryPerformance = performanceList
            .map((json) => CategoryPerformancee.fromJson(json))
            .toList();

        final revenueJson =
            jsonResponse['data']['revenu'] as Map<String, dynamic>? ?? {};
        final Revenuee revenue = Revenuee.fromJson(revenueJson);

        var collectionJson = jsonResponse['data']['collection'];
        Collection collection = Collection.fromJson(collectionJson ?? {});

        var deliveryJson = jsonResponse['data']['delivery'];
        Delivery delivery = Delivery.fromJson(deliveryJson ?? {});

        var topSellingList =
            jsonResponse['data']['top_selling_product'] as List;
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
          revenue: revenue,
          collection: collection,
          delivery: delivery,
          topSellingProducts: topSellingProducts,
          orderCountList: orderCountList,
        );
       } else if (response.statusCode == 400 || response.statusCode == 401) {
        _handleTokenExpiration();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load data with status code: ${response.statusCode}');
      }
    } on DioError catch (e) {
      log('DioError: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        await SessionHelper().clearAll();
        Get.offAllNamed(AppRoutes.login);
        await Future.delayed(Duration(milliseconds: 500));
        _handleTokenExpiration();
        throw Exception('Session expired');
      }
      throw Exception('DioError: ${e.message}');
    } catch (e) {
      log('Error fetching dashboard data: $e');
      throw Exception('Failed to fetch data: $e');
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
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchCategoryPerformance}');
    final requestBody = {
      'catId': catId,
      'startdate': startDate,
      'enddate': endDate,
      'targetType': '1',
    };

    try {
      print('API URL: $url');
      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('fetchDashboardCategoruPerformenceData ${response.statusCode}');
      print('fetchDashboardCategoruPerformenceData Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        print(
            'sabik kavungal ponmala plluippad i. .. .  . .. . . . .. . . . . .   ${jsonResponse['data']}');

        var allCategoryList = jsonResponse['data'] as List;
        List<Salesmanvn> allCategory =
            allCategoryList.map((json) => Salesmanvn.fromJson(json)).toList();

        return ResponseModelCp(
            statusCode: jsonResponse['status_code'] ?? 0,
            status: jsonResponse['status'] ?? false,
            message: jsonResponse['message'] ?? '',
            data: allCategory);
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch data: sabikk  kavungal $e');
    }
  }

  Future<ProductResponse> fetchCustomerDashboardCartData(
      {required dynamic customerId,
      required dynamic catId,
      required dynamic selectedYearCategory}) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.customerSaleByCategory}');
    final requestBody = {
      'customerId': customerId,
      'catId': catId,
      'selected_year_category': selectedYearCategory,
    };

    try {
      print('API URL: $url');
      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('fetchCustomerDashboardCartData: ${response.statusCode}');
      print('fetchCustomerDashboardCartData Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        print(
            'sabik kavungal ponmala plluippad i. .. .  . .. . . . .. . . . . .   ${jsonResponse['data']}');

        var productDetail = jsonResponse['data'] as List;
        List<ProductDetail> allproductDetail =
            productDetail.map((json) => ProductDetail.fromJson(json)).toList();

        return ProductResponse(
            statusCode: jsonResponse['status_code'] ?? 0,
            status: jsonResponse['status'] ?? false,
            message: jsonResponse['message'] ?? '',
            data: allproductDetail);
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch data: sabikk  kavungal $e');
    }
  }

  Future<SalesmenResponse> fetchChatData(String salesmanId) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchChat}');
    final requestBody = {
      "salesman_id": salesmanId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body)['data'];

        List<SalesmanChat> salesmanChats = [];
        rawData.forEach((chatList) {
          // Iterate through each JSON object in chatList and create SalesmanChat objects
          chatList.forEach((json) {
            salesmanChats.add(SalesmanChat.fromJson(json));
          });
        });

        return SalesmenResponse(
          statusCode: json.decode(response.body)['status_code'],
          status: json.decode(response.body)['status'],
          message: json.decode(response.body)['message'],
          data: [
            salesmanChats
          ], // Assuming SalesmenResponse expects List<List<SalesmanChat>>
        );
      } else {
        throw Exception('Failed to fetch chat data - ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch chat data: $e');
    }
  }

  // ignore: non_constant_identifier_names
  Future<MessagesResponse> fetch_individual_chat(String chatId) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchIndividualChat}');
    final requestBody = {
      "salesman_id": chatId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        var messagesList = jsonResponse['data'] as List;
        List<Messages> messages = messagesList
            .map((messageJson) => Messages.fromJson(messageJson))
            .toList();

        return MessagesResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: messages,
        );
      } else {
        throw Exception(
            'Failed to fetch individual chat data - ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch individual chat data: $e');
    }
  }

  Future<void> postAdminMessage({
    required String salesmanId,
    required String message,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.postAdminMessage}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'salesman_id': salesmanId, 'message': message}),
      );

      if (response.statusCode == 200) {
        // Request successful
        print('Admin message posted successfully');
      } else {
        // Request failed
        throw Exception('Failed to post admin message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to post admin message: $e');
    }
  }

  Future<OrderResponse> fetchAllOrders({
    required String startDate,
    required String endDate,
    OrderStatus? orderStatus,
  }) async {
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchAllOrders}');
    String orderStatusString = '';
    if (orderStatus != null) {
      orderStatusString = orderStatus.type.toString(); // Convert int to String
    }

    final requestBody = {
      "customer_id": '',
      "salesman_id": salesmanId,
      "order_type": orderStatusString,
      "payment_type": "3",
      "start_date": startDate,
      "end_date": endDate,
      "limit": 10,
      "page": 1,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Fetch All Orders Response: $jsonResponse');

        Pagination pagination =
            Pagination.fromJson(jsonResponse['pagination'] ?? {});
        List<dynamic>? orderData = jsonResponse['data'] as List<dynamic>?;

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
        throw Exception('Failed to fetch orders - ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<OrderResponse> fetchCustomerDashOrders({
    required String cusId,
    required String salesmanId,
    required String startDate,
    required String endDate,
    OrderStatus? orderStatus, // New parameter for filtering by order status
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchAllOrders}');

    // Determine order_status based on orderStatus parameter
    String orderStatusString = '';
    if (orderStatus != null) {
      orderStatusString = orderStatus.type.toString(); // Convert int to String
    }

    final requestBody = {
      "customer_id": cusId,
      "salesman_id": salesmanId,
      "order_type": orderStatusString,
      "payment_type": "3",
      "start_date": startDate,
      "end_date": endDate,
      "limit": 10,
      "page": 1,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print('Fetch All Orders Response: $jsonResponse');

        Pagination pagination =
            Pagination.fromJson(jsonResponse['pagination'] ?? {});
        List<dynamic>? orderData = jsonResponse['data'] as List<dynamic>?;

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
        throw Exception('Failed to fetch orders - ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> changeOrderStatus(
      String orderId, OrderStatus orderStatus) async {
    String orderStatusString = '';
    if (orderStatus != null) {
      orderStatusString = orderStatus.type.toString(); // Convert int to String
    }
    final requestBody = {'order_id': orderId, 'status': orderStatusString};

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.changeOrderStatus}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print("sssss require new data from ${requestBody}");

      print(
          'ponmlaa response :  : :  : : :  : :. . . . . .  . . ..response  . .  . : ${response}');

      print(
          'ponmlaa pllippadi :  : :  : : :  : :. . . . . .  . . ..requires  . .  . : ${response.request}');

      if (response.statusCode == 200) {
        print(
            'ponmlaa pllippadi :  : :  : : :  : :. . . . . .  . . .. . .  . : ${response.body}');
        // Successful status change
        print('Order status updated successfully');
      } else {
        // Handle other status codes if needed
        print('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or exceptions
      print('Exception during order status update: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<AdminResponse> fetchAdminDetails({required String token}) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.adminOnPopUp}');
    final requestBody = {"token": token};

    try {
      print('API URL: $url');
      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('fetchAdminDetails : ${response.statusCode}');
      print('fetchAdminDetails Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<AdminData> adminDetails = (jsonResponse['data'] as List)
            .map((json) => AdminData.fromJson(json))
            .toList();

        return AdminResponse(
          statusCode: jsonResponse['status_code'],
          status: jsonResponse['status'],
          message: jsonResponse['message'],
          data: adminDetails,
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load admin details');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch admin details: $e');
    }
  }

  Future<void> updateAdminDetails({
    required AdminData model,
    required File adminProfilePicture,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.updateAdmin}');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add fields to the multipart request
      request.fields['adminName'] = model.name;
      request.fields['emailAdmin'] = model.email;
      request.fields['mobilenoAdmin'] = model.phoneNo;
      request.fields['townAdmin'] = model.town;
      request.fields['addressAdmin'] = model.address;
      request.fields['zipcodeAdmin'] = model.zipcode.toString();
      request.fields['stateAdmin'] = model.state;
      request.fields['token'] = token;

      // Add adminProfilePicture as a file part
      var fileStream = http.ByteStream(adminProfilePicture.openRead());
      var length = await adminProfilePicture.length();
      var multipartFile = http.MultipartFile(
        'adminProfilePicture',
        fileStream,
        length,
        filename: adminProfilePicture.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await http.Response.fromStream(await request.send());

      print('updateAdminDetails : ${response.statusCode}');
      print('updateAdminDetails Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Admin details updated successfully');
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to update admin details');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to update admin details: $e');
    }
  }

  Future<CustomerResponseModelxx> fetchCustomer({
    required String salesmanId,
    required String customerName,
    required String startDate,
    required String endDate,
    required String limit,
    required String page,
    required String valueFromDw,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchCustomer}');
    final requestBody = {
      "salesman_id": salesmanId,
      "customer_name": customerName,
      "start_date": startDate,
      "end_date": endDate,
      "limit": limit,
      "page": page,
      "valueFromDw": valueFromDw,
    };

    try {
      print('API URL: $url');
      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('fetchCustomer : ${response.statusCode}');
      print('fetchCustomer Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var dataList = jsonResponse['data'] as List?;
        List<CustomerModelxx> customers = [];
        List<OrderTotalxx> orderTotal = [];
        if (dataList != null) {
          customers =
              dataList.map((json) => CustomerModelxx.fromJson(json)).toList();
        }

        return CustomerResponseModelxx(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: customers,
          orderTotal: orderTotal,
          pagination: Paginationxx.fromJson(jsonResponse['pagination'] ?? {}),
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<bool> addEvent(
      String customerId, int eventStatus, List<String> daysList) async {
    final String daysJson = jsonEncode(daysList); // Convert to JSON string
    final url = Uri.parse('$_baseUrl${ApiConstants.addEvent}');
    final body = jsonEncode({
      'customer_id': customerId,
      'event_status': eventStatus,
      'days_list': daysJson,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print("this is repose body : : : : :  ${response.body}");
        // Handle successful response if needed
        return true; // Event added successfully
      } else {
        // Handle error response
        print('Error: ${response.statusCode} ${response.body}');
        return false; // Event not added
      }
    } catch (e) {
      print('Exception: $e');
      return false; // Handle exception
    }
  }

  Future<ApiResponseModel> fetchCustomerDashboardDataa(
      String customerId, int specifiedYear) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.customer_dashboard_list}');

    final requestBody = {
      "customer_id": customerId,
      "specifiedYear": specifiedYear,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        // Print all the responses
        print("Response Data:");
        print(
            "Category Performance: ${jsonResponse['data']['category_performance']}");
        print("Recent Orders: ${jsonResponse['data']['recent_orders']}");
        print(
            "Frequent Product Lists: ${jsonResponse['data']['frequantliy_product_lists']}");
        print("Year List: ${jsonResponse['data']['year_list']}");
        print("Full Category: ${jsonResponse['data']['fullCategotry']}");
        // Parse category_performance
        List<CategoryPerformancez> categoryPerformance = [];
        if (jsonResponse['data']['category_performance'] != null) {
          categoryPerformance =
              (jsonResponse['data']['category_performance'] as List)
                  .map((json) => CategoryPerformancez.fromJson(json))
                  .toList();
        }

        // Parse allCategory
        List<FullCategory> allCategory = [];
        if (jsonResponse['data']['fullCategotry'] != null) {
          allCategory = (jsonResponse['data']['fullCategotry'] as List)
              .map((json) => FullCategory.fromJson(json))
              .toList();
        }
        print(
            "sabik ca ca ca caca cc acacac  ,${jsonResponse['data']['fullCategotry']}");

        // Parse recentOrders
        List<RecentOrder> recentOrders = [];
        if (jsonResponse['data']['recent_orders'] != null) {
          recentOrders = (jsonResponse['data']['recent_orders'] as List)
              .map((json) => RecentOrder.fromJson(json))
              .toList();
        }

        // Parse frequentProductLists
        List<FrequantliyProductList> frequentProductLists = [];
        if (jsonResponse['data']['frequantliy_product_lists'] != null) {
          frequentProductLists =
              (jsonResponse['data']['frequantliy_product_lists'] as List)
                  .map((json) => FrequantliyProductList.fromJson(json))
                  .toList();
        }

        // Parse yearList
        List<YearList> yearList = [];
        if (jsonResponse['data']['year_list'] != null) {
          yearList = (jsonResponse['data']['year_list'] as List)
              .map((json) => YearList.fromJson(json))
              .toList();
        }

        return ApiResponseModel(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: Data(
            categoryPerformance: categoryPerformance,
            recentOrders: recentOrders,
            frequentProductLists: frequentProductLists,
            yearList: yearList,
            fullCategory: allCategory,
          ),
        );
      } else {
        throw Exception(
            'Failed to fetch customer dashboard data - ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch customer dashboard data: $e');
    }
  }

  Future<CustomerTotalSaleResponse> fetchCustomerTotalSale(
      String customerId, int year) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.customeTotalSale}');

    final requestBody = {
      "customer_id": customerId,
      "year": year,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print("Response Data: ${jsonResponse['data']}");

        // Parse payment_completed
        PaymentCompleted paymentCompleted = PaymentCompleted.fromJson(
            jsonResponse['data']['total_sale']['payment_completed']);

        // Parse payment_remaning
        PaymentRemaining paymentRemaining = PaymentRemaining.fromJson(
            jsonResponse['data']['total_sale']['payment_remaning']);

        // Parse discount_data
        List<DiscountData> discountData = [];
        if (jsonResponse['data']['discount_data'] != null) {
          discountData = (jsonResponse['data']['discount_data'] as List)
              .map((json) => DiscountData.fromJson(json))
              .toList();
        }

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
    } catch (e) {
      throw Exception('Failed to fetch customer total sale data: $e');
    }
  }

  Future<ApiResponseModel> fetchCustomerDashboardData() async {
    final url = Uri.parse('$_baseUrl${ApiConstants.customer_dashboard_list}');

    final body = {
      'customer_id': 'CUSTO42',
      'specifiedYear': 2024,
    };

    try {
      final response = await http.post(url, body: body);
      print(
          " sabik k k k k kresponse k k k k  k k k  k kresponse k k kkresponse k k kresponse k k k  ${response}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print(
            " sabik k k k k k k k k k  k k k  k k k k kk k k k k k k  ${jsonData['data']}");

        return ApiResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  Future<ApiResponsees> fetchOrderCount(
    String customerId,
  ) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetchOrderCount}');
    final requestBody = {
      "salesman_id": "",
      "customer_id": customerId,
      "start_date": '',
      "end_date": '',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print("Response Data: ${jsonResponse['data']}");

        // Parse the data field from JSON
        OrderDataas orderData = OrderDataas.fromJson(jsonResponse['data']);

        print("Response sabik k k k  kk : ${jsonResponse['data']}");

        return ApiResponsees(
            statusCode: jsonResponse['status_code'] ?? 0,
            status: jsonResponse['status'] ?? false,
            message: jsonResponse['message'] ?? '',
            data: orderData);
      } else {
        throw Exception('Failed to fetch order count - ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch order count: $e');
    }
  }

  Future<CustomerResponse> fetchOneCustomer(String customerId) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.fetch_one_customer}');
    final requestBody = {
      "customer_id": customerId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        print('sasas json $jsonResponse');

        List<CustomerDashMo> customers = [];
        if (jsonResponse['data'] != null) {
          customers = (jsonResponse['data'] as List)
              .map((json) => CustomerDashMo.fromJson(json))
              .toList();
        }
        print("sui sui sui sui sui : :  - - - - == = $customers");

        return CustomerResponse(
          statusCode: jsonResponse['status_code'] ?? 0,
          status: jsonResponse['status'] ?? false,
          message: jsonResponse['message'] ?? '',
          data: customers,
        );
      } else {
        throw Exception(
            'Failed to fetch customer data - ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch customer data: $e');
    }
  }

  Future<void> updateCustomerDashDetails({
    required CustomerDashMo model,
    required File adminProfilePicture,
    required String customerId,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.update_customer}');

    try {
      var request = http.MultipartRequest('PATCH', url);

      // Add fields to the multipart request
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

      // Add adminProfilePicture as a file part
      var fileStream = http.ByteStream(adminProfilePicture.openRead());
      var length = await adminProfilePicture.length();
      var multipartFile = http.MultipartFile(
        'cutomerpicture',
        fileStream,
        length,
        filename: adminProfilePicture.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await http.Response.fromStream(await request.send());

      print('updateCustomerDashDetails : ${response.statusCode}');
      print('updateCustomerDashDetails Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Admin details updated successfully');
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to update admin details');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to update admin details: $e');
    }
  }

  Future<void> addCustomer(
      {required CustomerDashMo model,
      required File adminProfilePicture,
      required String salesmanId}) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.add_customer}');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add fields to the multipart request
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

      // Add adminProfilePicture as a file part
      var fileStream = http.ByteStream(adminProfilePicture.openRead());
      var length = await adminProfilePicture.length();
      var multipartFile = http.MultipartFile(
        'cutomerpicture',
        fileStream,
        length,
        filename: adminProfilePicture.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await http.Response.fromStream(await request.send());

      print('addCustomer : ${response.statusCode}');
      print('addCustomer Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Admin details updated successfully');
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to update admin details');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to update admin details: $e');
    }
  }

  Future<void> addLead({
    required CustomerDashMo model,
    required File adminProfilePicture,
    required String salesmanId,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConstants.add_customer}');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add fields to the multipart request
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

      // Add adminProfilePicture as a file part
      var fileStream = http.ByteStream(adminProfilePicture.openRead());
      var length = await adminProfilePicture.length();
      var multipartFile = http.MultipartFile(
        'cutomerpicture',
        fileStream,
        length,
        filename: adminProfilePicture.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send the request
      var response = await http.Response.fromStream(await request.send());

      print('addLead : ${response.statusCode}');
      print('addLead Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Admin details updated successfully');
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to update admin details');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to update admin details: $e');
    }
  }

  Future<CategoryResponse> fetchCategories() async {
    const String url =
        'http://16.50.232.153:3000/fetch_categories?company_id=1';
    // '$_baseUrl/fetch_categories?company_id=1';
    print('this is the fetchCategories() function');

    try {
      final response = await http.get(Uri.parse(url));

      // Check for a successful response
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Convert JSON to CategoryResponse object
        return CategoryResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Handle any errors
      print('Error fetching categories: $e');
      //this is the error we get
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<ApiResponseModel> fetchProductData() async {
    // const String url = '$_baseUrl/fetch_product?company_id=1';
    const String url = 'http://16.50.232.153:3000/fetch_products?company_id=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ApiResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
//  Future<void> updateAdmin({
//     required AdminData admin,
//     File? adminProfilePicture,
//     required String token,
//   }) async {
//     final url = Uri.parse('$_baseUrl/update_admin');
//     final headers = {'Content-Type': 'application/json'};
//     Map<String, dynamic> requestBody = {
//       'adminName': admin.name,
//       'emailAdmin': admin.email,
//       'mobilenoAdmin': admin.phoneNo,
//       'townAdmin': admin.town,
//       'addressAdmin': admin.address,
//       'zipcodeAdmin': admin.zipcode,
//       'stateAdmin': admin.state,
//       'token': token,
//     };

//     // Handle profile picture if provided
//     if (adminProfilePicture != null) {
//       List<int> imageBytes = adminProfilePicture.readAsBytesSync();
//       String base64Image = base64Encode(imageBytes);
//       requestBody['adminProfilePicture'] = base64Image;
//     }

//     try {
//       final response = await http.post(
//         url,
//         headers: headers,
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         // Optionally handle response data if needed
//       } else {
//         throw Exception('Failed to update admin');
//       }
//     } catch (e) {
//       throw Exception('Failed to update admin: $e');
//     }
//   }

class DashboardProvider with ChangeNotifier {
  Future<ResponseModell>? _futureResponseModel;
  Future<SalesmenResponse>? _salesmenResponse;
  Future<MessagesResponse>? _individualChatResponse;

  FilterDateEnum _selectedFilter = FilterDateEnum.thisMonth;
  String _selectedStartDate = '';
  String _selectedEndDate = '';
  final ApiService _apiService;
  final Logger _logger;

  DashboardProvider({required ApiService apiService, required Logger logger})
      : _apiService = apiService,
        _logger = logger {
     fetchData();
    fetchChatData('');
     fetchOrders();
    fetchAdminData();
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

  Future<void> fetchchartCategoryPerformmenc(dynamic catId) async {
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;

      // Iterate over each OrderStatus enum value
      for (OrderStatus status in OrderStatus.values) {
        _selectedStatus = status; // Set current status

        switch (_selectedFilter) {
          case FilterDateEnum.thisMonth:
            startDate = DateTime(now.year, now.month, 1)
                .toIso8601String()
                .substring(0, 10);
            endDate = DateTime(now.year, now.month + 1, 0)
                .toIso8601String()
                .substring(0, 10);
            break;
          case FilterDateEnum.today:
            startDate = DateTime(now.year, now.month, now.day)
                .toIso8601String()
                .substring(0, 10);
            endDate = startDate;
            break;
          case FilterDateEnum.thisWeek:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            startDate = startOfWeek.toIso8601String().substring(0, 10);
            endDate = now.toIso8601String().substring(0, 10);
            break;
          case FilterDateEnum.thisYear:
            startDate =
                DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
            endDate =
                DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
            break;
          case FilterDateEnum.range:
            startDate = _selectedStartDate;
            endDate = _selectedEndDate;
            break;
        }

        if (_selectedFilter == FilterDateEnum.range &&
            (startDate.isEmpty || endDate.isEmpty)) {
          throw Exception('Select both start and end dates');
        }

        // Debouncing network requests
        _responseModelCp = Future.delayed(Duration(milliseconds: 300), () {
          return _apiService.fetchDashboardCategoruPerformenceData(
            catId: catId,
            startDate: startDate,
            endDate: endDate,
          );
        });

        notifyListeners();

        print("Fetching orders for status: $_selectedStatus"); 

        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<SalesmenResponse>? get salesmenResponse => _salesmenResponse;
  Future<ResponseModell>? get futureResponseModel => _futureResponseModel;

  Future<MessagesResponse>? get individualChatResponse =>
      _individualChatResponse;
  FilterDateEnum get selectedFilter => _selectedFilter;
  String get selectedStartDate => _selectedStartDate;
  String get selectedEndDate => _selectedEndDate;
  SalesmanChat? selectedChat;
  final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
  Future<void> fetchOrdersForCustomDash(OrderStatus s, String custId) async {
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;

      switch (_selectedFilter) {
        case FilterDateEnum.thisMonth:
          startDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          endDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;
        case FilterDateEnum.today:
          startDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          endDate = startDate;
          break;
        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startDate = startOfWeek.toIso8601String().substring(0, 10);
          endDate = now.toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.thisYear:
          startDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          endDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.range:
          startDate = _selectedStartDate;
          endDate = _selectedEndDate;
          break;
      }

      if (_selectedFilter == FilterDateEnum.range &&
          (startDate.isEmpty || endDate.isEmpty)) {
        throw Exception('Select both start and end dates');
      }
      _orderResponse = Future.delayed(Duration(milliseconds: 300), () {
        return _apiService.fetchCustomerDashOrders(
            cusId: custId,
            salesmanId: salesmanId,
            startDate: startDate,
            endDate: endDate,
            orderStatus: s);
      });
      print("sadfdfoijgdiof sabik kavungal ponmala pllippadi k ${s.type}");

      notifyListeners();

      print(
          "sabik kkavungal ponmala pllippadi kkdc.fc.v.v.v.v.v.v.v.v.v.v.v.v. .. .  . . . .${_orderResponse}");

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> fetchOrdersSabik(OrderStatus s) async {
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;

      switch (_selectedFilter) {
        case FilterDateEnum.thisMonth:
          startDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          endDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;
        case FilterDateEnum.today:
          startDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          endDate = startDate;
          break;
        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startDate = startOfWeek.toIso8601String().substring(0, 10);
          endDate = now.toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.thisYear:
          startDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          endDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.range:
          startDate = _selectedStartDate;
          endDate = _selectedEndDate;
          break;
      }

      if (_selectedFilter == FilterDateEnum.range &&
          (startDate.isEmpty || endDate.isEmpty)) {
        throw Exception('Select both start and end dates');
      }

      // Debouncing network requests
      _orderResponse = Future.delayed(Duration(milliseconds: 300), () {
        return _apiService.fetchAllOrders(
            startDate: startDate, endDate: endDate, orderStatus: s);
      });
      print("sadfdfoijgdiof sabik kavungal ponmala pllippadi k ${s.type}");

      notifyListeners();

      print(
          "sabik kkavungal ponmala pllippadi kkdc.fc.v.v.v.v.v.v.v.v.v.v.v.v. .. .  . . . .${_orderResponse}");

      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  OrderStatus _selectedStatus = OrderStatus.cancelled;

  Future<void> fetchOrders() async {
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;
      for (OrderStatus status in OrderStatus.values) {
        _selectedStatus = status;

        switch (_selectedFilter) {
          case FilterDateEnum.thisMonth:
            startDate = DateTime(now.year, now.month, 1)
                .toIso8601String()
                .substring(0, 10);
            endDate = DateTime(now.year, now.month + 1, 0)
                .toIso8601String()
                .substring(0, 10);
            break;
          case FilterDateEnum.today:
            startDate = DateTime(now.year, now.month, now.day)
                .toIso8601String()
                .substring(0, 10);
            endDate = startDate;
            break;
          case FilterDateEnum.thisWeek:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            startDate = startOfWeek.toIso8601String().substring(0, 10);
            endDate = now.toIso8601String().substring(0, 10);
            break;
          case FilterDateEnum.thisYear:
            startDate =
                DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
            endDate =
                DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
            break;
          case FilterDateEnum.range:
            startDate = _selectedStartDate;
            endDate = _selectedEndDate;
            break;
        }

        if (_selectedFilter == FilterDateEnum.range &&
            (startDate.isEmpty || endDate.isEmpty)) {
          throw Exception('Select both start and end dates');
        }

        // Debouncing network requests
        _orderResponse = Future.delayed(Duration(milliseconds: 300), () {
          return _apiService.fetchAllOrders(
            startDate: startDate,
            endDate: endDate,
            orderStatus: _selectedStatus, // Pass current status
          );
        });

        notifyListeners();

        print("Fetching orders for status: $_selectedStatus"); // Debug print

        // You might want to await _orderResponse here if needed

        notifyListeners();
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching orders', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  // Future<void> selectDate(BuildContext context, bool isStartDate) async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: isStartDate
  //         ? DateTime.parse(_selectedStartDate)
  //         : DateTime.parse(_selectedEndDate),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2100),
  //   );

  //   if (pickedDate != null) {
  //     final formattedDate = pickedDate.toIso8601String().substring(0, 10);
  //     if (isStartDate) {
  //       _selectedStartDate = formattedDate;
  //     } else {
  //       _selectedEndDate = formattedDate;
  //     }
  //     notifyListeners();
  //   }
  // }
  // void fetchDatas() {
  //   _futureResponseModel = _apiService.fetchDashboardData(
  //     salesmanId: "",
  //     startDate: DateTime.now().toIso8601String(),
  //     endDate: DateTime.now().toIso8601String(),
  //   ); // Replace with your actual API call
  //   notifyListeners();
  // }
  // void onFilterChanged(FilterDateEnum? selectedFilter) {
  //   if (selectedFilter != null) {
  //     _selectedFilter = selectedFilter;
  //     if (_selectedFilter != FilterDateEnum.range) {
  //       _selectedStartDate = '2024-06-01';
  //       _selectedEndDate = '2024-06-30';
  //     }
  //     fetchData();
  //   }
  // }
// void onFilterChanged(FilterDateEnum? selectedFilter) {
//   if (selectedFilter != null) {
//     _selectedFilter = selectedFilter;

//     // Reset dates if not in range
//     if (_selectedFilter != FilterDateEnum.range) {
//       _selectedStartDate = _selectedStartDate;
//       _selectedEndDate = _selectedEndDate;
//     }

//     // Fetch data only if the filter is not a range
//     if (_selectedFilter != FilterDateEnum.range) {
//       fetchData();  // Fetch data based on the selected filter
//       fetchOrders(); // Fetch orders based on the selected filter
//       notifyListeners();
//     }
//   }
// }
  void onFilterChanged(FilterDateEnum? selectedFilter) {
    log('on filter changed');
    if (selectedFilter != null) {
      _selectedFilter = selectedFilter;
      if (_selectedFilter != FilterDateEnum.range) {
        _selectedStartDate = '';
        _selectedEndDate = '';
      }
      if (_selectedFilter != FilterDateEnum.range) {
        fetchData();
        fetchOrders();
      }

      notifyListeners();
    }
  }

  Future<void> fetchData() async {
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    String createdToken = jsonMap['createdToken'];
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;

      switch (_selectedFilter) {
        case FilterDateEnum.thisMonth:
          startDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          endDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;
        case FilterDateEnum.today:
          startDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          endDate = startDate;
          break;
        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startDate = startOfWeek.toIso8601String().substring(0, 10);
          endDate = now.toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.thisYear:
          startDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          endDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.range:
          startDate = _selectedStartDate;
          endDate = _selectedEndDate;
         
          if (startDate.isEmpty || endDate.isEmpty) {
            return;
          }
          break;
      }
      _futureResponseModel = Future.delayed(Duration(seconds: 2), () {
        Future<ResponseModell> api = _apiService.fetchDashboardData(
          salesmanId: salesmanId,
          startDate: startDate,
          endDate: endDate,
          createdToken: createdToken,
        );
        //log('Future response :++++++++++${api}');
        return api;
      });
      if (_selectedFilter != FilterDateEnum.range) {
        //fetchOrders();
      }

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
      final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      if (isStartDate) {
        _selectedStartDate = formattedDate;
      } else {
        _selectedEndDate = formattedDate;
      }

      // Only fetch data if both dates are set when range is selected
      if (_selectedFilter == FilterDateEnum.range &&
          _selectedStartDate.isNotEmpty &&
          _selectedEndDate.isNotEmpty) {
        // fetchData(); // Fetch data after selecting both dates
      }
      notifyListeners();
    }
  }

  Future<SalesmenResponse> fetchChatData(String salesmanId) async {
    try {
      final chatData = await _apiService.fetchChatData(salesmanId);
      _salesmenResponse = Future.value(chatData);
      notifyListeners();
      return chatData;
    } catch (e, stackTrace) {
      _logger.e('Error fetching chat data', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch chat data: $e');
    }
  }

  // Future<MessagesResponse> fetch_individual_chat(String chatId) async {
  //   try {
  //     final chatData = await _apiService.fetch_individual_chat(chatId);
  //     _individualChatResponse = Future.value(chatData);
  //     notifyListeners();
  //     return chatData;
  //   } catch (e, stackTrace) {
  //     _logger.e('Error fetching individual chat data',
  //         error: e, stackTrace: stackTrace);
  //     throw Exception('Failed to fetch individual chat data: $e');
  //   }
  // }

  // Future<void> postAdminMessage(String salesmanId, String message) async {
  //   try {
  //     await _apiService.postAdminMessage(
  //         salesmanId: salesmanId, message: message);
  //     notifyListeners();
  //   } catch (e, stackTrace) {
  //     _logger.e('Error posting admin message',
  //         error: e, stackTrace: stackTrace);
  //     throw Exception('Failed to post admin message: $e');
  //   }
  // }

  List<Messages>? _individualChatMessages;
  List<Messages>? get individualChatMessages => _individualChatMessages;

  List<SalesmanChat> selectedChats = [];

  Future<void> fetch_individual_chat(String chatId) async {
    try {
      final chatData = await _apiService.fetch_individual_chat(chatId);
      _individualChatMessages = chatData.data;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error fetching individual chat data',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch individual chat data: $e');
    }
  }

  Future<void> postAdminMessage(String chatId, String message) async {
    try {
      await _apiService.postAdminMessage(salesmanId: chatId, message: message);
      _individualChatMessages?.add(Messages(
        message: message,
        source: 'admin',
        id: 0,
        chatId: '',
        status: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Add other necessary fields
      ));
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e('Error posting admin message',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to post admin message: $e');
    }
  }

  void selectChat(SalesmanChat chat) {
    selectedChat = chat;
    fetch_individual_chat(chat.salesmanId);
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

  Future<AdminResponse> fetchAdminData() async {
    try {
      final chatData = await _apiService.fetchAdminDetails(token: 'AAAAAAAAA');
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

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _apiService.changeOrderStatus(orderId, newStatus);
      //fetchOrders();
      print('sabik . . . . .. orderid $orderId');
      print('sabik  . . . . . . . .newData $newStatus');
      fetchData();
      notifyListeners(); // Notify listeners after successful update
    } catch (e) {
      // Handle errors or exceptions
      print('Failed to update order status: $e');
      throw Exception('Failed to update order status: $e');
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

  File? _imageFileC;
  final ImagePicker _pickerC = ImagePicker();

  File? get imageFileC => _imageFile;

  Future<void> pickImageCommuni() async {
    final pickedFile = await _pickerC.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _imageFileC = File(pickedFile.path);
      notifyListeners();
    }
  }

  void clearImage() {
    _imageFile = null;
    notifyListeners();
  }

  Future<void> updateAdmin({
    required AdminData admin,
  }) async {
    try {
      await _apiService
          .updateAdminDetails(
              model: admin, adminProfilePicture: imageFile!, token: 'AAAAAAAAA')
          .then((value) => fetchAdminData())
          .then((value) => fetchData());

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update admin: $e');
    }
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

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _selectedOrderStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<OrderResponse>(
            future: provider.orderResponse,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final orders = snapshot.data?.data ?? [];

                // Filter orders based on selected order status
                final filteredOrders = orders.where((order) {
                  if (_selectedOrderStatus == null) {
                    return true; // Show all orders if no status filter is selected
                  } else {
                    return order.orderStatus == _selectedOrderStatus!.type;
                  }
                }).toList();

                return Column(
                  children: [
                    // Status filter buttons or checkboxes
                    _buildStatusFilterButtons(provider),

                    // Orders list
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return ListTile(
                            title: Text('Order ID: ${order.orderId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer ID: ${order.customerId}'),
                                Text('Payment Type: ${order.paymentType}'),
                                Text(
                                    'Order Created At: ${order.orderCreatedAt}'),
                                Text(
                                    'Order Total: \$${order.orderTotal.toStringAsFixed(2)}'),
                                Text(
                                    'Order Status: ${getOrderStatusName(order.orderStatus)}'),
                                // Add more fields as needed
                              ],
                            ),
                            onTap: () =>
                                _showOrderDetailsDialog(context, order),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusFilterButtons(DashboardProvider p) {
    return Wrap(
      //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            p.fetchOrdersSabik(OrderStatus.delivered);
            setState(() {
              _selectedOrderStatus = OrderStatus.delivered;
            });
          },
          child: Text('Delivered'),
        ),
        ElevatedButton(
          onPressed: () {
            p.fetchOrdersSabik(OrderStatus.outOfDelivery);
            setState(() {
              _selectedOrderStatus = OrderStatus.outOfDelivery;
            });
          },
          child: Text('outOfDelivery'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedOrderStatus = OrderStatus.preOrder;
            });
          },
          child: Text('Pre Order'),
        ),
        ElevatedButton(
          onPressed: () {
            p.fetchOrdersSabik(OrderStatus.cancelled);

            setState(() {
              _selectedOrderStatus = OrderStatus.cancelled;
            });
          },
          child: Text('Canccelled'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedOrderStatus = null; // Clear filter
            });
          },
          child: Text('Show All'),
        ),
      ],
    );
  }

  String getOrderStatusName(int orderStatus) {
    switch (orderStatus) {
      case 0:
        return 'Pre Order';
      case 1:
        return 'Out For Delivery';
      case 2:
        return 'Delivered';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Draft';
      case 5:
        return 'Processing';
      case 6:
        return 'Pending';
      case 7:
        return 'Estimates';
      case 8:
        return 'Accept By Admin';
      case 9:
        return 'Reject By Admin';
      case 10:
        return 'Packed For Delivery';
      default:
        return '';
    }
  }

  void _showOrderDetailsDialog(BuildContext context, OrdersDash order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Order Details',
                // style: TextStyle(
                //   fontSize: 18,
                //   fontWeight: FontWeight.bold,
                // ),
              ),
            ),
            ListTile(
              title: Text('Order ID: ${order.orderId}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer ID: ${order.customerId}'),
                  Text('Payment Type: ${order.paymentType}'),
                  Text('Order Created At: ${order.orderCreatedAt}'),
                  Text('Order Total: \$${order.orderTotal.toStringAsFixed(2)}'),
                  Text(
                      'Order Status: ${getOrderStatusName(order.orderStatus)}'),
                  // Add more fields as needed
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String salesmanId;

  ChatScreen({required this.salesmanId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<DashboardProvider>(context, listen: false)
        .fetchChatData(widget.salesmanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Data'),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<SalesmenResponse>(
            future: provider.salesmenResponse,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return Center(
                  child: Text('No chat data available'),
                );
              } else {
                final chatData = snapshot.data!.data;
                return ListView.builder(
                  itemCount: chatData.length,
                  itemBuilder: (context, index) {
                    final chatList = chatData[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: chatList.map((chat) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salesman ID: ${chat.salesmanId}',
                                  //   style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Message: ${chat.message}'),
                                Text('Message: ${chat.email}'),
                                SizedBox(height: 8.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardProvider(
        apiService: ApiService(),
        logger: Logger(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Category List'),
        ),
        body: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<FilterDateEnum>(
                    value: provider.selectedFilter,
                    onChanged: provider.onFilterChanged,
                    items: const [
                      DropdownMenuItem(
                        value: FilterDateEnum.thisMonth,
                        child: Text('This Month'),
                      ),
                      DropdownMenuItem(
                        value: FilterDateEnum.today,
                        child: Text('Today'),
                      ),
                      DropdownMenuItem(
                        value: FilterDateEnum.thisWeek,
                        child: Text('This Week'),
                      ),
                      DropdownMenuItem(
                        value: FilterDateEnum.thisYear,
                        child: Text('This Year'),
                      ),
                      DropdownMenuItem(
                        value: FilterDateEnum.range,
                        child: Text('Range'),
                      ),
                    ],
                  ),
                ),
                if (provider.selectedFilter == FilterDateEnum.range)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => provider.selectDate(context, true),
                          child: const Text('Select Start Date'),
                        ),
                        Text('Start Date: ${provider.selectedStartDate}'),
                        ElevatedButton(
                          onPressed: () => provider.selectDate(context, false),
                          child: const Text('Select End Date'),
                        ),
                        Text('End Date: ${provider.selectedEndDate}'),
                        ElevatedButton(
                          onPressed: provider.fetchData,
                          child: const Text('Load Data'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: FutureBuilder<ResponseModell>(
                    future: provider.futureResponseModel,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final categories = snapshot.data!.allCategory;
                        final categoryPerformance =
                            snapshot.data!.categoryPerformance;
                        final revenu = snapshot.data!.revenue;
                        final collection = snapshot.data!.collection;
                        final delivery = snapshot.data!.delivery; // Added
                        final topSellingProducts =
                            snapshot.data!.topSellingProducts; // New

                        return ListView.builder(
                          itemCount: categories?.length,
                          itemBuilder: (context, index) {
                            final category = categories?[index];
                            final categoryPerf =
                                categoryPerformance!.firstWhere(
                              (perf) => perf.category == category?.category,
                              orElse: () => CategoryPerformancee(
                                // salesmanId: '',
                                cid: 0,
                                category: category!.category,
                                //   count: 0,
                                actualProjection: 0.0,
                                salesman: [], actualTarget: 0,
                              ),
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: ExpansionTile(
                                title: Text(category!.category!),
                                children: [
                                  ListTile(
                                    title: const Text('Category Performance'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Count: ${categoryPerf.actualProjection}'),
                                        Text(
                                            'Actual Projection: ${categoryPerf.actualProjection?.toStringAsFixed(2)}'),
                                        const Divider(),
                                        const Text('Salesmen:'),
                                        ...categoryPerf.salesman!
                                            .map((salesman) => ListTile(
                                                  title: Text(
                                                      salesman.fullname ?? ''),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Salesman ID: ${salesman.salesmanId}'),
                                                      Text(
                                                          'Projection Target: ${salesman.projectionTarget}'),
                                                      Text(
                                                          'Projection Price: ${salesman.projectionPrice?.toStringAsFixed(2)}'),
                                                      Text(
                                                          'Actual Price: ${salesman.actualPrice?.toStringAsFixed(2)}'),
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Open the edit dialog or screen
                                        // After editing, call provider.updateCategory with the updated category
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Revenue Data'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Booking Revenue Data: ${revenu!.bookingRevenueData}'),
                                        const Divider(),
                                        Text('Order Revenue Data:'),
                                        ...revenu.orderRevenueData!
                                            .map((order) => ListTile(
                                                  title:
                                                      Text(order.orderId ?? ''),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Total: ${order.total}'),
                                                      Text(
                                                          'Discount: ${order.discount}'),
                                                      Text(
                                                          'Status: ${order.status}'),
                                                      Text(
                                                          'Created At: ${order.createdAt}'),
                                                      // Add more fields as needed
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Collection Data'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Total Pending Amount: ${collection!.order!.pendingAmount?.length}'),
                                        const Divider(),
                                        Text('Completed Orders:'),
                                        ...collection.payment!.completedOrders!
                                            .map((order) => ListTile(
                                                  title: Text(order.orderId),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Total: ${order.orderTotal}'),
                                                      Text(
                                                          'Received Amount: ${order.receivedAmount}'),
                                                      Text(
                                                          'Received Amount Date: ${order.receivedAmountDate}'),
                                                      // Add more fields as needed
                                                    ],
                                                  ),
                                                )),
                                        const Divider(),
                                        Text('Overdue Amount:'),
                                        ...collection.overdue!.overdueAmount!
                                            .map((order) => ListTile(
                                                  title:
                                                      Text(order.orderId ?? ''),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Total: ${order.amount}'),
                                                      Text(
                                                          'Due Date: ${order.dueDate}'),
                                                      // Add more fields as needed
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text(
                                        'Delivery Data'), // New section for delivery data
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Order Count: ${delivery?.order?.totalOrders?.length}'),
                                        const Divider(),
                                        Text(
                                            'Delivery Percentage: ${delivery?.deliveryOrder?.percentage}'),
                                        ...delivery!.order!.totalOrders!
                                            .map((orderDetails) => ListTile(
                                                  title: Text('Order Details'),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Order ID: ${orderDetails.orderId}'),
                                                      Text(
                                                          'Status: ${orderDetails.orderStatus}'),
                                                      Text(
                                                          'Total: ${orderDetails.delivered}'),
                                                      // Add more fields as needed
                                                    ],
                                                  ),
                                                )),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('Top Selling Products'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...topSellingProducts!.map((product) =>
                                            ListTile(
                                              title: Text(
                                                  'Product ID: ${product.variationId}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Created At: ${product.createdAt}'),
                                                  const Text('Customers:'),
                                                  ...product.customers!.map(
                                                      (customer) => ListTile(
                                                            title: Text(customer
                                                                    .fullname ??
                                                                ''),
                                                            subtitle: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    'Customer ID: ${customer.customerId}'),
                                                                Text(
                                                                    'Email: ${customer.email}'),
                                                                Text(
                                                                    'Mobile No: ${customer.mobileno}'),
                                                                // Add more fields as needed
                                                              ],
                                                            ),
                                                          )),
                                                  const Text('Quantity List:'),
                                                  ...product.quantityList!.map(
                                                      (quantity) => ListTile(
                                                            title: Text(
                                                                'Quantity ID: ${quantity.id}'),
                                                            subtitle: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    'Product ID: ${quantity.productId}'),
                                                                Text(
                                                                    'Quantity: ${quantity.quantity}'),
                                                                Text(
                                                                    'Price: ${quantity.price}'),
                                                                // Add more fields as needed
                                                              ],
                                                            ),
                                                          )),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text('No data found'));
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
