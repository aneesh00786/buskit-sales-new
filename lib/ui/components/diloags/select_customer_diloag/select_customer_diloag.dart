// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/custmerlist_and_map.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/route_input_dialog.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/time_select_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calendar_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectCustomerDiloag extends StatefulWidget {
  final DateTime dateTime;
  final CalenderMapController calenderMapController;
  final List<CalendarEventData<EventData>> eventData;
  final bool istoGoogleMap;
  final List<String> customerIds;
   final String salesmanId;

  const SelectCustomerDiloag(
      {super.key,
      required this.dateTime,
      required this.calenderMapController,
      required this.eventData,
      this.istoGoogleMap = false,
      required this.customerIds,
      required this.salesmanId,
      });

  @override
  State<SelectCustomerDiloag> createState() => _SelectCustomerDiloagState();
}

class _SelectCustomerDiloagState extends State<SelectCustomerDiloag>
    with WidgetsBindingObserver {
  final HomeController homeController = Get.put(HomeController());
  final ProductsController productsController = Get.find<ProductsController>();
  final subscriptionController = Get.find<SubscriptionController>();
  final CustomerAndOrderController customerAndOrderController =
      Get.find<CustomerAndOrderController>();

  bool isSaving = false;

  Map<String, String> selectedEventTimes = {}; // eventId → time
   final CalenderMapController _mapController = Get.put(CalenderMapController());
     @override
  void initState() {
    super.initState();
    fetchCustomerData();

    WidgetsBinding.instance.addObserver(this);
    _mapController.suggestions.clear();
    _mapController.searchedLatLng.value = null;

    List<CalendarEventData<EventData>> filteredEventData = widget.eventData
        .where((event) =>
            event.event != null &&
            widget.customerIds.contains(event.event!.customerId.toString()))
        .toList();

    _mapController.initializeCheckedList(
        filteredEventData.length, filteredEventData, widget.customerIds);

    _mapController.getDirections();
    _mapController.getCurrentLocation();
  }
  Future<void> fetchCustomerData() async {
    await widget.calenderMapController.loadOnlyCustomerData(
      DateFormat('yyyy-MM-dd').format(widget.dateTime),
      widget.customerIds,
    );

    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     widget.calenderMapController
  //         .initializeCheckedList(widget.eventData.length, widget.eventData,);
  //   });
  //   WidgetsBinding.instance.addObserver(this);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     widget.calenderMapController.suggestions.clear();
  //     widget.calenderMapController.searchedLatLng.value = null;
  //     widget.calenderMapController.getDirections();
  //     widget.calenderMapController.getCurrentLocation();
  //   });
  // }

  bool navigatedToMap = false;
  Customer? selectedCustomer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && navigatedToMap) {
      navigatedToMap = false;
      if (selectedCustomer != null) {
        _showReturnDialog(selectedCustomer!);
      }
    }
  }

  void _showReturnDialog(Customer customer) {
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
                      color: Colors.blueAccent.withOpacity(0.1), width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: NetworkImage(
                      '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer.businessName ?? 'Customer',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              CustomText(
                content: 'Reached Customer?',
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
                    elevation: 0,
                  ),
                  onPressed: () {
               
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      homeController.sidebarXController.selectIndex(1);
                      homeController.selectedIndex.value = 1;

                      productsController.selectedCustomerName.value =
                          customer.businessName ?? '';
                      productsController.selectedCustomerId.value =
                          customer.customerId ?? '';
                      productsController.selectedCustomerImageUrl.value =
                          customer.imageUrl ?? '';

                      Get.to(
                          CustomerDachScreen(
                            cusId: customer.customerId.toString(),
                            cusName: customer.businessName.toString(),
                            cusImage: customer.imageUrl.toString(),
                            cusEmail: customer.email ?? '',
                            cusMobile: customer.mobileno ?? '',
                            isFromCalendar: true,
                            isFromGoogle: false,
                            eventIds: widget.eventData
                                .map((e) => e.event!.eventId.toString())
                                .toList(),
                            customerIds: widget.customerIds,
                          ),
                          id: 2);

                      final dashProvider = Provider.of<CustomersProvider>(
                          context,
                          listen: false);

                      dashProvider.fetchCustomerDashboardData(
                          customer.customerId.toString());
                      dashProvider.fetchCustomerDashboardRevenueData(
                          customer.customerId.toString());
                      dashProvider.fetchCustomerDashboardDataSalseData(
                          customer.customerId.toString());
                      dashProvider.fetchCustomersDataDash(
                          customer.customerId.toString());
                      dashProvider.fetchCustomerDashboardCountData(
                          customer.customerId.toString());
                    });
                    productsController.onReached(true);
                    Navigator.of(context, rootNavigator: true).pop();
                    // --- YOUR ORIGINAL LOGIC END ---
                  },
                  child: const Text("Go to Customer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                     
                      final lat =
                          _mapController.currentLatLng.value?.latitude ?? 0.0;
                      final lng =
                          _mapController.currentLatLng.value?.longitude ?? 0.0;

                      navigateToo(
                          lat,
                          lng,
                          double.tryParse(customer.latitude ?? '0') ?? 0.0,
                          double.tryParse(customer.longitude ?? '0') ?? 0.0);
                    } else {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => const UpgradePlanScreen(),
                      );
                    }
                  },
                  child: const Text('Continue Navigation'),
                ),

                // 3. CANCEL ACTION
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // void _showReturnDialog(Customer customer) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 30,
  //               backgroundImage: NetworkImage(
  //                   '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}'),
  //             ),
  //             const SizedBox(width: 8),
  //             Text(customer.businessName ?? ''),
  //           ],
  //         ),
  //         content: CustomText(
  //           content: 'Reached customer Location ?',
  //           fontSize: 17,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               WidgetsBinding.instance.addPostFrameCallback((_) async {
  //                 if (!widget.istoGoogleMap) {
  //                   Navigator.pop(context);
  //                 }
  //                 Navigator.pop(context);
  //                 homeController.sidebarXController.selectIndex(1);
  //                 homeController.selectedIndex.value = 1;
  //                 customerAndOrderController
  //                     .setCustomerId(customer.customerId ?? '');
  //                 productsController.selectedCustomerName.value =
  //                     customer.businessName ?? '';
  //                 productsController.selectedCustomerId.value =
  //                     customer.customerId ?? '';
  //                 productsController.selectedCustomerImageUrl.value =
  //                     customer.imageUrl ?? '';
  //                 Get.to(
  //                   () => CustomerDachScreen(
  //                     isDirectDialogue: true,
  //                     cusId: productsController.selectedCustomerId.value,
  //                     cusName: productsController.selectedCustomerName.value,
  //                     cusImage:
  //                         productsController.selectedCustomerImageUrl.value,
  //                     cusEmail: productsController.selectedCustomerEmail.value,
  //                     cusMobile:
  //                         productsController.selectedCustomerMobileNo.value,
  //                   ),
  //                   id: 2,
  //                 );
  //                 final customerId = customer.customerId.toString();
  //                 final customersProvider =
  //                     Provider.of<CustomersProvider>(context, listen: false);
  //                 await Future.wait([
  //                   customersProvider.fetchCustomerDashboardData(customerId),
  //                   customersProvider
  //                       .fetchCustomerDashboardRevenueData(customerId),
  //                   customersProvider
  //                       .fetchCustomerDashboardDataSalseData(customerId),
  //                   customersProvider.fetchCustomersDataDash(customerId),
  //                   customersProvider
  //                       .fetchCustomerDashboardCountData(customerId),
  //                 ]);
  //               });
  //             },
  //             child: const Text("Go to Customer"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    List<CalendarEventData<EventData>> filteredEventData = widget.eventData
        .where((event) =>
            event.event != null &&
            widget.customerIds.contains(event.event!.customerId.toString()))
        .toList();
    widget.calenderMapController.initializeCheckedList(
        filteredEventData.length, filteredEventData, widget.customerIds);
    // .initializeCheckedList(widget.eventData.length, widget.eventData);
    String formattedDate = DateFormat('dd/MM/yyyy').format(widget.dateTime);
    DateTime now = DateTime.now();
    bool isToday = widget.dateTime.year == now.year &&
        widget.dateTime.month == now.month &&
        widget.dateTime.day == now.day;

    // Prevent RangeError: If no data, show fallback
    if (widget.calenderMapController.customerOnlyList.isEmpty ||
        filteredEventData.isEmpty) {
      return MyCommnonContainer(
        color: white,
        margin: isPhonePortrait(context)
            ? EdgeInsets.zero
            : AppDimensions.instance!.orientation == Orientation.landscape
                ? nkExtraLargePadding(
                    right: AppDimensions.instance!.width * .10,
                    left: AppDimensions.instance!.width * .10)
                : EdgeInsets.all(fullScreenWidth(context) * 0.08),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              isToday
                  ? DiloagAppBar(title: "Customer Visit For Today")
                  : DiloagAppBar(title: "Customer Visit For $formattedDate"),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }
    // return Obx(
    //   () {
    // log(widget.calenderMapController.isOnlyCustomerLoading.value
    //     .toString());
    return OrientationBuilder(builder: (context, ore) {
      return MyCommnonContainer(
        color: white,
        margin: isPhonePortrait(context)
            ? EdgeInsets.zero
            : AppDimensions.instance!.orientation == Orientation.landscape
                ? nkExtraLargePadding(
                    right: AppDimensions.instance!.width * .10,
                    left: AppDimensions.instance!.width * .10)
                : EdgeInsets.all(fullScreenWidth(context) * 0.08),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              isToday
                  ? DiloagAppBar(title: "Customer Visit For Today")
                  : DiloagAppBar(title: "Customer Visit For $formattedDate"),
              if (widget.calenderMapController.isOnlyCustomerLoading.value ==
                  true) ...[
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
              if (widget.calenderMapController.isOnlyCustomerLoading.value ==
                  false) ...[
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: CustomText(
                            content: "Customers",
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: Center(
                      //     child: CustomText(
                      //       content: isPhonePortrait(context) ? "" : "Timess",
                      //       fontWeight: FontWeight.w700,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        width: 65,
                      ),
                    ],
                  ),
                ),
                widget.eventData.isNotEmpty
                    ? Flexible(
                        child: ListView.builder(
                          padding: nkRegularPadding(),
                          itemCount: filteredEventData.length,
                          itemBuilder: (context, index) {
                            final customerEvent = filteredEventData[index];
                            final currentId =
                                customerEvent.event!.customerId.toString();
                            final customer =
                                _mapController.customerOnlyList.firstWhere(
                              (c) => c.customerId.toString() == currentId,
                              orElse: () => FetchOnlyCustomerData(
                                customerId: currentId,
                                businessName: 'Unknown',
                                // Fill other required fields...
                                eventId: '', scheduleTime: '', checkIn: null,
                                start: DateTime.now(),
                                fullname: '', mobileno: '', email: '',
                                imageUrl: '',

                                // Initialize coords to 0 if not found
                                latitude: '0.0',
                                longitude: '0.0',
                              ),
                            );
                            // final customerData =
                            //     _mapController.selectedCustomers.firstWhere(
                            //   (c) =>
                            //       c.customerId.toString() ==
                            //       customerEvent.event!.customerId.toString(),
                            //   orElse: () => Customer(),
                            // );
                            final navCustomer =
                                _mapController.selectedCustomers.firstWhere(
                              (c) => c.customerId.toString() == currentId,
                              orElse: () => Customer(
                                customerId: currentId,
                                businessName: customer
                                    .businessName, // Fallback to UI name
                                latitude:
                                    '0.0', // Default to 0 if full data isn't found
                                longitude: '0.0',
                              ),
                            );
                            // final customer =
                            //     _mapController.customerOnlyList[index];

                            String initialHour = '__';
                            String initialMinute = '__';
                            String initialPeriod = '_';

                            final time = customer.scheduleTime;

                            if (time != null &&
                                time.isNotEmpty &&
                                time.contains(":")) {
                              final parts = time.split(":");
                              int hour = int.tryParse(parts[0]) ?? 0;
                              int minute = int.tryParse(parts[1]) ?? 0;
                              int displayHour = hour % 12 == 0 ? 12 : hour % 12;
                              String period = hour >= 12 ? 'PM' : 'AM';

                              initialHour =
                                  displayHour.toString().padLeft(2, '0');
                              initialMinute = minute.toString().padLeft(2, '0');
                              initialPeriod = period;
                            }

                            if (!isPhonePortrait(context)) {
                              return Padding(
                                padding: nkSmallPadding(left: 0, right: 0),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  child: Card(
                                    elevation: 10,
                                    shadowColor: black.withOpacity(0.2),
                                    color: white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Avatar
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              '${ApiConstants.imageBaseUrl}${customer.imageUrl}',
                                            ),
                                            radius: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title
                                                CustomText(
                                                  content:
                                                      customer.businessName,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                                const SizedBox(height: 4),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      content:
                                                          customer.mobileno,
                                                      fontSize: 12,
                                                      maxLine: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    CustomText(
                                                      content: customer.email,
                                                      fontSize: 12,
                                                      maxLine: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // const SizedBox(width: 8),
                                          // TimePickerField(
                                          //   eventId: customer.eventId,
                                          //   initialHour: initialHour,
                                          //   initialMinute: initialMinute,
                                          //   initialPeriod: initialPeriod,
                                          //   onTimeSelected: (eventId, time) {
                                          //     setState(() {
                                          //       selectedEventTimes[eventId] =
                                          //           time;
                                          //       // Update the scheduleTime for the customer in customerOnlyList
                                          //       customer.scheduleTime = time;
                                          //     });
                                          //   },
                                          // ),

                                          // const SizedBox(width: 8),

                                          // Trailing icons
                                          SizedBox(
                                            width: 100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Checkbox
                                                SizedBox(
                                                  width: 20,
                                                  child: Obx(() {
                                                    return Checkbox(
                                                      value: widget
                                                          .calenderMapController
                                                          .checkedList[index],
                                                      onChanged: (value) {
                                                        widget
                                                            .calenderMapController
                                                            .toggleCustomerSelection(
                                                          index,
                                                          value ?? false,
                                                          filteredEventData[
                                                              index],
                                                        );
                                                      },
                                                    );
                                                  }),
                                                ),
                                                const SizedBox(width: 4),

                                                // Navigation icon
                                                SizedBox(
                                                  width: 30,
                                                  child: IconButton(
                                                    constraints:
                                                        const BoxConstraints(),
                                                    onPressed: () {
                                                      final CalendarEventData<
                                                              EventData> event =
                                                          widget
                                                              .eventData[index];
                                                      Navigator.of(context)
                                                          .pop();
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        homeController
                                                            .sidebarXController
                                                            .selectIndex(1);
                                                        homeController
                                                            .selectedIndex
                                                            .value = 1;

                                                        productsController
                                                            .selectedCustomerName
                                                            .value = customer
                                                                .businessName ??
                                                            '';
                                                        productsController
                                                            .selectedCustomerId
                                                            .value = customer
                                                                .customerId ??
                                                            '';
                                                        productsController
                                                            .selectedCustomerImageUrl
                                                            .value = customer
                                                                .imageUrl ??
                                                            '';

                                                        Get.to(
                                                          CustomerDachScreen(
                                                            cusId: event.event!
                                                                .customerId
                                                                .toString(),
                                                            cusName: event
                                                                .event!
                                                                .businessName
                                                                .toString(),
                                                            cusImage: event
                                                                .event!.imageUrl
                                                                .toString(),
                                                            cusEmail: event
                                                                    .event
                                                                    ?.email ??
                                                                '',
                                                            cusMobile: event
                                                                    .event
                                                                    ?.mobileNo ??
                                                                '',
                                                            isFromCalendar:
                                                                true,
                                                            isFromGoogle: false,
                                                          ),
                                                          id: 2,
                                                        );

                                                        final dashProvider =
                                                            Provider.of<
                                                                CustomersProvider>(
                                                          context,
                                                          listen: false,
                                                        );

                                                        dashProvider
                                                            .fetchCustomerDashboardData(
                                                                event.event!
                                                                    .customerId
                                                                    .toString());
                                                        dashProvider
                                                            .fetchCustomerDashboardRevenueData(
                                                                event.event!
                                                                    .customerId
                                                                    .toString());
                                                        dashProvider
                                                            .fetchCustomerDashboardDataSalseData(
                                                                event.event!
                                                                    .customerId
                                                                    .toString());
                                                        dashProvider
                                                            .fetchCustomersDataDash(
                                                                event.event!
                                                                    .customerId
                                                                    .toString());
                                                        dashProvider
                                                            .fetchCustomerDashboardCountData(
                                                                event.event!
                                                                    .customerId
                                                                    .toString());
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      EneftyIcons
                                                          .arrow_square_right_outline,
                                                      color: primaryColor,
                                                      size: 25,
                                                    ),
                                                    highlightColor: white,
                                                  ),
                                                ),

                                                const SizedBox(width: 4),

                                                // Near Me Button
                                                SizedBox(
                                                  width: 30,
                                                  child: Obx(() {
                                                    if (_mapController
                                                            .currentLatLng
                                                            .value ==
                                                        null) {
                                                      return Container(
                                                        height: 30,
                                                        width: 35,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child:
                                                            const CircularProgressIndicator(
                                                                strokeWidth: 2),
                                                      );
                                                    }
                                                    double currentLatitude =
                                                        _mapController
                                                            .currentLatLng
                                                            .value!
                                                            .latitude;
                                                    double currentLongitude =
                                                        _mapController
                                                            .currentLatLng
                                                            .value!
                                                            .longitude;

                                                    return IconButton(
                                                      icon: const Icon(
                                                        Icons.near_me_outlined,
                                                        size: 25,
                                                        color: red,
                                                      ),
                                                onPressed: () async {

  final isOnline = await ConnectivityService().isOnline();

  if (!isOnline) {
    showCustomToastDisplay(
      context,
      'You are offline. Show Route is disabled.',
      red,
      Icons.close
    );
    return;
  }

  if (subscriptionController.visitNavigation.value == "true") {
    // Parse coordinates first
    double destLat = double.tryParse(navCustomer.latitude ?? '0') ?? 0.0;
    double destLng = double.tryParse(navCustomer.longitude ?? '0') ?? 0.0;

    // If coordinates are missing (0.0), geocode the address
    if (destLat == 0.0 && destLng == 0.0) {
      // Check if customer has an address
      if (navCustomer.address == null || navCustomer.address!.isEmpty) {
        showCustomToastDisplay(
          context,
          'Customer address not available.',
          red,
          Icons.error_outline
        );
        return;
      }

      // Geocode the address
      print('Geocoding address: ${navCustomer.address}');
      LatLng? coords = await _mapController.getLatLngFromAddress(navCustomer.address!);
      
      if (coords == null) {
        showCustomToastDisplay(
          context,
          'Unable to find location for this address.',
          red,
          Icons.error_outline
        );
        return;
      }

      // Use the geocoded coordinates
      destLat = coords.latitude;
      destLng = coords.longitude;
      print('Geocoded coordinates - Lat: $destLat, Lng: $destLng');
    }

    selectedCustomer = Customer(
      customerId: customer.customerId,
      businessName: customer.businessName,
      email: customer.email,
      mobileno: customer.mobileno,
      imageUrl: customer.imageUrl,
      latitude: customer.latitude,
      longitude: customer.longitude,
    );
    navigatedToMap = true;

    

    navigateToo(
      currentLatitude,
      currentLongitude,
      destLat,
      destLng,
    );
  } else {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const UpgradePlanScreen(),
    );
  }
},
                                                      // onPressed: () async {
                                                      //   print(
                                                      //       'on tapped map icon');
                                                      //   final isOnline =
                                                      //       await ConnectivityService()
                                                      //           .isOnline();

                                                      //   if (!isOnline) {
                                                      //     showCustomToastDisplay(
                                                      //         context,
                                                      //         'You are offline. Show Route is disabled.',
                                                      //         red,
                                                      //         Icons.close);
                                                      //     return;
                                                      //   }

                                                      //   if (subscriptionController
                                                      //           .visitNavigation
                                                      //           .value ==
                                                      //       "true") {
                                                      //     // FIX: Use 'navCustomer' here because it is type 'Customer'
                                                      //     selectedCustomer =
                                                      //         Customer(
                                                      //       customerId: customer
                                                      //           .customerId,
                                                      //       businessName: customer
                                                      //           .businessName,
                                                      //       email:
                                                      //           customer.email,
                                                      //       mobileno: customer
                                                      //           .mobileno,
                                                      //       imageUrl: customer
                                                      //           .imageUrl,
                                                      //       // USE THE FRESH COORDINATES HERE:
                                                      //       latitude: customer
                                                      //           .latitude,
                                                      //       longitude: customer
                                                      //           .longitude,
                                                      //     );
                                                      //     navigatedToMap = true;

                                                      //     // Use tryParse on 'navCustomer' to get coordinates safely
                                                      //     double destLat =
                                                      //         double.tryParse(
                                                      //                 navCustomer
                                                      //                         .latitude ??
                                                      //                     '0') ??
                                                      //             0.0;
                                                      //     double destLng =
                                                      //         double.tryParse(
                                                      //                 navCustomer
                                                      //                         .longitude ??
                                                      //                     '0') ??
                                                      //             0.0;

                                                      //     print(
                                                      //         'current latitude: $currentLatitude');
                                                      //     print(
                                                      //         'current longitude: $currentLongitude');
                                                      //     print(
                                                      //         'dest latitude: $destLat');
                                                      //     print(
                                                      //         'dest longitude: $destLng');
                                                      //     print(
                                                      //         'customer detailsssss:${navCustomer.toJson()}');

                                                      //     navigateToo(
                                                      //       currentLatitude,
                                                      //       currentLongitude,
                                                      //       destLat,
                                                      //       destLng,
                                                      //     );
                                                      //   } else {
                                                      //     showDialog(
                                                      //       barrierDismissible:
                                                      //           false,
                                                      //       context: context,
                                                      //       builder: (context) =>
                                                      //           const UpgradePlanScreen(),
                                                      //     );
                                                      //   }
                                                      // },
                                                    
                                                      highlightColor: white,
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (isPhonePortrait(context)) {
                              return Padding(
                                padding: nkSmallPadding(left: 0, right: 0),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  child: Card(
                                    elevation: 10,
                                    shadowColor: black.withOpacity(0.2),
                                    color: white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Avatar
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  '${ApiConstants.imageBaseUrl}${customer.imageUrl}',
                                                ),
                                                radius: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Title
                                                    CustomText(
                                                      content:
                                                          customer.businessName,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CustomText(
                                                          content:
                                                              customer.mobileno,
                                                          fontSize: 12,
                                                          maxLine: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        CustomText(
                                                          content:
                                                              customer.email,
                                                          fontSize: 12,
                                                          maxLine: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          nkMediumSizeBox(),
                                          nkMediumSizeBox(),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CustomText(
                                                content: "Time : ",
                                                fontSize: 12,
                                                maxLine: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              TimePickerField(
                                                eventId: customer.eventId,
                                                initialHour: initialHour,
                                                initialMinute: initialMinute,
                                                initialPeriod: initialPeriod,
                                                onTimeSelected:
                                                    (eventId, time) {
                                                  setState(() {
                                                    selectedEventTimes[
                                                        eventId] = time;
                                                    // Update the scheduleTime for the customer in customerOnlyList
                                                    customer.scheduleTime =
                                                        time;
                                                  });
                                                },
                                              ),
                                              const Spacer(),

                                              const SizedBox(width: 8),

                                              // Trailing icons
                                              SizedBox(
                                                width: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Checkbox
                                                    SizedBox(
                                                      width: 20,
                                                      child: Obx(() {
                                                        return Checkbox(
                                                          value: widget
                                                              .calenderMapController
                                                              .checkedList[index],
                                                          onChanged: (value) {
                                                            widget
                                                                .calenderMapController
                                                                .toggleCustomerSelection(
                                                              index,
                                                              value ?? false,
                                                              filteredEventData[
                                                                  index],
                                                            );
                                                          },
                                                        );
                                                      }),
                                                    ),
                                                    const SizedBox(width: 4),

                                                    // Navigation icon
                                                    SizedBox(
                                                      width: 30,
                                                      child: IconButton(
                                                        constraints:
                                                            const BoxConstraints(),
                                                        onPressed: () {
                                                          final CalendarEventData<
                                                                  EventData>
                                                              event =
                                                              widget.eventData[
                                                                  index];
                                                          Navigator.of(context)
                                                              .pop();
                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback(
                                                                  (_) {
                                                            homeController
                                                                .sidebarXController
                                                                .selectIndex(1);
                                                            homeController
                                                                .selectedIndex
                                                                .value = 1;

                                                            productsController
                                                                .selectedCustomerName
                                                                .value = customer
                                                                    .businessName ??
                                                                '';
                                                            productsController
                                                                .selectedCustomerId
                                                                .value = customer
                                                                    .customerId ??
                                                                '';
                                                            productsController
                                                                .selectedCustomerImageUrl
                                                                .value = customer
                                                                    .imageUrl ??
                                                                '';

                                                            Get.to(
                                                              CustomerDachScreen(
                                                                cusId: event
                                                                    .event!
                                                                    .customerId
                                                                    .toString(),
                                                                cusName: event
                                                                    .event!
                                                                    .businessName
                                                                    .toString(),
                                                                cusImage: event
                                                                    .event!
                                                                    .imageUrl
                                                                    .toString(),
                                                                cusEmail: event
                                                                        .event
                                                                        ?.email ??
                                                                    '',
                                                                cusMobile: event
                                                                        .event
                                                                        ?.mobileNo ??
                                                                    '',
                                                                isFromCalendar:
                                                                    true,
                                                                isFromGoogle:
                                                                    false,
                                                              ),
                                                              id: 2,
                                                            );

                                                            final dashProvider =
                                                                Provider.of<
                                                                    CustomersProvider>(
                                                              context,
                                                              listen: false,
                                                            );

                                                            dashProvider
                                                                .fetchCustomerDashboardData(event
                                                                    .event!
                                                                    .customerId
                                                                    .toString());
                                                            dashProvider
                                                                .fetchCustomerDashboardRevenueData(event
                                                                    .event!
                                                                    .customerId
                                                                    .toString());
                                                            dashProvider
                                                                .fetchCustomerDashboardDataSalseData(event
                                                                    .event!
                                                                    .customerId
                                                                    .toString());
                                                            dashProvider
                                                                .fetchCustomersDataDash(event
                                                                    .event!
                                                                    .customerId
                                                                    .toString());
                                                            dashProvider
                                                                .fetchCustomerDashboardCountData(event
                                                                    .event!
                                                                    .customerId
                                                                    .toString());
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          EneftyIcons
                                                              .arrow_square_right_outline,
                                                          color: primaryColor,
                                                          size: 25,
                                                        ),
                                                        highlightColor: white,
                                                      ),
                                                    ),

                                                    const SizedBox(width: 4),

                                                    // Near Me Button
                                                    SizedBox(
                                                      width: 30,
                                                      child: Obx(() {
                                                        if (_mapController
                                                                .currentLatLng
                                                                .value ==
                                                            null) {
                                                          return Container(
                                                            height: 30,
                                                            width: 35,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child:
                                                                const CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2),
                                                          );
                                                        }
                                                        double currentLatitude =
                                                            _mapController
                                                                .currentLatLng
                                                                .value!
                                                                .latitude;
                                                        double
                                                            currentLongitude =
                                                            _mapController
                                                                .currentLatLng
                                                                .value!
                                                                .longitude;

                                                        return IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .near_me_outlined,
                                                            size: 25,
                                                            color: red,
                                                          ),
                                                          onPressed: () async {
                                                            print(
                                                                'on tapped map icon');
                                                            final isOnline =
                                                                await ConnectivityService()
                                                                    .isOnline();

                                                            if (!isOnline) {
                                                              showCustomToastDisplay(
                                                                  context,
                                                                  'You are offline. Show Route is disabled.',
                                                                  red,
                                                                  Icons.close);
                                                              return;
                                                            }

                                                            if (subscriptionController
                                                                    .visitNavigation
                                                                    .value ==
                                                                "true") {
                                                              // FIX: Use 'navCustomer' here because it is type 'Customer'
                                                              selectedCustomer =
                                                                  Customer(
                                                                customerId: customer
                                                                    .customerId,
                                                                businessName:
                                                                    customer
                                                                        .businessName,
                                                                email: customer
                                                                    .email,
                                                                mobileno: customer
                                                                    .mobileno,
                                                                imageUrl: customer
                                                                    .imageUrl,
                                                                // USE THE FRESH COORDINATES HERE:
                                                                latitude: customer
                                                                    .latitude,
                                                                longitude: customer
                                                                    .longitude,
                                                              );
                                                              navigatedToMap =
                                                                  true;

                                                              // Use tryParse on 'navCustomer' to get coordinates safely
                                                              double destLat =
                                                                  double.tryParse(
                                                                          navCustomer.latitude ??
                                                                              '0') ??
                                                                      0.0;
                                                              double destLng =
                                                                  double.tryParse(
                                                                          navCustomer.longitude ??
                                                                              '0') ??
                                                                      0.0;

                                                              print(
                                                                  'current latitude: $currentLatitude');
                                                              print(
                                                                  'current longitude: $currentLongitude');
                                                              print(
                                                                  'dest latitude: $destLat');
                                                              print(
                                                                  'dest longitude: $destLng');

                                                              navigateToo(
                                                                currentLatitude,
                                                                currentLongitude,
                                                                destLat,
                                                                destLng,
                                                              );
                                                            } else {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        const UpgradePlanScreen(),
                                                              );
                                                            }
                                                          },
                                                       
                                                          highlightColor: white,
                                                        );
                                                      }),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      )
                    : const SizedBox(),
                isSaving
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: ElevatedButton.icon(
                          label: CustomText(
                            content: selectedEventTimes.isNotEmpty
                                ? 'Save'
                                : 'Show Route',
                            color: white,
                            fontWeight: FontWeight.w600,
                          ),
                          style: ButtonStyle(
                            padding: const WidgetStatePropertyAll(
                                EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                              selectedEventTimes.isNotEmpty
                                  ? Colors.green
                                  : primaryColor,
                            ),
                          ),
                          icon: Icon(
                            selectedEventTimes.isNotEmpty
                                ? Icons.save_rounded
                                : EneftyIcons.location_outline,
                            color: white,
                            size: 25,
                          ),
                          // Inside SelectCustomerDiloag... onPressed:

                          onPressed: () async {
                            // 1. Checks
                            final isOnline =
                                await ConnectivityService().isOnline();
                            if (!isOnline) {
                              showCustomToastDisplay(context,
                                  'You are offline.', red, Icons.close);
                              return;
                            }

                            if (subscriptionController.appShowRoute.value ==
                                'true') {
                              if (widget.calenderMapController.routeCredit
                                          .value !=
                                      '0' &&
                                  widget.calenderMapController.routeCredit
                                          .value !=
                                      '') {
                                // Date check
                                DateTime today = DateTime.now();
                                DateTime currentDate = DateTime(
                                    today.year, today.month, today.day);
                                DateTime widgetDate = DateTime(
                                    widget.dateTime.year,
                                    widget.dateTime.month,
                                    widget.dateTime.day);

                                if (widgetDate.isAfter(currentDate)) {
                                  showCustomToastDisplay(
                                      context,
                                        'Only current and working days route can be generated',
                                      // 'This route can be accessed from $formattedDate',
                                      Colors.orange,
                                      Icons.warning);
                                  return;
                                }
                                  if (widgetDate.isBefore(currentDate)) {
                                  showCustomToastDisplay(
                                      context,
                                      'This route can be accessed from $formattedDate',
                                      Colors.orange,
                                      Icons.warning);
                                  return;
                                }
                                Get.back();
                                await _mapController.saveCustomersToHive(_mapController.selectedCustomers);
                                // 2. Just Open Dialog (Pass Data Down)
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => RouteInputDialog(
                                    controller: _mapController,
                                    currentAddress: _mapController
                                        .currentLocationText.value,
                                    currentLatLng:
                                        _mapController.currentLatLng.value ??
                                            const LatLng(0, 0),
                                    // Pass the necessary lists for the logic to work inside the dialog
                                    customerIds: widget.customerIds,
                                    eventData: widget.eventData,
                                  ),
                                );
                              } else {
                                showCustomToastDisplay(
                                    context,
                                    "Buy More Credits to Continue",
                                    red,
                                    Icons.close);
                              }
                            } else {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const UpgradePlanScreen(),
                              );
                            }
                          },
                         
                        ),
                      ),
              ]
            ],
          ),
        ),
      );
    });
    //   },
    // );
  }

//   @override
//   Widget build(BuildContext context) {

//  List<CalendarEventData<EventData>> filteredEventData = widget.eventData
//         .where((event) =>
//             event.event != null &&
//             widget.customerIds.contains(event.event!.customerId.toString()))
//         .toList();
//     widget.calenderMapController.initializeCheckedList(
//         filteredEventData.length, filteredEventData, widget.customerIds);


//     String formattedDate = DateFormat('dd/MM/yyyy').format(widget.dateTime);
//     DateTime now = DateTime.now();
//     bool isToday = widget.dateTime.year == now.year &&
//         widget.dateTime.month == now.month &&
//         widget.dateTime.day == now.day;

//     return Obx(() {
//       if (widget.calenderMapController.initChecklistLoading.value) {
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       }
//       if (widget.calenderMapController.checkedList.length !=
//           widget.eventData.length) {
//         return const SizedBox(); // waiting till lengths match
//       }
//       return OrientationBuilder(builder: (context, ore) {
//         return MyCommnonContainer(
//           color: white,
//           margin: isPhonePortrait(context)
//               ? EdgeInsets.zero
//               : AppDimensions.instance.orientation == Orientation.landscape
//                   ? nkExtraLargePadding(
//                       right: AppDimensions.instance.width * .10,
//                       left: AppDimensions.instance.width * .10)
//                   : EdgeInsets.all(fullScreenWidth(context) * 0.08),
//           child: ClipRRect(
//             borderRadius:
//                 BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
//             child: Column(
//               children: [
//                 isToday
//                     ? DiloagAppBar(title: "Customer Visit For Today")
//                     : DiloagAppBar(title: "Customer Visit For $formattedDate"),
//                 SizedBox(
//                   height: 50,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Center(
//                           child: CustomText(
//                             content: "Customers",
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: CustomText(
//                             content: isPhonePortrait(context) ? "" : "Time",
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 65,
//                       ),
//                     ],
//                   ),
//                 ),
//                 widget.eventData.isNotEmpty
//                     ? Flexible(
//                         child: ListView.builder(
//                           padding: nkRegularPadding(),
//                           itemCount: widget.eventData.length,
//                           itemBuilder: (context, index) {
//                             final customer = widget
//                                 .calenderMapController.customerOnlyList[index];

//                             String initialHour = '__';
//                             String initialMinute = '__';
//                             String initialPeriod = '_';

//                             final time = customer.scheduleTime;

//                             if (time != null &&
//                                 time.isNotEmpty &&
//                                 time.contains(":")) {
//                               final parts = time.split(":");
//                               int hour = int.tryParse(parts[0]) ?? 0;
//                               int minute = int.tryParse(parts[1]) ?? 0;
//                               int displayHour = hour % 12 == 0 ? 12 : hour % 12;
//                               String period = hour >= 12 ? 'PM' : 'AM';

//                               initialHour =
//                                   displayHour.toString().padLeft(2, '0');
//                               initialMinute = minute.toString().padLeft(2, '0');
//                               initialPeriod = period;
//                             }

//                             if (!isPhonePortrait(context)) {
//                               return Padding(
//                                 padding: nkSmallPadding(left: 0, right: 0),
//                                 child: InkWell(
//                                   highlightColor: Colors.transparent,
//                                   splashFactory: NoSplash.splashFactory,
//                                   child: Card(
//                                     elevation: 10,
//                                     shadowColor: black.withOpacity(0.2),
//                                     color: white,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(15.0),
//                                       child: Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           // Avatar
//                                           CircleAvatar(
//                                             backgroundImage: NetworkImage(
//                                               '${ApiConstants.imageBaseUrl}${customer.imageUrl}',
//                                             ),
//                                             radius: 24,
//                                           ),
//                                           const SizedBox(width: 12),

//                                           // Title and Subtitle
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 // Title
//                                                 CustomText(
//                                                   content:
//                                                       customer.businessName,
//                                                   fontWeight: FontWeight.w700,
//                                                   fontSize: 14,
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 // Subtitle details
//                                                 Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     CustomText(
//                                                       content:
//                                                           customer.mobileno,
//                                                       fontSize: 12,
//                                                       maxLine: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                     CustomText(
//                                                       content: customer.email,
//                                                       fontSize: 12,
//                                                       maxLine: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),

//                                           const SizedBox(width: 8),

//                                           // Red container (right of subtitle)
//                                           TimePickerField(
//                                             eventId: customer.eventId,
//                                             initialHour: initialHour,
//                                             initialMinute: initialMinute,
//                                             initialPeriod: initialPeriod,
//                                             onTimeSelected: (eventId, time) {
//                                               setState(() {
//                                                 selectedEventTimes[eventId] =
//                                                     time;
//                                               });
//                                             },
//                                           ),

//                                           const SizedBox(width: 8),

//                                           // Trailing icons
//                                           SizedBox(
//                                             width: 100,
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.end,
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 SizedBox(
//                                                   width: 20,
//                                                   child: Obx(() {
//                                                     return Checkbox(
//                                                       value: widget
//                                                           .calenderMapController
//                                                           .checkedList[index],
//                                                       onChanged: (value) {
//                                                         widget
//                                                             .calenderMapController
//                                                             .toggleCustomerSelection(
//                                                                 index,
//                                                                 value ?? false,
//                                                                 widget
//                                                                     .eventData);
//                                                       },
//                                                     );
//                                                   }),
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 SizedBox(
//                                                   width: 30,
//                                                   child: IconButton(
//                                                     constraints:
//                                                         const BoxConstraints(),
//                                                     onPressed: () {
//                                                       final CalendarEventData<
//                                                               EventData> event =
//                                                           widget
//                                                               .eventData[index];
//                                                       Navigator.of(context)
//                                                           .pop();
//                                                       WidgetsBinding.instance
//                                                           .addPostFrameCallback(
//                                                               (_) {
//                                                         homeController
//                                                             .sidebarXController
//                                                             .selectIndex(1);
//                                                         homeController
//                                                             .selectedIndex
//                                                             .value = 1;
//                                                         customerAndOrderController
//                                                             .setCustomerId(event
//                                                                     .event
//                                                                     ?.customerId ??
//                                                                 '');
//                                                         productsController
//                                                             .selectedCustomerName
//                                                             .value = event.event
//                                                                 ?.businessName ??
//                                                             '';
//                                                         productsController
//                                                             .selectedCustomerId
//                                                             .value = event.event
//                                                                 ?.customerId ??
//                                                             '';
//                                                         productsController
//                                                             .selectedCustomerImageUrl
//                                                             .value = event.event
//                                                                 ?.imageUrl ??
//                                                             '';
//                                                         Get.to(
//                                                             () =>
//                                                                 CustomerDachScreen(
//                                                                   isDirectDialogue:
//                                                                       true,
//                                                                   year: 2024,
//                                                                   isFromCalendar:
//                                                                       false,
//                                                                   cusId: event
//                                                                           .event!
//                                                                           .customerId ??
//                                                                       '',
//                                                                   cusName: event
//                                                                           .event!
//                                                                           .businessName ??
//                                                                       '',
//                                                                   cusImage: event
//                                                                           .event!
//                                                                           .imageUrl ??
//                                                                       '',
//                                                                   cusEmail: event
//                                                                           .event!
//                                                                           .email ??
//                                                                       '',
//                                                                   cusMobile: event
//                                                                           .event!
//                                                                           .mobileNo ??
//                                                                       '',
//                                                                   productsController:
//                                                                       productsController,
//                                                                   isFromGoogle:
//                                                                       false,
//                                                                 ),
//                                                             binding:
//                                                                 BindingsBuilder(
//                                                                     () {
//                                                           Get.lazyPut<
//                                                                   ApiWorker>(
//                                                               () =>
//                                                                   ApiWorker());
//                                                         }), id: 2);
//                                                         Provider.of<CustomersProvider>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .fetchCustomerDashboardData(
//                                                           event
//                                                               .event!.customerId
//                                                               .toString(),
//                                                         );
//                                                         Provider.of<CustomersProvider>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .fetchCustomerDashboardRevenueData(
//                                                           event
//                                                               .event!.customerId
//                                                               .toString(),
//                                                         );
//                                                         Provider.of<CustomersProvider>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .fetchCustomerDashboardDataSalseData(
//                                                                 event.event!
//                                                                     .customerId
//                                                                     .toString());
//                                                         Provider.of<CustomersProvider>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .fetchCustomersDataDash(
//                                                                 event.event!
//                                                                     .customerId
//                                                                     .toString());
//                                                         Provider.of<CustomersProvider>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .fetchCustomerDashboardCountData(
//                                                                 event.event!
//                                                                     .customerId
//                                                                     .toString());
//                                                       });
//                                                     },
//                                                     icon: const Icon(
//                                                       EneftyIcons
//                                                           .arrow_square_right_outline,
//                                                       color: primaryColor,
//                                                       size: 25,
//                                                     ),
//                                                     highlightColor: white,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 SizedBox(
//                                                   width: 30,
//                                                   child: Obx(
//                                                     () {
//                                                       if (widget
//                                                               .calenderMapController
//                                                               .currentLatLng
//                                                               .value ==
//                                                           null) {
//                                                         return Container(
//                                                           height: 30,
//                                                           width: 35,
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(10),
//                                                           child:
//                                                               const CircularProgressIndicator(
//                                                                   strokeWidth:
//                                                                       2),
//                                                         );
//                                                       }

//                                                       double currentLatitude =
//                                                           widget
//                                                               .calenderMapController
//                                                               .currentLatLng
//                                                               .value!
//                                                               .latitude;
//                                                       double currentLongitude =
//                                                           widget
//                                                               .calenderMapController
//                                                               .currentLatLng
//                                                               .value!
//                                                               .longitude;
//                                                       return IconButton(
//                                                         icon: const Icon(
//                                                           Icons
//                                                               .near_me_outlined,
//                                                           size: 25,
//                                                           color: red,
//                                                         ),
//                                                         onPressed: () async {
//                                                           final isOnline =
//                                                               await ConnectivityService()
//                                                                   .isOnline();
//                                                           if (!isOnline) {
//                                                             showCustomToastDisplay(
//                                                               context,
//                                                               'You are offline. Show Route is disabled.',
//                                                               red,
//                                                               Icons.close,
//                                                             );
//                                                             return;
//                                                           }
//                                                           if (subscriptionController
//                                                                   .visitNavigation
//                                                                   .value ==
//                                                               "true") {
//                                                             selectedCustomer = widget
//                                                                 .calenderMapController
//                                                                 .selectedCustomers[index];
//                                                             navigatedToMap =
//                                                                 true;
//                                                             navigateToo(
//                                                               currentLatitude,
//                                                               currentLongitude,
//                                                               double.parse(
//                                                                   selectedCustomer
//                                                                           ?.latitude ??
//                                                                       ''),
//                                                               double.parse(
//                                                                   selectedCustomer
//                                                                           ?.longitude ??
//                                                                       ''),
//                                                             );
//                                                           } else {
//                                                             showUpgradePlanDialog(
//                                                                 context);
//                                                           }
//                                                         },
//                                                         highlightColor: white,
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                             if (isPhonePortrait(context)) {
//                               return Padding(
//                                 padding: nkSmallPadding(left: 0, right: 0),
//                                 child: InkWell(
//                                   highlightColor: Colors.transparent,
//                                   splashFactory: NoSplash.splashFactory,
//                                   child: Card(
//                                     elevation: 10,
//                                     shadowColor: black.withOpacity(0.2),
//                                     color: white,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(15.0),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               // Avatar
//                                               CircleAvatar(
//                                                 backgroundImage: NetworkImage(
//                                                   '${ApiConstants.imageBaseUrl}${customer.imageUrl}',
//                                                 ),
//                                                 radius: 24,
//                                               ),
//                                               const SizedBox(width: 12),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     // Title
//                                                     CustomText(
//                                                       content:
//                                                           customer.businessName,
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       fontSize: 14,
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         CustomText(
//                                                           content:
//                                                               customer.mobileno,
//                                                           fontSize: 12,
//                                                           maxLine: 1,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                         CustomText(
//                                                           content:
//                                                               customer.email,
//                                                           fontSize: 12,
//                                                           maxLine: 1,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           nkMediumSizeBox(),
//                                           nkMediumSizeBox(),
//                                           Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               CustomText(
//                                                 content: "Time : ",
//                                                 fontSize: 12,
//                                                 maxLine: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               TimePickerField(
//                                                 eventId: customer.eventId,
//                                                 initialHour: initialHour,
//                                                 initialMinute: initialMinute,
//                                                 initialPeriod: initialPeriod,
//                                                 onTimeSelected:
//                                                     (eventId, time) {
//                                                   setState(() {
//                                                     selectedEventTimes[
//                                                         eventId] = time;
//                                                     // Update the scheduleTime for the customer in customerOnlyList
//                                                     customer.scheduleTime =
//                                                         time;
//                                                   });
//                                                 },
//                                               ),
//                                               Spacer(),

//                                               const SizedBox(width: 8),

//                                               // Trailing icons
//                                               SizedBox(
//                                                 width: 100,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.end,
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     // Checkbox
//                                                     SizedBox(
//                                                       width: 20,
//                                                       child: Obx(() {
//                                                         return Checkbox(
//                                                           value: widget
//                                                               .calenderMapController
//                                                               .checkedList[index],
//                                                           onChanged: (value) {
//                                                             widget
//                                                                 .calenderMapController
//                                                                 .toggleCustomerSelection(
//                                                                     index,
//                                                                     value ??
//                                                                         false,
//                                                                     widget
//                                                                         .eventData);
//                                                           },
//                                                         );
//                                                       }),
//                                                     ),
//                                                     const SizedBox(width: 4),

//                                                     // Navigation icon
//                                                     SizedBox(
//                                                       width: 30,
//                                                       child: IconButton(
//                                                         constraints:
//                                                             const BoxConstraints(),
//                                                         onPressed: () {
//                                                           final CalendarEventData<
//                                                                   EventData>
//                                                               event =
//                                                               widget.eventData[
//                                                                   index];
//                                                           Navigator.of(context)
//                                                               .pop();
//                                                           WidgetsBinding
//                                                               .instance
//                                                               .addPostFrameCallback(
//                                                                   (_) {
//                                                             homeController
//                                                                 .sidebarXController
//                                                                 .selectIndex(1);
//                                                             homeController
//                                                                 .selectedIndex
//                                                                 .value = 1;
//                                                             customerAndOrderController
//                                                                 .setCustomerId(event
//                                                                         .event
//                                                                         ?.customerId ??
//                                                                     '');
//                                                             productsController
//                                                                 .selectedCustomerName
//                                                                 .value = event
//                                                                     .event
//                                                                     ?.businessName ??
//                                                                 '';
//                                                             productsController
//                                                                 .selectedCustomerId
//                                                                 .value = event
//                                                                     .event
//                                                                     ?.customerId ??
//                                                                 '';
//                                                             productsController
//                                                                 .selectedCustomerImageUrl
//                                                                 .value = event
//                                                                     .event
//                                                                     ?.imageUrl ??
//                                                                 '';
//                                                             Get.to(
//                                                                 () =>
//                                                                     CustomerDachScreen(
//                                                                       isDirectDialogue:
//                                                                           true,
//                                                                       year:
//                                                                           2024,
//                                                                       isFromCalendar:
//                                                                           false,
//                                                                       cusId: event
//                                                                               .event!
//                                                                               .customerId ??
//                                                                           '',
//                                                                       cusName:
//                                                                           event.event!.businessName ??
//                                                                               '',
//                                                                       cusImage:
//                                                                           event.event!.imageUrl ??
//                                                                               '',
//                                                                       cusEmail:
//                                                                           event.event!.email ??
//                                                                               '',
//                                                                       cusMobile:
//                                                                           event.event!.mobileNo ??
//                                                                               '',
//                                                                       productsController:
//                                                                           productsController,
//                                                                       isFromGoogle:
//                                                                           false,
//                                                                     ),
//                                                                 binding:
//                                                                     BindingsBuilder(
//                                                                         () {
//                                                               Get.lazyPut<
//                                                                       ApiWorker>(
//                                                                   () =>
//                                                                       ApiWorker());
//                                                             }), id: 2);
//                                                             Provider.of<CustomersProvider>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .fetchCustomerDashboardData(
//                                                               event.event!
//                                                                   .customerId
//                                                                   .toString(),
//                                                             );
//                                                             Provider.of<CustomersProvider>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .fetchCustomerDashboardRevenueData(
//                                                               event.event!
//                                                                   .customerId
//                                                                   .toString(),
//                                                             );
//                                                             Provider.of<CustomersProvider>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .fetchCustomerDashboardDataSalseData(event
//                                                                     .event!
//                                                                     .customerId
//                                                                     .toString());
//                                                             Provider.of<CustomersProvider>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .fetchCustomersDataDash(event
//                                                                     .event!
//                                                                     .customerId
//                                                                     .toString());
//                                                             Provider.of<CustomersProvider>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .fetchCustomerDashboardCountData(event
//                                                                     .event!
//                                                                     .customerId
//                                                                     .toString());
//                                                           });
//                                                         },
//                                                         icon: const Icon(
//                                                           EneftyIcons
//                                                               .arrow_square_right_outline,
//                                                           color: primaryColor,
//                                                           size: 25,
//                                                         ),
//                                                         highlightColor: white,
//                                                       ),
//                                                     ),

//                                                     const SizedBox(width: 4),

//                                                     // Near Me Button
//                                                     SizedBox(
//                                                       width: 30,
//                                                       child: Obx(
//                                                         () {
//                                                           if (widget
//                                                                   .calenderMapController
//                                                                   .currentLatLng
//                                                                   .value ==
//                                                               null) {
//                                                             return Container(
//                                                               height: 30,
//                                                               width: 35,
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(10),
//                                                               child:
//                                                                   const CircularProgressIndicator(
//                                                                       strokeWidth:
//                                                                           2),
//                                                             );
//                                                           }

//                                                           double
//                                                               currentLatitude =
//                                                               widget
//                                                                   .calenderMapController
//                                                                   .currentLatLng
//                                                                   .value!
//                                                                   .latitude;
//                                                           double
//                                                               currentLongitude =
//                                                               widget
//                                                                   .calenderMapController
//                                                                   .currentLatLng
//                                                                   .value!
//                                                                   .longitude;
//                                                           return IconButton(
//                                                             icon: const Icon(
//                                                               Icons
//                                                                   .near_me_outlined,
//                                                               size: 25,
//                                                               color: red,
//                                                             ),
//                                                             onPressed:
//                                                                 () async {
//                                                               final isOnline =
//                                                                   await ConnectivityService()
//                                                                       .isOnline();
//                                                               if (!isOnline) {
//                                                                 showCustomToastDisplay(
//                                                                   context,
//                                                                   'You are offline. Show Route is disabled.',
//                                                                   red,
//                                                                   Icons.close,
//                                                                 );
//                                                                 return;
//                                                               }
//                                                               if (subscriptionController
//                                                                       .visitNavigation
//                                                                       .value ==
//                                                                   "true") {
//                                                                 selectedCustomer = widget
//                                                                     .calenderMapController
//                                                                     .selectedCustomers[index];
//                                                                 navigatedToMap =
//                                                                     true;
//                                                                 navigateToo(
//                                                                   currentLatitude,
//                                                                   currentLongitude,
//                                                                   double.parse(
//                                                                       selectedCustomer
//                                                                               ?.latitude ??
//                                                                           ''),
//                                                                   double.parse(
//                                                                       selectedCustomer
//                                                                               ?.longitude ??
//                                                                           ''),
//                                                                 );
//                                                               } else {
//                                                                 showUpgradePlanDialog(
//                                                                     context);
//                                                               }
//                                                             },
//                                                             highlightColor:
//                                                                 white,
//                                                           );
//                                                         },
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                             return null;
//                           },
//                         ),
//                       )
//                     : const SizedBox(),
//                 // Padding(
//                 //   padding: const EdgeInsets.only(bottom: 30),
//                 //   child: ElevatedButton.icon(
//                 //     label: CustomText(
//                 //         content: selectedEventTimes.isNotEmpty
//                 //             ? 'Save and Show Route'
//                 //             : 'Show Route',
//                 //         color: white),
//                 //     onPressed: () async {
//                 //       if (selectedEventTimes.isNotEmpty) {
//                 //         var saveVisit = await ApiWorker()
//                 //             .scheduleVisit(events: selectedEventTimes);
//                 //         if (saveVisit.statusCode == 200) {
//                 //           selectedEventTimes.clear();
//                 //           showCustomToastDisplay(context, "Visits Saved",
//                 //               Colors.green, Icons.check);
//                 //         }
//                 //       }

//                 //       if (subscriptionController.appShowRoute.value == 'true') {
//                 //         if (widget.calenderMapController.selectedCustomers
//                 //             .isNotEmpty) {
//                 //           Navigator.pop(context);
//                 //           widget.calenderMapController
//                 //               .showSelectedCustomerRoute(context);
//                 //           widget.calenderMapController.fetchDistanceAndTime();
//                 //         } else {
//                 //           Get.snackbar('No Route Available',
//                 //               'Please select at least one customer.');
//                 //         }
//                 //       } else {
//                 //         showUpgradePlanDialog(context);
//                 //       }
//                 //     },
//                 //     style: ButtonStyle(
//                 //       backgroundColor: WidgetStateProperty.all(primaryColor),
//                 //     ),
//                 //     icon: const Icon(
//                 //       EneftyIcons.location_outline,
//                 //       color: white,
//                 //       size: 25,
//                 //     ),
//                 //   ),
//                 // ),
//                 isSaving
//                     ? const Padding(
//                         padding: EdgeInsets.only(bottom: 30),
//                         child: Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       )
//                     : Padding(
//                         padding: const EdgeInsets.only(bottom: 30),
//                         child: ElevatedButton.icon(
//                           label: CustomText(
//                             content: selectedEventTimes.isNotEmpty
//                                 ? 'Save'
//                                 : 'Show Route',
//                             color: white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           style: ButtonStyle(
//                             padding: const WidgetStatePropertyAll(
//                                 EdgeInsets.all(20)),
//                             backgroundColor: MaterialStateProperty.all(
//                               selectedEventTimes.isNotEmpty
//                                   ? Colors.green
//                                   : primaryColor,
//                             ),
//                           ),
//                           icon: Icon(
//                             selectedEventTimes.isNotEmpty
//                                 ? Icons.save_rounded
//                                 : EneftyIcons.location_outline,
//                             color: white,
//                             size: 25,
//                           ),



//   onPressed: () async {
//                             // 1. Checks
//                             final isOnline =
//                                 await ConnectivityService().isOnline();
//                             if (!isOnline) {
//                               showCustomToastDisplay(context,
//                                   'You are offline.', red, Icons.close);
//                               return;
//                             }

//                             if (subscriptionController.appShowRoute.value ==
//                                 'true') {
//                               if (widget.calenderMapController.routeCredit
//                                           .value !=
//                                       '0' &&
//                                   widget.calenderMapController.routeCredit
//                                           .value !=
//                                       '') {
//                                 // Date check
//                                 DateTime today = DateTime.now();
//                                 DateTime currentDate = DateTime(
//                                     today.year, today.month, today.day);
//                                 DateTime widgetDate = DateTime(
//                                     widget.dateTime.year,
//                                     widget.dateTime.month,
//                                     widget.dateTime.day);

//                                 if (widgetDate.isAfter(currentDate)) {
//                                   showCustomToastDisplay(
//                                       context,
//                                       'This route can be accessed from $formattedDate',
//                                       Colors.orange,
//                                       Icons.warning);
//                                   return;
//                                 }
//                                   if (widgetDate.isBefore(currentDate)) {
//                                   showCustomToastDisplay(
//                                       context,
//                                       'This route can be accessed from $formattedDate',
//                                       Colors.orange,
//                                       Icons.warning);
//                                   return;
//                                 }
//                                 Get.back();
//                                 // 2. Just Open Dialog (Pass Data Down)
//                                 showDialog(
//                                   context: context,
//                                   barrierDismissible: false,
//                                   builder: (context) => RouteInputDialog(
//                                     controller: _mapController,
//                                     currentAddress: _mapController
//                                         .currentLocationText.value,
//                                     currentLatLng:
//                                         _mapController.currentLatLng.value ??
//                                             const LatLng(0, 0),
//                                     // Pass the necessary lists for the logic to work inside the dialog
//                                     customerIds: widget.customerIds,
//                                     eventData: widget.eventData,
//                                   ),
//                                 );
//                               } else {
//                                 showCustomToastDisplay(
//                                     context,
//                                     "Buy More Credits to Continue",
//                                     red,
//                                     Icons.close);
//                               }
//                             } else {
//                               showDialog(
//                                 barrierDismissible: false,
//                                 context: context,
//                                 builder: (context) => const UpgradePlanScreen(),
//                               );
//                             }
//                           },

//                           // onPressed: () async {
//                           //   final isOnline =
//                           //       await ConnectivityService().isOnline();
//                           //   if (!isOnline) {
//                           //     showCustomToastDisplay(
//                           //       context,
//                           //       'You are offline. Show Route is disabled.',
//                           //       red,
//                           //       Icons.close,
//                           //     );
//                           //     return;
//                           //   }
//                           //   // === Save Mode ===
//                           //   if (selectedEventTimes.isNotEmpty) {
//                           //     setState(() => isSaving = true);

//                           //     final events = widget.eventData
//                           //         .map((customer) {
//                           //           final eventId =
//                           //               customer.event?.eventId ?? '';
//                           //           return {
//                           //             'event_id': eventId,
//                           //             'time': selectedEventTimes[eventId] ?? '',
//                           //           };
//                           //         })
//                           //         .where((e) => e['time']!.isNotEmpty)
//                           //         .toList();

//                           //     var saveVisit = await ApiWorker()
//                           //         .scheduleVisit(events: events);

//                           //     if (saveVisit.statusCode == 200) {
//                           //       selectedEventTimes.clear();
//                           //       showCustomToastDisplay(context, "Visits Saved",
//                           //           Colors.green, Icons.check);
//                           //     }

//                           //     setState(() => isSaving = false);

//                           //     return;
//                           //   }

//                           //   // === Show Route Mode ===
//                           //   if (subscriptionController.appShowRoute.value ==
//                           //       'true') {
//                           //     if (widget.calenderMapController.routeCredit
//                           //                 .value !=
//                           //             '0' &&
//                           //         widget.calenderMapController.routeCredit
//                           //                 .value !=
//                           //             '') {
//                           //       DateTime today = DateTime.now();
//                           //       DateTime currentDate = DateTime(
//                           //           today.year, today.month, today.day);
//                           //       DateTime widgetDate = DateTime(
//                           //           widget.dateTime.year,
//                           //           widget.dateTime.month,
//                           //           widget.dateTime.day);

//                           //       // ✅ Check if all selected customers have a scheduleTime
//                           //       // bool allHaveScheduleTime = widget
//                           //       //     .calenderMapController.selectedCustomers
//                           //       //     .every((customer) =>
//                           //       //         customer. != null &&
//                           //       //         customer.scheduleTime
//                           //       //             .toString()
//                           //       //             .isNotEmpty);

//                           //       // if (!allHaveScheduleTime) {
//                           //       //   showCustomToastDisplay(
//                           //       //     context,
//                           //       //     'All selected customers must have a schedule time.',
//                           //       //     Colors.orange,
//                           //       //     Icons.warning,
//                           //       //   );
//                           //       //   return; // stop execution here
//                           //       // }

//                           //       if (widgetDate.isAfter(currentDate)) {
//                           //         showCustomToastDisplay(
//                           //           context,
//                           //           'This route can be accessed from $formattedDate',
//                           //           Colors.orange,
//                           //           Icons.warning,
//                           //         );
//                           //       } else {
//                           //         Navigator.pop(context);

//                           //         List<String> addresses = widget
//                           //             .calenderMapController.selectedCustomers
//                           //             .map((customer) =>
//                           //                 customer.address.toString())
//                           //             .toList();

//                           //         var creditResponse =
//                           //             await ApiWorker().debitRouteCredits(
//                           //           amount: addresses.length * 3,
//                           //           details: 'TESTING',
//                           //           addresses: addresses,
//                           //         );

//                           //         await widget.calenderMapController
//                           //             .updateCredit(
//                           //           creditResponse.credit.toString(),
//                           //         );

//                           //         // widget.calenderMapController
//                           //         //     .showSelectedCustomerRoute(
//                           //         //   context,
//                           //         // );
//                           //         {
//                           //           final selectedCustomerIds = widget
//                           //               .calenderMapController.selectedCustomers
//                           //               .map((c) => c.customerId)
//                           //               .toSet();

//                           //           final selectedEventIds = widget.eventData
//                           //               .where((event) =>
//                           //                   event.event != null &&
//                           //                   selectedCustomerIds.contains(event
//                           //                       .event!.customerId
//                           //                       .toString()))
//                           //               .map((event) => event.event!.eventId)
//                           //               .whereType<
//                           //                   String>() // removes nulls and casts to List<String>
//                           //               .toList();

//                           //           final selectedCustomerIdList = widget
//                           //               .eventData
//                           //               .where((event) =>
//                           //                   event.event != null &&
//                           //                   selectedCustomerIds.contains(event
//                           //                       .event!.customerId
//                           //                       .toString()))
//                           //               .map((event) => event.event!.customerId)
//                           //               .whereType<String>()
//                           //               .toList();

//                           //           widget.calenderMapController
//                           //               .showSelectedCustomerRoute(
//                           //             context,
//                           //             selectedCustomerIdList,
//                           //             selectedEventIds,
//                           //           );
//                           //         }

//                           //         widget.calenderMapController
//                           //             .fetchDistanceAndTime();
//                           //       }
//                           //     } else {
//                           //       showCustomToastDisplay(
//                           //         context,
//                           //         "Buy More Credits to Continue",
//                           //         red,
//                           //         Icons.close,
//                           //       );
//                           //     }
//                           //   } else {
//                           //     showUpgradePlanDialog(context);
//                           //   }
//                           // },
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         );
//       });
//     });
//   }
}
