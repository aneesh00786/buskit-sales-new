import 'dart:convert';
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
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_table_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/sibscription_model.dart';
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
  final ConnectivityService _connectivityService = ConnectivityService();
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
  Future<Response> sendOtp(String email) async {
    Map<String, dynamic> data = {
      'email': email,
    };
    try {
      final response = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.sendOtp}',
        data: data,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      handleExceptionMessage(apiName: "OTP", error: e, response: e.response);
      log('Error sending OTP: $e');
      rethrow;
    }
  }

  errorSnackbar(String message) {
    NkCommonFunction.showErrorSnakBar(message);
  }

  Future<Response> resetPassword(
      String email, String newPassword, String otp) async {
    Map<String, dynamic> data = {
      "email": email,
      "otp": otp,
      "newPassword": newPassword
    };
    final response = await dio
        .postbycustom(
      ApiConstants.verifyOtp,
      data: data,
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<LoginResponce?> loginApi(String email, String password) async {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };
    try {
      final response = await responsePostMethod(
          requestData: data, endPoint: ApiConstants.login);
      if (response.data != null) {
        final status = response.data['status'];
        final message = response.data['message'] ?? 'No message available';
        final statusCode = response.data['status_code'];
        if (status == false) {
          return LoginResponce(
            status: false,
            message: message,
            statusCode: statusCode,
          );
        }
        return LoginResponce.fromJson(response.data);
      } else {
        NkCommonFunction.showErrorSnakBar("${response.data['message']}");
        handleExceptionMessage(response: response, apiName: "login");
        return null;
      }
    } on DioException catch (error) {
      final errorData = error.response?.data;
      int statusCode = error.response?.statusCode ?? 0;
      String message = errorData?['message'] ?? 'An error occurred';
      handleExceptionMessage(
          response: error.response, apiName: "login", error: error);
      return LoginResponce(
        status: false,
        message: message,
        statusCode: statusCode,
      );
    } catch (e) {
      log("Login Error: $e");
      return LoginResponce(
        status: false,
        message: 'An unexpected error occurred.',
        statusCode: null,
      );
    }
  }

  Future<LeadsCountData> fetchLeadsCount() async {
    final Map<String, dynamic> requestData = {
      'companyId': companyId,
      'salesman_id': salesmanId,
    };
    try {
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: ApiConstants.fetchLeadsCount,
      );
      return LeadsCountData.fromJson(response.data);
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "leads count", error: error);
      return Future.error('No data available leads count');
    }
  }

  Future<List<AllCompanySettingsData>?> fetchAllSettings(int companyId) async {
    const cacheKey = 'all_settings_data';
    final settingsBox = Hive.box('settingsBox');
    bool isOnline = await ConnectivityService().isOnline();
    final requestData = {
      "compay_id": "$companyId",
    };
    if (isOnline) {
      try {
        final response = await responsePostMethod(
            requestData: requestData, endPoint: ApiConstants.fetchAllSetting);
        List<dynamic> dataList = response.data['data'] ?? [];
        List<AllCompanySettingsData> settingsList = dataList
            .map((item) => AllCompanySettingsData.fromJson(item))
            .toList();
        await settingsBox.put(
          cacheKey,
          settingsList.map((setting) => setting.toJson()).toList(),
        );
        await SessionHelper().setSettingsData(settingsList);
        return settingsList;
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "settings", error: error);
        return localStorage.storedSettingsData(settingsBox, cacheKey);
      } catch (e) {
        log("Error fetching settings: $e");
        errorSnackbar('An error occurred while fetching settings.');
      }
    }
    try {
      return localStorage.storedSettingsData(settingsBox, cacheKey);
    } catch (e) {
      log('Error fetching settings from Hive: $e');
      errorSnackbar('Error accessing offline settings data.');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchSalesmanTopBarData(
      String monthName, int tabStatus) async {
    try {
      final requestPayload = {
        "companyId": companyId,
        "salesman_id": salesmanId,
        "year": 2025,
        "month": monthName,
        "status_of_tile": tabStatus,
      };
      Response response = await responsePostMethod(
          requestData: requestPayload,
          endPoint: ApiConstants.salesmanDashNavContent);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        handleExceptionMessage(
            response: response, apiName: "salesman dash nav content");
        return null;
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "salesman dash nav content",
          error: error);
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
    final requestPayload = {
      "companyId": isfromLogin ? compId : companyId,
      "salesman_id": isfromLogin ? salesId : salesmanId,
      "year": year,
      "month": monthName,
      "targetType": targetType,
    };
    final cacheKey = 'performance_data_${salesmanId}_${year}_$monthName';
    final performanceBox = Hive.box('performanceBox');
    try {
      Response response = await responsePostMethod(
          requestData: requestPayload, endPoint: ApiConstants.salesmanDashView);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data['data'];
        log('Performance Response: $jsonData');
        await performanceBox.put(cacheKey, jsonData);
        return PerformanceData.fromJson(jsonData);
      } else {
        log("Failed to load data: ${response.statusCode} ${response.statusMessage}");
        return localStorage.storedPerfromanceData(performanceBox, cacheKey);
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "perfromance", error: error);
      return localStorage.storedPerfromanceData(performanceBox, cacheKey);
    } catch (e) {
      log("Error fetching salesman Performance: $e");
      return null;
    }
  }

  Future<FetchSpecificOrderInvoice> fetchSpecificOrderInvoice(
      String orderId) async {
    try {
      final bool isOnline = await ConnectivityService().isOnline();
      final requestData = {
        "order_id": orderId,
        "companyId": companyId,
      };
      if (!isOnline) {
        NkCommonFunction.showErrorSnakBar(
            'No internet connection. Please check your network and try again.');
        return Future.error('No internet connection');
      } else {
        final response = await responsePostMethod(
          requestData: requestData,
          endPoint: ApiConstants.fetchSpecificOrder,
          options: Options(
            validateStatus: (status) {
              return true;
            },
          ),
        );
        if (response.statusCode == 200) {
          return FetchSpecificOrderInvoice.fromJson(response.data);
        } else {
          handleExceptionMessage(
              response: response, apiName: "specific order invoice");
          return Future.error('API Error: ${response.statusCode}');
        }
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "specific order invoice,",
          error: error);
      return Future.error(error);
    }
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
      log('This function has been calledsss');
      bool isOnline = await ConnectivityService().isOnline();
      final requestBody = {
        "company_id": companyId,
        "salesman_id": salesmanId,
      };
      if (isOnline) {
        log('This function has been calledsss');
        final response = await responsePostMethod(
            requestData: requestBody, endPoint: ApiConstants.fetchcustomer);
        if (response.statusCode == 200) {
          log('This function has been calledsss');
          final customerData = CustomerAndOrderResponce.fromJson(response.data);
          await localStorage.storeCustomerData(customerData);
          return customerData;
        } else {
          handleExceptionMessage(response: response, apiName: "get customer");
          return Future.error('API Error: On Fetching Customer');
        }
      } else {
        log('No internet, fetching customer data from Hive...');
        final customerData = await localStorage.retrieveCustomerData();
        if (customerData != null) {
          log('Loaded customer data from Hive');
          return customerData;
        } else {
          throw Exception('No customer data available offline');
        }
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "get customer", error: error);
      return Future.error(
          'Failed to fetch customer data From API Worker: $error');
    }
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
    bool isOnline = await ConnectivityService().isOnline();
    final cacheKey = 'recent_order_count_${startDate ?? ''}_${endDate ?? ''}';
    if (isOnline) {
      try {
        final response = await responsePostMethod(
            requestData: requestData, endPoint: ApiConstants.recentOrderCount);
        var orderCountBox = await Hive.openBox('orderCountBox');
        await orderCountBox.put(cacheKey, response.data);
        return RecentOrderCountResponse.fromJson(response.data);
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "recent order", error: error);
        log('API Error: ${error.response?.data}');
        return await localStorage.getCachedRecentOrderCount(cacheKey);
      }
    } else {
      log('No internet. Fetching from Hive...');
      return await localStorage.getCachedRecentOrderCount(cacheKey);
    }
  }

  Future<CartOrderModel?> addToCart(Map<String, dynamic> sendData) async {
    sendData['companyId'] = companyId;
    log('[addToCart] Request Data: ${sendData.toString()}');
    try {
      final response = await dio1
          .post(
        "${ApiConstants.baseUrl}${ApiConstants.addToCart}",
        data: FormData.fromMap(sendData),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw DioException(
          requestOptions: RequestOptions(
              path: '${ApiConstants.baseUrl}${ApiConstants.addToCart}'),
          type: DioExceptionType.connectionTimeout,
        );
      });
      if (response.statusCode == 200) {
        if (response.data['cart_id'] == null) {
          log('[addToCart] Cart ID is null in response.');
          return null;
        }
        log('[addToCart] Response Data: ${response.data}');
        return CartOrderModel.fromJson(response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "add to cart");
        log('[addToCart] Unexpected status code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (error) {
      // if (error.type == DioExceptionType.connectionTimeout ||
      //     error.type == DioExceptionType.receiveTimeout) {
      //   log("Fetch Leads Count Timeout: $error");
      //   errorSnackbar(
      //       'Request timed out. Please check your internet connection and try again.');
      //   return Future.error(
      //     'Request timed out. Please check your internet connection and try again.',
      //   );
      // }
      handleExceptionMessage(
          response: error.response, apiName: "add to cart", error: error);
      log('[addToCart] Exception: $error');
      return Future.error(DioExceptionHandler.fromDioError(error));
    }
  }

  Future<CartOrderModel?> addToDraft(Map<String, dynamic> sendData) async {
    sendData['companyId'] = companyId;
    log('[addToDraft] Request Data: ${sendData.toString()}');
    try {
      final response = await dio1
          .post(
        "${ApiConstants.baseUrl}${ApiConstants.addToDraft}",
        data: FormData.fromMap(sendData),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw DioException(
          requestOptions: RequestOptions(
              path: '${ApiConstants.baseUrl}${ApiConstants.addToDraft}'),
          type: DioExceptionType.connectionTimeout,
        );
      });
      if (response.statusCode == 200) {
        if (response.data['cart_id'] == null) {
          log('[addToDraft] Cart ID is null in response.');
          return null;
        }
        log('[addToDraft] Response Data: ${response.data}');
        return CartOrderModel.fromJson(response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "add to draft");
        log('[addToDraft] Unexpected status code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (error) {
      // if (error.type == DioExceptionType.connectionTimeout ||
      //     error.type == DioExceptionType.receiveTimeout) {
      //   log("Fetch Leads Count Timeout: $error");
      //   errorSnackbar(
      //       'Request timed out. Please check your internet connection and try again.');
      //   return Future.error(
      //     'Request timed out. Please check your internet connection and try again.',
      //   );
      // }
      handleExceptionMessage(
          response: error.response, apiName: "add to draft", error: error);
      log('[addToCart] Exception: $error');
      return Future.error(DioExceptionHandler.fromDioError(error));
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

  /// ************************ CATEGORY SECTION ***************** ///
  Future<CategoryModel> getCategory() async {
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      final box = await Hive.openBox('categoriesBox');
      return localStorage.storedCategoryData(box);
    } else {
      try {
        final response = await dio1.get(
          '${ApiConstants.baseUrl}${ApiConstants.fetchcategories}',
          queryParameters: {"company_id": companyId},
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(
                path: '${ApiConstants.baseUrl}${ApiConstants.fetchcategories}'),
            type: DioExceptionType.connectionTimeout,
          );
        });
        final category = CategoryModel.fromJson(response.data);
        final box = await Hive.openBox('categoriesBox');
        await box.put('categoryItem', category.toJson());
        return category;
      } on DioException catch (error) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          log("Fetch Leads Count Timeout: $error");
          errorSnackbar(
              'Request timed out. Please check your internet connection and try again.');
          return Future.error(
            'Request timed out. Please check your internet connection and try again.',
          );
        }
        log("to This Exception");
        handleExceptionMessage(
            response: error.response,
            apiName: "product category",
            error: error);
        final box = await Hive.openBox('categoriesBox');
        return localStorage.storedCategoryData(box);
      }
    }
  }

  /// ************************ PRODUCT SECTION ***************** ///
  Future<List<ProductModel>> getTempProduct(String subCatId) async {
    List<ProductModel> allProducts = [];
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      try {
        final requestParams = {"company_id": companyId};
        final response = await dio1
            .get(
          '${ApiConstants.baseUrl}${ApiConstants.fetchproduct}',
          queryParameters: requestParams,
        )
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(
                path: '${ApiConstants.baseUrl}${ApiConstants.fetchproduct}'),
            type: DioExceptionType.connectionTimeout,
          );
        });
        if (response.statusCode == 200 && response.data['data'] is List) {
          for (var item in response.data['data']) {
            if (item['product'] is List) {
              allProducts.addAll((item['product'] as List)
                  .map((productJson) => ProductModel.fromJson(productJson))
                  .toList());
            }
          }
          var productBox = Hive.box('productBox');
          await productBox.put(
            'products',
            allProducts.map((product) => product.toJson()).toList(),
          );
        } else {
          errorSnackbar("Failed to fetch Products from the API");
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          log("Fetch Leads Count Timeout: $error");
          errorSnackbar(
              'Request timed out. Please check your internet connection and try again.');
          return Future.error(
            'Request timed out. Please check your internet connection and try again.',
          );
        }
        handleExceptionMessage(
            response: error.response, apiName: "products", error: error);
      }
    } else {
      log('No internet. Fetching from Hive...');
    }
    try {
      var productBox = Hive.box('productBox');
      allProducts = localStorage.storedProductData(productBox, allProducts);
    } catch (e) {
      log('Error fetching from Hive: $e');
    }
    List<ProductModel> filteredProducts = allProducts.where((product) {
      return product.scid == subCatId;
    }).toList();
    return filteredProducts;
  }

  Future<void> fetchDiscounts(int companyId, String salesmanId) async {
    try {
      Map<String, dynamic> requestPayload = {
        "companyId": companyId,
        "salesman_id": salesmanId,
      };
      Response response = await responsePostMethod(
          requestData: requestPayload, endPoint: ApiConstants.fetchAllDiscount);
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is List<dynamic>) {
          List<dynamic> dataList = response.data['data'];
          List<CustomerDiscountModel> discountList = dataList.map((data) {
            return CustomerDiscountModel.fromJson(data);
          }).toList();
          final discountBox = Hive.box<CustomerDiscountModel>('discounts');
          await discountBox.clear();
          for (var discount in discountList) {
            await discountBox.add(discount);
          }
        } else {
          log('Unexpected response format: ${response.data}');
        }
      } else {
        errorSnackbar(response.statusMessage ?? '');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "discount", error: error);
      log('Error occurred while fetching discounts: $error');
    }
  }

  /// ************************ LEADS SECTION ***************** ///
  Future<Response> addCustomer(
    Map<String, dynamic> sendData,
    File leadsImage,
  ) async {
    try {
      final customerPicture = await MultipartFile.fromFile(
        leadsImage.path,
        filename: leadsImage.path.split('/').last,
      );
      sendData['cutomerpicture'] = customerPicture;

      final formData = FormData.fromMap(sendData);

      log("data: $sendData");

      final response = await dio
          .postbycustom(ApiConstants.addCustomer, data: formData)
          .onError((DioException error, stackTrace) {
        log(error.toString());
        return Future.error(throw DioExceptionHandler.fromDioError(error));
      });
      return response;
    } on DioException catch (error) {
      log("DioException: ${error.message}");
      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (error) {
      log("Unexpected error: $error");
      return Future.error(error);
    }
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

  Future<LeadResponce> getLeadsData(int currentPage) async {
    final requestData = {
      "page": currentPage,
      "limit": 10,
      "salesman_id": salesmanId,
      "companyId": companyId,
    };
    final cacheKey = 'leads_data_${salesmanId}_$currentPage';
    final leadsBox = await Hive.openBox('leadsBox');
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      try {
        final response = await responsePostMethod(
            requestData: requestData, endPoint: ApiConstants.fetchLeads);
        if (response.statusCode == 200) {
          await leadsBox.put(cacheKey, response.data);
          return LeadResponce.fromJson(response.data);
        } else {
          handleExceptionMessage(response: response, apiName: "leads");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "leads", error: error);
        return localStorage.storedLeadsData(leadsBox, cacheKey);
      }
    } else {
      log('No internet. Fetching from Hive...');
    }
    try {
      return localStorage.storedLeadsData(leadsBox, cacheKey);
    } catch (e) {
      log('Error fetching from Hive: $e');
      throw Exception('Failed to fetch data from API and Hive.');
    }
  }

  Future<LeadResponce> getLeadsRejectedData(int currentPage) async {
    final cacheKey = 'leads_rejected_$currentPage';
    final leadsBox = await Hive.openBox('leadsRejectBox');
    bool isOnline = await ConnectivityService().isOnline();
    final requestData = {
      "page": currentPage,
      "limit": 10,
      "salesman_id": salesmanId,
      "companyId": companyId,
    };
    if (isOnline) {
      try {
        final response = await responsePostMethod(
            requestData: requestData,
            endPoint: ApiConstants.fetchRejectedLeads);
        if (response.statusCode == 200) {
          await leadsBox.put(cacheKey, response.data);
          return LeadResponce.fromJson(response.data);
        } else {
          handleExceptionMessage(response: response, apiName: "rejected leads");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "rejected leads", error: error);
        return localStorage.storedLeadsData(leadsBox, cacheKey);
      }
    } else {}
    try {
      return localStorage.storedLeadsData(leadsBox, cacheKey);
    } catch (e) {
      errorSnackbar("Error fetching datas from hive");
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
    bool isOnline = await ConnectivityService().isOnline();
    if (isOnline) {
      try {
        final response = await dio1
            .post(
          '${ApiConstants.baseUrl}${ApiConstants.getEvent}',
          data: FormData.fromMap(sendData),
        )
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw DioException(
            requestOptions: RequestOptions(
                path: '${ApiConstants.baseUrl}${ApiConstants.getEvent}'),
            type: DioExceptionType.connectionTimeout,
          );
        });
        final castedResponse =
            LocalStorage().castToStringDynamic(response.data);
        if (castedResponse['data'] is List) {
          List<dynamic> eventsJson = castedResponse['data'];
          await eventsBox.put(cacheKey, eventsJson);
          allEvents = eventsJson
              .map((event) => EventData.fromJson(event as Map<String, dynamic>))
              .toList();
        } else {
          log('Unexpected response format: $castedResponse');
          return [];
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          log("Fetch Leads Count Timeout: $error");
          errorSnackbar(
              'Request timed out. Please check your internet connection and try again.');
          return Future.error(
            'Request timed out. Please check your internet connection and try again.',
          );
        }
        handleExceptionMessage(
            response: error.response, apiName: "calender event", error: error);
      }
    } else {
      // NkCommonFunction.showErrorSnakBar(
      //     'No internet connection. Unable to fetch data.');
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
      handleExceptionMessage(
          response: e.response, apiName: "calender event", error: e);
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
    try {
      final requestData = {
        "customer_id": customerId,
        "status": statusResponce,
        "companyId": companyId,
      };
      log('This function has been called handleLeadStatus');
      final response = await responsePostMethod(
          requestData: requestData, endPoint: ApiConstants.handleLeads);
      if (response.statusCode == 200) {
        return response;
      } else {
        errorSnackbar('Failed to change lead status');
        throw Exception('Failed to change lead status: ${response.statusCode}');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "Handle lead", error: error);
      throw Exception('Error in handleLeadStatus: $error');
    }
  }

  /// ************************ ORDER SECTION *****************
  Future<OrderResponce> getOrdersData(
      {String? customerId,
      String? salesmanId,
      SearchModel? searchModel,
      PaginationModel? paginationModel}) async {
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
    log('RequestBody Pending : $requestData');
    final cacheKey =
        'pending_payment_${chartIndex}_${salesmanId ?? ''}_${paginationModel?.currentPage ?? ''}';
    final pendingPaymentBox = Hive.box('pendingPaymentBox');
    try {
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        return localStorage.storedPendingPaymentData(
            pendingPaymentBox, cacheKey);
      }
      final response = await responsePostMethod(
          requestData: requestData,
          endPoint: ApiConstants.fetchPendingPayments);
      log("API Response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        await pendingPaymentBox.put(cacheKey, response.data);
        return PendingPaymentResponse.fromJson(response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "pending payments");
        return localStorage.storedPendingPaymentData(
            pendingPaymentBox, cacheKey);
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "pending payments", error: error);
      return localStorage.storedPendingPaymentData(pendingPaymentBox, cacheKey);
    } catch (e) {
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        return localStorage.storedPendingPaymentData(
            pendingPaymentBox, cacheKey);
      } else {
        throw Exception('Unexpected error occurred: $e');
      }
    }
  }

  Future<IndividualPendingPaymentResponse> getAllPendingPaymentIndividual(
      {String? customerId}) async {
    try {
      final requestData = {
        "customer_id": customerId,
        "companyId": 1,
      };
      final response = await responsePostMethod(
          requestData: requestData,
          endPoint: ApiConstants.getAllPendingPaymentIndividuals);
      if (response.statusCode == 200) {
        return IndividualPendingPaymentResponse.fromJson(response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "pending payments");
        return Future.error('API Error: ${response.statusCode}');
      }
    } on DioException catch (error) {
      final handledError = DioExceptionHandler.fromDioError(error);
      handleExceptionMessage(
          response: error.response, apiName: "pending payments", error: error);
      return Future.error(handledError);
    }
  }

  //************************ RECENT ORDERS **************/
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
    final isConnected = await ConnectivityService().isOnline();
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
        final response = await responsePostMethod(
            requestData: requestData, endPoint: ApiConstants.getRecentOrder);
        await ordersBox.put(cacheKey, response.data);
        return OrderResponce.fromJson(response.data);
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "recent orders", error: error);
        if (ordersBox.containsKey(cacheKey)) {
          return localStorage.storedRecentOrdersData(ordersBox, cacheKey);
        } else {
          errorSnackbar("No cached data available after API failure.");
          throw Exception('Failed to fetch data and no cached data available.');
        }
      }
    }
    if (ordersBox.containsKey(cacheKey)) {
      return localStorage.storedRecentOrdersData(ordersBox, cacheKey);
    } else {
      log('No cached data available offline for key: $cacheKey');
      throw Exception("No internet connection and no cached data available.");
    }
  }

  Future<OrderProcessInvoice> getOrderProcessInvoiceData({
    String? orderId,
    int? orderStatus,
  }) async {
    try {
      final requestBody = {
        "order_id": orderId,
        "order_status": orderStatus,
        "companyId": companyId,
      };
      final response = await responsePostMethod(
          requestData: requestBody, endPoint: ApiConstants.orderProcessInvoice);
      if (response.statusCode == 200) {
        return OrderProcessInvoice.fromJson(response.data);
      } else {
        handleExceptionMessage(
            response: response, apiName: "order processing invoice");
        throw Exception('Failed to fetch order process invoice data.');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response,
          apiName: "order processing invoice",
          error: error);
      throw DioExceptionHandler.fromDioError(error);
    } catch (e) {
      log('An unexpected error occurred: $e');
      throw Exception(
          'An unexpected error occurred while fetching order process invoice data.');
    }
  }

  Future<OrderProcessInvoice> loadWaitingForApproval({
    String? orderId,
  }) async {
    log("this function has been called");
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

  Future<String?> getWeeklyType() async {
    const cacheKey = 'weekly_type';
    final weeklyTypeBox = Hive.box('weeklyTypeBox');
    try {
      bool isOnline = await _connectivityService.isOnline();
      final requestBody = {"companyId": companyId};
      if (isOnline) {
        final response = await responsePostMethod(
          requestData: requestBody,
          endPoint: ApiConstants.getWeekelyType,
        );
        if (response.statusCode == 200 &&
            response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          final weeklyType = response.data['data'].toString();
          await weeklyTypeBox.put(cacheKey, weeklyType);
          return weeklyType;
        } else {
          handleExceptionMessage(response: response, apiName: "weekly type");
          throw Exception("Unexpected API response for Weekly Type");
        }
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "weekly type", error: error);
    } catch (e) {
      log("Unexpected error while fetching Weekly Type: $e");
    }
    final cachedWeeklyType =
        localStorage.storedWeekelyTypeData(weeklyTypeBox, cacheKey);
    return cachedWeeklyType;
  }

  Future<SalesmanValueTargetResponse?> fetchSalesmanValueTarget(
      String salesmanId, String year, String? month,
      {int? compid, bool? isFromLogin}) async {
    final requestPayload = {
      "salesman_id": salesmanId,
      "year": year,
      if (month != null) "month": month,
      "companyId": isFromLogin ?? false ? compid : companyId,
    };
    final cacheKey =
        'salesman_value_target_${salesmanId}_${year}_${month ?? 'all'}';
    final targetBox = Hive.box('salesmanValueTargetBox');
    try {
      bool isOnline = await _connectivityService.isOnline();
      if (isOnline) {
        final response = await dio.postbycustom(
          ApiConstants.fetchSalesmanValueTarget,
          data: requestPayload,
        );
        if (response.statusCode == 200 &&
            response.data is Map<String, dynamic>) {
          final jsonData = response.data;
          log("Salesman Value Target fetched from API: $jsonData");
          if (jsonData != null && jsonData is Map<String, dynamic>) {
            await targetBox.put(cacheKey, jsonData);
            log("Salesman Value Target data saved to Hive with key: $cacheKey");
            return SalesmanValueTargetResponse.fromJson(jsonData);
          } else {
            log("Invalid data format received from API. Data not cached.");
          }
        } else {
          log("Failed to fetch Salesman Value Target data: ${response.statusCode}, ${response.statusMessage}");
        }
      }
    } catch (e) {
      log("Error while fetching Salesman Value Target from API: $e");
    }

    // Fallback to Hive

    return null;
  }

  Future<void> placeOrder(
    CartOrderModel cartOrder,
    Function(int statusCode, String message, Map<String, dynamic>? responseData)
        onResponse,
  ) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    cartOrder.companyId = companyId;
    try {
      log('Assigned companyId: ${cartOrder.companyId}');
      log('Place Order Payload: ${cartOrder.toJson()}');
      final response = await responsePostMethod(
          requestData: cartOrder.toJson(), endPoint: "place_order");
      log('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        log('Order placed successfully: ${response.data}');
        onResponse(
            200, 'Your order has been successfully placed.', response.data);
      } else {
        log('Failed to place order: ${response.data}');
        handleExceptionMessage(response: response, apiName: "place order");
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "place order", error: error);
      log('Error placing order: $error');
      onResponse(500, 'An error occurred while placing the order.', null);
    }
  }

  Future<SalesmanTargetTableResponse?> fetchSalesmanTarget(
      String salesmanId, String month, String year,
      {int? compId, bool? isFromLogin}) async {
    final requestPayload = {
      "salesman_id": salesmanId,
      "year": year,
      "month": month,
      "companyId": isFromLogin ?? false ? compId : companyId,
    };
    final cacheKey = 'salesman_target_${salesmanId}_${year}_$month';
    final targetBox = Hive.box('salesmanTargetBox');
    log("fetchSalesmanTarget request345: $requestPayload");
    try {
      bool isOnline = await _connectivityService.isOnline();
      log('Is Online fetch sales target: $isOnline');
      if (isOnline) {
        try {
          final response = await dio.postbycustom(
            ApiConstants.fetchSalesmanTarget,
            data: requestPayload,
          );

          if (response.statusCode == 200) {
            final dynamic jsonData = response.data;
            log("Fetched Salesman Target Data: $jsonData");
            if (jsonData != null) {
              await targetBox.put(cacheKey, jsonData);
              return SalesmanTargetTableResponse.fromJson(jsonData);
            }
          } else {
            handleExceptionMessage(
                response: response, apiName: "salesman target");
            log("API Error: ${response.statusCode} ${response.statusMessage}");
          }
        } catch (apiError) {
          log("API fetch error: $apiError");
        }
      } else {
        log("Falling back to cached data.");
        if (targetBox.containsKey(cacheKey)) {
          final cachedData = targetBox.get(cacheKey);
          log("Using cached data for key: $cacheKey");
          if (cachedData != null) {
            return SalesmanTargetTableResponse.fromJson(cachedData);
          } else {
            log("Cached data is null for key: $cacheKey");
          }
        } else {
          log("No cached data available for key: $cacheKey");
        }
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          response: e.response, apiName: "salesman target", error: e);
      log("Unexpected error during fetch: $e");
      try {
        if (targetBox.containsKey(cacheKey)) {
          final cachedData = targetBox.get(cacheKey);
          log("Using cached data for key (fallback): $cacheKey");

          if (cachedData != null) {
            return SalesmanTargetTableResponse.fromJson(cachedData);
          } else {
            log("Fallback cached data is null for key: $cacheKey");
          }
        } else {
          log("Fallback: No cached data available for key: $cacheKey");
        }
      } catch (cacheError) {
        log("Error accessing fallback cached data: $cacheError");
      }
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
      handleExceptionMessage(
          response: error.response, apiName: "time sheet", error: error);
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
    final requestPayload = {
      "categories": categoryData,
      "weekly_target": weeklyTarget,
      "weekly_projection": weeklyProjection,
      "sales_id": salesmanId,
      "year": int.parse(year),
      "month": month,
      "companyId": companyId,
    };

    log('Sending API request to updateCategoryTargetValue...');
    log('API Payload: ${jsonEncode(requestPayload)}');

    final response = await dio1
        .post(
      // ApiConstants.updateCategoryTargetValue,
      'http://16.50.232.153:3000/Update_CategorytargetValue',
      data: requestPayload,
    )
        .onError((DioException error, stackTrace) {
      log("Dio Error: ${error.toString()}");
      return Future.error(DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<LeadResponce> getLeadsCustomerData(int currentPage) async {
    final cacheKey = 'leads_customer_${salesmanId}_$currentPage';
    final leadsBox = await Hive.openBox('leadsCustomerBox');
    bool isOnline = await ConnectivityService().isOnline();
    log('Has Internet: $isOnline');
    final requestData = {
      "page": currentPage,
      "limit": 10,
      "salesman_id": salesmanId,
      "companyId": companyId,
    };
    if (isOnline) {
      try {
        final response = await responsePostMethod(
            requestData: requestData,
            endPoint: ApiConstants.fetchLeadsCustomer);
        if (response.statusCode == 200) {
          log('Response Body Fetch Leads Customer: ${response.data}');
          await leadsBox.put(cacheKey, response.data);
          log('Data saved to Hive for key: $cacheKey');
          return LeadResponce.fromJson(response.data);
        } else {
          handleExceptionMessage(response: response, apiName: "leads customer");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "leads customer", error: error);
        log('Error fetching data from API: ${error.response?.statusCode ?? 0}');
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

  Future<List<Plan>> fetchPlans() async {
    const String url = 'https://test.thrivewoo.com/get_plan_detiails';
    try {
      Response response = await dio1.get(url);
      if (response.statusCode == 200 && response.data['status'] == true) {
        List<dynamic> data = response.data['data'];
        List<Plan> plans = data.map((item) => Plan.fromJson(item)).toList();
        return plans;
      } else {
        handleExceptionMessage(apiName: "register plans", response: response);
        throw Exception('Failed to fetch plans: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleExceptionMessage(
            apiName: "register plans", error: e, response: e.response);
        throw Exception(
            'Dio Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Dio Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error fetching plans: $e');
    }
  }

  Future<String> sendVerificationMail(String email) async {
    final requestData = {
      "email": email,
    };
    try {
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: ApiConstants.sendVerificationMail,
      );
      if (response.data['status'] == true) {
        log('Verification mail sent successfully.');
      } else {
        log('Error: ${response.data['message'] ?? 'Unknown error occurred.'}');
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          apiName: "Send verification Email", error: e, response: e.response);
    } catch (e) {
      print('Unexpected error: $e');
    }
    return "";
  }

  Future<void> insertAdmin({
    required String name,
    required String email,
    required String password,
    required String town,
    required String state,
    required String zipcode,
    required String address,
    required String country,
    required String fullPhoneNo,
  }) async {
    final Map<String, String> requestData = {
      "name": name,
      "email": email,
      "password": password,
      "town": town,
      "state": state,
      "zipcode": zipcode,
      "address": address,
      "country": country,
      "fullphoneno": fullPhoneNo,
    };

    try {
      final response = await responsePostMethod(
          requestData: requestData, endPoint: ApiConstants.insertadmin);
      if (response.statusCode == 200) {
        log("Admin inserted successfully: ${response.data}");
      } else {
        handleExceptionMessage(apiName: "insert admin", response: response);
        print(
            "Failed to insert admin: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          apiName: "insert admin", response: e.response, error: e);
      log("Error occurred while making POST request: $e");
    }
  }

  /// *******************************  SUBSCRIPTION  *******************************/

  Future<SubscribedPlan?> fetchSubscribtionPlan(int companyId) async {
    final cacheKey = 'subscribed_plan_data_$companyId';
    final subscribtionBox = Hive.box('subscribtionBox');
    log('Fetching subscription plan for company ID: $companyId');

    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        final response = await dio1.post(
          "${ApiConstants.baseUrl}${ApiConstants.get_subscribed_plan}",
          data: {"company_id": "$companyId"},
        );
        log("Fetch Subscription URL: ${ApiConstants.baseUrl}${ApiConstants.get_subscribed_plan}");
        final subscribedPlan = SubscribedPlan.fromJson(response.data);
        log('Subscription plan fetched: ${subscribedPlan.toJson()}');
        await subscribtionBox.put(cacheKey, subscribedPlan.toJson());
        log('Subscription plan saved to Hive.');
        return subscribedPlan;
      } on DioException catch (dioError) {
        log("Dio error while fetching subscription plan: ${dioError.response?.data}");
        handleExceptionMessage(
          apiName: 'Fetch Subscription Plan',
          response: dioError.response,
        );
        final cachedData = subscribtionBox.get(cacheKey);
        if (cachedData != null) {
          log('Loaded subscription plan from cache: $cachedData');
          return SubscribedPlan.fromJson(Map<String, dynamic>.from(cachedData));
        } else {
          log("No cached subscription data available.");
          NkCommonFunction.showErrorSnakBar(
              'No offline subscription data available.');
        }
      } catch (e) {
        log("Unexpected error: $e");
        NkCommonFunction.showErrorSnakBar('An unexpected error occurred.');
      }
    } else {
      log("No internet connection. Trying to load subscription plan from Hive.");
    }

    // Offline or fallback logic
    try {
      final cachedData = subscribtionBox.get(cacheKey);
      if (cachedData != null) {
        log('Loaded subscription plan from cache: $cachedData');
        return SubscribedPlan.fromJson(Map<String, dynamic>.from(cachedData));
      } else {
        log("No cached subscription data available.");
        NkCommonFunction.showErrorSnakBar(
            'No offline subscription data available.');
      }
    } catch (e) {
      log('Error reading from Hive: $e');
      NkCommonFunction.showErrorSnakBar(
          'Error accessing offline subscription data.');
    }

    return null;
  }

  Future<SubscribtionPlanDetails?> fetchPlanDetails() async {
    const cacheKey = 'subscription_plan_details';
    final subscribtionBox = Hive.box('subscribtionPlanDetailsBox');
    log('Fetching subscription plan for company ID: ${SessionHelper.loginSavedData?.company_id ?? 0}');
    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        final response = await dio1.get(
          "${ApiConstants.baseUrl}${ApiConstants.get_plan_detiails}",
          // queryParameters: {"company_id": companyId}, // <- Correct way for GET
        );

        log("Fetch Subscription Plan Details URL: ${ApiConstants.baseUrl}${ApiConstants.get_plan_detiails}");

        final subscribedPlan = SubscribtionPlanDetails.fromJson(response.data);
        log('Subscription Plan Details fetched: ${subscribedPlan.toJson()}');

        // Save to Hive
        await subscribtionBox.put(cacheKey, subscribedPlan.toJson());
        log('Subscription Plan Details saved to Hive.');

        return subscribedPlan;
      } on DioException catch (dioError) {
        log("Dio error while fetching subscription plan details: ${dioError.response?.data}");

        handleExceptionMessage(
          apiName: 'Fetch Subscription Plan Details',
          response: dioError.response,
        );

        // Try loading from cache
        final cachedData = subscribtionBox.get(cacheKey);
        if (cachedData != null) {
          log('Loaded subscription plan details from cache: $cachedData');
          return SubscribtionPlanDetails.fromJson(
              Map<String, dynamic>.from(cachedData));
        } else {
          log("No cached subscription plan details data available.");
          NkCommonFunction.showErrorSnakBar(
              'No offline subscription plan details data available.');
        }
      } catch (e) {
        log("Unexpected error: $e");
        NkCommonFunction.showErrorSnakBar('An unexpected error occurred.');
      }
    } else {
      log("No internet connection. Trying to load subscription plan details from Hive.");
    }

    // Offline or fallback logic
    try {
      final cachedData = subscribtionBox.get(cacheKey);
      if (cachedData != null) {
        log('Loaded subscription plan details from cache: $cachedData');
        return SubscribtionPlanDetails.fromJson(
            Map<String, dynamic>.from(cachedData));
      } else {
        log("No cached subscription plan details data available.");
        NkCommonFunction.showErrorSnakBar(
            'No offline subscription plan details data available.');
      }
    } catch (e) {
      log('Error reading from Hive: $e');
      NkCommonFunction.showErrorSnakBar(
          'Error accessing offline subscription plan details data.');
    }

    return null;
  }

  Future<Response> sendInvoice(String orderId) async {
    try {
      Map<String, dynamic> data = {
        "order_id": orderId,
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0
      };

      final response = await dio.postbycustom(
        ApiConstants.sendInvoice,
        data: data,
      );

      return response;
    } catch (error) {
      log("Error occurred while sending invoice: $error");
      handleExceptionMessage(
        apiName: 'Send Invoice',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to send invoice: $error');
    }
  }
}
