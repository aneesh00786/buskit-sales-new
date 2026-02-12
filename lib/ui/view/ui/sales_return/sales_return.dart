import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
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
    salesReturnController.selectedFilter.value = FilterDateEnum.thisMonth;
    initializeData();

    // SET 1
    _scrollController1 = _controllers.addAndGet();
    _scrollController2 = _controllers.addAndGet();
    _scrollController3 = _controllers.addAndGet();

    vertical.addListener(() {
      if (vertical1.hasClients &&
          vertical.position.pixels != vertical1.position.pixels) {
        vertical1.jumpTo(vertical.position.pixels);
      }
    });

    vertical1.addListener(() {
      if (vertical.hasClients &&
          vertical1.position.pixels != vertical.position.pixels) {
        vertical.jumpTo(vertical1.position.pixels);
      }
    });
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

    // Ensure UI is ready before triggering update
    if (mounted) {
      setState(() {}); // Optional: trigger rebuild if needed
    }

    // This will now use FilterDateEnum.thisMonth
    await salesReturnController.updateSalesReturnList();

    log("Sales Return Response: ${salesReturnController.salesReturnList.length} items loaded");
  }

  // void initializeData() async {
  //   bool isOnline = await ConnectivityService().isOnline();
  //   if (!isOnline) {
  //     showCustomToastDisplay(
  //         context, "You are Offline!", Colors.red, Icons.close);
  //     return;
  //   }
  //   await salesReturnController.updateSalesReturnList();
  //   log("Sales Return Response: ${salesReturnController.salesReturnList}");
  // }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Sales Return",
                style: TextStyle(
                    fontSize: NkFontSize.largeFont(largeFont: 20),
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const NotificationWidget(
                startDate: '',
                endDate: '',
              ),
               SizedBox(width: 120, child: profiloe())
            ],
          ),
          // ListTile(
          //   leading:    Text(
          //       "Sales Return",
          //         style: TextStyle(
          //     fontSize: NkFontSize.extraLargeFont(),
          //     fontWeight: FontWeight.bold),
          //     ),
          //     trailing: Row(
          //       children: [
          //         const NotificationWidget(
          //           startDate: '',
          //           endDate: '',
          //         ),
          //         const SizedBox(width: 120, child: UpdateAdminBt())
          //       ],
          //     ),
          // ),
          SizedBox(
            width: isPhonePortrait(context)
                ? fullScreenWidth(context) * 2.3
                : fullScreenWidth(context) > 640
                    ? fullScreenWidth(context) * 1
                    : fullScreenWidth(context) * 1.1,
            child: Card(
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
                child: _buildTableLayout(context, fixedRowHeight),
              ),
            ),
          ),
        ],
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

    // Build the dropdown (Matched to DashboardTopWidget)
    Widget timePeriodDropdown() {
      return SizedBox(
        height: 45,
        width: dropdownWidth,
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
                items: const [
                  DropdownMenuItem(
                    value: FilterDateEnum.thisMonth,
                    child: Text('Month', style: TextStyle(fontSize: 12)),
                  ),
                  // DropdownMenuItem(
                  //   value: FilterDateEnum.thisWeek,
                  //   child: Text('Week', style: TextStyle(fontSize: 12)),
                  // ),
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
        ),
      );
    }

    // This widget Row holds the dropdown AND the dynamic pickers
    // Inside _buildFilters in sales_return.dart

    Widget buildTimeFilterRow() {
      return Obx(() => Row(
            // Wrap in Obx to listen to selectedFilter changes
            mainAxisSize: MainAxisSize.min,
            children: [
              timePeriodDropdown(), // The main dropdown

              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.thisMonth) ...[
                const SizedBox(width: 10),
                const SalesReturnMonthDropdown() // <-- NEW WIDGET
              ],

              // if (salesReturnController.selectedFilter.value == FilterDateEnum.thisWeek) ...[
              //   const SizedBox(width: 10),
              //   const SalesReturnWeekDropdown() // <-- NEW WIDGET
              // ],

              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.thisYear) ...[
                const SizedBox(width: 10),
                // You can create SalesReturnYearDropdown similarly or use logic here
                const SalesReturnYearDropdown()
              ],

              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.today) ...[
                const SizedBox(width: 10),
                const SalesReturnDayPicker() // <-- NEW WIDGET
              ],

              if (salesReturnController.selectedFilter.value ==
                  FilterDateEnum.range) ...[
                const SizedBox(width: 10),
                const SalesReturnRangePicker() // <-- NEW WIDGET
              ],
            ],
          ));
    }

    return [
      // 1. Time Period (Dropdown + Conditional Widgets)
      _buildFilterColumn(
        title: CustomText(content: 'Time Period', fontWeight: FontWeight.bold),
        spacing: 10,
        child: buildTimeFilterRow(), // <--- New logic here
      ),

      // 2. Search Customer
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0),

      _buildFilterColumn(
        title:
            CustomText(content: 'Search Customer', fontWeight: FontWeight.bold),
        child: SizedBox(
          width: fieldWidth,
          height: fieldHeight,
          child: TextField(
            onChanged: (value) {
              salesReturnController.setCustomerSearch(value.trim());
            },
            controller: _customerSearchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name...',
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
          ),
        ),
      ),

      // 3. Search Order/Invoice
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0),
      _buildFilterColumn(
        title: CustomText(
            content: 'Search Order/Invoice', fontWeight: FontWeight.bold),
        child: SizedBox(
          width: fieldWidth,
          height: fieldHeight,
          child: TextField(
            controller: _orderORIdSearchCtrl,
            onChanged: (value) {
              salesReturnController.setOrderORIdSearch(value);
            },
            decoration: InputDecoration(
              hintText: 'Search by Order ID or Invoice ID...',
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
            child: ElevatedButton(
              onPressed: () async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(
                      context, "You are Offline!", Colors.red, Icons.close);
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
                backgroundColor: const Color.fromARGB(255, 110, 171, 125),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go'),
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
    final ScrollController _horizontalScrollController = ScrollController();
    
    // DEFINE ITEMS PER PAGE (Set this to whatever your pagination expects, e.g., 10)
    const int itemsPerPage = 10; 

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------
              // LEFT SIDE (Fixed Columns: Sl.No & Customer)
              // ---------------------------------------------
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildSalesReturnTableHeader1(
                          Center(
                            child: CustomText(
                              content: "Sl.No.",
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          60,
                        ),
                        buildSalesReturnTableHeader1(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 40),
                              CustomText(
                                content: "Customer Details",
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          240,
                        ),
                      ],
                    ),
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
                                  content: "No delivered orders found",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }

                          // --- PAGINATION LOGIC START ---
                          // 1. Calculate Start Index based on Current Page
                          int currentPage = salesReturnController.currentPage.value;
                          int startIndex = (currentPage - 1) * itemsPerPage;

                          // 2. Safely slice the list (Get only 10 items for this page)
                          // If the list has ALL data, this slices it. 
                          // If the list has ONLY page data, this logic handles it gracefully.
                          var displayList = list.length > itemsPerPage
                              ? list.skip(startIndex).take(itemsPerPage).toList()
                              : list; 

                          // If displayList is empty (e.g. page out of range), fallback
                          if (displayList.isEmpty && list.isNotEmpty) {
                             displayList = list.take(itemsPerPage).toList();
                             startIndex = 0;
                          }
                          // --- PAGINATION LOGIC END ---

                          return Column(
                            children: displayList.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;

                              // Calculate correct Serial Number (Sl.No)
                              // If on Page 2 (index 0), Sl.No should be 11, not 1.
                              int serialNumber = (list.length > itemsPerPage) 
                                  ? startIndex + index + 1 
                                  : index + 1;

                              return Container(
                                height: 90,
                                color: index.isEven
                                    ? Colors.grey[50]
                                    : Colors.white,
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: CustomText(
                                          content: "$serialNumber", // Use calculated Sl.No
                                          fontWeight: FontWeight.bold,
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
                                                        data.imageUrl!.trim().isNotEmpty)
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CustomText(
                                                  content: data.businessName ?? '-',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                CustomText(
                                                  content: data.mobileno ?? '',
                                                  fontSize: 12,
                                                ),
                                                CustomText(
                                                  content: data.email ?? '',
                                                  overflow: TextOverflow.ellipsis,
                                                  fontSize: 12,
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

              // ---------------------------------------------
              // RIGHT SIDE (Scrollable Data Columns)
              // ---------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  child: SizedBox(
                    width: totalTableWidth,
                    child: Column(
                      children: [
                        buildSalesReturnTableHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: vertical1,
                            physics: const ClampingScrollPhysics(),
                            child: Obx(() {
                              final list = salesReturnController.filteredList;

                              // --- APPLY SAME PAGINATION LOGIC HERE ---
                              int currentPage = salesReturnController.currentPage.value;
                              int startIndex = (currentPage - 1) * itemsPerPage;

                              var displayList = list.length > itemsPerPage
                                  ? list.skip(startIndex).take(itemsPerPage).toList()
                                  : list;
                              
                              if (displayList.isEmpty && list.isNotEmpty) {
                                 displayList = list.take(itemsPerPage).toList();
                                 startIndex = 0;
                              }
                              // ----------------------------------------

                              return Column(
                                children: displayList.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var data = entry.value;
                                  
                                  // Pass the correct Serial Number/Index logic if your buildTableRow needs it
                                  // Note: buildTableRow usually just needs the data. 
                                  // The 'index' here is 0-9 for the current page.
                                  return buildTableRow(context, index, 90, data);
                                }).toList(),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                controller: _horizontalScrollController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildTableLayout(BuildContext context, double fixedRowHeight) {
  //   double totalTableWidth = 130 + 360 + 150 + 150 + 150 + 150 + 150 + 110;
  //   final ScrollController _horizontalScrollController = ScrollController();

  //   return Column(
  //     children: [
  //       Expanded(
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(
  //               width: 300,
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       buildSalesReturnTableHeader1(
  //                         Center(
  //                           child: CustomText(
  //                             content: "Sl.No.",
  //                             textAlign: TextAlign.center,
  //                             fontSize: 14,
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         60,
  //                       ),
  //                       buildSalesReturnTableHeader1(
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             const SizedBox(width: 40),
  //                             CustomText(
  //                               content: "Customer Details",
  //                               fontSize: 14,
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ],
  //                         ),
  //                         240,
  //                       ),
  //                     ],
  //                   ),
  //                   Expanded(
  //                     child: SingleChildScrollView(
  //                       scrollDirection: Axis.vertical,
  //                       controller: vertical,
  //                       physics: const ClampingScrollPhysics(),
  //                       child: Obx(() {
  //                         final list = salesReturnController.filteredList;
  //                         if (list.isEmpty) {
  //                           return SizedBox(
  //                             height: MediaQuery.of(context).size.height * 0.1,
  //                             child: Center(
  //                               child: CustomText(
  //                                 content: "No delivered orders found",
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           );
  //                         }

  //                         return Column(
  //                           children: list.asMap().entries.map((entry) {
  //                             int index = entry.key;
  //                             var data = entry.value;

  //                             // ✅ REMOVED: Don't try to access customer array
  //                             // Use flat fields directly from data

  //                             return Container(
  //                               height: 90,
  //                               color: index.isEven
  //                                   ? Colors.grey[50]
  //                                   : Colors.white,
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: Row(
  //                                 children: [
  //                                   SizedBox(
  //                                     width: 60,
  //                                     child: Padding(
  //                                       padding:
  //                                           const EdgeInsets.only(left: 20),
  //                                       child: CustomText(
  //                                         content: "${index + 1}",
  //                                         fontWeight: FontWeight.bold,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     child: Row(
  //                                       children: [
  //                                         CircleAvatar(
  //                                           radius: 30,
  //                                           backgroundColor: Colors.grey[200],
  //                                           backgroundImage:
  //                                               (data.imageUrl != null &&
  //                                                       data.imageUrl!
  //                                                           .trim()
  //                                                           .isNotEmpty)
  //                                                   ? NetworkImage(
  //                                                       "${ApiConstants.imageBaseUrl}/${data.imageUrl!.trim()}",
  //                                                     )
  //                                                   : null,
  //                                           child: (data.imageUrl == null ||
  //                                                   data.imageUrl!
  //                                                       .trim()
  //                                                       .isEmpty)
  //                                               ? const Icon(
  //                                                   Icons.person,
  //                                                   color: Colors.blue,
  //                                                   size: 30,
  //                                                 )
  //                                               : null,
  //                                         ),

                                       
  //                                         const SizedBox(width: 10),
  //                                         Expanded(
  //                                           child: Column(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             mainAxisAlignment:
  //                                                 MainAxisAlignment.center,
  //                                             children: [
  //                                               CustomText(
  //                                                 content: data.businessName ??
  //                                                     '-', // ✅ Use data.businessName
  //                                                 fontWeight: FontWeight.bold,
  //                                               ),
  //                                               CustomText(
  //                                                 content: data.mobileno ??
  //                                                     '', // ✅ Use data.mobileno
  //                                                 fontSize: 12,
  //                                               ),
  //                                               CustomText(
  //                                                 content: data.email ??
  //                                                     '', // ✅ Use data.email
  //                                                 overflow:
  //                                                     TextOverflow.ellipsis,
  //                                                 fontSize: 12,
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           }).toList(),
  //                         );
  //                       }),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 controller: _horizontalScrollController,
  //                 child: SizedBox(
  //                   width: totalTableWidth,
  //                   child: Obx(() {
  //                     final list = salesReturnController.filteredList;
  //                     return Column(
  //                       children: [
  //                         buildSalesReturnTableHeader(),
  //                         Expanded(
  //                           child: SingleChildScrollView(
  //                             scrollDirection: Axis.vertical,
  //                             controller: vertical1,
  //                             physics: const ClampingScrollPhysics(),
  //                             child: Column(
  //                               children: list.asMap().entries.map((entry) {
  //                                 int index = entry.key;
  //                                 var data = entry.value;
  //                                 return buildTableRow(
  //                                     context, index, 90, data);
  //                               }).toList(),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     );
  //                   }),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       Container(
  //         color: Colors.white,
  //         padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               children: [
  //                 SalesReturnPagination(
  //                     salesReturnController: salesReturnController),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             CustomHorizontalScrollbar(
  //               thumbColor: Colors.blue,
  //               controller: _horizontalScrollController,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
