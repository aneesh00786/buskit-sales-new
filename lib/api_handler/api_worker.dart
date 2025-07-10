import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
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
import 'package:intl/intl.dart';
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
  // final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
  // final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
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
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final requestData = {
      "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "current_password": currentPassword,
      "newpwd": newPassword,
      "cnewpwd": confirmPassword,
    };
    log('Request Data Change Password$requestData');
    try {
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: 'ChangePasswordStaff',
      );

      if (response.statusCode == 200) {
        log("Password changed successfully: ${response.data}");
      } else {
        log("Failed to change password: ${response.statusCode}");
      }
    } catch (e) {
      log("Error changing password: $e");
    }
  }

  Future<bool> submitCardForm({
    required String cardName,
    required String cardToken,
    required int adminId,
    required int checkedPlanId,
    required String licenses,
    required String currencyCode,
    required double amount,
  }) async {
    log('ADMIN ID : $adminId');
    try {
      final setupIntentRes = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.createSetUpIntent}',
        data: {'adminId': adminId},
      );
      if (setupIntentRes.statusCode != 200 ||
          setupIntentRes.data['stripeCustomerId'] == null) {
        log('❌ Failed to create setup intent: ${setupIntentRes.data}');
        return false;
      }
      final stripeCustomerId = setupIntentRes.data['stripeCustomerId'];
      final paymentMethodId = cardToken;
      final endDate = DateTime.now().add(Duration(days: 14));
      final endDateFormatted = DateFormat('yyyy-MM-dd').format(endDate);
      final saveResponse = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.insertTransactionAndSubscriptionDetails}',
        data: {
          'user_id': adminId,
          'plan_id': checkedPlanId,
          'card_token': paymentMethodId,
          'end_date': endDateFormatted,
          'amount': amount,
          'payment_method': 'card',
          'status': 'trial',
          'licenses': licenses,
          'stripeCustomerId': stripeCustomerId,
          'currency': currencyCode,
        },
      );
      final saveData = saveResponse.data;
      final bool isSuccess =
          saveResponse.statusCode == 200 && saveData['status_code'] == 200;
      if (isSuccess) {
        log("✅ 14-day trial started. Login credentials have been sent to your email.");
        return true;
      } else {
        log("❌ Failed to save subscription: ${saveData['message']}");
        return false;
      }
    } catch (e) {
      log("❌ Error in submitCardForm: $e");
      return false;
    }
  }

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

  Future<LoginResponse?> loginApi(String email, String password) async {
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
          return LoginResponse(
            status: false,
            message: message,
            statusCode: statusCode,
          );
        }
        return LoginResponse.fromJson(response.data);
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
      return LoginResponse(
        status: false,
        message: message,
        statusCode: statusCode,
      );
    } catch (e) {
      log("Login Error: $e");
      return LoginResponse(
        status: false,
        message: 'An unexpected error occurred.',
        statusCode: null,
      );
    }
  }

  Future<LeadsCountData> fetchLeadsCount() async {
    final Map<String, dynamic> requestData = {
      'companyId': SessionHelper.loginSavedData?.company_id ?? 0,
      'salesman_id': SessionHelper.loginSavedData?.salesmanId ?? '',
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
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    final year = DateTime.now().year;
    final cacheKey =
        'topBarData_${companyId}_${salesmanId}_${year}_${monthName}_$tabStatus';
    final box = Hive.box('topBarDataBox');

    // Check cache first
    final cachedData = box.get(cacheKey);
    if (cachedData != null) {
      try {
        return Map<String, dynamic>.from(cachedData);
      } catch (e) {
        log('Cache parse error for $cacheKey: $e');
      }
    }

    try {
      final requestPayload = {
        "companyId": companyId,
        "salesman_id": salesmanId,
        "year": year,
        "month": monthName,
        "status_of_tile": tabStatus,
      };
      Response response = await responsePostMethod(
          requestData: requestPayload,
          endPoint: ApiConstants.salesmanDashNavContent);
      if (response.statusCode == 200) {
        // Cache the response
        await box.put(cacheKey, response.data);
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
      "companyId":
          isfromLogin ? compId : SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": isfromLogin
          ? salesId
          : SessionHelper.loginSavedData?.salesmanId ?? '',
      "year": year,
      "month": monthName,
      "targetType": targetType,
    };
    final cacheKey =
        'performance_data_${SessionHelper.loginSavedData?.salesmanId ?? ''}_${year}_$monthName';
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
          response: error.response, apiName: "performance", error: error);
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
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
        log('Response Data ${response.data}');
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

  /// ************************ CUSTOMER AND ORDER SECTION ***************** ///
  Future<CustomerAndOrderResponce> getCustomer() async {
    try {
      log('This function has been calledsss');
      bool isOnline = await ConnectivityService().isOnline();
      final requestBody = {
        "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
        "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
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
      'companyId': SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
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
    sendData['companyId'] = SessionHelper.loginSavedData?.company_id ?? 0;
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
      handleExceptionMessage(
          response: error.response, apiName: "add to cart", error: error);
      log('[addToCart] Exception: $error');
      return Future.error(DioExceptionHandler.fromDioError(error));
    }
  }

  Future<CartOrderModel?> addToDraft(Map<String, dynamic> sendData) async {
    sendData['companyId'] = SessionHelper.loginSavedData?.company_id ?? 0;
    log('[addToDraft] Request Data: ${sendData.toString()}');
    try {
      final response = await dio1
          .post(
        "${ApiConstants.baseUrl}${ApiConstants.addToDraft}",
        data: FormData.fromMap(sendData),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
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
      handleExceptionMessage(
          response: error.response, apiName: "add to draft", error: error);
      log('[addToCart] Exception: $error');
      return Future.error(DioExceptionHandler.fromDioError(error));
    }
  }

  Future<Response> deleteCustomer(String id) async {
    final response = await dio.postbycustom(ApiConstants.deletCustomer, data: {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "id": id,
    }).onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  /// ************************ CATEGORY SECTION ***************** ///

  Future<CategoryModel> getCategory({required int companyid}) async {
    try {
      final isConnected = await ConnectivityService().isOnline();
      final cacheKey =
          "${SessionHelper.loginSavedData?.company_id ?? 0}_categoryData";

      final box = await Hive.openBox('categoriesBox');

      if (!isConnected) {
        final savedCategory = box.get(cacheKey) as Map?;
        if (savedCategory != null) {
          return CategoryModel.fromJson(
            ApiService().castToStringDynamic(savedCategory),
          );
        } else {
          throw Exception('No data available offline');
        }
      } else {
        final response = await dio.getbycustom(
          ApiConstants.fetchCategories,
          queryParameters: {
            "company_id": companyid,
          },
        );

        final category = CategoryModel.fromJson(response.data);
        await box.put(cacheKey, category.toJson());

        return category;
      }
    } catch (error) {
      log('Error occurred while fetching category: $error');
      handleExceptionMessage(
        apiName: 'Fetch Category',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch category data: $error');
    }
  }

  Future<List<ProductModel>> getTempProduct(String subCatId,
      {required int companyid}) async {
    log('=== getTempProduct START ===');
    log('Request Parameters: subCatId=$subCatId, companyId=$companyid');

    final isConnected = await ConnectivityService().isOnline();
    log('Internet Connection: $isConnected');

    if (isConnected) {
      try {
        final queryParams = {
          "company_id": companyid,
          "sub_catid": subCatId,
        };
        log('API Request Parameters: $queryParams');

        final response = await dio.getbycustom(ApiConstants.fetchProduct,
            queryParameters: queryParams);

        log('API Response Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = response.data;
          log('API Response Data: $responseData');

          // Parse the new response structure
          final productApiResponse = ProductApiResponse.fromJson(responseData);
          log('Parsed ProductApiResponse - Total scid groups: ${productApiResponse.data.length}');

          List<ProductModel> productsForSubCategory = [];
          ScidProductGroup? targetScidGroup;

          // Find products for the specific subcategory
          for (var scidGroup in productApiResponse.data) {
            log('Checking scid group: ${scidGroup.scid} (contains ${scidGroup.products.length} products)');
            if (scidGroup.scid == subCatId) {
              productsForSubCategory.addAll(scidGroup.products);
              targetScidGroup = scidGroup;
              log('Found matching scid group: ${scidGroup.scid}');
              break; // Found the specific subcategory, no need to continue
            }
          }

          log('Fetched Products for subcategory $subCatId: ${productsForSubCategory.length}');
          log('Cache Key (scid): $subCatId');

          // Cache only the specific subcategory data, not all data
          if (targetScidGroup != null) {
            await _cacheSingleScidGroup(targetScidGroup);
            log('Products cached successfully for scid: $subCatId');
          } else {
            log('No matching scid group found for subcategory: $subCatId');
          }

          log('=== getTempProduct END (Online) ===');
          return productsForSubCategory;
        } else {
          log("Failed to load products, status code: ${response.statusCode}");
          log('=== getTempProduct END (API Error) ===');
          return [];
        }
      } catch (e) {
        log("Error fetching products: $e");
        handleExceptionMessage(
          apiName: 'Get Temp Product',
          response: e is DioException ? e.response : null,
        );
        log('=== getTempProduct END (Exception) ===');
        return [];
      }
    } else {
      // Load from cached data when offline
      log('Loading from cache for subcategory: $subCatId');
      final cachedProducts = await _loadCachedProductsBySubCategory(subCatId);
      log('Loaded ${cachedProducts.length} products from cache for subcategory: $subCatId');
      log('=== getTempProduct END (Offline) ===');
      return cachedProducts;
    }
  }

  // Helper method to load cached products for a specific subcategory
  Future<List<ProductModel>> _loadCachedProductsBySubCategory(
      String subCatId) async {
    log('=== _loadCachedProductsBySubCategory START ===');
    log('Loading cached products for subcategory: $subCatId');

    try {
      // Try to load from scid-based cache first
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
        log('Using existing scidProductGroups box for subcategory loading');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
        log('Created new scidProductGroups box for subcategory loading');
      }

      // Check if the box has any data
      if (scidGroupBox.isEmpty) {
        log('Scid-based cache is empty');
      } else {
        log('Scid-based cache has ${scidGroupBox.length} entries');
        log('Available scid keys: ${scidGroupBox.keys.toList()}');
      }

      log('Looking for scid group with key: $subCatId');
      final scidGroup = scidGroupBox.get(subCatId);
      if (scidGroup != null) {
        log("Found scid group: ${scidGroup.scid} with ${scidGroup.products.length} products");
        log('=== _loadCachedProductsBySubCategory END (Scid-based) ===');
        return scidGroup.products;
      }

      // Fallback to old cache structure - filter by scid
      log('Scid group not found, trying legacy cache with filter...');
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        log('Legacy cache has ${productBox.length} products');

        // Show all available scids in legacy cache for debugging
        final allScids = productBox.values.map((p) => p.scid).toSet().toList();
        log('All scids available in legacy cache: $allScids');

        List<ProductModel> offlineProducts = productBox.values
            .where((product) => product.scid == subCatId)
            .toList();
        log("Loaded ${offlineProducts.length} products for subcategory $subCatId from legacy cache");

        if (offlineProducts.isNotEmpty) {
          log('Product scids found in legacy cache: ${offlineProducts.map((p) => p.scid).toSet().toList()}');
        }

        log('=== _loadCachedProductsBySubCategory END (Legacy) ===');
        return offlineProducts;
      } else {
        log("No products available offline for subcategory $subCatId");
        log('=== _loadCachedProductsBySubCategory END (Empty) ===');
        return [];
      }
    } catch (e) {
      log('Error loading cached products for subcategory $subCatId: $e');
      log('=== _loadCachedProductsBySubCategory END (Error) ===');
      return [];
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    log('=== getAllProducts START ===');
    final companyId = SessionHelper.loginSavedData?.company_id;
    log('Request Parameters: companyId=$companyId');

    final isConnected = await ConnectivityService().isOnline();
    log('Internet Connection: $isConnected');

    if (isConnected) {
      try {
        final queryParams = {"company_id": companyId};
        log('API Request Parameters: $queryParams');

        final response = await dio.getbycustom(ApiConstants.fetchProduct,
            queryParameters: queryParams);

        log('API Response Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = response.data;
          log('[getAllProducts] API Response Data: $responseData');

          // Parse the new response structure
          final productApiResponse = ProductApiResponse.fromJson(responseData);
          log('Parsed ProductApiResponse - Total scid groups: ${productApiResponse.data.length}');

          List<ProductModel> allProducts = [];

          // Extract all products from all scid groups
          for (var scidGroup in productApiResponse.data) {
            log('Processing scid group: ${scidGroup.scid} (contains ${scidGroup.products.length} products)');
            allProducts.addAll(scidGroup.products);
          }

          log('Total Products Fetched: ${allProducts.length}');
          log('Cache Keys (scids): ${productApiResponse.data.map((group) => group.scid).toList()}');

          // Store products by scid for caching
          await _cacheProductsByScid(productApiResponse.data);
          log('All products cached successfully for ${productApiResponse.data.length} scid groups');
          log('Cached scid groups: ${productApiResponse.data.map((group) => '${group.scid}(${group.products.length} products)').toList()}');

          // Verify cache was successful
          await _verifyProductCache();

          log('=== getAllProducts END (Online) ===');
          return allProducts;
        } else {
          log("Failed to load products, status code: ${response.statusCode}");
          log('=== getAllProducts END (API Error) ===');
          return [];
        }
      } catch (e) {
        log("Error fetching products: $e");
        handleExceptionMessage(
          apiName: 'Get All Product',
          response: e is DioException ? e.response : null,
        );
        log('=== getAllProducts END (Exception) ===');
        return [];
      }
    } else {
      // Load from cached data when offline
      log('Loading all products from cache');
      final cachedProducts = await _loadCachedProducts();
      log('Loaded ${cachedProducts.length} products from cache');
      log('=== getAllProducts END (Offline) ===');
      return cachedProducts;
    }
  }

  // Method to verify product cache status
  Future<void> _verifyProductCache() async {
    log('=== _verifyProductCache START ===');
    try {
      late Box<ScidProductGroup> scidGroupBox;
      late Box<ProductModel> productBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (Hive.isBoxOpen('products')) {
        productBox = Hive.box<ProductModel>('products');
      } else {
        productBox = await Hive.openBox<ProductModel>('products');
      }

      log('Cache verification:');
      log('- ScidProductGroups box has ${scidGroupBox.length} entries');
      log('- Products box has ${productBox.length} entries');
      log('- Available scid keys: ${scidGroupBox.keys.toList()}');

      if (scidGroupBox.isNotEmpty) {
        for (var key in scidGroupBox.keys) {
          final group = scidGroupBox.get(key);
          log('- Scid group $key: ${group?.products.length ?? 0} products');
        }
      }

      log('=== _verifyProductCache END ===');
    } catch (e) {
      log('Error verifying product cache: $e');
      log('=== _verifyProductCache END (Error) ===');
    }
  }

  // Helper method to cache a single scid group
  Future<void> _cacheSingleScidGroup(ScidProductGroup scidGroup) async {
    log('=== _cacheSingleScidGroup START ===');
    log('Caching single scid group: ${scidGroup.scid} (${scidGroup.products.length} products)');

    try {
      // Open or create box for caching
      late Box<ScidProductGroup> scidGroupBox;
      late Box<ProductModel> productBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
        log('Using existing scidProductGroups box');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
        log('Created new scidProductGroups box');
      }

      if (Hive.isBoxOpen('products')) {
        productBox = Hive.box<ProductModel>('products');
        log('Using existing products box');
      } else {
        productBox = await Hive.openBox<ProductModel>('products');
        log('Created new products box');
      }

      // Store the single scid group with its scid as key
      log('Storing scid group with cache key: ${scidGroup.scid}');
      await scidGroupBox.put(scidGroup.scid, scidGroup);

      // Remove existing products with the same scid to avoid duplicates
      final existingProducts =
          productBox.values.where((p) => p.scid == scidGroup.scid).toList();
      log('Found ${existingProducts.length} existing products with scid: ${scidGroup.scid}');

      for (var product in existingProducts) {
        if (product.productId != null) {
          await productBox.delete(product.productId);
          log('Removed existing product: ${product.productId}');
        }
      }

      // Add new products for this scid (don't deduplicate here - let the API handle it)
      await productBox.addAll(scidGroup.products);
      log('Updated legacy cache with ${scidGroup.products.length} products for scid: ${scidGroup.scid}');

      log('Single scid group cache operation completed successfully');
      log('Cache Key stored: ${scidGroup.scid}');
      log('Total cached scid groups 2: ${scidGroupBox.length}');
      log('Total cached products 2: ${productBox.length}');
      log('=== _cacheSingleScidGroup END ===');
    } catch (e) {
      log('Error caching single scid group: $e');
      log('=== _cacheSingleScidGroup END (Error) ===');
    }
  }

  // Helper method to cache products by scid
  Future<void> _cacheProductsByScid(List<ScidProductGroup> scidGroups) async {
    log('=== _cacheProductsByScid START ===');
    log('Caching ${scidGroups.length} scid groups');

    try {
      // Open or create boxes for caching
      late Box<ScidProductGroup> scidGroupBox;
      late Box<ProductModel> productBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
        log('Using existing scidProductGroups box');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
        log('Created new scidProductGroups box');
      }

      if (Hive.isBoxOpen('products')) {
        productBox = Hive.box<ProductModel>('products');
        log('Using existing products box');
      } else {
        productBox = await Hive.openBox<ProductModel>('products');
        log('Created new products box');
      }

      // Store scid groups with their scid as key (don't clear existing data)
      log('Storing scid groups with cache keys...');
      for (var scidGroup in scidGroups) {
        log('Caching scid group: ${scidGroup.scid} (${scidGroup.products.length} products)');
        await scidGroupBox.put(scidGroup.scid, scidGroup);
      }

      // Update legacy cache by adding new products (don't clear existing)
      List<ProductModel> newProducts = [];
      for (var scidGroup in scidGroups) {
        newProducts.addAll(scidGroup.products);
      }

      // Remove existing products with the same scids to avoid duplicates
      for (var scidGroup in scidGroups) {
        final existingProducts =
            productBox.values.where((p) => p.scid == scidGroup.scid).toList();
        for (var product in existingProducts) {
          if (product.productId != null) {
            await productBox.delete(product.productId);
            log('Removed existing product: ${product.productId}');
          }
        }
      }

      // Add new products without deduplication (let the API handle it)
      await productBox.addAll(newProducts);
      log('Updated legacy cache with ${newProducts.length} new products');

      log('Cache operation completed successfully');
      log('Cache Keys stored: ${scidGroups.map((group) => group.scid).toList()}');
      log('Total cached scid groups: ${scidGroupBox.length}');
      log('Total cached products: ${productBox.length}');
      log('=== _cacheProductsByScid END ===');
    } catch (e) {
      log('Error caching products by scid: $e');
      log('=== _cacheProductsByScid END (Error) ===');
    }
  }

  // Helper method to load cached products
  Future<List<ProductModel>> _loadCachedProducts() async {
    log('=== _loadCachedProducts START ===');
    try {
      // Try to load from scid-based cache first
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
        log('Using existing scidProductGroups box for loading');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
        log('Created new scidProductGroups box for loading');
      }

      if (scidGroupBox.isNotEmpty) {
        List<ProductModel> allProducts = [];
        log('Loading from scid-based cache...');
        for (var scidGroup in scidGroupBox.values) {
          log('Loading scid group: ${scidGroup.scid} (${scidGroup.products.length} products)');
          allProducts.addAll(scidGroup.products);
        }
        log("Loaded ${allProducts.length} products from scid-based cache");
        log('=== _loadCachedProducts END (Scid-based) ===');
        return allProducts;
      }

      // Fallback to old cache structure
      log('Scid-based cache is empty, trying legacy cache...');
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        List<ProductModel> offlineProducts = productBox.values.toList();
        log("Loaded ${offlineProducts.length} products from legacy local storage");
        log('=== _loadCachedProducts END (Legacy) ===');
        return offlineProducts;
      } else {
        log("No products available offline");
        log('=== _loadCachedProducts END (Empty) ===');
        return [];
      }
    } catch (e) {
      log('Error loading cached products: $e');
      log('=== _loadCachedProducts END (Error) ===');
      return [];
    }
  }

  // New method to get products by specific scid
  Future<List<ProductModel>> getProductsByScid(String scid) async {
    log('=== getProductsByScid START ===');
    log('Requesting products for scid: $scid');

    try {
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
        log('Using existing scidProductGroups box');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
        log('Created new scidProductGroups box');
      }

      final scidGroup = scidGroupBox.get(scid);
      if (scidGroup != null) {
        log("Found scid group: ${scidGroup.scid} with ${scidGroup.products.length} products");
        log('=== getProductsByScid END (Success) ===');
        return scidGroup.products;
      } else {
        log("No products found for scid: $scid");
        log('=== getProductsByScid END (Empty) ===');
        return [];
      }
    } catch (e) {
      log('Error loading products for scid $scid: $e');
      log('=== getProductsByScid END (Error) ===');
      return [];
    }
  }

  // Method to check if a subcategory has cached data
  Future<bool> hasCachedProductsForSubCategory(String subCatId) async {
    log('=== hasCachedProductsForSubCategory START ===');
    log('Checking if subcategory $subCatId has cached data');

    try {
      // Check scid-based cache first
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      final scidGroup = scidGroupBox.get(subCatId);
      if (scidGroup != null && scidGroup.products.isNotEmpty) {
        log('Found cached data for subcategory $subCatId: ${scidGroup.products.length} products');
        log('=== hasCachedProductsForSubCategory END (True - Scid-based) ===');
        return true;
      }

      // Check legacy cache
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        final hasProducts =
            productBox.values.any((product) => product.scid == subCatId);
        log('Legacy cache check for subcategory $subCatId: $hasProducts');
        log('=== hasCachedProductsForSubCategory END ($hasProducts - Legacy) ===');
        return hasProducts;
      }

      log('No cached data found for subcategory $subCatId');
      log('=== hasCachedProductsForSubCategory END (False) ===');
      return false;
    } catch (e) {
      log('Error checking cached data for subcategory $subCatId: $e');
      log('=== hasCachedProductsForSubCategory END (Error) ===');
      return false;
    }
  }

  // Method to clear all cached products
  Future<void> clearProductCache() async {
    log('=== clearProductCache START ===');
    try {
      late Box<ScidProductGroup> scidGroupBox;
      late Box<ProductModel> productBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (Hive.isBoxOpen('products')) {
        productBox = Hive.box<ProductModel>('products');
      } else {
        productBox = await Hive.openBox<ProductModel>('products');
      }

      await scidGroupBox.clear();
      await productBox.clear();
      log('Product cache cleared successfully');
      log('=== clearProductCache END ===');
    } catch (e) {
      log('Error clearing product cache: $e');
      log('=== clearProductCache END (Error) ===');
    }
  }

  // Method to clear products for a specific subcategory
  Future<void> clearProductsForSubCategory(String subCatId) async {
    log('=== clearProductsForSubCategory START ===');
    log('Clearing products for subcategory: $subCatId');

    try {
      late Box<ScidProductGroup> scidGroupBox;
      late Box<ProductModel> productBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (Hive.isBoxOpen('products')) {
        productBox = Hive.box<ProductModel>('products');
      } else {
        productBox = await Hive.openBox<ProductModel>('products');
      }

      // Remove from scid-based cache
      await scidGroupBox.delete(subCatId);

      // Remove from legacy cache
      final existingProducts =
          productBox.values.where((p) => p.scid == subCatId).toList();
      for (var product in existingProducts) {
        if (product.productId != null) {
          await productBox.delete(product.productId);
        }
      }

      log('Cleared ${existingProducts.length} products for subcategory: $subCatId');
      log('=== clearProductsForSubCategory END ===');
    } catch (e) {
      log('Error clearing products for subcategory $subCatId: $e');
      log('=== clearProductsForSubCategory END (Error) ===');
    }
  }

  // Method to get all available cached subcategory IDs
  Future<List<String>> getCachedSubcategoryIds() async {
    log('=== getCachedSubcategoryIds START ===');

    try {
      List<String> cachedScids = [];

      // Get from scid-based cache
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (scidGroupBox.isNotEmpty) {
        cachedScids = scidGroupBox.keys.cast<String>().toList();
        log('Found ${cachedScids.length} cached subcategory IDs: $cachedScids');
      } else {
        log('No scid-based cache found');
      }

      log('=== getCachedSubcategoryIds END ===');
      return cachedScids;
    } catch (e) {
      log('Error getting cached subcategory IDs: $e');
      log('=== getCachedSubcategoryIds END (Error) ===');
      return [];
    }
  }

  // Method to get comprehensive cache status
  Future<Map<String, dynamic>> getCacheStatus() async {
    log('=== getCacheStatus START ===');

    try {
      Map<String, dynamic> status = {};

      // Check scid-based cache
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      status['scidBasedCache'] = {
        'isEmpty': scidGroupBox.isEmpty,
        'entryCount': scidGroupBox.length,
        'keys': scidGroupBox.keys.cast<String>().toList(),
      };

      // Check legacy cache
      var productBox = Hive.box<ProductModel>('products');
      status['legacyCache'] = {
        'isEmpty': productBox.isEmpty,
        'entryCount': productBox.length,
        'scids': productBox.values.map((p) => p.scid).toSet().toList(),
      };

      log('Cache Status: $status');
      log('=== getCacheStatus END ===');
      return status;
    } catch (e) {
      log('Error getting cache status: $e');
      log('=== getCacheStatus END (Error) ===');
      return {};
    }
  }

  // Method to check if any cache has data
  Future<bool> hasAnyCachedData() async {
    log('=== hasAnyCachedData START ===');

    try {
      // Check scid-based cache
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (scidGroupBox.isNotEmpty) {
        log('Scid-based cache has data: ${scidGroupBox.length} entries');
        log('=== hasAnyCachedData END (True - Scid-based) ===');
        return true;
      }

      // Check legacy cache
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        log('Legacy cache has data: ${productBox.length} products');
        log('=== hasAnyCachedData END (True - Legacy) ===');
        return true;
      }

      log('No cached data found in any cache');
      log('=== hasAnyCachedData END (False) ===');
      return false;
    } catch (e) {
      log('Error checking for cached data: $e');
      log('=== hasAnyCachedData END (Error) ===');
      return false;
    }
  }

  Future<void> fetchDiscounts(int companyId, String salesmanId) async {
    try {
      Map<String, dynamic> requestPayload = {
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
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

  Future<Response> updateCustomer(
    Map<String, dynamic> sendData,
    File? leadsImage,
  ) async {
    try {
      if (leadsImage != null) {
        final customerPicture = await MultipartFile.fromFile(
          leadsImage.path,
          filename: leadsImage.path.split('/').last,
        );
        sendData['cutomerpicture'] = customerPicture;
      }

      final formData = FormData.fromMap(sendData);
      log("data: $sendData");

      final response = await dio1.patch(
        "${ApiConstants.baseUrl}${ApiConstants.updateCustomer}",
        data: formData,
      );

      return response;
    } on DioException catch (error) {
      log("DioException: ${error.message}");
      log("Error type: ${error.type}");
      log("Error response: ${error.response}");

      if (error.response != null) {
        handleExceptionMessage(
          apiName: 'Update Customer',
          response: error.response,
        );
      }
      throw DioExceptionHandler.fromDioError(error);
    } catch (error) {
      log("Unexpected error: $error");
      return Future.error(error);
    }
  }

  Future<LeadResponce> getLeadsData(int currentPage) async {
    final requestData = {
      "page": currentPage,
      "limit": 10,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };
    final cacheKey =
        'leads_data_${SessionHelper.loginSavedData?.salesmanId ?? ''}_$currentPage';
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
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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

    bool fetchedFromApi = false;

    if (isOnline) {
      try {
        final response = await dio1
            .post(
          '${ApiConstants.baseUrl}${ApiConstants.getEvent}',
          data: FormData.fromMap(sendData),
        )
            .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw DioException(
              requestOptions: RequestOptions(
                path: '${ApiConstants.baseUrl}${ApiConstants.getEvent}',
              ),
              type: DioExceptionType.connectionTimeout,
            );
          },
        );

        final castedResponse =
            LocalStorage().castToStringDynamic(response.data);

        if (castedResponse['data'] is List) {
          log('✅ Data fetched from API');
          List<dynamic> eventsJson = castedResponse['data'];
          await eventsBox.put(cacheKey, eventsJson);
          allEvents = eventsJson
              .map((event) => EventData.fromJson(event as Map<String, dynamic>))
              .toList();
          fetchedFromApi = true;
        } else {
          log('❌ Invalid response format from API: $castedResponse');
          throw Exception('API response does not contain expected event list.');
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          log("⏱ Timeout Error: $error");
          errorSnackbar(
              'Request timed out. Please check your internet connection and try again.');
          return Future.error(
              'Request timed out. Please check your internet connection and try again.');
        }

        log('❌ DioException: ${error.message}');
        handleExceptionMessage(
          response: error.response,
          apiName: "calendar event",
          error: error,
        );
      } catch (e, st) {
        log('❌ General exception during API fetch: $e\n$st');
      }
    } else {
      log('📴 No internet. Using Hive cache...');
    }
    if (!fetchedFromApi) {
      try {
        var cachedData = eventsBox.get(cacheKey);
        if (cachedData != null && cachedData is List) {
          log('📦 Loading events from Hive cache');
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
      } on DioException catch (e, st) {
        log('❌ Error reading Hive cache: $e\n$st');
        handleExceptionMessage(
            response: null, apiName: "calendar event", error: e);
      }
    }

    log('Events loaded 2: ${allEvents.length}');
    return allEvents;
  }

  Future<Response> handleLeadStatus(
      int? customerId, String? statusResponce) async {
    try {
      final requestData = {
        "customer_id": customerId,
        "status": statusResponce,
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
      "companyId": isLogin == true
          ? compId
          : SessionHelper.loginSavedData?.company_id ?? 0,
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
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
          "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
        };
        log('Request Data $requestData');
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
          log("No cached data available after API failure.");
          // errorSnackbar("No cached data available after API failure.");
          // throw Exception('Failed to fetch data and no cached data available.');
        }
      }
    }
    if (ordersBox.containsKey(cacheKey)) {
      return localStorage.storedRecentOrdersData(ordersBox, cacheKey);
    } else {
      log('No cached data available offline for key: $cacheKey');
      // throw Exception("No internet connection and no cached data available.");
      return localStorage.storedRecentOrdersData(ordersBox, cacheKey);
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
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    final cacheKey =
        'schedule_${companyId}_${salesmanId}_${startDate}_$endDate';
    final scheduleBox = Hive.box('scheduleBox');

    // Check cache first
    final cachedData = scheduleBox.get(cacheKey);
    if (cachedData != null) {
      try {
        return ScheduleListResponse.fromJson(cachedData);
      } catch (e) {
        log('Cache parse error for $cacheKey: $e');
      }
    }

    final response = await dio
        .postbycustom(ApiConstants.fetchSchedule,
            data: FormData.fromMap({
              "end_date": endDate,
              "salesman_id": salesmanId,
              "start_date": startDate,
              "company_id": companyId,
            }))
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(
        error,
      ));
    });
    // Cache the response
    await scheduleBox.put(cacheKey, response.data);
    return ScheduleListResponse.fromJson(response.data);
  }

  Future<String?> getWeeklyType() async {
    const cacheKey = 'weekly_type';
    final weeklyTypeBox = Hive.box('weeklyTypeBox');
    try {
      log("[getWeekelyType]");
      bool isOnline = await _connectivityService.isOnline();
      final requestBody = {
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0
      };
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
    String salesmanId,
    String year,
    String? month, {
    int? compid,
    bool? isFromLogin,
  }) async {
    log('\x1B[32m******************************** fetch Salesman Value Target ********************************\x1B[0m');

    final requestPayload = {
      "salesman_id": salesmanId,
      "year": year,
      if (month != null) "month": month,
      "companyId": (isFromLogin ?? false)
          ? compid
          : SessionHelper.loginSavedData?.company_id ?? 0,
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
          log('\x1B[36m[API Response]\x1B[0m $jsonData');

          if (jsonData != null && jsonData is Map<String, dynamic>) {
            await targetBox.put(cacheKey, jsonData);
            log("✅ Salesman Value Target data saved to Hive with key: $cacheKey");
            return SalesmanValueTargetResponse.fromJson(jsonData);
          } else {
            log("⚠️ Invalid data format received from API. Data not cached.");
          }
        } else {
          log("❌ Failed to fetch Salesman Value Target data: ${response.statusCode}, ${response.statusMessage}");
        }
      } else {
        log("📴 Device offline. Attempting to load cached data for key: $cacheKey");
      }
    } catch (e) {
      log("❌ Error while fetching Salesman Value Target from API: $e");
    }

    // Fallback to Hive
    try {
      final cachedData = targetBox.get(cacheKey);
      if (cachedData != null) {
        log('\x1B[33m[Cached Response]\x1B[0m $cachedData');
        return SalesmanValueTargetResponse.fromJson(
          Map<String, dynamic>.from(cachedData),
        );
      } else {
        log("⚠️ No cached Salesman Value Target data found for key: $cacheKey");
      }
    } catch (e) {
      log("❌ Error while reading Salesman Value Target from Hive: $e");
    }

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
    log('\x1B[31m******************************** fetch Salesman Target ********************************\x1B[31m');
    final requestPayload = {
      "salesman_id": salesmanId,
      "year": year,
      "month": month,
      "companyId": isFromLogin ?? false
          ? compId
          : SessionHelper.loginSavedData?.company_id ?? 0,
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
    final id = SessionHelper.loginSavedData?.id ?? '';
    final cacheKey = 'timesheet_${id}_${startDate ?? ''}_${endDate ?? ''}';
    final timesheetBox = Hive.box('timesheetBox');

    // Check cache first
    final cachedData = timesheetBox.get(cacheKey);
    if (cachedData != null) {
      try {
        return StaffTimesheetResponse.fromJson(cachedData);
      } catch (e) {
        log('Cache parse error for $cacheKey: $e');
      }
    }

    log("🔍 API Request: startDate=$startDate, endDate=$endDate, id=$id");
    try {
      final response = await dio.postbycustom(
        ApiConstants.getStaffTimeSheet,
        data: FormData.fromMap({
          "startdate": startDate,
          "enddate": endDate,
          "id": id,
        }),
      );

      log("✅ API Response: \\${response.statusMessage}, Data: \\${response.data}");
      // Cache the response
      await timesheetBox.put(cacheKey, response.data);
      return StaffTimesheetResponse.fromJson(response.data);
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "time sheet", error: error);
      log("❌ API Error: \\${error.response?.statusCode} - \\${error.message}");
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
                "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    log('Sending API request to updateCategoryTargetValue...');
    log('API Payload: ${jsonEncode(requestPayload)}');

    final response = await responsePostMethod(
            requestData: requestPayload, endPoint: 'Update_CategorytargetValue')
        .onError((DioException error, stackTrace) {
      log("Dio Error: ${error.toString()}");
      return Future.error(DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<LeadResponce> getLeadsCustomerData(int currentPage) async {
    final cacheKey =
        'leads_customer_${SessionHelper.loginSavedData?.salesmanId ?? ''}_$currentPage';
    final leadsBox = await Hive.openBox('leadsCustomerBox');
    bool isOnline = await ConnectivityService().isOnline();
    log('Has Internet: $isOnline');
    final requestData = {
      "page": currentPage,
      "limit": 10,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
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

  Future<dynamic> getRegisteredAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? adminId = prefs.getInt('admin_id');
      if (adminId == null) {
        log("Admin ID not found.");
        return null;
      }
      log("Fetching registered address for admin ID: $adminId");
      final response = await dio1.post(
        "${ApiConstants.baseUrl}${ApiConstants.getRegisteredAddressAdmin}",
        data: {'admin_id': adminId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data;
      log("dataRegist: ${data['data']}");

      if (response.statusCode == 200 && data['data'] != null) {
        return data['data'];
      } else {
        log("Error: ${data['message']}");
      }
    } catch (e) {
      log("❌ Error fetching registered address: $e");
    }

    return null;
  }

  Future<List<Plan>> fetchPlans() async {
    const String url = '${ApiConstants.baseUrl}${ApiConstants.getPlanDetiails}';
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
      log('Unexpected error: $e');
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
    required String regNo,
    required String adminFname,
    required String adminLname,
    required String privacy,
    required String refund,
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
      "reg_no": regNo,
      "admin_fname": adminFname,
      "admin_lname": adminLname,
      "privacy": privacy,
      "refund": refund,
    };
    log('Request Data $requestData');
    try {
      final response = await responsePostMethod(
          requestData: requestData, endPoint: ApiConstants.insertadmin);
      if (response.statusCode == 200) {
        final data = response.data['data'][0];
        final int adminId = data['id_admin'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('admin_id', adminId);
        log("Admin inserted successfully: ${response.data}");
      } else {
        handleExceptionMessage(apiName: "insert admin", response: response);
        log("Failed to insert admin: ${response.statusCode} - ${response.data}");
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          apiName: "insert admin", response: e.response, error: e);
      log("Error occurred while making POST request: $e");
    }
  }

  /// *******************************  SUBSCRIPTION  *******************************/

  Future<SubscribedPlan?> fetchSubscribtionPlan(int companyId) async {
    final cacheKey =
        '${SessionHelper.loginSavedData?.company_id ?? -1}_subscribed_plan_data';
    final subscribtionBox = Hive.box('subscribtionBox');
    log('Fetching subscription plan for company ID: $companyId');

    final isConnected = await ConnectivityService().isOnline();

    Future<SubscribedPlan?> loadFromCache() async {
      try {
        final cachedData = subscribtionBox.get(cacheKey);

        if (cachedData == null) {
          log("No cached subscription data available.");
          NkCommonFunction.showErrorSnakBar(
              'No offline subscription data available.');
          return null;
        }

        if (cachedData is Map) {
          // log("Loaded subscription plan from cache (Map): $cachedData");
          return SubscribedPlan.fromJson(
              localStorage.castToStringDynamic(cachedData));
        }

        if (cachedData is String) {
          try {
            final decoded = jsonDecode(cachedData);
            if (decoded is Map<String, dynamic>) {
              // log("Loaded subscription plan from cache (JSON String): $decoded");
              return SubscribedPlan.fromJson(decoded);
            } else {
              throw const FormatException("Decoded JSON is not a map.");
            }
          } catch (e) {
            log("Invalid cached string format. Expected valid JSON, got Dart-style map string.");
            NkCommonFunction.showErrorSnakBar(
                'Offline cache is corrupt. Please refresh with an internet connection.');
            return null;
          }
        }
        log("Unexpected cache type: ${cachedData.runtimeType}");
        NkCommonFunction.showErrorSnakBar('Offline cache format is invalid.');
      } catch (e) {
        log('Error reading from Hive: $e');
        NkCommonFunction.showErrorSnakBar(
            '1 Error accessing offline subscription data.');
      }

      return null;
    }

    if (isConnected) {
      try {
        final response = await dio1.post(
          "${ApiConstants.baseUrl}${ApiConstants.getSubscribedPlan}",
          data: {"company_id": "$companyId"},
        );

        log("Fetch Subscription URL: ${ApiConstants.baseUrl}${ApiConstants.getSubscribedPlan}");

        final subscribedPlan = SubscribedPlan.fromJson(response.data);
        log('Subscription plan fetched: ${subscribedPlan.toJson()}');

        // ✅ Save as Map, not string
        await subscribtionBox.put(cacheKey, subscribedPlan.toJson());
        log('Subscription plan saved to Hive.');

        return subscribedPlan;
      } on DioException catch (dioError) {
        log("Dio error while fetching subscription plan: ${dioError.response?.data}");
        handleExceptionMessage(
          apiName: 'Fetch Subscription Plan',
          response: dioError.response,
        );
        return await loadFromCache();
      } catch (e) {
        log("Unexpected error: $e");
        NkCommonFunction.showErrorSnakBar('An unexpected error occurred.');
        return await loadFromCache();
      }
    } else {
      log("No internet connection. Trying to load subscription plan from Hive.");
      return await loadFromCache();
    }
  }

  Future<SubscribtionPlanDetails?> fetchPlanDetails() async {
    const cacheKey = 'subscription_plan_details';
    final subscribtionBox = Hive.box('subscribtionPlanDetailsBox');
    log('Fetching subscription plan for company ID: ${SessionHelper.loginSavedData?.company_id ?? 0}');
    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        final response = await dio1.get(
          "${ApiConstants.baseUrl}${ApiConstants.getPlanDetiails}",
        );

        log("Fetch Subscription Plan Details URL: ${ApiConstants.baseUrl}${ApiConstants.getPlanDetiails}");
        final subscribedPlan = SubscribtionPlanDetails.fromJson(response.data);
        log('Subscription Plan Details fetched: ${subscribedPlan.toJson()}');
        await subscribtionBox.put(cacheKey, subscribedPlan.toJson());
        log('Subscription Plan Details saved to Hive.');

        return subscribedPlan;
      } on DioException catch (dioError) {
        log("Dio error while fetching subscription plan details: ${dioError.response?.data}");

        handleExceptionMessage(
          apiName: 'Fetch Subscription Plan Details',
          response: dioError.response,
        );
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

  Future<String> getRouteCredit() async {
    try {
      final response = await dio.postbycustom(
        ApiConstants.getRouteCredit,
        data: {
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        },
      );
      var res = RouteCreditResponse.fromJson(response.data);
      return res.credit;
    } on DioException catch (error) {
      log(error.toString());
      handleExceptionMessage(
          apiName: 'Get route credit', response: error.response);

      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (error) {
      log("Unexpected error: $error");
      return Future.error(Exception("Unexpected error: $error"));
    }
  }

  Future<UserVerificationResponse> userVerification(
    int companyId,
    String salesId,
  ) async {
    log("user Verification");
    try {
      Map<String, dynamic> data = {
        "companyId": companyId,
        "salesman_id": salesId,
        "usertype": "sales",
        "loginType": "app"
      };

      final response = await responsePostMethod(
        endPoint: ApiConstants.userVerification,
        requestData: data,
      );
      if (response.statusCode == 200) {
        log("userVerification log : ${response.data}");
        return UserVerificationResponse.fromJson(response.data);
      } else {
        final message = response.data['message'] ?? 'Verification failed';
        throw Exception(message);
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Verification failed';
      throw Exception(message);
    } catch (e) {
      throw Exception("Unexpected error during user verification");
    }
  }

  Future<void> saveSubscription({
    required int userId,
    required int planId,
    required String orderId,
    required double amount,
    required String licenses,
    required String currency,
  }) async {
    log('This function has been called');
    final endDate =
        DateTime.now().add(Duration(days: 14)).toIso8601String().split('T')[0];
    final response = await dio1.post(
      '${ApiConstants.baseUrl}${ApiConstants.insertTransactionAndSubscriptionDetails}',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({
        'user_id': userId,
        'plan_id': planId,
        'card_token': orderId,
        'end_date': endDate,
        'amount': amount,
        'payment_method': 'pay-pal',
        'status': 'trial',
        'licenses': licenses,
        'stripeCustomerId': '',
        'currency': currency
      }),
    );
    final data = response.data;
    if (data['status_code'] != 200) {
      throw Exception(data['message'] ?? 'Failed to save subscription');
    }
  }

  Future<String?> createPayPalOrder({
    required String amount,
    required String currency,
    required int adminId,
  }) async {
    log('Admin ID :$adminId');
    try {
      final response = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.createPaypalAuth}',
        data: {
          'amount': amount,
          'currency': currency,
          'adminId': adminId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data;
      if (response.statusCode == 200 && data['orderID'] != null) {
        return data['orderID'];
      } else {
        throw Exception(data['error'] ?? 'Failed to create PayPal order');
      }
    } catch (e) {
      if (e is DioException) {
        final errorData = e.response?.data;
        throw Exception(errorData?['error'] ?? e.message);
      } else {
        throw Exception(e.toString());
      }
    }
  }

  Future<Response> updateCustomerCheckInOut({
    String? date,
    String? time,
    String? direction,
    String? lat,
    String? long,
    String? customerId,
  }) async {
    var request = {
      "custid": customerId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id":  SessionHelper.loginSavedData?.salesmanId ?? '',
      "direction": direction,
      "time": time,
      "longitude": long,
      "latitude": lat,
    };
    log(request.toString());
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.updateCheckinCustomer,
        requestData: request,
      );

      return response;
    } catch (error) {
      log("Error occurred during customer check-in/out update: $error");
      handleExceptionMessage(
        apiName: 'Customer Check-In/Out',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to update customer check-in/out: $error');
    }
  }

  Future<FetchOnlyCustomer> fetchOnlyCustomerData(
    String eventDate,
    List<String> customerIds,
    String startDate,
    String endDate,
  ) async {
    final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final String cacheKey = '${companyId}_${startDate}_${endDate}';
    log(cacheKey);
    final box = await Hive.openBox('fetchOnlyCustomerDataInWholeBox');
    final isConnected = await ConnectivityService().isOnline();
    if (!isConnected) {
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        try {
          final convertedData = ApiService()
              .castToStringDynamic(Map<String, dynamic>.from(cachedData));
          final allData = FetchOnlyCustomer.fromJson(convertedData);
          // Filter by eventDate (start field)
          final filteredByDate = allData.data.where((item) {
            final startStr = item.start.toIso8601String().substring(0, 10);
            return startStr == eventDate;
          }).toList();
          // Filter by customerIds
          final filteredByCustomer = filteredByDate
              .where((item) => customerIds.contains(item.customerId))
              .toList();
          return FetchOnlyCustomer(
            statusCode: allData.statusCode,
            status: allData.status,
            message: allData.message,
            data: filteredByCustomer,
          );
        } catch (e) {
          log("Error converting or filtering cached fetchOnlyCustomerDataInWhole: $e");
          throw Exception(
              'Corrupt offline data for fetchOnlyCustomerDataInWhole');
        }
      } else {
        throw Exception(
            'No offline data available for fetchOnlyCustomerDataInWhole');
      }
    }
    try {
      var request = {
        "companyId": companyId,
        "customer_id": customerIds,
        "start_date": eventDate,
        "end_date": eventDate
      };
      log(request.toString());
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchOnlyCustomerData,
        requestData: request,
      );
      // Do not store anything here
      return FetchOnlyCustomer.fromJson(response.data);
    } catch (error) {
      log("Error occurred while fetching only customer data: $error");
      handleExceptionMessage(
        apiName: 'Fetch Only Customer Data',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch only customer data: $error');
    }
  }

  Future<FetchOnlyCustomer> fetchOnlyCustomerDataInWhole(
    String startDate,
    String endDate,
  ) async {
    final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final String cacheKey = '${companyId}_${startDate}_${endDate}';
    final box = await Hive.openBox('fetchOnlyCustomerDataInWholeBox');
    final isConnected = await ConnectivityService().isOnline();
    if (!isConnected) {
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        try {
          final convertedData = ApiService()
              .castToStringDynamic(Map<String, dynamic>.from(cachedData));
          return FetchOnlyCustomer.fromJson(convertedData);
        } catch (e) {
          log("Error converting cached fetchOnlyCustomerDataInWhole: $e");
          throw Exception(
              'Corrupt offline data for fetchOnlyCustomerDataInWhole');
        }
      } else {
        throw Exception(
            'No offline data available for fetchOnlyCustomerDataInWhole');
      }
    }
    try {
      var request = {
        "companyId": companyId,
        "start_date": startDate,
        "end_date": endDate
      };
      log(request.toString());
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchOnlyCustomerData,
        requestData: request,
      );
      // Cache the response
      await box.put(cacheKey, response.data);
      return FetchOnlyCustomer.fromJson(response.data);
    } catch (error) {
      log("Error occurred while fetching only customer data: $error");
      handleExceptionMessage(
        apiName: 'Fetch Only Customer Data',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch only customer data: $error');
    }
  }

  // Future<FetchOnlyCustomer> fetchOnlyCustomerData(
  //     String eventDate, List<String> customerIds) async {
  //   try {
  //     var request = {
  //       "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //       "customer_id": customerIds,
  //       // "event_id": eventId,
  //       "date": eventDate,
  //     };
  //     log(request.toString());
  //     final response = await responsePostMethod(
  //       endPoint: ApiConstants.fetchOnlyCustomerData,
  //       requestData: request,
  //     );

  //     return FetchOnlyCustomer.fromJson(response.data);
  //   } catch (error) {
  //     log("Error occurred while fetching only customer data: $error");
  //     handleExceptionMessage(
  //       apiName: 'Fetch Only Customer Data',
  //       response: error is DioException ? error.response : null,
  //     );
  //     throw Exception('Failed to fetch only customer data: $error');
  //   }
  // }

  Future<Response> scheduleVisit({
    List<Map<String, String>>? events,
  }) async {
    var request = {"companyId": 1, "events": events};
    log(request.toString());
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.scheduleVisit,
        requestData: request,
      );

      return response;
    } catch (error) {
      log("Error saving schedule visits: $error");
      handleExceptionMessage(
        apiName: 'Schedule Visit',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to save schedule visits: $error');
    }
  }

  Future<DebitCreditResponse> debitRouteCredits({
    required int? amount,
    required String? details,
    required List<String>? addresses,
  }) async {
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.deductCreditRoute,
        requestData: {
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
          "amount": amount,
          "details": details,
          "addresses": addresses
        },
      ).onError((DioException error, stackTrace) {
        log(error.toString());
        handleExceptionMessage(
            apiName: 'Debit Route Credits', response: error.response);
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      var res = DebitCreditResponse.fromJson(response.data);
      return res;
    } catch (e) {
      log("Error Debit Route Credits: $e");
      rethrow;
    }
  }

  Future<ShowRouteResponse> showRoutes({
    required List<String>? eventList,
  }) async {
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.showRoute,
        requestData: {"companyId": 1, "eventlist": eventList},
      ).onError((DioException error, stackTrace) {
        log(error.toString());
        handleExceptionMessage(
            apiName: 'Show Routes API', response: error.response);
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      var res = ShowRouteResponse.fromJson(response.data);
      return res;
    } catch (e) {
      log("Error in Show Routes: $e");
      rethrow;
    }
  }
}
