import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/main.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/services/checkin_service.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';

import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        WidgetsBindingObserver,
        TextEditingController,
        WidgetsBinding,
        showDialog,
        AlertDialog,
        BorderRadius,
        RoundedRectangleBorder,
        Colors,
        CircleAvatar,
        Divider,
        ElevatedButton,
        Theme,
        OutlinedButton,
        TextButton,
        Scaffold,
        AppBar,
        CircularProgressIndicator,
        IconButton,
        Icons,
        SnackBar,
        ScaffoldMessenger,
        ListTile,
        InkWell,
        Autocomplete,
        TextFormField,
        InputDecoration,
        OutlineInputBorder,
        Material,
        Card;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerMapScreen extends StatefulWidget {
  final List<String> customerIds;
  final List<String> eventIds;

  // Added these fields to receive data from the Popup Dialog
  final String? initialStartAddress;
  final String? initialEndAddress;
  static bool isNavigatingFromDashboard = false;
  static dynamic nextCustomerToVisit;

  CustomerMapScreen({
    super.key,
    required this.customerIds,
    required this.eventIds,
    this.initialStartAddress,
    this.initialEndAddress,
  });

  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

void navigateToo(
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

class _CustomerMapScreenState extends State<CustomerMapScreen>
    with WidgetsBindingObserver, RouteAware {
  final CalenderMapController _mapController =
      Get.find<CalenderMapController>();
  final HomeController homeController = Get.put(HomeController());
  final ProductsController productsController = Get.find<ProductsController>();
  final CustomerAndOrderController customerAndOrderController =
      Get.find<CustomerAndOrderController>();
  final subscriptionController = Get.find<SubscriptionController>();

  bool navigatedToMap = false;
  Customer? selectedResult;

  // Drawer State Variables
  bool _isDrawerOpen = false; // Default to open so user sees list first
  final double _drawerWidth = 300.0;

  // -- NEW VARIABLES FOR ROUTE INPUT --
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  LatLng? _startLatLng;
  LatLng? _endLatLng;
  bool _isRouteCalculating = false;

  // Cache for distance/duration per customerId
  final Map<String, Map<String, String>> _distanceDurationCache = {};
  final Map<String, bool> _isLoadingDistance = {};
  bool _hasInputChanged = false;

  Future<void> fetchLegDistanceAndDuration(
    Customer customer,
    int index,
    List<Customer> routeList,
  ) async {
    final cacheKey = "${index}_${customer.customerId}";

    if (_distanceDurationCache.containsKey(cacheKey) ||
        _isLoadingDistance[cacheKey] == true) {
      return;
    }

    _isLoadingDistance[cacheKey] = true;

    LatLng? originLatLng;

    if (index == 0) {
      originLatLng = _mapController.currentLatLng.value;
    } else {
      final prev = routeList[index - 1];
      originLatLng = LatLng(
        double.parse(prev.latitude!),
        double.parse(prev.longitude!),
      );
    }

    final destinationLatLng = LatLng(
      double.parse(customer.latitude!),
      double.parse(customer.longitude!),
    );

    if (originLatLng == null) return;

    final origin = "${originLatLng.latitude},${originLatLng.longitude}";
    final destination =
        "${destinationLatLng.latitude},${destinationLatLng.longitude}";

    try {
      final response = await http.get(
        Uri.parse(
          "https://maps.googleapis.com/maps/api/distancematrix/json"
          "?origins=$origin"
          "&destinations=$destination"
          "&key=${ApiConstants.kGoogleApiKey}",
        ),
      );

      final data = jsonDecode(response.body);

      if (data['rows'][0]['elements'][0]['status'] == 'OK') {
        final element = data['rows'][0]['elements'][0];
        _distanceDurationCache[cacheKey] = {
          'distance': element['distance']['text'],
          'duration': element['duration']['text'],
        };
      } else {
        _distanceDurationCache[cacheKey] = {
          'distance': '-',
          'duration': '-',
        };
      }
    } catch (_) {
      _distanceDurationCache[cacheKey] = {
        'distance': '-',
        'duration': '-',
      };
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDistance[cacheKey] = false;
        });
      }
    }
  }

  Customer? _getNextUnvisitedCustomer() {
    final displayList = _mapController.selectedCustomers;
    for (var customer in displayList) {
      // FIX: Removed '?? []' because visitedCustomerIds is now a non-null RxSet
      if (customer.customerId != null &&
          !customerAndOrderController.visitedCustomerIds
              .contains(customer.customerId)) {
        return customer;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // --- SYNC WITH POPUP DIALOG VALUES ---
    // 1. Text Fields: Use passed values first, otherwise fallback to Controller
    _startController.text =
        widget.initialStartAddress ?? _mapController.currentLocationText.value;
    _endController.text = widget.initialEndAddress ?? "";

    // 2. Coordinates: Use Controller values (already set by the Dialog)
    _startLatLng = _mapController.currentLatLng.value;
    _endLatLng = _mapController.searchedLatLng.value;
    _startController.addListener(_onTextChanged);
    _endController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      if (mounted) {
        setState(() {
          _isDrawerOpen = true;
        });
      }
      // await _mapController.loadShowRoute(widget.eventIds);
      await _mapController.getDirections();

      // Safety check: ensure text is populated if coordinates exist
      if (_startController.text.isEmpty &&
          _mapController.currentLocationText.value.isNotEmpty) {
        _startController.text = _mapController.currentLocationText.value;
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }
  @override
  void didPopNext() {
    // We check if the drawer is closed, and if so, pop it open.
    if (mounted && !_isDrawerOpen) {
      setState(() {
        _isDrawerOpen = true;
      });
    }
  }

  void _onTextChanged() {
    if (!_hasInputChanged) {
      setState(() {
        _hasInputChanged = true;
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _startController.removeListener(_onTextChanged);
    _endController.removeListener(_onTextChanged);
    WidgetsBinding.instance.removeObserver(this);
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted && !_isDrawerOpen) {
        setState(() {
          _isDrawerOpen = true;
        });
      }
      // 1. Standard flow: If navigation started from this Map Screen
      if (navigatedToMap && selectedResult != null) {
        navigatedToMap = false;
        _showReturnDialog(selectedResult!);
      }
      // 2. NEW flow: If navigation started from the Dashboard Screen
      else if (CustomerMapScreen.isNavigatingFromDashboard &&
          CustomerMapScreen.nextCustomerToVisit != null) {
        CustomerMapScreen.isNavigatingFromDashboard = false; // Reset flag
        _showReturnDialog(CustomerMapScreen.nextCustomerToVisit!);
      }
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed && navigatedToMap) {
  //     navigatedToMap = false;
  //     if (selectedResult != null) {
  //       _showReturnDialog(selectedResult!);
  //     }
  //   }
  // }

  void _showReturnDialog(Customer result) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.2), width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: NetworkImage(
                      '${ApiConstants.imageBaseUrl}${result.imageUrl}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.businessName!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 10),
              CustomText(
                content: 'Reached Customer?'.tr,
                fontSize: 17,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    // 1. Capture provider while context is valid
                    final dashProvider =
                        Provider.of<CustomersProvider>(context, listen: false);

                    // 2. Close the Dialog
                    Navigator.of(context).pop();

                    // 3. Mark as visited
                    // (This will work now because we initialized the list in Step 1)
                    await customerAndOrderController
                        .markAsVisited(result.customerId!);

                    // 4. Close the Map Screen
                    Get.back();

                    // 5. Use addPostFrameCallback
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Switch Tab to Customers (Index 1)
                      homeController.sidebarXController.selectIndex(1);
                      homeController.selectedIndex.value = 1;

                      // Update Controllers
                      customerAndOrderController
                          .setCustomerId(result.customerId!);
                      productsController.selectedCustomerName.value =
                          result.businessName!;
                      productsController.selectedCustomerId.value =
                          result.customerId!;
                      productsController.selectedCustomerImageUrl.value =
                          result.imageUrl!;
                      productsController.onReached(true);

                      // Fetch Data
                      dashProvider
                          .fetchCustomerDashboardData(result.customerId!);
                      dashProvider.fetchCustomerDashboardRevenueData(
                          result.customerId!);
                      dashProvider.fetchCustomerDashboardDataSalseData(
                          result.customerId!);
                      dashProvider.fetchCustomersDataDash(result.customerId!);
                      dashProvider
                          .fetchCustomerDashboardCountData(result.customerId!);

                      // Navigate to Dashboard
                      Get.to(
                        () => CustomerDachScreen(
                          cusId: result.customerId!,
                          cusName: result.businessName!,
                          cusImage: result.imageUrl!,
                          cusEmail: result.email!,
                          cusMobile: result.mobileno!,
                          isFromCalendar: true,
                          isFromGoogle: true,
                          eventIds: widget.eventIds,
                          customerIds: widget.customerIds,
                        ),
                        id: 2,
                      );
                    });
                  },
                  child:  Text("Go to Customer".tr,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (subscriptionController.visitNavigation.value ==
                        "true") {
                      selectedResult = result;
                      navigatedToMap = true;
                      final currentLatitude =
                          _mapController.currentLatLng.value?.latitude ?? 0.0;
                      final currentLongitude =
                          _mapController.currentLatLng.value?.longitude ?? 0.0;

                      navigateToo(
                        currentLatitude,
                        currentLongitude,
                        double.parse(result.latitude!),
                        double.parse(result.longitude!),
                      );
                    } else {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => const UpgradePlanScreen(),
                      );
                    }
                  },
                  child:  Text('Continue Navigation'.tr),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // NEW: Ensure drawer remains open when popup is cancelled
                    if (mounted && !_isDrawerOpen) {
                      setState(() {
                        _isDrawerOpen = true;
                      });
                    }
                  },
                  child:
                      Text('Cancel'.tr, style: TextStyle(color: Colors.grey[600])),
                ),
                // TextButton(
                //   onPressed: () => Navigator.of(context).pop(),
                //   child:
                //       Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Clear customer context before going back
        final productsController = Get.find<ProductsController>();
        productsController.selectedCustomerId.value = '';
        productsController.selectedCustomerName.value = '';
        productsController.customerAndOrderData.update((val) {
          if (val != null) val.customerId = '';
        });

        final customerOrderController = Get.find<CustomerAndOrderController>();
        customerOrderController.setCustomerId('');
        customerOrderController.isActive.value = false;

        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 50,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // 1. MAIN CONTENT (MAP)
            Positioned.fill(
              child: Obx(() {
                if (_mapController.isShowRouteLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _mapController.buildGoogleMap();
              }),
            ),

            // 2. SIDEBAR (FIXED LEFT STRIP)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Container(
                  width: 50,
                  color: primaryColor.withOpacity(0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          size: 24,
                          color: primaryColor,
                        ),
                        onPressed: _toggleDrawer,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. OVERLAY (Closes drawer on tap)
            if (_isDrawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDrawerOpen = false;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),

            // 4. SLIDING DRAWER CONTENT
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: 0,
              bottom: 0,
              left: _isDrawerOpen ? 50 : -_drawerWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Container(
                  width: _drawerWidth,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 2,
                    )
                  ]),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // -- AUTOCOMPLETE FIELD: START LOCATION --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildAutoCompleteField(
                          hint: 'Start Location',
                          icon: Icons.my_location,
                          controller: _startController,
                          onLocationSelected: (latLng, address) {
                            _startLatLng = latLng;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // -- AUTOCOMPLETE FIELD: DESTINATION --
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildAutoCompleteField(
                          hint: 'Destination',
                          icon: Icons.location_on,
                          controller: _endController,
                          onLocationSelected: (latLng, address) {
                            _endLatLng = latLng;
                            if (!_hasInputChanged)
                              setState(() => _hasInputChanged = true);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // -- GO BUTTON --
                      if (_hasInputChanged)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _isRouteCalculating
                                  ? null
                                  : () async {
                                      // 1. Validation
                                      if (_startLatLng == null ||
                                          _endLatLng == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Please select start and destination points"),
                                        ));
                                        return;
                                      }

                                      setState(
                                          () => _isRouteCalculating = true);

                                      try {
                                        // 2. Update Controller State
                                        _mapController.currentLatLng.value =
                                            _startLatLng;
                                        _mapController.searchedLatLng.value =
                                            _endLatLng;

                                        // 3. Prepare Data for API (Credit Debit)
                                        // We use the customers currently selected/visible in controller
                                        List<String> addresses = _mapController
                                            .selectedCustomers
                                            .map((customer) =>
                                                customer.address.toString())
                                            .toList();

                                        // 4. API Call: Debit Credits
                                        var creditResponse =
                                            await ApiWorker().debitRouteCredits(
                                          amount: addresses.length *
                                              3, // Logic from dialog
                                          details: 'ROUTE_UPDATE',
                                          addresses: addresses,
                                        );

                                        // Update UI with new credit balance
                                        await _mapController.updateCredit(
                                          creditResponse.credit.toString(),
                                        );

                                        // 5. Refresh Route on Map
                                        await _mapController.getDirections();

                                        // 6. Fetch Metrics (Time/Distance)
                                        await _mapController
                                            .fetchDistanceAndTime();

                                        // Clear Cache to force refresh of legs
                                        setState(() {
                                          _distanceDurationCache.clear();
                                        });
                                      } catch (e) {
                                        print("Error updating route: $e");
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text("Failed to update route"),
                                        ));
                                      } finally {
                                        if (mounted)
                                          setState(() =>
                                              _isRouteCalculating = false);
                                      }
                                    },
                              child: _isRouteCalculating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text("Refresh route map",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),

                      // Header and Start Navigation Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              'Customer List'.tr,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.green, size: 20),
                              label:  Text("Start Navigation".tr,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                                          onPressed: () async {
                              final nextCustomer = _getNextUnvisitedCustomer();

                              if (nextCustomer != null) {
                                if (subscriptionController
                                        .visitNavigation.value ==
                                    "true") {
                                  // --- 1. CHECK ATTENDANCE STATUS ---
                                  bool isAttendanceCheckedIn =
                                      await ApiWorker().loadSwitchState();

                                  if (!isAttendanceCheckedIn) {
                                    // Show the required check-in dialog
                                    bool? confirmCheckIn =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          titlePadding:
                                              const EdgeInsets.fromLTRB(
                                                  16.0, 16.0, 16.0, 0),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  16.0, 8.0, 16.0, 12.0),
                                          actionsPadding:
                                              const EdgeInsets.fromLTRB(
                                                  16.0, 0, 16.0, 16.0),
                                          title: const Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 25.0,
                                                color:
                                                    primaryColor, // Assuming primaryColor is globally defined in your file
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Required',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: const Text(
                                            'You are required to sign in to proceed with navigation.',
                                            style: TextStyle(
                                              fontSize: 19.0,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          actions: [
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 10.0),
                                                side: const BorderSide(
                                                    color: primaryColor,
                                                    width: 2.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                backgroundColor: Colors.white,
                                                elevation: 3,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 10.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                elevation: 4,
                                                shadowColor: primaryColor
                                                    .withOpacity(0.4),
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text(
                                                'Check-In',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmCheckIn == true) {
                                  
                                      await CheckInService()
                                          .performCheckIn(context);

                                    
                                      bool verifyAttendance =
                                          await ApiWorker().loadSwitchState();
                                      if (!verifyAttendance) {
                                      
                                        return;
                                      }
                                    } else {
                                     
                                      return;
                                    }
                                  }
                                 

                                 
                                  selectedResult = nextCustomer;
                                  navigatedToMap = true;
                                  final currentLatitude = _mapController
                                          .currentLatLng.value?.latitude ??
                                      0.0;
                                  final currentLongitude = _mapController
                                          .currentLatLng.value?.longitude ??
                                      0.0;

                                  // Close drawer and start nav
                                  setState(() => _isDrawerOpen = false);

                                  navigateToo(
                                    currentLatitude,
                                    currentLongitude,
                                    double.parse(nextCustomer.latitude!),
                                    double.parse(nextCustomer.longitude!),
                                  );
                                } else {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) =>
                                        const UpgradePlanScreen(),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      "Route completed! All customers visited."),
                                  backgroundColor: Colors.green,
                                ));
                              }
                            },
                              // onPressed: () {
                              //   final nextCustomer =
                              //       _getNextUnvisitedCustomer();
                              //   if (nextCustomer != null) {
                              //     if (subscriptionController
                              //             .visitNavigation.value ==
                              //         "true") {
                              //       selectedResult = nextCustomer;
                              //       navigatedToMap = true;
                              //       final currentLatitude = _mapController
                              //               .currentLatLng.value?.latitude ??
                              //           0.0;
                              //       final currentLongitude = _mapController
                              //               .currentLatLng.value?.longitude ??
                              //           0.0;

                              //       // Close drawer and start nav
                              //       setState(() => _isDrawerOpen = false);

                              //       navigateToo(
                              //         currentLatitude,
                              //         currentLongitude,
                              //         double.parse(nextCustomer.latitude!),
                              //         double.parse(nextCustomer.longitude!),
                              //       );
                              //     } else {
                              //       showDialog(
                              //         barrierDismissible: false,
                              //         context: context,
                              //         builder: (context) =>
                              //             const UpgradePlanScreen(),
                              //       );
                              //     }
                              //   } else {
                              //     Get.snackbar(
                              //       "Success",
                              //       "You have already completed all your visits.",
                              //       backgroundColor: Colors.green,
                              //       colorText: Colors.white,
                              //       snackPosition: SnackPosition.TOP,
                              //       margin: const EdgeInsets.all(10),
                              //     );
                              //     // ScaffoldMessenger.of(context)
                              //     //     .showSnackBar(const SnackBar(
                              //     //   content: Text(
                              //     //       "Route completed! All customers visited."),
                              //     //   backgroundColor: Colors.green,
                              //     // ));
                              //   }
                              // },
                            ),
                          ],
                        ),
                      ),
                      _buildRouteSummary(),

                      const Divider(),

                      // List of Customers
                      Expanded(
                        child: Obx(() {
                          if (_mapController.isShowRouteLoading.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final displayList = _mapController.selectedCustomers;
                          log('displaylistsssss: ${jsonEncode(displayList.map((e) => e.toJson()).toList())}');
                          if (displayList.isEmpty) {
                            return const Center(child: Text("No routes found"));
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final result = displayList[index];
                              if (!_distanceDurationCache
                                      .containsKey(result.customerId) &&
                                  _mapController.currentLatLng.value != null) {
                                fetchLegDistanceAndDuration(
                                    result, index, displayList);
                              }
                              final cacheKey = "${index}_${result.customerId}";
                              final distance = _distanceDurationCache[cacheKey]
                                      ?['distance'] ??
                                  '...';
                              final duration = _distanceDurationCache[cacheKey]
                                      ?['duration'] ??
                                  '...';
                              final isLoading =
                                  _isLoadingDistance[result.customerId] == true;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    onTap: () {
                                      if (result.latitude != null &&
                                          result.longitude != null) {
                                        _mapController.zoomToLocation(
                                          double.parse(result.latitude!),
                                          double.parse(result.longitude!),
                                        );
                                        // Close drawer after selection to see map
                                        setState(() {
                                          _isDrawerOpen = false;
                                        });
                                      }
                                    },
                                    // FIX 1: Added SizedBox to prevent "Leading widget consumes entire width" error
                                    leading: SizedBox(
                                      width: 60,
                                      // 1. We PUT OBX BACK because visitedCustomerIds is now reactive (.obs)
                                      // This ensures the checkmark appears immediately without refreshing.
                                      child: Obx(() {
                                        // 2. We REMOVED "(... ?? [])"
                                        // Since we defined it as RxSet in the controller, it is never null.
                                        bool isVisited =
                                            customerAndOrderController
                                                .visitedCustomerIds
                                                .contains(result.customerId);

                                        if (isVisited) {
                                          return const Center(
                                            child: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.green,
                                              child: Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 18),
                                            ),
                                          );
                                        }
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${index + 1}.",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: CircleAvatar(
                                                radius: 18,
                                                backgroundImage: NetworkImage(
                                                  '${ApiConstants.imageBaseUrl}${result.imageUrl}',
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    title: CustomText(
                                      content: result.businessName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 12, color: Colors.red),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                result.address!,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                    EneftyIcons.routing_outline,
                                                    color: primaryColor,
                                                    size: 14),
                                                const SizedBox(width: 2),
                                                isLoading
                                                    ? const SizedBox(
                                                        width: 10,
                                                        height: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2))
                                                    : Text(distance,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 11)),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                    EneftyIcons.clock_2_outline,
                                                    color: Colors.red,
                                                    size: 14),
                                                const SizedBox(width: 2),
                                                isLoading
                                                    ? const SizedBox(
                                                        width: 10,
                                                        height: 10,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2))
                                                    : Text(duration,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 11)),
                                              ],
                                            ),
                                            Obx(() {
                                              if (_mapController
                                                      .currentLatLng.value ==
                                                  null) {
                                                return const SizedBox(
                                                    width: 15,
                                                    height: 15,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2));
                                              }
                                              return 
                                               InkWell(
                                              onTap: () async {
                                                if (subscriptionController
                                                        .visitNavigation
                                                        .value ==
                                                    "true") {
                                                  // --- 1. CHECK ATTENDANCE STATUS ---
                                                  bool isAttendanceCheckedIn =
                                                      await ApiWorker()
                                                          .loadSwitchState();

                                                  if (!isAttendanceCheckedIn) {
                                                    // Show the required check-in dialog
                                                    bool? confirmCheckIn =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          titlePadding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  16.0,
                                                                  16.0,
                                                                  16.0,
                                                                  0),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  16.0,
                                                                  8.0,
                                                                  16.0,
                                                                  12.0),
                                                          actionsPadding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  16.0,
                                                                  0,
                                                                  16.0,
                                                                  16.0),
                                                          title: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .warning_amber_rounded,
                                                                size: 25.0,
                                                                color:
                                                                    primaryColor, 
                                                              ),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Text(
                                                                'Required',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          content: const Text(
                                                            'You are required to sign in to proceed with navigation.',
                                                            style: TextStyle(
                                                              fontSize: 19.0,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                          actions: [
                                                            OutlinedButton(
                                                              style:
                                                                  OutlinedButton
                                                                      .styleFrom(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0,
                                                                    vertical:
                                                                        10.0),
                                                                side: const BorderSide(
                                                                    color:
                                                                        primaryColor,
                                                                    width: 2.0),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                elevation: 3,
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          false),
                                                              child: const Text(
                                                                'Cancel',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color:
                                                                      primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    primaryColor,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0,
                                                                    vertical:
                                                                        10.0),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                                elevation: 4,
                                                                shadowColor:
                                                                    primaryColor
                                                                        .withOpacity(
                                                                            0.4),
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true),
                                                              child: const Text(
                                                                'Check-In',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    if (confirmCheckIn ==
                                                        true) {
                                               
                                                      await CheckInService()
                                                          .performCheckIn(
                                                              context);

                                                      
                                                      bool verifyAttendance =
                                                          await ApiWorker()
                                                              .loadSwitchState();
                                                      if (!verifyAttendance) {
                                                 
                                                        return;
                                                      }
                                                    } else {
                                                    
                                                      return;
                                                    }
                                                  }
                                                  
                                                  selectedResult =
                                                      result; 
                                                  navigatedToMap = true;
                                                  final currentLatitude =
                                                      _mapController
                                                              .currentLatLng
                                                              .value
                                                              ?.latitude ??
                                                          0.0;
                                                  final currentLongitude =
                                                      _mapController
                                                              .currentLatLng
                                                              .value
                                                              ?.longitude ??
                                                          0.0;

                                                  
                                                  setState(() =>
                                                      _isDrawerOpen = false);

                                                  navigateToo(
                                                    currentLatitude,
                                                    currentLongitude,
                                                    double.parse(
                                                        result.latitude!),
                                                    double.parse(
                                                        result.longitude!),
                                                  );
                                                } else {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) =>
                                                        const UpgradePlanScreen(),
                                                  );
                                                }
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                    Icons.near_me_outlined,
                                                    size: 18,
                                                    color: Colors.blue),
                                              ),
                                            );
                                              // InkWell(
                                              //   onTap: () {
                                              //     if (subscriptionController
                                              //             .visitNavigation
                                              //             .value ==
                                              //         "true") {
                                              //       selectedResult = result;
                                              //       navigatedToMap = true;
                                              //       final currentLatitude =
                                              //           _mapController
                                              //                   .currentLatLng
                                              //                   .value
                                              //                   ?.latitude ??
                                              //               0.0;
                                              //       final currentLongitude =
                                              //           _mapController
                                              //                   .currentLatLng
                                              //                   .value
                                              //                   ?.longitude ??
                                              //               0.0;

                                              //       // Close drawer
                                              //       setState(() =>
                                              //           _isDrawerOpen = false);

                                              //       navigateToo(
                                              //         currentLatitude,
                                              //         currentLongitude,
                                              //         double.parse(
                                              //             result.latitude!),
                                              //         double.parse(
                                              //             result.longitude!),
                                              //       );
                                              //     } else {
                                              //       showDialog(
                                              //         barrierDismissible: false,
                                              //         context: context,
                                              //         builder: (context) =>
                                              //             const UpgradePlanScreen(),
                                              //       );
                                              //     }
                                              //   },
                                              //   child: const Padding(
                                              //     padding: EdgeInsets.all(4.0),
                                              //     child: Icon(
                                              //         Icons.near_me_outlined,
                                              //         size: 18,
                                              //         color: Colors.blue),
                                              //   ),
                                              // );
                                            })
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the autocomplete text field within the drawer constraints
  Widget _buildAutoCompleteField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(LatLng, String) onLocationSelected,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Autocomplete<Map<String, dynamic>>(
            initialValue: TextEditingValue(text: controller.text),
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text == '') {
                return const Iterable<Map<String, dynamic>>.empty();
              }
              // Call controller's fetch function
              return await _mapController
                  .fetchAutoCompletePlaces(textEditingValue.text);
            },
            displayStringForOption: (Map<String, dynamic> option) {
              return option['description'] ?? '';
            },
            onSelected: (Map<String, dynamic> selection) async {
              controller.text = selection['description'];
              final placeId = selection['place_id'];
              if (placeId != null) {
                LatLng? coords =
                    await _mapController.getLatLngFromPlaceId(placeId);
                if (coords != null) {
                  onLocationSelected(coords, selection['description']);
                }
              }
            },
            fieldViewBuilder:
                (context, textController, focusNode, onFieldSubmitted) {
              // Sync texts
              if (textController.text != controller.text) {
                textController.text = controller.text;
              }
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: hint,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: textController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            textController.clear();
                            controller.clear();
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  controller.text = val;
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    // Constrain width to slightly less than drawer width
                    width: _drawerWidth - 60,
                    constraints: const BoxConstraints(maxHeight: 200),
                    color: Colors.white,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          dense: true,
                          title: Text(
                            option['description'],
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSummary() {
    final totals = _calculateRouteTotals();
    final bool isEmpty = totals['distance'] == "0.0 km";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Total Distance
          Row(
            children: [
              const Icon(EneftyIcons.routing_2_bold,
                  color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Distance",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    isEmpty ? "--" : totals['distance']!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Container(height: 30, width: 1, color: Colors.grey[300]), // Divider
          // Total Time
          Row(
            children: [
              const Icon(EneftyIcons.clock_bold,
                  color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Est. Time",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    isEmpty ? "--" : totals['duration']!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. Helper to parse string distance (e.g., "5.4 km" or "500 m") to double km
  double _parseDistance(String distString) {
    if (distString == '-' || distString == '...') return 0.0;
    try {
      // Remove commas (e.g. 1,000 km)
      String clean = distString.replaceAll(',', '');
      if (clean.contains('km')) {
        return double.parse(clean.replaceAll('km', '').trim());
      } else if (clean.contains('m')) {
        // Convert meters to km
        return double.parse(clean.replaceAll('m', '').trim()) / 1000;
      }
    } catch (e) {
      return 0.0;
    }
    return 0.0;
  }

  // 2. Helper to parse string duration (e.g. "1 hour 5 mins") to total minutes
  int _parseDurationToMinutes(String durString) {
    if (durString == '-' || durString == '...') return 0;
    int totalMinutes = 0;
    try {
      String clean = durString.replaceAll(',', '');

      // Parse Days
      if (clean.contains('day')) {
        final dayMatch = RegExp(r'(\d+)\s?day').firstMatch(clean);
        if (dayMatch != null) {
          totalMinutes += int.parse(dayMatch.group(1)!) * 24 * 60;
        }
      }

      // Parse Hours
      if (clean.contains('hour')) {
        final hourMatch = RegExp(r'(\d+)\s?hour').firstMatch(clean);
        if (hourMatch != null) {
          totalMinutes += int.parse(hourMatch.group(1)!) * 60;
        }
      }

      // Parse Minutes
      if (clean.contains('min')) {
        final minMatch = RegExp(r'(\d+)\s?min').firstMatch(clean);
        if (minMatch != null) {
          totalMinutes += int.parse(minMatch.group(1)!);
        }
      }
    } catch (e) {
      return 0;
    }
    return totalMinutes;
  }

  // 3. Main function to build the summary string
  Map<String, String> _calculateRouteTotals() {
    double totalDistKm = 0.0;
    int totalDurationMins = 0;
    int loadedSegments = 0;

    // Iterate through the cache to sum up values
    _distanceDurationCache.forEach((key, value) {
      String dText = value['distance'] ?? '';
      String tText = value['duration'] ?? '';

      if (dText != '-' && dText != '...') {
        totalDistKm += _parseDistance(dText);
        totalDurationMins += _parseDurationToMinutes(tText);
        loadedSegments++;
      }
    });

    // Format Duration back to readable string (e.g., 2h 15m)
    int hours = totalDurationMins ~/ 60;
    int minutes = totalDurationMins % 60;
    String timeString = "";
    if (hours > 0) timeString += "${hours}h ";
    timeString += "${minutes}m";

    return {
      'distance': "${totalDistKm.toStringAsFixed(1)} km",
      'duration': timeString.trim(),
      'loaded': loadedSegments.toString(), // To optionally show progress
    };
  }
}
