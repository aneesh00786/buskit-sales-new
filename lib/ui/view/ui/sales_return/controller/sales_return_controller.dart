import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SalesReturnController extends GetxController {
  FilterDateEnum selectedFilter = FilterDateEnum.thisMonth;
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
    updateSalesReturnList();
  }

  RxList<GetRecentOrderReturnData> salesReturnList = <GetRecentOrderReturnData>[].obs;
  final RxList<GetRecentOrderReturnData> filteredList = <GetRecentOrderReturnData>[].obs;

  // ✅ FIX: Unified pagination navigation
  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      updateSalesReturnList(); // ✅ Use main fetch method
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      updateSalesReturnList(); // ✅ Use main fetch method
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      updateSalesReturnList(); // ✅ Use main fetch method
    }
  }

  // ✅ REMOVED: Old returnOrderData() method - not needed anymore

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
      // Customer name filter
      final bool nameMatch = _searchNameTerm.isEmpty ||
          (item.customer?.first.businessName ?? '')
              .toLowerCase()
              .contains(_searchNameTerm);

      // Order/Invoice filter
      final bool orderMatch = _searchOrderORIdTerm.isEmpty ||
          (item.orderId?.toLowerCase().contains(_searchOrderORIdTerm) ?? false) ||
          (item.invoice?.invoiceId?.toString().toLowerCase().contains(_searchOrderORIdTerm) ?? false);

      return nameMatch && orderMatch;
    }).toList();

    filteredList.assignAll(temp);
  }

  // ✅ FIX: Main fetch method now handles pagination
  Future updateSalesReturnList() async {
    isOrderLoading.value = true;

    // Calculate date range based on filter
    DateTime today = DateTime.now();

    switch (selectedFilter) {
      case FilterDateEnum.today:
        startDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        endDate = startDate;
        break;
      case FilterDateEnum.thisWeek:
        DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
        DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
        startDate = "${firstDayOfWeek.year}-${firstDayOfWeek.month.toString().padLeft(2, '0')}-${firstDayOfWeek.day.toString().padLeft(2, '0')}";
        endDate = "${lastDayOfWeek.year}-${lastDayOfWeek.month.toString().padLeft(2, '0')}-${lastDayOfWeek.day.toString().padLeft(2, '0')}";
        break;
      case FilterDateEnum.thisMonth:
        startDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-01";
        endDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${DateTime(today.year, today.month + 1, 0).day.toString().padLeft(2, '0')}";
        break;
      case FilterDateEnum.thisYear:
        startDate = "${today.year}-01-01";
        endDate = "${today.year}-12-31";
        break;
      case FilterDateEnum.range:
        if (customStartDate != null && customEndDate != null) {
          if (customEndDate!.isBefore(customStartDate!)) {
            Get.snackbar("Invalid Date Range", "End date cannot be before start date");
            isOrderLoading.value = false;
            return;
          }
          startDate = "${customStartDate!.year}-${customStartDate!.month.toString().padLeft(2, '0')}-${customStartDate!.day.toString().padLeft(2, '0')}";
          endDate = "${customEndDate!.year}-${customEndDate!.month.toString().padLeft(2, '0')}-${customEndDate!.day.toString().padLeft(2, '0')}";
        } else {
          salesReturnList.clear();
          filteredList.clear();
          isOrderLoading.value = false;
          return;
        }
        break;
    }

    try {
      // ✅ FIX: Pass page parameter to API
      final response = await ApiWorker().getRecentOrdersReturns(
        startDate: startDate,
        endDate: endDate,
        page: currentPage.value, // ✅ ADD THIS
      );

      // ✅ FIX: Update pagination info
      if (response.data == null || response.data!.isEmpty) {
        salesReturnList.clear();
        totalPages.value = 0;
      } else {
        salesReturnList.assignAll(response.data!);
        
        // ✅ FIX: Extract pagination from response
        if (response.pagination != null && response.pagination!.totalPages != null) {
          totalPages.value = response.pagination!.totalPages!.toInt();
        } else {
          totalPages.value = 1;
        }
      }

      _applyFilters();
      log("Updated Sales Return List: ${salesReturnList.length} items, Page: ${currentPage.value}/${totalPages.value}");
    } catch (e) {
      log("Error updating sales return list: $e");
      salesReturnList.clear();
      filteredList.clear();
      totalPages.value = 0;
    } finally {
      isOrderLoading.value = false;
    }

    update();
  }

  // ✅ FIX: Reset to page 1 when setting date range
  Future<void> setDateRange(DateTime start, DateTime end) async {
    customStartDate = start;
    customEndDate = end;
    selectedFilter = FilterDateEnum.range;
    currentPage.value = 1; // ✅ Reset to first page
    await updateSalesReturnList();
  }
}

