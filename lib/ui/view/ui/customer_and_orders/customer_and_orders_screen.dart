// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, use_build_context_synchronously, empty_catches

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/order_status_enum.dart';
import 'package:busskit_salesexecutive/common/file_size_checker.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/common/no_data_widget.dart';
import 'package:busskit_salesexecutive/common/time_convertion.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/generated/assets.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/view/order_taking.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/common_hight_width.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/Invoice_dialogue/detailed_invoice_dialogue.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/html_invoice.dart';
import 'package:busskit_salesexecutive/ui/components/custom_tooltip.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/side_bar/nk_sidebarx.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/widget/payment_history_popup.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/event_type_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/day_picker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/month_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/week_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/year_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/products_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/custom_scrollbar.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:busskit_salesexecutive/ui/view/ui/chatbot/chatbot_top_bar_button.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';
import '../../../components/color/colors.dart';
import '../../../theme/custom_fonts.dart';
import '../../../utills/enum/filter_date_enum.dart';
import '../dashboard1/provider/dash_models.dart';
import '../products/staff_controller.dart';
import 'csord_model/customers_orders_model.dart';
import 'cus_provider/cus_provider.dart';
import 'customer_dashbord/customer_dashbord_screen.dart';

class Tableee extends StatefulWidget {
  const Tableee({super.key});

  @override
  State<Tableee> createState() => _TableeeState();
}

