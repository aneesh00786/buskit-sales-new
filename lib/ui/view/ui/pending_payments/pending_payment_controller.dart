// ignore_for_file: empty_catches

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class PendingPaymentController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  RxList<CustomerData> orderDataList = <CustomerData>[].obs;
  RxInt selectedTabIndex = 0.obs;
  Rx<ChartDetails> chartData =
      ChartDetails(nearlyDue: 0, due: 0, all: 0, overdue: 0).obs;
  RxDouble totalAmount = 0.0.obs;
  RxDouble nearlyDueAmount = 0.0.obs;
  RxDouble dueAmount = 0.0.obs;
  RxDouble overdueAmount = 0.0.obs;
  PaginationModel paginationModel = PaginationModel();

  RxList<IndividualPendingData> individualPendingPayments =
      <IndividualPendingData>[].obs;
  RxBool isLoading = false.obs;

  RxList<String> orderTableColumCategory = [
    " Customer List",
    "Order Number",
    "Order created",
    "Due Date",
    "Days",
    "Order Price",
    "Status",
    ""
  ].obs;

  SearchModel searchModel = SearchModel();

  List<IndividualPendingData> allItems = [];

  // RxList to track selected items
  RxList<IndividualPendingData> selectedItems = <IndividualPendingData>[].obs;
  RxBool isLoadingPayment = true.obs;
// Call this method when an item is selected or deselected
  void toggleItemSelection(IndividualPendingData item) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
  }

  List<IndividualPendingData> getSelectedItems() {
    return selectedItems.toList();
  }

  Future<void> loadOrderData(
      {required int chartIndex, int? compId, bool? isLogin}) async {
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    try {
      var data = await _apiWorker.getPendingPaymentData(
          chartIndex: chartIndex,
          searchModel: searchModel,
          paginationModel:paginationModel,
          salesmanId: salesmanId,
          compId: compId,
          isLogin: isLogin);
      // ignore: unnecessary_null_comparison
      if (data.data != null) {
        orderDataList.assignAll(data.data);
        chartData.value = data.chartDetails;
        totalAmount.value = data.totalAmount.toDouble();
        nearlyDueAmount.value = data.nearlydueAmount.toDouble();
        dueAmount.value = data.dueAmount.toDouble();
        overdueAmount.value = data.overdueAmount.toDouble();
      } else {
        orderDataList.clear();
      }
    } catch (e) {
      // Handle errors here
    }
  }
  // inside PendingPaymentController class

  Future<void> loadIndividualPendingPayments(String customerId) async {
    try {
      print('api called');
      isLoading.value = true;
      
      bool isOnline = await ConnectivityService().isOnline();

      if (isOnline) {
        print('Online mode: Fetching from API');
        // --- ONLINE FLOW ---
        // 1. Fetch from API
        var response = await _apiWorker.getAllPendingPaymentIndividual(
          customerId: customerId,
        );
       

        if (response.data != null) {
          individualPendingPayments.assignAll(response.data);
          
          // 2. SAVE TO HIVE FOR OFFLINE USE
          try {
            var box = await Hive.openBox('offlineCustomerPayments');
            // Convert list of objects to list of JSON maps
            List<Map<String, dynamic>> jsonList = response.data.map((e) => e.toJson()).toList();
            await box.put(customerId, jsonList); 
          } catch (e) {
            print("Error saving offline data: $e");
          }
        } else {
          individualPendingPayments.clear();
        }
      } else {
    
        // --- OFFLINE FLOW ---
        // 3. LOAD FROM HIVE
        try {
          var box = await Hive.openBox('offlineCustomerPayments');
          if (box.containsKey(customerId)) {
            // Get the raw data (List of Maps)
            List<dynamic> storedData = box.get(customerId);
            
            // Convert back to your model objects
            List<IndividualPendingData> offlineList = storedData.map((e) {
               // Ensure 'e' is cast to Map<String, dynamic> safely
               return IndividualPendingData.fromJson(Map<String, dynamic>.from(e));
            }).toList();
            
            individualPendingPayments.assignAll(offlineList);
          } else {
             individualPendingPayments.clear();
          }
        } catch (e) {
          print("Error loading offline data: $e");
          individualPendingPayments.clear();
        }
      }
    } catch (e) {
       print("Error in loadIndividualPendingPayments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> loadIndividualPendingPayments(String customerId) async {
  //   try {
  //     isLoading.value = true;
  //     var response = await _apiWorker.getAllPendingPaymentIndividual(
  //       customerId: customerId,
  //     );
  //     // ignore: unnecessary_null_comparison
  //     if (response.data != null) {
  //       individualPendingPayments.assignAll(response.data);
  //     } else {
  //       individualPendingPayments.clear();
  //     }
  //   } catch (e) {
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
    loadOrderData(chartIndex: newIndex);
  }

  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchModel.startDate = NKDateUtils.apiDayFormat(startDate);
      searchModel.endDate = NKDateUtils.apiDayFormat(endDate);
      loadOrderData;
    } else {
      searchModel.startDate = "";
      searchModel.endDate = "";
      loadOrderData;
    }
    refresh();
  }

  void processPayments(
      List<IndividualPendingData> selectedItemsList, num enteredAmount) {
    num remainingAmount = enteredAmount;

    for (int i = 0; i < selectedItemsList.length; i++) {
      num amountToBePaid;

      if (selectedItemsList[i].receivableAmount != null) {
        amountToBePaid = selectedItemsList[i].receivableAmount!;
      } else {
        amountToBePaid = selectedItemsList[i].orderTotal;
      }

      log(
          "Processing orderId: ${selectedItemsList[i].orderId}, Amount to be paid: $amountToBePaid, Remaining amount: $remainingAmount");

      if (remainingAmount <= 0) {
        break;
      }

      if (remainingAmount >= amountToBePaid) {
        log(
            "Paying $amountToBePaid for orderId: ${selectedItemsList[i].orderId}");
        remainingAmount -= amountToBePaid;
      } else {
        log(
            "Paying $remainingAmount for orderId: ${selectedItemsList[i].orderId}");
        remainingAmount = 0;
      }
    }

    if (remainingAmount > 0) {
    }
  }

  Widget orderStatusWidget(String status, Color color) {
    return Container(
      padding: nkRegularPadding(),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: MyRegularText(
        label: status,
      ),
    );
  }
}
