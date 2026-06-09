// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, non_constant_identifier_names, deprecated_member_use
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart/category_line_chart.dart';
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
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text("Reached Customer Location".tr),
              content: Text("Would you like to Check-In now?".tr),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Call the check-in function
                    _performCheckInFromMap();
                  },
                  child: Text(
                    "Check-In".tr,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
            return AlertDialog(
              title: Text('Customer Check-Out'.tr),
              content: Text('Do you want to Check-out?'.tr),
              actions: [
                if (isCheckingOut)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  TextButton(
                    child: Text('Stay'.tr),
                    onPressed: () {
                      shouldProceed = false;
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Check-out and leave'.tr),
                    onPressed: () async {
                      setState(() => isCheckingOut = true);

                      if (!await handleLocationPermission(context)) {
                        if (context.mounted) Navigator.of(context).pop();
                        return;
                      }

                      final date =
                          DateFormat('dd-MM-yyyy').format(DateTime.now());
                      final time = DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(DateTime.now());
                      final direction = "OUT";
                      final customerId =
                          productsController.selectedCustomerId.value;

                      try {
                        final position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );
                        final lat = position.latitude.toString();
                        final long = position.longitude.toString();

                        final isOnline = await ConnectivityService().isOnline();

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
                          await ApiWorker().saveSwitchState(false);
                          customerOrderController.isActive.value = false;
                          shouldProceed = true;
                        } else {
                          final response =
                              await ApiWorker().updateCustomerCheckInOut(
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
                                response.statusMessage.toString(),
                                Colors.red,
                                Icons.close,
                              );
                            }
                          } else {
                            await ApiWorker().saveSwitchState(false);
                            customerOrderController.isActive.value = false;
                            shouldProceed = true;
                          }
                        }
                      } catch (e) {
                        //
                      }

                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ],
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
        appBar: AppBar(
          leadingWidth: 200,
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
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                titlePadding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Aligns image and text to the top
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.blueAccent
                                                .withOpacity(0.2),
                                            width: 2),
                                      ),
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey[100],
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // ---> ADDED THE ADDRESS ROW HERE <---
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 14, color: Colors.red),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  nextCustomer.address ??
                                                      "Address not available",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                content: Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                      "Would you like to continue navigation to this customer?"
                                          .tr),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Cancel".tr,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      wantsToContinueNav = true;
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Continue Navigation".tr,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
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
                  child: Container(
                    decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: primaryColor)),
                    child: const Icon(
                      EneftyIcons.arrow_left_3_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(
                  width: 10,
                ),
                Text(
                  "Customer dashboard".tr,
                  style: TextStyle(
                      fontSize: NkFontSize.largeFont(largeFont: 20),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: 120,
              child: Obx(() {
                final credit = _customercreditctrl.customerCredit.value;
                final isLoading = _customercreditctrl.isLoading.value;

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        credit > 0 ? Colors.green.shade50 : Colors.grey.shade50,
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            InkWell(
              onTap: () {
                showUpdateCustomerDialog(
                    context, customerId, customerName, customerImage);
              },
              child: SizedBox(
                width: 130,
                child: SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xffe6ecff),
                          radius: 15,
                          child: CachedNetworkImage(
                            imageUrl:
                                '${ApiConstants.baseUrl}uploads/$customerImage',
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: double.infinity),
                                child: MyRegularText(
                                  label: customerName,
                                  fontSize: 8.8,
                                  maxlines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              MyRegularText(label: "Customer".tr, fontSize: 9),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
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
                                        height: screenWidth * 0.7,
                                        child: Category(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
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
                                        height: screenWidth * 0.7,
                                        child: TabTab(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 110, // Adjusted width
                                  child: YearCustomerAndOrdersDropdown(
                                    onYearSelected: (int year) async {
                                      final isOnline =
                                          await ConnectivityService()
                                              .isOnline();
                                      if (!isOnline) {
                                        // 2. Show a popup message if offline
                                        if (context.mounted) {
                                          showCustomToastDisplay(
                                            context,
                                            'No internet connection. Please connect to the internet to filter data.'
                                                .tr,
                                            Colors.orange,
                                            Icons.wifi_off,
                                          );
                                        }
                                        return; // 3. Stop execution here, do not fetch new data
                                      }
                                      if (context.mounted) {
                                        setState(() {
                                          selectedYear = year;
                                        });
                                        final customerProvider =
                                            Provider.of<CustomersProvider>(
                                                context,
                                                listen: false);
                                        customerProvider
                                            .updateDashboardYear(year);
                                        customerProvider
                                            .fetchCustomerDashboardData(
                                                widget.cusId);
                                        customerProvider
                                            .fetchCustomerDashboardRevenueData(
                                                widget.cusId);
                                        customerProvider
                                            .fetchCustomerDashboardDataSalseData(
                                                widget.cusId);
                                        customerProvider.fetchCustomersDataDash(
                                            widget.cusId);
                                        customerProvider
                                            .fetchCustomerDashboardCountData(
                                                widget.cusId);
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Sales Return'.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width: 145,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (subscriptionController
                                              .orderTakingFromDashboard.value !=
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
                                              .orderTakingFromDashboard.value ==
                                          "true") {
                                        _navigateToOrderTaking();
                                      }
                                      CartDatabaseManager().getCartItems(
                                          productsController
                                              .selectedCustomerId.value);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shadowColor: WidgetStateColor.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          side: const BorderSide(
                                              color: primaryColor)),
                                    ),
                                    child: Text(
                                      'Order Taking'.tr,
                                      style: TextStyle(
                                          color: white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                          fontFamily: fontFamilyName),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
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
                                        height: screenWidth * 0.7,
                                        child: Category(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
                                        child: OrdersPayments(
                                            context,
                                            recentOrders ?? [],
                                            subscriptionController,
                                            widget.cusEmail,
                                            widget.cusMobile),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
                                        child: TabTab(context),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
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
      child: MyCommnonContainer(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 300,
        width: double.infinity,
        isCommonBorder: true,
        child: Consumer<CustomersProvider>(builder: (context, provider, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    dashboardContainerHeader('Category Sales'.tr),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                          right: fullScreenWidth(context) > 630 ? 20 : 2,
                          top: 2),
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
      child: MyCommnonContainer(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: 25,
        height: 320,
        width: double.infinity,
        isCommonBorder: true,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 240,
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tabIndex = 0;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 20,
                                            left: 20,
                                            top: 5,
                                            bottom: 5),
                                        decoration: _tabIndex == 0
                                            ? BoxDecoration(
                                                color: primaryColor
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(25),
                                                ),
                                              )
                                            : null,
                                        child: Text(
                                          'Revenue'.tr,
                                          style: _tabIndex == 0
                                              ? cardHeadingTextStyle
                                              : tabTextStyle,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tabIndex = 1;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 20,
                                            left: 20,
                                            top: 5,
                                            bottom: 5),
                                        decoration: _tabIndex == 1
                                            ? BoxDecoration(
                                                color: const Color(0xff5bc0de)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(25),
                                                ),
                                              )
                                            : null,
                                        child: Text(
                                          'Customer Offer'.tr,
                                          style: _tabIndex == 1
                                              ? cardHeadingTextStyle
                                              : tabTextStyle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 240,
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tabIndex = 0;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 20,
                                            left: 20,
                                            top: 5,
                                            bottom: 5),
                                        decoration: _tabIndex == 0
                                            ? BoxDecoration(
                                                color: primaryColor
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(25),
                                                ),
                                              )
                                            : null,
                                        child: Text(
                                          'Revenue'.tr,
                                          style: _tabIndex == 0
                                              ? cardHeadingTextStyle
                                              : tabTextStyle,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tabIndex = 1;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 20,
                                            left: 20,
                                            top: 5,
                                            bottom: 5),
                                        decoration: _tabIndex == 1
                                            ? BoxDecoration(
                                                color: const Color(0xff5bc0de)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomRight:
                                                      Radius.circular(25),
                                                ),
                                              )
                                            : null,
                                        child: Text(
                                          'Customer Offer'.tr,
                                          style: _tabIndex == 1
                                              ? cardHeadingTextStyle
                                              : tabTextStyle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
