import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesReturnController extends GetxController {
  // FilterDateEnum selectedFilter = FilterDateEnum.thisMonth;
  Rx<FilterDateEnum> selectedFilter = FilterDateEnum.thisMonth.obs;
  String startDate = "";
  String endDate = "";
  String _searchNameTerm = '';
  String _searchOrderORIdTerm = '';
  DateTime? customStartDate;
  DateTime? customEndDate;
  
  
  var totalPages = 0.obs;
  var currentPage = 1.obs;
  RxBool isOrderLoading = false.obs;
  RxInt selectedStatusCountIndex = 11.obs;
  SearchModel searchData = SearchModel();
  RxBool hasOfflineOrders = false.obs;
  RxInt selectedTabIndex = 0.obs;

@override
  void onInit() {
    super.onInit();
    // Initialize defaults
    String currentMonth = DateFormat('MMMM').format(DateTime.now());
    selectedMonths.add(currentMonth);
    
    // Initialize current week
    int dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
    int weekNum = ((dayOfYear - DateTime(DateTime.now().year, 1, 1).weekday + 10) / 7).floor();
    selectedWeeks.add("week$weekNum");

    selectedDayDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    updateSalesReturnList();
  }

  RxList<GetRecentOrderReturnData> salesReturnList =
      <GetRecentOrderReturnData>[].obs;
  final RxList<GetRecentOrderReturnData> filteredList =
      <GetRecentOrderReturnData>[].obs;

      RxList<String> selectedMonths = <String>[].obs;
  RxList<String> selectedWeeks = <String>[].obs;
  RxInt selectedYear = DateTime.now().year.obs;
  RxString selectedDayDate = "".obs; 
  RxString rangeStartDate = "".obs; 
  RxString rangeEndDate = "".obs;

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      updateSalesReturnList();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      updateSalesReturnList();
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      updateSalesReturnList();
    }
  }

  void setCustomerSearch(String term) {
    _searchNameTerm = term.toLowerCase();
    _applyFilters();
  }

  void setOrderORIdSearch(String term) {
    _searchOrderORIdTerm = term.toLowerCase();
    _applyFilters();
  }

  void _applyFilters() {
    final List<GetRecentOrderReturnData> temp = salesReturnList.where((item) {
      final bool nameMatch = _searchNameTerm.isEmpty ||
          (item.businessName ?? '')
              .toLowerCase()
              .contains(_searchNameTerm);

      final bool orderMatch = _searchOrderORIdTerm.isEmpty ||
          (item.orderId?.toLowerCase().contains(_searchOrderORIdTerm) ??
              false) ||
          (item.invoiceId
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchOrderORIdTerm) ??
              false);

      return nameMatch && orderMatch;
    }).toList();

    filteredList.assignAll(temp);
  }
  void setSelectedMonths(List<String> months) => selectedMonths.assignAll(months);
  void setSelectedWeeks(List<String> weeks) => selectedWeeks.assignAll(weeks);
  void setSelectedYear(int year) => selectedYear.value = year;
  void setSelectedDay(String date) => selectedDayDate.value = date;
  void setRange(String start, String end) {
    rangeStartDate.value = start;
    rangeEndDate.value = end;
  }

  Future updateSalesReturnList() async {
    isOrderLoading.value = true;
    
    // The Web App payload requires Range for dates
    String valueFromDw = "Range"; 
    List<String> selectedRange = [];

    int year = selectedYear.value != 0 ? selectedYear.value : DateTime.now().year;

    final List<String> monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];

    switch (selectedFilter.value) {
      case FilterDateEnum.thisMonth:
        valueFromDw = "Range";
        if (selectedMonths.isEmpty) {
           selectedMonths.add(DateFormat('MMMM').format(DateTime.now()));
        }
        
        String selectedMonthName = selectedMonths.first;
        int monthIndex = monthNames.indexOf(selectedMonthName) + 1;

        if (monthIndex > 0) {
           String start = DateFormat('yyyy-MM-dd').format(DateTime(year, monthIndex, 1));
           String end = DateFormat('yyyy-MM-dd').format(DateTime(year, monthIndex + 1, 0));
           selectedRange = [start, end];
        }
        break;

      case FilterDateEnum.thisWeek:
        valueFromDw = "Range";
        if (selectedWeeks.isEmpty) {
          selectedWeeks.add("week1");
        }
        int weekNum = int.tryParse(selectedWeeks.first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        DateTime firstDayOfYear = DateTime(year, 1, 1);
        DateTime weekStart = firstDayOfYear.add(Duration(days: (weekNum - 1) * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));
        selectedRange = [
          DateFormat('yyyy-MM-dd').format(weekStart),
          DateFormat('yyyy-MM-dd').format(weekEnd)
        ];
        break;

      case FilterDateEnum.today: // "Day" in UI
        valueFromDw = "Range";
        if (selectedDayDate.value.isEmpty) {
          selectedDayDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }
        // Backend treats single days as a range where Start = End
        selectedRange = [selectedDayDate.value, selectedDayDate.value];
        break;

      case FilterDateEnum.range:
        valueFromDw = "Range";
        if (rangeStartDate.value.isEmpty || rangeEndDate.value.isEmpty) {
          isOrderLoading.value = false; 
          Get.snackbar("Error", "Please select valid date range");
          return;
        }
        selectedRange = [rangeStartDate.value, rangeEndDate.value];
        break;

      default: // Fallback
        valueFromDw = "Range";
        selectedRange = [
           DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1)),
           DateFormat('yyyy-MM-dd').format(DateTime(year, 12, 31))
        ];
        break;
    }

    try {
      final response = await ApiWorker().getRecentOrdersReturns(
        page: currentPage.value,
        valueFromDw: valueFromDw,
        selectedRange: selectedRange,
      );

      if (response.data == null || response.data!.isEmpty) {
        salesReturnList.clear();
        totalPages.value = 0;
      } else {
        salesReturnList.assignAll(response.data!);
        if (response.pagination != null && response.pagination!.totalPages != null) {
          totalPages.value = response.pagination!.totalPages!.toInt();
        } else {
          totalPages.value = 1;
        }
      }
      _applyFilters(); 
    } catch (e) {
      salesReturnList.clear();
      filteredList.clear();
      totalPages.value = 0;
    } finally {
      isOrderLoading.value = false;
    }
    update();
  }
