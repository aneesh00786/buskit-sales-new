// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, non_constant_identifier_names, deprecated_member_use
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart/category_line_chart.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/dashboard_card.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/message/customer_revenue_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/custmerlist_and_map.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebarx.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/controller/customer_credit_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/controller/sales_return_search_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_option_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/frequently_bought_product.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/message/customer_category_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payments.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/total_sale_customer.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/total_sales.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/update_customer_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/year_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../api_handler/api_worker.dart';
import 'package:hive/hive.dart';

class CustomerDachScreen extends StatefulWidget {
  final dynamic year;
  final dynamic startDate;
  final dynamic endDate;
  final String cusName;
  final String cusId;
  final String cusImage;
  final String cusEmail;
  final String cusMobile;
  final bool isFromCalendar;
  final bool isDirectDialogue;
  final bool isFromOrder;
  final bool isFromGoogle;
  final ProductsController? productsController;
  final List<String> eventIds;
  final List<String> customerIds;

  const CustomerDachScreen({
    super.key,
    this.year,
    this.startDate,
    this.endDate,
    required this.cusId,
    required this.cusName,
    required this.cusImage,
    required this.cusEmail,
    required this.cusMobile,
    this.isFromCalendar = false,
    this.isDirectDialogue = false,
    this.isFromOrder = false,
    this.productsController,
    this.isFromGoogle = false,
    this.eventIds = const [],
    this.customerIds = const [],
  });

  @override
  State<CustomerDachScreen> createState() => _CustomerDachScreenState();
}

