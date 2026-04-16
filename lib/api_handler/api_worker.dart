// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/local_storage_datas.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/model/pending_payment_model.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/model/verify_response.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/bulk/model/bulk_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/model/staff_discount_model.dart';
import 'package:busskit_salesexecutive/ui/components/promotions/promotion_models.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/model/calendar_salesman_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/controller/sales_return_search_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_action_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/customer_event_details_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_table_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_responce/product_frequency_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/product_return_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/return_info_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/sibscription_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
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
    try {
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: 'ChangePasswordStaff',
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {
      //
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
    try {
      final setupIntentRes = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.createSetUpIntent}',
        data: {'adminId': adminId},
      );
      if (setupIntentRes.statusCode != 200 ||
          setupIntentRes.data['stripeCustomerId'] == null) {
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
        return true;
      } else {
        return false;
      }
    } catch (e) {
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

    final cacheKey =
        'leads_count_${SessionHelper.loginSavedData?.salesmanId ?? ''}';
    final leadsCountBox = Hive.box('leadsCountBox');
    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        final response = await responsePostMethod(
          requestData: requestData,
          endPoint: ApiConstants.fetchLeadsCount,
        );

        if (response.statusCode == 200) {
          await leadsCountBox.put(cacheKey, response.data);
          return LeadsCountData.fromJson(response.data);
        } else {
          handleExceptionMessage(response: response, apiName: "leads count");
          final cachedData = leadsCountBox.get(cacheKey);
          if (cachedData != null) {
            return LeadsCountData.fromJson(
                LocalStorage().castToStringDynamic(cachedData));
          } else {
            return Future.error('No data available leads count');
          }
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "leads count", error: error);
        final cachedData = leadsCountBox.get(cacheKey);
        if (cachedData != null) {
          return LeadsCountData.fromJson(
              LocalStorage().castToStringDynamic(cachedData));
        } else {
          return Future.error('No data available leads count');
        }
      }
    } else {
      final cachedData = leadsCountBox.get(cacheKey);
      if (cachedData != null) {
        return LeadsCountData.fromJson(
            LocalStorage().castToStringDynamic(cachedData));
      } else {
        return Future.error('No cached data available for leads count');
      }
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
        errorSnackbar('An error occurred while fetching settings.');
      }
    }
    try {
      return localStorage.storedSettingsData(settingsBox, cacheKey);
    } catch (e) {
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

    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
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
        log('reposne data of salesmanDashNavContent:${response.data}');
        if (response.statusCode == 200) {
          final data = Map<String, dynamic>.from(response.data as Map);
          await box.put(cacheKey, data);
          log('response of the api :${response.data}');
          return data;
        } else {
          handleExceptionMessage(
              response: response, apiName: "salesman dash nav content");
          final cachedData = box.get(cacheKey);
          if (cachedData != null) {
            try {
              return Map<String, dynamic>.from(
                LocalStorage().castToStringDynamic(cachedData),
              );
            } catch (e) {
              //
            }
          }
          return null;
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response,
            apiName: "salesman dash nav content",
            error: error);
        final cachedData = box.get(cacheKey);
        if (cachedData != null) {
          try {
            return Map<String, dynamic>.from(
              LocalStorage().castToStringDynamic(cachedData),
            );
          } catch (e) {
            //
          }
        }
        return null;
      }
    } else {
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        try {
          return Map<String, dynamic>.from(
            LocalStorage().castToStringDynamic(cachedData),
          );
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
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
        await performanceBox.put(cacheKey, jsonData);
        return PerformanceData.fromJson(jsonData);
      } else {
        return localStorage.storedPerfromanceData(performanceBox, cacheKey);
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "performance", error: error);
      return localStorage.storedPerfromanceData(performanceBox, cacheKey);
    } catch (e) {
      return null;
    }
  }

  Future<FetchSpecificOrderInvoice> fetchSpecificOrderInvoice(
      String orderId) async {
    try {
      print('fetch fetchSpecificOrderInvoice called');
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchSpecificOrder,
        requestData: {
          "order_id": orderId,
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        },
      );

      return FetchSpecificOrderInvoice.fromJson(response.data);
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Fetch Specific Order Invoice',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch specific order invoice: $error');
    }
  }

  // Future<FetchSpecificOrderInvoice> fetchSpecificOrderInvoice(
  //     String orderId) async {
  //   try {
  //     final bool isOnline = await ConnectivityService().isOnline();
  //     final requestData = {
  //       "order_id": orderId,
  //       "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //     };
  //     if (!isOnline) {
  //       return Future.error('No internet connection');
  //     } else {
  //       final response = await responsePostMethod(
  //         requestData: requestData,
  //         endPoint: ApiConstants.fetchSpecificOrder,
  //         options: Options(
  //           validateStatus: (status) {
  //             return true;
  //           },
  //         ),
  //       );
  //       if (response.statusCode == 200) {
  //         return FetchSpecificOrderInvoice.fromJson(response.data);
  //       } else {
  //         handleExceptionMessage(
  //             response: response, apiName: "specific order invoice");
  //         return Future.error('API Error: ${response.statusCode}');
  //       }
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         response: error.response,
  //         apiName: "specific order invoice,",
  //         error: error);
  //     return Future.error(error);
  //   }
  // }

  Future<CustomerAndOrderResponce> getCustomer() async {
    try {
      bool isOnline = await ConnectivityService().isOnline();
      final requestBody = {
        "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
        "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      };
      if (isOnline) {
        final response = await responsePostMethod(
            requestData: requestBody, endPoint: ApiConstants.fetchcustomer);
        if (response.statusCode == 200) {
          final customerData = CustomerAndOrderResponce.fromJson(response.data);
          await localStorage.storeCustomerData(customerData);
          return customerData;
        } else {
          handleExceptionMessage(response: response, apiName: "get customer");
          return Future.error('API Error: On Fetching Customer');
        }
      } else {
        final customerData = await localStorage.retrieveCustomerData();
        if (customerData != null) {
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
        return await localStorage.getCachedRecentOrderCount(cacheKey);
      }
    } else {
      return await localStorage.getCachedRecentOrderCount(cacheKey);
    }
  }

  Future<CartOrderModel?> addToCart(Map<String, dynamic> sendData) async {
    sendData['companyId'] = SessionHelper.loginSavedData?.company_id ?? 0;
    try {
      log("ADD TO CART REQUEST : $sendData");
      final response = await dio1
          .post(
        "${ApiConstants.baseUrl}${ApiConstants.addToCart}",
        data: sendData,
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
          return null;
        }
        return CartOrderModel.fromJson(response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "add to cart");
        return null;
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "add to cart", error: error);
      return Future.error(DioExceptionHandler.fromDioError(error));
    }
  }

  Future<CartOrderModel?> addToDraft(Map<String, dynamic> sendData) async {
    sendData['companyId'] = SessionHelper.loginSavedData?.company_id ?? 0;
    try {
      print('add to draft called');
      final response = await dio1
          .post(
        "${ApiConstants.baseUrl}${ApiConstants.addToDraft}",
        data: sendData,
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
          return null;
        }
        return CartOrderModel.fromJson(response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "add to draft");
        return null;
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "add to draft", error: error);
      return Future.error(DioExceptionHandler.fromDioError(error));
    }
  }

  Future<Response> deleteCustomer(String id) async {
    final response = await dio.postbycustom(ApiConstants.deletCustomer, data: {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "id": id,
    }).onError((DioException error, stackTrace) {
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

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
      handleExceptionMessage(
        apiName: 'Fetch Category',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch category data: $error');
    }
  }

  Future<CategoryModel> getCategoryForPromo(List<String> categories) async {
    try {
      final request = {
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        "categories": categories
      };
      final response = await dio.postbycustom(
        ApiConstants.getPromoCategories,
        data: request,
      );

      final category = CategoryModel.fromJson(response.data);

      return category;
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Fetch Category Promo',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch category Promo data: $error');
    }
  }

  Future<List<ProductModel>> getTempProduct(String subCatId,
      {required int companyid}) async {
    final isConnected = await ConnectivityService().isOnline();

    if (isConnected) {
      try {
        print('api called correctlyyyyyy get temp product');

        // 1. Construct the URL manually to match your required format
        late String requestUrl =
            "${ApiConstants.fetchProduct}?company_id=$companyid&sub_catid=$subCatId";

        print('Requesting URL: $requestUrl');

        // 2. Pass the full URL directly. Do NOT pass 'queryParameters'
        final response = await dio.getbycustom(requestUrl);
log('response of alll products get :${response.data}'); 
        if (response.statusCode == 200) {
          final responseData = response.data;
          // log('category data from backend in order taking screen:${responseData}');

          final productApiResponse = ProductApiResponse.fromJson(responseData);

          List<ProductModel> productsForSubCategory = [];
          ScidProductGroup? targetScidGroup;

          for (var scidGroup in productApiResponse.data) {
            if (scidGroup.scid == subCatId) {
              productsForSubCategory.addAll(scidGroup.products);
              targetScidGroup = scidGroup;
              break;
            }
          }

          if (targetScidGroup != null) {
            await _cacheSingleScidGroup(targetScidGroup);
          } else {}

          return productsForSubCategory;
        } else {
          return [];
        }
      } catch (e) {
        handleExceptionMessage(
          apiName: 'Get Temp Product',
          response: e is DioException ? e.response : null,
        );
        return [];
      }
    } else {
      
      final cachedProducts = await _loadCachedProductsBySubCategory(subCatId);
      return cachedProducts;
    }
  }

  // Future<List<ProductModel>> getTempProduct(String subCatId,
  //     {required int companyid}) async {
  //   final isConnected = await ConnectivityService().isOnline();

  //   if (isConnected) {
  //     try {
  //       print('api called correctlyyyyyy get temp product');
  //       final queryParams = {
  //         "company_id": companyid,
  //         "sub_catid": subCatId,
  //       };
  //       print('query parametr:$queryParams');

  //       final response = await dio.getbycustom(ApiConstants.fetchProduct,
  //           queryParameters: queryParams);

  //       if (response.statusCode == 200) {
  //         final responseData = response.data;
  //         // log('API Response Data: $responseData');
  // log('category data from backend in order taking screen:${responseData}');
  //         // Parse the new response structure
  //         final productApiResponse = ProductApiResponse.fromJson(responseData);

  //         List<ProductModel> productsForSubCategory = [];
  //         ScidProductGroup? targetScidGroup;

  //         // Find products for the specific subcategory
  //         for (var scidGroup in productApiResponse.data) {
  //           if (scidGroup.scid == subCatId) {
  //             productsForSubCategory.addAll(scidGroup.products);
  //             targetScidGroup = scidGroup;
  //             break; // Found the specific subcategory, no need to continue
  //           }
  //         }

  //         // Cache only the specific subcategory data, not all data
  //         if (targetScidGroup != null) {
  //           await _cacheSingleScidGroup(targetScidGroup);
  //         } else {}

  //         return productsForSubCategory;
  //       } else {
  //         return [];
  //       }
  //     } catch (e) {
  //       handleExceptionMessage(
  //         apiName: 'Get Temp Product',
  //         response: e is DioException ? e.response : null,
  //       );
  //       return [];
  //     }
  //   } else {
  //     // Load from cached data when offline
  //     final cachedProducts = await _loadCachedProductsBySubCategory(subCatId);
  //     return cachedProducts;
  //   }
  // }

  // Helper method to load cached products for a specific subcategory
  Future<List<ProductModel>> _loadCachedProductsBySubCategory(
      String subCatId) async {
    try {
      // Try to load from scid-based cache first
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      // Check if the box has any data
      if (scidGroupBox.isEmpty) {
      } else {}

      final scidGroup = scidGroupBox.get(subCatId);
      if (scidGroup != null) {
        return scidGroup.products;
      }

      // Fallback to old cache structure - filter by scid
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        // Show all available scids in legacy cache for debugging
        productBox.values.map((p) => p.scid).toSet().toList();

        List<ProductModel> offlineProducts = productBox.values
            .where((product) => product.scid == subCatId)
            .toList();

        if (offlineProducts.isNotEmpty) {}

        return offlineProducts;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    final companyId = SessionHelper.loginSavedData?.company_id;

    final isConnected = await ConnectivityService().isOnline();

    if (isConnected) {
      try {
        print('get all product api called');
        // print('get all product api called');
        final queryParams = {"company_id": companyId};
        // print('query paerametyer in the get all product:$queryParams');

        final response = await dio.getbycustom(ApiConstants.fetchProduct,
            queryParameters: queryParams);

        if (response.statusCode == 200) {
          final responseData = response.data;
          // log('[getAllProducts] API Response Data: $responseData');
// log('category data from backend in order taking screen get all producrt:${responseData}');
          // Parse the new response structure
          final productApiResponse = ProductApiResponse.fromJson(responseData);

          List<ProductModel> allProducts = [];

          // Extract all products from all scid groups
          for (var scidGroup in productApiResponse.data) {
            allProducts.addAll(scidGroup.products);
          }

          // Store products by scid for caching
          await _cacheProductsByScid(productApiResponse.data);

          // Verify cache was successful
          await _verifyProductCache();

          return allProducts;
        } else {
          return [];
        }
      } catch (e, stackTrace) {
        print('┌───────────────────────────────');
        print('│ ERROR in getAllProducts()');
        print('├───────────────────────────────');
        print('│ Type:     ${e.runtimeType}');
        print('│ Message:  $e');
        if (e is DioException) {
          print('│ Status:   ${e.response?.statusCode}');
          print('│ Endpoint: ${e.requestOptions.path}');
          print('│ Response: ${e.response?.data}');
        }
        print('│');
        print('│ Stack trace (first few lines):');
        print('│ ${stackTrace.toString().split('\n').take(6).join('\n│ ')}');
        print('└───────────────────────────────');

        handleExceptionMessage(
          apiName: 'Get All Product',
          response: e is DioException ? e.response : null,
        );
        // handleExceptionMessage(
        //   apiName: 'Get All Product',
        //   response: e is DioException ? e.response : null,
        // );
        return [];
      }
    } else {
      // Load from cached data when offline
      final cachedProducts = await _loadCachedProducts();
      return cachedProducts;
    }
  }

  // Method to verify product cache status
  Future<void> _verifyProductCache() async {
    try {
      late Box<ScidProductGroup> scidGroupBox;

      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (Hive.isBoxOpen('products')) {
      } else {}

      if (scidGroupBox.isNotEmpty) {
        for (var key in scidGroupBox.keys) {
          scidGroupBox.get(key);
        }
      }
    } catch (e) {
      //
    }
  }

  // Helper method to cache a single scid group
  Future<void> _cacheSingleScidGroup(ScidProductGroup scidGroup) async {
    try {
      // Open or create box for caching
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

      // Store the single scid group with its scid as key
      await scidGroupBox.put(scidGroup.scid, scidGroup);

      // Remove existing products with the same scid to avoid duplicates
      final existingProducts =
          productBox.values.where((p) => p.scid == scidGroup.scid).toList();

      for (var product in existingProducts) {
        if (product.productId != null) {
          await productBox.delete(product.productId);
          // log('Removed existing product: ${product.productId}');
        }
      }

      // Add new products for this scid (don't deduplicate here - let the API handle it)
      await productBox.addAll(scidGroup.products);
    } catch (e) {
      //
    }
  }

  // Helper method to cache products by scid
  Future<void> _cacheProductsByScid(List<ScidProductGroup> scidGroups) async {
    try {
      // Open or create boxes for caching
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

      // Store scid groups with their scid as key (don't clear existing data)
      for (var scidGroup in scidGroups) {
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
            // log('Removed existing product: ${product.productId}');
          }
        }
      }

      // Add new products without deduplication (let the API handle it)
      await productBox.addAll(newProducts);
    } catch (e) {
      //
    }
  }

  // Helper method to load cached products
  Future<List<ProductModel>> _loadCachedProducts() async {
    try {
      // Try to load from scid-based cache first
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      if (scidGroupBox.isNotEmpty) {
        List<ProductModel> allProducts = [];
        for (var scidGroup in scidGroupBox.values) {
          allProducts.addAll(scidGroup.products);
        }
        return allProducts;
      }

      // Fallback to old cache structure
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        List<ProductModel> offlineProducts = productBox.values.toList();
        return offlineProducts;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // New method to get products by specific scid
  Future<List<ProductModel>> getProductsByScid(String scid) async {
    try {
      late Box<ScidProductGroup> scidGroupBox;
      if (Hive.isBoxOpen('scidProductGroups')) {
        scidGroupBox = Hive.box<ScidProductGroup>('scidProductGroups');
      } else {
        scidGroupBox =
            await Hive.openBox<ScidProductGroup>('scidProductGroups');
      }

      final scidGroup = scidGroupBox.get(scid);
      if (scidGroup != null) {
        return scidGroup.products;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Method to check if a subcategory has cached data
  Future<bool> hasCachedProductsForSubCategory(String subCatId) async {
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
        return true;
      }

      // Check legacy cache
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        final hasProducts =
            productBox.values.any((product) => product.scid == subCatId);
        return hasProducts;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Method to clear all cached products
  Future<void> clearProductCache() async {
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
    } catch (e) {
      //
    }
  }

  // Method to clear products for a specific subcategory
  Future<void> clearProductsForSubCategory(String subCatId) async {
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
    } catch (e) {
      //
    }
  }

  // Method to get all available cached subcategory IDs
  Future<List<String>> getCachedSubcategoryIds() async {
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
      } else {}

      return cachedScids;
    } catch (e) {
      return [];
    }
  }

  // Method to get comprehensive cache status
  Future<Map<String, dynamic>> getCacheStatus() async {
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

      return status;
    } catch (e) {
      return {};
    }
  }

  // Method to check if any cache has data
  Future<bool> hasAnyCachedData() async {
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
        return true;
      }

      // Check legacy cache
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
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
        } else {}
      } else {
        errorSnackbar(response.statusMessage ?? '');
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "discount", error: error);
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

      final response = await dio.postbycustom(
        ApiConstants.addCustomer,
        data: formData,
      );

      return response;
    } on DioException catch (error) {
      handleExceptionMessage(
        apiName: 'Add Customer',
        response: error.response,
      );

      throw DioExceptionHandler.fromDioError(error);
    } catch (error) {
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

      final response = await dio.patchbycustom(
        ApiConstants.updateCustomer,
        data: formData,
      );

      return response;
    } on DioException catch (error) {
      handleExceptionMessage(
        apiName: 'Update Customer',
        response: error.response,
      );

      throw DioExceptionHandler.fromDioError(error);
    } catch (error) {
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
    } else {}
    try {
      return localStorage.storedLeadsData(leadsBox, cacheKey);
    } catch (e) {
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
    sendData['salesman_id'] = SessionHelper.loginSavedData?.salesmanId ?? '';
    final cacheKey =
        'calendar_events_${sendData['companyId']}_${sendData['salesman_id']}_${sendData['startDate']}_${sendData['endDate']}';

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
          List<dynamic> eventsJson = castedResponse['data'];
          await eventsBox.put(cacheKey, eventsJson);
          allEvents = eventsJson
              .map((event) => EventData.fromJson(event as Map<String, dynamic>))
              .toList();
          fetchedFromApi = true;
        } else {
          throw Exception('API response does not contain expected event list.');
        }
      } on DioException catch (error) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          errorSnackbar(
              'Request timed out. Please check your internet connection and try again.');
          return Future.error(
              'Request timed out. Please check your internet connection and try again.');
        }

        handleExceptionMessage(
          response: error.response,
          apiName: "calendar event",
          error: error,
        );
      } catch (e) {
        //
      }
    } else {}
    if (!fetchedFromApi) {
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
      } on DioException catch (e) {
        handleExceptionMessage(
            response: null, apiName: "calendar event", error: e);
      }
    }

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

  Future<OrderResponce> getRecentOrdersData({
    SearchModel? searchModel,
    int? orderStatus,
    int? page,
    required bool isLogin,
  }) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    try {
      final requestData = {
        "order_status": orderStatus,
        "start_date": '',
        "end_date": '',
        "limit": 10,
        "page": page,
        "companyId": companyId,
        "salesmanid": SessionHelper.loginSavedData?.salesmanId ?? '',
      };

      final response = await responsePostMethod(
        endPoint: ApiConstants.getRecentOrdersData,
        requestData: requestData,
      );
      log('get recent orders response:${response.data}');

    
      if (response.data['status'] == true &&
          response.data['status_code'] == 200) {}

      try {
        return OrderResponce.fromJson(response.data);
      } catch (parseError) {
        throw Exception('Invalid response format.');
      }
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode ?? 0;

      if (statusCode != 200 || error.response?.data['status'] != true) {
        handleExceptionMessage(
          apiName: 'Recent Orders (DioException)',
          response: error.response,
        );
      }

      throw Exception('Failed to fetch data and no cached data available.');
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  // Future<OrderResponce> getRecentOrdersData({
  //   SearchModel? searchModel,
  //   int? orderStatus,
  //   String? startDate,
  //   String? endDate,
  //   int? page,
  //   required bool isLogin,
  // }) async {
  //   try {
  //     final requestData = {
  //       "order_status": orderStatus,
  //       "start_date": '',
  //       "end_date": '',
  //       "limit": 10,
  //       "page": page,
  //       "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //       "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
  //     };

  //     final response = await responsePostMethod(
  //       endPoint: ApiConstants.getRecentOrder,
  //       requestData: requestData,
  //     );

  //     if (response.data['status'] == true &&
  //         response.data['status_code'] == 200) {}

  //     try {
  //       return OrderResponce.fromJson(response.data);
  //     } catch (parseError) {
  //       throw Exception('Invalid response format.');
  //     }
  //   } on DioException catch (error) {
  //     final statusCode = error.response?.statusCode ?? 0;

  //     if (statusCode != 200 || error.response?.data['status'] != true) {
  //       handleExceptionMessage(
  //         apiName: 'Recent Orders (DioException)',
  //         response: error.response,
  //       );
  //     }

  //     throw Exception('Failed to fetch data and no cached data available.');
  //   } catch (e) {
  //     throw Exception('Unexpected error occurred: $e');
  //   }
  // }

  Future<OrderProcessInvoice> getOrderProcessInvoiceData({
    String? orderId,
    int? orderStatus,
  }) async {
    try {
      print('getOrderProcessInvoiceData called');
      final requestBody = {
        "order_id": orderId,
        "order_status": orderStatus,
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      };
      final response = await responsePostMethod(
          requestData: requestBody, endPoint: ApiConstants.orderProcessInvoice);
          log('reponse of the order invoice details:${response.data}');
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
      throw Exception(
          'An unexpected error occurred while fetching order process invoice data.');
    }
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
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      }),
    )
        .onError((DioException error, stackTrace) {
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderProcessInvoice.fromJson(response.data);
  }

  Future<ScheduleListResponse?> fetchSchedule(
    String endDate,
    String startDate,
  ) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    final cacheKey =
        'schedule_${companyId}_${salesmanId}_${startDate}_$endDate';

    final scheduleBox = Hive.box('scheduleBox');

    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        final requestData = {
          "end_date": endDate,
          "salesman_id": salesmanId,
          "start_date": startDate,
          "company_id": companyId,
        };

        final response = await responsePostMethod(
          endPoint: ApiConstants.fetchSchedule,
          requestData: requestData,
        );

        final scheduleResponse = ScheduleListResponse.fromJson(response.data);

        await scheduleBox.put(cacheKey, response.data);

        return scheduleResponse;
      } on DioException {
        final cachedData = scheduleBox.get(cacheKey);
        if (cachedData != null) {
          return ScheduleListResponse.fromJson(
              Map<String, dynamic>.from(cachedData));
        } else {
          // NkCommonFunction.showErrorSnakBar(
          //   // 'No offline schedule data available.',
          // );
        }
      } catch (e) {
        NkCommonFunction.showErrorSnakBar('An unexpected error occurred.');
      }
    }

    try {
      final cachedData = scheduleBox.get(cacheKey);
      if (cachedData != null) {
        return ScheduleListResponse.fromJson(
            Map<String, dynamic>.from(cachedData));
      } else {
        // NkCommonFunction.showErrorSnakBar(
        //   'No offline schedule data available.',
        // );
      }
    } catch (e) {
      NkCommonFunction.showErrorSnakBar(
        'Error accessing offline schedule data.',
      );
    }

    return null;
  }

  Future<String?> getWeeklyType() async {
    const cacheKey = 'weekly_type';
    final weeklyTypeBox = Hive.box('weeklyTypeBox');
    try {
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
      //
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

          if (jsonData != null && jsonData is Map<String, dynamic>) {
            await targetBox.put(cacheKey, jsonData);
            return SalesmanValueTargetResponse.fromJson(jsonData);
          }
        }
      }
    } catch (e) {
      //
    }

    try {
      final cachedData = targetBox.get(cacheKey);
      if (cachedData != null) {
        return SalesmanValueTargetResponse.fromJson(
          Map<String, dynamic>.from(cachedData),
        );
      }
    } catch (e) {
      //
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
      final Map<String, dynamic> requestPayload = cartOrder.toJson();

      requestPayload['order_source'] = "app";

      log("PLACE ORDER REQUEST : $requestPayload");

      final response = await responsePostMethod(
          requestData: requestPayload, endPoint: "place_order");

      if (response.statusCode == 200) {
        onResponse(
            200, 'Your order has been successfully placed.'.tr, response.data);
      } else {
        handleExceptionMessage(response: response, apiName: "place order");
      }
    } on DioException catch (error) {
      handleExceptionMessage(
          response: error.response, apiName: "place order", error: error);
      onResponse(500, 'An error occurred while placing the order.', null);
    }
  }

  // Future<void> placeOrder(
  //   CartOrderModel cartOrder,
  //   Function(int statusCode, String message, Map<String, dynamic>? responseData)
  //       onResponse,
  // ) async {
  //   final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  //   cartOrder.companyId = companyId;
  //   try {
  //     log("PLACE ORDER REQUEST : ${cartOrder.toJson()}");
  //     final response = await responsePostMethod(
  //         requestData: cartOrder.toJson(), endPoint: "place_order");
  //     if (response.statusCode == 200) {
  //       onResponse(
  //           200, 'Your order has been successfully placed.', response.data);
  //     } else {
  //       handleExceptionMessage(response: response, apiName: "place order");
  //     }
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //         response: error.response, apiName: "place order", error: error);
  //     onResponse(500, 'An error occurred while placing the order.', null);
  //   }
  // }

  Future<SalesmanTargetTableResponse?> fetchSalesmanTarget(
      String salesmanId, String month, String year,
      {int? compId, bool? isFromLogin}) async {
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
    try {
      bool isOnline = await _connectivityService.isOnline();
      if (isOnline) {
        try {
          final response = await dio.postbycustom(
            ApiConstants.fetchSalesmanTarget,
            data: requestPayload,
          );
          if (response.statusCode == 200) {
            final dynamic jsonData = response.data;
            if (jsonData != null) {
              await targetBox.put(cacheKey, jsonData);
              return SalesmanTargetTableResponse.fromJson(jsonData);
            }
          } else {
            handleExceptionMessage(
                response: response, apiName: "salesman target");
          }
        } catch (apiError) {
          //
        }
      } else {
        if (targetBox.containsKey(cacheKey)) {
          final cachedData = targetBox.get(cacheKey);
          if (cachedData != null) {
            return SalesmanTargetTableResponse.fromJson(cachedData);
          }
        }
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          response: e.response, apiName: "salesman target", error: e);
      try {
        if (targetBox.containsKey(cacheKey)) {
          final cachedData = targetBox.get(cacheKey);

          if (cachedData != null) {
            return SalesmanTargetTableResponse.fromJson(cachedData);
          }
        }
      } catch (cacheError) {
        //
      }
    }
    return null;
  }
  Future<StaffTimesheetResponse> getTimeSheetData({
  required String filterValue, // Pass "March" here
  required String filterType,  // Pass "Month" here
}) async {
  final id = SessionHelper.loginSavedData?.id ?? '';

  // Update cache key to be unique based on inputs
  final cacheKey = 'timesheet_${id}_${filterType}_$filterValue';
  final timesheetBox = await Hive.openBox('timesheetBox');

  bool isOnline = await ConnectivityService().isOnline();

  // Correct Payload Structure matches Web App
  final requestData = {
    "id": id,
    "valueFromDw": filterType, // "Month"
    "selected_range": [filterValue] // ["March"]
  };

  if (isOnline) {
    try {
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: ApiConstants.getStaffTimeSheet,
      );
      
      if (response.statusCode == 200) {
        await timesheetBox.put(cacheKey, response.data);
        return StaffTimesheetResponse.fromJson(response.data);
      } else {
        return _getFromCache(timesheetBox, cacheKey);
      }
    } catch (e) {
      return _getFromCache(timesheetBox, cacheKey);
    }
  } else {
    return _getFromCache(timesheetBox, cacheKey);
  }
}

  // Future<StaffTimesheetResponse> getTimeSheetData({
  //   required String year, // Changed parameters to accept Year
  // }) async {
  //   final id = SessionHelper.loginSavedData?.id ?? '';

  //   // Update cache key to be unique by ID and Year
  //   final cacheKey = 'timesheet_${id}_$year';
  //   final timesheetBox = await Hive.openBox('timesheetBox');

  //   bool isOnline = await ConnectivityService().isOnline();

  //   // New Payload Structure
  //   final requestData = {
  //     "id": id,
  //     "valueFromDw": "Year", 
  //     "selected_range": [year] 
  //   };

  //   if (isOnline) {
  //     try {
  //       final response = await responsePostMethod(
  //         requestData: requestData,
  //         endPoint: ApiConstants.getStaffTimeSheet,
  //       );
  //       log('time sheet response data: ${response.data}');

  //       if (response.statusCode == 200) {
  //         // Cache the fresh data
  //         await timesheetBox.put(cacheKey, response.data);
  //         return StaffTimesheetResponse.fromJson(response.data);
  //       } else {
  //         return _getFromCache(timesheetBox, cacheKey);
  //       }
  //     } on DioException {
  //       return _getFromCache(timesheetBox, cacheKey);
  //     } catch (e) {
  //       return _getFromCache(timesheetBox, cacheKey);
  //     }
  //   } else {
  //     return _getFromCache(timesheetBox, cacheKey);
  //   }
  // }

  

  StaffTimesheetResponse _getFromCache(Box timesheetBox, String cacheKey) {
    final cachedData = timesheetBox.get(cacheKey);

    if (cachedData != null) {
      final castedData = LocalStorage().castToStringDynamic(cachedData);
      return StaffTimesheetResponse.fromJson(castedData);
    } else {
      throw Exception(
          'No internet and no cached data available for $cacheKey.');
    }
  }

  Future<bool> loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('switch_state') ?? false;
  }

  Future<void> saveSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switch_state', value);
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
    final request = {
      "sales_id": salesmanId,
      "year": year,
      "month_target": monthTarget,
      "weekly_target": weeklyTarget,
      "month_to_insert": month,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    final response = await dio
        .postbycustom(ApiConstants.updateValueBasedTargetValue, data: (request))
        .onError((DioException error, stackTrace) {
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

    final response = await responsePostMethod(
            requestData: requestPayload, endPoint: 'Update_CategorytargetValue')
        .onError((DioException error, stackTrace) {
      return Future.error(DioExceptionHandler.fromDioError(error));
    });
    return response;
  }

  Future<LeadResponce> getLeadsCustomerData(int currentPage) async {
    final cacheKey =
        'leads_customer_${SessionHelper.loginSavedData?.salesmanId ?? ''}_$currentPage';
    final leadsBox = await Hive.openBox('leadsCustomerBox');
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
            endPoint: ApiConstants.fetchLeadsCustomer);
        if (response.statusCode == 200) {
          await leadsBox.put(cacheKey, response.data);
          return LeadResponce.fromJson(response.data);
        } else {
          handleExceptionMessage(response: response, apiName: "leads customer");
          return localStorage.storedLeadsData(leadsBox, cacheKey);
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "leads customer", error: error);
        return localStorage.storedLeadsData(leadsBox, cacheKey);
      }
    }
    try {
      final cachedData = leadsBox.get(cacheKey);
      if (cachedData != null) {
        final castedData = LocalStorage().castToStringDynamic(cachedData);
        return LeadResponce.fromJson(castedData);
      } else {
        throw Exception('No internet and no cached data available.');
      }
    } catch (e) {
      throw Exception('Failed to fetch data from API and Hive.');
    }
  }

  Future<dynamic> getRegisteredAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? adminId = prefs.getInt('admin_id');
      if (adminId == null) {
        return null;
      }
      final response = await dio1.post(
        "${ApiConstants.baseUrl}${ApiConstants.getRegisteredAddressAdmin}",
        data: {'admin_id': adminId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data;

      if (response.statusCode == 200 && data['data'] != null) {
        return data['data'];
      }
    } catch (e) {
      //
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
      } else {}
    } on DioException catch (e) {
      handleExceptionMessage(
          apiName: "Send verification Email", error: e, response: e.response);
    } catch (e) {
      //
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
    try {
      final response = await responsePostMethod(
          requestData: requestData, endPoint: ApiConstants.insertadmin);
      if (response.statusCode == 200) {
        final data = response.data['data'][0];
        final int adminId = data['id_admin'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('admin_id', adminId);
      } else {
        handleExceptionMessage(apiName: "insert admin", response: response);
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          apiName: "insert admin", response: e.response, error: e);
    }
  }

  Future<SubscribedPlan?> fetchSubscribtionPlan(int companyId) async {
    final cacheKey =
        '${SessionHelper.loginSavedData?.company_id ?? -1}_subscribed_plan_data';
    final subscribtionBox = Hive.box('subscribtionBox');

    final isConnected = await ConnectivityService().isOnline();

    Future<SubscribedPlan?> loadFromCache() async {
      try {
        final cachedData = subscribtionBox.get(cacheKey);

        if (cachedData == null) {
          NkCommonFunction.showErrorSnakBar(
              'No offline subscription data available.');
          return null;
        }

        if (cachedData is Map) {
          return SubscribedPlan.fromJson(
              localStorage.castToStringDynamic(cachedData));
        }

        if (cachedData is String) {
          try {
            final decoded = jsonDecode(cachedData);
            if (decoded is Map<String, dynamic>) {
              return SubscribedPlan.fromJson(decoded);
            } else {
              throw const FormatException("Decoded JSON is not a map.");
            }
          } catch (e) {
            NkCommonFunction.showErrorSnakBar(
                'Offline cache is corrupt. Please refresh with an internet connection.');
            return null;
          }
        }
        NkCommonFunction.showErrorSnakBar('Offline cache format is invalid.');
      } catch (e) {
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

        final subscribedPlan = SubscribedPlan.fromJson(response.data);

        await subscribtionBox.put(cacheKey, subscribedPlan.toJson());

        return subscribedPlan;
      } on DioException catch (dioError) {
        handleExceptionMessage(
          apiName: 'Fetch Subscription Plan',
          response: dioError.response,
        );
        return await loadFromCache();
      } catch (e) {
        NkCommonFunction.showErrorSnakBar('An unexpected error occurred.');
        return await loadFromCache();
      }
    } else {
      return await loadFromCache();
    }
  }

  Future<SubscribtionPlanDetails?> fetchPlanDetails() async {
    const cacheKey = 'subscription_plan_details';
    final subscribtionBox = Hive.box('subscribtionPlanDetailsBox');
    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        final response = await dio1.get(
          "${ApiConstants.baseUrl}${ApiConstants.getPlanDetiails}",
        );

        final subscribedPlan = SubscribtionPlanDetails.fromJson(response.data);
        await subscribtionBox.put(cacheKey, subscribedPlan.toJson());

        return subscribedPlan;
      } on DioException catch (dioError) {
        handleExceptionMessage(
          apiName: 'Fetch Subscription Plan Details',
          response: dioError.response,
        );
        final cachedData = subscribtionBox.get(cacheKey);
        if (cachedData != null) {
          return SubscribtionPlanDetails.fromJson(
              Map<String, dynamic>.from(cachedData));
        } else {
          NkCommonFunction.showErrorSnakBar(
              'No offline subscription plan details data available.');
        }
      } catch (e) {
        NkCommonFunction.showErrorSnakBar('An unexpected error occurred.');
      }
    }
    try {
      final cachedData = subscribtionBox.get(cacheKey);
      if (cachedData != null) {
        return SubscribtionPlanDetails.fromJson(
            Map<String, dynamic>.from(cachedData));
      } else {
        NkCommonFunction.showErrorSnakBar(
            'No offline subscription plan details data available.');
      }
    } catch (e) {
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
      handleExceptionMessage(
        apiName: 'Send Invoice',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to send invoice: $error');
    }
  }

  Future<String> getRouteCredit() async {
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.getRouteCredit,
        requestData: {
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        },
      );
      var res = RouteCreditResponse.fromJson(response.data);
      return res.credit;
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: 'Get route credit', response: error.response);

      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (error) {
      return Future.error(Exception("Unexpected error: $error"));
    }
  }

  Future<UserVerificationResponse> userVerification(
    int companyId,
    String salesId,
  ) async {
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
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "direction": direction,
      "time": time,
      "longitude": long,
      "latitude": lat,
    };
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.updateCheckinCustomer,
        requestData: request,
      );

      return response;
    } catch (error) {
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
    final String cacheKey = '${companyId}_${startDate}_$endDate';
    final box = await Hive.openBox('fetchOnlyCustomerDataInWholeBox');
    final isConnected = await ConnectivityService().isOnline();
    if (!isConnected) {
      final cachedData = box.get(cacheKey);
      if (cachedData != null) {
        try {
          final convertedData = ApiService()
              .castToStringDynamic(Map<String, dynamic>.from(cachedData));
          final allData = FetchOnlyCustomer.fromJson(convertedData);
          final filteredByDate = allData.data.where((item) {
            final startStr = item.start.toIso8601String().substring(0, 10);
            return startStr == eventDate;
          }).toList();
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
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchOnlyCustomerData,
        requestData: request,
      );
      // Do not store anything here
      return FetchOnlyCustomer.fromJson(response.data);
    } catch (error) {
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
    final String cacheKey = '${companyId}_${startDate}_$endDate';
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
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchOnlyCustomerData,
        requestData: request,
      );
      await box.put(cacheKey, response.data);
      return FetchOnlyCustomer.fromJson(response.data);
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Fetch Only Customer Data',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch only customer data: $error');
    }
  }

  Future<Response> scheduleVisit({
    List<Map<String, String>>? events,
  }) async {
    var request = {"companyId": 1, "events": events};
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.scheduleVisit,
        requestData: request,
      );

      return response;
    } catch (error) {
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
        handleExceptionMessage(
            apiName: 'Debit Route Credits', response: error.response);
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      var res = DebitCreditResponse.fromJson(response.data);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<ShowRouteResponse> showRoutes({
    required List<String>? eventList,
  }) async {
    try {
      print('show route api is called');
      // 1. Store the data in a variable first
      Map<String, dynamic> requestData = {
        "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        "eventlist": eventList
      };

      // 2. Print it to the console
      print('--- Show Route Request Data ---');
      print(requestData);
      // Or use log(jsonEncode(requestData)) for a cleaner look if you import 'dart:convert'

      final response = await responsePostMethod(
        endPoint: ApiConstants.showRoute,
        requestData: requestData, // Use the variable here
      ).onError((DioException error, stackTrace) {
        handleExceptionMessage(
            apiName: 'Show Routes API', response: error.response);
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      log('showRoutes response: ${response.data}');
      var res = ShowRouteResponse.fromJson(response.data);

      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Future<ShowRouteResponse> showRoutes({
  //   required List<String>? eventList,
  // }) async {
  //   try {
  //     final response = await responsePostMethod(
  //       endPoint: ApiConstants.showRoute,
  //       requestData: {"companyId": 1, "eventlist": eventList},
  //     ).onError((DioException error, stackTrace) {
  //       handleExceptionMessage(
  //           apiName: 'Show Routes API', response: error.response);
  //       return Future.error(DioExceptionHandler.fromDioError(error));
  //     });

  //     var res = ShowRouteResponse.fromJson(response.data);
  //     return res;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Response> addCustomer2({
    required Map<String, dynamic> model,
    File? adminProfilePicture,
    required String salesmanId,
  }) async {
    try {
      if (adminProfilePicture != null) {
        final customerPicture = await MultipartFile.fromFile(
          adminProfilePicture.path,
          filename: adminProfilePicture.path.split('/').last,
        );
        model['cutomerpicture'] = customerPicture;
      }

      final formData = FormData.fromMap(model);

      final response = await dio.postbycustom(
        ApiConstants.addCustomer,
        data: formData,
      );

      return response;
    } on DioException catch (error) {
      handleExceptionMessage(
        apiName: 'Add Customer',
        response: error.response,
      );

      throw DioExceptionHandler.fromDioError(error);
    } catch (error) {
      return Future.error(error);
    }
  }
  // Future<Response> addCustomer2({
  //   required Map<String, dynamic> model,
  //   required File adminProfilePicture,
  //   required String salesmanId,
  // }) async {
  //   try {
  //     final customerPicture = await MultipartFile.fromFile(
  //       adminProfilePicture.path,
  //       filename: adminProfilePicture.path.split('/').last,
  //     );
  //     model['cutomerpicture'] = customerPicture;

  //     final formData = FormData.fromMap(model);

  //     final response = await dio.postbycustom(
  //       ApiConstants.addCustomer,
  //       data: formData,
  //     );

  //     return response;
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //       apiName: 'Add Customer',
  //       response: error.response,
  //     );

  //     throw DioExceptionHandler.fromDioError(error);
  //   } catch (error) {
  //     return Future.error(error);
  //   }
  // }

  Future<LeadsForUpdatingData> fetchLeadsForUpdate(
    String? customerId,
  ) async {
    try {
      final response = await dio.postbycustom(
        ApiConstants.getLeadForUpdating,
        data: FormData.fromMap({
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
          "customer_id": customerId ?? ""
        }),
      );

      final parsedJson =
          response.data is String ? jsonDecode(response.data) : response.data;

      final leadsList = LeadsForUpdating.fromJson(parsedJson).data;
      try {
        return leadsList.firstWhere((lead) => lead.customerId == customerId);
      } catch (_) {
        return leadsList.first;
      }
    } on DioException catch (error) {
      handleExceptionMessage(
        apiName: 'Get Leads for Update',
        response: error.response,
      );

      throw DioExceptionHandler.fromDioError(error);
    } catch (error) {
      return Future.error(error);
    }
  }
  // Future<LeadsForUpdatingData> fetchLeadsForUpdate(
  //   String? customerId,
  // ) async {
  //   try {
  //     final response = await dio.postbycustom(
  //       ApiConstants.getLeadForUpdating,
  //       data: {
  //         "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //         "customer_id": customerId
  //       },
  //     );

  //     final parsedJson =
  //         response.data is String ? jsonDecode(response.data) : response.data;

  //     return LeadsForUpdating.fromJson(parsedJson).data.first;
  //   } on DioException catch (error) {
  //     handleExceptionMessage(
  //       apiName: 'Get Leads for Update',
  //       response: error.response,
  //     );

  //     throw DioExceptionHandler.fromDioError(error);
  //   } catch (error) {
  //     return Future.error(error);
  //   }
  // }
  Future<void> customerPayment({
    BuildContext? context,
    required String detail,
    required String orderId,
    required String paymentType,
    required double receivedAmount,
    String? checkDueDate = "",
    String? checkNumber = "",
    String? transactionDate = "",
    String? transactionId = "",
  }) async {
    // 1. Get the current timestamp
    String timestamp = DateTime.now().toIso8601String();

    // 2. Get the Sales ID (Assuming it is stored in SessionHelper like company_id)
    // If your sales ID variable is named differently (e.g., userId), change '.id' below.
    String salesId = SessionHelper.loginSavedData?.id?.toString() ?? "0"; 

    // 3. Generate the Unique ID
    String uniqueId = "${timestamp}_$salesId";

    final requestPayload = {
      "check_due_date": checkDueDate,
      "check_number": checkNumber,
      "detail": detail,
      "order_id": orderId,
      "payment_type": paymentType,
      "recieved_amount": receivedAmount,
      "transation_date": transactionDate,
      "transation_id": transactionId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      
      // ✅ Add the new fields here
      "sales_id": salesId,   // Ensure sales_id is in payload for your offline logic
      "unique_id": uniqueId, // The unique string you requested
    };

    // print('payment-type in api function:$paymentType');
    print('transactionId in api function:$transactionId');
    print('Generated Unique ID: $uniqueId'); // Debug print

    try {
      bool isOnline = await ConnectivityService().isOnline();

      if (!isOnline) {
        var box = await Hive.openBox('offlineRequests');
        await box.add({
          "url": '${ApiConstants.baseUrl}${ApiConstants.customerPayment}',
          "payload": requestPayload,
          "timestamp": timestamp, // Use the SAME timestamp we generated above
        });
        return;
      }

      final response = await dio1.post(
        '${ApiConstants.baseUrl}${ApiConstants.customerPayment}',
        data: requestPayload,
      );

      if (response.statusCode == 200) {
        showCustomToastDisplay(
            context!, "Payment successful", Colors.green, Icons.check);
      } else {
        showCustomToastDisplay(
            context!, "Payment failed", Colors.red, Icons.close);
      }
    } catch (error) {
      showCustomToastDisplay(
          context!, "Error in Payment : $error", Colors.red, Icons.close);
      if (error is DioException) {
        handleExceptionMessage(
            apiName: 'Customer Payment', response: error.response);
        throw DioExceptionHandler.fromDioError(error);
      } else {
        throw Exception('Unexpected error in customerPayment: $error');
      }
    }
  }

  // Future<void> customerPayment({
  //   BuildContext? context,
  //   required String detail,
  //   required String orderId,
  //   required String paymentType,
  //   required double receivedAmount,
  //   String? checkDueDate = "",
  //   String? checkNumber = "",
  //   String? transactionDate = "",
  //   String? transactionId = "",
  // }) async {
  //   final requestPayload = {
  //     "check_due_date": checkDueDate,
  //     "check_number": checkNumber,
  //     "detail": detail,
  //     "order_id": orderId,
  //     "payment_type": paymentType,
  //     "recieved_amount": receivedAmount,
  //     "transation_date": transactionDate,
  //     "transation_id": transactionId,
  //     "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
  //   };
  //   // print('payment-type in api function:$paymentType');
  //   print('transactionId in api function:$transactionId');
  //   try {
  //     bool isOnline = await ConnectivityService().isOnline();

  //     if (!isOnline) {
  //       var box = await Hive.openBox('offlineRequests');
  //       await box.add({
  //         "url": '${ApiConstants.baseUrl}${ApiConstants.customerPayment}',
  //         "payload": requestPayload,
  //         "timestamp": DateTime.now().toIso8601String(),
  //       });
  //       return;
  //     }

  //     final response = await dio1.post(
  //       '${ApiConstants.baseUrl}${ApiConstants.customerPayment}',
  //       data: requestPayload,
  //     );

  //     if (response.statusCode == 200) {
  //       showCustomToastDisplay(
  //           context!, "Payment successful", Colors.green, Icons.check);
  //     } else {
  //       showCustomToastDisplay(
  //           context!, "Payment failed", Colors.red, Icons.close);
  //     }
  //   } catch (error) {
  //     showCustomToastDisplay(
  //         context!, "Error in Payment : $error", Colors.red, Icons.close);
  //     if (error is DioException) {
  //       handleExceptionMessage(
  //           apiName: 'Customer Payment', response: error.response);
  //       throw DioExceptionHandler.fromDioError(error);
  //     } else {
  //       throw Exception('Unexpected error in customerPayment: $error');
  //     }
  //   }
  // }

  Future<ProductFrequencyResponse> getProductFrequency() async {
    try {
      final isConnected = await ConnectivityService().isOnline();
      final cacheKey =
          "${SessionHelper.loginSavedData?.company_id ?? 0}_product_frequency";

      final box = await Hive.openBox('productFrequencyBox');

      if (!isConnected) {
        final savedProductFrequency = box.get(cacheKey) as Map?;
        if (savedProductFrequency != null) {
          return ProductFrequencyResponse.fromJson(
            ApiService().castToStringDynamic(savedProductFrequency),
          );
        } else {
          throw Exception('No data available offline');
        }
      } else {
        final response = await responsePostMethod(
          requestData: {
            "companyId": SessionHelper.loginSavedData?.company_id ?? 0
          },
          endPoint: ApiConstants.getProductFrequency,
        );

        final productFrequency =
            ProductFrequencyResponse.fromJson(response.data);
        await box.put(cacheKey, productFrequency.toJson());

        return productFrequency;
      }
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Product Frequency',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch product frequency: $error');
    }
  }

  Future<List<PromotionReponse>> getPromotions() async {
    try {
      print('get promotions called');
      final isConnected = await ConnectivityService().isOnline();
      final cacheKey =
          "${SessionHelper.loginSavedData?.company_id ?? 0}_promotion_data";

      final box = await Hive.openBox('promotionsBox');

      if (!isConnected) {
        final savedPromotions = box.get(cacheKey) as List?;
        if (savedPromotions != null) {
          return List<PromotionReponse>.from(
            savedPromotions.map(
              (x) => PromotionReponse.fromJson(
                ApiService().castToStringDynamic(x),
              ),
            ),
          );
        } else {
          throw Exception('No data available offline');
        }
      } else {
        final response = await dio.getbycustom(
          ApiConstants.promotions,
          queryParameters: {
            "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
          },
        );
        log('promotions response: ${response.data}');

        final promotions = List<PromotionReponse>.from(
          response.data.map((x) => PromotionReponse.fromJson(x)),
        );

        await box.put(
          cacheKey,
          promotions.map((e) => e.toJson()).toList(),
        );

        return promotions;
      }
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Fetch Promotions',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch promotions data: $error');
    }
  }

  Future<List<ProductModel>> getProductByBrand(
    List<String> brandNames,
  ) async {
    final isConnected = await ConnectivityService().isOnline();

    if (isConnected) {
      try {
        final request = {
          "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
          "brand_names": brandNames,
        };

        final response = await dio.postbycustom(
          ApiConstants.fetchProductByBrand,
          data: request,
        );

        if (response.statusCode == 200) {
          final responseData = response.data;

          final productApiResponse = ProductApiResponse.fromJson(responseData);

          List<ProductModel> allProducts = [];
          for (var scidGroup in productApiResponse.data) {
            allProducts.addAll(scidGroup.products);
          }
          return allProducts;
        } else {
          return [];
        }
      } catch (e) {
        handleExceptionMessage(
          apiName: 'Get Product By Brand',
          response: e is DioException ? e.response : null,
        );
        return [];
      }
    } else {
      return [];
    }
  }

Future<GetRecentOrderReturn> getRecentOrdersReturns({
  SearchModel? searchModel,
  int? page,
  // New strict parameters
  required String valueFromDw,
  required List<String> selectedRange,
}) async {
  bool isConnected = await ConnectivityService().isOnline();

  // Update cache key to be unique based on the new filters
  final cacheKey = "${SessionHelper.loginSavedData?.company_id ?? 0}_sales_return_${valueFromDw}_${selectedRange.join('_')}_$page";
  final box = Hive.box('salesReturnBox');

  if (!isConnected) {
    final savedData = box.get(cacheKey);
    if (savedData != null && savedData is Map) {
      return GetRecentOrderReturn.fromJson(ApiService().castToStringDynamic(savedData));
    } else {
      throw Exception('No offline data available');
    }
  }

  // UPDATED PAYLOAD
  final response = await dio.postbycustom(
    ApiConstants.getRecentOrder,
    data: {
      "companyId": SessionHelper.loginSavedData?.company_id ?? 1,
      "limit": 10, // Updated to 1000 as per your payload
      "page": page ?? 1,
      "valueFromDw": valueFromDw,
      "selected_range": selectedRange,
      "order_status": 2,
    },
    
  ).onError((DioException error, _) {
    
    return Future.error(DioExceptionHandler.fromDioError(error));
  });
 print({
  "companyId": SessionHelper.loginSavedData?.company_id ?? 1,
  "limit": 10,
  "page": page ?? 1,
  "valueFromDw": valueFromDw,
  "selected_range": selectedRange,
  "order_status": 2,
});
  final responseJson = response.data as Map<String, dynamic>;
  await box.put(cacheKey, responseJson);

  return GetRecentOrderReturn.fromJson(responseJson);
}

  // Future<GetRecentOrderReturn> getRecentOrdersReturns({
  //   SearchModel? searchModel,
  //   int? page,
  //   // New strict parameters
  //   required String valueFromDw,
  //   required List<String> selectedRange,
  // }) async {
  //   print('api called');
  //   bool isConnected = await ConnectivityService().isOnline();

  //   // Update cache key to be unique based on the new filters
  //   final cacheKey =
  //       "${SessionHelper.loginSavedData?.company_id ?? 0}_sales_return_${valueFromDw}_${selectedRange.join('_')}_$page";
  //   final box = Hive.box('salesReturnBox');

  //   if (!isConnected) {
  //     final savedData = box.get(cacheKey);
  //     if (savedData != null && savedData is Map) {
  //       return GetRecentOrderReturn.fromJson(
  //           ApiService().castToStringDynamic(savedData));
  //     } else {
  //       throw Exception('No offline data available');
  //     }
  //   }

  //   // UPDATED PAYLOAD
  //   final response = await dio.postbycustom(
  //     ApiConstants.getRecentOrder,
  //     data: {
  //       "companyId": SessionHelper.loginSavedData?.company_id ?? 1,
  //       "limit": 10, // Updated to 1000 as per your payload
  //       "page": page ?? 1,
  //       "valueFromDw": valueFromDw,
  //       "selected_range": selectedRange,
  //       "order_status": 2,
  //     },
  //   ).onError((DioException error, _) {
  //     return Future.error(DioExceptionHandler.fromDioError(error));
  //   });

  //   final responseJson = response.data as Map<String, dynamic>;
  //   await box.put(cacheKey, responseJson);

  //   return GetRecentOrderReturn.fromJson(responseJson);
  // }


  Future<ProductReturn> getProductReturnDetails(
      {required String orderId}) async {
    if (orderId.isEmpty) throw Exception('orderId is required');

    bool isConnected = await ConnectivityService().isOnline();

    final String cacheKey =
        "${SessionHelper.loginSavedData?.company_id ?? 0}_return_details_$orderId";
    final box = Hive.box('productReturnDetailsBox');
    if (!isConnected) {
      final savedData = box.get(cacheKey);
      if (savedData != null && savedData is Map) {
        return ProductReturn.fromJson(
          ApiService().castToStringDynamic(savedData),
        );
      } else {
        throw Exception('No offline data available for order $orderId');
      }
    }
    final payload = {
      "companyId": 1,
      "order_id": orderId,
      "order_status": 2,
    };
    print('API Payload: $payload');
    final response = await dio
        .postbycustom(ApiConstants.getReturnOrderDetails, data: payload)
        .onError((DioException error, _) {
      return Future.error(DioExceptionHandler.fromDioError(error));
    });

    final responseJson = response.data as Map<String, dynamic>;
    await box.put(cacheKey, responseJson);
    final parsed = ProductReturn.fromJson(responseJson);
    // print('orderDataResponse:${parsed.data}');
    return parsed;
  }

  Future<Map<String, dynamic>> submitButtonTap({
    required String orderId,
    required String invoiceId,
    required String returnReason,
    required List<Map<String, dynamic>> returnItems,
    required String customerId,
    required String cartId,
    required String salesmanId,
    required String salesmanName,
    List<Map<String, dynamic>>? imageList,
  }) async {
    // -------------------------------------------------
    // 1. Validation
    // -------------------------------------------------
    if (orderId.isEmpty) throw Exception('orderId is required');
    if (invoiceId.isEmpty) throw Exception('invoiceId is required');
    if (returnItems.isEmpty) throw Exception('returnItems cannot be empty');

    // -------------------------------------------------
    // 2. Internet check
    // -------------------------------------------------
    bool isConnected = await ConnectivityService().isOnline();
    if (!isConnected) {
      throw Exception(
          'No internet connection. Return submission requires online access.');
    }

    // -------------------------------------------------
    // 3. Payload (all strings)
    // -------------------------------------------------
    final Map<String, dynamic> payload = {
      "order_id": orderId,
      "invoice_id": invoiceId,
      "company_id": "1",
      "customer_id": customerId,
      "cart_id": cartId,
      "return_reason": returnReason,
      "created_by_id": salesmanId,
      "created_by_name": salesmanName,
      "return_items": jsonEncode(returnItems),
    };
    if (imageList != null && imageList.isNotEmpty) {
      for (final imageData in imageList) {
        final clientKey = imageData['client_key'] as int;
        final file = imageData['file'] as File?;
        if (file != null) {
          payload['damage_image_$clientKey'] = await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          );
        }
      }
    }

    try {
      final formData = FormData.fromMap(payload);

      final response = await dio
          .postbycustom(
        ApiConstants.createSalesReturn, // e.g., "/create_sales_return1"
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      )
          .onError<DioException>((error, _) {
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      debugPrint(">>> API Response status: ${response.statusCode}");
      debugPrint(">>> API Response data: ${response.data}");

      if (response.statusCode == 200) {
        final responseJson = response.data as Map<String, dynamic>;
        return responseJson;
      } else {
        throw Exception("Failed with status ${response.statusCode}");
      }
    } on DioException catch (e) {
      debugPrint("DioException: ${e.message}");
      debugPrint("Dio Response: ${e.response?.data}");
      throw Exception("Dio error: ${e.message}");
    } catch (e) {
      debugPrint("Unknown Error: $e");
      throw Exception("Error: $e");
    }
  }

  Future<SearchResponse> searchInvoice({
    required String query,
    required String customerId,
    required String salesmanId,
  }) async {
    // Validation
    if (query.trim().isEmpty) throw Exception('Search query is required');
    if (customerId.isEmpty) throw Exception('customerId is required');
    if (salesmanId.isEmpty) throw Exception('salesmanId is required');

    // Check internet
    bool isConnected = await ConnectivityService().isOnline();
    if (!isConnected) {
      throw Exception('No internet connection. Search requires online access.');
    }

    // Payload
    final Map<String, dynamic> payload = {
      "company_id": 1,
      "search": query.trim(),
      "customer_id": customerId,
      "salesman_id": salesmanId,
    };
    dev.log('search invoice payload: $payload');
    // API Call
    final response = await dio
        .postbycustom(
      ApiConstants.SearchInvoice, // Add this constant to your ApiConstants
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    )
        .onError<DioException>((error, _) {
      return Future.error(DioExceptionHandler.fromDioError(error));
    });

    final responseJson = response.data as Map<String, dynamic>;
    dev.log('response by search: $responseJson');

    // Return parsed response
    return SearchResponse.fromJson(responseJson);
  }

  Future<ReturnInfo> fetchInforeturnData({
    required String cartId,
    required String companyId,
  }) async {
    // ------------------- 1. Validation -------------------
    if (cartId.trim().isEmpty) {
      throw Exception('cartId is required');
    }
    // if (companyId <= 0) {
    //   throw Exception('companyId must be a positive integer');
    // }

    // ------------------- 2. Internet check -------------------
    final bool isConnected = await ConnectivityService().isOnline();
    if (!isConnected) {
      throw Exception(
          'No internet connection. Fetching returns requires online access.');
    }

    // ------------------- 3. Payload -------------------
    final Map<String, dynamic> payload = {
      "cart_id": cartId.trim(),
      "companyId": companyId, // API expects int (e.g. 1)
    };

    // ------------------- 4. API Call -------------------
    final response = await dio
        .postbycustom(
      ApiConstants.GetPendingReturnsForCart, // <-- add this constant
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    )
        .onError<DioException>((error, _) {
      return Future.error(DioExceptionHandler.fromDioError(error));
    });

    final responseJson = response.data as Map<String, dynamic>;
    dev.log('Pending returns response: $responseJson');

    // ------------------- 5. Return parsed model -------------------
    return ReturnInfo.fromJson(responseJson);
  }

  Future<OnlinePaymentSession> createOnlinePaymentSession({
    required double amount,
    required String orderIds,
    // required String customerId,
    // required String companyId,
  }) async {
    final requestPayload = {
      "amount": amount,
      "isCents": false,
      "order_id": orderIds,
      "company_id": "1",
    };

    try {
      bool isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        final box = await Hive.openBox('offlineRequests');
        await box.add({
          "url": '${ApiConstants.baseUrl1}/create-checkout-session-product',
          // "url": 'https://test.thrivewoo.com/create-checkout-session-product',
          "method": "POST",
          "payload": requestPayload,
          "timestamp": DateTime.now().toIso8601String(),
          "type": "online_session_create",
        });
        throw Exception("Offline: Session creation queued");
      }

      final response = await dio1.post(
        '${ApiConstants.baseUrl1}/create-checkout-session-product',
        // 'https://test.thrivewoo.com/create-checkout-session-product',
        data: requestPayload,
      );

      print('response:$response');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OnlinePaymentSession.fromJson(response.data);
      } else {
        throw Exception("Session creation failed: ${response.statusMessage}");
      }
    } catch (error) {
      if (error is DioException) {
        handleExceptionMessage(
            apiName: 'Create Online Session', response: error.response);
      }
      rethrow;
    }
  }

  Future<OnlinePaymentVerifyResponse> verifyOnlinePaymentSession({
    required String sessionId,
    required String companyId,
  }) async {
    try {
      print("\n🌐 [API] ========== API CALL START ==========");
      print("🌐 [API] URL: ${ApiConstants.baseUrl}/verify-checkout-session");
      print("🌐 [API] session_id: $sessionId");
      print("🌐 [API] company_id: $companyId");

      final response = await dio1.get(
        '${ApiConstants.baseUrl1}/verify-checkout-session',
        // 'https://test.thrivewoo.com/verify-checkout-session',
        queryParameters: {
          'session_id': sessionId,
          'company_id': companyId,
        },
      );

      print("\n📡 [API] Response Status Code: ${response.statusCode}");
      print("📦 [API] Raw Response Data Type: ${response.data.runtimeType}");
      print("📦 [API] Raw Response Data: ${response.data}");

      if (response.statusCode == 200) {
        try {
          // Ensure response.data is a Map
          Map<String, dynamic> jsonData;

          if (response.data is Map<String, dynamic>) {
            jsonData = response.data;
          } else if (response.data is String) {
            print("⚠️ [API] Response is String, attempting to parse JSON...");
            jsonData = json.decode(response.data);
          } else {
            print(
                "❌ [API] Unexpected response type: ${response.data.runtimeType}");
            throw Exception("Invalid response format");
          }

          final result = OnlinePaymentVerifyResponse.fromJson(jsonData);
          print("\n✅ [API] Successfully parsed response:");
          print("   - paid: ${result.paid}");
          print("   - paymentStatus: ${result.paymentStatus}");
          print("   - paymentIntentId: ${result.paymentIntentId}");
          print("🌐 [API] ========== API CALL END ==========\n");
          return result;
        } catch (parseError, stackTrace) {
          print("\n❌ [API] JSON Parsing Error: $parseError");
          print("📚 [API] Stack Trace: $stackTrace");
          print("📄 [API] Failed to parse data: ${response.data}");
          print("🌐 [API] ========== API CALL END (ERROR) ==========\n");

          // Return pending status on parse error
          return OnlinePaymentVerifyResponse(
            paid: false,
            paymentStatus: 'error',
            metadata: {},
          );
        }
      } else {
        print("\n⚠️ [API] Non-200 Status Code: ${response.statusCode}");
        print("📄 [API] Response body: ${response.data}");
        print("🌐 [API] ========== API CALL END ==========\n");

        return OnlinePaymentVerifyResponse(
          paid: false,
          paymentStatus: 'pending',
          metadata: {},
        );
      }
    } on DioException catch (dioError) {
      print("\n❌ [API] DioException caught:");
      print("   Type: ${dioError.type}");
      print("   Message: ${dioError.message}");
      print("   Response Status: ${dioError.response?.statusCode}");
      print("   Response Data: ${dioError.response?.data}");

      // CRITICAL: Some APIs return success data even in error responses
      if (dioError.response?.data != null) {
        try {
          print("🔄 [API] Attempting to parse data from error response...");

          Map<String, dynamic> jsonData;
          if (dioError.response!.data is Map<String, dynamic>) {
            jsonData = dioError.response!.data;
          } else if (dioError.response!.data is String) {
            jsonData = json.decode(dioError.response!.data);
          } else {
            throw Exception("Cannot parse error response");
          }

          final result = OnlinePaymentVerifyResponse.fromJson(jsonData);
          print("✅ [API] Successfully parsed from error response!");
          print("🌐 [API] ========== API CALL END ==========\n");
          return result;
        } catch (e) {
          print("❌ [API] Failed to parse error response: $e");
        }
      }

      print("🌐 [API] ========== API CALL END (DIO ERROR) ==========\n");
      return OnlinePaymentVerifyResponse(
        paid: false,
        paymentStatus: 'pending',
        metadata: {},
      );
    } catch (e, stackTrace) {
      print("\n❌ [API] Unexpected Error: $e");
      print("📚 [API] Stack Trace: $stackTrace");
      print("🌐 [API] ========== API CALL END (UNEXPECTED ERROR) ==========\n");

      return OnlinePaymentVerifyResponse(
        paid: false,
        paymentStatus: 'pending',
        metadata: {},
      );
    }
  }
//   // In your ApiWorker class
// Future<OnlinePaymentVerifyResponse> verifyOnlinePaymentSession({
//   required String sessionId,
//   required String companyId,
// }) async {
//   try {
//     final response = await dio1.get(
//       '${ApiConstants.baseUrl}/verify-checkout-session',
//       queryParameters: {
//         'session_id': sessionId,
//         'company_id': companyId,
//       },
//     );

//     if (response.statusCode == 200) {
//       return OnlinePaymentVerifyResponse.fromJson(response.data);
//     } else {
//       // 404, 500, etc. → NOT an error → just "not paid yet"
//       return OnlinePaymentVerifyResponse(
//         paid: false,
//         paymentStatus: 'pending',
//         metadata: {},
//       );
//     }
//   } catch (e) {
//     // Network error, timeout → also "not paid yet"
//     return OnlinePaymentVerifyResponse(
//       paid: false,
//       paymentStatus: 'pending',
//       metadata: {},
//     );
//   }
// }
  // Future<OnlinePaymentVerifyResponse> verifyOnlinePaymentSession({
  //   required String sessionId,
  //   required String companyId,
  // }) async {
  //   try {
  //     final response = await dio1.get(
  //       '${ApiConstants.baseUrl}/verify-checkout-session',
  //       queryParameters: {
  //         'session_id': sessionId,
  //         'company_id': companyId,
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       return OnlinePaymentVerifyResponse.fromJson(response.data);
  //     }
  //     else {
  //     // For 404, 500, etc. → just return "not paid yet"
  //     print("Verify returned ${response.statusCode} → assuming not paid yet");
  //     return OnlinePaymentVerifyResponse(
  //       paid: false,
  //       paymentStatus: 'pending',
  //       metadata: {},
  //     );
  //   }

  //   } catch (error) {
  //     // Silent fail during polling is okay
  //    print("Verification poll error (will retry): $error");
  //   return OnlinePaymentVerifyResponse(
  //     paid: false,
  //     paymentStatus: 'pending',
  //     metadata: {},
  //   );
  //   }
  // }
// }
// Future<Bulk> getBulkVolumes() async {
//     // 1. Define a unique cache key based on company ID
//     final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
//     final String cacheKey = "${companyId}_bulk_volumes";
//     final String boxName = 'bulkVolumesBox';

//     try {
//       final isConnected = await ConnectivityService().isOnline();

//       if (isConnected) {
//         // --- ONLINE MODE ---
//         print('get bulk api called (Online)');

//         final response = await dio.postbycustom(
//           ApiConstants.getVolumes,
//           data: {
//             "company_id": companyId,
//           },
//         );

//         print('response status code in bulk: ${response.statusCode}');

//         if (response.statusCode == 200) {
//           final responseData = response.data;
          
//           // 1. Parse Data
//           final bulk = Bulk.fromJson(responseData);

//           // 2. Cache Data (Save the JSON/Map to Hive)
//           await _cacheBulkData(boxName, cacheKey, responseData);

//           print('bulk volumes fetched and cached successfully');
//           return bulk;
//         } else {
//           // If API fails but we are "connected", you might want to try fallback or throw
//           throw Exception('Failed to load bulk volumes: ${response.statusCode}');
//         }
//       } else {
//         // --- OFFLINE MODE ---
//         print('Device is offline. Attempting to load Bulk from cache...');
//         return await _loadCachedBulkData(boxName, cacheKey);
//       }
//     } catch (error) {
//       // If API fails (e.g. server error), try falling back to cache
//       print('Error occurred: $error. Attempting fallback to cache...');
//       try {
//         return await _loadCachedBulkData(boxName, cacheKey);
//       } catch (cacheError) {
//         // If cache also fails, handle the original exception
//         handleExceptionMessage(
//           apiName: 'Fetch Bulk Volumes',
//           response: error is DioException ? error.response : null,
//         );
//         throw Exception('Failed to fetch bulk volumes (Online & Offline failed)');
//       }
//     }
//   }
Future<Bulk> getBulkVolumes() async {
    // 1. Setup Keys
    final int companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final String cacheKey = "${companyId}_bulk_volumes";
    final String boxName = 'bulkVolumesBox';

    try {
      final isConnected = await ConnectivityService().isOnline();

      if (isConnected) {
        // --- ONLINE MODE ---
        print('Attempting Online Fetch...');
        
        final response = await dio.postbycustom(
          ApiConstants.getVolumes,
          data: {"company_id": companyId},
        );
        log('reposne of bulk item:${response.data}');

        if (response.statusCode == 200) {
          try {
            // A. Try Parsing
            print('API Success. Parsing data...');
            final bulk = Bulk.fromJson(response.data);

            // B. Save to Cache (Only if parsing works)
            await _cacheBulkData(boxName, cacheKey, response.data);
            
            return bulk;
          } catch (e) {
            print('CRITICAL: JSON Parsing Failed! Check your Bulk.fromJson model.');
            print('Error: $e');
            // If parsing fails, we throw to trigger the offline fallback
            throw Exception('JSON Parsing Error: $e');
          }
        } else {
          throw Exception('API returned status: ${response.statusCode}');
        }
      } else {
        // --- OFFLINE MODE (No Internet) ---
        print('No Internet. Loading from cache...');
        return await _loadCachedBulkData(boxName, cacheKey);
      }

    } catch (e) {
      // --- FALLBACK (API Failed or Parsing Failed) ---
      print('Online fetch failed ($e). Attempting fallback to cache...');

      try {
        return await _loadCachedBulkData(boxName, cacheKey);
      } catch (cacheError) {
        // Both failed.
        print('Cache also failed or is empty: $cacheError');
        
        // OPTIONAL: Return an empty object instead of throwing error
        // return Bulk(data: []); // Uncomment if you have an empty constructor
        
        throw Exception('Failed to fetch bulk volumes (Online & Offline failed)');
      }
    }
  }

  // --- Helper: Cache the data ---
  Future<void> _cacheBulkData(String boxName, String key, dynamic json) async {
    try {
      late Box box;
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box(boxName);
      } else {
        box = await Hive.openBox(boxName);
      }
      await box.put(key, json);
      print('Bulk data cached for key: $key');
    } catch (e) {
      print('Failed to cache bulk data: $e');
    }
  }

  // --- Helper: Load from Cache ---


// ... inside your class ...

Future<Bulk> _loadCachedBulkData(String boxName, String key) async {
  try {
    late Box box;
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box(boxName);
    } else {
      box = await Hive.openBox(boxName);
    }

    final cachedData = box.get(key);

    if (cachedData != null) {
      print('Cache hit for $key. Processing data...');

      // --- THE FIX ---
      // Hive returns Map<dynamic, dynamic>.
      // We encode it to String and decode it back to JSON.
      // This cleans up all nested Map types to Map<String, dynamic>.
      final jsonString = json.encode(cachedData);
      final Map<String, dynamic> cleanJson = json.decode(jsonString);

      return Bulk.fromJson(cleanJson);
    } else {
      print('Cache miss: No data found for key $key');
      throw Exception('No offline data available');
    }
  } catch (e) {
    print('Error loading cached bulk data: $e');
    throw e;
  }
}

  // Future<void> _cacheBulkData(String boxName, String key, dynamic json) async {
  //   try {
  //     final box = await Hive.openBox(boxName);
  //     await box.put(key, json);
  //     print('Saved to Hive: $boxName / $key');
  //   } catch (e) {
  //     print('Failed to save cache: $e');
  //   }
  // }
  // Future<Bulk> _loadCachedBulkData(String boxName, String key) async {
  //   try {
  //     late Box box;
  //     if (Hive.isBoxOpen(boxName)) {
  //       box = Hive.box(boxName);
  //     } else {
  //       box = await Hive.openBox(boxName);
  //     }

  //     final cachedData = box.get(key);

  //     if (cachedData != null) {
  //       print('Found cached bulk data for key: $key');
  //       // Convert the cached JSON Map back into your Bulk model
  //       // Ensure cachedData is cast to Map<String, dynamic> if Hive stored it as generic Map
  //       final jsonMap = Map<String, dynamic>.from(cachedData as Map);
  //       return Bulk.fromJson(jsonMap);
  //     } else {
  //       print('No cached bulk data found.');
  //       // Return an empty Bulk object or throw specific error based on your app logic
  //       // Assuming Bulk has an empty constructor or you can return null
  //       throw Exception('No offline data available');
  //     }
  //   } catch (e) {
  //     print('Error loading cached bulk data: $e');
  //     throw e;
  //   }
  // }
  // Future<Bulk> getBulkVolumes() async {
  //   try {
  //     print('get bulk api called');

  //     final isConnected = await ConnectivityService().isOnline();
  //     final cacheKey =
  //         "${SessionHelper.loginSavedData?.company_id ?? 0}_bulk_volumes";

  //     // You can keep offline caching later — for now let's focus on making the request work

  //     // ONLINE MODE - POST with body
  //     final response = await dio.postbycustom(
  //       ApiConstants.getVolumes, // "get-volumes"
  //       data: {
  //         // ← Send as JSON body
  //         "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
  //       },
  //       // queryParameters: null,  // ← remove or leave empty
  //     );

  //     print('response status code in bulk: ${response.statusCode}');
  //     log('response data: ${response.data}'); // ← very useful for debugging

  //     final bulk = Bulk.fromJson(response.data);

  //     print('bulk volumes fetched successfully');

  //     // Cache the response (uncomment when ready)
  //     // final box = await Hive.openBox('bulkVolumesBox');
  //     // await box.put(cacheKey, bulk.toJson());

  //     return bulk;
  //   } catch (error) {
  //     handleExceptionMessage(
  //       apiName: 'Fetch Bulk Volumes',
  //       response: error is DioException ? error.response : null,
  //     );

  //     // Optional: print more details about the error
  //     if (error is DioException) {
  //       print('Dio error details:');
  //       print('Status: ${error.response?.statusCode}');
  //       print('Response data: ${error.response?.data}');
  //       print('Message: ${error.message}');
  //     }

  //     throw Exception('Failed to fetch bulk volumes: $error');
  //   }
  // }

  Future<CalendarSalesmanResponse> fetchSalesmanOfCustomer(
    String salesmanId,
  ) async {
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.fetchSalesmanOfCustomer,
        requestData: {
          "salesman_id": salesmanId,
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
        },
      );

      return CalendarSalesmanResponse.fromJson(response.data);
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Fetch Salesman Of Customer',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch salesman of customer: $error');
    }
  }

  Future<ButtonAction> orderAccept({
    String? orderId,
    List<dynamic>? updatedOrders,
  }) async {
    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.orderAcceptDirect,
        requestData: {
          "order_id": orderId,
          "updatedOrders": updatedOrders,
          "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
          "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      return ButtonAction.fromJson(response.data);
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: 'Order Accept Direct', response: error.response);

      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (e) {
      return Future.error(Exception("Unexpected error: $e"));
    }
  }

  Future<ButtonAction> orderReject({
    String? orderId,
    String? rejectReason,
  }) async {
    final request = {
      "order_id": orderId,
      "rejection_reason": rejectReason,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
    };

    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.orderReject,
        requestData: request,
      );

      return ButtonAction.fromJson(response.data);
    } on DioException catch (error) {
      handleExceptionMessage(apiName: 'Order Reject', response: error.response);

      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (e) {
      return Future.error(Exception("Unexpected error: $e"));
    }
  }

  Future<Response> packedAndReadyAdd({
    String? cartId,
    String? orderId,
  }) async {
    final requestData = {
      "cart_id": cartId,
      "order_id": orderId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
    };

    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.addInvoice,
        requestData: requestData,
      );

      return response;
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: 'Packed and Ready Add', response: error.response);

      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (e) {
      return Future.error(Exception("Unexpected error: $e"));
    }
  }

  Future<ButtonAction> orderDeliver({
    String? orderId,
  }) async {
    final requestData = {
      "order_id": orderId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 0,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
    };

    try {
      final response = await responsePostMethod(
        endPoint: ApiConstants.orderDelivered,
        requestData: requestData,
      );

      return ButtonAction.fromJson(response.data);
    } on DioException catch (error) {
      handleExceptionMessage(
          apiName: 'Order Deliver', response: error.response);

      return Future.error(DioExceptionHandler.fromDioError(error));
    } catch (e) {
      return Future.error(Exception("Unexpected error: $e"));
    }
  }

  Future<StaffDiscount> getStaffDiscount() async {
    try {
      // print('getstaffdiscount called');
      final isConnected = await ConnectivityService().isOnline();
      final cacheKey =
          "${SessionHelper.loginSavedData?.company_id ?? 0}_staff_discount";

      final box = await Hive.openBox('staffDiscountBox');

      if (!isConnected) {
        final cachedData = box.get(cacheKey);

        if (cachedData != null) {
          return StaffDiscount.fromJson(cachedData
              // ApiService().castToStringDynamic(cachedData),
              );
        } else {
          throw Exception('No staff discount data available offline');
        }
      }

      // 🔹 ONLINE MODE
      final response = await dio.postbycustom(
        ApiConstants.staffDiscount,
        queryParameters: {
          "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
        },
      );

      final staffDiscount = StaffDiscount.fromJson(response.data);

      print('staffdiscount:$staffDiscount');

      // 🔹 CACHE DATA
      await box.put(cacheKey, staffDiscount.toJson());

      return staffDiscount;
    } catch (error) {
      handleExceptionMessage(
        apiName: 'Fetch Staff Discount',
        response: error is DioException ? error.response : null,
      );
      throw Exception('Failed to fetch staff discount data: $error');
    }
  }

