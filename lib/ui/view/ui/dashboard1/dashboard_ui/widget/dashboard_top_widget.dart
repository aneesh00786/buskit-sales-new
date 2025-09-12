// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/handle_logout.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
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
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/day_picker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/month_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/range_picker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/week_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/year_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/home/home_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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

  Future<void> checkUserVerification() async {
    try {
      final response = await ApiWorker().userVerification(
          SessionHelper.loginSavedData?.company_id ?? 0,
          SessionHelper.loginSavedData?.salesmanId ?? '');

      if (response.statusCode == 200) {
        log('success', name: 'userVerification');
      } else {
        final message = response.message;
        Get.snackbar(
          "Error",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.5),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        log(message, name: 'userVerification');
        handleLogout(context);
      }
    } catch (e) {
      log('userVerification exception: $e', name: 'userVerification');
    }
  }

  Future<void> _initData() async {
    await checkUserVerification();

    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    dashboardProvider.resetFilter();
    if (!dashboardProvider.dataFetched) {
      dashboardProvider.resetProvider();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dashboardProvider.fetchData();
      });
      dashboardProvider.fetchChatData(salesmanId);
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        calender(),
        nkSmallSizeBox(),
        Obx(() {
          if (widget.dashBoardController.isLoading.value) {
            return const Center(
              child: SpinKitFadingCube(
                color: primaryColor,
                size: 20.0,
              ),
            );
          }
          if (widget.dashBoardController.errorMessage.value.isNotEmpty) {
            log('Error: ${widget.dashBoardController.errorMessage.value}');
            return const Center(child: NodataWidget());
          }
          final data = widget.dashBoardController.dashbordData.value;
          log('DashBoard data Value ===========${data.orderCountList}');
          return OptionWidget(
            customType: "",
            customOrderStatusType: OrderStatus.preOrder,
            draftCount: data.orderCountList?.draftOrder ?? 0,
            orderCount: data.orderCountList?.totalOrder ?? 0,
            preOrderCount: data.orderCountList?.preorderFilterOrder ?? 0,
            eastimatesCount: data.orderCountList?.estimateFilterOrder ?? 0,
            cancelledCount: data.orderCountList?.cancelOrder ?? 0,
            eastimatesFilterCount:
                data.orderCountList?.estimateFilterOrder ?? 0,
            preOrderFilterCount: data.orderCountList?.preorderFilterOrder ?? 0,
            draftFilterCount: data.orderCountList?.draftFilteredCount ?? 0,
            userType: UserType.customer,
            userId: "",
            startDate: widget.dashBoardController.selectedStartDate.value,
            endDate: widget.dashBoardController.selectedEndDate.value,
          );
        }),
      ],
    );
  }

  Widget _buildFilterDropdown(
      DashboardProvider provider, BuildContext context) {
    return SizedBox(
      height: 45,
      width: 120,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10.0, right: 4.0, top: 4.0, bottom: 1.0),
          child: DropdownButton<FilterDateEnum>(
            value: provider.selectedFilterTemp,
            onChanged: (newValue) async {
              bool isOnline = await ConnectivityService().isOnline();
              if (!isOnline) {
                showCustomToastDisplay(
                    context, "You are Offline!", red, Icons.close);
                return;
              }

              if (newValue != null) {
                provider.onFilterChanged(newValue);
              }
            },
            items: const [
              DropdownMenuItem(
                value: FilterDateEnum.thisMonth,
                child: Text('Month', style: TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: FilterDateEnum.thisWeek,
                child: Text('Week', style: TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: FilterDateEnum.today,
                child: Text('Day', style: TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: FilterDateEnum.thisYear,
                child: Text('Year', style: TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: FilterDateEnum.range,
                child: Text('Range', style: TextStyle(fontSize: 12)),
              ),
            ],
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            underline: Container(),
          ),
        ),
      ),
    );
  }

  Widget calender() {
    final loginController = Get.find<LoginController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            /// --- Tablet Layout (keep as Row)
            if (isTabletOrPhoneLandscape(context)) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        _buildFilterDropdown(provider, context),
                        if (provider.selectedFilterTemp ==
                            FilterDateEnum.thisMonth) ...[
                          const SizedBox(width: 10),
                          const MonthDropdown()
                        ],
                        if (provider.selectedFilterTemp ==
                            FilterDateEnum.thisWeek) ...[
                          const SizedBox(width: 10),
                          const WeekDropdown()
                        ],
                        if (provider.selectedFilterTemp ==
                            FilterDateEnum.thisYear) ...[
                          const SizedBox(width: 10),
                          const YearDropdown()
                        ],
                        if (provider.selectedFilterTemp ==
                            FilterDateEnum.today) ...[
                          const SizedBox(width: 10),
                          const DatePickerWidget()
                        ],
                        if (provider.selectedFilterTemp ==
                            FilterDateEnum.range) ...[
                          const SizedBox(width: 10),
                          const Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 320,
                                child: RangePickerWidget(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Obx(() => loginController.isSyncing.value
                  //     ? SizedBox(
                  //         width: 100,
                  //         child: Center(
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               showDialog(
                  //                 context: context,
                  //                 builder: (context) => AlertDialog(
                  //                   title: const Text('Syncing'),
                  //                   content: const Text(
                  //                       'Data syncing in background'),
                  //                   actions: [
                  //                     TextButton(
                  //                       onPressed: () =>
                  //                           Navigator.of(context).pop(),
                  //                       child: const Text('OK'),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               );
                  //             },
                  //             child: const CircularProgressIndicator(),
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox.shrink()),
                  const SizedBox(width: 20),
                  NotificationWidget(
                    startDate: provider.selectedStartDate,
                    endDate: provider.selectedEndDate,
                  ),
                  SizedBox(width: 120, child: profiloe()),
                ],
              );
            }

            /// --- Phone Layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Row: Notification + Update Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NotificationWidget(
                      startDate: provider.selectedStartDate,
                      endDate: provider.selectedEndDate,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 120, child: profiloe()),
                  ],
                ),
                const SizedBox(height: 4),

                /// Filters and Sync in a horizontal scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      _buildFilterDropdown(provider, context),
                      if (provider.selectedFilterTemp ==
                          FilterDateEnum.thisMonth) ...[
                        const SizedBox(width: 10),
                        const MonthDropdown()
                      ],
                      if (provider.selectedFilterTemp ==
                          FilterDateEnum.thisWeek) ...[
                        const SizedBox(width: 10),
                        const WeekDropdown()
                      ],
                      if (provider.selectedFilterTemp ==
                          FilterDateEnum.thisYear) ...[
                        const SizedBox(width: 10),
                        const YearDropdown()
                      ],
                      if (provider.selectedFilterTemp ==
                          FilterDateEnum.today) ...[
                        const SizedBox(width: 10),
                        const DatePickerWidget()
                      ],
                      if (provider.selectedFilterTemp ==
                          FilterDateEnum.range) ...[
                        const SizedBox(width: 10),
                        const SizedBox(
                          width: 320,
                          child: RangePickerWidget(),
                        ),
                      ],
                      const SizedBox(width: 20),
                      // Obx(() => loginController.isSyncing.value
                      //     ? SizedBox(
                      //         width: 100,
                      //         child: Center(
                      //           child: GestureDetector(
                      //             onTap: () {
                      //               showDialog(
                      //                 context: context,
                      //                 builder: (context) => AlertDialog(
                      //                   title: const Text('Syncing'),
                      //                   content: const Text(
                      //                       'Data syncing in background'),
                      //                   actions: [
                      //                     TextButton(
                      //                       onPressed: () =>
                      //                           Navigator.of(context).pop(),
                      //                       child: const Text('OK'),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               );
                      //             },
                      //             child: const CircularProgressIndicator(),
                      //           ),
                      //         ),
                      //       )
                      //     : const SizedBox.shrink()),
                    ],
                  ),
                ),
                SizedBox(height: 12)
              ],
            );
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
      height: AppDimensions.instance.height * 0.03,
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
