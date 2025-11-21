import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
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

  RxList<GetRecentOrderReturnData> salesReturnList =
      <GetRecentOrderReturnData>[].obs;
  final RxList<GetRecentOrderReturnData> filteredList =
      <GetRecentOrderReturnData>[].obs;

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
          (item.customer?.first.businessName ?? '')
              .toLowerCase()
              .contains(_searchNameTerm);

      final bool orderMatch = _searchOrderORIdTerm.isEmpty ||
          (item.orderId?.toLowerCase().contains(_searchOrderORIdTerm) ??
              false) ||
          (item.invoice?.invoiceId
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchOrderORIdTerm) ??
              false);

      return nameMatch && orderMatch;
    }).toList();

    filteredList.assignAll(temp);
  }

  Future updateSalesReturnList() async {
    isOrderLoading.value = true;

    DateTime today = DateTime.now();

    switch (selectedFilter) {
      case FilterDateEnum.today:
        startDate =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        endDate = startDate;
        break;
      case FilterDateEnum.thisWeek:
        DateTime firstDayOfWeek =
            today.subtract(Duration(days: today.weekday - 1));
        DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
        startDate =
            "${firstDayOfWeek.year}-${firstDayOfWeek.month.toString().padLeft(2, '0')}-${firstDayOfWeek.day.toString().padLeft(2, '0')}";
        endDate =
            "${lastDayOfWeek.year}-${lastDayOfWeek.month.toString().padLeft(2, '0')}-${lastDayOfWeek.day.toString().padLeft(2, '0')}";
        break;
      case FilterDateEnum.thisMonth:
        startDate =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-01";
        endDate =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${DateTime(today.year, today.month + 1, 0).day.toString().padLeft(2, '0')}";
        break;
      case FilterDateEnum.thisYear:
        startDate = "${today.year}-01-01";
        endDate = "${today.year}-12-31";
        break;
      case FilterDateEnum.range:
        if (customStartDate != null && customEndDate != null) {
          if (customEndDate!.isBefore(customStartDate!)) {
            Get.snackbar(
                "Invalid Date Range", "End date cannot be before start date");
            isOrderLoading.value = false;
            return;
          }
          startDate =
              "${customStartDate!.year}-${customStartDate!.month.toString().padLeft(2, '0')}-${customStartDate!.day.toString().padLeft(2, '0')}";
          endDate =
              "${customEndDate!.year}-${customEndDate!.month.toString().padLeft(2, '0')}-${customEndDate!.day.toString().padLeft(2, '0')}";
        } else {
          salesReturnList.clear();
          filteredList.clear();
          isOrderLoading.value = false;
          return;
        }
        break;
    }

    try {
      final response = await ApiWorker().getRecentOrdersReturns(
        startDate: startDate,
        endDate: endDate,
        page: currentPage.value,
      );

      if (response.data == null || response.data!.isEmpty) {
        salesReturnList.clear();
        totalPages.value = 0;
      } else {
        salesReturnList.assignAll(response.data!);

        if (response.pagination != null &&
            response.pagination!.totalPages != null) {
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

  Future<void> setDateRange(DateTime start, DateTime end) async {
    customStartDate = start;
    customEndDate = end;
    selectedFilter = FilterDateEnum.range;
    currentPage.value = 1;
    await updateSalesReturnList();
  }
}
