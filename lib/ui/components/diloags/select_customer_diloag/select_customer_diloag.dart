import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/app_bar/diloag_app_bar.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/custmerlist_and_map.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calendar_responce/calender_all_event_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dashbord_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectCustomerDiloag extends StatefulWidget {
  final DateTime dateTime;
  final CalenderMapController calenderMapController;
  final List<CalendarEventData<EventData>> eventData;
  final bool istoGoogleMap;

  SelectCustomerDiloag(
      {super.key,
      required this.dateTime,
      required this.calenderMapController,
      required this.eventData,
      this.istoGoogleMap = false});

  @override
  State<SelectCustomerDiloag> createState() => _SelectCustomerDiloagState();
}

class _SelectCustomerDiloagState extends State<SelectCustomerDiloag>
    with WidgetsBindingObserver {
  final HomeController homeController = Get.put(HomeController());
  final ProductsController productsController = Get.put(ProductsController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.calenderMapController.suggestions.clear();
      widget.calenderMapController.searchedLatLng.value = null;
      widget.calenderMapController.getDirections();
      widget.calenderMapController.getCurrentLocation();
    });
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
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    '${ApiConstants.imageBaseUrl}${customer.imageUrl ?? ''}'),
              ),
              SizedBox(width: 8),
              Text("${customer.businessName ?? ''}"),
            ],
          ),
          content: CustomText(
            content: 'Reached customer Location ?',
            fontSize: 17,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!widget.istoGoogleMap) {
                    Navigator.pop(context);
                  }
                  Navigator.pop(context);
                  homeController.sidebarXController.selectIndex(1);
                  homeController.selectedIndex.value = 1;
                  productsController.selectedCustomerName.value =
                      customer.businessName ?? '';
                  productsController.selectedCustomerImageUrl.value =
                      customer.imageUrl ?? '';
                  productsController.selectedCustomerId.value =
                      customer.customerId ?? '';
                  Get.to(
                    () => CustomerDachScreen(
                      isFromCalendar: true,
                      isDirectDialogue: true,
                    ),
                    id: 2,
                  );
                  final now = DateTime.now();
                  final startDate = DateTime(now.year, now.month, 1);
                  final endDate = DateTime(now.year, now.month + 1, 0);
                  final formattedStartDate =
                      DateFormat('yyyy-MM-dd').format(startDate);
                  final formattedEndDate =
                      DateFormat('yyyy-MM-dd').format(endDate);
                  final customerId = customer.customerId.toString();
                  final customersProvider =
                      Provider.of<CustomersProvider>(context, listen: false);
                  await Future.wait([
                    customersProvider.fetchCustomerDashboardData(
                        customerId, 2024, formattedStartDate, formattedEndDate),
                    customersProvider.fetchCustomerDashboardRevenueData(
                        customerId, 2024, formattedStartDate, formattedEndDate),
                    customersProvider.fetchCustomerDashboardDataSalseData(
                        customerId, 2024),
                    customersProvider.fetchCustomersDataDash(customerId),
                    customersProvider
                        .fetchCustomerDashboardCountData(customerId),
                  ]);
                });
              },
              child: Text("Go to Customer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.calenderMapController
        .initializeCheckedList(widget.eventData.length, widget.eventData);
    String formattedDate = DateFormat('dd/MM/yyyy').format(widget.dateTime);
    DateTime now = DateTime.now();
    bool isToday = widget.dateTime.year == now.year &&
        widget.dateTime.month == now.month &&
        widget.dateTime.day == now.day;
    return OrientationBuilder(builder: (context, ore) {
      return MyCommnonContainer(
        color: white,
        margin: AppDimensions.instance.orientation == Orientation.landscape
            ? nkExtraLargePadding(
                right: AppDimensions.instance.width * .20,
                left: AppDimensions.instance.width * .20)
            : nkExtraLargePadding(),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
          child: Column(
            children: [
              isToday
                  ? DiloagAppBar(title: "Customer Visit For Today")
                  : DiloagAppBar(title: "Customer Visit For $formattedDate"),
              widget.eventData.isNotEmpty
                  ? Flexible(
                      child: ListView.builder(
                        padding: nkRegularPadding(),
                        itemCount: widget.eventData.length,
                        itemBuilder: (context, index) {
                          CalendarEventData<EventData> customerEvent =
                              widget.eventData[index];
                          log('${customerEvent.event?.imageUrl}');
                          return Padding(
                            padding: nkSmallPadding(left: 0, right: 0),
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                              child: Card(
                                elevation: 10,
                                shadowColor: black.withOpacity(0.2),
                                color: white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        '${ApiConstants.imageBaseUrl}${customerEvent.event?.imageUrl ?? ''}'),
                                  ),
                                  title: CustomText(
                                    content:
                                        customerEvent.event?.businessName ?? '',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                          content:
                                              customerEvent.event?.address ??
                                                  ''),
                                      CustomText(
                                          content:
                                              customerEvent.event?.mobileNo ??
                                                  ''),
                                      CustomText(
                                          content:
                                              customerEvent.event?.email ?? ''),
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          child: Obx(() {
                                            return Checkbox(
                                              value: widget
                                                  .calenderMapController
                                                  .checkedList[index],
                                              onChanged: (value) {
                                                widget.calenderMapController
                                                    .toggleCustomerSelection(
                                                        index,
                                                        value ?? false,
                                                        widget.eventData);
                                              },
                                            );
                                          }),
                                        ),
                                        SizedBox(width: 4),
                                        SizedBox(
                                          width: 30,
                                          child: IconButton(
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              final CalendarEventData<EventData>
                                                  event =
                                                  widget.eventData[index];
                                              Navigator.of(context).pop();
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                homeController
                                                    .sidebarXController
                                                    .selectIndex(1);
                                                homeController
                                                    .selectedIndex.value = 1;
                                                log('${event.event!.customerId}');
                                                productsController
                                                        .selectedCustomerName
                                                        .value =
                                                    event.event!.businessName ??
                                                        '';
                                                productsController
                                                        .selectedCustomerId
                                                        .value =
                                                    event.event!.customerId ??
                                                        '';
                                                productsController
                                                    .selectedCustomerImageUrl
                                                    .value = event
                                                        .event!.imageUrl ??
                                                    '';
                                                Get.to(
                                                    () => CustomerDachScreen(
                                                          isDirectDialogue:
                                                              true,
                                                          year: 2024,
                                                          isFromCalendar: false,
                                                          cusId: event.event!
                                                                  .customerId ??
                                                              '',
                                                          cusName: event.event!
                                                                  .businessName ??
                                                              '',
                                                          cusImage: event.event!
                                                                  .imageUrl ??
                                                              '',
                                                          productsController:
                                                              productsController,
                                                          isFromGoogle: false,
                                                        ),
                                                    binding:
                                                        BindingsBuilder(() {
                                                  Get.lazyPut<ApiWorker>(
                                                      () => ApiWorker());
                                                }), id: 2);
                                                final now = DateTime.now();
                                                final startDate = DateTime(
                                                    now.year, now.month, 1);
                                                final endDate = DateTime(
                                                    now.year, now.month + 1, 0);
                                                final formattedStartDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(startDate);
                                                final formattedEndDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(endDate);
                                                Provider.of<CustomersProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchCustomerDashboardData(
                                                        event.event!.customerId
                                                            .toString(),
                                                        2024,
                                                        formattedStartDate,
                                                        formattedEndDate);
                                                Provider.of<CustomersProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchCustomerDashboardRevenueData(
                                                        event.event!.customerId
                                                            .toString(),
                                                        2024,
                                                        formattedStartDate,
                                                        formattedEndDate);
                                                Provider.of<CustomersProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchCustomerDashboardDataSalseData(
                                                        event.event!.customerId
                                                            .toString(),
                                                        2024);
                                                Provider.of<CustomersProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchCustomersDataDash(
                                                        event.event!.customerId
                                                            .toString());
                                                Provider.of<CustomersProvider>(
                                                        context,
                                                        listen: false)
                                                    .fetchCustomerDashboardCountData(
                                                        event.event!.customerId
                                                            .toString());
                                              });
                                            },
                                            icon: Icon(
                                              EneftyIcons
                                                  .arrow_square_right_outline,
                                              color: primaryColor,
                                              size: 25,
                                            ),
                                            highlightColor: white,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        SizedBox(
                                          width: 30,
                                          child: Obx(
                                            () {
                                              if (widget.calenderMapController
                                                      .currentLatLng.value ==
                                                  null) {
                                                return Container(
                                                  height: 30,
                                                  width: 35,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child:
                                                      const CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                );
                                              }

                                              double currentLatitude = widget
                                                  .calenderMapController
                                                  .currentLatLng
                                                  .value!
                                                  .latitude;
                                              double currentLongitude = widget
                                                  .calenderMapController
                                                  .currentLatLng
                                                  .value!
                                                  .longitude;
                                              return IconButton(
                                                icon: const Icon(
                                                  Icons.near_me_outlined,
                                                  size: 25,
                                                  color: red,
                                                ),
                                                onPressed: () {
                                                  selectedCustomer = widget
                                                      .calenderMapController
                                                      .selectedCustomers[index];
                                                  navigatedToMap = true;
                                                  navigateToo(
                                                    currentLatitude,
                                                    currentLongitude,
                                                    double.parse(
                                                        selectedCustomer
                                                                ?.latitude ??
                                                            ''),
                                                    double.parse(
                                                        selectedCustomer
                                                                ?.longitude ??
                                                            ''),
                                                  );
                                                  log('Selected Customer : ${selectedCustomer?.businessName}');
                                                },
                                                highlightColor: white,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  label: CustomText(content: 'Show Route', color: white),
                  onPressed: () {
                    if (widget
                        .calenderMapController.selectedCustomers.isNotEmpty) {
                      Navigator.pop(context);
                      widget.calenderMapController
                          .showSelectedCustomerRoute(context);
                      widget.calenderMapController.fetchDistanceAndTime();
                    } else {
                      Get.snackbar('No Route Available',
                          'Please select at least one customer.');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primaryColor),
                  ),
                  icon: Icon(
                    EneftyIcons.location_outline,
                    color: white,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