class _CustomerDachScreenState extends State<CustomerDachScreen>
    with SingleTickerProviderStateMixin {
  bool showChatbotMobile = false;

  late int selectedYear;
  late TabController _tabController;
  late int _tabIndex;
  HomeController homeController = Get.put(HomeController());
  CustomerAndOrderController customerOrderController =
      Get.find<CustomerAndOrderController>();
  final subscriptionController = Get.find<SubscriptionController>();
  final productsController = Get.find<ProductsController>();
  ApiWorker apiWorker = Get.put(ApiWorker());
  final CustomerCreditController _customercreditctrl =
      Get.find<CustomerCreditController>();

  @override
  void initState() {
    super.initState();
    _fetchCredit();
    final customerProvider =
        Provider.of<CustomersProvider>(context, listen: false);
    selectedYear = (widget.year != null && widget.year.toString().isNotEmpty)
        ? int.tryParse(widget.year.toString()) ?? DateTime.now().year
        : DateTime.now().year;
    // final currentYear = DateTime.now().year;

    customerProvider.updateDashboardYear(selectedYear);

    // Fetch fresh data for current year
    _loadDashboardData(customerProvider);

    // --- CHECK-IN POPUP LOGIC FOR MAP NAVIGATION ---
    if (widget.isFromGoogle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false, // Force user to choose
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          colors: [primaryColor, Color(0xFF2D3748)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on_outlined,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Reached Customer Location".tr,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Would you like to Check-In now?".tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Cancel".tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Call the check-in function
                                    _performCheckInFromMap();
                                  },
                                  child: Text(
                                    "Check-In".tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    }
    // -----------------------------------------------

    _tabIndex = 0;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context
            .read<CustomersProvider>()
            .setSelectedIndex(_tabController.index);
      }
    });
  }

  void _navigateTooNext(
      double startLat, double startLng, double endLat, double endLng) async {
    if (Platform.isAndroid) {
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps on Android';
      }
    } else if (Platform.isIOS) {
      final Uri googleMapsUrl = Uri.parse(
          'comgooglemaps://?saddr=$startLat,$startLng&daddr=$endLat,$endLng&directionsmode=driving');
      final Uri appleMapsUrl = Uri.parse(
          'https://maps.apple.com/?saddr=$startLat,$startLng&daddr=$endLat,$endLng&dirflg=d');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch any map application on iOS';
      }
    }
  }

  // --- NEW METHOD TO HANDLE MAP CHECK-IN ---
  Future<void> _performCheckInFromMap() async {
    // 1. Check Permission (using helper if available, otherwise manual check)
    if (!await handleLocationPermission(context)) {
      return;
    }

    // 2. Show loading indicator if needed (optional)
    showCustomToastDisplay(
        context, "Checking in...".tr, Colors.blue, Icons.info);

    try {
      // 3. Get Location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Prepare Data
      final connectivityService = ConnectivityService();
      final isOnline = await connectivityService.isOnline();
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final time =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString();
      final direction = "IN";
      final lat = position.latitude.toString();
      final long = position.longitude.toString();
      final customerId = widget.cusId;

      if (!isOnline) {
        // 5a. Offline Logic
        await _saveCheckInOutRequestOffline(
          date: date,
          time: time,
          direction: direction,
          lat: lat,
          long: long,
          customerId: customerId,
        );

        // Update Controller State
        customerOrderController.isActive.value = true;
        await ApiWorker().saveSwitchState(true);

        if (mounted) {
          showCustomToastDisplay(
            context,
            'You are offline. Check-in saved locally.',
            Colors.orange,
            Icons.save,
          );
        }
      } else {
        // 5b. Online Logic
        final response = await ApiWorker().updateCustomerCheckInOut(
            date: date,
            time: time,
            direction: direction,
            lat: lat,
            long: long,
            customerId: customerId);

        if (response.statusCode == 200) {
          // Update Controller State
          customerOrderController.isActive.value = true;
          await ApiWorker().saveSwitchState(true);

          if (mounted) {
            showCustomToastDisplay(
              context,
              'Checked-in successfully!'.tr,
              Colors.green,
              Icons.check_circle,
            );
          }
        } else {
          if (mounted) {
            showCustomToastDisplay(
              context,
              response.statusMessage.toString(),
              Colors.red,
              Icons.error,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomToastDisplay(
            context, "Check-in failed: $e", Colors.red, Icons.error);
      }
    }
  }

  void _loadDashboardData(CustomersProvider provider) {
    provider.fetchCustomerDashboardData(widget.cusId);
    provider.fetchCustomerDashboardRevenueData(widget.cusId);
    provider.fetchCustomerDashboardDataSalseData(widget.cusId);
    provider.fetchCustomersDataDash(widget.cusId);
    provider.fetchCustomerDashboardCountData(widget.cusId);
  }

  // ... rest of your code (didUpdateWidget, _fetchCredit, _navigateToOrderTaking, etc.) ...

  @override
  void didUpdateWidget(CustomerDachScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cusId != widget.cusId) {
      _fetchCredit();
    }
  }

  void _fetchCredit() {
    if (widget.cusId.isNotEmpty) {
      _customercreditctrl.fetchCustomerCredit(
        companyId: SessionHelper.loginSavedData?.company_id ?? 1,
        salesmanId: SessionHelper.loginSavedData?.salesmanId ?? "SALES1",
        searchedCustomerId: widget.cusId,
      );
    }
  }

  void _navigateToOrderTaking() {
    final cartProvider = Provider.of<CustomersProvider>(context, listen: false);
    final customerId = productsController.selectedCustomerId.value;
    customerOrderController
        .setCustomerId(customerOrderController.customerId.value);

    CartDatabaseManager().getCartItems(customerId);
    cartProvider.getCartItemCounts(customerId);
    CartDatabaseManager().addListener(() {
      cartProvider.updateCartCount(customerId);
    });

    _initializeCustomerData(
      customerId,
      productsController.selectedCustomerName.value,
      productsController.selectedCustomerImageUrl.value,
      productsController,
      customerOrderController,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: Provider.of<CustomersProvider>(context, listen: false),
          child: OrderTaking(
            productsController: productsController,
            selectedCustId: widget.cusId,
            selectedCustName: widget.cusName,
            selectedCustImageUrl: widget.cusImage,
            isFromCalender: widget.isFromCalendar,
            isDirectDialogue: widget.isDirectDialogue,
            isFromOrder: widget.isFromOrder,
          ),
        ),
      ),
    ).then((value) {
      cartProvider.fetchCustomerDashboardCountData(customerId);
    });
  }

  Future<void> _initializeCustomerData(
      String customerId,
      String businessName,
      String customerImage,
      ProductsController productsController,
      CustomerAndOrderController customerAndOrderController) async {
    if (customerId.isEmpty) {
      return;
    }
    customerAndOrderController.setCustomerId(customerId);
    productsController.selectedCustomerId.value = customerId;
    productsController.updateSelectedCustomer(
      name: businessName,
      imageUrl: customerImage,
      id: customerId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    checkCustomerOut();
  }

  Future<void> _saveCheckInOutRequestOffline({
    required String date,
    required String time,
    required String direction,
    required String lat,
    required String long,
    required String customerId,
  }) async {
    final box = await Hive.openBox('offlineRequests');
    final payload = {
      "custid": customerId,
      "companyId": SessionHelper.loginSavedData?.company_id ?? 1,
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "direction": direction,
      "time": time,
      "longitude": double.tryParse(long) ?? 0.0,
      "latitude": double.tryParse(lat) ?? 0.0,
    };
    await box.add({
      'url': ApiConstants.baseUrl + ApiConstants.updateCheckinCustomer,
      'payload': payload,
    });
  }

  Future<bool> checkCustomerOut() async {
    if (!customerOrderController.isActive.value) return true;

    bool shouldProceed = false;
    bool isCheckingOut = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          colors: [primaryColor, Color(0xFF2D3748)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Customer Check-Out'.tr,
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Do you want to Check-out?'.tr,
                            style: const TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          if (isCheckingOut)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      side: const BorderSide(
                                          color: Color(0xFFE2E8F0), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      shouldProceed = false;
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Stay'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      side: const BorderSide(
                                          color: Color(0xFF727CF5), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() => isCheckingOut = true);

                                      if (!await handleLocationPermission(
                                          context)) {
                                        if (context.mounted)
                                          Navigator.of(context).pop();
                                        return;
                                      }

                                      final date = DateFormat('dd-MM-yyyy')
                                          .format(DateTime.now());
                                      final time =
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(DateTime.now());
                                      final direction = "OUT";
                                      final customerId = productsController
                                          .selectedCustomerId.value;

                                      try {
                                        final position =
                                            await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.high,
                                        );
                                        final lat =
                                            position.latitude.toString();
                                        final long =
                                            position.longitude.toString();

                                        final isOnline =
                                            await ConnectivityService()
                                                .isOnline();

                                        if (!isOnline) {
                                          await _saveCheckInOutRequestOffline(
                                            date: date,
                                            time: time,
                                            direction: direction,
                                            lat: lat,
                                            long: long,
                                            customerId: customerId,
                                          );
                                          if (context.mounted) {
                                            showCustomToastDisplay(
                                              context,
                                              'You are offline. Your check-out will sync when online.'
                                                  .tr,
                                              Colors.orange,
                                              Icons.info,
                                            );
                                          }
                                          await ApiWorker()
                                              .saveSwitchState(false);
                                          customerOrderController
                                              .isActive.value = false;
                                          shouldProceed = true;
                                        } else {
                                          final response = await ApiWorker()
                                              .updateCustomerCheckInOut(
                                            date: date,
                                            time: time,
                                            direction: direction,
                                            lat: lat,
                                            long: long,
                                            customerId: customerId,
                                          );

                                          if (response.statusCode != 200) {
                                            if (context.mounted) {
                                              showCustomToastDisplay(
                                                context,
                                                response.statusMessage
                                                    .toString(),
                                                Colors.red,
                                                Icons.close,
                                              );
                                            }
                                          } else {
                                            await ApiWorker()
                                                .saveSwitchState(false);
                                            customerOrderController
                                                .isActive.value = false;
                                            shouldProceed = true;
                                          }
                                        }
                                      } catch (e) {
                                        //
                                      }

                                      if (context.mounted)
                                        Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Check-out and leave'.tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        color: Color(0xFF727CF5),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return shouldProceed;
  }

  // ... Build Method and other Widgets remain exactly the same as previous code ...
  @override
  Widget build(BuildContext context) {
    // The content of the build method from the previous response remains unchanged.
    // Copy the build method from the previous 'customer_dashbord_screen.dart' here.
    // (This prevents the code block from being too long, but let me know if you need it repeated)

    final customerId = widget.isFromCalendar
        ? widget.cusId
        : productsController.selectedCustomerId.value;
    final loginData = SessionHelper.loginSavedData;
    final salesmanInternalId = loginData?.salesmanId?.toString();
    final customerName = widget.isFromCalendar
        ? widget.cusName
        : productsController.selectedCustomerName.value;
    final customerImage = widget.isFromCalendar
        ? widget.cusImage
        : productsController.selectedCustomerImageUrl.value;
    String? startDate;
    String? endDate;
    double screenWidth = fullScreenWidth(context);
    double screenHeight = fullScreenHeight(context);
    bool isMobile = screenWidth < 600;

    return nkMediumSizeBox(
      height: isMobile
          ? screenHeight * 0.9
          : MediaQuery.of(context).orientation == Orientation.portrait
              ? screenHeight * 0.9
              : screenHeight * 1.55,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          leadingWidth: isMobile ? 240 : 320,
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                // Replace your existing InkWell inside the AppBar's leading Row with this:

                InkWell(
                  onTap: () async {
                    bool shouldProceed = await checkCustomerOut();
                    if (!shouldProceed) return;

                    if (!context.mounted) return;

                    // --- 1. FIND THE NEXT UNVISITED ITEM ---
                    final mapController = Get.find<CalenderMapController>();
                    final custOrderController =
                        Get.find<CustomerAndOrderController>();
                    dynamic nextCustomer;

                    for (var customer in mapController.selectedCustomers) {
                      if (!custOrderController.visitedCustomerIds
                          .contains(customer.customerId)) {
                        nextCustomer = customer;
                        break; // Found the next item!
                      }
                    }

                    bool wantsToContinueNav = false;

                    // --- 2. SHOW SNACKBAR OR POPUP ---
                    if (widget.isFromGoogle) {
                      if (nextCustomer != null) {
                        String nextName =
                            nextCustomer.businessName?.toLowerCase() ?? "";

                        // If the next item is just the End Location, mark it visited and show SnackBar
                        if (nextName.contains("end location") ||
                            nextName.contains("destination") ||
                            nextName.isEmpty) {
                          // ---> NEW: Mark the end location as visited so the map screen updates <---
                          if (nextCustomer.customerId != null) {
                            await custOrderController
                                .markAsVisited(nextCustomer.customerId!);
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "All customer visits are complete. Today’s route plan has been completed."),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } else {
                          // It's a real customer, show the "Continue Navigation" dialog

                          // It's a real customer, show the "Continue Navigation" dialog
                          // It's a real customer, show the "Continue Navigation" dialog
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.white,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 380),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryColor,
                                              Color(0xFF2D3748)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.4),
                                                    width: 2),
                                              ),
                                              child: CircleAvatar(
                                                radius: 24,
                                                backgroundColor: Colors.white24,
                                                backgroundImage: NetworkImage(
                                                    '${ApiConstants.imageBaseUrl}${nextCustomer.imageUrl}'),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Next: ${nextCustomer.businessName ?? 'Customer'}",
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins_Regular',
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // ---> ADDED THE ADDRESS ROW HERE <---
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Icon(
                                                          Icons.location_on,
                                                          size: 13,
                                                          color:
                                                              Colors.white70),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          nextCustomer
                                                                  .address ??
                                                              "Address not available",
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'Poppins_Regular',
                                                            fontSize: 11,
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: InkWell(
                                                onTap: () {
                                                  showCustomerRevenueChartDialog(
                                                    context,
                                                    "Revenue",
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.white
                                                          .withOpacity(0.18)),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(6.0),
                                                    child: Icon(
                                                      Icons.open_in_new,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 20, 20, 20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Would you like to continue navigation to this customer?"
                                                  .tr,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins_Regular',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                      side: const BorderSide(
                                                          color: Color(
                                                              0xFFE2E8F0)),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      "Cancel".tr,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        color:
                                                            Color(0xFF64748B),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          primaryColor,
                                                      elevation: 0,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      wantsToContinueNav = true;
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      "Continue Navigation".tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        // Fallback just in case the list is completely empty
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "All customers visited! Route completed."),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    }

                    // 1. PREVENT "BuildContext is no longer valid" CRASH
                    if (!context.mounted) return;

                    customerOrderController.isActive.value = false;

                    // 2. CLEAR THE SIMPLE OBSERVABLES
                    productsController.selectedCustomerId.value = '';
                    productsController.selectedCustomerName.value = '';
                    customerOrderController.setCustomerId('');

                    // 3. THE GETX MAGIC BULLET: Clear the ID and FORCE a refresh
                    productsController.customerAndOrderData.value.customerId =
                        null;
                    productsController.customerAndOrderData.refresh();

                    // 4. Handle External Map Navigation for Next Customer
                    if (wantsToContinueNav && nextCustomer != null) {
                      try {
                        CustomerMapScreen.isNavigatingFromDashboard = true;
                        CustomerMapScreen.nextCustomerToVisit = nextCustomer;

                        final currentLatitude =
                            mapController.currentLatLng.value?.latitude ?? 0.0;
                        final currentLongitude =
                            mapController.currentLatLng.value?.longitude ?? 0.0;

                        _navigateTooNext(
                          currentLatitude,
                          currentLongitude,
                          double.parse(nextCustomer.latitude!),
                          double.parse(nextCustomer.longitude!),
                        );
                      } catch (e) {
                        print("Error finding next customer: $e");
                      }
                    }

                    // 5. ROUTE SAFELY
                    if (widget.isFromGoogle) {
                      homeController.sidebarXController.selectIndex(5);
                      homeController.selectedIndex.value = 5;
                      Get.back(id: 2);
                    } else if (widget.isDirectDialogue) {
                      homeController.sidebarXController.selectIndex(5);
                      homeController.selectedIndex.value = 5;
                      Get.toNamed(AppRoutes.calender, id: 2);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),

                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "Customer dashboard".tr,
                    style: TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          bottom: (isMobile && showChatbotMobile)
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0, bottom: 8.0, top: 4.0),
                      child: const ChatbotTopBarButton(
                          routeName: "/customer_dashboard"),
                    ),
                  ),
                )
              : null,
          actions: [
            Builder(
              builder: (context) {
                List<Widget> actionWidgets = [
                  if (!isMobile)
                    const ChatbotTopBarButton(routeName: "/customer_dashboard"),
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: primaryColor),
                      onPressed: () {
                        setState(() {
                          showChatbotMobile = !showChatbotMobile;
                        });
                      },
                    ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: Obx(() {
                      final credit = _customercreditctrl.customerCredit.value;
                      final isLoading = _customercreditctrl.isLoading.value;

                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: credit > 0
                              ? Colors.green.shade50
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: credit > 0
                                ? Colors.green.shade600
                                : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Credit:'.tr),
                              SizedBox(
                                width: 7,
                              ),
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 15,
                                color: credit > 0
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                              SizedBox(width: 5),
                              Text(
                                credit > 0
                                    ? "${formatAmount(credit)}"
                                    : "${formatAmount(0)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: credit > 0
                                      ? Colors.green.shade800
                                      : Colors.grey.shade700,
                                ),
                              ),
                              if (isLoading)
                                Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      showUpdateCustomerDialog(
                          context, customerId, customerName, customerImage);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 120, maxWidth: 175),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: (customerImage == null ||
                                        customerImage.isEmpty)
                                    ? const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl:
                                            '${ApiConstants.baseUrl}uploads/$customerImage',
                                        placeholder: (context, url) =>
                                            const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 18,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        width: 34,
                                        height: 34,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    customerName.isNotEmpty
                                        ? customerName
                                        : 'Customer',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    "Customer".tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ];

                if (isMobile) {
                  return SizedBox(
                    width: screenWidth - 170,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: actionWidgets,
                      ),
                    ),
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actionWidgets,
                  );
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<CustomersProvider>(
          builder: (context, provider, child) {
            return FutureBuilder<ApiResponseModel>(
              future: provider.customersDashFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  final responseModel = snapshot.data;
                  final frequentProductLists =
                      responseModel?.data.frequentProductLists;
                  final recentOrders = responseModel?.data.recentOrders;

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        OptionWidgetCustomerDash(
                          customerId: widget.cusId,
                          customType: "",
                          customOrderStatusType: OrderStatus.preOrder,
                          userType: UserType.customer,
                          userId: "",
                          startDate: startDate,
                          endDate: endDate,
                          onContinueShopping: _navigateToOrderTaking,
                          productsController: productsController,
                        ),
                        const SizedBox(height: 5.7),
                        Expanded(
                          child: SingleChildScrollView(
                            child: screenWidth < 600
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 350,
                                        child: Category(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: 350,
                                        child: OrdersPayments(
                                          context,
                                          recentOrders ?? [],
                                          subscriptionController,
                                          widget.cusEmail,
                                          widget.cusMobile,
                                        ),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: 350,
                                        child: TabTab(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: 350,
                                        child: Frequently(
                                            context,
                                            frequentProductLists ?? [],
                                            subscriptionController),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Category(context),
                                          ),
                                          const SizedBox(width: 4.7),
                                          Expanded(
                                            child: OrdersPayments(
                                              context,
                                              recentOrders ?? [],
                                              subscriptionController,
                                              widget.cusEmail, // <--- ADD THIS
                                              widget.cusMobile,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.7),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TabTab(context),
                                          ),
                                          const SizedBox(width: 4.7),
                                          Expanded(
                                            child: Frequently(
                                                context,
                                                frequentProductLists ?? [],
                                                subscriptionController),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                } else {
                  final responseModel = snapshot.data;
                  final frequentProductLists =
                      responseModel?.data.frequentProductLists;
                  final recentOrders = responseModel?.data.recentOrders;
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // --- ITEM 1 (LEFT): The Dropdown ---
                            SizedBox(
                              width: 110,
                              child: YearCustomerAndOrdersDropdown(
                                onYearSelected: (int year) {
                                  setState(() {
                                    selectedYear = year;
                                  });
                                  final customerProvider =
                                      Provider.of<CustomersProvider>(context,
                                          listen: false);

                                  customerProvider.updateDashboardYear(year);

                                  customerProvider
                                      .fetchCustomerDashboardData(widget.cusId);
                                  customerProvider
                                      .fetchCustomerDashboardRevenueData(
                                          widget.cusId);
                                  customerProvider
                                      .fetchCustomerDashboardDataSalseData(
                                          widget.cusId);
                                  customerProvider
                                      .fetchCustomersDataDash(widget.cusId);
                                  customerProvider
                                      .fetchCustomerDashboardCountData(
                                          widget.cusId);
                                },
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                child: Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        print('customer id: ${widget.cusId}');
                                        OrderIdSnackBar.show(
                                            context,
                                            widget.cusId.toString(),
                                            salesmanInternalId!);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 38, 165, 42),
                                        elevation: 0,
                                        minimumSize: const Size(130, 42),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      icon: const Icon(
                                          Icons.assignment_return_outlined,
                                          size: 16,
                                          color: Colors.white),
                                      label: Text(
                                        'Sales Return'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamilyName,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width:
                                          10, // Adds a small gap between the two buttons
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (subscriptionController
                                                .orderTakingFromDashboard
                                                .value !=
                                            "true") {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return const UpgradePlanScreen();
                                            },
                                          );
                                        }
                                        if (subscriptionController
                                                .orderTakingFromDashboard
                                                .value ==
                                            "true") {
                                          _navigateToOrderTaking();
                                        }
                                        CartDatabaseManager().getCartItems(
                                            productsController
                                                .selectedCustomerId.value);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                        minimumSize: const Size(140, 42),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      icon: const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 16,
                                          color: Colors.white),
                                      label: Text(
                                        'Order Taking'.tr,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                            fontFamily: fontFamilyName,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         SizedBox(
                        //           width: 110, // Adjusted width
                        //           child: YearCustomerAndOrdersDropdown(
                        //             onYearSelected: (int year) async {
                        //               final isOnline =
                        //                   await ConnectivityService()
                        //                       .isOnline();
                        //               if (!isOnline) {
                        //                 // 2. Show a popup message if offline
                        //                 if (context.mounted) {
                        //                   showCustomToastDisplay(
                        //                     context,
                        //                     'No internet connection. Please connect to the internet to filter data.'
                        //                         .tr,
                        //                     Colors.orange,
                        //                     Icons.wifi_off,
                        //                   );
                        //                 }
                        //                 return; // 3. Stop execution here, do not fetch new data
                        //               }
                        //               if (context.mounted) {
                        //                 setState(() {
                        //                   selectedYear = year;
                        //                 });
                        //                 final customerProvider =
                        //                     Provider.of<CustomersProvider>(
                        //                         context,
                        //                         listen: false);
                        //                 customerProvider
                        //                     .updateDashboardYear(year);
                        //                 customerProvider
                        //                     .fetchCustomerDashboardData(
                        //                         widget.cusId);
                        //                 customerProvider
                        //                     .fetchCustomerDashboardRevenueData(
                        //                         widget.cusId);
                        //                 customerProvider
                        //                     .fetchCustomerDashboardDataSalseData(
                        //                         widget.cusId);
                        //                 customerProvider.fetchCustomersDataDash(
                        //                     widget.cusId);
                        //                 customerProvider
                        //                     .fetchCustomerDashboardCountData(
                        //                         widget.cusId);
                        //               }
                        //             },
                        //           ),
                        //         ),
                        //         SizedBox(
                        //           width: 280,
                        //         ),
                        //         Row(
                        //           children: [
                        //             ElevatedButton(
                        //               onPressed: () {
                        //                 print('customer id: ${widget.cusId}');
                        //                 OrderIdSnackBar.show(
                        //                     context,
                        //                     widget.cusId.toString(),
                        //                     salesmanInternalId!);
                        //               },
                        //               style: ElevatedButton.styleFrom(
                        //                 backgroundColor: const Color.fromARGB(
                        //                     255, 38, 165, 42),
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(4.0),
                        //                 ),
                        //               ),
                        //               child: Text(
                        //                 'Sales Return'.tr,
                        //                 style: TextStyle(
                        //                     color: Colors.white,
                        //                     overflow: TextOverflow.ellipsis),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         const SizedBox(
                        //           width: 5,
                        //         ),
                        //         SizedBox(
                        //           width: 145,
                        //           child: ElevatedButton(
                        //             onPressed: () {
                        //               if (subscriptionController
                        //                       .orderTakingFromDashboard.value !=
                        //                   "true") {
                        //                 showDialog(
                        //                   barrierDismissible: false,
                        //                   context: context,
                        //                   builder: (context) {
                        //                     return const UpgradePlanScreen();
                        //                   },
                        //                 );
                        //               }
                        //               if (subscriptionController
                        //                       .orderTakingFromDashboard.value ==
                        //                   "true") {
                        //                 _navigateToOrderTaking();
                        //               }
                        //               CartDatabaseManager().getCartItems(
                        //                   productsController
                        //                       .selectedCustomerId.value);
                        //             },
                        //             style: ElevatedButton.styleFrom(
                        //               backgroundColor: primaryColor,
                        //               shadowColor: WidgetStateColor.transparent,
                        //               shape: RoundedRectangleBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(4.0),
                        //                   side: const BorderSide(
                        //                       color: primaryColor)),
                        //             ),
                        //             child: Text(
                        //               'Order Taking'.tr,
                        //               style: TextStyle(
                        //                   color: white,
                        //                   fontSize: 12,
                        //                   fontWeight: FontWeight.bold,
                        //                   letterSpacing: 0.3,
                        //                   fontFamily: fontFamilyName),
                        //             ),
                        //           ),
                        //         )
                        //       ],
                        //     )
                        //   ],
                        // ),
                        OptionWidgetCustomerDash(
                          customerId: widget.cusId,
                          customType: "",
                          customOrderStatusType: OrderStatus.newOrder,
                          userType: UserType.customer,
                          userId: "",
                          startDate: startDate,
                          endDate: endDate,
                          productsController: productsController,
                          onContinueShopping: _navigateToOrderTaking,
                        ),
                        const SizedBox(height: 5.7),
                        Expanded(
                          child: SingleChildScrollView(
                            child: screenWidth < 600
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 350,
                                        child: Category(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: 350,
                                        child: OrdersPayments(
                                            context,
                                            recentOrders ?? [],
                                            subscriptionController,
                                            widget.cusEmail,
                                            widget.cusMobile),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: 350,
                                        child: TabTab(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: 350,
                                        child: Frequently(
                                            context,
                                            frequentProductLists ?? [],
                                            subscriptionController),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Category(context),
                                          ),
                                          const SizedBox(width: 4.7),
                                          Expanded(
                                            child: OrdersPayments(
                                              context,
                                              recentOrders ?? [],
                                              subscriptionController,
                                              widget.cusEmail, // <--- ADD THIS
                                              widget.cusMobile,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TabTab(context),
                                          ),
                                          const SizedBox(width: 4.7),
                                          Expanded(
                                            child: Frequently(
                                                context,
                                                frequentProductLists ?? [],
                                                subscriptionController),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  // ... (Keep existing Category, TabTab, showUpdateCustomerDialog methods) ...

  Widget Category(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DashboardCard(
        height: 300,
        child: Consumer<CustomersProvider>(builder: (context, provider, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dashboardContainerHeader('Category Sales'.tr),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: InkWell(
                        onTap: () {
                          showCustomerCategoryChartDialog(
                            context,
                            "Category Sales".tr,
                            widget.cusId,
                            selectedYear,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor.withOpacity(0.3)),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.open_in_new,
                              size: 17,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                nkSmallSizeBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<CustomersProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<ApiResponseModel>(
                          future: provider.customersDashFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData) {
                              return const Center(child: NodataWidget());
                            } else {
                              final responseModel = snapshot.data!;
                              final categoryPerformance =
                                  snapshot.data!.data.categoryPerformance;

                              return Center(
                                child: CustomBarChartCustomerDash(
                                  categoryPerformance: categoryPerformance,
                                  allCategory: responseModel.data.fullCategory,
                                  customerId: widget.cusId,
                                  year: selectedYear,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ]);
        }),
      ),
    );
  }

  String getStatusName(int orderStatus) {
    switch (orderStatus) {
      case 5:
        return 'Order Processing';
      case 10:
        return 'Packed for Delivery';
      case 1:
        return 'Out for Delivery';
      case 2:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  Widget TabTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DashboardCard(
        height: 320,
        child: Consumer<CustomersProvider>(builder: (context, provider, child) {
          return FutureBuilder<CustomerTotalSaleResponse>(
              future: provider.customerTotalSaleResponseFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tabIndex = 0;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _tabIndex == 0
                                            ? primaryColor.withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Revenue'.tr,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.bold,
                                          color: _tabIndex == 0
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tabIndex = 1;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _tabIndex == 1
                                            ? const Color(0xff5bc0de)
                                                .withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Customer Offer'.tr,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.bold,
                                          color: _tabIndex == 1
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: InkWell(
                                  onTap: () {
                                    showCustomerRevenueChartDialog(
                                      context,
                                      "Revenue",
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: primaryColor.withOpacity(0.1)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: fullScreenWidth(context) > 680 ? 0 : 30,
                      ),
                      Expanded(
                        child: _tabIndex == 0
                            ? totalSalse(context)
                            : totalSalseCustomers(context),
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tabIndex = 0;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _tabIndex == 0
                                            ? primaryColor.withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Revenue'.tr,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.bold,
                                          color: _tabIndex == 0
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _tabIndex = 1;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _tabIndex == 1
                                            ? const Color(0xff5bc0de)
                                                .withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Customer Offer'.tr,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Poppins_Regular',
                                          fontWeight: FontWeight.bold,
                                          color: _tabIndex == 1
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: InkWell(
                                  onTap: () {
                                    showCustomerRevenueChartDialog(
                                      context,
                                      "Revenue",
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: primaryColor.withOpacity(0.1)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: fullScreenWidth(context) > 680 ? 0 : 30,
                      ),
                      Expanded(
                        child: _tabIndex == 0
                            ? totalSalse(context)
                            : totalSalseCustomers(context),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              });
        }),
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MMMM-yyyy').format(dateTime);
  }

  void showUpdateCustomerDialog(BuildContext context, String customerId,
      String customerName, String? customerImage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(15),
          child: UpdateCustomerPopup(
            customerId: customerId,
            initialName: customerName,
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF9E9E9E),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildModernField({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFF0F7FF) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlight ? Colors.blueAccent : Colors.grey[500],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isHighlight ? Colors.blue[800] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void useEffect(VoidCallback callback, List<Object?> dependencies) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
