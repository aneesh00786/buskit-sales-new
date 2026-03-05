// import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_middle_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_top_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DashBoardScreen extends StatefulWidget {
//   final HomeController homeController;
//   const DashBoardScreen({super.key, required this.homeController});

//   @override
//   State<DashBoardScreen> createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> {
//   CalenderMapController calenderMapController =
//       Get.put(CalenderMapController());
//   final DashBoardController controller = Get.put(DashBoardController());
//   ApiWorker apiWorker = Get.put(ApiWorker());
//   @override
//   void initState() {
//     super.initState();
//     calenderMapController.requestLocationPermission();
//     showOfflineMsg();
//   }

//   void showOfflineMsg() async {
//     bool isOnline = await ConnectivityService().isOnline();
//     if (!isOnline) {
//       NkCommonFunction.showErrorSnakBar(
//           'No Internet Connection. Please check your network');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       body: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Column(
//           children: [
//             DashboardTopWidget(
//               dashBoardController: controller,
//               homeController: widget.homeController,
//             ),
//             nkSmallSizeBox(),
//             Flexible(
//               fit: FlexFit.tight,
//               child: SingleChildScrollView(
//                 child: DashBoardMiddleWidget(
//                   dashBoardController: controller,
//                   context: context,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

// ignore_for_file: deprecated_member_use, use_build_context_synchronously





// import 'dart:async';
// import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
// import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
// import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
// import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
// import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
// import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_middle_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_top_widget.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
// import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// class DashBoardScreen extends StatefulWidget {
//   final HomeController homeController;
//   const DashBoardScreen({super.key, required this.homeController});

//   @override
//   State<DashBoardScreen> createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> with WidgetsBindingObserver {
//   CalenderMapController calenderMapController = Get.put(CalenderMapController());
//   final DashBoardController controller = Get.put(DashBoardController());
//   ApiWorker apiWorker = Get.put(ApiWorker());

  
//   static bool _hasShownPopupInThisSession = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
    
//     calenderMapController.requestLocationPermission();
//     showOfflineMsg();
    
 
//     if (!_hasShownPopupInThisSession) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _checkAttendanceRequirement();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
   
//     if (state == AppLifecycleState.paused) {
//       _hasShownPopupInThisSession = false;
//     }
//   }

//   void showOfflineMsg() async {
//     bool isOnline = await ConnectivityService().isOnline();
//     if (!isOnline) {
//       NkCommonFunction.showErrorSnakBar(
//           'No Internet Connection. Please check your network');
//     }
//   }

//   Future<void> _checkAttendanceRequirement() async {
//     if (_hasShownPopupInThisSession) return;

//     try {
     
//       bool isCheckedIn = await ApiWorker().loadSwitchState();
//       if (isCheckedIn) {
//         _hasShownPopupInThisSession = true;
//         return; 
//       }

     
//       final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
//       List<AllCompanySettingsData>? settings = await ApiWorker().fetchAllSettings(companyId);
      
//       if (settings == null) return;

     
//       String dayListStr = settings.firstWhere((e) => e.key == 'day_list', orElse: () => AllCompanySettingsData(value: '')).value ?? '';
   
//       String startTimeStr = "09:00"; 

//       String toTimeStr = settings.firstWhere((e) => e.key == 'to_time', orElse: () => AllCompanySettingsData(value: '')).value ?? '';

      
//       if (_shouldPromptCheckIn(dayListStr, startTimeStr, toTimeStr)) {
//         if (mounted) {
//           _hasShownPopupInThisSession = true;
//           _showCheckInDialog();
//         }
//       }
//     } catch (e) {
//       print("Error in attendance check: $e");
//     }
//   }

//   // Future<void> _checkAttendanceRequirement() async {
//   //   if (_hasShownPopupInThisSession) return;

//   //   try {
//   //     // 1. Check if user is ALREADY checked in
//   //     bool isCheckedIn = await ApiWorker().loadSwitchState();
//   //     if (isCheckedIn) {
//   //       _hasShownPopupInThisSession = true;
//   //       return; 
//   //     }

//   //     // 2. Load Settings
//   //     final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
//   //     List<AllCompanySettingsData>? settings = await ApiWorker().fetchAllSettings(companyId);
      
//   //     if (settings == null) return;