//   Future updateSalesReturnList() async {
//     isOrderLoading.value = true;
    
//     String valueFromDw = "Month";
//     List<String> selectedRange = [];
    
//     // Default start/end to today (backend requires them even if ignored by logic)
//     String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     String reqStartDate = todayStr;
//     String reqEndDate = todayStr;

//     // Logic to build the payload based on selectedFilter
//     switch (selectedFilter.value) {
//       case FilterDateEnum.thisMonth:
//         valueFromDw = "Month";
//         // If nothing selected, default to current month
//         if (selectedMonths.isEmpty) {
//            selectedMonths.add(DateFormat('MMMM').format(DateTime.now()));
//         }
//         selectedRange = selectedMonths.toList();
//         break;

//       // case FilterDateEnum.thisWeek:
//       //   valueFromDw = "Week";
//       //   if (selectedWeeks.isEmpty) {
//       //      // Default logic if needed
//       //   }
//       //   selectedRange = selectedWeeks.toList();
//       //   break;

//       case FilterDateEnum.thisYear:
//         valueFromDw = "year";
//         selectedRange = ["${selectedYear.value}"];
//         break;
// case FilterDateEnum.today: // UI says "Day"
//         valueFromDw = "Day";
//         // Ensure we have a date
//         if (selectedDayDate.value.isEmpty) {
//           selectedDayDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
//         }
//         selectedRange = [selectedDayDate.value];
//         break;

//       case FilterDateEnum.range:
//         valueFromDw = "Range";
//         // Validation
//         if (rangeStartDate.value.isEmpty || rangeEndDate.value.isEmpty) {
//           isOrderLoading.value = false; 
//           Get.snackbar("Error", "Please select valid date range");
//           return;
//         }
//         selectedRange = [rangeStartDate.value, rangeEndDate.value];
//         // reqStartDate = rangeStartDate.value;
//         // reqEndDate = rangeEndDate.value;
//         break;
//         case FilterDateEnum.thisWeek:
//         // This case is unreachable from UI, but required by Dart.
//         // We can just break, or default to Month logic if somehow reached.
//         valueFromDw = "Month"; 
//         if (selectedMonths.isEmpty) {
//            selectedMonths.add(DateFormat('MMMM').format(DateTime.now()));
//         }
//         selectedRange = selectedMonths.toList();
//         break;
//     }

//     try {
//       final response = await ApiWorker().getRecentOrdersReturns(
//         page: currentPage.value,
//         valueFromDw: valueFromDw,
//         selectedRange: selectedRange,
//       );

//       if (response.data == null || response.data!.isEmpty) {
//         salesReturnList.clear();
//         totalPages.value = 0;
//       } else {
//         salesReturnList.assignAll(response.data!);
//         if (response.pagination != null && response.pagination!.totalPages != null) {
//           totalPages.value = response.pagination!.totalPages!.toInt();
//         } else {
//           totalPages.value = 1;
//         }
//       }
//       _applyFilters(); // Re-run local search filters if any
//     } catch (e) {
//       salesReturnList.clear();
//       filteredList.clear();
//       totalPages.value = 0;
//       log("Error: $e");
//     } finally {
//       isOrderLoading.value = false;
//     }
//     update();
//   }


  Future<void> setDateRange(DateTime start, DateTime end) async {
    customStartDate = start;
    customEndDate = end;
    selectedFilter.value = FilterDateEnum.range;
    currentPage.value = 1;
    await updateSalesReturnList();
  }
}
