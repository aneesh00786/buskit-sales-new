// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, non_constant_identifier_names, deprecated_member_use
import 'dart:developer';
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
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebarx.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dash_chart.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/frequently_bought_product.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/message/customer_category_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/orders_payments.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/total_sale_customer.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/total_sales.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../api_handler/api_worker.dart';
import 'package:hive/hive.dart';

class CustomerDachScreen extends StatefulWidget {
  final dynamic year;
  final dynamic startDate;
  final dynamic endDate;
  final String cusName;
  final String cusId;
  final String cusImage;
  final bool isFromCalendar;
  final bool isDirectDialogue;
  final bool isFromOrder;
  final bool isFromGoogle;
  final ProductsController? productsController;

  const CustomerDachScreen({
    super.key,
    this.year,
    this.startDate,
    this.endDate,
    required this.cusId,
    required this.cusName,
    required this.cusImage,
    this.isFromCalendar = false,
    this.isDirectDialogue = false,
    this.isFromOrder = false,
    this.productsController,
    this.isFromGoogle = false,
  });

  @override
  State<CustomerDachScreen> createState() => _CustomerDachScreenState();
}

class _CustomerDachScreenState extends State<CustomerDachScreen>
    with SingleTickerProviderStateMixin {
  int selectedYear = DateTime.now().year;
  late TabController _tabController;
  late int _tabIndex;
  HomeController homeController = Get.put(HomeController());
  CustomerAndOrderController customerOrderController =
      Get.find<CustomerAndOrderController>();
  final subscriptionController = Get.find<SubscriptionController>();
  final productsController = Get.find<ProductsController>();
  ApiWorker apiWorker = Get.put(ApiWorker());
  @override
  void initState() {
    super.initState();
    log('Is Calender :${widget.isFromCalendar}');
    log('Calender Calender Customer ID :${widget.cusId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomersProvider>(context, listen: false)
          .fetchCustomerDashboardDataSalseData(widget.cusId.toString());
    });
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

    // cartProvider.updateCartCount(customerOrderController.customerId.value);
    log('CustomerId 2 :${customerOrderController.customerId.value}');
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

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    checkCustomerOut();
    // check_back
    // customerOrderController.isActive.value = false;
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
            log("${widget.isDirectDialogue} +${widget.isFromCalendar} + ${widget.isFromGoogle}");
            log("Customer Id checkout: ${widget.cusId}");

            return AlertDialog(
              title: const Text('Customer Check-Out'),
              content: const Text('Customer will be checked-out!'),
              actions: [
                if (isCheckingOut)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  TextButton(
                    child: const Text('Stay'),
                    onPressed: () {
                      shouldProceed = false;
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Check-out and leave'),
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
                              'You are offline. Your check-out will sync when online.',
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
                        log('Error during check-out: $e');
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

  @override
  Widget build(BuildContext context) {
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
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () async {
                log("Customer Id backbutton : ${widget.cusId}");
                log("${widget.isDirectDialogue} +${widget.isFromCalendar} + ${widget.isFromGoogle}");

                if (widget.isFromGoogle) {
                  bool shouldProceed = await checkCustomerOut();
                  if (shouldProceed) {
                    homeController.sidebarXController.selectIndex(5);
                    homeController.selectedIndex.value = 5;
                  }
                } else if (widget.isDirectDialogue) {
                  bool shouldProceed = await checkCustomerOut();
                  if (shouldProceed) {
                    homeController.sidebarXController.selectIndex(5);
                    homeController.selectedIndex.value = 5;
                    customerOrderController.isActive.value = false;
                    Get.toNamed(AppRoutes.calender, id: 2);
                  }
                } else {
                  bool shouldProceed = await checkCustomerOut();
                  if (shouldProceed) {
                    customerOrderController.isActive.value = false;
                    Navigator.pop(context);
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffdcdefc),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (subscriptionController.orderTakingFromDashboard.value !=
                    "true") {
                  showUpgradePlanDialog(context);
                }
                if (subscriptionController.orderTakingFromDashboard.value ==
                    "true") {
                  _navigateToOrderTaking();
                }
                CartDatabaseManager()
                    .getCartItems(productsController.selectedCustomerId.value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text(
                'Order Taking',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
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
                      const SizedBox(
                        width: 4.5,
                      ),
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
                            const MyRegularText(label: "Customer", fontSize: 9),
                          ],
                        ),
                      ),
                    ],
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
                }
                // comeback
                else if (snapshot.hasError) {
                  // return Center(child: Text('Error 1: ${snapshot.error}'));

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showCustomToastDisplay(
                      context,
                      snapshot.error.toString(),
                      Colors.red,
                      Icons.close,
                    );
                  });

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
                                            subscriptionController),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
                                        child: TotalSalse(context),
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
                                                subscriptionController),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.7),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TotalSalse(context),
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
                  // return Center(child: Text('Error 1: ${snapshot.error}'));

                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   showCustomToastDisplay(
                  //     context,
                  //     snapshot.error.toString(),
                  //     Colors.red,
                  //     Icons.close,
                  //   );
                  // });
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
                                            subscriptionController),
                                      ),
                                      const SizedBox(height: 4.7),
                                      SizedBox(
                                        height: screenWidth * 0.7,
                                        child: TotalSalse(context),
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
                                                subscriptionController),
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
                    dashboardContainerHeader('Category Sales'),
                    const SizedBox(width: 14),
                    Container(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? ResponsiveInfo.isMobileDimension(context)
                              ? 20
                              : 26
                          : ResponsiveInfo.isMobileDimension(context)
                              ? 17
                              : 22,
                      padding: const EdgeInsets.only(left: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xffeef2f7),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: DropdownButton<int>(
                        iconSize: 12,
                        value: selectedYear,
                        underline: Container(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                            // Fetch data for the selected year
                            Provider.of<CustomersProvider>(context,
                                    listen: false)
                                .fetchCustomerDashboardData(
                              widget.cusId,
                            );
                            Provider.of<CustomersProvider>(context,
                                    listen: false)
                                .fetchCustomerDashboardRevenueData(
                                    widget.cusId);
                          });
                        },
                        items: provider.yearList
                            .map((item) => DropdownMenuItem<int>(
                                  value: item.year,
                                  child: Text(
                                    item.year.toString(),
                                    style: cardHeadingTextStyle,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                          right: fullScreenWidth(context) > 630 ? 20 : 2,
                          top: 2),
                      child: InkWell(
                        onTap: () {
                          showCustomerCategoryChartDialog(
                            context,
                            "Category Sales",
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
      child: Consumer<CustomersProvider>(builder: (context, provider, child) {
        return FutureBuilder<CustomerTotalSaleResponse>(
            future: provider.customerTotalSaleResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return MyCommnonContainer(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 211, 211, 211)
                          .withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(4, 4),
                    ),
                  ],
                  borderRadius: 25,
                  height: 320,
                  width: double.infinity,
                  isCommonBorder: true,
                  child: Column(
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
                                          'Revenue',
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
                                          'Customer Offer',
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
                          Positioned(
                            top: fullScreenWidth(context) > 680 ? 2 : 32,
                            right: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                height: 26,
                                padding: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xffeef2f7),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: DropdownButton<int>(
                                  iconSize: 18,
                                  value: selectedYear,
                                  underline: Container(),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      selectedYear = newValue!;
                                      Provider.of<CustomersProvider>(context,
                                              listen: false)
                                          .fetchCustomerDashboardDataSalseData(
                                        widget.cusId,
                                      );
                                    });
                                  },
                                  items: provider.yearList
                                      .map((item) => DropdownMenuItem<int>(
                                            value: item.year,
                                            child: Text(
                                              item.year.toString(),
                                              style: cardHeadingTextStyle,
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: fullScreenWidth(context) > 680 ? 0 : 30,
                      ),
                      Expanded(
                        child: _tabIndex == 0
                            ? TotalSalse(context)
                            : TotalSalseCustomers(context),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: NodataWidget());
              }
            });
      }),
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MMMM-yyyy').format(dateTime);
  }
}