//   //     // 3. Extract settings
//   //     String dayListStr = settings.firstWhere((e) => e.key == 'day_list', orElse: () => AllCompanySettingsData(value: '')).value ?? '';
//   //     String startTimeStr = settings.firstWhere((e) => e.key == 'start_time', orElse: () => AllCompanySettingsData(value: '')).value ?? '';
//   //     String toTimeStr = settings.firstWhere((e) => e.key == 'to_time', orElse: () => AllCompanySettingsData(value: '')).value ?? '';

//   //     // 4. Validate Logic
//   //     if (_shouldPromptCheckIn(dayListStr, startTimeStr, toTimeStr)) {
//   //       if (mounted) {
//   //         _hasShownPopupInThisSession = true;
//   //         _showCheckInDialog();
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print("Error in attendance check: $e");
//   //   }
//   // }

//   bool _shouldPromptCheckIn(String dayList, String startTime, String endTime) {
//     if (dayList.isEmpty || startTime.isEmpty || endTime.isEmpty) return false;

//     DateTime now = DateTime.now();
    
 
//     String currentDay = DateFormat('EEEE').format(now);
//     if (!dayList.contains(currentDay)) {
//       return false; 
//     }

  
//     try {
//       DateFormat timeFormat = DateFormat("HH:mm");
      
//       DateTime startDt = timeFormat.parse(startTime);
//       startDt = DateTime(now.year, now.month, now.day, startDt.hour, startDt.minute);

//       DateTime endDt = timeFormat.parse(endTime);
//       endDt = DateTime(now.year, now.month, now.day, endDt.hour, endDt.minute);

     
//       if (now.isAfter(startDt) && now.isBefore(endDt)) {
//         return true;
//       }
//     } catch (e) {
//       print("Time parsing error: $e");
//     }

//     return false;
//   }

//   void _showCheckInDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text("Attendance Reminder"),
//         content: const Text(
//           "You have not checked in yet, but it is currently working hours.\n\nPlease check in from the sidebar.",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Later", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
//             onPressed: () {
           
//               Navigator.pop(context);
           
//               HomeController.homeScaffoldKey.currentState?.openDrawer();
//             },
//             child: const Text("Check In Now", style: TextStyle(color: white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       body: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Column(
//           children: [
//             DashboardTopWidget(
//               dashBoardController: controller,
//               homeController: widget.homeController,
//             ),
//             nkSmallSizeBox(),
//             Flexible(
//               fit: FlexFit.tight,
//               child: SingleChildScrollView(
//                 child: DashBoardMiddleWidget(
//                   dashBoardController: controller,
//                   context: context,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



























import 'dart:async';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';

