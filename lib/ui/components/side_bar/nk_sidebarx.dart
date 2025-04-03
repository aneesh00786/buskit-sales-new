// ignore: file_names
import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_network_image.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/auth_model/login_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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

class _NkSidebarXSideBarState extends State<NkSidebarXSideBar> {
  bool _onSwitchSelected = false;
  bool _isLoading = true;
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
  ProductsController productsController = Get.put(ProductsController());
  PendingPaymentController pendingPaymentController =
      Get.put(PendingPaymentController());
    SearchModel searchData = SearchModel();
  final ApiWorker _apiWorker = ApiWorker();
  TabController? _tabController;
  TabController? get tabController => _tabController;
  final int currentYear = DateTime.now().year;
  @override
  void initState() {
    super.initState();
    ApiWorker().loadSwitchState().then((value) {
      if (mounted) {
        setState(() {
          _onSwitchSelected = value;
          _isLoading = false;
        });
      }
    });
    log('Switch state: $_onSwitchSelected');
  }

  @override
  Widget build(BuildContext context) {
    log('ImagePath Side : ${widget.userDetails.imagePath}');
    final dashboardProvider =
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
                        onSync: () async {
                          DateTime now = DateTime.now();
                          DateTime firstDayOfMonth =
                              DateTime(now.year, now.month, 1);
                          DateTime lastDayOfMonth =
                              DateTime(now.year, now.month + 1, 0);
                          String firstDayString =
                              DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
                          String lastDayString =
                              DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
                          DateTime? initialDay;
                          final companyId =
                              SessionHelper.loginSavedData?.company_id ?? 0;
                          final salesmanId =
                              SessionHelper.loginSavedData?.salesmanId ?? '';
                      
                          dashboardProvider.resetProvider();
                          dashboardProvider.fetchData();
                          dashboardProvider.fetchChatData(salesmanId);
                          await Future.delayed(const Duration(seconds: 2));
                          final settings =
                              await _apiWorker.fetchAllSettings(companyId);
                          await Future.delayed(const Duration(microseconds: 500));
                          // ignore: use_build_context_synchronously
                          await Provider.of<CustomersProvider>(context,
                                  listen: false)
                              .fetchCustomerData();
                          await customerAndOrderController.loadCustomer();
                          await Future.delayed(const Duration(microseconds: 500));
                          await productsController.fetchCategoryData();
                          await Future.delayed(const Duration(microseconds: 500));
                          await ApiWorker()
                              .fetchRecentOrderCount(startDate: '', endDate: '');
                          await Future.delayed(const Duration(microseconds: 500));
                          await pendingPaymentController.loadOrderData(
                              chartIndex: 0, compId: companyId, isLogin: true);
                          await Future.delayed(const Duration(microseconds: 500));
                          await staffController.loadSalesmanTargetForSelectedTab(
                              currentYear: currentYear.toString(),
                              selectedTabIndex: _tabController?.index ?? 0 + 1,
                              staffId: salesmanId);
                      
                          if (settings != null) {
                            await SessionHelper().setSettingsData(settings);
                          }
                          SubCategoryItem? subCategoryItem =
                              productsController.getInitialSubCategoryIdAndName();
                          if (subCategoryItem != null &&
                              (subCategoryItem.id ?? '').isNotEmpty) {
                            await productsController
                                .fetchProducts(subCategoryItem.id!);
                          } else {
                            log("No subcategory found. Products not fetched.");
                          }
                          await Future.delayed(const Duration(microseconds: 500));
                          await leadsController.loadLeadsCustomerData;
                          await leadsCustomerController.loadLeadsCustomerData;
                          await leadsRejectedController.loadRejectedLeadsData;
                          await Future.delayed(const Duration(microseconds: 500));
                          ApiWorker().getRecentOrdersData(
                            searchModel: searchData,
                            orderStatus: 11,
                            isLogin: false,
                            startDate: firstDayString,
                            endDate: lastDayString,
                          );
                          await calenderMapController
                              .fetchCalenderEvents(initialDay ?? DateTime.now());
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Syncing offline orders...'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            content:
                                widget.userDetails.fullname?.toUpperCase() ??
                                    'No Data',
                            fontSize: ResponsiveInfo.isMobile() ? 15 : 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomText(
                            content: widget.userDetails.email ?? 'No Data',
                            fontSize: ResponsiveInfo.isMobile() ? 8 : 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 35,
                        child: _isLoading
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
                                          child: _isLoading
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
                              ),
                      ),
                    ],
                  ),
                )
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

  Future<bool> _handleLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (status.isGranted) {
        return true;
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      bool? openSettings = await showDialog<bool>(
        // ignore: use_build_context_synchronously
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

    return true; // Already granted
  }

  void _handleSwitchToggle(BuildContext context) async {
    bool newState = !_onSwitchSelected;

    // Show confirmation dialog
    bool? confirmAction = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(newState ? 'Confirm Check-In' : 'Confirm Check-Out'),
          content: Text(
              'Are you sure you want to ${newState ? 'check in' : 'check out'}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmAction == true) {
      // ignore: use_build_context_synchronously
      if (!await _handleLocationPermission(context)) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        Position position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high,
        );

        final response = await ApiWorker().updateAdminCheckInOut(
          date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
          time: DateFormat('HH:mm').format(DateTime.now()),
          direction: newState ? "in" : "out",
          lat: position.latitude.toString(),
          long: position.longitude.toString(),
        );

        if (response.statusCode == 200) {
          await ApiWorker().saveSwitchState(newState);

          if (mounted) {
            setState(() {
              _onSwitchSelected = newState;
            });
          }
        }
      } catch (e) {
        log('Error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
