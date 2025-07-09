// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:math' as rand;

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/api_handler/handle_logout.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/splash_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../../common/search_model.dart';

class LoginController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  TabController? _tabController;
  final _phoneCode = ''.obs;
  String get phoneCode => _phoneCode.value;
  TabController? get tabController => _tabController;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController businessEmailController = TextEditingController();
  TextEditingController companyRegController = TextEditingController();
  TextEditingController adminFirstNameController = TextEditingController();
  TextEditingController adminLastnameController = TextEditingController();
  FocusNode addressFocusNode = FocusNode();
  FocusNode townFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode postCodeFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode businessEmailFocusNode = FocusNode();
  FocusNode otpFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ProductsController productsController = Get.put(ProductsController());
  PendingPaymentController pendingPaymentController =
      Get.put(PendingPaymentController());
  StaffController staffController = Get.put(StaffController());
  LeadsController leadsController = Get.put(LeadsController());
  CustomersController leadsCustomerController = Get.put(CustomersController());
  OrderController orderController = Get.put(OrderController());
  CalenderMapController calenderMapController =
      Get.put(CalenderMapController());
  RejectedLeadsController leadsRejectedController =
      Get.put(RejectedLeadsController());
  LoginResponse? loginResponce;
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  RoundedLoadingButtonController loginButtonController =
      RoundedLoadingButtonController();
  RoundedLoadingButtonController registerButtonController =
      RoundedLoadingButtonController();
  RoundedLoadingButtonController registerController =
      RoundedLoadingButtonController();
  SubscriptionController subscriptionController =
      Get.put(SubscriptionController());
  RxBool isPasswordVisible = true.obs;
  PaginationModel paginationModel = PaginationModel();
  final int currentYear = DateTime.now().year;
  int selectedTabIndex = 0;
  SearchModel searchData = SearchModel();
  var isEmailVerified = false.obs;
  var successMessage = "".obs;
  String? serverGeneratedOtp;
  RxBool isOtpSent = false.obs;
  RxBool isResend = false.obs;
  TextEditingController otpController = TextEditingController();

  void updatePhoneCode(String code) {
    _phoneCode.value = code;
  }

  Future<void> verifyEmail(String email) async {
    try {
      serverGeneratedOtp = generateOtp();
      final requestData = {
        "email": email,
        "otp": serverGeneratedOtp,
      };
      isResend.value = true;
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: ApiConstants.sendVerificationMail,
      );
      if (response.data['status'] == true) {
        log('Verification mail sent successfully.');
        successMessage.value =
            "An OTP has been sent to your email. Please enter the OTP below to verify your email.";
        isEmailVerified.value = false;
        isOtpSent.value = true;
      } else {
        log('Error: ${response.data['message'] ?? 'Unknown error occurred.'}');
        successMessage.value = "Verification failed. Please try again.";
        isEmailVerified.value = false;
      }
    } on DioException catch (e) {
      handleExceptionMessage(
          apiName: "Send verification Email", error: e, response: e.response);
      successMessage.value = "Verification failed. Please try again.";
      isEmailVerified.value = false;
    } catch (e) {
      log('Unexpected error: $e');
      successMessage.value = "Verification failed. Please try again.";
      isEmailVerified.value = false;
    }
  }

  String generateOtp({int length = 4}) {
    final random = rand.Random();
    return List.generate(length, (_) => random.nextInt(10)).join();
  }

  bool validateOtp(String enteredOtp) {
    if (enteredOtp == serverGeneratedOtp) {
      isEmailVerified.value = true;
      isResend.value = false;
      successMessage.value = "OTP verified successfully.";
      return true;
    } else {
      isEmailVerified.value = false;
      isResend.value = true;
      successMessage.value = "Invalid OTP. Please try again.";
      return false;
    }
  }

  void resetVerificationState() {
    isEmailVerified.value = false;
    successMessage.value = "";
    serverGeneratedOtp = null;
    otpController.clear();
  }

  Widget get getIsPasswordVisible {
    if (isPasswordVisible.value) {
      return IconButton(
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
        },
        icon: const Icon(Icons.visibility),
      );
    } else {
      return IconButton(
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
        },
        icon: const Icon(Icons.visibility_off),
      );
    }
  }

  void initializeTabController(TickerProvider vsync, {required int length}) {
    _tabController = TabController(length: length, vsync: vsync);
  }

  void clearAllFields() {
    businessEmailController.clear();
    otpController.clear();
    phoneNumberController.clear();
    addressController.clear();
    countryController.clear();
    businessNameController.clear();
    stateController.clear();
    townController.clear();
    postCodeController.clear();
    adminFirstNameController.clear();
    adminLastnameController.clear();
    companyRegController.clear();

    isEmailVerified.value = false;
    successMessage.value = '';
  }

  Future<bool> performLogin(BuildContext context) async {
    DateTime now = DateTime.now();
    String currentMonthName = DateFormat('MMMM').format(now);
    try {
      final requestBody = {
        "email": emailController.text.removeAllWhitespace,
        "password": passwordController.text,
      };
      bool isOnline = await ConnectivityService().isOnline();

      if (!isOnline) {
        showErrorDialog('Login Failed',
            'No internet connection. Please check your network.');
        return false;
      }

      log("Request Body: $requestBody");
      loginResponce = await _apiWorker.loginApi(
        emailController.text.removeAllWhitespace,
        passwordController.text,
      );
      log("Response Body: ${loginResponce?.toJson()}");
      log("StatusCode: ${loginResponce?.statusCode}");

      if (loginResponce?.statusCode == 200) {
        try {
          final response = await ApiWorker().userVerification(
              loginResponce?.data?.company_id ?? 0,
              loginResponce?.data?.salesmanId ?? '');

          if (response.statusCode == 200) {
            log('success', name: 'userVerification');
          } else {
            final message = response.message;
            Get.snackbar(
              "Error",
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.5),
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
            log(message, name: 'userVerification');
            showCustomToastDisplay(
              context,
              response.message,
              red,
              Icons.close,
              duration: 5,
            );
            return false;
          }
        } catch (e) {
          log('userVerification exception: $e', name: 'userVerification');
          showCustomToastDisplay(
            context,
            "App not activated, Please contact admin",
            red,
            Icons.close,
            duration: 5,
          );
          return false;
        }
      }

      if (loginResponce?.statusCode == 200) {
        loginButtonController.success();

        await SessionHelper().getLoginData();
        final oldSalesmanId = SessionHelper.backupLoginData?.salesmanId;
        final newSalesmanId = loginResponce?.data?.salesmanId;
        bool isSameUser =
            (oldSalesmanId != null && oldSalesmanId == newSalesmanId);
        if (oldSalesmanId != null && oldSalesmanId != newSalesmanId) {
          await handleLogout(context);
          productsController.categoryData.value = CategoryModel();
          productsController.products.clear();
        }

        await SessionHelper().setLoginData(loginResponce!.data!);
        await SessionHelper().getLoginData();
        log("Fetching settings after login...");
        await Future.delayed(const Duration(seconds: 2));
        final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
        final settings = await _apiWorker
            .fetchAllSettings(SessionHelper.loginSavedData?.company_id ?? 0);

        bool syncInBackground = false;
        late void Function() onSyncInBackground;
        final requiredDataFuture = loadAllInitialData(context, companyId);
        final customerSyncFuture =
            isSameUser ? Future.value() : fetchAllCustomerPages(context);
        final navigationCompleter = Completer<void>();
        onSyncInBackground = () {
          if (!syncInBackground) {
            syncInBackground = true;
            requiredDataFuture.then((_) {
              if (!navigationCompleter.isCompleted) {
                navigationCompleter.complete();
              }
            });
          }
        };

        Get.to(
          () => SplashScreenLogging(
            message:
                "We are settling up your App and it might take a few minutes. Thanks for your patience.",
            onSyncInBackground: isSameUser ? null : onSyncInBackground,
          ),
          transition: Transition.fade,
        );

        requiredDataFuture.then((_) async {
          log('[SyncInBackground] requiredDataFuture.then triggered');
          if (settings != null) {
            await SessionHelper().setSettingsData(settings);
            await SessionHelper().getSettingsData();
          }
          // If sync in background was pressed, navigate to home immediately
          if (syncInBackground) {
            log('[SyncInBackground] syncInBackground is true, navigating home');
            if (!navigationCompleter.isCompleted) {
              log('[SyncInBackground] Completing navigationCompleter (from then)');
              navigationCompleter.complete();
            } else {
              log('[SyncInBackground] navigationCompleter already completed (from then)');
            }
          } else {
            // Otherwise, wait for customer sync to finish before navigating
            log('[SyncInBackground] Waiting for customerSyncFuture');
            await customerSyncFuture;
            if (!navigationCompleter.isCompleted) {
              log('[SyncInBackground] Completing navigationCompleter (after customerSyncFuture)');
              navigationCompleter.complete();
            } else {
              log('[SyncInBackground] navigationCompleter already completed (after customerSyncFuture)');
            }
          }
        });

        await navigationCompleter.future;
        Get.offAllNamed(AppRoutes.home);
        return true;

        // if (settings != null) {
        //   await SessionHelper().setSettingsData(settings);
        // }
        // SubCategoryItem? subCategoryItem =
        //     productsController.getInitialSubCategoryIdAndName();
        // if (subCategoryItem != null && (subCategoryItem.id ?? '').isNotEmpty) {
        //   await productsController.fetchProducts(subCategoryItem.id!);
        // } else {
        //   log("No subcategory found. Products not fetched.");
        // }
        // await subscriptionController.loadSubscriptionFeatures(companyId);
        // Get.offAllNamed(AppRoutes.home);
        // return true;
      } else {
        return _handleLoginError(loginResponce);
      }
    } on DioException catch (e) {
      _handleException(e);
      return false;
    }
  }

  void _handleException(Object e) {
    log("Login Error: $e");
    loginButtonController.error();
    loginButtonController.reset();

    if (e is DioException) {
      showErrorDialog(
        'Login Failed',
        e.response?.data['message'] ?? e.message,
      );
    } else {
      showErrorDialog(
        'Login Failed',
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  bool _handleLoginError(LoginResponse? response) {
    if (response == null) {
      handleHttpResponseError(
        statusCode: 500,
        showErrorSnackBar: (message) {
          showErrorDialog('Login Failed', message);
        },
      );
      return false;
    }
    handleHttpResponseError(
      statusCode: response.statusCode ?? 0,
      showErrorSnackBar: (message) {
        showErrorDialog('Login Failed', message);
      },
      message: response.message,
    );
    if (response.statusCode == 422 || response.statusCode == 409) {
      return false;
    } else if (response.statusCode == 401) {
      return false;
    }
    return false;
  }

  void showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Column(
          children: [
            Image.asset("assets/images/mobile-password-forgot.png"),
            SizedBox(
              height: 10,
            ),
            CustomText(content: title),
          ],
        ),
        content: CustomText(content: message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void handleTokenExpiration() async {
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

  Future<void> fetchAllCustomerPages(BuildContext context) async {
    final provider = Provider.of<CustomersProvider>(context, listen: false);
    final apiService = ApiService();
    List<CustomerModelxx> allCustomers = [];
    List<OrderTotalxx> allOrderTotals = [];
    List<YearsListOfAll> allYearsList = [];
    int totalPages = 1;
    int page = 1;
    try {
      // Fetch first page to get totalPages
      log('[fetchAllCustomerPages] Fetching customer page 1');
      final firstResponse = await apiService.fetchCustomer(
        salesmanId: '',
        customerName: provider.searchCustomerName,
        startDate: '',
        endDate: '',
        limit: 10,
        page: 1,
        valueFromDw: provider.selectedFilter == FilterDateEnum.range
            ? [
                provider.selectedFilter.name,
                provider.selectedStartDate,
                provider.selectedEndDate
              ]
            : provider.selectedFilter.name,
      );
      allCustomers.addAll(firstResponse.data);
      allOrderTotals.addAll(firstResponse.orderTotal);
      allYearsList.addAll(firstResponse.yearsListOfAll);
      totalPages = firstResponse.pagination.totalPages;
      log('[fetchAllCustomerPages] First page fetched, totalPages reported: $totalPages');
      // Save first page to Hive with cacheKey
      final customerBox = Hive.box('customerBox');
      final cacheKeyFirst =
          '${SessionHelper.loginSavedData?.company_id ?? 0}_customer_list_1';
      await customerBox.put(cacheKeyFirst, firstResponse.toJson());
      log('[fetchAllCustomerPages] Caching page 1 with ${firstResponse.data.length} customers');
      // Fetch remaining pages if any
      for (page = 2; page <= totalPages; page++) {
        log('[fetchAllCustomerPages] Fetching customer page $page');
        final response = await apiService.fetchCustomer(
          salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
          customerName: provider.searchCustomerName,
          startDate: '',
          endDate: '',
          limit: 10,
          page: page,
          valueFromDw: provider.selectedFilter == FilterDateEnum.range
              ? [
                  provider.selectedFilter.name,
                  provider.selectedStartDate,
                  provider.selectedEndDate
                ]
              : provider.selectedFilter.name,
        );
        allCustomers.addAll(response.data);
        allOrderTotals.addAll(response.orderTotal);
        allYearsList.addAll(response.yearsListOfAll);
        final cacheKey =
            '${SessionHelper.loginSavedData?.company_id ?? 0}_customer_list_$page';
        await customerBox.put(cacheKey, response.toJson());
        log('[fetchAllCustomerPages] Caching page $page with ${response.data.length} customers');
      }
      provider.setCustomers(allCustomers, totalPages);
      provider.setOrderTotal(allOrderTotals);
      provider.setYearList(allYearsList);
      log('[fetchAllCustomerPages] Finished fetching all pages. Total pages: $totalPages, Total customers: ${allCustomers.length}');
      // Build unique customerId list from all pages
      final allCustomerIds = allCustomers
          .map((c) => c.customerId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      await prefetchAndCacheAllCustomerDashboards(context, allCustomerIds);
    } catch (e) {
      log('Error fetching all customer pages : $e');
      rethrow;
    }
  }

  Future<void> loadAllCachedCustomerPages(BuildContext context) async {
    final provider = Provider.of<CustomersProvider>(context, listen: false);
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final customerBox = Hive.box('customerBox');
    List<CustomerModelxx> allCustomers = [];
    List<OrderTotalxx> allOrderTotals = [];
    List<YearsListOfAll> allYearsList = [];
    int totalPages = 1;
    int page = 1;

    while (true) {
      final cacheKey = '${companyId}_customer_list_$page';
      final cachedData = customerBox.get(cacheKey);
      if (cachedData == null) break;
      try {
        final response = CustomerResponseModelxx.fromJson(cachedData);
        allCustomers.addAll(response.data);
        allOrderTotals.addAll(response.orderTotal);
        allYearsList.addAll(response.yearsListOfAll);
        totalPages = response.pagination.totalPages;
      } catch (e) {
        log('Error parsing cached customer page $page: $e');
      }
      page++;
    }
    if (allCustomers.isNotEmpty) {
      provider.setCustomers(allCustomers, totalPages);
      provider.setOrderTotal(allOrderTotals);
      provider.setYearList(allYearsList);
    }
  }

  Future<void> prefetchAndCacheAllCustomerDashboards(
      BuildContext context, List<String> customerIds) async {
    final apiService = ApiService();
    final now = DateTime.now();
    final year = now.year;
    final startDate = DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1));
    final endDate = DateFormat('yyyy-MM-dd').format(DateTime(year, 12, 31));
    for (final customerId in customerIds) {
      if (customerId.isEmpty) continue;
      try {
        log('[prefetchDash] Dashboard for $customerId');
        await apiService.fetchCustomerDashboardDataa(
            customerId, year, startDate, endDate);
      } catch (e) {
        log('Error prefetching dashboard data $e');
      }
      try {
        log('[prefetchDash] TotalSale for $customerId');
        await apiService.fetchCustomerTotalSale(customerId, year);
      } catch (e) {
        log('Error prefetching total sale $e');
      }
      try {
        log('[prefetchDash] Revenue for $customerId');
        await apiService.fetchCustomerRevenueData(
            customerId, year, startDate, endDate);
      } catch (e) {
        log('Error prefetching revenue $e');
      }
      try {
        log('[prefetchDash] OrderCount for $customerId');
        await apiService.fetchOrderCount(customerId, startDate, endDate);
      } catch (e) {
        log('Error prefetching order count $e');
      }
    }
  }

  // Helper to wrap futures with timeout and error logging
  Future<T?> withTimeoutAndLog<T>(
    Future<T> future,
    String label, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    log('\x1B[32m******************************** $label ********************************\x1B[0m');
    try {
      return await future.timeout(
        timeout,
        onTimeout: () async {
          log('[Timeout] $label did not complete in ${timeout.inSeconds}s');
          return Future.value(null); // ✅ ensure it's Future<T?>
        },
      );
    } catch (e, stack) {
      log('[Error] $label failed: $e\n$stack');
      return null;
    }
  }

  Future<void> loadAllInitialData(BuildContext context, int companyId) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final startDate = formatter.format(firstDayOfMonth);
    final endDate = formatter.format(lastDayOfMonth);

    final String currentMonth = DateFormat.MMMM().format(DateTime.now());
    log("📆 Month passed : $currentMonth");

    try {
      log('loadAllInitialData: Starting to load all initial data...');
      
      await Future.wait([
        subscriptionController.loadSubscriptionFeatures(companyId),
        Provider.of<DashboardProvider>(context, listen: false).fetchData(),
        customerAndOrderController.loadCustomer(),
        productsController.loadCategoriesAndDefaultProducts(),
        pendingPaymentController.loadOrderData(
            chartIndex: 0, compId: companyId, isLogin: true),
        ApiWorker().fetchDiscounts(companyId, ""),
        leadsController.loadLeadsCustomerData,
        leadsCustomerController.loadLeadsCustomerData,
        leadsRejectedController.loadRejectedLeadsData,
        orderController.loadOrderCountData(),
        _apiWorker.getAllProducts(),
        calenderMapController.getRouteCredit(),
        _apiWorker.getCalendarEvents({
          'companyId': companyId,
          'initialDay': DateTime(DateTime.now().year, DateTime.now().month, 1)
              .toIso8601String(),
        }),
        _apiWorker.fetchOnlyCustomerDataInWhole(startDate, endDate),

        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: '',
            orderStatus: OrderStatus.delivered,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 7,
            orderStatus: OrderStatus.estimates,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 0,
            orderStatus: OrderStatus.preOrder,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 4,
            orderStatus: OrderStatus.draft,
            fetchType: "Month"),
        ApiService().fetchAllOrders(
            isLogin: true,
            orderType: 3,
            orderStatus: OrderStatus.cancelled,
            fetchType: "Month"),

        // --- Performance/Staff module API calls ---
        withTimeoutAndLog(ApiWorker().getWeeklyType(), 'getWeeklyType'),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanPerformanceData(
            monthName: DateFormat.MMMM().format(DateTime.now()),
            year: DateTime.now().year,
            compId: companyId,
            salesId: SessionHelper.loginSavedData?.salesmanId ?? '',
            isfromLogin: true,
          ),
          'fetchSalesmanPerformanceData',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanTopBarData(
              DateFormat.MMMM().format(DateTime.now()), 1),
          'fetchSalesmanTopBarData-1',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanTopBarData(
              DateFormat.MMMM().format(DateTime.now()), 2),
          'fetchSalesmanTopBarData-2',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanTopBarData(
              DateFormat.MMMM().format(DateTime.now()), 3),
          'fetchSalesmanTopBarData-3',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanTopBarData(
              DateFormat.MMMM().format(DateTime.now()), 4),
          'fetchSalesmanTopBarData-4',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanValueTarget(
            SessionHelper.loginSavedData?.salesmanId ?? '',
            DateTime.now().year.toString(), null,
            // currentMonth,
          ),
          'fetchSalesmanValueTarget',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSalesmanTarget(
            SessionHelper.loginSavedData?.salesmanId ?? '',
            currentMonth,
            DateTime.now().year.toString(),
          ),
          'fetchSalesmanTarget',
        ),
        withTimeoutAndLog(
          ApiWorker().getTimeSheetData(
            startDate: startDate,
            endDate: endDate,
          ),
          'getTimeSheetData',
        ),
        withTimeoutAndLog(
          ApiWorker().fetchSchedule(
            endDate,
            startDate,
          ),
          'fetchSchedule',
        ),
      ]);
      
      // Check cache status after loading all data
      log('loadAllInitialData: Checking cache status after data loading...');
      await productsController.checkCacheStatus();
      
    } catch (e, stack) {
      log('Error in Future.wait during login: $e\n$stack');
      // Optionally: Show a user-friendly error message here
      // Do NOT rethrow, so the future always completes
    }
  }
}
