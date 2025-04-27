import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/product_model.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  CustomerResponseModelxx storedCustomerData(Box<dynamic> customerBox) {
    final cachedData = customerBox.get('fetchCustomerData');
    if (cachedData == null) {
      throw Exception('No cached data available');
    }
    try {
      log('Fetched cached data from Hive: $cachedData');
      final castedData = castToStringDynamic(cachedData);
      if (castedData == null || castedData.isEmpty) {
        throw Exception('Cached data is null or improperly formatted.');
      }
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
    } catch (e) {
      log('Error processing cached data: $e');
      throw Exception('Failed to parse cached data: $e');
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

  Future<CustomerAndOrderResponce?> retrieveCustomerData() async {
    final box = await Hive.openBox('customerBox');
    final jsonString = box.get('customerData');

    if (jsonString != null) {
      try {
        final convertedData = LocalStorage()
            .castToStringDynamic(Map<String, dynamic>.from(jsonString));
        return CustomerAndOrderResponce.fromJson(convertedData);
      } catch (e) {
        log("Error converting customer data: $e");
        return null;
      }
    }
    return null;
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

  storedSettingsData(Box<dynamic> settingsBox, String cacheKey) {
    final cachedData = settingsBox.get(cacheKey);
    if (cachedData != null) {
      log('Fetched settings from Hive: $cachedData');
      final settingsList = (cachedData as List<dynamic>)
          .map((item) => AllCompanySettingsData.fromJson(LocalStorage()
              .castToStringDynamic(Map<dynamic, dynamic>.from(item))))
          .toList();
      return settingsList;
    } else {
      log("No cached settings data available.");
      errorSnackbar('No offline data available.');
    }
  }

  storedPerfromanceData(Box<dynamic> performanceBox, String cacheKey) {
    final cachedData = performanceBox.get(cacheKey);
    if (cachedData != null) {
      final castedData = castToStringDynamic(cachedData);
      return PerformanceData.fromJson(castedData);
    } else {
      errorSnackbar('No perfromance cached data available');
      return null;
    }
  }

  Future<RecentOrderCountResponse> getCachedRecentOrderCount(
      String cacheKey) async {
    try {
      var orderCountBox = await Hive.openBox('orderCountBox');
      if (orderCountBox.containsKey(cacheKey)) {
        log('Fetching cached data for key: $cacheKey');
        final cachedData = orderCountBox.get(cacheKey);
        log('Cached Data: $cachedData');
        final parsedData = LocalStorage().castToStringDynamic(cachedData);
        return RecentOrderCountResponse.fromJson(parsedData);
      } else {
        log('No cached data available for key: $cacheKey');
        throw Exception('No cached data available4');
      }
    } catch (e) {
      log('Error fetching from Hive: $e');
      throw Exception('Failed to fetch data from Hive');
    }
  }

  storedCategoryData(Box<dynamic> box) {
    final savedCategory = box.get('categoryItem');
    if (savedCategory != null) {
      try {
        final convertedData = LocalStorage()
            .castToStringDynamic(Map<String, dynamic>.from(savedCategory));
        return CategoryModel.fromJson(convertedData);
      } catch (e) {
        log("Error converting category data: $e");
        throw Exception('Failed to convert offline data');
      }
    } else {
      throw Exception('An Unexpected Error occured');
    }
  }

  storedProductData(Box<dynamic> productBox, List<ProductModel> allProducts) {
    var rawProductList = productBox.get('products');
    if (rawProductList is List) {
      allProducts = rawProductList
          .map((productJson) {
            if (productJson is Map) {
              return ProductModel.fromJson(
                  LocalStorage().castToStringDynamic(productJson));
            }
            return null;
          })
          .whereType<ProductModel>()
          .toList();
    }
    return allProducts;
  }

  storedRecentOrdersData(Box<dynamic> ordersBox, String cacheKey) {
    final cachedData = ordersBox.get(cacheKey);
    final castedData = LocalStorage().castToStringDynamic(cachedData);
    return OrderResponce.fromJson(castedData);
  }

  storedWeekelyTypeData(Box<dynamic> weeklyTypeBox, String cacheKey) {
    try {
      if (weeklyTypeBox.containsKey(cacheKey)) {
        final cachedWeeklyType = weeklyTypeBox.get(cacheKey) as String?;
        log("Weekly Type fetched from Hive345: $cachedWeeklyType");
        return cachedWeeklyType;
      } else {
        log("No cached Weekly Type data found for key: $cacheKey");
      }
    } catch (e) {
      log("Error accessing cached Weekly Type data: $e");
    }
  }

  storedSalesmanValueTarget(Box<dynamic> targetBox, cacheKey) {
    try {
      if (targetBox.containsKey(cacheKey)) {
        final cachedData = targetBox.get(cacheKey);
        final convertedData = castToStringDynamic(cachedData);
        return SalesmanValueTargetResponse.fromJson(convertedData);
      } else {
        errorSnackbar("No salesman value target cached data available");
        log("No cached data available for Salesman Value Target.");
      }
    } catch (e) {
      log("Error accessing cached Salesman Value Target data: $e");
    }
  }

  storedCustomerRevenueData(dynamic cachedData, String customerId) {
    if (cachedData != null) {
      if (cachedData is Map<String, dynamic>) {
        return CustomerRevenueResponse.fromJson(cachedData);
      } else {
        throw Exception(
            'Invalid cached data format for customerId: $customerId');
      }
    } else {
      errorSnackbar("No customer revenue cached data available");
      throw Exception('No cached data available for customerId: $customerId');
    }
  }

  MessagesResponse _parseCachedChatData(dynamic cachedData) {
    try {
      final Map<String, dynamic> castedData =
          (cachedData as Map<dynamic, dynamic>)
              .map((key, value) => MapEntry(key.toString(), value));
      log('Casted data runtimeType: ${castedData.runtimeType}');
      final List<dynamic> rawData = castedData['data'] ?? [];
      final List<Messages> parsedData = rawData.map((messageJson) {
        final messageMap = (messageJson as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry(key.toString(), value),
        );
        return Messages.fromJson(messageMap);
      }).toList();
      return MessagesResponse(
        statusCode: castedData['status_code'] ?? 0,
        status: castedData['status'] ?? false,
        message: castedData['message'] ?? '',
        data: parsedData,
      );
    } catch (e) {
      log('Error parsing cached data: $e');
      throw Exception('Failed to process cached data due to type mismatch.');
    }
  }

  storedChatData(dynamic cachedData, String cacheKey) {
    if (cachedData != null) {
      log('Found cached data for key: $cacheKey');
      return _parseCachedChatData(cachedData);
    } else {
      log('No cached data found for key $cacheKey.');
      throw Exception('No cached data available.');
    }
  }

  ApiResponseModel customerdashboardResponse(
      Map<String, dynamic> jsonResponse) {
    List<CategoryPerformancez> categoryPerformance = [];
    if (jsonResponse['data']['category_performance'] != null) {
      categoryPerformance =
          (jsonResponse['data']['category_performance'] as List)
              .map((json) => CategoryPerformancez.fromJson(json))
              .toList();
    }
    List<FullCategory> allCategory = [];
    if (jsonResponse['data']['fullCategotry'] != null) {
      allCategory = (jsonResponse['data']['fullCategotry'] as List)
          .map((json) => FullCategory.fromJson(json))
          .toList();
    }
    List<RecentOrder> recentOrders = [];
    if (jsonResponse['data']['recent_orders'] != null) {
      recentOrders = (jsonResponse['data']['recent_orders'] as List)
          .map((json) => RecentOrder.fromJson(json))
          .toList();
    }
    List<FrequantliyProductList> frequentProductLists = [];
    if (jsonResponse['data']['frequantliy_product_lists'] != null) {
      frequentProductLists =
          (jsonResponse['data']['frequantliy_product_lists'] as List)
              .map((json) => FrequantliyProductList.fromJson(json))
              .toList();
    }
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
  }
}
