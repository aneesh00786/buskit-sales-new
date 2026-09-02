import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/custom_scrollbar.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_retrun_daypicker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_return_month_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_return_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_return_rangepicker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_return_week_dropdown.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_return_year_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class SalesReturn extends StatefulWidget {
  const SalesReturn({super.key});

  @override
  State<SalesReturn> createState() => _SalesReturnState();
}

class _SalesReturnState extends State<SalesReturn> {
  SalesReturnController salesReturnController =
      Get.find<SalesReturnController>();

  final TextEditingController _customerSearchCtrl = TextEditingController();
  final TextEditingController _orderORIdSearchCtrl = TextEditingController();

  // LinkedScrollControllerGroup forwards the user's drag delta to every
  // linked controller directly, instead of reacting to a finished position
  // change with jumpTo() — the previous jumpTo-based approach could fight an
  // in-progress drag/fling on the other controller and made the table feel
  // like it randomly stopped responding to scroll input. Mirrors the fix
  // applied to lead_bottom_screen.dart.
  late final LinkedScrollControllerGroup _verticalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController vertical = _verticalGroup.addAndGet();
  late final ScrollController vertical1 = _verticalGroup.addAndGet();

  // Keeps the scrollable header row moving in sync with the scrollable body
  // rows underneath it, the same way Pending Payments/Leads do — the header
  // is drawn once as a single full-width gradient bar overlaid on top of the
  // body, instead of two separate gradient boxes side by side (which
  // produced a visible seam).
  late final LinkedScrollControllerGroup _horizontalGroup =
      LinkedScrollControllerGroup();
  late final ScrollController headerHorizontal = _horizontalGroup.addAndGet();
  late final ScrollController bodyHorizontal = _horizontalGroup.addAndGet();

  @override
  void initState() {
    super.initState();

    salesReturnController.selectedFilter.value = FilterDateEnum.thisMonth;
    initializeData();
  }

  @override
  void dispose() {
    vertical.dispose();
    vertical1.dispose();
    headerHorizontal.dispose();
    bodyHorizontal.dispose();
    super.dispose();
  }

