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
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/product_ui/product_responce/product_responce_temp.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../common/pagination_model.dart';
import '../ui/view/ui/auth/auth_model/login_responce.dart';

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

  // Future<StaffResponce> getSingleSaleManData(String salesmanId) async {
  //   Map<String, dynamic> data = {
  //     'salesman_id': salesmanId,
  //   };
  //   final response = await dio
  //       .postbycustom(
  //     ApiConstants.fetch_on_salesman,
  //     data: data,
  //   )
  //       .onError((DioError error, stackTrace) {
  //     log(error.toString());
  //     return Future.error(throw DioExceptionHandler.fromDioError(error));
  //   });
  //   return StaffResponce.fromJson(response.data);
  // }
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
      // log("Response status of Customer Fetching: ${response.statusCode}");
      // log("Response data: ${response.data}");
      return CustomerAndOrderResponce.fromJson(response.data);
    } catch (error) {
      // log("Error fetching customer data: $error");
      return Future.error('Failed to fetch customer data: $error');
    }
  }
/*  Future<CustomerAndOrderResponce> getCustomer({String? salesManId,
    SearchModel? searchData,
    String? customerId,
    PaginationModel? paginationModel,
  }) async {
    print("salesManId>>>>>${salesManId}");
    print("data post ++ ++${salesManId} : ${customerId ?? ''} : ${searchModel?.startDate} : ${searchModel?.endDate} : ${paginationModel?.limit.toString()} : ${paginationModel?.currentPage.toString()}");

    final response = await dio
        .postbycustom(ApiConstants.fetchcustomer,
        data: FormData.fromMap({
          "salesman_id": salesManId,
          "customer_name": searchData?.searchText??'',
          "start_date": searchData?.startDate ?? '',
          "end_date": searchData?.endDate ?? '',
          "page": paginationModel?.currentPage,
          "limit": paginationModel?.limit,
        }))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });

    return CustomerAndOrderResponce.fromJson(response.data);
  }*/

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
    // log("Send DATA: ${FormData.fromMap(sendData).fields}");
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
  // log("Send DATA: ${FormData.fromMap(sendData).fields}");
  // log("Send DATA: $sendData");
  try {
    final response = await dio.postbycustom(
      ApiConstants.add_to_cart,
      data: FormData.fromMap(sendData),
    ).onError((DioError error, stackTrace) {
      // log('Dio Error: ${error.response?.data}');
      return Future.error(DioExceptionHandler.fromDioError(error));
    });
    // log('Cart Response Status: ${response.statusCode}');
    // log('Cart Response: ${response.data}');

    if (response.statusCode == 200) {
      if (response.data['cart_id'] == null) {
        // log('Cart ID is null in response data: ${response.data}');
        return null;
      }
      final cartOrder = CartOrderModel.fromJson(response.data);
      // log('Parsed CartOrder: ${cartOrder}');
      return cartOrder;
    } else {
      // log('Unexpected Response: ${response.data}');
      return null;
    }
  } catch (e) {
    // log('Error on adding to cart: $e');
    return null;
  }
}





  Future<Response> deleteCartItem(String cartId, String variationId) async {
    // log("Send DATA: ${FormData.fromMap({
    //       "cart_id": cartId,
    //       "variation_id": variationId
    //     }).fields}");
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
  // Future<CategoryModel> getCategory() async {
  //   final jsonString = await SessionManager.getStringValue(SpString.spLogin);
  //   Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  //   int companyId = jsonMap['company_id'];
  //   log('$companyId');
  //   final response =
  //       await dio.getbycustom(ApiConstants.fetchcategories, queryParameters: {
  //     "company_id": companyId,
  //   }).onError((DioError error, stackTrace) {
  //     log(error.toString());
  //     return Future.error(throw DioExceptionHandler.fromDioError(error));
  //   });

  //   return CategoryModel.fromJson(response.data);
  // }

  //

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

  /// ******************** CALENDAR SECTION ******************/
  Future<AllCalenderEvent> getCalendarEvents(
      Map<String, dynamic> sendData) async {
    final response = await dio
        .postbycustom(ApiConstants.fetch_on_salesman,
            data: FormData.fromMap(sendData))
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return AllCalenderEvent.fromJson(response.data);
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

  // Future<AllCalenderEvent> getTodayScheduled(
  //     Map<String, dynamic> sendData) async {
  //   final response = await dio
  //       .postbycustom(ApiConstants.fetch_schedule_customer,
  //           showErrorSnakBar: false, data: FormData.fromMap(sendData))
  //       .onError((DioError error, stackTrace) {
  //     log(error.toString());
  //     return Future.error(throw DioExceptionHandler.fromDioError(error,
  //         showErrorSnakBar: false));
  //   });
  //   return AllCalenderEvent.fromJson(response.data);
  // }

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
////
//   Future<OrderResponce> getOrdersData(
//       {String? customerId,
//       String? salesmanId,
//       SearchModel? searchModel,
//       PaginationModel? paginationModel}) async {
//     final response = await dio
//         .postbycustom(
//       ApiConstants.fetch_order,
//       data: FormData.fromMap({
//         "salesman_id": salesmanId,
//         "customer_id": customerId,
//         "start_date": searchModel?.startDate ?? '',
//         "end_date": searchModel?.endDate ?? '',
//         "limit": paginationModel?.limit.toString() ?? '',
//         "page": paginationModel?.currentPage.toString() ?? ''
//       }),
//     )
//         .onError((DioError error, stackTrace) {
//       log(error.toString());
//       return Future.error(throw DioExceptionHandler.fromDioError(error));
//     });
//     return OrderResponce.fromJson(response.data);
//   }

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
        "start_date": '2024-10-01',
        //searchModel?.startDate ?? ,
        "end_date": "2024-10-30",
        //searchModel?.endDate ?? '',
      }),
    )
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OptionOrderResponce.fromJson(response.data);
  }

  /// ******************** PENDING PAYMENT ******************/
  Future<OrderResponce> getPendingPaymentData(String salesmanId,
      {SearchModel? searchModel, PaginationModel? paginationModel}) async {
    final response = await dio
        .postbycustom(
      ApiConstants.fetch_pending_payments,
      data: FormData.fromMap({
        "start_date": searchModel?.startDate ?? '',
        "end_date": searchModel?.endDate ?? '',
        "limit": paginationModel?.limit.toString() ?? '',
        "page": paginationModel?.currentPage.toString() ?? '',
        "salesman_id": "",
      }),
    )
        .onError((DioError error, stackTrace) {
      log(error.toString());
      return Future.error(throw DioExceptionHandler.fromDioError(error));
    });
    return OrderResponce.fromJson(response.data);
  }
}
