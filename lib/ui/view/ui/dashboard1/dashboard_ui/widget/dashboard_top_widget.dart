import 'dart:developer';
import 'dart:io';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/category_model.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/option/option_widget.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/calander/calender_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../dashboard_controller.dart';

class DashboardTopWidget extends StatefulWidget {
  final DashBoardController dashBoardController;
  final HomeController homeController;
  const DashboardTopWidget(
      {super.key,
      required this.dashBoardController,
      required this.homeController});

  @override
  State<DashboardTopWidget> createState() => _DashboardTopWidgetState();
}

class _DashboardTopWidgetState extends State<DashboardTopWidget> {
  String? startDate;
  String? endDate;
  final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
  ProductsController productsController = Get.put(ProductsController());
  PendingPaymentController pendingPaymentController =
      Get.put(PendingPaymentController());
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
  PaginationModel paginationModel = PaginationModel();
  final int currentYear = DateTime.now().year;
  int selectedTabIndex = 0;
  SearchModel searchData = SearchModel();
  final ApiWorker _apiWorker = ApiWorker();
  TabController? _tabController;
  TabController? get tabController => _tabController;
  @override
  void initState() {
    super.initState();
    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    if (!dashboardProvider.dataFetched) {
      dashboardProvider.resetProvider();
      dashboardProvider.fetchData();
      dashboardProvider.fetchChatData(salesmanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        calender(),
        nkSmallSizeBox(),
        SizedBox(height: 10),
        Obx(() {
          if (widget.dashBoardController.isLoading.value) {
            return Center(
              child: SpinKitFadingCube(
                color: primaryColor,
                size: 20.0,
              ),
            );
          }
          if (widget.dashBoardController.errorMessage.value.isNotEmpty) {
            log('Error: ${widget.dashBoardController.errorMessage.value}');
            return Center(
                child: Text(
                    'Error: ${widget.dashBoardController.errorMessage.value}'));
          }
          final data = widget.dashBoardController.dashbordData.value;
          log('DashBoard data Value ===========${data.orderCountList}');
          return OptionWidget(
            customType: "",
            customOrderStatusType: OrderStatus.preOrder,
            draftCount: data.orderCountList?.draftOrder ?? 0,
            orderCount: data.orderCountList?.totalOrder ?? 40,
            preOrderCount: data.orderCountList?.preorderOrder ?? 60,
            eastimatesCount: data.orderCountList?.estimateOrder ?? 80,
            userType: UserType.customer,
            userId: "",
            startDate: widget.dashBoardController.selectedStartDate.value,
            endDate: widget.dashBoardController.selectedEndDate.value,
          );
        }),
      ],
    );
  }

