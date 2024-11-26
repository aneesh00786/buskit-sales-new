import 'dart:convert';
import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';
import 'package:get/get.dart';

class CustomerAndOrderController extends GetxController {
  // final ApiWorker _apiWorker = Get.find();
   RxString customerId = ''.obs;

  RxList<CustomerAndOrderData> customerAndOrderList =
      <CustomerAndOrderData>[].obs;

  RxString customerVisitScheduleSet = "".obs;

  SearchModel searchData = SearchModel();

  RxList<String> coustomerTabelsHeadersList = [
    "Customer",
    "Edit",
    "Total Sales",
    "Sales",
    "Delivery",
    "Payment",
    "Estimates",
    "Pre-Order",
    "Drafts",
    "Visit",
  ].obs;

  RxList<String> visitTypeList = [
    "Select Visit Type",
    "Today",
    "This Week",
    "Fortnightly",
    "This Month",
    "Daily"
  ].obs;
  void setCustomerId(String id) {
    customerId.value = id;
  }
Future<List<CustomerAndOrderData>> loadCustomer() async {
  try {
    log("Fetching customers...");
    var response = await ApiWorker().getCustomer();
    if (response.custAndOrderdata != null) {
      customerAndOrderList.assignAll(response.custAndOrderdata!);
    } else {
      customerAndOrderList.clear();
    }
    refresh(); 
  } catch (error) {
    log("Error loading customer data: $error");
  }
  return customerAndOrderList;
}


  Future<CustomerAndOrderData> loadSelectedCustomer(String customerId) async {
    var data = await ApiWorker()
        .getSingleCustomer(customerId)
        .onError((error, stackTrace) {
      return Future.error(error.toString());
    });
    refresh();
    return data;
  }

  Future assignCustomerVisit(
      String customerId, String customerName, String eventStatus,
      {List<String>? selectedWeekDay}) async {
    log("eventStatus ${visitType(int.parse(eventStatus))}");
    var map = {
      "customer_id": customerId,
      "event_status": eventStatus,
      "days_list": jsonEncode(selectedWeekDay ?? [])
    };
    var data = await ApiWorker().assignVisit(map);
    if (data.statusCode == 200 && data.data["status"] == true) {
      NkCommonFunction.showSuccessSnakBar(
          "${customerName.nkStringCapitalizeFirstCaracter} $customerVisitScheduleSet");
    }
    refresh();
    return data;
  }

  String visitType(int type) {
    switch (type) {
      case 1:
        return "Today";
      case 2:
        return "This Week";
      case 3:
        return "Fortnightly";
      case 4:
        return "This Month";
      case 5:
        return "Daily";
      default:
        return "Select Visit Type";
    }
  }
    var searchText = ''.obs;
  var selectedYear = '2023'.obs;
  var years = ['2023'].obs;
  int updateVisitType(int type) {
    refresh();
    return type;
  }
    void updateSelectedYear(String value) {
    selectedYear.value = value;
  }


  CustomerAndOrderData updateSingleCustomerData(CustomerAndOrderData data) {
    refresh();
    return data;
  }

  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchData.startDate = NKDateUtils.apiDayFormat(startDate);
      searchData.endDate = NKDateUtils.apiDayFormat(endDate);
      loadCustomer;
    } else {
      searchData.startDate = "";
      searchData.endDate = "";
      loadCustomer;
    }
    refresh();
  }
}
