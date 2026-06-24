// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/location_services/location_services.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/sync_button/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:busskit_salesexecutive/ui/services/permission_status_service.dart';
import 'package:busskit_salesexecutive/ui/services/checkin_service.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class NkSidebarXSideBar extends StatefulWidget {
  const NkSidebarXSideBar({
    super.key,
    required List<SidebarXItem> itemList,
    required SidebarXController controller,
    required this.userDetails,
  })  : _controller = controller,
        _itemList = itemList;

  final SidebarXController _controller;
  final List<SidebarXItem> _itemList;
  final LoginData userDetails;

  @override
  State<NkSidebarXSideBar> createState() => _NkSidebarXSideBarState();
}

class _NkSidebarXSideBarState extends State<NkSidebarXSideBar> with WidgetsBindingObserver {
  bool _onSwitchSelected = false;
  bool _isLoading = true;
  bool _hasAlwaysPermission = false;
  bool _pendingSettingsReturn = false;
   Timer? _foregroundTimer;
  StaffController staffController = Get.put(StaffController());
  LeadsController leadsController = Get.put(LeadsController());
  CustomersController leadsCustomerController = Get.put(CustomersController());
  OrderController orderController = Get.put(OrderController());
  CalenderMapController calenderMapController =
      Get.put(CalenderMapController());
  RejectedLeadsController leadsRejectedController =
      Get.put(RejectedLeadsController());
  CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  ProductsController productsController = Get.find<ProductsController>();
  PendingPaymentController pendingPaymentController =
      Get.put(PendingPaymentController());
  SearchModel searchData = SearchModel();
  TabController? _tabController;
  TabController? get tabController => _tabController;
  final int currentYear = DateTime.now().year;
  Worker? _checkingInWorker;
  @override
  void initState() {
    super.initState();
    // Register lifecycle observer to detect when app returns from settings
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize permission status service and set up listener
    _initializePermissionStatus();
    
    _checkingInWorker = ever(CheckInService.isCheckingIn, (bool isChecking) {
      if (!isChecking) {
        ApiWorker().loadSwitchState().then((value) {
          if (mounted) {
            setState(() {
              _onSwitchSelected = value;
            });
          }
        });
      }
    });
    
    ApiWorker().loadSwitchState().then((value) {
      if (mounted) {
        setState(() {
          _onSwitchSelected = value;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _initializePermissionStatus() async {
    final permissionService = PermissionStatusService();
    print("=== Sidebar initializing permission service ===");
    
    // Wait for permission service to initialize and get current status
    await permissionService.initialize();
    
    // Get current permission status after initialization
    var alwaysStatus = await Permission.locationAlways.status;
    bool currentPermissionStatus = alwaysStatus.isGranted;
    
    print("=== Sidebar permission service initialized ===");
    print("=== Current permission status: $currentPermissionStatus ===");
    
    // Set initial permission status
    if (mounted) {
      setState(() {
        _hasAlwaysPermission = currentPermissionStatus;
      });
    }
    
    print("=== Sidebar adding listener to permission service ===");
    permissionService.addListener(() {
      print("=== Sidebar listener called, new permission status: ${permissionService.hasAlwaysPermission} ===");
      if (mounted) {
        setState(() {
          _hasAlwaysPermission = permissionService.hasAlwaysPermission;
        });
      }
    });
  }

  @override
  void dispose() {
    _checkingInWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
      _stopForegroundTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from settings OR from iOS permission popup
    if (state == AppLifecycleState.resumed) {
      if (_pendingSettingsReturn) {
        _pendingSettingsReturn = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<DashboardProvider>(context, listen: false);
    return OrientationBuilder(builder: (context, orientation) {
      return SidebarX(
        controller: widget._controller,
        headerDivider: Container(
          color: primaryColor,
        ),
        theme: SidebarXTheme(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(color: primaryTextColor),
          selectedTextStyle: const TextStyle(color: primaryColor),
          selectedItemDecoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            border: const Border(
              left: BorderSide(
                color: primaryColor,
                width: 5.0,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.black.withOpacity(0.4),
            size: 24,
          ),
          selectedIconTheme: const IconThemeData(
            color: primaryColor,
            size: 24,
          ),
        ),
        showToggleButton: false,
        headerBuilder: (context, extended) {
          return Container(
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkResponse(
                          onTap: () => {
                                HomeController.homeScaffoldKey.currentState
                                    ?.closeDrawer(),
                              },
                          child: Icon(
                            EneftyIcons.menu_outline,
                            size: ResponsiveInfo.isMobile() ? 24 : 32,
                            color: white,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SyncButtonWidget(
                        // onSync: () async {
                        //   DateTime now = DateTime.now();
                        //   DateTime firstDayOfMonth =
                        //       DateTime(now.year, now.month, 1);
                        //   DateTime lastDayOfMonth =
                        //       DateTime(now.year, now.month + 1, 0);
                        //   String firstDayString =
                        //       DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
                        //   String lastDayString =
                        //       DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
                        //   DateTime? initialDay;
                        //   final companyId =
                        //       SessionHelper.loginSavedData?.company_id ?? 0;
                        //   final salesmanId =
                        //       SessionHelper.loginSavedData?.salesmanId ?? '';

                        //   dashboardProvider.resetProvider();
                        //   dashboardProvider.fetchData();
                        //   dashboardProvider.fetchChatData(salesmanId);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.delivered,
                        //       isLogin: true);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.estimates,
                        //       checkDate: true,
                        //       isLogin: true);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.estimates,
                        //       checkDate: false,
                        //       isLogin: true);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.preOrder,
                        //       checkDate: true,
                        //       isLogin: true);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.preOrder,
                        //       checkDate: false,
                        //       isLogin: true);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.draft,
                        //       isLogin: true);
                        //   await dashboardProvider.fetchOrdersData(
                        //       OrderStatus.cancelled,
                        //       isLogin: true);
                        //   await Future.delayed(const Duration(seconds: 2));
                        //   final settings =
                        //       await _apiWorker.fetchAllSettings(companyId);
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   await Provider.of<CustomersProvider>(context,
                        //           listen: false)
                        //       .fetchCustomerData();
                        //   await customerAndOrderController.loadCustomer();
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   await productsController.fetchCategoryData();
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   await ApiWorker().fetchRecentOrderCount(
                        //       startDate: '', endDate: '');
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   await pendingPaymentController.loadOrderData(
                        //       chartIndex: 0, compId: companyId, isLogin: true);
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   await staffController
                        //       .loadSalesmanTargetForSelectedTab(
                        //           currentYear: currentYear.toString(),
                        //           selectedTabIndex:
                        //               _tabController?.index ?? 0 + 1,
                        //           staffId: salesmanId);

                        //   if (settings != null) {
                        //     await SessionHelper().setSettingsData(settings);
                        //   }
                        //   SubCategoryItem? subCategoryItem = productsController
                        //       .getInitialSubCategoryIdAndName();
                        //   if (subCategoryItem != null &&
                        //       (subCategoryItem.id ?? '').isNotEmpty) {
                        //     await productsController
                        //         .fetchProducts(subCategoryItem.id!);
                        //   } else {
                        //     log("No subcategory found. Products not fetched.");
                        //   }
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   await leadsController.loadLeadsCustomerData;
                        //   await leadsCustomerController.loadLeadsCustomerData;
                        //   await leadsRejectedController.loadRejectedLeadsData;
                        //   await Future.delayed(
                        //       const Duration(microseconds: 500));
                        //   ApiWorker().getRecentOrdersData(
                        //     searchModel: searchData,
                        //     orderStatus: 11,
                        //     isLogin: false,
                        //     startDate: firstDayString,
                        //     endDate: lastDayString,
                        //   );
                        //   await calenderMapController.fetchCalenderEvents(
                        //       initialDay ?? DateTime.now());
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       content: Text('Syncing offline orders...'),
                        //       backgroundColor: Colors.blue,
                        //     ),
                        //   );
                        // },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Container(
                    height: ResponsiveInfo.isMobile() ? 70 : 100,
                    width: ResponsiveInfo.isMobile() ? 70 : 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 164, 236, 247),
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: MyNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.userDetails.imagePath ?? '',
                        height: ResponsiveInfo.isMobile() ? 50 : 75,
                        width: ResponsiveInfo.isMobile() ? 50 : 75,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              content:
                                  widget.userDetails.fullname?.toUpperCase() ??
                                      'No Data',
                              fontSize: ResponsiveInfo.isMobile() ? 15 : 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomText(
                              content: widget.userDetails.email ?? 'No Data',
                              fontSize: ResponsiveInfo.isMobile() ? 8 : 12,
                              color: Colors.white,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 35,
                        child: Obx(() {
                          final isChecking = CheckInService.isCheckingIn.value;
                          bool isLoading = _isLoading || isChecking;
                          return isLoading
                              ? const CircularProgressIndicator(color: white)
                              : GestureDetector(
                                  onTap: () => _handleSwitchToggle(context),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 100,
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: _onSwitchSelected
                                          ? const Color.fromARGB(
                                              255, 100, 224, 164)
                                          : const Color.fromARGB(
                                              255, 244, 152, 152),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 15),
                                            child: Text(
                                              'Out',
                                              style: TextStyle(
                                                color: _onSwitchSelected
                                                    ? Colors.transparent
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Text(
                                              'In',
                                              style: TextStyle(
                                                color: !_onSwitchSelected
                                                    ? Colors.transparent
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        AnimatedAlign(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          alignment: _onSwitchSelected
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.white,
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 14,
                                                    height: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : Icon(
                                                    _onSwitchSelected
                                                        ? Icons.check
                                                        : Icons.close,
                                                    size: 20,
                                                    color: _onSwitchSelected
                                                        ? const Color.fromARGB(
                                                            255, 100, 224, 164)
                                                        : const Color.fromARGB(
                                                            255, 244, 152, 152),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ],
                  ),
                ),
                // Show Always Permission Status when Checked In
                if (_onSwitchSelected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasAlwaysPermission
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          color: _hasAlwaysPermission
                              ? Colors.green
                              : Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _hasAlwaysPermission
                                ? 'Background location enabled'
                                : 'Background location disabled - tracking only when app is open',
                            style: TextStyle(
                              color: _hasAlwaysPermission
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        extendedTheme: SidebarXTheme(
          width: AppDimensions.instance.width * 0.7,
          decoration: const BoxDecoration(
            color: backgroundColor,
          ),
        ),
        items: widget._itemList,
      );
    });
  }

  void _handleSwitchToggle(BuildContext context) async {
    bool newState = !_onSwitchSelected;

    // Initial Confirmation - Close this dialog FIRST before requesting permissions
    bool? confirmAction = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
          actionsPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          title: Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 25.0,
                color: primaryColor,
              ),
              const SizedBox(width: 8.0),
              Text(
                newState ? 'Confirm Check-In'.tr : 'Confirm Check-Out'.tr,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to'.tr + ' ${newState ? 'check in'.tr : 'check out'.tr}?',
            style: TextStyle(
              fontSize: 19.0,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                side: BorderSide(color: primaryColor, width: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.white,
                elevation: 3,
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel'.tr,
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.4),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Confirm'.tr,
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

    if (confirmAction != true) return;

    // Close any remaining dialogs/popups before proceeding
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);

    setState(() => _isLoading = true);

    try {
      if (newState) {
        // Use the shared CheckInService for check-in
        print("=== Sidebar calling CheckInService().performCheckIn ===");
        await CheckInService().performCheckIn(context);
        
        // After CheckInService completes, reload the switch state and update UI
        bool updatedState = await ApiWorker().loadSwitchState();
        if (mounted) {
          setState(() {
            _onSwitchSelected = updatedState;
          });
        }
        
        // The CheckInService will handle permission status updates
        // and the sidebar listener will automatically update the permission status
      } 
      else {
        // === CHECK OUT LOGIC ===
        setState(() {
          _hasAlwaysPermission = false;
        });

        // Stop background service if running
        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke('stopService');
        }

        // Stop any CheckInService tracking
        CheckInService().stopTracking();

        // Stop foreground tracking if used
        _stopForegroundTracking();

        // --- NEW OFFLINE LOGIC ---
        final connectivityService = ConnectivityService();
        final isOnline = await connectivityService.isOnline();

        final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
        final time = DateFormat('HH:mm').format(DateTime.now());

        if (!isOnline) {
          // OFFLINE: Save checkout request to Hive
          final box = await Hive.openBox('offlineRequests');
          final payload = {
            "companyId": widget.userDetails.company_id ?? 0,
            "date": date,
            "sales_id": widget.userDetails.salesmanId ?? '',
            "time": time,
            "direction": "out",
            "latitude": "0.0",
            "longitude": "0.0",
          };

          await box.add({
            'url': ApiConstants.baseUrl + ApiConstants.updateCheckinOut,
            'payload': payload,
          });

          // Update local state to successfully check out visually
          await ApiWorker().saveSwitchState(false);
          
          if (mounted) {
            setState(() {
              _onSwitchSelected = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text('Offline: Admin Check-out saved locally and will sync when online.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          // ONLINE: Send API for check-out
          final response = await ApiWorker().updateAdminCheckInOut(
            date: date,
            time: time,
            direction: "out",
            lat: "0.0",
            long: "0.0",
          );

          if (response.statusCode == 200) {
            await ApiWorker().saveSwitchState(false);
            if (mounted) {
              setState(() {
                _onSwitchSelected = false;
              });
            }
          }
        }
      }
      // else {
      //   // Handle check-out logic
      //   // Reset permission status on check out
      //   setState(() {
      //     _hasAlwaysPermission = false;
      //   });
        
      //   // === CHECK OUT LOGIC ===
      //   CheckInService().stopTracking();

      //   // Send API for check-out
      //   final response = await ApiWorker().updateAdminCheckInOut(
      //     date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
      //     time: DateFormat('HH:mm').format(DateTime.now()),
      //     direction: "out",
      //     lat: "0.0", // No position needed for check-out
      //     long: "0.0",
      //   );

      //   if (response.statusCode == 200) {
      //     await ApiWorker().saveSwitchState(false);
      //     if (mounted) {
      //       setState(() {
      //         _onSwitchSelected = false;
      //       });
      //     }
      //   }
      // }
    } 
    catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // void _handleSwitchToggle(BuildContext context) async {
  //   bool newState = !_onSwitchSelected;
  //   bool? confirmAction = await showDialog<bool>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(newState ? 'Confirm Check-In' : 'Confirm Check-Out'),
  //         content: Text(
  //             'Are you sure you want to ${newState ? 'check in' : 'check out'}?'),
  //         actions: [
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () => Navigator.of(context).pop(false),
  //           ),
  //           ElevatedButton(
  //             child: const Text('Confirm'),
  //             onPressed: () => Navigator.of(context).pop(true),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirmAction == true) {
  //     if (!await handleLocationPermission(context)) {
  //       return;
  //     }

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     try {
  //       Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high,
  //       );
  //       final response = await ApiWorker().updateAdminCheckInOut(
  //         date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
  //         time: DateFormat('HH:mm').format(DateTime.now()),
  //         direction: newState ? "in" : "out",
  //         lat: position.latitude.toString(),
  //         long: position.longitude.toString(),
  //       );
  //       if (response.statusCode == 200) {
  //         await ApiWorker().saveSwitchState(newState);

  //         if (mounted) {
  //           setState(() {
  //             _onSwitchSelected = newState;
  //           });
  //         }
  //       }
  //     } catch (e) {
  //     //
  //     } finally {
  //       if (mounted) {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     }
  //   }
  // }
   void _stopForegroundTracking() {
    if (_foregroundTimer != null) {
      _foregroundTimer!.cancel();
      _foregroundTimer = null;
      print("Stopped foreground tracking.");
    }
  }
}



Future<bool> _showAlwaysPermissionDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Enable Background Tracking"),
      content: const Text(
        "To track your location even when the app is closed (for accurate attendance), please allow 'Always' permission.\n\n"
        "If you prefer, you can continue with foreground-only tracking (app must stay open)."
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // User chose "No"
          child: const Text("Only while using the app"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true), // User chose to proceed
          child: const Text("Request Always"),
        ),
      ],
    ),
  ) ?? false;
}
Future<bool> handleLocationPermission(BuildContext context) async {
  PermissionStatus status = await Permission.locationWhenInUse.status;

  if (status.isDenied) {
    status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return false;
    }
  } else if (status.isPermanentlyDenied) {
    bool? openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Location permission is permanently denied. Open settings to enable it.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
    return openSettings ?? false;
  }

  return true;
}
