import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/measurements/responsive_info.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/custom_scrollbar.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/widgets/sales_return_pagination.dart';
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
    initializeData();

    _controllers = LinkedScrollControllerGroup();
    salesReturnController.selectedFilter = FilterDateEnum.thisMonth;
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
      showCustomToastDisplay(
          context, "You are Offline!", Colors.red, Icons.close);
      return;
    }
    await salesReturnController.updateSalesReturnList();
    log("Sales Return Response: ${salesReturnController.salesReturnList}");
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: CustomText(
                content: 'Sales Return',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
    // Controllers for date fields (only used when Range is selected)
    final TextEditingController _startDateCtrl = TextEditingController();
    final TextEditingController _endDateCtrl = TextEditingController();

    const double fieldHeight = 55.0;
    final double cardWidth = salesReturncardWidth(context); // <-- SAME AS CARD
    final double fieldWidth = isMobile
        ? cardWidth // mobile → full card width
        : (cardWidth * 0.22).clamp(186.0, 280.0);

    // Helper: Date picker field
    Widget _dateField(String hint, TextEditingController controller) {
      return SizedBox(
        // width: fieldWidth,
        // width: isMobile ? double.infinity : 150,
        // height: 55,
        width: fieldWidth,
        height: fieldHeight,
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.text =
                  "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
      );
    }

    // Build the dropdown (always visible)
    Widget timePeriodDropdown() {
      return Container(
        width: fieldWidth,
        height: fieldHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<FilterDateEnum>(
          alignment: Alignment.center,
          value: salesReturnController.selectedFilter,
          onChanged: (newValue) async {
            bool isOnline = await ConnectivityService().isOnline();
            if (!isOnline) {
              showCustomToastDisplay(
                  context, "You are Offline!", Colors.red, Icons.close);
              return;
            }
            if (newValue != null) {
              setState(() {
                salesReturnController.selectedFilter = newValue;
                if (newValue == FilterDateEnum.range) {
                  salesReturnController.salesReturnList.clear();
                  salesReturnController.filteredList.clear();
                  // Clear previous range dates
                }
              });

              // Only auto-refresh if NOT range
              // if (newValue != FilterDateEnum.range) {
              //   await salesReturnController.updateSalesReturnList();
              // }
            }
          },
          items: [
            DropdownMenuItem(
              // alignment: Alignment.center,
              value: FilterDateEnum.today,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomText(
                    content: 'Today',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            DropdownMenuItem(
              // alignment: Alignment.center,
              value: FilterDateEnum.thisWeek,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomText(
                    content: 'This Week',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            DropdownMenuItem(
              // alignment: Alignment.center,
              value: FilterDateEnum.thisMonth,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomText(
                    content: 'This Month',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            DropdownMenuItem(
              // alignment: Alignment.center,
              value: FilterDateEnum.thisYear,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomText(
                    content: 'This Year',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            DropdownMenuItem(
              // alignment: Alignment.center,
              value: FilterDateEnum.range,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomText(
                    content: 'Range',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
          isExpanded: true,
          underline: Container(),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    // Build the range date fields (only shown when Range is selected)
    Widget _rangeDateFields() {
      if (salesReturnController.selectedFilter != FilterDateEnum.range) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 19,
          ),
          _dateField('mm/dd/yyyy', _startDateCtrl),
          const SizedBox(width: 12),
          _dateField('mm/dd/yyyy', _endDateCtrl),
          // const SizedBox(width: 10),
        ],
      );
    }

    return [
      _buildFilterColumn(
        title: CustomText(content: 'Time Period', fontWeight: FontWeight.bold),
        spacing: 10,
        child: timePeriodDropdown(),
      ),

      if (!isMobile) ...[
        _rangeDateFields(),
      ] else ...[
        _rangeDateFields(),
      ],

      // 3. Search Customer
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0),

      _buildFilterColumn(
        title:
            CustomText(content: 'Search Customer', fontWeight: FontWeight.bold),
        child: SizedBox(
          // width: fieldWidth,
          // width: isMobile ? double.infinity : 186,
          // width:  isMobile
          // ? double.infinity
          // : (MediaQuery.of(context).size.width * 0.15).clamp(186.0, 280.0),
          width: fieldWidth,
          height: fieldHeight,
          child: TextField(
            onChanged: (value) {
              salesReturnController.setCustomerSearch(value.trim());
            },
            controller: _customerSearchCtrl, // <-- bind controller
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

      // _buildFilterColumn(
      //   title: CustomText(content: 'Search Customer', fontWeight: FontWeight.bold),
      //   child: SizedBox(
      //     width: fieldWidth,
      //     child: _buildTextField('Search by name...'),
      //   ),
      // ),

      // 4. Search Order/Invoice
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 20 : 0),
      _buildFilterColumn(
        title: CustomText(
            content: 'Search Order/Invoice', fontWeight: FontWeight.bold),
        child: SizedBox(
          // width: isMobile ? double.infinity : 186,
          // width:  isMobile
          //   ? double.infinity
          //   : (MediaQuery.of(context).size.width * 0.15).clamp(186.0, 280.0),
          width: fieldWidth,
          height: fieldHeight,
          child: TextField(
            controller: _orderORIdSearchCtrl, // <-- bind
            onChanged: (value) {
              salesReturnController
                  .setOrderORIdSearch(value); // <-- call setter
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
      // _buildFilterColumn(
      //   title: CustomText(content: 'Search Order/Invoice', fontWeight: FontWeight.bold),
      //   child: SizedBox(
      //     width: isMobile ? double.infinity : 230,
      //     child: _buildTextField('Search by Order ID or Invoice ID...'),
      //   ),
      // ),

      // 5. Go Button (unchanged)
      SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 50 : 50),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //      final  double goButtonWidth  = 80.0, // <-- YOUR DESIRED WIDTH
          // final double goButtonHeight = 55.0;
          // const SizedBox(height: 20),
          SizedBox(
            // height: 55,
            // width: fieldWidth,
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

                // Pass range dates only if Range is selected
                if (salesReturnController.selectedFilter ==
                    FilterDateEnum.range) {
                  final s = _parse(_startDateCtrl.text);
                  final e = _parse(_endDateCtrl.text);
                  if (s == null || e == null) {
                    showCustomToastDisplay(
                        context,
                        "Please select valid date range!",
                        Colors.red,
                        Icons.close);
                    return;
                  }
                  if (e.isBefore(s)) {
                    showCustomToastDisplay(
                        context,
                        "End date cannot be before start date",
                        Colors.red,
                        Icons.close);
                    return;
                  }
                  await salesReturnController.setDateRange(s, e);
                  // startDate: _startDateCtrl.text.isEmpty ? null : _startDateCtrl.text,
                  // endDate: _endDateCtrl.text.isEmpty ? null : _endDateCtrl.text,
                } else {
                  await salesReturnController.updateSalesReturnList();
                }
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
          SizedBox(
            height: 2,
          )
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
    return Row(
      children: [
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
                        SizedBox(width: 40),
                        CustomText(
                          content: "Customer Details",
                          textAlign: TextAlign.center,
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
                          height: fixedRowHeight,
                          child: Center(
                            child: CustomText(
                              content: "No delivered orders found",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: list.asMap().entries.map((entry) {
                          int index = entry.key;
                          GetRecentOrderReturnData salesReturnData =
                              entry.value;
                          return Container(
                            height: fixedRowHeight,
                            color:
                                index.isEven ? Colors.grey[50] : Colors.white,
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: CustomText(
                                      content: "${index + 1}",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CustomText(
                                              content: salesReturnData
                                                  .customer?.first.businessName,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            CustomText(
                                              content: '1234567891000000',
                                              fontSize: 12,
                                            ),
                                            CustomText(
                                              content:
                                                  'emailllkkjxhsjxkhdaehihujhgvyh',
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 12,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    })),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(3),
                height: 50,
                color: Colors.white,
                child: Row(
                  children: [
                    SalesReturnPagination(
                        salesReturnController: salesReturnController),
                    const Spacer()
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller:
                    _horizontalScrollController, // << Add controller here
                child: SizedBox(
                  width: totalTableWidth,
                  child: Obx(() {
                    final list = salesReturnController.filteredList;

                    return Column(
                      children: [
                        // ---------------- HEADER -----------------
                        SizedBox(
                          child: buildSalesReturnTableHeader(
                              // controller: _horizontalScrollController, // << pass controller
                              ),
                        ),

                        // ---------------- BODY -----------------
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: vertical1,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: list.asMap().entries.map((entry) {
                                int index = entry.key;
                                final salesReturnData = entry.value;

                                return buildTableRow(
                                  context,
                                  index,
                                  fixedRowHeight,
                                  salesReturnData,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // Custom Scrollbar overlay
              Positioned(
                // top: 40,
                bottom: 10,
                left: 0,
                right: 0,
                child: CustomHorizontalScrollbar(
                  thumbColor: Colors.blue,
                  controller:
                      _horizontalScrollController, // must be same controller
                ),
              ),
            ],
          ),
        )

        // Expanded(
        //   child: Stack(
        //     children: [
        //       SingleChildScrollView(
        //         scrollDirection: Axis.horizontal,
        //         child: SizedBox(
        //           width: totalTableWidth,
        //           child: Obx((){
        //             final list = salesReturnController.filteredList;
        //             return Column(
        //             mainAxisAlignment: MainAxisAlignment.start,
        //             children: [
        //               SizedBox(child: buildSalesReturnTableHeader()),
        //               Expanded(
        //                 child: SingleChildScrollView(
        //                     scrollDirection: Axis.vertical,
        //                       controller: vertical1,
        //                     // scrollDirection: Axis.vertical,
        //                     physics: const ClampingScrollPhysics(),
        //                     // controller: vertical1,

        //                     child: Column(
        //                       children:
        //                         //  salesReturnController.salesReturnList
        //                         list
        //                           .asMap()
        //                           .entries
        //                           .map((entry) {
        //                         int index = entry.key;
        //                         GetRecentOrderReturnData salesReturnData = entry.value;
        //                         return buildTableRow(context,
        //                             index, fixedRowHeight,salesReturnData);
        //                       }).toList(),
        //                     ),
        //                     ),
        //               ),
        //               // if (widget.leadsController.totalPages > 1)
        //             ],
        //           );
        //           })
        //         ),
        //       ),
        //       Positioned(
        //        top: 30,
        //         left: 0,
        //         right: 0,
        //         child: CustomHorizontalScrollbar(
        //           thumbColor: Colors.red,

        //           controller: _horizontalScrollController,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