// class SalesReturnController extends GetxController{

//   FilterDateEnum selectedFilter = FilterDateEnum.thisMonth;
//     String startDate = "";
//     String endDate = "";
//     String _searchNameTerm = '';
//     String _searchOrderORIdTerm = '';
//     DateTime? customStartDate;
//   DateTime? customEndDate;
//   var totalPages = 0.obs;
//   var currentPage = 1.obs;
//   RxBool isOrderLoading = false.obs;
//   RxInt selectedStatusCountIndex = 11.obs;
//   SearchModel searchData = SearchModel();
//   RxBool hasOfflineOrders = false.obs;
//    RxInt selectedTabIndex = 0.obs;
  
// @override
//   void onInit() {
//     super.onInit();
//     updateSalesReturnList();
//   }             

//   RxList<GetRecentOrderReturnData> salesReturnList = <GetRecentOrderReturnData>[].obs;
// final RxList<GetRecentOrderReturnData> filteredList = <GetRecentOrderReturnData>[].obs;

//  void goToPreviousPage() {
//     if (currentPage.value > 1) {
//       currentPage.value--;
//       returnOrderData(
//           selectedIndex: hasOfflineOrders.value
//               ? selectedTabIndex.value - 1
//               : selectedTabIndex.value);
//     }
//   }
//   void goToPage(int page) {
//     if (page >= 1 && page <= totalPages.value) {
//       currentPage.value = page;
//       returnOrderData(
//           selectedIndex: hasOfflineOrders.value
//               ? selectedTabIndex.value - 1
//               : selectedTabIndex.value);
//     }
//   }
//   void goToNextPage() {
//     if (currentPage.value < totalPages.value) {
//       currentPage.value++;
//       returnOrderData(
//           selectedIndex: hasOfflineOrders.value
//               ? selectedTabIndex.value - 1
//               : selectedTabIndex.value);
//     }
//   }


//   Future<List<GetRecentOrderReturnData>> returnOrderData(
//       {required int selectedIndex, bool hasOfflineOrders = false}) async {
//     salesReturnList.clear();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       salesReturnList.clear();
//     });
//     isOrderLoading.value = true;

//     if (hasOfflineOrders) {
//       switch (selectedIndex) {
//         case 0:
//           break;
//         case 1:
//           selectedStatusCountIndex.value = 11;
//           break;
//         case 2:
//           selectedStatusCountIndex.value = 12;
//           break;
//         case 3:
//           selectedStatusCountIndex.value = 14;
//           break;
//         case 4:
//           selectedStatusCountIndex.value = 5;
//           break;
//         case 5:
//           selectedStatusCountIndex.value = 1;
//           break;
//         case 6:
//           selectedStatusCountIndex.value = 2;
//           break;
//         case 7:
//           selectedStatusCountIndex.value = 13;
//           break;
//         default:
//           selectedStatusCountIndex.value = 11;
//       }
//     } else {
//       switch (selectedIndex) {
//         case 0:
//           selectedStatusCountIndex.value = 11;
//           break;
//         case 1:
//           selectedStatusCountIndex.value = 12;
//           break;
//         case 2:
//           selectedStatusCountIndex.value = 14;
//           break;
//         case 3:
//           selectedStatusCountIndex.value = 5;
//           break;
//         case 4:
//           selectedStatusCountIndex.value = 1;
//           break;
//         case 5:
//           selectedStatusCountIndex.value = 2;
//           break;
//         case 6:
//           selectedStatusCountIndex.value = 13;
//           break;
//         default:
//           selectedStatusCountIndex.value = 11;
//       }
//     }

//     try {
//       var data = await ApiWorker().getRecentOrdersReturns(
//         searchModel: searchData,
//         // orderStatus: selectedStatusCountIndex.value,
//         page: currentPage.value,
//         // isLogin: false,
//       );

//       if (data.data == null || data.data!.isEmpty) {
//         salesReturnList.clear();
//       } else {
//         salesReturnList.assignAll(data.data!);

