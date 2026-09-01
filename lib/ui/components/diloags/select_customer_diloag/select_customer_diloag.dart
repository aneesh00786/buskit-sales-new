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

  const SelectCustomerDiloag({
    super.key,
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
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confirm Visit'.tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkResponse(
                        onTap: () => Navigator.of(context).pop(),
                        child: const CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child:
                              Icon(Icons.close, color: Colors.white, size: 22),
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
                      ClipOval(
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            border: Border.all(
                                color: primaryColor.withOpacity(0.15)),
                          ),
                          child: Image.network(
                            '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  color: Color(0xFF94A3B8), size: 32);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        customer.businessName ?? 'Customer',
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reached Customer?'.tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
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
                              productsController.selectedCustomerImageUrl
                                  .value = customer.imageUrl ?? '';

                              Get.to(
                                  CustomerDachScreen(
                                    cusId: customer.customerId.toString(),
                                    cusName: customer.businessName.toString(),
                                    cusImage: customer.imageUrl.toString(),
                                    cusEmail: customer.email ?? '',
                                    cusMobile: customer.mobileno ?? '',
                                    isFromCalendar: true,
                                    isFromGoogle: true,
                                    eventIds: widget.eventData
                                        .map((e) => e.event!.eventId.toString())
                                        .toList(),
                                    customerIds: widget.customerIds,
                                  ),
                                  id: 2);

                              final dashProvider =
                                  Provider.of<CustomersProvider>(context,
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
                              style: TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();

                            if (subscriptionController.visitNavigation.value ==
                                "true") {
                              final lat = _mapController
                                      .currentLatLng.value?.latitude ??
                                  0.0;
                              final lng = _mapController
                                      .currentLatLng.value?.longitude ??
                                  0.0;

                              navigateToo(
                                  lat,
                                  lng,
                                  double.tryParse(customer.latitude ?? '0') ??
                                      0.0,
                                  double.tryParse(customer.longitude ?? '0') ??
                                      0.0);
                            } else {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const UpgradePlanScreen(),
                              );
                            }
                          },
                          child: const Text('Continue Navigation',
                              style: TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: primaryColor,
                              )),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 3. CANCEL ACTION
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            )),
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
                  ? DiloagAppBar(
                      title: "Customer Visit For Today".tr,
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                  : DiloagAppBar(
                      title: 'Customer Visit For'.tr + ' $formattedDate',
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
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
                  ? DiloagAppBar(
                      title: "Customer Visit For Today".tr,
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                  : DiloagAppBar(
                      title: 'Customer Visit For'.tr + ' $formattedDate',
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
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
                            content: "Customers".tr,
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
                        child: RawScrollbar(
                          thumbVisibility: true,
                          thumbColor: Colors.blue,
                          trackVisibility: true,
                          trackColor: Colors.grey.withOpacity(0.2),
                          thickness: 6.0,
                          radius: const Radius.circular(10),
                          child: ListView.builder(
                            padding: nkRegularPadding(),
                            itemCount: filteredEventData.length,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                int displayHour =
                                    hour % 12 == 0 ? 12 : hour % 12;
                                String period = hour >= 12 ? 'PM' : 'AM';

                                initialHour =
                                    displayHour.toString().padLeft(2, '0');
                                initialMinute =
                                    minute.toString().padLeft(2, '0');
                                initialPeriod = period;
                              }

                              if (!isPhonePortrait(context)) {
                                return Padding(
                                  padding: nkSmallPadding(left: 0, right: 0),
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                    child: Card(
                                      elevation: 0,
                                      shadowColor:
                                          Colors.black.withOpacity(0.08),
                                      color: white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Avatar
                                            ClipOval(
                                              child: Container(
                                                height: 48,
                                                width: 48,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE2E8F0),
                                                  border: Border.all(
                                                      color: primaryColor
                                                          .withOpacity(0.15)),
                                                ),
                                                child: Image.network(
                                                  '${ApiConstants.imageBaseUrl}${customer.imageUrl}',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.person,
                                                        color:
                                                            Color(0xFF94A3B8),
                                                        size: 24);
                                                  },
                                                ),
                                              ),
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
                                                    color:
                                                        const Color(0xFF0F172A),
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
                                                        color: const Color(
                                                            0xFF64748B),
                                                      ),
                                                      CustomText(
                                                        content: customer.email,
                                                        fontSize: 12,
                                                        maxLine: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: const Color(
                                                            0xFF64748B),
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
                                              width: 128,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Checkbox
                                                  SizedBox(
                                                    width: 34,
                                                    child: Obx(() {
                                                      final isChecked = widget
                                                          .calenderMapController
                                                          .checkedList[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          widget
                                                              .calenderMapController
                                                              .toggleCustomerSelection(
                                                            index,
                                                            !isChecked,
                                                            filteredEventData[
                                                                index],
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 34,
                                                          width: 34,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: isChecked
                                                                ? primaryColor
                                                                : Colors.white,
                                                            border: Border.all(
                                                              color: isChecked
                                                                  ? primaryColor
                                                                  : const Color(
                                                                      0xFFCBD5E1),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: isChecked
                                                              ? const Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 18,
                                                                )
                                                              : null,
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  const SizedBox(width: 10),

                                                  // Navigation icon
                                                  SizedBox(
                                                    width: 34,
                                                    child: Container(
                                                      height: 34,
                                                      width: 34,
                                                      decoration: BoxDecoration(
                                                        color: primaryColor
                                                            .withOpacity(0.08),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: IconButton(
                                                        padding:
                                                            EdgeInsets.zero,
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
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: primaryColor,
                                                          size: 14,
                                                        ),
                                                        highlightColor: white,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  // Near Me Button
                                                  SizedBox(
                                                    width: 34,
                                                    child: Obx(() {
                                                      if (_mapController
                                                              .currentLatLng
                                                              .value ==
                                                          null) {
                                                        return Container(
                                                          height: 34,
                                                          width: 34,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
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
                                                      double currentLongitude =
                                                          _mapController
                                                              .currentLatLng
                                                              .value!
                                                              .longitude;

                                                      return Container(
                                                        height: 34,
                                                        width: 34,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              red.withOpacity(
                                                                  0.08),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                          icon: const Icon(
                                                            Icons
                                                                .navigation_rounded,
                                                            size: 18,
                                                            color: red,
                                                          ),
                                                          onPressed: () async {
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
                                                              // Parse coordinates first
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

                                                              // If coordinates are missing (0.0), geocode the address
                                                              if (destLat ==
                                                                      0.0 &&
                                                                  destLng ==
                                                                      0.0) {
                                                                // Check if customer has an address
                                                                if (navCustomer
                                                                            .address ==
                                                                        null ||
                                                                    navCustomer
                                                                        .address!
                                                                        .isEmpty) {
                                                                  showCustomToastDisplay(
                                                                      context,
                                                                      'Customer address not available.',
                                                                      red,
                                                                      Icons
                                                                          .error_outline);
                                                                  return;
                                                                }

                                                                // Geocode the address
                                                                print(
                                                                    'Geocoding address: ${navCustomer.address}');
                                                                LatLng? coords =
                                                                    await _mapController
                                                                        .getLatLngFromAddress(
                                                                            navCustomer.address!);

                                                                if (coords ==
                                                                    null) {
                                                                  showCustomToastDisplay(
                                                                      context,
                                                                      'Unable to find location for this address.',
                                                                      red,
                                                                      Icons
                                                                          .error_outline);
                                                                  return;
                                                                }

                                                                // Use the geocoded coordinates
                                                                destLat = coords
                                                                    .latitude;
                                                                destLng = coords
                                                                    .longitude;
                                                                print(
                                                                    'Geocoded coordinates - Lat: $destLat, Lng: $destLng');
                                                              }

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
                                                                latitude: customer
                                                                    .latitude,
                                                                longitude: customer
                                                                    .longitude,
                                                              );
                                                              navigatedToMap =
                                                                  true;

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
                                                        ),
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
                                      elevation: 0,
                                      shadowColor:
                                          Colors.black.withOpacity(0.08),
                                      color: white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(
                                            color: Color(0xFFE2E8F0)),
                                      ),
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
                                                ClipOval(
                                                  child: Container(
                                                    height: 48,
                                                    width: 48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFE2E8F0),
                                                      border: Border.all(
                                                          color: primaryColor
                                                              .withOpacity(
                                                                  0.15)),
                                                    ),
                                                    child: Image.network(
                                                      '${ApiConstants.imageBaseUrl}${customer.imageUrl}',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                            Icons.person,
                                                            color: Color(
                                                                0xFF94A3B8),
                                                            size: 24);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Title
                                                      CustomText(
                                                        content: customer
                                                            .businessName,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        color: const Color(
                                                            0xFF0F172A),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            content: customer
                                                                .mobileno,
                                                            fontSize: 12,
                                                            maxLine: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            color: const Color(
                                                                0xFF64748B),
                                                          ),
                                                          CustomText(
                                                            content:
                                                                customer.email,
                                                            fontSize: 12,
                                                            maxLine: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            color: const Color(
                                                                0xFF64748B),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  width: 128,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Checkbox
                                                      SizedBox(
                                                        width: 34,
                                                        child: Obx(() {
                                                          final isChecked = widget
                                                              .calenderMapController
                                                              .checkedList[index];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              widget
                                                                  .calenderMapController
                                                                  .toggleCustomerSelection(
                                                                index,
                                                                !isChecked,
                                                                filteredEventData[
                                                                    index],
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 34,
                                                              width: 34,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: isChecked
                                                                    ? primaryColor
                                                                    : Colors
                                                                        .white,
                                                                border:
                                                                    Border.all(
                                                                  color: isChecked
                                                                      ? primaryColor
                                                                      : const Color(
                                                                          0xFFCBD5E1),
                                                                  width: 1.5,
                                                                ),
                                                              ),
                                                              child: isChecked
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 18,
                                                                    )
                                                                  : null,
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      const SizedBox(width: 10),

                                                      // Navigation icon
                                                      SizedBox(
                                                        width: 34,
                                                        child: Container(
                                                          height: 34,
                                                          width: 34,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primaryColor
                                                                .withOpacity(
                                                                    0.08),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            onPressed: () {
                                                              final CalendarEventData<
                                                                      EventData>
                                                                  event =
                                                                  widget.eventData[
                                                                      index];
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              WidgetsBinding
                                                                  .instance
                                                                  .addPostFrameCallback(
                                                                      (_) {
                                                                homeController
                                                                    .sidebarXController
                                                                    .selectIndex(
                                                                        1);
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
                                                              Icons
                                                                  .arrow_forward_ios_rounded,
                                                              color:
                                                                  primaryColor,
                                                              size: 14,
                                                            ),
                                                            highlightColor:
                                                                white,
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      // Near Me Button
                                                      SizedBox(
                                                        width: 34,
                                                        child: Obx(() {
                                                          if (_mapController
                                                                  .currentLatLng
                                                                  .value ==
                                                              null) {
                                                            return Container(
                                                              height: 34,
                                                              width: 34,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              child:
                                                                  const CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            );
                                                          }
                                                          double
                                                              currentLatitude =
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

                                                          return Container(
                                                            height: 34,
                                                            width: 34,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: red
                                                                  .withOpacity(
                                                                      0.08),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              icon: const Icon(
                                                                Icons
                                                                    .navigation_rounded,
                                                                size: 18,
                                                                color: red,
                                                              ),
                                                              onPressed:
                                                                  () async {
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
                                                                      Icons
                                                                          .close);
                                                                  return;
                                                                }

                                                                if (subscriptionController
                                                                        .visitNavigation
                                                                        .value ==
                                                                    "true") {
                                                                  // FIX: Use 'navCustomer' here because it is type 'Customer'
                                                                  selectedCustomer =
                                                                      Customer(
                                                                    customerId:
                                                                        customer
                                                                            .customerId,
                                                                    businessName:
                                                                        customer
                                                                            .businessName,
                                                                    email: customer
                                                                        .email,
                                                                    mobileno:
                                                                        customer
                                                                            .mobileno,
                                                                    imageUrl:
                                                                        customer
                                                                            .imageUrl,
                                                                    // USE THE FRESH COORDINATES HERE:
                                                                    latitude:
                                                                        customer
                                                                            .latitude,
                                                                    longitude:
                                                                        customer
                                                                            .longitude,
                                                                  );
                                                                  navigatedToMap =
                                                                      true;

                                                                  // Use tryParse on 'navCustomer' to get coordinates safely
                                                                  double
                                                                      destLat =
                                                                      double.tryParse(navCustomer.latitude ??
                                                                              '0') ??
                                                                          0.0;
                                                                  double
                                                                      destLng =
                                                                      double.tryParse(navCustomer.longitude ??
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
                                                              highlightColor:
                                                                  white,
                                                            ),
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
                                ? 'Save'.tr
                                : 'Show Route'.tr,
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
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            elevation: const MaterialStatePropertyAll(0),
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
                              // Date check
                              DateTime today = DateTime.now();
                              DateTime currentDate =
                                  DateTime(today.year, today.month, today.day);
                              DateTime widgetDate = DateTime(
                                  widget.dateTime.year,
                                  widget.dateTime.month,
                                  widget.dateTime.day);

                              if (widgetDate.isAfter(currentDate)) {
                                showCustomToastDisplay(
                                    context,
                                    "Only current and working day's route can be generated"
                                        .tr,
                                    // 'This route can be accessed from $formattedDate',
                                    Colors.orange,
                                    Icons.warning);
                                return;
                              }
                              if (widgetDate.isBefore(currentDate)) {
                                showCustomToastDisplay(
                                    context,
                                    "Only current and working day's route can be generated"
                                        .tr,
                                    // 'This route can be accessed from $formattedDate',
                                    Colors.orange,
                                    Icons.warning);
                                return;
                              }
                              Get.back();
                              await _mapController.saveCustomersToHive(
                                  _mapController.selectedCustomers);
                              // 2. Just Open Dialog (Pass Data Down)
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => RouteInputDialog(
                                  controller: _mapController,
                                  currentAddress:
                                      _mapController.currentLocationText.value,
                                  currentLatLng:
                                      _mapController.currentLatLng.value ??
                                          const LatLng(0, 0),
                                  // Pass the necessary lists for the logic to work inside the dialog
                                  customerIds: widget.customerIds,
                                  eventData: widget.eventData,
                                ),
                              );
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

//
}
