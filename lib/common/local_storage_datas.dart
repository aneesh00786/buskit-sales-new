import 'dart:developer';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  storedCustomerData(Box<dynamic> customerBox) {
    final cachedData = customerBox.get('fetchCustomerData');
    if (cachedData != null) {
      final castedData = castToStringDynamic(cachedData);
      List<CustomerModelxx> customers = [];
      List<OrderTotalxx> orderTotal = [];
      List<YearsListOfAll> yearList = [];
      if (castedData['data'] is List) {
        customers = (castedData['data'] as List)
            .map((json) => CustomerModelxx.fromJson(json))
            .toList();
      }
      if (castedData['orderTotal'] is List) {
        orderTotal = (castedData['orderTotal'] as List)
            .map((json) => OrderTotalxx.fromJson(json))
            .toList();
      }
      if (castedData['yearsListOfAll'] is List) {
        yearList = (castedData['yearsListOfAll'] as List)
            .map((json) => YearsListOfAll.fromJson(json))
            .toList();
      }
      return CustomerResponseModelxx(
        statusCode: castedData['statusCode'] ?? 0,
        status: castedData['status'] ?? false,
        message: castedData['message'] ?? '',
        data: customers,
        orderTotal: orderTotal,
        pagination: Paginationxx.fromJson(castedData['pagination'] ?? {}),
        yearsListOfAll: yearList,
      );
    } else {
      throw Exception('No cached data available');
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

  storedDashboardData(Box<dynamic> dashboardBox) {
    final cachedData = dashboardBox.get('dashboardData');
    if (cachedData != null) {
      try {
        if (cachedData is Map) {
          final safeCachedData =
              castToStringDynamic(Map<dynamic, dynamic>.from(cachedData));
          return mapJsonToResponseModel(safeCachedData);
        } else {
          throw Exception('Invalid cached data format.');
        }
      } catch (e) {
        throw Exception('Failed to process cached data due to type mismatch.');
      }
    } else {
      throw Exception('No cached data available.');
    }
  }

  ResponseModell mapJsonToResponseModel(Map<String, dynamic> jsonResponse) {
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

  storedPendingPaymentData(Box<dynamic> pendingPaymentBox, String cacheKey) {
    final cachedData = pendingPaymentBox.get(cacheKey);

    if (cachedData != null) {
      log('Cached data found: $cachedData');
      return PendingPaymentResponse.fromJson(
          LocalStorage().castToStringDynamic(cachedData));
    } else {
      throw Exception('API error occurred, and no cached data is available.');
    }
  }

  LeadResponce storedLeadsData(Box<dynamic> leadsBox, String cacheKey) {
    final cachedData = leadsBox.get(cacheKey);
    if (cachedData != null) {
      log('Cached data found: $cachedData');
      return LeadResponce.fromJson(
          LocalStorage().castToStringDynamic(cachedData));
    } else {
      throw Exception('API error occurred, and no cached data is available.');
    }
  }

  Future<void> storeCustomerData(CustomerAndOrderResponce customerData) async {
    final box = await Hive.openBox('customerBox');
    await box.put('customerData', customerData.toJson());
    log('Customer data stored in Hive');
  }

}
