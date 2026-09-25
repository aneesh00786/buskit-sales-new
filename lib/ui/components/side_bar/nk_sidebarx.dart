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
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/sync_button/sync_controller.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
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
import 'package:dio/dio.dart';

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

class _NkSidebarXSideBarState extends State<NkSidebarXSideBar>
    with WidgetsBindingObserver {
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
        CheckInService().checkCheckInTimeout().then((_) {
          ApiWorker().loadSwitchState().then((value) {
            if (mounted) {
              setState(() {
                _onSwitchSelected = value;
              });
            }
          });
        });
      }
    });

    CheckInService().checkCheckInTimeout().then((_) {
      ApiWorker().loadSwitchState().then((value) {
        if (mounted) {
          setState(() {
            _onSwitchSelected = value;
            _isLoading = false;
          });
        }
      });
    });
  }

  Future<void> _initializePermissionStatus() async {
    final permissionService = PermissionStatusService();
    print("=== Sidebar initializing permission service ===");

    // Wait for permission service to initialize and get current status
    await permissionService.initialize();

    // Sync permission status to backend after initialization
    final dioForPermissionSync = Dio();
    dioForPermissionSync.options.connectTimeout = const Duration(seconds: 10);
    dioForPermissionSync.options.receiveTimeout = const Duration(seconds: 10);
    permissionService.sendPermissionToBackend(dio: dioForPermissionSync);

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
      print(
          "=== Sidebar listener called, new permission status: ${permissionService.hasAlwaysPermission} ===");
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
      CheckInService().checkCheckInTimeout().then((timeoutOccurred) {
        if (timeoutOccurred) {
          ApiWorker().loadSwitchState().then((value) {
            if (mounted) {
              setState(() {
                _onSwitchSelected = value;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<DashboardProvider>(context, listen: false);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: AnimatedBuilder(
              animation: widget._controller,
              builder: (context, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget._itemList.length,
                  itemBuilder: (context, index) {
                    final item = widget._itemList[index];
                    final isSelected =
                        widget._controller.selectedIndex == index;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget._controller.selectIndex(index);
                        item.onTap?.call();
                      },
                      child: item.iconBuilder != null
                          ? item.iconBuilder!(isSelected, true)
                          : const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF183884), Color(0xFF11265E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Celestial curved dotted line decoration
          Positioned.fill(
            child: CustomPaint(
              painter: _ConstellationCurvePainter(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkResponse(
                      onTap: () => {
                        HomeController.homeScaffoldKey.currentState
                            ?.closeDrawer(),
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildHeaderSyncWidget(context),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 74,
                      width: 74,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: (widget.userDetails.imagePath ?? '').isNotEmpty
                            ? MyNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: widget.userDetails.imagePath!,
                                height: 74,
                                width: 74,
                                errorWidget: (context, url, error) =>
                                    _avatarInitials(),
                              )
                            : _avatarInitials(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF183884),
                            width: 2.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  widget.userDetails.fullname ?? 'Raj P. Patel',
                  style: const TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  (widget.userDetails.designation ?? '').isNotEmpty
                      ? widget.userDetails.designation!
                      : 'Sales Executive',
                  style: const TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFBFDBFE),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  widget.userDetails.email ?? 'sales1@gmail.com',
                  style: TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF93C5FD).withOpacity(0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(right: 14, bottom: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    final isChecking = CheckInService.isCheckingIn.value;
                    bool isLoading = _isLoading || isChecking;
                    return isLoading
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _onSwitchSelected
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFE15241),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _handleSwitchToggle(context),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(5, 4, 14, 4),
                              decoration: BoxDecoration(
                                color: _onSwitchSelected
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFE15241),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_onSwitchSelected
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFE15241))
                                        .withOpacity(0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _onSwitchSelected
                                          ? Icons.check_rounded
                                          : Icons.close_rounded,
                                      size: 14,
                                      color: _onSwitchSelected
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFE15241),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _onSwitchSelected ? 'In'.tr : 'Out'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                  }),
                ),
              ),
              // Show Always Permission Status when Checked In
              if (_onSwitchSelected)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasAlwaysPermission
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color:
                            _hasAlwaysPermission ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _hasAlwaysPermission
                              ? 'Your location will be shared continuously.'
                              : "Location is shared only while using the app. Enable 'Always' access for background tracking.",
                          style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            color: _hasAlwaysPermission
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                            fontSize: 10.5,
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
    );
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
            'Are you sure you want to'.tr +
                ' ${newState ? 'check in'.tr : 'check out'.tr}?',
            style: TextStyle(
              fontSize: 19.0,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
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
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);

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
      } else {
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
                content: Text(
                    'Offline: Admin Check-out saved locally and will sync when online.'),
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
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _stopForegroundTracking() {
    if (_foregroundTimer != null) {
      _foregroundTimer!.cancel();
      _foregroundTimer = null;
      print("Stopped foreground tracking.");
    }
  }

  Widget _buildHeaderSyncWidget(BuildContext context) {
    final syncController = Get.find<SyncController>()..loadLastSyncTime();
    return Obx(() {
      final isSyncing = syncController.isSyncing.value;
      final lastSync = syncController.lastSyncTime.value;
      final timeStr = lastSync == null
          ? DateFormat('hh:mm a').format(DateTime.now())
          : DateFormat('hh:mm a').format(lastSync);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isSyncing
                  ? null
                  : () async {
                      bool isOnline = await ConnectivityService().isOnline();
                      if (!isOnline) {
                        showCustomToastDisplay(
                          context,
                          "You are offline! Please check your internet connection."
                              .tr,
                          red,
                          Icons.cloud_off_rounded,
                        );
                      } else {
                        syncController.startSyncing(context);
                      }
                    },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.sync_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                    const SizedBox(width: 5),
                    Text(
                      isSyncing ? 'Syncing...'.tr : 'Sync'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins_Regular',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontFamily: 'Poppins_Regular',
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _avatarInitials() {
    final name = widget.userDetails.fullname ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (parts.isNotEmpty && parts.first.isNotEmpty)
            ? parts.first[0].toUpperCase()
            : 'RP';
    const size = 74.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }
}

/// Subtle constellation / starry curved dotted trail painter for sidebar header.
class _ConstellationCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaintMuted = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final dotPaintBright = Paint()
      ..color = const Color(0xFFFBBF24).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Dots placed along a gentle celestial arc
    final List<Offset> starPoints = [
      Offset(size.width * 0.02, size.height * 0.38),
      Offset(size.width * 0.08, size.height * 0.35),
      Offset(size.width * 0.16, size.height * 0.34),
      Offset(size.width * 0.25, size.height * 0.36),
      Offset(size.width * 0.35, size.height * 0.38),
      Offset(size.width * 0.45, size.height * 0.40),
      Offset(size.width * 0.58, size.height * 0.32),
      Offset(size.width * 0.68, size.height * 0.26),
      Offset(size.width * 0.76, size.height * 0.21),
      Offset(size.width * 0.84, size.height * 0.16),
      Offset(size.width * 0.92, size.height * 0.13),
    ];

    for (int i = 0; i < starPoints.length; i++) {
      final pt = starPoints[i];
      final isAccent = (i == 3 || i == 6 || i == 8);
      canvas.drawCircle(
        pt,
        isAccent ? 2.8 : 1.6,
        isAccent ? dotPaintBright : dotPaintMuted,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<bool> _showAlwaysPermissionDialog(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enable Background Tracking"),
          content: const Text(
              "To track your location even when the app is closed (for accurate attendance), please allow 'Always' permission.\n\n"
              "If you prefer, you can continue with foreground-only tracking (app must stay open)."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // User chose "No"
              child: const Text("Only while using the app"),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true), // User chose to proceed
              child: const Text("Request Always"),
            ),
          ],
        ),
      ) ??
      false;
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