  Widget calender() {
    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            bool isSmallScreen = ResponsiveInfo.isMobileDimension(context);
            Widget rowContent = Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      SizedBox(
                        height: isSmallScreen ? 29 : 38,
                        width: isSmallScreen ? 84 : 104,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 4.0, top: 4.0, bottom: 1.0),
                              child: DropdownButton<FilterDateEnum>(
                                value: provider.selectedFilter,
                                onChanged: (newValue) async {
                                  bool isConnected =
                                      await ConnectivityService().isOnline();
                                  if (newValue != null && isConnected) {
                                    provider.onFilterChanged(newValue);
                                  } else {
                                    showNoInternetSnackBar(context);
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: FilterDateEnum.thisMonth,
                                    child: Text(
                                      'This Month',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: isSmallScreen ? 7.7 : 9.8,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: FilterDateEnum.today,
                                    child: Text(
                                      'Today',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: isSmallScreen ? 7.7 : 10.5,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: FilterDateEnum.thisWeek,
                                    child: Text(
                                      'This Week',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: isSmallScreen ? 7.7 : 10.5,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: FilterDateEnum.thisYear,
                                    child: Text(
                                      'This Year',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: isSmallScreen ? 7.7 : 10.5,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: FilterDateEnum.range,
                                    child: Text(
                                      'Range',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: isSmallScreen ? 7.7 : 10.5,
                                      ),
                                    ),
                                  ),
                                ],
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(10),
                                underline: Container(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (provider.selectedFilter == FilterDateEnum.range)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () =>
                                        provider.selectDate(context, true),
                                    child: Container(
                                      height: isSmallScreen ? 29 : 38,
                                      width: isSmallScreen ? 62 : 90,
                                      decoration: BoxDecoration(
                                        color: const Color(0xfff9f9fb),
                                        border: Border.all(
                                            color: const Color(0xffd1d1d1),
                                            width: 1.0),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            provider.selectedStartDate.isEmpty
                                                ? 'DD-MM-YYYY'
                                                : provider.selectedStartDate,
                                            style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 7.7 : 10.5,
                                                color: Colors.grey[800]),
                                          ),
                                          Icon(
                                            Icons.calendar_today,
                                            size: isSmallScreen ? 10 : 14,
                                            color: Colors.grey[700],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () =>
                                        provider.selectDate(context, false),
                                    child: Container(
                                      height: isSmallScreen ? 29 : 38,
                                      width: isSmallScreen ? 62 : 90,
                                      decoration: BoxDecoration(
                                        color: const Color(0xfff9f9fb),
                                        border: Border.all(
                                            color: const Color(0xffd1d1d1),
                                            width: 1.0),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            provider.selectedEndDate.isEmpty
                                                ? 'DD-MM-YYYY'
                                                : provider.selectedEndDate,
                                            style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 7.7 : 10.5,
                                                color: Colors.grey[800]),
                                          ),
                                          Icon(
                                            Icons.calendar_today,
                                            size: isSmallScreen ? 10 : 14,
                                            color: Colors.grey[700],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: SizedBox(
                                    height: isSmallScreen ? 29 : 36.4,
                                    width: isSmallScreen ? 65 : 68,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        provider.fetchData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Go',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SyncButtonWidget(
                  onSync: () async {
                    DateTime now = DateTime.now();
                    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
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
                    await Provider.of<CustomersProvider>(context, listen: false)
                        .fetchCustomerData();
                    await customerAndOrderController.loadCustomer();
                    await Future.delayed(const Duration(microseconds: 500));
                    await productsController.fetchCategoryData();
                    await Future.delayed(const Duration(microseconds: 500));
                    await ApiWorker().fetchRecentOrderCount(
                        startDate: '', endDate: '');
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
                      isLogin: true,
                      startDate: firstDayString,
                      endDate: lastDayString,
                    );
                    await calenderMapController
                        .fetchCalenderEvents(initialDay ?? DateTime.now());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Syncing offline orders...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
                SizedBox(width: 20),
                NotificationWidget(
                  startDate: provider.selectedStartDate,
                  endDate: provider.selectedEndDate,
                ),
                profiloe(),
              ],
            );

            return rowContent;
          },
        );
      },
    );
  }

  int calculateNotificationCount() {
    return (widget.dashBoardController.recentOrderCountData.mainNotification!
                .recentOrders ??
            0) +
        (widget.dashBoardController.recentOrderCountData.mainNotification!
                .waitingForApproval ??
            0) +
        (widget.dashBoardController.recentOrderCountData.mainNotification!
                .quickSale ??
            0) +
        (widget.dashBoardController.recentOrderCountData.mainNotification!
                .processingOrders ??
            0) +
        (widget.dashBoardController.recentOrderCountData.mainNotification!
                .packedAndReadyForDelivery ??
            0);
  }

  Widget get orderTrakingButton => MyThemeButton(
        buttonText: orderTaking,
        fontSize: NkFontSize.smallFont() + 4,
        padding: nkSymmetricPadding(vertical: 0),
        //width: AppDimensions.instance!.width * 0.12,
        onPressed: () =>
            {widget.homeController.sidebarXController.selectIndex(1)},
      );

  Widget options() {
    return Row(
      children: [
        orderOptions(
            title: orders,
            count: '109',
            svg: Assets.iconsIcDashboardShoppingCart,
            svgBgColor: const Color(0xFFFCDABD),
            onTap: () {}),
        nkSmallSizeBox(),
        orderOptions(
          title: estimates,
          count: '34',
          svg: Assets.iconsIcDashboardEstimates,
          svgBgColor: const Color(0xFFC3DDFD),
        ),
        nkSmallSizeBox(),
        orderOptions(
            title: preOrder,
            count: '59',
            svg: Assets.iconsIcDashboardPreOrder,
            svgBgColor: const Color(0xFFAFECEF),
            onTap: () {}),
        nkSmallSizeBox(),
        orderOptions(
          title: draft,
          count: '10',
          svg: Assets.iconsIcDashboardDraft,
          svgBgColor: const Color(0xFFBCF0DA),
        ),
      ],
    );
  }

  Widget orderOptions(
      {required String title,
      required String count,
      required String svg,
      required Color svgBgColor,
      VoidCallback? onTap}) {
    SvgPicture svgComponet = SvgPicture.asset(
      svg,
      height: AppDimensions.instance!.height * 0.03,
      fit: BoxFit.contain,
    );
    return MyCommnonContainer(
      onTap: onTap,
      //margin: nkSymmetricPadding(vertical: 0),

      isCommonBorder: true,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ClipOval(
                child: ColoredBox(
                    color: svgBgColor,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: svgComponet,
                    )),
              ),
            ),
            //nkExtraSmallSizeBox(),

            Expanded(
              flex: 4,
              child: Column(
                //spacing: 0.2,
                children: [
                  MyRegularText(
                    label: title,
                  ),
                  MyRegularText(
                    label: count,
                  )
                ],
              ),
            )
          ]),
    );
  }
}