class _TableeeState extends State<Tableee> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<CustomersProvider>(context, listen: false).currentPage = 1;

    _scrollController1.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
      if (_scrollController1.hasClients &&
          _scrollController3.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController3.position.pixels) {
        _scrollController3.jumpTo(_scrollController1.position.pixels);
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
      if (_scrollController2.hasClients &&
          _scrollController3.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController3.position.pixels) {
        _scrollController3.jumpTo(_scrollController2.position.pixels);
      }
    });

    _scrollController3.addListener(() {
      if (_scrollController3.hasClients &&
          _scrollController1.hasClients &&
          _scrollController3.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController3.position.pixels);
      }
      if (_scrollController3.hasClients &&
          _scrollController2.hasClients &&
          _scrollController3.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController3.position.pixels);
      }
    });

    Provider.of<CustomersProvider>(context, listen: false).fetchCustomerData();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  bool showChatbotMobile = false;

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final provider = Provider.of<CustomersProvider>(context);
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: white,
        surfaceTintColor: white,
        toolbarHeight: (isTabletOrPhoneLandscape(context))
            ? null
            : (showChatbotMobile ? 110 : 80),
        actions: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customers & Orders'.tr,
                      style: const TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      )),
                  Row(
                    children: [
                      if (!isMobile) addCustomer(context),
                      if (!isMobile) const SizedBox(width: 12),
                      if (!isMobile)
                        const ChatbotTopBarButton(routeName: '/customers'),
                      if (isMobile)
                        IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: primaryColor),
                          onPressed: () {
                            setState(() {
                              showChatbotMobile = !showChatbotMobile;
                            });
                          },
                        ),
                      if (!isMobile) const SizedBox(width: 12),
                      if (!isMobile)
                        NotificationWidget(
                          startDate: provider.selectedStartDate,
                          endDate: provider.selectedEndDate,
                        ),
                      SizedBox(width: 120, child: profiloe()),
                    ],
                  ),
                ],
              ),
              if (isMobile && showChatbotMobile)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: const ChatbotTopBarButton(routeName: '/customers'),
                  ),
                ),
            ],
          )),
          // Padding(
          //   padding: const EdgeInsets.only(top: 8),
          //   child: CustomText(content: 'Customers',fontWeight: FontWeight.bold,),
          // ),
          // SizedBox(width: 5,),
          // Expanded(child: calender()),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Column(
              children: [
                calender(),
                SizedBox(
                  height: 5,
                ),
                TopTotalWidget(
                    scrollController: _scrollController3, provider: provider),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 120),
              Expanded(
                  child: FrozenHeaderTable(
                scrollController: _scrollController1,
              )),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomTotalWidget(
                scrollController: _scrollController2, provider: provider),
          ),
        ],
      ),
    );
  }

  Widget calender() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, child) {
            return Consumer<CustomersProvider>(
              builder: (context, provider, child) {
                /// --- Tablet / Landscape Layout
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
                            if (provider.selectedFilter !=
                                FilterDateEnum.range) ...[
                              buildYearDropdownWidget(
                                  context, dashboardProvider),
                              const SizedBox(width: 10),
                            ],

                            // 2. Main Filter Dropdown
                            buildFilterDropdown(provider, context),

                            // 3. Conditional Pickers (No internal Go buttons)
                            if (provider.selectedFilter ==
                                FilterDateEnum.thisMonth) ...[
                              const SizedBox(width: 10),
                              const MonthDropdown(),
                            ],
                            if (provider.selectedFilter ==
                                FilterDateEnum.thisWeek) ...[
                              const SizedBox(width: 10),
                              const WeekDropdown(),
                            ],
                            if (provider.selectedFilter ==
                                FilterDateEnum.today) ...[
                              const SizedBox(width: 10),
                              const DatePickerWidget(),
                            ],
                            if (provider.selectedFilter ==
                                FilterDateEnum.range) ...[
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  // Start Date Picker
                                  SizedBox(
                                    height: 50,
                                    width: 125,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.white, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFE1E5E9),
                                            width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            blurRadius: 0,
                                            offset: const Offset(-2, -2),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          bool isOnline =
                                              await ConnectivityService()
                                                  .isOnline();
                                          if (!isOnline) {
                                            showCustomToastDisplay(
                                                context,
                                                "You are Offline!".tr,
                                                red,
                                                Icons.close);
                                            return;
                                          }
                                          provider.selectDate(context, true);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  provider.selectedStartDate
                                                          .isNotEmpty
                                                      ? DateFormat('dd-MM-yyyy')
                                                          .format(DateTime
                                                              .parse(provider
                                                                  .selectedStartDate))
                                                      : "DD-MM-YYYY",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.calendar_today,
                                                  size: 18,
                                                  color: primaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),

                                  // End Date Picker
                                  SizedBox(
                                    height: 50,
                                    width: 125,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.white, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFE1E5E9),
                                            width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            blurRadius: 0,
                                            offset: const Offset(-2, -2),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          bool isOnline =
                                              await ConnectivityService()
                                                  .isOnline();
                                          if (!isOnline) {
                                            showCustomToastDisplay(
                                                context,
                                                "You are Offline!".tr,
                                                red,
                                                Icons.close);
                                            return;
                                          }
                                          provider.selectDate(context, false);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  provider.selectedEndDate
                                                          .isNotEmpty
                                                      ? DateFormat('dd-MM-yyyy')
                                                          .format(DateTime
                                                              .parse(provider
                                                                  .selectedEndDate))
                                                      : "DD-MM-YYYY",
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.calendar_today,
                                                  size: 18,
                                                  color: primaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(width: 10),
                            // 4. Unified Go Button
                            buildGoButton(context, provider),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                /// --- Phone / Portrait Layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        addCustomer(context),
                        const SizedBox(width: 8),
                        NotificationWidget(
                          startDate: provider.selectedStartDate,
                          endDate: provider.selectedEndDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 5),

                          // 1. Conditional Standalone Year Dropdown
                          if (provider.selectedFilter !=
                              FilterDateEnum.range) ...[
                            buildYearDropdownWidget(context, dashboardProvider),
                            const SizedBox(width: 10),
                          ],

                          // 2. Main Filter Dropdown
                          buildFilterDropdown(provider, context),

                          // 3. Conditional Pickers
                          if (provider.selectedFilter ==
                              FilterDateEnum.thisMonth) ...[
                            const SizedBox(width: 10),
                            const MonthDropdown()
                          ],
                          if (provider.selectedFilter ==
                              FilterDateEnum.thisWeek) ...[
                            const SizedBox(width: 10),
                            const WeekDropdown()
                          ],
                          if (provider.selectedFilter ==
                              FilterDateEnum.today) ...[
                            const SizedBox(width: 10),
                            const DatePickerWidget()
                          ],
                          if (provider.selectedFilter ==
                              FilterDateEnum.range) ...[
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      provider.selectDate(context, true),
                                  child: dateBox(provider.selectedStartDate),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      provider.selectDate(context, false),
                                  child: dateBox(provider.selectedEndDate),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(width: 10),
                          // 4. Unified Go Button
                          buildGoButton(context, provider),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildFilterDropdown(CustomersProvider provider, BuildContext context) {
    return SizedBox(
      height: 50,
      width: 125,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 0,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FilterDateEnum>(
              // Fallback to month if somehow stuck on thisYear
              value: provider.selectedFilter == FilterDateEnum.thisYear
                  ? FilterDateEnum.thisMonth
                  : provider.selectedFilter,
              onChanged: (newValue) async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(
                      context, "You are Offline!".tr, red, Icons.close);
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
                      const Icon(Icons.calendar_month,
                          size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('Month'.tr,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: FilterDateEnum.thisWeek,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('Week'.tr,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: FilterDateEnum.today,
                  child: Row(
                    children: [
                      const Icon(Icons.today, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('Day'.tr,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // REMOVED FilterDateEnum.thisYear
                DropdownMenuItem(
                  value: FilterDateEnum.range,
                  child: Row(
                    children: [
                      const Icon(Icons.date_range,
                          size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text('Range'.tr,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// New Standalone Blue Year Dropdown Widget
  Widget buildYearDropdownWidget(
      BuildContext context, DashboardProvider dashboardProvider) {
    final int startYear = 2024;
    final int currentYear = DateTime.now().year;
    final int endYear = currentYear;

    final List<int> years = startYear <= endYear
        ? List.generate(endYear - startYear + 1, (index) => (startYear + index))
        : [currentYear];

    int displayYear = dashboardProvider.selectedYear != 0
        ? dashboardProvider.selectedYear
        : currentYear;

    return SizedBox(
      height: 50,
      width: 100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE1E5E9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: years.contains(displayYear) ? displayYear : years.last,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.black54, size: 20),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (int? newValue) async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(
                      context, "You are Offline!".tr, red, Icons.close);
                  return;
                }
                if (newValue != null) {
                  dashboardProvider.updateSelectedYear(newValue);
                  // UI updates automatically, wait for Go button press to fetch data
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

  /// New Unified Go Button
  Widget buildGoButton(BuildContext context, CustomersProvider provider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          bool isOnline = await ConnectivityService().isOnline();
          if (!isOnline) {
            showCustomToastDisplay(
                context, "You are Offline!".tr, red, Icons.close);
            return;
          }
          provider.currentPage = 1;
          provider.fetchCustomerData();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A72FF), // Standard blue Go Button
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF4A72FF).withOpacity(0.4),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text('Go'.tr),
      ),
    );
  }

  Widget dateBox(String date) {
    return Container(
      height: 38,
      width: 90,
      decoration: BoxDecoration(
        color: const Color(0xfff9f9fb),
        border: Border.all(color: const Color(0xffd1d1d1), width: 1.0),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date.isEmpty
                ? 'DD-MM-YYYY'
                : DateFormat('dd-MM-yyyy').format(DateTime.parse(date)),
            style: TextStyle(fontSize: 10.5, color: Colors.grey[800]),
          ),
          Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Consumer<CustomersProvider> addCustomer(BuildContext context) {
    ResponsiveInfo.isMobileDimension(context);
    return Consumer<CustomersProvider>(builder: (context, provider, child) {
      return FutureBuilder<CustomerResponse>(
        future: provider.customerResponse,
        builder: (context, snapshot) {
          TextEditingController phoneController = TextEditingController();
          TextEditingController emailController = TextEditingController();
          TextEditingController telephoneController = TextEditingController();
          TextEditingController townController = TextEditingController();
          TextEditingController stateController = TextEditingController();
          TextEditingController zipcodeController = TextEditingController();
          TextEditingController addressController = TextEditingController();
          TextEditingController countryController = TextEditingController();

          TextEditingController bsNameController = TextEditingController();

          TextEditingController contactPersonNameController =
              TextEditingController();
          TextEditingController contactNumController = TextEditingController();

          TextEditingController deliveryAddressController =
              TextEditingController();
          TextEditingController deliveryTownController =
              TextEditingController();
          TextEditingController deliveryStateController =
              TextEditingController();
          TextEditingController deliveryZipcodeController =
              TextEditingController();
          TextEditingController deliveryCountryController =
              TextEditingController();

          // NEW: Delivery Contact Number Controller
          TextEditingController deliveryContactNumController =
              TextEditingController();

          TextEditingController remarkController = TextEditingController();

          bool sameAsAbove = false;
          bool isAddingCustomer = false;

          return SizedBox(
            height: 38,
            width: 108,
            child: CustomButton2(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dialog(
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: white,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              side: BorderSide.none,
                            ),
                            elevation: 24.0,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor,
                                          Color(0xFF2D3748)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Add Customer'.tr,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins_Regular',
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        InkResponse(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            child: Icon(Icons.close,
                                                color: Colors.white, size: 22),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        buildInputField(
                                            bsNameController,
                                            'Business Name'.tr,
                                            Assets.icBusiness),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: buildInputField(
                                                  addressController,
                                                  'Address'.tr,
                                                  Assets.icLocation),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              flex: 1,
                                              child: buildInputField(
                                                  townController,
                                                  'City or Suburb'.tr,
                                                  Assets.icCity),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildInputField(
                                                  stateController,
                                                  'State'.tr,
                                                  Assets.icState),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                  zipcodeController,
                                                  'Zip/Post/Pin Code'.tr,
                                                  Assets.icZipcode),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                  countryController,
                                                  'Country'.tr,
                                                  Assets.icLocation),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: buildInputField(
                                                phoneController,
                                                'Mobile Number'.tr,
                                                Assets.icMobile,
                                                length: 10,
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                  emailController,
                                                  'Email'.tr,
                                                  Assets.icEmail),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                  telephoneController,
                                                  'Business Reg.No'.tr,
                                                  Assets.icBusinessReg),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Contact Details'.tr,
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: buildInputField(
                                                  contactPersonNameController,
                                                  'Contact Person'.tr,
                                                  Assets.icUser),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                contactNumController,
                                                'Contact Number'.tr,
                                                Assets.icPhone,
                                                length: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Delivery Address    '.tr,
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              Checkbox(
                                                value: sameAsAbove,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    sameAsAbove =
                                                        value ?? false;
                                                    if (sameAsAbove) {
                                                      deliveryAddressController
                                                              .text =
                                                          addressController
                                                              .text;
                                                      deliveryContactNumController
                                                              .text =
                                                          contactNumController
                                                              .text; // Updated
                                                      deliveryTownController
                                                              .text =
                                                          townController.text;
                                                      deliveryStateController
                                                              .text =
                                                          stateController.text;
                                                      deliveryZipcodeController
                                                              .text =
                                                          zipcodeController
                                                              .text;
                                                      deliveryCountryController
                                                              .text =
                                                          countryController
                                                              .text;
                                                    } else {
                                                      deliveryAddressController
                                                          .clear();
                                                      deliveryContactNumController
                                                          .clear(); // Updated
                                                      deliveryTownController
                                                          .clear();
                                                      deliveryStateController
                                                          .clear();
                                                      deliveryZipcodeController
                                                          .clear();
                                                      deliveryCountryController
                                                          .clear();
                                                    }
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 5),
                                              Text('Same as Above'.tr),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: buildInputField(
                                                  deliveryAddressController,
                                                  'Address'.tr,
                                                  Assets.icLocation),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              flex: 1,
                                              child: buildInputField(
                                                  deliveryTownController,
                                                  'City or Suburb'.tr,
                                                  Assets.icCity),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: buildInputField(
                                                  deliveryStateController,
                                                  'State'.tr,
                                                  Assets.icState),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                  deliveryZipcodeController,
                                                  'Zip/Post/Pin Code'.tr,
                                                  Assets.icZipcode),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: buildInputField(
                                                  deliveryCountryController,
                                                  'Country'.tr,
                                                  Assets.icLocation),
                                            ),
                                          ],
                                        ),
                                        // NEW: Delivery Contact Field Build
                                        buildInputField(
                                            deliveryContactNumController,
                                            'Delivery Contact Number'.tr,
                                            Assets.icPhone,
                                            length: 10),
                                        SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              Spacer(),
                                              SizedBox(width: 8.0),
                                              Expanded(
                                                  child:
                                                      Text("Company logo".tr))
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            // Remark Input Field
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      blurRadius: 6.0,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: TextField(
                                                  controller: remarkController,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 16.0,
                                                            vertical: 18.0),
                                                    labelText: 'Remark',
                                                    labelStyle: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                    prefixIcon: filledIcon(
                                                        Assets.icRemark),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.blue,
                                                              width: 1.5),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade400,
                                                          width: 1.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),

                                            // Image Picker
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth:
                                                                      340),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    20,
                                                                    20,
                                                                    20,
                                                                    12),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Select Method'
                                                                          .tr,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Poppins_Regular',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Color(0xFF0F172A)),
                                                                    ),
                                                                    InkWell(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      onTap: () =>
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(4),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .close,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              Color(0xFF64748B),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 16),
                                                                _selectMethodOption(
                                                                  context:
                                                                      context,
                                                                  icon: EneftyIcons
                                                                      .camera_outline,
                                                                  label:
                                                                      'Camera'
                                                                          .tr,
                                                                  onTap:
                                                                      () async {
                                                                    await provider
                                                                        .pickImage(
                                                                            ImageSource.camera);
                                                                    setState(
                                                                        () {});
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                _selectMethodOption(
                                                                  context:
                                                                      context,
                                                                  icon: EneftyIcons
                                                                      .gallery_bold,
                                                                  label:
                                                                      'Gallery'
                                                                          .tr,
                                                                  onTap:
                                                                      () async {
                                                                    await provider
                                                                        .pickImage(
                                                                            ImageSource.gallery);
                                                                    setState(
                                                                        () {});
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        blurRadius: 6.0,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 18.0,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.image,
                                                          color: Colors
                                                              .grey.shade600,
                                                          size: 28.0,
                                                        ),
                                                        const SizedBox(
                                                            width: 12.0),
                                                        Expanded(
                                                          child: Text(
                                                            provider.imageFile ==
                                                                    null
                                                                ? 'Pick an image from gallery'
                                                                    .tr
                                                                : 'Image selected'
                                                                    .tr,
                                                            style: TextStyle(
                                                              color: const Color(
                                                                  0xFF0F172A),
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        if (provider
                                                                .imageFile !=
                                                            null)
                                                          SizedBox(
                                                            height: 100,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      NkGeneralSize
                                                                          .nkCommonBorderRadius()),
                                                              child: provider
                                                                          .imageFile !=
                                                                      null
                                                                  ? Image.file(
                                                                      provider
                                                                          .imageFile!,
                                                                      height: AppDimensions
                                                                              .instance
                                                                              .height *
                                                                          0.2,
                                                                    )
                                                                  : nkSmallSizeBox(),
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: isAddingCustomer
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    isAddingCustomer = true;
                                                  });

                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 1), () {
                                                    if (mounted) {
                                                      setState(() {
                                                        isAddingCustomer =
                                                            false;
                                                      });
                                                    }
                                                  });

                                                  bool isOnline =
                                                      await ConnectivityService()
                                                          .isOnline();
                                                  if (!isOnline) {
                                                    setState(() {
                                                      isAddingCustomer = false;
                                                    });
                                                    showCustomToastDisplay(
                                                        context,
                                                        "You are Offline!",
                                                        red,
                                                        Icons.close);
                                                    return;
                                                  }

                                                  final fields = {
                                                    'Business Name':
                                                        bsNameController,
                                                    'Address':
                                                        addressController,
                                                    'Town': townController,
                                                    'State': stateController,
                                                    'Zip Code':
                                                        zipcodeController,
                                                    'Country':
                                                        countryController,
                                                    'Mobile Number':
                                                        phoneController,
                                                    'Email': emailController,
                                                    'Telephone':
                                                        telephoneController,
                                                    'Contact Person':
                                                        contactPersonNameController,
                                                    'Contact Number':
                                                        contactNumController,
                                                    'Delivery Address':
                                                        deliveryAddressController,
                                                    'Delivery Contact Number':
                                                        deliveryContactNumController,
                                                    'Delivery Town':
                                                        deliveryTownController,
                                                    'Delivery State':
                                                        deliveryStateController,
                                                    'Delivery Zip Code':
                                                        deliveryZipcodeController,
                                                    'Delivery Country':
                                                        deliveryCountryController,
                                                  };

                                                  // 1. Check for missing fields
                                                  for (var entry
                                                      in fields.entries) {
                                                    if (entry.value.text
                                                        .trim()
                                                        .isEmpty) {
                                                      setState(() {
                                                        isAddingCustomer =
                                                            false;
                                                      });
                                                      showCustomToastDisplay(
                                                          context,
                                                          '${entry.key} is required',
                                                          Colors.red,
                                                          Icons.close);
                                                      return;
                                                    }
                                                  }

                                                  final phoneFields = {
                                                    'Mobile Number':
                                                        phoneController,
                                                    'Contact Number':
                                                        contactNumController,
                                                    'Delivery Contact Number':
                                                        deliveryContactNumController,
                                                  };

                                                  for (var entry
                                                      in phoneFields.entries) {
                                                    final phone =
                                                        entry.value.text.trim();
                                                    if (!RegExp(r'^\d{10}$')
                                                        .hasMatch(phone)) {
                                                      setState(() {
                                                        isAddingCustomer =
                                                            false;
                                                      });
                                                      showCustomToastDisplay(
                                                          context,
                                                          '${entry.key} must be 10 digits',
                                                          Colors.red,
                                                          Icons.close);
                                                      return;
                                                    }
                                                  }

                                                  final email = emailController
                                                      .text
                                                      .trim();
                                                  final emailRegex = RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                                  if (!emailRegex
                                                      .hasMatch(email)) {
                                                    setState(() {
                                                      isAddingCustomer = false;
                                                    });
                                                    showCustomToastDisplay(
                                                        context,
                                                        'Invalid Email format',
                                                        Colors.red,
                                                        Icons.close);
                                                    return;
                                                  }

                                                  if (provider.imageFile !=
                                                      null) {
                                                    bool isValid =
                                                        await isFileSizeWithinLimit(
                                                            provider
                                                                .imageFile!);
                                                    if (!isValid) {
                                                      setState(() {
                                                        isAddingCustomer =
                                                            false;
                                                      });
                                                      showCustomToastDisplay(
                                                          context,
                                                          'File exceeds 1MB.',
                                                          red,
                                                          Icons.close);
                                                      return;
                                                    }
                                                  }

                                                  Map<String, dynamic> data = {
                                                    "userid": SessionHelper
                                                            .loginSavedData
                                                            ?.salesmanId ??
                                                        '',
                                                    "salesman_id": SessionHelper
                                                            .loginSavedData
                                                            ?.salesmanId ??
                                                        '',
                                                    "businessname":
                                                        bsNameController.text
                                                            .trim(),
                                                    "address": addressController
                                                        .text
                                                        .trim(),
                                                    "town": townController.text
                                                        .trim(),
                                                    "state": stateController
                                                        .text
                                                        .trim(),
                                                    "zipcode": int.tryParse(
                                                            zipcodeController
                                                                .text
                                                                .trim()) ??
                                                        0,
                                                    "country": countryController
                                                        .text
                                                        .trim(),
                                                    "mobileno": int.tryParse(
                                                            phoneController.text
                                                                .trim()) ??
                                                        0,
                                                    "email": emailController
                                                            .text
                                                            .trim()
                                                            .isNotEmpty
                                                        ? emailController.text
                                                            .trim()
                                                        : "N/A",
                                                    "tfn": int.tryParse(
                                                            telephoneController
                                                                .text
                                                                .trim()) ??
                                                        0,
                                                    "fullname":
                                                        contactPersonNameController
                                                            .text
                                                            .trim(),
                                                    "businesscontact": int.tryParse(
                                                            contactNumController
                                                                .text
                                                                .trim()) ??
                                                        0,
                                                    "delivery_address":
                                                        deliveryAddressController
                                                            .text
                                                            .trim(),
                                                    "delivery_contact":
                                                        int.tryParse(
                                                                deliveryContactNumController
                                                                    .text
                                                                    .trim()) ??
                                                            0,
                                                    "delivery_town":
                                                        deliveryTownController
                                                            .text
                                                            .trim(),
                                                    "delivery_state":
                                                        deliveryStateController
                                                            .text
                                                            .trim(),
                                                    "delivery_zipcode":
                                                        int.tryParse(
                                                                deliveryZipcodeController
                                                                    .text
                                                                    .trim()) ??
                                                            0,
                                                    "deliverycountry":
                                                        deliveryCountryController
                                                            .text
                                                            .trim(),
                                                    "remark": remarkController
                                                        .text
                                                        .trim(),
                                                    "status_type": 1,
                                                    "company_id": SessionHelper
                                                            .loginSavedData
                                                            ?.company_id ??
                                                        0,
                                                  };

                                                  try {
                                                    await provider.addCustomer(
                                                      admin: data,
                                                      salsmanId: '',
                                                    );

                                                    provider
                                                        .handlePaginationClick(
                                                            1);
                                                    fetchAllCustomerPages(
                                                        context);
                                                    if (context.mounted) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  } catch (error) {
                                                    if (context.mounted) {
                                                      String errMsg =
                                                          error.toString();

                                                      final regex = RegExp(
                                                          r'"message"\s*:\s*"([^"]+)"');
                                                      final match = regex
                                                          .firstMatch(errMsg);
                                                      if (match != null &&
                                                          match.groupCount >=
                                                              1) {
                                                        errMsg =
                                                            match.group(1)!;
                                                      } else {
                                                        errMsg = errMsg
                                                            .replaceAll(
                                                                "Exception: Failed to update admin: ",
                                                                "")
                                                            .trim();
                                                        errMsg = errMsg
                                                            .replaceAll(
                                                                "Exception: ",
                                                                "")
                                                            .trim();
                                                      }

                                                      showCustomToastDisplay(
                                                          context,
                                                          errMsg,
                                                          Colors.red,
                                                          Icons.error);
                                                    }
                                                  } finally {
                                                    setState(() {
                                                      isAddingCustomer = false;
                                                    });
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                          child: isAddingCustomer
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  'Add Customer'.tr,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              text: 'Customer'.tr,
            ),
          );
        },
      );
    });
  }

  Widget buildInputField(
      TextEditingController controller, String labelText, String icon,
      {int? length}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          maxLength: length,
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            labelText: labelText,
            labelStyle: TextStyle(color: const Color(0xFF0F172A)),
            prefixIcon: filledIcon(icon),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                  color: Colors.grey.shade400, width: 1.0), // Neutral border
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Modern rounded list-item row used by the "Select Method" picker in the
  /// Add Customer dialog's image-picker. Purely presentational — the tap
  /// callback passed in is whatever the caller already wired up
  /// (camera/gallery picking), unchanged.
  Widget _selectMethodOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchAllCustomerPages(BuildContext context) async {
    final provider = Provider.of<CustomersProvider>(context, listen: false);
    final apiService = ApiService();
    List<CustomerModelxx> allCustomers = [];
    List<OrderTotalxx> allOrderTotals = [];
    List<YearsListOfAll> allYearsList = [];
    int totalPages = 1;
    int page = 1;
    try {
      // Fetch first page to get totalPages
      final firstResponse = await apiService.fetchCustomer(
        salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
        customerName: '',
        startDate: '',
        endDate: '',
        limit: 10,
        page: 1,
        valueFromDw: "Month",
        selectedRange: [DateFormat('MMMM').format(DateTime.now())],
      );
      allCustomers.addAll(firstResponse.data);
      allOrderTotals.addAll(firstResponse.orderTotal);
      allYearsList.addAll(firstResponse.yearsListOfAll);
      totalPages = firstResponse.pagination.totalPages;
      // Save first page to Hive with cacheKey
      final customerBox = Hive.box('customerBox');
      final cacheKeyFirst =
          '${SessionHelper.loginSavedData?.company_id ?? 0}_customer_list_1';
      await customerBox.put(cacheKeyFirst, firstResponse.toJson());
      // Fetch remaining pages if any
      for (page = 2; page <= totalPages; page++) {
        final response = await ApiService().fetchCustomer(
          salesmanId: SessionHelper.loginSavedData?.salesmanId ?? '',
          customerName: '',
          startDate: '',
          endDate: '',
          limit: 10,
          page: page,
          valueFromDw: "Month",
          selectedRange: [DateFormat('MMMM').format(DateTime.now())],
        );
        allCustomers.addAll(response.data);
        allOrderTotals.addAll(response.orderTotal);
        allYearsList.addAll(response.yearsListOfAll);
        final cacheKey =
            '${SessionHelper.loginSavedData?.company_id ?? 0}_customer_list_$page';
        await customerBox.put(cacheKey, response.toJson());
      }
      provider.setCustomers(allCustomers, totalPages);
      provider.setOrderTotal(allOrderTotals);
      provider.setYearList(allYearsList);

      final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
      ApiWorker().cacheSyncImages(companyId);
    } catch (e) {
      print("Error fetching customer pages: $e. Falling back to local cache.");
      try {
        final loginController = Get.find<LoginController>();
        await loginController.loadAllCachedCustomerPages(context);
      } catch (_) {}
    }
  }
}

class TopTotalWidget extends StatelessWidget {
  const TopTotalWidget({
    super.key,
    required ScrollController scrollController,
    required this.provider,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final CustomersProvider provider;

  @override
  Widget build(BuildContext context) {
    final searchController = provider.searchController;
    final CustomerAndOrderController customerAndOrderController =
        CustomerAndOrderController();
    SubscriptionController subscriptionController =
        Get.find<SubscriptionController>();
    double totalTableWidth =
        120 + 140 + 140 + 140 + 140 + 140 + 140 + 140 + 160;
    // Header is painted as a single continuous gradient bar spanning both
    // the frozen search column and the scrollable header cells (instead of
    // two separate gradient/color boxes side by side), matching the
    // lead_bottom_screen / sales_return pattern and avoiding a visible
    // seam at the frozen/scrollable boundary.
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF2D3748)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: _buildTableHeader(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      onChanged: (query) {
                        provider.updateSearchQuery(query);
                      },
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontFamily: fontFamilyName,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.search,
                            size: 18, color: Colors.grey),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 36, minHeight: 38),
                        hintText: 'Customer...'.tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14.5,
                          fontFamily: fontFamilyName,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(right: 10),
                      ),
                    ),
                  ),
                ),
              ),
              300,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: SizedBox(
                width: totalTableWidth,
                child: Row(
                  children: [
                    _buildTableHeader(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sales'.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: fontFamilyName,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 6),
                          Obx(() {
                            // Build unique list of years first
                            customerAndOrderController.years.value = provider
                                .yearsListOfAllList
                                .map((yearItem) =>
                                    yearItem.orderYears?.toString() ?? '')
                                .where((year) => year.isNotEmpty)
                                .toSet()
                                .toList();

                            // Set selected year only if present in the list, otherwise default to first
                            if (customerAndOrderController.years.isNotEmpty) {
                              if (!customerAndOrderController.years.contains(
                                  customerAndOrderController
                                      .selectedYear.value)) {
                                customerAndOrderController.selectedYear.value =
                                    customerAndOrderController.years.first;
                              }
                            } else {
                              customerAndOrderController.selectedYear.value =
                                  '';
                            }

                            return Container(
                              height: 28,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (subscriptionController
                                          .customerYearComparison.value !=
                                      'true') {
                                    showUpgradePlanDialog(context);
                                  }
                                },
                                child: AbsorbPointer(
                                  absorbing: subscriptionController
                                          .customerYearComparison.value !=
                                      'true',
                                  child: DropdownButton<String>(
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        size: 14, color: Colors.black87),
                                    iconSize: 14,
                                    value: customerAndOrderController
                                            .selectedYear.value.isNotEmpty
                                        ? customerAndOrderController
                                            .selectedYear.value
                                        : null,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        customerAndOrderController
                                            .updateSelectedYear(newValue);
                                      }
                                    },
                                    items: customerAndOrderController.years
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: fontFamilyName,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    dropdownColor: Colors.white,
                                    isExpanded: false,
                                    underline: const SizedBox(),
                                  ),
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                      120,
                    ),
                    _buildTableHeader(
                      Text(
                        'Sales'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      120,
                    ),
                    _buildTableHeader(
                      Text(
                        'Deliveries'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      140,
                    ),
                    _buildTableHeader(
                      Text(
                        'Payments'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      140,
                    ),
                    _buildTableHeader(
                      Text(
                        'Bookings'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      140,
                    ),
                    _buildTableHeader(
                      Text(
                        'Estimates'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      140,
                    ),
                    _buildTableHeader(
                      Text(
                        'Drafts'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      140,
                    ),
                    _buildTableHeader(
                      Text(
                        'Cancelled'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      140,
                    ),
                    _buildTableHeader(
                      Text(
                        'Visit'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamilyName,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      180,
                      showBorder: false,
                    ),
                    // _buildTableHeader(
                    //   const Center(
                    //     child: Text(
                    //       'Staff',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontFamily: 'Poppins_Regular',
                    //       ),
                    //     ),
                    //   ),
                    //   120,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class BottomTotalWidget extends StatefulWidget {
  const BottomTotalWidget({
    super.key,
    required ScrollController scrollController,
    required this.provider,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final CustomersProvider provider;

  @override
  State<BottomTotalWidget> createState() => _BottomTotalWidgetState();
}

class _BottomTotalWidgetState extends State<BottomTotalWidget> {
  bool isOnline = false;

  bool isOfflineAndSearch = false;

  void loadOnineAndSearchState() async {
    isOnline = await ConnectivityService().isOnline();

    if (!isOnline && widget.provider.searchCustomerName.isNotEmpty) {
      isOfflineAndSearch = true;
    } else {
      isOfflineAndSearch = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void loadOnineAndSearchStateWithProvider(CustomersProvider provider) async {
    isOnline = await ConnectivityService().isOnline();

    if (!isOnline && provider.searchCustomerName.isNotEmpty) {
      isOfflineAndSearch = true;
    } else {
      isOfflineAndSearch = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadOnineAndSearchState();
  }

  @override
  void didUpdateWidget(BottomTotalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state when provider changes (e.g., when search is performed)
    loadOnineAndSearchState();
  }

  List<dynamic> _buildPagination(int currentPage, int totalPages) {
    List<dynamic> pages = [];

    if (totalPages <= 5) {
      if (currentPage == 1 && totalPages == 5) {
        pages.addAll([1, 2, 3, '...5']);
        return pages;
      }

      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
      return pages;
    }

    if (currentPage <= 2) {
      pages.addAll([1, 2, 3, '...$totalPages']);
    } else if (currentPage == 3) {
      pages.addAll([1, 2, 3, 4, '...$totalPages']);
    } else if (currentPage == totalPages - 2) {
      pages.add('1...');
      pages
          .addAll([totalPages - 3, totalPages - 2, totalPages - 1, totalPages]);
    } else if (currentPage >= totalPages - 1) {
      pages.add('1...');
      pages.addAll([totalPages - 2, totalPages - 1, totalPages]);
    } else {
      pages.add('1...');
      pages.addAll(
          [currentPage - 1, currentPage, currentPage + 1, '...$totalPages']);
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        // Update state when provider changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadOnineAndSearchStateWithProvider(provider);
        });

        if (provider.orderTotalList.isEmpty ||
            provider.orderTotalList.length < 7) {
          return const LoadingToNoDataWidget();
        }
        return Column(
          children: [
            Row(
              children: [
                _buildTableCell(
                  padding: EdgeInsets.zero,
                  Container(
                    width: 260,
                    color: const Color(0xFFF8FAFC),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              // Remove fixed width
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryColor, Color(0xFF2D3748)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: provider.currentPage > 1
                                          ? () {
                                              provider.handlePaginationClick(
                                                  provider.currentPage - 1);
                                            }
                                          : null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: const Icon(
                                          Icons.keyboard_double_arrow_left,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Wrap(
                                        alignment: WrapAlignment.spaceAround,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 4.0,
                                        runSpacing: 4.0,
                                        children: _buildPagination(
                                                provider.currentPage,
                                                provider.totalPages)
                                            .map<Widget>((item) {
                                          if (item is String &&
                                              item.endsWith('...')) {
                                            final int page = int.parse(
                                                item.replaceAll('...', ''));
                                            return GestureDetector(
                                              onTap: () {
                                                provider.handlePaginationClick(
                                                    page);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins_Regular',
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (item is String &&
                                              item.startsWith('...')) {
                                            final int page = int.parse(
                                                item.replaceAll('...', ''));
                                            return GestureDetector(
                                              onTap: () {
                                                provider.handlePaginationClick(
                                                    page);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins_Regular',
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (item is int) {
                                            final bool isCurrent =
                                                item == provider.currentPage;
                                            return GestureDetector(
                                              onTap: isCurrent
                                                  ? null
                                                  : () {
                                                      provider
                                                          .handlePaginationClick(
                                                              item);
                                                    },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isCurrent
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '$item',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Poppins_Regular',
                                                    fontSize: 13,
                                                    color: isCurrent
                                                        ? primaryColor
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }).toList(),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: provider.currentPage <
                                              provider.totalPages
                                          ? () {
                                              provider.handlePaginationClick(
                                                  provider.currentPage + 1);
                                            }
                                          : null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: const Icon(
                                          Icons.keyboard_double_arrow_right,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const Spacer(),
                        const SizedBox(width: 10),
                        Container(
                          color: const Color(0xFFF8FAFC),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Total'.tr,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                  300,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: widget._scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildTableCell(
                                Center(
                                  child: Text(
                                      formatAmount(isOfflineAndSearch
                                          ? provider.customers.fold(
                                              0.0,
                                              (sum, item) =>
                                                  sum +
                                                  num.parse(item
                                                      .previousYearSales
                                                      .toString()))
                                          : provider.orderTotalList[7]
                                              .previousYearSale),
                                      style: const TextStyle(
                                          fontFamily: "BarlowCondensed",
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                ),
                                120,
                              ),
                              _buildTableCell(
                                const SizedBox.shrink(),
                                20,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(item.totalSales
                                                        .toString()))
                                            : provider.orderTotalList[0].sales),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(item.deliveryPrice
                                                        .toString()))
                                            : provider
                                                .orderTotalList[1].delivery),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(item.paymentPrice
                                                        .toString()))
                                            : provider
                                                .orderTotalList[2].payment),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(
                                                      item.orderData.preOrder
                                                          .takeLast(item
                                                              .preOrder
                                                              .toInt())
                                                          .fold(
                                                              0.0,
                                                              (a, b) =>
                                                                  a +
                                                                  b.orderTotal)
                                                          .toString(),
                                                    ))
                                            : provider
                                                .orderTotalList[4].preOrder),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(item
                                                        .estimatesPrice
                                                        .toString()))
                                            : provider
                                                .orderTotalList[3].estimate),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(
                                                      item.orderData.draft
                                                          .takeLast(item.drafts
                                                              .toInt())
                                                          .fold(
                                                              0.0,
                                                              (a, b) =>
                                                                  a +
                                                                  b.orderTotal)
                                                          .toString(),
                                                    ))
                                            : provider.orderTotalList[5].draft),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        formatAmount(isOfflineAndSearch
                                            ? provider.customers.fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    num.parse(item
                                                        .orderData.cancel
                                                        .takeLast(item.cancelled
                                                            .toInt())
                                                        .fold(
                                                            0.0,
                                                            (a, b) =>
                                                                a +
                                                                b.orderTotal)
                                                        .toString()))
                                            : provider
                                                .orderTotalList[6].cancelled),
                                        style: const TextStyle(
                                            fontFamily: "BarlowCondensed",
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                140,
                              ),
                              _buildTableCell(
                                const Text(
                                  '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                160,
                              ),
                              // _buildTableCell(
                              //   const Text(
                              //     '',
                              //     style: TextStyle(
                              //       fontWeight: FontWeight.w600,
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              //   120,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CustomHorizontalScrollbar(
              controller: widget._scrollController,
              thumbColor: Colors.blue,
            )
          ],
        );
      },
    );
  }
}

class FrozenHeaderTable extends StatefulWidget {
  final ScrollController scrollController;

  const FrozenHeaderTable({required this.scrollController, super.key});

  @override
  State<FrozenHeaderTable> createState() => _FrozenHeaderTableState();
}

class _FrozenHeaderTableState extends State<FrozenHeaderTable> {
  final CustomerAndOrderController customerAndOrderController =
      Get.put(CustomerAndOrderController());
  final StaffController staffController = Get.put(StaffController());
  final LeadsController leadsController = Get.put(LeadsController());
  final ProductsController prodController = Get.find<ProductsController>();
  final subscriptionController = Get.find<SubscriptionController>();

  String? startDate;
  String? endDate;
  String dropdownValue = 'Today';

  final ScrollController vertical = ScrollController();
  final ScrollController vertical1 = ScrollController();

  late LinkedScrollControllerGroup _controllers;

  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;

  @override
  void initState() {
    super.initState();

    _controllers = LinkedScrollControllerGroup();

    // SET 1
    _scrollController1 = _controllers.addAndGet();
    _scrollController2 = _controllers.addAndGet();
    _scrollController3 = _controllers.addAndGet();

    vertical.addListener(() {
      if (vertical.hasClients &&
          vertical1.hasClients &&
          vertical.position.pixels != vertical1.position.pixels) {
        vertical1.jumpTo(vertical.position.pixels);
      }
    });

    vertical1.addListener(() {
      if (vertical1.hasClients &&
          vertical.hasClients &&
          vertical1.position.pixels != vertical.position.pixels) {
        vertical.jumpTo(vertical1.position.pixels);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double totalTableWidth =
        120 + 140 + 140 + 140 + 140 + 140 + 140 + 140 + 160;

    double fixedRowHeight = isLandscape
        ? !isTablet(context)
            ? fullScreenHeight(context) / 6
            : fullScreenHeight(context) / 9.05
        : isPhonePortrait(context)
            ? (fullScreenHeight(context) - (66 * 3)) / 11.1
            : (fullScreenHeight(context) - (66 * 3)) / 11.5;

    return Consumer<CustomersProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(
            child: CircularProgressIndicator(color: primaryColor));
      } else if (provider.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            provider.errorMessage.endsWith("Failed to load data")
                ? "NO CUSTOMERS FOUND"
                : provider.errorMessage.contains("No element")
                    ? "NO CUSTOMERS FOUND"
                    : provider.errorMessage,
          ),
        );
      } else if (provider.currentPageCustomers.isEmpty) {
        return const Center(child: Text('No customers found'));
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: vertical,
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 58.0),
                        child: Column(
                          children: List.generate(
                            provider.currentPageCustomers.length,
                            (index) {
                              var customer =
                                  provider.currentPageCustomers[index];
                              return Container(
                                height: fixedRowHeight,
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? const Color(0xFFF8FAFC)
                                      : Colors.white,
                                  border: const Border(
                                    bottom: BorderSide(
                                        color: Color(0xFFE2E8F0), width: 0.6),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                color: Colors.grey[200],
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      '${ApiConstants.imageBaseUrl}/${customer.imageUrl}',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Padding(
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    child: CircleAvatar(
                                                        radius: 10,
                                                        child:
                                                            CircularProgressIndicator()),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.grey,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () async {
                                                  if (subscriptionController
                                                          .customerDashboardView
                                                          .value ==
                                                      'true') {
                                                    bool shouldNavigate = true;
                                                    // CHECKOUT CONDITIONS
                                                    if (customerAndOrderController
                                                            .isActive.value &&
                                                        (customerAndOrderController
                                                                    .customerId
                                                                    .value !=
                                                                '' ||
                                                            customerAndOrderController
                                                                    .customerId
                                                                    .value !=
                                                                null) &&
                                                        (customerAndOrderController
                                                                .customerId
                                                                .value !=
                                                            customer
                                                                .customerId)) {
                                                      shouldNavigate =
                                                          await checkCustomerOut(
                                                              customerAndOrderController
                                                                  .selectedCustomerName
                                                                  .value);
                                                    } else {
                                                      shouldNavigate = true;
                                                    }

                                                    if (shouldNavigate) {
                                                      provider
                                                          .setCurrentMonthDates();
                                                      provider
                                                          .fetchCustomerDashboardData(
                                                        customer.customerId,
                                                      );
                                                      provider
                                                          .fetchCustomerDashboardRevenueData(
                                                        customer.customerId,
                                                      );
                                                      provider
                                                          .fetchCustomerDashboardCountData(
                                                              customer
                                                                  .customerId);
                                                      prodController
                                                              .selectedCustomerName
                                                              .value =
                                                          customer.businessName;
                                                      prodController
                                                          .selectedCustomerEmail
                                                          .value = customer.email;
                                                      prodController
                                                              .selectedCustomerMobileNo
                                                              .value =
                                                          customer.mobileno;
                                                      prodController
                                                              .selectedCustomerId
                                                              .value =
                                                          customer.customerId;
                                                      prodController
                                                              .selectedCustomerImageUrl
                                                              .value =
                                                          customer.imageUrl;
                                                      customerAndOrderController
                                                          .setCustomerId(
                                                              customer
                                                                  .customerId);
                                                      customerAndOrderController
                                                              .selectedCustomerName
                                                              .value =
                                                          customer.businessName;
                                                      customerAndOrderController
                                                              .selectedCustomerImage
                                                              .value =
                                                          customer.imageUrl;
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  100));
                                                      final dashProvider = Provider
                                                          .of<DashboardProvider>(
                                                              context,
                                                              listen: false);

                                                      int globalSelectedYear =
                                                          dashProvider.selectedYear !=
                                                                  0
                                                              ? dashProvider
                                                                  .selectedYear
                                                              : DateTime.now()
                                                                  .year;

                                                      if (customerAndOrderController
                                                              .selectedYear
                                                              .value
                                                              .isNotEmpty &&
                                                          customerAndOrderController
                                                                  .selectedYear
                                                                  .value !=
                                                              DateTime.now()
                                                                  .year
                                                                  .toString()) {
                                                        globalSelectedYear = int.tryParse(
                                                                customerAndOrderController
                                                                    .selectedYear
                                                                    .value) ??
                                                            globalSelectedYear;
                                                      }

                                                      final dateFormat =
                                                          DateFormat(
                                                              'yyyy-MM-dd');
                                                      final firstDayOfYear =
                                                          DateTime(
                                                              globalSelectedYear,
                                                              1,
                                                              1);
                                                      final lastDayOfYear =
                                                          DateTime(
                                                              globalSelectedYear,
                                                              12,
                                                              31);

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerDachScreen(
                                                            year:
                                                                globalSelectedYear, // <-- This will correctly pass 2025!
                                                            startDate: dateFormat
                                                                .format(
                                                                    firstDayOfYear),
                                                            endDate: dateFormat
                                                                .format(
                                                                    lastDayOfYear),
                                                            isFromOrder: true,
                                                            cusId: customer
                                                                .customerId,
                                                            cusName: customer
                                                                .businessName,
                                                            cusImage: customer
                                                                .imageUrl,
                                                            cusEmail:
                                                                customer.email,
                                                            cusMobile: customer
                                                                .mobileno,
                                                            productsController:
                                                                prodController,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    showUpgradePlanDialog(
                                                        context);
                                                  }
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      customer.businessName,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      customer.town,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      customer.email,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: widget.scrollController,
                child: SizedBox(
                  width: totalTableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          controller: vertical1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 58),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.currentPageCustomers.length,
                              itemBuilder: (context, index) {
                                var customer =
                                    provider.currentPageCustomers[index];

                                return Container(
                                  height: fixedRowHeight,
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? const Color(0xFFF8FAFC)
                                        : Colors.white,
                                    border: const Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFE2E8F0), width: 0.6),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildTableCell(
                                        Center(
                                          child: InkWell(
                                            onTap: () {
                                              _showOrderDataDialog(
                                                  context,
                                                  customer,
                                                  customer.orderData
                                                      .previousYearSales,
                                                  'Previous Year');
                                            },
                                            child: CustomText(
                                              content: formatAmount(
                                                  customer.previousYearSales),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        120,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.sales == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.totalSales,
                                                      'Sales');
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.sales.toString(),
                                                  customer.totalSales
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.blue,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                print('on tappedyy');
                                                print(
                                                    'out of delivery : ${customer.orderData.outOfDiviery}');
                                                if (customer.delivery == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer.orderData
                                                          .outOfDiviery,
                                                      'Delivery');
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.delivery.toString(),
                                                  customer.deliveryPrice
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.green.shade700,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.payment == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.payment,
                                                      'Paymentyy');
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.payment.toString(),
                                                  customer.paymentPrice
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.orange,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(0.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.preOrder == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.preOrder,
                                                      'Booking');
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.preOrder.toString(),
                                                  customer.orderData.preOrder
                                                      .takeLast(customer
                                                          .preOrder
                                                          .toInt())
                                                      .fold(
                                                          0.0,
                                                          (a, b) =>
                                                              a + b.orderTotal)
                                                      .toString(),
                                                  Colors.cyan,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                        padding: EdgeInsets.zero,
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.estimates == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer
                                                          .orderData.estimate,
                                                      'Estimate');
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.estimates.toString(),
                                                  customer.estimatesPrice
                                                          ?.toString() ??
                                                      '0',
                                                  Colors.purple,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.drafts == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer.orderData.draft,
                                                      'Draft');
                                                }
                                              },
                                              child: _buildDataCell(
                                                  customer.drafts.toString(),
                                                  customer.orderData.draft
                                                      .takeLast(customer.drafts
                                                          .toInt())
                                                      .fold(
                                                          0.0,
                                                          (a, b) =>
                                                              a + b.orderTotal)
                                                      .toString(),
                                                  Colors.grey.shade700,
                                                  false),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (customer.cancelled == 0) {
                                                  showCustomToastDisplay(
                                                      context,
                                                      'Record Not Found'.tr,
                                                      red,
                                                      Icons.close);
                                                } else {
                                                  _showOrderDataDialog(
                                                      context,
                                                      customer,
                                                      customer.orderData.cancel,
                                                      "Cancelled");
                                                }
                                              },
                                              child: _buildDataCell(
                                                customer.cancelled.toString(),
                                                customer.orderData.cancel
                                                    .takeLast(customer.cancelled
                                                        .toInt())
                                                    .fold(
                                                        0.0,
                                                        (a, b) =>
                                                            a + b.orderTotal)
                                                    .toString(),
                                                Colors.red.shade600,
                                                false,
                                              ),
                                            ),
                                          ),
                                        ),
                                        140,
                                        height: fixedRowHeight,
                                        bgColor: const Color.fromRGBO(
                                                239, 240, 207, 1)
                                            .withOpacity(0.4),
                                      ),
                                      _buildTableCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          child: EventTypeDropdown(
                                            initialValue:
                                                EventTypeExtension.fromValue(
                                                    customer.eventType),
                                            onChanged: (EventType newType) {},
                                            defaultEventDays:
                                                customer.eventDays,
                                            customerId: customer.customerId,
                                            eventStatus: customer.eventType,
                                            eventPeriod: customer.eventPeriod,
                                            provider: provider,
                                          ),
                                        ),
                                        160,
                                      ),
                                      // _buildTableCell(
                                      //   Padding(
                                      //     padding:
                                      //         const EdgeInsets.all(4.0),
                                      //     child: Center(
                                      //       child: CustomText(
                                      //         content:
                                      //             customer.salesmanName,
                                      //         fontSize: 12,
                                      //       ),
                                      //     ),
                                      //   ),
                                      //   120,
                                      // ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
    });
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

  Future<bool> checkCustomerOut(String customerName) async {
    if (!customerAndOrderController.isActive.value) return true;

    bool shouldProceed = false;
    bool isCheckingOut = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actionsPadding:
                  const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                'Customer Check-Out'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              content: Text(
                '$customerName is already checked In. Do you want to Check-out?',
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                ),
              ),
              actions: [
                if (isCheckingOut)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFE2E8F0), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        shouldProceed = false;
                        Navigator.of(context).pop();
                        {
                          final cartProvider = Provider.of<CustomersProvider>(
                              context,
                              listen: false);
                          final customerId =
                              customerAndOrderController.customerId.value;
                          customerAndOrderController.setCustomerId(
                              customerAndOrderController.customerId.value);

                          prodController.selectedCustomerName.value =
                              customerAndOrderController
                                  .selectedCustomerName.value;
                          prodController.selectedCustomerImageUrl.value =
                              customerAndOrderController
                                  .selectedCustomerImage.value;

                          CartDatabaseManager().getCartItems(customerId);
                          cartProvider.getCartItemCounts(customerId);
                          CartDatabaseManager().addListener(() {
                            cartProvider.updateCartCount(customerId);
                          });

                          Get.to(
                                  ChangeNotifierProvider.value(
                                    value: Provider.of<CustomersProvider>(
                                        context,
                                        listen: false),
                                    child: OrderTaking(
                                      productsController: prodController,
                                      selectedCustId: customerAndOrderController
                                          .customerId.value,
                                      selectedCustName:
                                          customerAndOrderController
                                              .selectedCustomerName.value,
                                      selectedCustImageUrl:
                                          customerAndOrderController
                                              .selectedCustomerImage.value,
                                    ),
                                  ),
                                  id: 2)
                              ?.then((value) {
                            cartProvider
                                .fetchCustomerDashboardCountData(customerId);
                          });
                        }
                      },
                      child: Text(
                        'Stay'.tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 210,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF727CF5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
                            prodController.selectedCustomerId.value;

                        try {
                          final position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                          );
                          final lat = position.latitude.toString();
                          final long = position.longitude.toString();

                          final isOnline =
                              await ConnectivityService().isOnline();

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
                            customerAndOrderController.isActive.value = false;
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
                              customerAndOrderController.isActive.value = false;
                              shouldProceed = true;
                            }
                          }
                        } catch (e) {}

                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Text(
                        'Check-out and Proceed'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: Color(0xFF727CF5),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
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

  Widget _buildStatusBadge(int? orderStatus, String text) {
    final status = OrderHandlingClass.fromType(orderStatus ?? 0);
    final Color bg = status.statusBgColor;
    final Color textColor = status.statusTextColor;
    final Color dotColor = status.statusDotColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dotColor.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text.tr,
            style: TextStyle(
              fontFamily: 'Poppins_Regular',
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState(
      String title, String subtitle, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title.tr,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle.tr,
            style: const TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 12.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOrderDataDialog(BuildContext context, CustomerModelxx customer,
      List<Order> filteredOrders, String orderType) {
    final ScrollController verticalScrollController = ScrollController();
    final ScrollController horizontalScrollController = ScrollController();

    final double totalSum = filteredOrders.fold<double>(
      0.0,
      (sum, order) => sum + (order.orderTotal),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: screenHeight * 0.88,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Color(0xFF2D3748)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shopping_cart_outlined,
                                  color: Colors.white, size: 17),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$orderType ${'List'.tr}',
                              style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.35)),
                              ),
                              child: Text(
                                '${filteredOrders.length} ${'Records'.tr}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins_Regular',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 17),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- BODY ---
                  if (filteredOrders.isEmpty)
                    _buildModernEmptyState(
                        'No Orders Found',
                        'There are no records found for this customer.',
                        context)
                  else
                    Flexible(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Scrollbar(
                            controller: verticalScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            radius: const Radius.circular(8),
                            thickness: 6,
                            notificationPredicate: (notif) =>
                                notif.metrics.axis == Axis.vertical,
                            child: Scrollbar(
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              radius: const Radius.circular(8),
                              thickness: 6,
                              notificationPredicate: (notif) =>
                                  notif.metrics.axis == Axis.horizontal,
                              child: SingleChildScrollView(
                                controller: verticalScrollController,
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  controller: horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(
                                          const Color(0xFFF1F5F9)),
                                      headingTextStyle: const TextStyle(
                                        fontFamily: 'Poppins_Regular',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: 0.3,
                                      ),
                                      dataRowMinHeight: 56,
                                      dataRowMaxHeight: 68,
                                      columnSpacing: 14,
                                      horizontalMargin: 16,
                                      columns: [
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Customer'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Order #'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Date'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Sales Rep'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Amount'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Invoice'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Payment'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Status'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                        DataColumn(
                                            headingRowAlignment:
                                                MainAxisAlignment.center,
                                            label: Center(
                                                child: Text('Action',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Color(
                                                            0xFF0F172A))))),
                                      ],
                                      rows: filteredOrders.map((order) {
                                        return DataRow(
                                          cells: [
                                            // Customer Info
                                            DataCell(
                                              Center(
                                                child: SizedBox(
                                                  width: 140,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 14,
                                                        backgroundColor:
                                                            const Color(
                                                                0xFFEEF2FF),
                                                        child: const Icon(
                                                            Icons.person,
                                                            size: 15,
                                                            color:
                                                                primaryColor),
                                                      ),
                                                      const SizedBox(width: 7),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              customer.businessName
                                                                      .isNotEmpty
                                                                  ? customer
                                                                      .businessName
                                                                  : 'N/A',
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins_Regular',
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (customer
                                                                .fullname
                                                                .isNotEmpty)
                                                              Text(
                                                                customer
                                                                    .fullname,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Poppins_Regular',
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .black87),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            if (customer
                                                                .mobileno
                                                                .isNotEmpty)
                                                              Text(
                                                                customer
                                                                    .mobileno,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Poppins_Regular',
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black87),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Order No
                                            DataCell(
                                              Center(
                                                child: InkWell(
                                                  onTap: () async {
                                                    bool isOnline =
                                                        await ConnectivityService()
                                                            .isOnline();
                                                    if (isOnline) {
                                                      showDetailedOrderInvoiceDialog(
                                                          context,
                                                          order.orderId,
                                                          false);
                                                    } else {
                                                      showCustomToastDisplay(
                                                          context,
                                                          'You are Offline!'.tr,
                                                          red,
                                                          Icons.warning);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: primaryColor
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                    child: Text(
                                                      order.orderId,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        color: primaryColor,
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Date
                                            DataCell(
                                              Center(
                                                child: Text(
                                                  order.orderCreatAt != null &&
                                                          order.orderCreatAt
                                                              .toString()
                                                              .isNotEmpty
                                                      ? TimeUtils.formatTimeInZone(
                                                          DateTime.tryParse(order
                                                                  .orderCreatAt
                                                                  .toString()) ??
                                                              DateTime.now(),
                                                          format: 'dd-MM-yyyy')
                                                      : 'N/A',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins_Regular',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            // Sales Rep
                                            DataCell(
                                              Center(
                                                child: SizedBox(
                                                  width: 90,
                                                  child: Text(
                                                    '${order.fullname?.nkStringCapitalizeFirstCaracter ?? ""} ${order.lastname ?? ""}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins_Regular',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Amount
                                            DataCell(
                                              Center(
                                                child: Text(
                                                  formatAmount(
                                                      order.orderTotal),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins_Regular',
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            // Invoice
                                            DataCell(
                                              Center(
                                                child: InkWell(
                                                  onTap: () async {
                                                    bool isOnline =
                                                        await ConnectivityService()
                                                            .isOnline();
                                                    if (order.invoiceId !=
                                                            null &&
                                                        order.invoiceId
                                                            .toString()
                                                            .isNotEmpty &&
                                                        order.invoiceId !=
                                                            'null') {
                                                      if (isOnline) {
                                                        showDetailedOrderInvoiceDialog(
                                                            context,
                                                            order.orderId,
                                                            false);
                                                      } else {
                                                        showCustomToastDisplay(
                                                            context,
                                                            'You are Offline!'
                                                                .tr,
                                                            red,
                                                            Icons.warning);
                                                      }
                                                    }
                                                  },
                                                  child: Text(
                                                    order.invoiceId == null ||
                                                            order.invoiceId
                                                                .toString()
                                                                .isEmpty ||
                                                            order.invoiceId ==
                                                                'null'
                                                        ? '-'
                                                        : order.invoiceId
                                                            .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Poppins_Regular',
                                                      color: (order.invoiceId ==
                                                                  null ||
                                                              order.invoiceId
                                                                  .toString()
                                                                  .isEmpty ||
                                                              order.invoiceId ==
                                                                  'null')
                                                          ? Colors.black54
                                                          : primaryColor,
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Payment Status
                                            DataCell(
                                              Center(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7,
                                                      vertical: 2.5),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        order.paymentStatus == 0
                                                            ? const Color(
                                                                0xFFFEE2E2)
                                                            : const Color(
                                                                0xFFDCFCE7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color:
                                                          order.paymentStatus ==
                                                                  0
                                                              ? const Color(
                                                                  0xFFEF4444)
                                                              : const Color(
                                                                  0xFF10B981),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    order.paymentStatus == 0
                                                        ? 'Pending'.tr
                                                        : 'Paid'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Poppins_Regular',
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          order.paymentStatus ==
                                                                  0
                                                              ? const Color(
                                                                  0xFF991B1B)
                                                              : const Color(
                                                                  0xFF065F46),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Status Badge
                                            DataCell(
                                              Center(
                                                child: _buildStatusBadge(
                                                    order.orderStatus
                                                            ?.toInt() ??
                                                        0,
                                                    getStatusName(order
                                                            .orderStatus
                                                            ?.toInt() ??
                                                        0)),
                                              ),
                                            ),
                                            // Action Icon
                                            DataCell(
                                              Center(
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                          minWidth: 32,
                                                          minHeight: 32),
                                                  icon: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEEF2FF),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: primaryColor
                                                              .withOpacity(
                                                                  0.2)),
                                                    ),
                                                    child: const Icon(
                                                        Icons
                                                            .visibility_outlined,
                                                        size: 15,
                                                        color: primaryColor),
                                                  ),
                                                  onPressed: () async {
                                                    bool isOnline =
                                                        await ConnectivityService()
                                                            .isOnline();
                                                    if (isOnline) {
                                                      showDetailedOrderInvoiceDialog(
                                                          context,
                                                          order.orderId,
                                                          false);
                                                    } else {
                                                      showCustomToastDisplay(
                                                          context,
                                                          'You are Offline!'.tr,
                                                          red,
                                                          Icons.warning);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // --- FOOTER ---
                  if (filteredOrders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        border:
                            Border(top: BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${'Showing'.tr} ${filteredOrders.length} ${'Orders'.tr}',
                            style: const TextStyle(
                                fontFamily: 'Poppins_Regular',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${'Total'.tr}: ',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                                Text(
                                  formatAmount(totalSum),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildTableHeader(Widget child, double width, {bool showBorder = true}) {
  // Background is intentionally transparent: the whole header row (frozen
  // search column + scrollable columns) is painted by a single gradient
  // Container in TopTotalWidget so the gradient reads as one continuous bar
  // instead of a seam at each cell's edge.
  return Container(
    height: 54,
    width: width,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: showBorder
          ? Border(
              right: BorderSide(
                color: Colors.white.withOpacity(0.18),
                width: 0.8,
              ),
            )
          : null,
    ),
    child: child,
  );
}

Widget _buildTableCell(Widget child, double width,
    {EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    Color bgColor = Colors.transparent,
    double height = 58}) {
  return Container(
    color: bgColor,
    height: height,
    width: width,
    padding: padding,
    child: child,
  );
}

Widget _buildDataCell(String count, String amount, Color color, bool isCenter) {
  return Row(
    mainAxisAlignment:
        isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomText(
            content: count,
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: 4),
      Flexible(
        child: CustomText(
          content: formatAmount(amount),
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) => skip(length - n).toList();
}
