import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/common/custom_fonts.dart' as font1;
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/show_product_list_dialog.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/routes/routes.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/category_line_chart.dart';
import 'package:busskit_salesexecutive/ui/components/bar_and_chart/revenue_pie_chart.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/select_customer_diloag/custmerlist_and_map.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/csord_model/customers_orders_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/custom_toast.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/customer_dash_chart.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/editabledatacell_new.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/custom_toast.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/message/customer_category_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/message/customer_revenue_chart_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/order_payment_enlarge_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_collection_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/dash_frequently_table.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_rev_value_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/show_times_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../api_handler/api_worker.dart';
import '../../../../utills/extentions/string_extention.dart';

class CustomerDachScreen extends StatefulWidget {
  final dynamic year;
  final dynamic startDate;
  final dynamic endDate;
  final String? cusName;
  final String? cusId;
  final String? cusImage;
  final bool isFromCalendar;
  final bool isDirectDialogue;
  final bool isFromOrder;
  final bool isFromGoogle;
  final ProductsController? productsController;

  CustomerDachScreen({
    super.key,
    this.year,
    this.startDate,
    this.endDate,
    this.cusId,
    this.cusName,
    this.cusImage,
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
  int selectedYear = 2025;
  late TabController _tabController;
  HomeController homeController = Get.put(HomeController());
  CustomerAndOrderController customerOrderController =
      Get.put(CustomerAndOrderController());
  ApiWorker apiWorker = Get.put(ApiWorker());
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    log('Is Calender :${widget.isFromCalendar}');
    log('Calender Calender Customer ID :${widget.cusId}');
    //_initializeCustomerData();
    //_refreshScreen();
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
      final customerId = widget.productsController?.selectedCustomerId.value;
     customerOrderController
                    .setCustomerId(customerOrderController.customerId.value);
    cartProvider.updateCartCount(customerOrderController.customerId.value);
                log('Customer Id :${customerOrderController.customerId.value}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTaking(
                      productsController:
                          widget.productsController ?? ProductsController(),
                      isFromCalender: widget.isFromCalendar,
                      isDirectDialogue: widget.isDirectDialogue,
                      isFromOrder: widget.isFromOrder,
                    ),
                  ),
                ).then((value) {
                 cartProvider.fetchCustomerDashboardCountData(customerId??'');
                 
                });
  }

  // void _refreshScreen() {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     bool isConnected = await ConnectivityService().isOnline();
  //     if (isConnected) {
  //       await _initializeCustomerData();
  //       final customerId = widget.productsController?.selectedCustomerId.value;
  //       if (customerId != null && customerId.isNotEmpty) {
  //         final customersProvider =
  //             Provider.of<CustomersProvider>(context, listen: false);
  //         customersProvider.fetchCustomerDashboardData(
  //           customerId,
  //           selectedYear,
  //           widget.startDate,
  //           widget.endDate,
  //         );
  //         customersProvider.fetchCustomerDashboardRevenueData(
  //           customerId,
  //           selectedYear,
  //           widget.startDate,
  //           widget.endDate,
  //         );
  //         customersProvider.fetchCustomerDashboardDataSalseData(
  //           customerId,
  //           selectedYear,
  //         );
  //         customersProvider.fetchCustomersDataDash(customerId);
  //         customersProvider.fetchCustomerDashboardCountData(customerId);
  //       }
  //     } else {
  //       showNoInternetSnackBar(context);
  //     }
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.isFromCalendar
        ? widget.cusName ?? ''
        : widget.productsController?.selectedCustomerName.value;
    final customerImage = widget.isFromCalendar
        ? widget.cusImage ?? ''
        : widget.productsController?.selectedCustomerImageUrl.value;
    String? startDate;
    String? endDate;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return nkMediumSizeBox(
      height: isMobile
          ? AppDimensions.instance.height * 3
          : AppDimensions.instance.height * 0.98,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () {
                log('Is Direct ${widget.isDirectDialogue}');
                log('Is Calender ${widget.isFromCalendar}');
                if (widget.isFromCalendar) {
                  homeController.sidebarXController.selectIndex(6);
                  homeController.selectedIndex.value = 6;
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CustomerMapScreen(
                        istoGoogleMap: widget.isFromGoogle,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                } else if (widget.isDirectDialogue) {
                  homeController.sidebarXController.selectIndex(6);
                  homeController.selectedIndex.value = 6;
                  Get.toNamed(AppRoutes.calender, id: 2);
                } else {
                  Navigator.pop(context);
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
               _navigateToOrderTaking();
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
              child: Container(
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
                              'http://16.50.232.153:3000/uploads/${customerImage}',
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
                              constraints:
                                  BoxConstraints(maxWidth: double.infinity),
                              child: MyRegularText(
                                label: customerName ?? '',
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

            //UpdateCustomer(widget: widget),
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
                  log("Snapshot error : ${snapshot.error}");
                  return Center(child: NodataWidget());
                } else {
                  final responseModel = snapshot.data;
                  final frequentProductLists =
                      responseModel?.data.frequentProductLists;
                  final recentOrders = responseModel?.data.recentOrders;
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        OptionWidgetCustomerDash(
                          customerId: widget.cusId ?? '',
                          customType: "",
                          customOrderStatusType: OrderStatus.newOrder,
                          userType: UserType.customer,
                          userId: "",
                          startDate: startDate,
                          endDate: endDate,
                          productsController:widget.productsController,
                          onContinueShopping: _navigateToOrderTaking,
                        ),
                        const SizedBox(height: 5.7),
                        Expanded(
                          child: SingleChildScrollView(
                            child: screenWidth < 600
                                ? Column(
                                    children: [
                                      Expanded(
                                        child: Category(context),
                                      ),
                                      const SizedBox(height: 2),
                                      Expanded(
                                        child: OrdersPayments(
                                            context, recentOrders??[]),
                                      ),
                                      const SizedBox(height: 2),
                                      Expanded(
                                        child: TotalSalse(context),
                                      ),
                                      const SizedBox(height: 2),
                                      Expanded(
                                        child: Frequently(
                                            context, frequentProductLists??[]),
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
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: OrdersPayments(
                                                context, recentOrders??[]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TabTab(context),
                                          ),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Frequently(
                                                context, frequentProductLists??[]),
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
                                    widget.cusId ?? '',
                                    selectedYear,
                                    widget.startDate,
                                    widget.endDate);
                            Provider.of<CustomersProvider>(context,
                                    listen: false)
                                .fetchCustomerDashboardRevenueData(
                                    widget.cusId ?? '',
                                    selectedYear,
                                    widget.startDate,
                                    widget.endDate);
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
                      padding: const EdgeInsets.only(right: 20, top: 2),
                      child: InkWell(
                        onTap: () {
                          showCustomerCategoryChartDialog(
                            context,
                            "Category Sales",
                            widget.cusId ?? '',
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
                              return const Center(
                                  child: Text('No data available'));
                            } else {
                              final responseModel = snapshot.data!;
                              final categoryPerformance =
                                  snapshot.data!.data.categoryPerformance;

                              return Center(
                                child: CustomBarChartCustomerDash(
                                  categoryPerformance: categoryPerformance,
                                  allCategory: responseModel.data.fullCategory,
                                  customerId: widget.cusId ?? '',
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

  // Expanded Category(BuildContext context) {
  //   return Expanded(
  //       child: Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: MyCommnonContainer(
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
  //           blurRadius: 5,
  //           offset: Offset(4, 4),
  //         ),
  //       ],
  //       borderRadius: 25,
  //       height: 300,
  //       width: double.infinity,
  //       isCommonBorder: true,
  //       child: Consumer<CustomersProvider>(builder: (context, provider, child) {
  //         return Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: [
  //                   InkWell(
  //                     onTap: () {
  //                       Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (_) => DashboardScreen(
  //                                     cus: widget.productsController
  //                                             ?.selectedCategoryId.value ??
  //                                         '',
  //                                     y: '2024',
  //                                   )));
  //                     },
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: primaryColor.withOpacity(0.2),
  //                         borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(25),
  //                           bottomRight: Radius.circular(25),
  //                         ),
  //                       ),
  //                       padding: const EdgeInsets.only(
  //                           right: 20, left: 20, top: 5, bottom: 5),
  //                       child: Text(
  //                         'Category Sales',
  //                         style: cardHeadingTextStyle,
  //                         maxLines: 1,
  //                         softWrap: false,
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 14),
  //                   Container(
  //                     height: MediaQuery.of(context).orientation ==
  //                             Orientation.portrait
  //                         ? ResponsiveInfo.isMobileDimension(context)
  //                             ? 20
  //                             : 26
  //                         : ResponsiveInfo.isMobileDimension(context)
  //                             ? 17
  //                             : 22,
  //                     padding: const EdgeInsets.only(left: 6),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xffeef2f7),
  //                       borderRadius: BorderRadius.circular(4.0),
  //                     ),
  //                     child: DropdownButton<int>(
  //                       iconSize: 12,
  //                       value: selectedYear,
  //                       underline: Container(),
  //                       onChanged: (int? newValue) {
  //                         setState(() {
  //                           selectedYear = newValue!;
  //                           Provider.of<CustomersProvider>(context,
  //                                   listen: false)
  //                               .fetchCustomerDashboardData(
  //                                   widget.productsController
  //                                           ?.selectedCategoryId.value ??
  //                                       '',
  //                                   selectedYear,
  //                                   widget.startDate,
  //                                   widget.endDate);
  //                           Provider.of<CustomersProvider>(context,
  //                                   listen: false)
  //                               .fetchCustomerDashboardRevenueData(
  //                                   widget.productsController
  //                                           ?.selectedCategoryId.value ??
  //                                       '',
  //                                   selectedYear,
  //                                   widget.startDate,
  //                                   widget.endDate);
  //                         });
  //                       },
  //                       items: provider.yearList
  //                           .map((item) => DropdownMenuItem<int>(
  //                                 value: item.year,
  //                                 child: Text(
  //                                   item.year.toString(),
  //                                   style: cardHeadingTextStyle,
  //                                 ),
  //                               ))
  //                           .toList(),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               nkSmallSizeBox(),
  //               Expanded(
  //                 child: Scrollbar(
  //                   child: Consumer<CustomersProvider>(
  //                     builder: (context, provider, child) {
  //                       return FutureBuilder<ApiResponseModel>(
  //                         future: provider.customersDashFuture,
  //                         builder: (context, snapshot) {
  //                           if (snapshot.connectionState ==
  //                               ConnectionState.waiting) {
  //                             return const Center(
  //                                 child: CircularProgressIndicator());
  //                           } else if (snapshot.hasError) {
  //                             return Center(
  //                                 child: Text('Error: ${snapshot.error}'));
  //                           } else if (!snapshot.hasData) {
  //                             return const NodataWidget();
  //                           } else {
  //                             final responseModel = snapshot.data!;
  //                             final categoryPerformance =
  //                                 snapshot.data!.data.categoryPerformance;
  //                             // Map categoryPerformance to a list of cids

  //                             return Center(
  //                               child: CustomBarChartCustomerDash(
  //                                 categoryPerformance: categoryPerformance,
  //                                 allCategory: responseModel.data.fullCategory,
  //                                 customerId: widget.productsController
  //                                         ?.selectedCategoryId.value ??
  //                                     '',
  //                                 year: selectedYear,
  //                               ),
  //                             );
  //                           }
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ]);
  //       }),
  //     ),
  //   ));
  // }

  // ignore: non_constant_identifier_names
  // Expanded OrdersPayments(
  //     BuildContext context, List<RecentOrder> recentOrders) {
  //   return Expanded(
  //     child: MyCommnonContainer(
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
  //           blurRadius: 5,
  //           offset: Offset(4, 4),
  //         ),
  //       ],
  //       borderRadius: 25,
  //       height: 300,
  //       isCommonBorder: true,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: [
  //                   Container(
  //                     decoration: BoxDecoration(
  //                       color: primaryColor.withOpacity(0.2),
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(25),
  //                         bottomRight: Radius.circular(25),
  //                       ),
  //                     ),
  //                     padding: const EdgeInsets.only(
  //                         right: 20, left: 20, top: 5, bottom: 5),
  //                     child: Text(
  //                       'Orders & Payment/s',
  //                       style: cardHeadingTextStyle,
  //                       maxLines: 1,
  //                       softWrap: false,
  //                     ),
  //                   ),
  //                   nkSmallSizeBox(),
  //                   SizedBox(
  //                     height: 25,
  //                     child: ElevatedButton(
  //                       onPressed: () {
  //                         List<RecentOrder> selectedOrders = [];
  //                         for (var order in recentOrders) {
  //                           if (context
  //                               .read<CustomersProvider>()
  //                               .isOrderSelected(order)) {
  //                             selectedOrders.add(order);
  //                           }
  //                         }

  //                         // Show the appropriate dialog or toast based on the selection
  //                         if (selectedOrders.isNotEmpty) {
  //                           paymentCollectionDialog(context, selectedOrders);
  //                         } else {
  //                           showCustomToast(context);
  //                         }
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xff5bc0de),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(4.0),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         'Collection',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(right: 20, top: 2),
  //                 child: InkWell(
  //                   onTap: () {
  //                     showCustomDialog(context, recentOrders);
  //                   },
  //                   child: Container(
  //                       decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(10),
  //                           color: primaryColor.withOpacity(0.3)),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(5.0),
  //                         child: const Icon(
  //                           Icons.open_in_new,
  //                           size: 17,
  //                           color: primaryColor,
  //                         ),
  //                       )),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           nkSmallSizeBox(),
  //           Expanded(
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: LayoutBuilder(
  //                 builder: (context, constraints) {
  //                   double availableWidth = constraints.maxWidth;
  //                   double availableHeight = constraints.maxHeight;
  //                   double fontSize = 11;
  //                   return Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       const Row(
  //                         children: [
  //                           Expanded(
  //                             child: Center(
  //                               child: Text(
  //                                 "Date",
  //                                 style: TextStyle(
  //                                   fontFamily: 'Poppins_Regular',
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Center(
  //                               child: Text(
  //                                 "Invoice",
  //                                 style: TextStyle(
  //                                   fontFamily: 'Poppins_Regular',
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Center(
  //                               child: Text(
  //                                 "Status",
  //                                 style: TextStyle(
  //                                   fontFamily: 'Poppins_Regular',
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Center(
  //                               child: Text(
  //                                 "Amount",
  //                                 style: TextStyle(
  //                                   fontFamily: 'Poppins_Regular',
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Center(
  //                               child: Text(
  //                                 "Due By",
  //                                 style: TextStyle(
  //                                   fontFamily: 'Poppins_Regular',
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 11,
  //                                 ),
  //                                 maxLines: 1,
  //                               ),
  //                             ),
  //                           ),
  //                           Expanded(
  //                             child: Center(
  //                               child: Text(
  //                                 "Select",
  //                                 style: TextStyle(
  //                                   fontFamily: 'Poppins_Regular',
  //                                   fontWeight: FontWeight.w600,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       Padding(
  //                         padding: const EdgeInsets.only(top: 8.0, bottom: 0),
  //                         child: Container(
  //                           height: 1,
  //                           color: Colors.grey.shade100,
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SingleChildScrollView(
  //                           scrollDirection: Axis.vertical,
  //                           child: Column(
  //                             children: recentOrders.map((order) {
  //                               return Padding(
  //                                 padding:
  //                                     const EdgeInsets.symmetric(vertical: 0.0),
  //                                 child: Row(
  //                                   children: [
  //                                     Expanded(
  //                                       child: Center(
  //                                         child: Text(
  //                                           getFormattedOrderCreatAt(
  //                                               order.orderCreatAt),
  //                                           style: TextStyle(
  //                                             fontSize: fontSize,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     Expanded(
  //                                       child: Center(
  //                                         child: Text(
  //                                           order.orderId,
  //                                           style: TextStyle(
  //                                             fontSize: fontSize,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     Expanded(
  //                                       child: Center(
  //                                         child: Container(
  //                                           decoration: const BoxDecoration(
  //                                             color: Color(0xff008000),
  //                                             borderRadius: BorderRadius.all(
  //                                                 Radius.circular(4.0)),
  //                                           ),
  //                                           child: Padding(
  //                                             padding: EdgeInsets.symmetric(
  //                                               horizontal: availableWidth / 80,
  //                                               vertical: availableHeight / 100,
  //                                             ),
  //                                             child: Text(
  //                                               getStatusName(
  //                                                   order.orderStatus),
  //                                               maxLines: 1,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               style: TextStyle(
  //                                                 color: Colors.white,
  //                                                 fontSize: fontSize,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     Expanded(
  //                                       child: Center(
  //                                         child: Text(
  //                                           formatAmount(order.orderTotal),
  //                                           maxLines: 1,
  //                                           style: TextStyle(
  //                                             fontSize: fontSize,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     Expanded(
  //                                       child: Center(
  //                                         child: Text(
  //                                           getFormattedOrderCreatAt(
  //                                               order.orderCreatAt),
  //                                           style: TextStyle(
  //                                             fontSize: fontSize,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                     Expanded(
  //                                       child: Center(
  //                                         child: Consumer<CustomersProvider>(
  //                                           builder:
  //                                               (context, provider, child) {
  //                                             return Checkbox(
  //                                               value: provider
  //                                                   .isOrderSelected(order),
  //                                               onChanged: (bool? isSelected) {
  //                                                 provider.toggleOrderSelection(
  //                                                     order);
  //                                               },
  //                                             );
  //                                           },
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               );
  //                             }).toList(),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Expanded OrdersPayments(
      BuildContext context, List<RecentOrder> recentOrders) {
    return Expanded(
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
        isCommonBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, top: 5, bottom: 5),
                      child: Text(
                        'Orders & Payment/s',
                        style: cardHeadingTextStyle,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                    nkSmallSizeBox(),
                    SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        onPressed: () {
                          List<RecentOrder> selectedOrders = [];
                          for (var order in recentOrders) {
                            if (context
                                .read<CustomersProvider>()
                                .isOrderSelected(order)) {
                              selectedOrders.add(order);
                            }
                          }
                          // Show the appropriate dialog or toast based on the selection
                          if (selectedOrders.isNotEmpty) {
                            paymentCollectionDialog(context, selectedOrders);
                          } else {
                            showCustomToast(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5bc0de),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          'Collection',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 2),
                  child: InkWell(
                    onTap: () {
                      showCustomDialog(context, recentOrders);
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primaryColor.withOpacity(0.3)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(
                            Icons.open_in_new,
                            size: 17,
                            color: primaryColor,
                          ),
                        )),
                  ),
                ),
              ],
            ),
            nkSmallSizeBox(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double availableWidth = constraints.maxWidth;
                    double availableHeight = constraints.maxHeight;
                    double fontSize = 11;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Date",
                                  style: TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Invoice",
                                  style: TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Status",
                                  style: TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Amount",
                                  style: TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Due By",
                                  style: TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Select",
                                  style: TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 0),
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: recentOrders.map((order) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            getFormattedOrderCreatAt(
                                                order.orderCreatAt),
                                            style: TextStyle(
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            order.orderId,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xff008000),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: availableWidth / 80,
                                                vertical: availableHeight / 100,
                                              ),
                                              child: Text(
                                                getStatusName(
                                                    order.orderStatus),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: fontSize,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            formatAmount(order.orderTotal),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            // getFormattedOrderCreatAt(
                                            //     order.duedate?.first ?? ''),
                                            order.duedate!.isNotEmpty
                                                ? order.duedate?.first ?? ''
                                                : '',
                                            // order.duedate?.first ?? '',
                                            style: TextStyle(
                                              color: order.duedate!.isEmpty
                                                  ? Colors.grey
                                                  : order.duedate?[1] >= 3
                                                      ? Colors.green
                                                      : order.duedate?[1] <=
                                                                  3 &&
                                                              order.duedate?[
                                                                      1] >=
                                                                  1
                                                          ? Colors.amber
                                                          : Colors.red,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Consumer<CustomersProvider>(
                                            builder:
                                                (context, provider, child) {
                                              return Checkbox(
                                                value: provider
                                                    .isOrderSelected(order),
                                                onChanged: (bool? isSelected) {
                                                  provider.toggleOrderSelection(
                                                      order);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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

  Widget TotalSalseCustomers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Consumer<CustomersProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<CustomerTotalSaleResponse>(
            future: provider.customerTotalSaleResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final categoryPerformance = snapshot.data!;
                final discountDataList = categoryPerformance.data.discountData;

                final paymentCompleted = categoryPerformance
                    .data.totalSale.paymentCompleted.totalAmount;

                final remaCompleted = categoryPerformance
                    .data.totalSale.paymentRemaining.totalAmount;

                return MyCommnonContainer(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  padding: nkRegularPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final List<Color> textColors = [
                            Colors.red,
                            Colors.orange,
                            Colors.red,
                            Colors.black,
                          ];

                          double availableWidth = constraints.maxWidth;
                          double padding = availableWidth / 50;
                          double fixedIconSize = 13.0;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: availableWidth,
                              ),
                              child: DataTable(
                                headingRowColor:
                                    MaterialStateProperty.all(Colors.grey[100]),
                                dataRowHeight: 40,
                                headingRowHeight: 45,
                                columnSpacing: 10,
                                horizontalMargin: 10,
                                columns: [
                                  DataColumn(
                                    label: Expanded(
                                      child: Center(
                                        child: MyRegularText(
                                          label: "Category",
                                          fontWeight:
                                              NkGeneralSize.nkBoldFontWeight(),
                                          color: primaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Center(
                                        child: MyRegularText(
                                          label: "Order Value",
                                          fontWeight:
                                              NkGeneralSize.nkBoldFontWeight(),
                                          color: primaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Center(
                                        child: MyRegularText(
                                          label: "Discount(%)",
                                          fontWeight:
                                              NkGeneralSize.nkBoldFontWeight(),
                                          color: primaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: discountDataList
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  DiscountData discountData = entry.value;

                                  Color textColor =
                                      textColors[index % textColors.length];
                                  Color rowColor = index % 2 == 0
                                      ? Colors.white
                                      : Colors.grey[100]!;

                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                        Color>(
                                      (Set<MaterialState> states) {
                                        return rowColor;
                                      },
                                    ),
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: MyRegularText(
                                            label: discountData.category,
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: MyRegularText(
                                            label: discountData.value,
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: MyRegularText(
                                            label: discountData.discount,
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return const NodataWidget();
              }
            },
          );
        },
      ),
    );
  }

  Expanded TabTab(BuildContext context) {
    return Expanded(
      child: Consumer<CustomersProvider>(builder: (context, provider, child) {
        return FutureBuilder<CustomerTotalSaleResponse>(
            future: provider.customerTotalSaleResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final categoryPerformance = snapshot.data!;
                final discountDataList = categoryPerformance.data.discountData;
                final paymentCompleted = categoryPerformance
                    .data.totalSale.paymentCompleted.totalAmount;
                final remaCompleted = categoryPerformance
                    .data.totalSale.paymentRemaining.totalAmount;

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: MyCommnonContainer(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 211, 211, 211)
                            .withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(4, 4),
                      ),
                    ],
                    borderRadius: 25,
                    height: 320,
                    width: double.infinity,
                    isCommonBorder: true,
                    padding: nkRegularPadding(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 240,
                              height: 27,
                              child: TabBar(
                                controller: _tabController,
                                indicatorColor: primaryColor,
                                labelColor: primaryColor,
                                unselectedLabelColor: Colors.black,
                                tabs: const [
                                  Tab(
                                    child: Text(
                                      'Revenue',
                                      style: tabTextStyle,
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      'Customer Offer',
                                      style: tabTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
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
                                            widget
                                                    .productsController
                                                    ?.selectedCategoryId
                                                    .value ??
                                                '',
                                            selectedYear);
                                  });
                                },
                                items: provider.yearList
                                    .map((item) => DropdownMenuItem<int>(
                                          value: item.year,
                                          child: Text(
                                            item.year.toString(),
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              TotalSalse(context),
                              TotalSalseCustomers(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const NodataWidget();
              }
            });
      }),
    );
  }

  Widget TotalSalse(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<CustomersProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<CustomerRevenueResponse>(
            future: provider.customerRevenueResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final categoryPerformance = snapshot.data!;

                final paymentCompleted = categoryPerformance
                            .data.revenue.bookingRevenueData?.isNotEmpty ==
                        true
                    ? categoryPerformance.data.revenue.bookingRevenueData!.last
                        .totalBookingRevenue
                    : 0;

                final remaCompleted = categoryPerformance
                            .data.revenue.orderRevenueData?.isNotEmpty ==
                        true
                    ? categoryPerformance
                        .data.revenue.orderRevenueData!.last.totalOrderRevenue
                    : 0;

                return MyCommnonContainer(
                  height: double.infinity,
                  width: double.infinity,
                  isCommonBorder: false,
                  padding: nkRegularPadding(),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Expanded(
                            child: Center(
                              child: DoughnutDefaultCustomerDash(
                                customerData: categoryPerformance,
                                booking: "Booking : 3",
                                order: "Order : 3",
                                aColor: Colors.blue.shade900,
                                bColor: Colors.blue,
                                legend1: const SizedBox.shrink(),
                                legend2: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (categoryPerformance.data.revenue
                                            .bookingRevenueData!.isNotEmpty) {
                                          showValueDialogCusDash(
                                              context,
                                              categoryPerformance.data.revenue
                                                      .bookingRevenueData
                                                  as List<dynamic>,
                                              'Booking');
                                        }
                                      },
                                      child: _buildLegendItem(
                                        Colors.blue.shade900,
                                        'Booking : ${formatAmount(paymentCompleted)}',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        if (categoryPerformance.data.revenue
                                            .orderRevenueData!.isNotEmpty) {
                                          showValueDialogCusDash(
                                              context,
                                              categoryPerformance.data.revenue
                                                      .orderRevenueData
                                                  as List<dynamic>,
                                              'Order');
                                        }
                                      },
                                      child: _buildLegendItem(
                                        Colors.blue,
                                        'Order : ${formatAmount(remaCompleted)}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: -10,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, top: 2),
                          child: InkWell(
                            onTap: () {
                              showCustomerRevenueChartDialog(
                                context,
                                "Revenue",
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
                      )
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 5),
        MyRegularText(
          label: label,
          fontSize: 11.6,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
 Widget Frequently(
      BuildContext context, List<FrequantliyProductList> frequentProductLists) {
    // frequentProductLists.sort((a, b) => b.quantity.compareTo(a.quantity));
    frequentProductLists
        .sort((a, b) => b.count.length.compareTo(a.count.length));

    return MyCommnonContainer(
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 211, 211, 211).withOpacity(0.2),
          blurRadius: 5,
          offset: const Offset(4, 4),
        ),
      ],
      borderRadius: 25,
      height: 320,
      isCommonBorder: true,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dashboardContainerHeader("Frequently Bought Products"),
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 2),
                child: InkWell(
                  onTap: () {
                    if (frequentProductLists.isNotEmpty) {
                      return showProductListDialog<FrequantliyProductList>(
                        context: context,
                        productList: frequentProductLists,
                        getQuantity: (product) =>
                            product.count.length.toDouble(),
                        getProductName: (product) => product.productName,
                        getVariationName: (product) => product.variationName,
                        getFormattedDate: (product) =>
                            DateFormat('dd-MM-yyyy').format(product.createdAt),
                        getPrice: (product) => formatAmount(product.totalPrice),
                        getBuyQuantity: (product) => product.quantity,
                        getInNo: (product) => product.inNo,
                        onQuantityTap: (context, product) =>
                            showDashTimesDialogue(
                          context,
                          product,
                          (p) => p.count,
                          (data) => data.businessName,
                          (data) => formatAmount(data.price),
                          (data) => formatAmount(data.tax),
                          (data) => data.quantity.toString(),
                          (data) => formatAmount(
                            data.inclTax == "incl_tax"
                                ? ((double.tryParse(
                                            data.totalPrice.toString()) ??
                                        0)
                                    //     *
                                    // (double.tryParse(
                                    //         data.quantity.toString()) ??
                                    //     0)
                                    )
                                : (((double.tryParse(
                                                data.totalPrice.toString()) ??
                                            0) *
                                        (double.tryParse(
                                                data.quantity.toString()) ??
                                            0)) +
                                    (double.tryParse(data.tax.toString()) ??
                                        0.0)),
                          ),
                          (data) =>
                              DateFormat('dd-MM-yyyy').format(data.createdAt!),
                          (data) => data.orderId.toString(),
                          false,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No data available"),
                        ),
                      );
                    }
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
                      )),
                ),
              ),
            ],
          ),
          nkSmallSizeBox(),
          Expanded(child: topSellingProductsCustomer(frequentProductLists)),
        ],
      ),
    );
  }

  Widget topSellingProductsCustomer(
      List<FrequantliyProductList> frequentProductLists) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double flexWidth = availableWidth * 1.4;

        double colWidth0 = flexWidth * 1 / 12;
        double colWidth1 = flexWidth * 2.8 / 12;
        double colWidth2_2 = flexWidth * 1.2 / 12;
        double colWidth2 = flexWidth * 2 / 12;
        double colWidth3 = flexWidth * 1 / 12;
        double colWidth4 = flexWidth * 2.1 / 12;
        double colWidth5 = flexWidth * 1 / 12;

        double fontSize = 11;

        if (frequentProductLists.isEmpty) {
          return const NodataWidget();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: flexWidth + 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed Header
                  Container(
                    height: 35,
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        SizedBox(
                          width: colWidth0,
                          child: const Center(
                            child: MyRegularText(
                              label: "Sl.No.",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: colWidth1,
                          child: const Center(
                            child: MyRegularText(
                              label: "Product",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: colWidth2_2,
                          child: const Center(
                            child: MyRegularText(
                              label: "I/N",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: colWidth2,
                          child: const Center(
                            child: MyRegularText(
                              label: "Last Purchase",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: colWidth3,
                          child: const Center(
                            child: MyRegularText(
                              label: "Times",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: colWidth4,
                          child: const Center(
                            child: MyRegularText(
                              label: "Amount",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: colWidth5,
                          child: const Center(
                            child: MyRegularText(
                              label: "Qty",
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                              align: TextAlign.center,
                              fontSize: 11.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children:
                            frequentProductLists.asMap().entries.map((entry) {
                          int index = entry.key;
                          var product = entry.value;

                          return SizedBox(
                            height: 35,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: colWidth0,
                                  child: MyRegularText(
                                    label: "${index + 1}.",
                                    fontSize: fontSize,
                                    maxlines: 1,
                                    align: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: colWidth1,
                                  child: MyRegularText(
                                    label:
                                        '${product.productName} - ${product.variationName}',
                                    fontSize: fontSize,
                                    maxlines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: colWidth2_2,
                                  child: Center(
                                    child: MyRegularText(
                                      label: product.inNo.toString(),
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: colWidth2,
                                  child: Center(
                                    child: MyRegularText(
                                      label: DateFormat('dd-MM-yyyy')
                                          .format(product.createdAt.toLocal()),
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: colWidth3,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        showDashTimesDialogue(
                                          context,
                                          product,
                                          (p) => p.count,
                                          (data) => data.businessName,
                                          (data) => formatAmount(data.price),
                                          (data) => formatAmount(data.tax),
                                          (data) => data.quantity.toString(),
                                          (data) => formatAmount(
                                            data.inclTax == "incl_tax"
                                                ? ((double.tryParse(data
                                                            .totalPrice
                                                            .toString()) ??
                                                        0)
                                                    //     *
                                                    // (double.tryParse(data.quantity.toString()) ??
                                                    //     0)
                                                    )
                                                : (((double.tryParse(data
                                                                .totalPrice
                                                                .toString()) ??
                                                            0) *
                                                        (double.tryParse(data
                                                                .quantity
                                                                .toString()) ??
                                                            0)) +
                                                    (double.tryParse(data.tax
                                                            .toString()) ??
                                                        0.0)),
                                          ),
                                          (data) => DateFormat('dd-MM-yyyy')
                                              .format(data.createdAt!),
                                          (data) => data.orderId.toString(),
                                          false,
                                        );
                                      },
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: MyRegularText(
                                            label:
                                                product.count.length.toString(),
                                            color: buttonTextColor,
                                            align: TextAlign.center,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: colWidth4,
                                  child: Center(
                                    child: MyRegularText(
                                      label: formatAmount(product.totalPrice),
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
                                      maxlines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: colWidth5,
                                  child: Center(
                                    child: MyRegularText(
                                      label: product.quantity.toString(),
                                      color: secondaryTextColor,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MMMM-yyyy').format(dateTime);
  }
}

class UpdateCustomer extends StatelessWidget {
  UpdateCustomer({
    super.key,
    required this.widget,
  });

  final CustomerDachScreen widget;
  ProductsController productsController = Get.put(ProductsController());
  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(builder: (context, provider, child) {
      return FutureBuilder<CustomerResponse>(
          future: provider.customerResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const NodataWidget();
            } else {
              final customer = snapshot.data?.data.first;
              TextEditingController nameController =
                  TextEditingController(text: customer!.fullname);
              TextEditingController phoneController =
                  TextEditingController(text: customer.mobileno);
              TextEditingController emailController =
                  TextEditingController(text: customer.email);
              TextEditingController townController =
                  TextEditingController(text: customer.town);
              TextEditingController stateController =
                  TextEditingController(text: customer.state);
              TextEditingController zipcodeController =
                  TextEditingController(text: customer.zipcode.toString());
              TextEditingController addressController =
                  TextEditingController(text: customer.address);

              TextEditingController bsNameController =
                  TextEditingController(text: customer.businessName);
              TextEditingController bsNumController =
                  TextEditingController(text: customer.businessNo);

              TextEditingController remarkController =
                  TextEditingController(text: customer.remark);

              return InkWell(
                onTap: () {
                  provider.fetchCustomersDataDash(
                      productsController.selectedCategoryId.value);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Dialog(
                              insetPadding: EdgeInsets.zero,
                              backgroundColor:
                                  Colors.grey[200], // Grey background color
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                side: BorderSide.none, // Remove outline
                              ),
                              elevation: 24.0, // Shadow elevation
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4.8),
                                    decoration: const BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Update Customer',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.5,
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          child: SizedBox(
                                            width: 25.8,
                                            height: 25.8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.5),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 16,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  // First row - Full Name
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 16.0,
                                          ),
                                          labelText: 'Full Name',
                                          prefixIcon: Icon(Icons.person),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Second row - Mobile Number and Email
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: phoneController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Mobile Number',
                                                prefixIcon: Icon(Icons.phone),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: emailController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Email',
                                                prefixIcon: Icon(Icons.email),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Third row - State and Zip Code
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: townController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Town',
                                                prefixIcon:
                                                    Icon(Icons.location_city),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: stateController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'State',
                                                prefixIcon:
                                                    Icon(Icons.location_city),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: zipcodeController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Zip Code',
                                                prefixIcon: Icon(Icons.map),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Fourth row - Address
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: TextField(
                                        controller: addressController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 16.0,
                                          ),
                                          labelText: 'Address',
                                          prefixIcon: Icon(Icons.home),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Second row - Mobile Number and Email
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: bsNameController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Busniness Name',
                                                prefixIcon: Icon(Icons.phone),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextField(
                                              controller: bsNumController,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 16.0,
                                                ),
                                                labelText: 'Business Contact',
                                                prefixIcon:
                                                    Icon(Icons.phone_callback),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Fifth row - Image Picker
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                          remarkController,
                                                      decoration:
                                                          const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12.0,
                                                          vertical: 16.0,
                                                        ),
                                                        labelText: 'Remark',
                                                        prefixIcon:
                                                            Icon(Icons.phone),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: GestureDetector(
                                                onTap: provider.pickImage,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 16.0,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            const Icon(
                                                                Icons.image,
                                                                color: Colors
                                                                    .grey),
                                                            const SizedBox(
                                                                height: 12.0),
                                                            Text(
                                                              provider.imageFile ==
                                                                      null
                                                                  ? 'Pick an image from gallery'
                                                                  : 'Image selected',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      700]),
                                                            ),
                                                          ],
                                                        ),
                                                        // Spacer(),
                                                        // InkWell(
                                                        //   onTap: provider
                                                        //       .pickImage,
                                                        //   child: Padding(
                                                        //     padding:
                                                        //         const EdgeInsets
                                                        //             .all(8.0),
                                                        //     child: Container(
                                                        //       height:
                                                        //           100.0, // Adjust height as needed
                                                        //       width:
                                                        //           120.0, // Adjust width as needed
                                                        //       decoration:
                                                        //           BoxDecoration(
                                                        //         borderRadius:
                                                        //             BorderRadius
                                                        //                 .circular(
                                                        //                     8.0),
                                                        //         border: Border.all(
                                                        //             color: Colors
                                                        //                 .grey),
                                                        //       ),
                                                        //       child:
                                                        //           Image.network(
                                                        //         'http://16.50.232.153:3000/uploads/${admin.imagePath}',
                                                        //         loadingBuilder:
                                                        //             (context,
                                                        //                 child,
                                                        //                 loadingProgress) {
                                                        //           if (loadingProgress ==
                                                        //               null)
                                                        //             return child;
                                                        //           return Center(
                                                        //             child:
                                                        //                 CircularProgressIndicator(
                                                        //               value: loadingProgress.expectedTotalBytes !=
                                                        //                       null
                                                        //                   ? loadingProgress.cumulativeBytesLoaded /
                                                        //                       loadingProgress.expectedTotalBytes!
                                                        //                   : null,
                                                        //             ),
                                                        //           );
                                                        //         },
                                                        //         errorBuilder: (context,
                                                        //                 error,
                                                        //                 stackTrace) =>
                                                        //             Center(
                                                        //                 child: Text(
                                                        //                     'Failed to load image: $error')),
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12.0),
                                      if (provider.imageFile != null) ...[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 100.0,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: kIsWeb
                                                ? Image.network(
                                                    provider.imageFile!.path,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(provider
                                                        .imageFile!.path),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 16.0),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final updatedAdmin = CustomerDashMo(
                                              customerId: productsController
                                                  .selectedCategoryId.value,
                                              // cartId:
                                              //     widget.cusId, // Provide default or empty values if not applicable
                                              fullname: nameController.text,
                                              mobileno: phoneController.text,
                                              email: emailController.text,
                                              town: townController.text,
                                              state: stateController.text,
                                              zipcode: int.parse(
                                                  zipcodeController.text),
                                              address: addressController.text,
                                              businessName:
                                                  bsNameController.text,
                                              businessNo: bsNumController
                                                  .text, 
                                            );

                                            try {
                                              await provider.updateCustomerDash(
                                                  admin: updatedAdmin,
                                                  cusId: productsController
                                                      .selectedCategoryId
                                                      .value);

                                              print(
                                                  "this is admin data from this mdoel $updatedAdmin");
                                              Navigator.of(context)
                                                  .pop();
                                            } catch (error) {
                                           
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                primaryColor, // Background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4.0), // Border radius
                                            ),
                                          ),
                                          child: const Text(
                                            'Update',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
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
                    },
                  );
                },
                child: SizedBox(
                  width: 110,
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    //  color: const Color(0xffffffff),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Spacer(),
                          CircleAvatar(
                            backgroundColor: const Color(0xffe6ecff),
                            radius: 15,
                            child: productsController
                                        .selectedCustomerImageUrl.value !=
                                    null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        'http://16.50.232.153:3000/uploads/${productsController.selectedCustomerImageUrl.value}',
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons
                                    .person), // Placeholder if imagePath is null
                          ),
                          const SizedBox(
                            width: 4.5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyRegularText(
                                  label: productsController
                                      .selectedCustomerName.value,
                                  fontSize: 8.8),
                              // SizedBox(
                              //   height: 2.5,
                              // ),
                              const MyRegularText(
                                  label: "Customer", fontSize: 9),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          });
    });
  }
}

class DashboardScreen extends StatelessWidget {
  final String cus;
  final dynamic y;

  const DashboardScreen({super.key, required this.cus, this.y});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
      ),
      body: Consumer<CustomersProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<ApiResponseModel>(
            future: provider.customersDashFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const NodataWidget();
              } else {
                final data = snapshot.data!.data;
                return ListView(
                  children: [
                    Text(data.fullCategory.length.toString()),
                    // Display Category Performance
                    _buildCategoryPerformance(data.categoryPerformance),
                    // Display Recent Orders
                    _buildRecentOrders(data.recentOrders),
                    // Display Frequent Product Lists
                    _buildFrequentProductLists(data.frequentProductLists),
                    // Display Year List
                    _buildYearList(data.yearList),
                    // Display Full Category
                    _buildFullCategory(data.fullCategory),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryPerformance(
      List<CategoryPerformancez> categoryPerformance) {
    return ExpansionTile(
      title: const Text('Category Performance'),
      children: categoryPerformance.map((item) {
        return ListTile(
          title: Text(item.category),
          // Display other fields
        );
      }).toList(),
    );
  }

  Widget _buildRecentOrders(List<RecentOrder> recentOrders) {
    return ExpansionTile(
      title: const Text('Recent Orders'),
      children: recentOrders.map((item) {
        return ListTile(
          title: Text(item.customerId),
          // Display other fields
        );
      }).toList(),
    );
  }

  Widget _buildFrequentProductLists(
      List<FrequantliyProductList> frequentProductLists) {
    return ExpansionTile(
      title: const Text('Frequent Product Lists'),
      children: frequentProductLists.map((item) {
        return ListTile(
          title: Column(
            children: [
              Text(item.variationName!),
              const Text("quantityList"),
              Text(item.quantityList.first.quantity.toString()),
              const Text("count"),
              // Text(item.count.first.count.toString()),
              // Text(item.count.first.reason.toString()),
            ],
          ),
          // Display other fields
        );
      }).toList(),
    );
  }

  Widget _buildYearList(List<YearList> yearList) {
    return ExpansionTile(
      title: const Text('Year List'),
      children: yearList.map((item) {
        return ListTile(
          title: Text(item.year.toString()),
          // Display other fields
        );
      }).toList(),
    );
  }

  Widget _buildFullCategory(List<FullCategory> fullCategory) {
    return ExpansionTile(
      title: const Text('Full Category'),
      children: fullCategory.map((item) {
        return ListTile(
          title: Text(item.categoryName.toString()),
          // Display other fields
        );
      }).toList(),
    );
  }
}

class CustomerTotalSalePages extends StatelessWidget {
  final String customerId;
  final int year;

  CustomerTotalSalePages({required this.customerId, required this.year});

  @override
  Widget build(BuildContext context) {
    // Access CustomersProvider
    final provider = Provider.of<CustomersProvider>(context);

    // Fetch data if not already fetched
    provider.fetchCustomerDashboardDataSalseData(customerId, year);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Total Sale Data'),
      ),
      body: Consumer<CustomersProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<CustomerTotalSaleResponse>(
            future: provider.customerTotalSaleResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final data = snapshot.data!.data;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text('Payment Completed',
                        style: Theme.of(context).textTheme.labelLarge),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Count')),
                        DataColumn(label: Text('Percentage')),
                        DataColumn(label: Text('Total Amount')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text(data.totalSale.paymentCompleted.count
                              .toString())),
                          DataCell(Text(
                              '${data.totalSale.paymentCompleted.percentage}%')),
                          DataCell(Text(data
                              .totalSale.paymentCompleted.totalAmount
                              .toString())),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Payment Remaining',
                        style: Theme.of(context).textTheme.labelLarge),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Count')),
                        DataColumn(label: Text('Percentage')),
                        DataColumn(label: Text('Total Amount')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text(data.totalSale.paymentRemaining.count
                              .toString())),
                          DataCell(Text(
                              '${data.totalSale.paymentRemaining.percentage}%')),
                          DataCell(Text(data
                              .totalSale.paymentRemaining.totalAmount
                              .toString())),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Discount Data',
                        style: Theme.of(context).textTheme.bodyLarge),
                    ...data.discountData.map((discount) {
                      return Card(
                        child: ListTile(
                          title: Text('Category: ${discount.category}'),
                          subtitle: Text('Discount: ${discount.discount}'),
                          trailing: Text('Value: ${discount.value}'),
                        ),
                      );
                    }).toList(),
                  ],
                );
              } else {
                return const NodataWidget();
              }
            },
          );
        },
      ),
    );
  }
}

// class CustomerDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CustomersProvider>(
//       builder: (context, provider, child) {
//         // Ensure data fetching happens only once
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (provider.countFuture == null) {
//             provider.fetchCustomerDashboardCountData('CUSTO3');
//           }
//         });

//         return FutureBuilder<ApiResponsees>(
//           future: provider.countFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (snapshot.hasData) {
//               final data = snapshot.data!.data;
//               return Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Order Count Summary',
//                       style: Theme.of(context).textTheme.labelLarge,
//                     ),
//                     const SizedBox(height: 16),
//                     DataTable(
//                       columns: const [
//                         DataColumn(label: Text('Order Type')),
//                         DataColumn(label: Text('Count')),
//                       ],
//                       rows: [
//                         DataRow(cells: [
//                           const DataCell(Text('Total Order')),
//                           DataCell(Text(data.totalOrder.toString())),
//                         ]),
//                         DataRow(cells: [
//                           const DataCell(Text('Estimate Order')),
//                           DataCell(Text(data.estimateOrder.toString())),
//                         ]),
//                         DataRow(cells: [
//                           const DataCell(Text('Preorder Order')),
//                           DataCell(Text(data.preorderOrder.toString())),
//                         ]),
//                         DataRow(cells: [
//                           const DataCell(Text('Draft Order')),
//                           DataCell(Text(data.draftOrder.toString())),
//                         ]),
//                         DataRow(cells: [
//                           const DataCell(Text('Cancel Order')),
//                           DataCell(Text(data.cancelOrder.toString())),
//                         ]),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               return const NodataWidget();
//             }
//           },
//         );
//       },
//     );
//   }
// }

// class CustomerDetailScreen extends StatelessWidget {
//   final String customerId;

//   const CustomerDetailScreen({Key? key, required this.customerId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CustomersProvider>(
//       builder: (context, provider, child) {
//         // Ensure data fetching happens only once
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (provider.customerResponse == null) {
//             provider.fetchCustomersDataDash('CUSTO3');
//           }
//         });

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Customer Details'),
//           ),
//           body: FutureBuilder<CustomerResponse?>(
//             future: provider.customerResponse,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (snapshot.hasData) {
//                 final customer = snapshot
//                     .data?.data.first; // Assuming there is only one customer
//                 return customer != null
//                     ? Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Full Name: ${customer.fullname}',
//                               style: const TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 8),
//                             Text('Email: ${customer.email}'),
//                             const SizedBox(height: 8),
//                             Text('Address: ${customer.address}'),
//                             const SizedBox(height: 8),
//                             Text('Discount: ${customer.discount}'),
//                             // Add more fields as needed
//                           ],
//                         ),
//                       )
//                     : const Center(child: Text('No data available'));
//               } else {
//                 return const Center(child: Text('No data available'));
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
// }