// Inside ApiWorker class

  Future<Map<String, dynamic>?> fetchVisitReportData({
    required String startDate,
    required String endDate,
  }) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

    // Unique cache key including the date range
    final cacheKey =
        'visitReport_${companyId}_${salesmanId}_${startDate}_$endDate';
    final box = Hive.box('topBarDataBox');

    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        // payload matching your exact requirement
        final requestPayload = {
          "salesman_id": salesmanId,
          "start_date": startDate, // "2026-02-01"
          "end_date": endDate, // "2026-02-28"
          "company_id": companyId
        };

        // CHANGE THIS to your actual endpoint

        Response response = await responsePostMethod(
            requestData: requestPayload, endPoint: ApiConstants.visitReport);
        log('response of the event:${response.data}');

        if (response.statusCode == 200) {
          final data = Map<String, dynamic>.from(response.data as Map);
          await box.put(cacheKey, data);
          return data;
        } else {
          handleExceptionMessage(response: response, apiName: "visit report");
          return null;
        }
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "visit report", error: error);
        return null;
      }
    } else {
      // Offline logic (optional)
      final cachedData = box.get(cacheKey);
      return cachedData != null
          ? Map<String, dynamic>.from(
              LocalStorage().castToStringDynamic(cachedData))
          : null;
    }
  }

