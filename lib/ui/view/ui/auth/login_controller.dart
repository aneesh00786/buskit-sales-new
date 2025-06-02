// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:math' as rand;

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/dio_client.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/splash_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
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
      final response = await responsePostMethod(
        requestData: requestData,
        endPoint: ApiConstants.sendVerificationMail,
      );
      if (response.data['status'] == true) {
        log('Verification mail sent successfully.');
        successMessage.value =
            "Your email verification is successful, and an OTP has been sent to your email.";
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
      successMessage.value = "OTP verified successfully.";
      return true;
    } else {
      isEmailVerified.value = false;
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
        loginButtonController.success();
        Get.to(() => SplashScreen(message: "Logging in..."),
            transition: Transition.fade);
        await SessionHelper().setLoginData(loginResponce!.data!);
        log('Login Data ${loginResponce!.data!.createdToken}');
        final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
        final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
        log("Fetching settings after login...");
        await Future.delayed(const Duration(milliseconds: 500));
        final settings = await _apiWorker.fetchAllSettings(companyId);
        await Future.wait([
          Provider.of<CustomersProvider>(context, listen: false)
              .fetchCustomerData(),
          Provider.of<DashboardProvider>(context, listen: false).fetchData(),
          customerAndOrderController.loadCustomer(),
          productsController.fetchCategoryData(),
          pendingPaymentController.loadOrderData(
              chartIndex: 0, compId: companyId, isLogin: true),
          staffController.loadSalesmanTargetForSelectedTab(
              currentYear: currentYear.toString(),
              selectedTabIndex: _tabController!.index + 1,
              staffId: salesmanId,
              monthName: currentMonthName,
              compId: companyId,
              isFromLogin: true),
          _apiWorker.fetchSalesmanTarget(salesmanId, currentMonthName, "2025",
              compId: companyId, isFromLogin: true),
          _apiWorker.fetchSalesmanValueTarget(
              salesmanId, "2025", currentMonthName,
              compid: companyId, isFromLogin: true),
          leadsController.loadLeadsCustomerData,
          leadsCustomerController.loadLeadsCustomerData,
          leadsRejectedController.loadRejectedLeadsData,
          ApiWorker().fetchDiscounts(companyId, salesmanId),
          CartDatabaseManager().getDraftItems(),
          ApiWorker()
              .getRecentOrdersData(
                searchModel: searchData,
                orderStatus: 11,
                isLogin: true,
                startDate: '',
                endDate: '',
                page: 1,
              )
              .then((data) =>
                  log("Recent orders fetched successfully. Data: ${data.data}"))
              .catchError((e) => log("Error while fetching recent orders: $e"))
        ]);
        if (settings != null) {
          await SessionHelper().setSettingsData(settings);
        }
        SubCategoryItem? subCategoryItem =
            productsController.getInitialSubCategoryIdAndName();
        if (subCategoryItem != null && (subCategoryItem.id ?? '').isNotEmpty) {
          await productsController.fetchProducts(subCategoryItem.id!);
        } else {
          log("No subcategory found. Products not fetched.");
        }
        await subscriptionController.loadSubscriptionFeatures(companyId);
        Get.offAllNamed(AppRoutes.home);
        return true;
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
}
