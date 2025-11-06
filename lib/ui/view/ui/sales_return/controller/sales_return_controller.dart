import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/model/sales_return_model.dart';
import 'package:get/get.dart';

class SalesReturnController extends GetxController{

  FilterDateEnum selectedFilter = FilterDateEnum.thisMonth;
    String startDate = "";
    String endDate = "";
    String _searchNameTerm = '';
    String _searchOrderORIdTerm = '';
    DateTime? customStartDate;
  DateTime? customEndDate;
  
@override
  void onInit() {
    super.onInit();
    updateSalesReturnList();
  }             

  RxList<GetRecentOrderReturnData> salesReturnList = <GetRecentOrderReturnData>[].obs;
final RxList<GetRecentOrderReturnData> filteredList = <GetRecentOrderReturnData>[].obs;

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
    // ── 1. Customer name ─────────────────────────────────────
    final bool nameMatch = _searchNameTerm.isEmpty ||
        (item.customer?.first.businessName ?? '')
            .toLowerCase()
            .contains(_searchNameTerm);

    // ── 2. Order / Invoice ───────────────────────────────────
    //   • `orderId`  – usually a **String**
    //   • `invoice`  – an **Invoice?** object, we need the ID inside it
    final bool orderMatch = _searchOrderORIdTerm.isEmpty ||
        // orderId (String)
        (item.orderId?.toLowerCase().contains(_searchOrderORIdTerm) ?? false) ||
        // invoice?.invoiceId (or whatever field holds the invoice number)
        (item.invoice?.invoiceId?.toString().toLowerCase().contains(_searchOrderORIdTerm) ??
            false);

    return nameMatch && orderMatch;
  }).toList();

  filteredList.assignAll(temp);
}
  // void _applyFilters() {
  //   if (_searchNameTerm.isEmpty) {
  //     filteredList.assignAll(salesReturnList);
  //   } else {
  //     filteredList.assignAll(
  //       salesReturnList.where((item) =>
  //           (item.customer?.first.businessName ?? '')
  //               .toLowerCase()
  //               .contains(_searchNameTerm)),
  //     );
  //   }
  // }

  Future updateSalesReturnList() async {

        DateTime today = DateTime.now();

    switch(selectedFilter){
      case FilterDateEnum.today:
        startDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}";
        endDate = startDate;
        break;
      case FilterDateEnum.thisWeek:
        DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
        DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
        startDate = "${firstDayOfWeek.year}-${firstDayOfWeek.month.toString().padLeft(2,'0')}-${firstDayOfWeek.day.toString().padLeft(2,'0')}";
        endDate = "${lastDayOfWeek.year}-${lastDayOfWeek.month.toString().padLeft(2,'0')}-${lastDayOfWeek.day.toString().padLeft(2,'0')}";
        break;
      case FilterDateEnum.thisMonth:
        startDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-01";
        endDate = "${today.year}-${today.month.toString().padLeft(2,'0')}-${DateTime(today.year, today.month + 1, 0).day.toString().padLeft(2,'0')}";
        break;
      case FilterDateEnum.thisYear:
        startDate = "${today.year}-01-01";
        endDate = "${today.year}-12-31";
        break;
      case FilterDateEnum.range:
      if(customStartDate != null && customEndDate != null){

        if(customEndDate!.isBefore(customStartDate!)){
          Get.snackbar("Invalid Date Range", "End date cannot be before start date");
          return;
        }
        startDate = "${customStartDate!.year}-${customStartDate!.month.toString().padLeft(2,'0')}-${customStartDate!.day.toString().padLeft(2,'0')}";
        endDate = "${customEndDate!.year}-${customEndDate!.month.toString().padLeft(2,'0')}-${customEndDate!.day.toString().padLeft(2,'0')}";
      }else{
        salesReturnList.clear();
        filteredList.clear();
        // startDate = "";
        // endDate = "";
        return;
      }
        break;

    }

    final response = await ApiWorker().getRecentOrdersReturns(startDate: startDate, endDate: endDate);
    salesReturnList.value = response.data ?? [];

    update();
    _applyFilters();

    log("Updated Sales Return List: ${salesReturnList.length} items");
  }
  Future<void> setDateRange(DateTime start, DateTime end) async {

    customStartDate = start;
    customEndDate = end;
    selectedFilter = FilterDateEnum.range;
    await updateSalesReturnList();
    _applyFilters();
  }
 

}