// Add this inside your API Worker class
  Future<List<CustomerEventModel>?> fetchCustomerEventsData({
    required String eventIds,
  }) async {
    // 1. Setup Cache Key
    final cacheKey = 'customer_events_$eventIds';
    final box = Hive.box('topBarDataBox'); // Using your existing box

    bool isOnline = await ConnectivityService().isOnline();

    if (isOnline) {
      try {
        // 2. Prepare Payload
        final requestPayload = {'event_id': eventIds};

        // 3. Call API using your wrapper (Dio)
        // Replace 'get_events' with ApiConstants.getEvents if you have it
        Response response = await responsePostMethod(
          requestData: requestPayload,
          endPoint: ApiConstants.getEvents,
        );

        if (response.statusCode == 200) {
          // Dio automatically decodes JSON to Map/List
          final jsonResponse = response.data;

          if (jsonResponse['status'] == true) {
            final List<dynamic> rawData = jsonResponse['data'];

            // 4. Save to Hive Cache
            await box.put(cacheKey, rawData);

            // 5. Convert to Model List and Return
            return rawData.map((e) => CustomerEventModel.fromJson(e)).toList();
          }
        }

        // Handle unsuccessful status
        handleExceptionMessage(response: response, apiName: "get_events");
        return null;
      } on DioException catch (error) {
        handleExceptionMessage(
            response: error.response, apiName: "get_events", error: error);
        return null;
      }
    } else {
      // --- Offline Logic ---
      if (box.containsKey(cacheKey)) {
        final cachedData = box.get(cacheKey);
        // Cast cached data back to List
        if (cachedData is List) {
          // Use LocalStorage helper if needed, or map directly
          return cachedData
              .map((e) =>
                  CustomerEventModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return null;
    }
  }
  Future<String> getCompanyActiveLanguage() async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final requestUrl = '${ApiConstants.baseUrl1}/Companydetails_GET?company_id=$companyId';
    final isConnected = await ConnectivityService().isOnline();

    // 1. If offline, return the last saved language from SharedPreferences
    if (!isConnected) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language') ?? 'en'; 
    }

    // 2. If online, fetch from API
    try {
      final response = await dio.getbycustom(requestUrl); // Use your existing Dio setup
      
      if (response.data == null) {
        throw Exception("API returned empty data");
      }

      // Check if data exists and safely extract just the active_language
      if (response.data['status'] == true && response.data['data'] != null) {
        String activeLanguage = response.data['data']['active_language'] ?? 'en';
        return activeLanguage;
      }
      
      return 'en'; // Default fallback

    } catch (e) {
      print("Error fetching active language: $e");
      // Fallback to local storage on error
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language') ?? 'en';
    }
  }
}
