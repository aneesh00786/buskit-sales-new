import 'dart:convert';
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/cart_data_model.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/option/model/option_order_responce.dart';
import 'package:busskit_salesexecutive/ui/components/search/search_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/today_tasks_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_dashboard_total_sale_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_action_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_responce/product_responce_temp.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../common/pagination_model.dart';
import '../ui/view/ui/auth/auth_model/login_responce.dart';
import '../ui/view/ui/customer_and_orders/csord_model/recent_count_response.dart';

class ApiWorker with ApiConstants {
  late DioClient dio;

  ApiWorker() {
    dio = DioClient();
  }

  Future<LoginResponce> loginApi(String email, String password) async {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };
    final response = await dio
        .postbycustom(
      ApiConstants.login,
      data: data,
    )
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return LoginResponce.fromJson(response.data);
  }

  /// ************************ DASHBOARD SECTION ***************** ///

  Future<DashboardResponse> dashboardData() async {
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
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
      final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
      final jsonString = await SessionManager.getStringValue(SpString.spLogin);
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      int companyId = jsonMap['company_id'];
      final response = await dio.postbycustom(
        ApiConstants.fetchcustomer,
        data: FormData.fromMap({
          "company_id": companyId,
          "salesman_id": salesmanId,
        }),
      );
      return CustomerAndOrderResponce.fromJson(response.data);
    } catch (error) {
      return Future.error(
          'Failed to fetch customer data From API Worker: $error');
    }
  }

  Future<RecentOrderCountResponse> fetchRecentOrderCount() async {
    final response = await dio
        .getbycustom(
      ApiConstants.recent_order_count,
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
    return RecentOrderCountResponse.fromJson(response.data);
  }

  Future<CustomerDashboardResponse> getCustomerDashboard(
    String customerId,
  ) async {
    final response = await dio
        .postbycustom(ApiConstants.customer_dashboard_list,
            data: FormData.fromMap({
              "customer_id": customerId,
            }))
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
    log('${sendData}');
    try {
      final response = await dio
          .postbycustom(
        ApiConstants.add_to_cart,
        data: FormData.fromMap(sendData),
      )
          .onError((DioError error, stackTrace) {
        return Future.error(DioExceptionHandler.fromDioError(error));
      });

      if (response.statusCode == 200) {
        if (response.data['cart_id'] == null) {
          return null;
        }
        final cartOrder = CartOrderModel.fromJson(response.data);
        return cartOrder;
      } else {
        return null;
      }
    } catch (e) {
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
            data: FormData.fromMap({"customer_id": customerId}))
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
            data: FormData.fromMap({"customer_id": customerId}))
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

  Future<Response> setPaymentDetails(Map<String, dynamic> sendData) async {
    log("Send DATA: ${FormData.fromMap(sendData).fields}");
    final response = await dio
        .postbycustom(ApiConstants.payment_add_detail,
            data: FormData.fromMap(sendData))
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
      final savedCategory = box.get('categoryItem') as CategoryModel?;
      if (savedCategory != null) {
        return savedCategory;
      } else {
        throw Exception('No data available offline');
      }
    } else {
      final jsonString = await SessionManager.getStringValue(SpString.spLogin);
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      int companyId = jsonMap['company_id'];
      log('$companyId');
      final response = await dio.getbycustom(ApiConstants.fetchcategories,
          queryParameters: {
            "company_id": companyId
          }).onError((DioError error, stackTrace) {
        log(error.toString());
        return Future.error(DioExceptionHandler.fromDioError(error));
      });
      final category = CategoryModel.fromJson(response.data);
      final box = await Hive.openBox('categoriesBox');
      await box.put('categoryData', category);

      return category;
    }
  }
  /// ************************ PRODUCT SECTION ***************** ///
  Future<List<ProductModel>> getTempProduct(String subCatId) async {
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    int companyId = jsonMap['company_id'];
    log('Company ID: $companyId');
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    bool hasInternet = !connectivityResult.contains(ConnectivityResult.none);
    log('Has Internet: $hasInternet');
    if (hasInternet) {
      try {
        final response = await dio.getbycustom(ApiConstants.fetchproduct,
            queryParameters: {"company_id": companyId, "sub_catid": subCatId});
        if (response.statusCode == 200) {
          final responseData = response.data;
          log('Response Data: $responseData');
          if (responseData['data'] is List) {
            List<ProductModel> productList = [];
            for (var item in responseData['data']) {
              if (item['product'] is List) {
                List<dynamic> productsJsonList = item['product'];
                productList.addAll(productsJsonList
                    .map((productJson) => ProductModel.fromJson(productJson))
                    .toList());
              }
            }

            log('Fetched Products: ${productList.length}');
            var productBox = Hive.isBoxOpen('products')
                ? Hive.box<ProductModel>('products')
                : await Hive.openBox<ProductModel>('products');
            log('The box Values ${productBox.values.length}');
            await productBox.clear();
            log('Hive box cleared');
            await productBox.addAll(productList);
            log('Added new products to Hive');

            return productList;
          } else {
            log("Unexpected response format: 'data' is not a list");
            return [];
          }
        } else {
          log("Failed to load products, status code: ${response.statusCode}");
          return [];
        }
      } catch (e) {
        log("Error fetching products: $e");
        return [];
      }
    } else {
      // Load products from local storage (Hive) when offline
      var productBox = Hive.box<ProductModel>('products');
      if (productBox.isNotEmpty) {
        List<ProductModel> offlineProducts = productBox.values.toList();
        log("Loaded products from local storage");
        return offlineProducts;
      } else {
        log("No products available offline");
        return [];
      }
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
    final response = await dio
        .postbycustom(ApiConstants.fetch_leads,
            data: FormData.fromMap({
              "page": paginationModel?.currentPage ?? "",
              "limit": paginationModel?.limit ?? '',
              "salesman_id": salesManId
            }))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return LeadResponce.fromJson(response.data);
  }

  Future<LeadResponce> getLeadsRejectedData(
      {PaginationModel? paginationModel}) async {
    final response = await dio
        .postbycustom(ApiConstants.fetch_leads_reject,
            data: FormData.fromMap({
              "page": paginationModel?.currentPage ?? "",
              "limit": paginationModel?.limit ?? '',
              "salesman_id": ""
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
            data: FormData.fromMap(
                {"customer_id": customerId, "status": statusResponce}))
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
  }) async {
    final requestData = {
      "chart_index": chartIndex,
      "start_date": searchModel?.startDate,
      "end_date": searchModel?.endDate,
      "limit": paginationModel?.limit.toString() ?? '',
      "page": paginationModel?.currentPage.toString() ?? '',
      "salesman_id": salesmanId,
    };

    log("Sending request with data: $requestData");

    final response = await dio
        .postbycustom(
      ApiConstants.fetch_pending_payments,
      data: FormData.fromMap(requestData),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return PendingPaymentResponse.fromJson(response.data);
  }

  Future<IndividualPendingPaymentResponse> getAllPendingPaymentIndividual(
      {String? customerId}) async {
    final response = await dio
        .postbycustom(
      ApiConstants.get_all_pending_payment_individual,
      data: FormData.fromMap({
        "customer_id": customerId,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return IndividualPendingPaymentResponse.fromJson(response.data);
  }

  //************************RECENT ORDERS **************/
  Future<OrderCountResponse> getOrderCountData({
    SearchModel? searchModel,
  }) async {
    print(
        "startDate++1234++${searchModel?.startDate ?? ''}:${searchModel?.endDate ?? ''}");
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    int companyId = jsonMap['company_id'];
    final response = await dio
        .postbycustom(
      ApiConstants.orders_count_get,
      data: FormData.fromMap({
        "start_date": searchModel?.startDate,
        "end_date": searchModel?.endDate,
        "companyId":companyId,
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
    int? order_status,
  }) async {
    log(
        "startDate++1234++${searchModel?.startDate ?? ''}:${searchModel?.endDate ?? ''} :${order_status}");
    final response = await dio
        .postbycustom(
      ApiConstants.get_recent_order,
      data: FormData.fromMap({
        "order_status": order_status,
        "start_date": searchModel?.startDate,
        "end_date": searchModel?.endDate,
        "companyId": 1,
      }),
    )
        .onError((DioException error, stackTrace) {
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
        //added
        "companyId": 1,
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
        //added
        "companyId": 1,
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
        //added
        "companyId": 1,
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
        "companyId": 1,
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
          "companyId": 1,
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
          "companyId": 1,
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
        "companyId": 1,
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
        "companyId": 1,
      }),
    )
        .onError((DioException error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return ButtonAction.fromJson(response.data);
  }
}