  void initializeData() async {
    bool isOnline = await ConnectivityService().isOnline();
    if (!isOnline) {
      if (mounted) {
        showCustomToastDisplay(
            context, "You are Offline!", Colors.red, Icons.close);
      }
      return;
    }

    if (mounted) {
      setState(() {});
    }

    await salesReturnController.updateSalesReturnList();

    log("Sales Return Response: ${salesReturnController.salesReturnList.length} items loaded");
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double fixedRowHeight = isLandscape
        ? isTablet(context)
            ? MediaQuery.of(context).size.height / 10.09
            : MediaQuery.of(context).size.height / 5.09
        : MediaQuery.of(context).size.height / 10 -
            MediaQuery.of(context).size.height * 0.024;

    final isMobile = ResponsiveInfo.isMobile();
    final isSmallMobile = ResponsiveInfo.isSmallMobile();

    final double cardPadding = isSmallMobile ? 10 : 20;
    final double fieldWidth = isMobile ? double.infinity : 200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Sales Return'.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    )),
                const Spacer(),
                const NotificationWidget(
                  startDate: '',
                  endDate: '',
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: profiloe(),
                )
              ],
            ),
          SizedBox(
            width: isPhonePortrait(context)
                ? fullScreenWidth(context) * 2.3
                : fullScreenWidth(context) > 640
                    ? fullScreenWidth(context) * 1
                    : fullScreenWidth(context) * 1.1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              _buildFilters(context, fieldWidth, isMobile),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children:
                              _buildFilters(context, fieldWidth, isMobile),
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyCommnonContainer(
                color: Colors.white,
                borderRadius: 16,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                child: _buildTableLayout(context, fixedRowHeight),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  List<Widget> _buildFilters(
    BuildContext context,
    double fieldWidth,
    bool isMobile,
  ) {
    // Note: We don't need the manual _startDateCtrl/_endDateCtrl here anymore
    // if we are using the Dashboard's RangePickerWidget.

    const double fieldHeight = 55.0;

    // Adjusted width for the dropdown to match Dashboard style
    final double dropdownWidth = 120.0;

    // Build the dropdown (Professional Design)
    Widget timePeriodDropdown() {
      return SizedBox(
        height: 50,
        width: dropdownWidth,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Obx(
              () => DropdownButton<FilterDateEnum>(
                value: salesReturnController.selectedFilter.value,
                onChanged: (newValue) async {
                  bool isOnline = await ConnectivityService().isOnline();
                  if (!isOnline) {
                    showCustomToastDisplay(
                        context, "You are Offline!", Colors.red, Icons.close);
                    return;
                  }

                  if (newValue != null) {
                    setState(() {
                      salesReturnController.selectedFilter.value = newValue;
                      if (newValue == FilterDateEnum.range) {
                        salesReturnController.salesReturnList.clear();
                        salesReturnController.filteredList.clear();
                      }
                    });
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: FilterDateEnum.thisMonth,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month,
                            size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Month'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins_Regular')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: FilterDateEnum.today,
                    child: Row(
                      children: [
                        Icon(Icons.today, size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Day'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins_Regular')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: FilterDateEnum.thisYear,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_view_month,
                            size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Year'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins_Regular')),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: FilterDateEnum.range,
                    child: Row(
                      children: [
                        Icon(Icons.date_range, size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Range'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins_Regular')),
                      ],
                    ),
                  ),
                ],
                isExpanded: true,
                borderRadius: BorderRadius.circular(14),
                underline: Container(),
                icon: Icon(Icons.keyboard_arrow_down,
                    size: 20, color: Colors.grey[600]),
                dropdownColor: Colors.white,
                elevation: 8,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins_Regular',
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildTimeFilterRow() {
      return Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (salesReturnController.selectedFilter.value !=
                  FilterDateEnum.range) ...[
                const SalesReturnYearDropdown(),
                const SizedBox(width: 10),
              ],
              timePeriodDropdown(),
              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.thisMonth) ...[
                const SizedBox(width: 10),
                const SalesReturnMonthDropdown()
              ],
              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.thisWeek) ...[
                const SizedBox(width: 10),
                const SalesReturnWeekDropdown() // <-- NEW WIDGET
              ],
              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.today) ...[
                const SizedBox(width: 10),
                const SalesReturnDayPicker()
              ],
              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.range) ...[
                const SizedBox(width: 10),
                const SalesReturnRangePicker()
              ],
            ],
          ));
    }

    return [
      // 1. Time Period (Dropdown + Conditional Widgets)
      _buildFilterColumn(
        title:
            CustomText(content: 'Time Period'.tr, fontWeight: FontWeight.bold),
        spacing: 10,
        child: buildTimeFilterRow(), // <--- New logic here
      ),

      // 2. Search Customer
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0),

      _buildFilterColumn(
        title: CustomText(content: 'Customer'.tr, fontWeight: FontWeight.bold),
        child: SizedBox(
          width: fieldWidth,
          height: fieldHeight,
          child: TextField(
            onChanged: (value) {
              salesReturnController.setCustomerSearch(value.trim());
            },
            controller: _customerSearchCtrl,
            style: const TextStyle(fontFamily: 'Poppins_Regular'),
            decoration: InputDecoration(
              hintText: 'Search by name...'.tr,
              hintStyle: const TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins_Regular'),
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
      ),

      // 3. Search Order/Invoice
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0),
      _buildFilterColumn(
        title: CustomText(
            content: 'Order/Invoice'.tr, fontWeight: FontWeight.bold),
        child: SizedBox(
          width: fieldWidth,
          height: fieldHeight,
          child: TextField(
            controller: _orderORIdSearchCtrl,
            onChanged: (value) {
              salesReturnController.setOrderORIdSearch(value);
            },
            style: const TextStyle(fontFamily: 'Poppins_Regular'),
            decoration: InputDecoration(
              hintText: 'Search by Order ID or Invoice ID...'.tr,
              hintStyle: const TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins_Regular'),
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
      ),

      // 4. Go Button
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 50 : 50),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: isPhonePortrait(context)
                ? 50.0
                : fullScreenWidth(context) > 640
                    ? 155.0 * (1.0 / 2.3)
                    : 155.0 * (1.1 / 2.3),
            height: fieldHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF727CF5),
                    const Color(0xFF6C757D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
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
              child: ElevatedButton(
                onPressed: () async {
                  bool isOnline = await ConnectivityService().isOnline();
                  if (!isOnline) {
                    showCustomToastDisplay(context, "You are Offline!".tr,
                        Colors.red, Icons.close);
                    return;
                  }
                  salesReturnController.currentPage.value = 1;

                  // NOTE: If using RangePickerWidget from dashboard, ensure
                  // it updates the controller or the provider correctly.
                  // If using the original logic, you might need to hook up
                  // data from those widgets here.

                  await salesReturnController.updateSalesReturnList();

                  final searchTerm = _customerSearchCtrl.text.trim();
                  final orderOrIdTerm = _orderORIdSearchCtrl.text.trim();

                  salesReturnController.setCustomerSearch(searchTerm);
                  salesReturnController.setOrderORIdSearch(orderOrIdTerm);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Go'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontFamily: 'Poppins_Regular',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2)
        ],
      ),
    ];
  }

  DateTime? _parse(String txt) {
    if (txt.isEmpty) return null;
    final parts = txt.split('/');
    if (parts.length != 3) return null;
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Widget _buildFilterColumn(
      {required Widget title, required Widget child, double spacing = 10.0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        SizedBox(height: spacing),
        child,
      ],
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildTableLayout(BuildContext context, double fixedRowHeight) {
    double totalTableWidth = 130 + 360 + 150 + 150 + 150 + 150 + 150 + 110;
    bool isArabic = Get.locale?.languageCode == 'ar';
    double slNoWidth = isArabic ? 80 : 60;
    double customerDetailsWidth = isArabic ? 220 : 240;

    const int itemsPerPage = 10;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _buildTableHeader(
                  slNoWidth, customerDetailsWidth, totalTableWidth),
              _buildTableBody(context, totalTableWidth, itemsPerPage),
            ],
          ),
        ),

        // FOOTER
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fix for footer visibility
            children: [
              Row(
                children: [
                  SalesReturnPagination(
                      salesReturnController: salesReturnController),
                ],
              ),
              const SizedBox(height: 8),
              CustomHorizontalScrollbar(
                thumbColor: Colors.blue,
                controller: bodyHorizontal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Single continuous gradient bar spanning the frozen (Sl.No/Customer
  // Details) columns and the horizontally-scrollable columns, overlaid on
  // top of the body via a Stack — avoids the visible seam that two
  // side-by-side gradient containers produced. Mirrors
  // lead_bottom_screen.dart's _buildHeader.
  Widget _buildTableHeader(
      double slNoWidth, double customerDetailsWidth, double totalTableWidth) {
    const double headerHeight = 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Container(
        width: double.infinity,
        height: headerHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, Color(0xFF2D3748)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: Row(
                children: [
                  buildSalesReturnTableHeader1(
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          // Replaced CustomText with Text to ensure overflow works
                          "Sl.No.".tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins_Regular',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow
                              .ellipsis, // Adds ... if it still overflows
                        ),
                      ),
                    ),
                    slNoWidth, // Uses dynamic width
                  ),
                  buildSalesReturnTableHeader1(
                    Padding(
                      // Better for RTL than a hardcoded SizedBox(width: 40)
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            // Forces the text to respect the parent width constraint
                            child: Text(
                              "Customer Details".tr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins_Regular',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Adds ... if text is too long
                            ),
                          ),
                        ],
                      ),
                    ),
                    customerDetailsWidth, // Uses dynamic width
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: headerHorizontal,
                primary: false,
                child: SizedBox(
                  width: totalTableWidth,
                  child: buildSalesReturnTableHeader(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableBody(
      BuildContext context, double totalTableWidth, int itemsPerPage) {
    const double headerHeight = 50;

    return Align(
      alignment: FractionalOffset.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: headerHeight),
        child: Row(
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
                      child: Obx(() {
                        final list = salesReturnController.filteredList;

                        if (list.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Center(
                              child: CustomText(
                                content: "No delivered orders found".tr,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        int currentPage =
                            salesReturnController.currentPage.value;
                        int startIndex = (currentPage - 1) * itemsPerPage;

                        var displayList = list.length > itemsPerPage
                            ? list.skip(startIndex).take(itemsPerPage).toList()
                            : list;

                        if (displayList.isEmpty && list.isNotEmpty) {
                          displayList = list.take(itemsPerPage).toList();
                          startIndex = 0;
                        }

                        return Column(
                          children: displayList.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;

                            int serialNumber = (list.length > itemsPerPage)
                                ? startIndex + index + 1
                                : index + 1;

                            return Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? const Color(0xFFF8FAFC)
                                    : Colors.white,
                                border: const Border(
                                  bottom: BorderSide(
                                      color: Color(0xFFE2E8F0), width: 0.6),
                                ),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: CustomText(
                                        content:
                                            "$serialNumber", // Use calculated Sl.No
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage:
                                              (data.imageUrl != null &&
                                                      data.imageUrl!
                                                          .trim()
                                                          .isNotEmpty)
                                                  ? NetworkImage(
                                                      "${ApiConstants.imageBaseUrl}/${data.imageUrl!.trim()}",
                                                    )
                                                  : null,
                                          child: (data.imageUrl == null ||
                                                  data.imageUrl!.trim().isEmpty)
                                              ? const Icon(
                                                  Icons.person,
                                                  color: Colors.blue,
                                                  size: 30,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CustomText(
                                                content:
                                                    data.businessName ?? '-',
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                              CustomText(
                                                content: data.mobileno ?? '',
                                                fontSize: 12,
                                                color: const Color(0xFF64748B),
                                              ),
                                              CustomText(
                                                content: data.email ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 12,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: bodyHorizontal,
                primary: false,
                child: SizedBox(
                  width: totalTableWidth,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: vertical1,
                    physics: const ClampingScrollPhysics(),
                    child: Obx(() {
                      final list = salesReturnController.filteredList;

                      int currentPage = salesReturnController.currentPage.value;
                      int startIndex = (currentPage - 1) * itemsPerPage;

                      var displayList = list.length > itemsPerPage
                          ? list.skip(startIndex).take(itemsPerPage).toList()
                          : list;

                      if (displayList.isEmpty && list.isNotEmpty) {
                        displayList = list.take(itemsPerPage).toList();
                        startIndex = 0;
                      }

                      return Column(
                        children: displayList.asMap().entries.map((entry) {
                          int index = entry.key;
                          var data = entry.value;

                          return buildTableRow(context, index, 90, data);
                        }).toList(),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
