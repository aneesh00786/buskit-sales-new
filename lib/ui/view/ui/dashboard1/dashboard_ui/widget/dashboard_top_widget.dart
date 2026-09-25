// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/api_handler/handle_logout.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
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
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
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
  bool showChatbotMobile = false;

  Future<void> checkUserVerification() async {
    try {
      final response = await ApiWorker().userVerification(
          SessionHelper.loginSavedData?.company_id ?? 0,
          SessionHelper.loginSavedData?.salesmanId ?? '');

      if (response.statusCode == 200) {
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
        handleLogout(context);
      }
    } catch (e) {
      //
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
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Dashboard'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isMobile) const ChatbotTopBarButton(),
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: primaryColor),
                      onPressed: () {
                        setState(() {
                          showChatbotMobile = !showChatbotMobile;
                        });
                      },
                    ),
                  const SizedBox(width: 12),
                  Consumer<DashboardProvider>(
                    builder: (context, provider, child) {
                      return NotificationWidget(
                        startDate: provider.selectedStartDate,
                        endDate: provider.selectedEndDate,
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: profiloe(),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isMobile && showChatbotMobile)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: const ChatbotTopBarButton(),
            ),
          ),
        const SizedBox(height: 4),
        calender(),
        const SizedBox(height: 6),
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
            return const Center(child: NodataWidget());
          }
          final data = widget.dashBoardController.dashbordData.value;
          return OptionWidget(
            customType: "",
            customOrderStatusType: OrderStatus.preOrder,
            draftCount: data.orderCountList?.draftOrder ?? 0,
            orderCount: data.orderCountList?.totalOrder ?? 0,
<<<<<<< HEAD
            preOrderCount: data.orderCountList?.preorderOrder ?? 0,
            eastimatesCount: data.orderCountList?.estimateOrder ?? 0,
=======
            preOrderCount: data.orderCountList?.preorderFilterOrder ?? 0,
            eastimatesCount: data.orderCountList?.estimateFilterOrder ?? 0,
>>>>>>> dd766a8bd0954c77d8a373f356044cfdb1f9e07a
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

  Widget _buildFilterDropdown(DashboardProvider provider, BuildContext context) {
    return SizedBox(
      height: 42,
      width: 125,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FilterDateEnum>(
              value: provider.selectedFilterTemp == FilterDateEnum.thisYear
                  ? FilterDateEnum.thisMonth
                  : provider.selectedFilterTemp,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 18),
              dropdownColor: Colors.white,
              onChanged: (newValue) async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(context, "You are Offline!".tr, red, Icons.close);
                  return;
                }

                if (newValue != null) {
                  provider.onFilterChanged(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: FilterDateEnum.thisMonth,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 15, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 7),
                      Text('Month'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: FilterDateEnum.thisWeek,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 15, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 7),
                      Text('Week'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: FilterDateEnum.today,
                  child: Row(
                    children: [
                      const Icon(Icons.today, size: 15, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 7),
                      Text('Day'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: FilterDateEnum.range,
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 15, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 7),
                      Text('Range'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
              ],
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildFilterDropdown(
  //     DashboardProvider provider, BuildContext context) {
  //   return SizedBox(
  //     height: 50,
  //     width: 125,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             Colors.white,
  //             Colors.white,
  //           ],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.08),
  //             blurRadius: 8,
  //             offset: const Offset(0, 4),
  //             spreadRadius: 0,
  //           ),
  //           BoxShadow(
  //             color: Colors.white.withOpacity(0.8),
  //             blurRadius: 0,
  //             offset: const Offset(-2, -2),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  //         child: DropdownButton<FilterDateEnum>(
  //           value: provider.selectedFilterTemp,
  //           onChanged: (newValue) async {
  //             bool isOnline = await ConnectivityService().isOnline();
  //             if (!isOnline) {
  //               showCustomToastDisplay(
  //                   context, "You are Offline!".tr, red, Icons.close);
  //               return;
  //             }

  //             if (newValue != null) {
  //               provider.onFilterChanged(newValue);
  //             }
  //           },
  //           items:  [
  //             DropdownMenuItem(
  //               value: FilterDateEnum.thisMonth,
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.calendar_month, size: 16, color: primaryColor),
  //                   SizedBox(width: 8),
  //                   Text('Month'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  //                 ],
  //               ),
  //             ),
  //             DropdownMenuItem(
  //               value: FilterDateEnum.thisWeek,
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.calendar_today, size: 16, color: primaryColor),
  //                   SizedBox(width: 8),
  //                   Text('Week'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  //                 ],
  //               ),
  //             ),
  //             DropdownMenuItem(
  //               value: FilterDateEnum.today,
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.today, size: 16, color: primaryColor),
  //                   SizedBox(width: 8),
  //                   Text('Day'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  //                 ],
  //               ),
  //             ),
  //             DropdownMenuItem(
  //               value: FilterDateEnum.thisYear,
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.calendar_view_month, size: 16, color: primaryColor),
  //                   SizedBox(width: 8),
  //                   Text('Year'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  //                 ],
  //               ),
  //             ),
  //             DropdownMenuItem(
  //               value: FilterDateEnum.range,
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.date_range, size: 16, color: primaryColor),
  //                   SizedBox(width: 8),
  //                   Text('Range'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  //                 ],
  //               ),
  //             ),
  //           ],
  //           isExpanded: true,
  //           borderRadius: BorderRadius.circular(12),
  //           underline: Container(),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget calender() {
    final loginController = Get.find<LoginController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            /// --- Tablet Layout
            if (isTabletOrPhoneLandscape(context)) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const SizedBox(width: 5),

                        // 1. Conditional Standalone Year Dropdown
                        if (provider.selectedFilterTemp != FilterDateEnum.range) ...[
                          buildYearDropdownWidget(context, provider),
                          const SizedBox(width: 10),
                        ],

                        // 2. Main Filter Dropdown
                        _buildFilterDropdown(provider, context),

                        // 3. Conditional Pickers
                        if (provider.selectedFilterTemp == FilterDateEnum.thisMonth) ...[
                          const SizedBox(width: 10),
                          const MonthDropdown()
                        ],
                        if (provider.selectedFilterTemp == FilterDateEnum.thisWeek) ...[
                          const SizedBox(width: 10),
                          const WeekDropdown()
                        ],
                        if (provider.selectedFilterTemp == FilterDateEnum.today) ...[
                          const SizedBox(width: 10),
                          const DatePickerWidget()
                        ],
                        if (provider.selectedFilterTemp == FilterDateEnum.range) ...[
                          const SizedBox(width: 10),
                          const Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 300,
                                child: RangePickerWidget(),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        
                        // 4. Unified Go Button
                        buildGoButton(context, provider),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Obx(() => loginController.isSyncing.value
                      ? SizedBox(
                          width: 100,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Syncing'),
                                    content: const Text('Data syncing in background'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              );
            }

            /// --- Phone Layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),

                      // 1. Conditional Standalone Year Dropdown
                      if (provider.selectedFilterTemp != FilterDateEnum.range) ...[
                        buildYearDropdownWidget(context, provider),
                        const SizedBox(width: 10),
                      ],

                      // 2. Main Filter Dropdown
                      _buildFilterDropdown(provider, context),

                      // 3. Conditional Pickers
                      if (provider.selectedFilterTemp == FilterDateEnum.thisMonth) ...[
                        const SizedBox(width: 10),
                        const MonthDropdown()
                      ],
                      if (provider.selectedFilterTemp == FilterDateEnum.thisWeek) ...[
                        const SizedBox(width: 10),
                        const WeekDropdown()
                      ],
                      if (provider.selectedFilterTemp == FilterDateEnum.today) ...[
                        const SizedBox(width: 10),
                        const DatePickerWidget()
                      ],
                      if (provider.selectedFilterTemp == FilterDateEnum.range) ...[
                        const SizedBox(width: 10),
                        const SizedBox(
                          width: 320,
                          child: RangePickerWidget(),
                        ),
                      ],
                      // const SizedBox(width: 10),

                      // 4. Unified Go Button
                      buildGoButton(context, provider),
                      
                      // const SizedBox(width: 20),
                      Obx(() => loginController.isSyncing.value
                          ? SizedBox(
                              width: 100,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Syncing'),
                                        content: const Text('Data syncing in background'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                const SizedBox(height: 12)
              ],
            );
          },
        );
      },
    );
  }

  // Widget calender() {
  //   Get.find<LoginController>();

  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       return Consumer<DashboardProvider>(
  //         builder: (context, provider, child) {
  //           /// --- Tablet Layout (keep as Row)
  //           if (isTabletOrPhoneLandscape(context)) {
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Flexible(
  //                   child: Row(
  //                     children: [
  //                       // CustomText(content: 'Dashboard',fontWeight: FontWeight.bold,),

  //                       _buildFilterDropdown(provider, context),
  //                       if (provider.selectedFilterTemp ==
  //                           FilterDateEnum.thisMonth) ...[
  //                         const SizedBox(width: 10),
  //                         const MonthDropdown()
  //                       ],
  //                       if (provider.selectedFilterTemp ==
  //                           FilterDateEnum.thisWeek) ...[
  //                         const SizedBox(width: 10),
  //                         const WeekDropdown()
  //                       ],
  //                       if (provider.selectedFilterTemp ==
  //                           FilterDateEnum.thisYear) ...[
  //                         const SizedBox(width: 10),
  //                         const YearDropdown()
  //                       ],
  //                       if (provider.selectedFilterTemp ==
  //                           FilterDateEnum.today) ...[
  //                         const SizedBox(width: 10),
  //                         const DatePickerWidget()
  //                       ],
  //                       if (provider.selectedFilterTemp ==
  //                           FilterDateEnum.range) ...[
  //                         const SizedBox(width: 10),
  //                         const Expanded(
  //                           child: SingleChildScrollView(
  //                             scrollDirection: Axis.horizontal,
  //                             child: SizedBox(
  //                               width: 320,
  //                               child: RangePickerWidget(),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(width: 15),
                 
  //                 const SizedBox(width: 15),
                
  //               ],
  //             );
  //           }

  //           /// --- Phone Layout
  //           return Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               /// Top Row: Notification + Update Button
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   NotificationWidget(
  //                     startDate: provider.selectedStartDate,
  //                     endDate: provider.selectedEndDate,
  //                   ),
  //                   const SizedBox(width: 10),
  //                   SizedBox(width: 120, child: profiloe()),
  //                 ],
  //               ),
  //               const SizedBox(height: 4),

  //               /// Filters and Sync in a horizontal scroll
  //               SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     const SizedBox(width: 5),
  //                     _buildFilterDropdown(provider, context),
  //                     if (provider.selectedFilterTemp ==
  //                         FilterDateEnum.thisMonth) ...[
  //                       const SizedBox(width: 10),
  //                       const MonthDropdown()
  //                     ],
  //                     if (provider.selectedFilterTemp ==
  //                         FilterDateEnum.thisWeek) ...[
  //                       const SizedBox(width: 10),
  //                       const WeekDropdown()
  //                     ],
  //                     if (provider.selectedFilterTemp ==
  //                         FilterDateEnum.thisYear) ...[
  //                       const SizedBox(width: 10),
  //                       const YearDropdown()
  //                     ],
  //                     if (provider.selectedFilterTemp ==
  //                         FilterDateEnum.today) ...[
  //                       const SizedBox(width: 10),
  //                       const DatePickerWidget()
  //                     ],
  //                     if (provider.selectedFilterTemp ==
  //                         FilterDateEnum.range) ...[
  //                       const SizedBox(width: 10),
  //                       const SizedBox(
  //                         width: 320,
  //                         child: RangePickerWidget(),
  //                       ),
  //                     ],
  //                     const SizedBox(width: 20),
                    
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(height: 12)
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Widget buildYearDropdownWidget(BuildContext context, DashboardProvider provider) {
    final int startYear = 2024;
    final int currentYear = DateTime.now().year;
    final int endYear = currentYear;

    final List<int> years = startYear <= endYear
        ? List.generate(endYear - startYear + 1, (index) => (startYear + index))
        : [currentYear];

    int displayYear = provider.selectedYear != 0 ? provider.selectedYear : currentYear;

    return SizedBox(
      height: 42,
      width: 95,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: years.contains(displayYear) ? displayYear : years.last,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 18),
              dropdownColor: Colors.white,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (int? newValue) async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(context, "You are Offline!".tr, red, Icons.close);
                  return;
                }
                if (newValue != null) {
                  provider.updateSelectedYear(newValue);
                }
              },
              items: years.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGoButton(BuildContext context, DashboardProvider provider) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: () async {
          bool isOnline = await ConnectivityService().isOnline();
          if (!isOnline) {
            showCustomToastDisplay(context, "You are Offline!".tr, red, Icons.close);
            return;
          }

          await provider.setTempToFilter();
          await provider.fetchAllOrdersAtOnce();
          provider.fetchData();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
          textStyle: const TextStyle(
            fontFamily: 'Poppins_Regular',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text('Go'.tr),
      ),
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
