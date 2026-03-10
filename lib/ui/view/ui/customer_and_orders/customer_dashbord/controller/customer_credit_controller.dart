// controllers/customer_credit_controller.dart
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/model/customer_credit_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
 // your session helper

class CustomerCreditController extends GetxController {
  final Dio _dio = Dio();

  // Observable variables
  var isLoading = false.obs;
  var customerCredit = 0.obs;
  var errorMessage = ''.obs;
  var allCustomers = <Customer>[].obs;

  final String apiUrl = "https://test.thrivewoo.com/get_customer_credit";
  static const String _boxName = 'customerCreditBox';

  // Generate cache key using company_id and salesman_id
  String _getCacheKey(int companyId, String salesmanId) {
    return "${companyId}_$salesmanId-customer_credit";
  }

  Future<void> fetchCustomerCredit({
    required int companyId,
    required String? salesmanId,
    required String searchedCustomerId,
  }) async {
    
    final cacheKey = _getCacheKey(companyId, salesmanId!);
    final isConnected = await ConnectivityService().isOnline();

    try {
      isLoading(true);
      errorMessage('');
      // customerCredit(0);

      final box = await Hive.openBox(_boxName);

      // Offline: Try to load from cache
      if (!isConnected) {
        final cachedData = box.get(cacheKey);
        if (cachedData != null && cachedData is List) {
          final List<Customer> cachedCustomers = cachedData
              .map((e) => Customer.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          allCustomers.assignAll(cachedCustomers);
          _updateCreditFromList(searchedCustomerId);
          // Get.snackbar("Offline", "Showing cached credit data", backgroundColor: const Color.fromARGB(255, 238, 250, 8),colorText: Colors.black);
        } else {
          errorMessage('No cached data available offline');
        }
        isLoading(false);
        return;
      }

      // Online: Fetch from API
      final response = await _dio.post(
        apiUrl,
        data: {
          "company_id": companyId,
          "salesman_id": salesmanId,
        },
      );

      if (response.statusCode == 200) {
        final customerCreditResponse = CustomerCredit.fromJson(response.data);

        if (customerCreditResponse.status == true) {
          final customers = customerCreditResponse.customers ?? [];

          // Save to Hive (store raw JSON list)
          await box.put(
            cacheKey,
            customers.map((c) => c.toJson()).toList(),
          );

          allCustomers.assignAll(customers);
          // currentCustomerId(searchedCustomerId);
          _updateCreditFromList(searchedCustomerId);
         
        } else {
          errorMessage('API returned false status');
        }
      }
    } on DioException catch (e) {
      errorMessage(e.response?.data?.toString() ?? 'Network error');
    } catch (e) {
      errorMessage('Unexpected error: $e');
    } finally {
      isLoading(false);
    }
  }

  // Helper: Find and set credit from current allCustomers list
  void _updateCreditFromList(String searchedCustomerId) {
    final customer = allCustomers.firstWhere(
      (c) => c.customerId == searchedCustomerId,
      orElse: () => Customer(customerId: searchedCustomerId, creditAmt: 0),
    );
    customerCredit(customer.creditAmt?? 0);
    print('customer credit updated: ${customer.customerId} → ${formatAmount(customer.creditAmt ?? 0)}');

  }
 

  // Optional: Clear cache for this salesman/company
  Future<void> clearCache(int companyId, String salesmanId) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(_getCacheKey(companyId, salesmanId));
  }
/// Update a customer's credit locally in Hive using only customerId
Future<void> updateCustomerCreditLocally({
  required String customerId,
  required  newCreditAmount,
}) async {
  // Get current companyId & salesmanId from Auth (or wherever you store them)
  // final authController = Get.find<AuthController>(); // Adjust if different
  final int companyId = SessionHelper.loginSavedData?.company_id ?? 1;
  final String salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';

  final cacheKey = "${companyId}_$salesmanId-customer_credit";
  final box = await Hive.openBox('customerCreditBox');

  try {
    final cachedData = box.get(cacheKey);

    if (cachedData == null || cachedData is! List) {
      print("No cached credit data found.");
      return;
    }

    // Reconstruct customer list
    List<Customer> customers = cachedData
        .map((e) => Customer.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Find and update the customer
    final customerIndex = customers.indexWhere((c) => c.customerId == customerId);

    if (customerIndex == -1) {
      print("Customer $customerId not found in cache.");
      return;
    }

    customers[customerIndex].creditAmt = newCreditAmount;

    // Save back to Hive
    await box.put(cacheKey, customers.map((c) => c.toJson()).toList());

    // Update observable list
    allCustomers.assignAll(customers);

    // Auto-update current credit if this is the selected customer
    final currentSelectedId = Get.find<ProductsController>().selectedCustomerId.value;
    if (currentSelectedId == customerId) {
      customerCredit.value = newCreditAmount;
    }

    print("Credit updated locally → Customer: $customerId | New: ${formatAmount(newCreditAmount)}");

  } catch (e) {
    print("Failed to update local credit: $e");
  }
}

  @override
  void onClose() {
    Hive.close();
    super.onClose();
  }
}