//         if (data.pagination != null && data.pagination!.totalPages != null) {
//           totalPages.value = data.pagination!.totalPages!.toInt();
//         } else {
//           totalPages.value = 1;
//         }
//       }
//     } catch (e) {
//       isOrderLoading.value = false;
//     } finally {
//       isOrderLoading.value = false;
//     }

//     return salesReturnList;
//   }


//  void setCustomerSearch(String term) {
//     _searchNameTerm = term.toLowerCase();
//     _applyFilters();
//   }
//   void setOrderORIdSearch(String term) {
//     _searchOrderORIdTerm = term.toLowerCase();
//     _applyFilters();
//   }
// void _applyFilters() {
//   final List<GetRecentOrderReturnData> temp = salesReturnList.where((item) {
//     // ── 1. Customer name ─────────────────────────────────────
//     final bool nameMatch = _searchNameTerm.isEmpty ||
//         (item.customer?.first.businessName ?? '')
//             .toLowerCase()
//             .contains(_searchNameTerm);

//     // ── 2. Order / Invoice ───────────────────────────────────
//     //   • `orderId`  – usually a **String**
//     //   • `invoice`  – an **Invoice?** object, we need the ID inside it
//     final bool orderMatch = _searchOrderORIdTerm.isEmpty ||
//         // orderId (String)
//         (item.orderId?.toLowerCase().contains(_searchOrderORIdTerm) ?? false) ||
//         // invoice?.invoiceId (or whatever field holds the invoice number)
//         (item.invoice?.invoiceId?.toString().toLowerCase().contains(_searchOrderORIdTerm) ??
//             false);

//     return nameMatch && orderMatch;
//   }).toList();

//   filteredList.assignAll(temp);
// }
//   // void _applyFilters() {
//   //   if (_searchNameTerm.isEmpty) {
//   //     filteredList.assignAll(salesReturnList);
//   //   } else {
//   //     filteredList.assignAll(
//   //       salesReturnList.where((item) =>
//   //           (item.customer?.first.businessName ?? '')
//   //               .toLowerCase()
//   //               .contains(_searchNameTerm)),
//   //     );
//   //   }
//   // }

//   Future updateSalesReturnList() async {

//         DateTime today = DateTime.now();

//     switch(selectedFilter){
//       case FilterDateEnum.today:
//         startDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";
//         endDate = startDate;
//         break;
//       case FilterDateEnum.thisWeek:
//         DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
//         DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
//         startDate = "${firstDayOfWeek.year}-${firstDayOfWeek.month.toString().padLeft(2,'0')}-${firstDayOfWeek.day.toString().padLeft(2,'0')}";
//         endDate = "${lastDayOfWeek.year}-${lastDayOfWeek.month.toString().padLeft(2,'0')}-${lastDayOfWeek.day.toString().padLeft(2,'0')}";
//         break;
//       case FilterDateEnum.thisMonth:
//         startDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-01";
//         endDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-${DateTime(today.year, today.month + 1, 0).day.toString().padLeft(2,'0')}";
//         break;
//       case FilterDateEnum.thisYear:
//         startDate = "${today.year}-01-01";
//         endDate = "${today.year}-12-31";
//         break;
//       case FilterDateEnum.range:
//       if(customStartDate != null && customEndDate != null){

//         if(customEndDate!.isBefore(customStartDate!)){
//           Get.snackbar("Invalid Date Range", "End date cannot be before start date");
//           return;
//         }
//         startDate = "${customStartDate!.year}-${customStartDate!.month.toString().padLeft(2,'0')}-${customStartDate!.day.toString().padLeft(2,'0')}";
//         endDate = "${customEndDate!.year}-${customEndDate!.month.toString().padLeft(2,'0')}-${customEndDate!.day.toString().padLeft(2,'0')}";
//       }else{
//         salesReturnList.clear();
//         filteredList.clear();
//         // startDate = "";
//         // endDate = "";
//         return;
//       }
//         break;

//     }

//     final response = await ApiWorker().getRecentOrdersReturns(startDate: startDate, endDate: endDate);
//     salesReturnList.value = response.data ?? [];

//     update();
//     _applyFilters();

//     log("Updated Sales Return List: ${salesReturnList.length} items");
//   }
//   Future<void> setDateRange(DateTime start, DateTime end) async {

//     customStartDate = start;
//     customEndDate = end;
//     selectedFilter = FilterDateEnum.range;
//     await updateSalesReturnList();
//     _applyFilters();
//   }
 

// }