import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/location_services/location_services.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_middle_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_top_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DashBoardScreen extends StatefulWidget {
  final HomeController homeController;
  const DashBoardScreen({super.key, required this.homeController});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> with WidgetsBindingObserver {
  CalenderMapController calenderMapController = Get.put(CalenderMapController());
  final DashBoardController controller = Get.put(DashBoardController());
  ApiWorker apiWorker = Get.put(ApiWorker());
  
  
  static bool _hasShownPopupInThisSession = false;

  @override
  void initState() {
    super.initState();
   
    WidgetsBinding.instance.addObserver(this);
    
    calenderMapController.requestLocationPermission();
    showOfflineMsg();
    
   
    if (!_hasShownPopupInThisSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAttendanceRequirement();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
   
    if (state == AppLifecycleState.paused) {
      _hasShownPopupInThisSession = false;
    }
    
   
    if (state == AppLifecycleState.resumed && !_hasShownPopupInThisSession) {
       _checkAttendanceRequirement();
    }
  }

  void showOfflineMsg() async {
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      NkCommonFunction.showErrorSnakBar(
          'No Internet Connection. Please check your network');
    }
  }
  Future<void> _checkAttendanceRequirement() async {
    if (_hasShownPopupInThisSession) return;

    try {
     
      bool isCheckedIn = await ApiWorker().loadSwitchState();
      if (isCheckedIn) {
        _hasShownPopupInThisSession = true;
        return; 
      }

     
      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      List<AllCompanySettingsData>? settings = await ApiWorker().fetchAllSettings(companyId);
      
      if (settings == null) return;

      
      String dayListStr = settings.firstWhere((e) => e.key == 'day_list', orElse: () => AllCompanySettingsData(value: '')).value ?? '';
      
     
      String startTimeStr = "09:00"; 
      String toTimeStr = settings.firstWhere((e) => e.key == 'to_time', orElse: () => AllCompanySettingsData(value: '')).value ?? '';

     
      if (_shouldPromptCheckIn(dayListStr, startTimeStr, toTimeStr)) {
        if (mounted) {
          _hasShownPopupInThisSession = true;
          _showCheckInDialog();
        }
      }
    } catch (e) {
      print("Error in attendance check: $e");
    }
  }

  // Future<void> _checkAttendanceRequirement() async {
  //   // Double check to prevent multiple popups
  //   if (_hasShownPopupInThisSession) return;

  //   try {
  //     // 1. Check if user is ALREADY checked in
  //     bool isCheckedIn = await ApiWorker().loadSwitchState();
  //     if (isCheckedIn) {
  //       _hasShownPopupInThisSession = true; // Mark as handled so we don't check again
  //       return; 
  //     }

  //     // 2. Load Settings (Offline capable)
  //     final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
  //     List<AllCompanySettingsData>? settings = await ApiWorker().fetchAllSettings(companyId);
      
  //     if (settings == null) return;

  //     // 3. Extract settings
  //     String dayListStr = settings.firstWhere((e) => e.key == 'day_list', orElse: () => AllCompanySettingsData(value: '')).value ?? '';
  //     String startTimeStr = settings.firstWhere((e) => e.key == 'start_time', orElse: () => AllCompanySettingsData(value: '')).value ?? '';
  //     String toTimeStr = settings.firstWhere((e) => e.key == 'to_time', orElse: () => AllCompanySettingsData(value: '')).value ?? '';

  //     // 4. Validate Logic
  //     if (_shouldPromptCheckIn(dayListStr, startTimeStr, toTimeStr)) {
  //       if (mounted) {
  //         // Mark as shown BEFORE showing dialog to prevent duplicates
  //         _hasShownPopupInThisSession = true;
  //         _showCheckInDialog();
  //       }
  //     }
  //   } catch (e) {
  //     print("Error in attendance check: $e");
  //   }
  // }

  bool _shouldPromptCheckIn(String dayList, String startTime, String endTime) {
    if (dayList.isEmpty || startTime.isEmpty || endTime.isEmpty) return false;

    DateTime now = DateTime.now();
    
 
    String currentDay = DateFormat('EEEE').format(now);
    if (!dayList.contains(currentDay)) {
      return false; 
    }

   
    try {
      DateFormat timeFormat = DateFormat("HH:mm");
      
      DateTime startDt = timeFormat.parse(startTime);
      startDt = DateTime(now.year, now.month, now.day, startDt.hour, startDt.minute);

      DateTime endDt = timeFormat.parse(endTime);
      endDt = DateTime(now.year, now.month, now.day, endDt.hour, endDt.minute);

      
      if (now.isAfter(startDt) && now.isBefore(endDt)) {
        return true;
      }
    } catch (e) {
      print("Time parsing error: $e");
    }

    return false;
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Attendance Reminder"),
        content: const Text(
          "You have not checked in yet, but it is currently working hours.\n\nDo you want to Check In now?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              Navigator.pop(context);
              _performCheckIn();
            },
            child: const Text("Check In Now", style: TextStyle(color: white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performCheckIn() async {
   
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (!await _handleLocationPermission()) {
        Navigator.pop(context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

     
      var alwaysStatus = await Permission.locationAlways.status;
      if (!alwaysStatus.isGranted) {
        await Permission.locationAlways.request();
      }
      
      await initializeService(); 
      final service = FlutterBackgroundService();
      if (!await service.isRunning()) service.startService();

      
      final response = await ApiWorker().updateAdminCheckInOut(
        date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
        time: DateFormat('HH:mm').format(DateTime.now()),
        direction: "in",
        lat: position.latitude.toString(),
        long: position.longitude.toString(),
      );

      Navigator.pop(context); 

      if (response.statusCode == 200) {
        await ApiWorker().saveSwitchState(true);
        NkCommonFunction.showSuccessSnakBar("Checked In Successfully");
        setState(() {});
      } else {
        NkCommonFunction.showErrorSnakBar("Failed to Check In: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      NkCommonFunction.showErrorSnakBar("Error: $e");
    }
  }

  Future<bool> _handleLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
         NkCommonFunction.showErrorSnakBar('Location permission denied');
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            DashboardTopWidget(
              dashBoardController: controller,
              homeController: widget.homeController,
            ),
            nkSmallSizeBox(),
            Flexible(
              fit: FlexFit.tight,
              child: SingleChildScrollView(
                child: DashBoardMiddleWidget(
                  dashBoardController: controller,
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}