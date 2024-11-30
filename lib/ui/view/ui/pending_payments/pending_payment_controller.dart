import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_responce/pending_payment_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PendingPaymentController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  RxList<CustomerData> orderDataList = <CustomerData>[].obs;
  RxInt selectedTabIndex = 0.obs; // Track the selected tab index
  Rx<ChartDetails> chartData =
      ChartDetails(nearlyDue: 0, due: 0, all: 0, overdue: 0).obs;
  int? totalAmount;
  int? nearlyDueAmount;
  int? dueAmount;
  int? overdueAmount;

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

// Call this method when an item is selected or deselected
  void toggleItemSelection(IndividualPendingData item) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
  }

// This should return the currently selected items
  List<IndividualPendingData> getSelectedItems() {
    return selectedItems.toList();
  }

  Future<void> loadOrderData({required int chartIndex}) async {
    final salesmanId = SessionHelper.loginSavedData?.salesmanId??'';
    print("Loading data for chartIndex: $chartIndex");
    try {
      var data = await _apiWorker.getPendingPaymentData(
        chartIndex: chartIndex,
        searchModel: searchModel,
        paginationModel: PaginationModel(),
        salesmanId: salesmanId
      );

      if (data.data != null) {
        orderDataList.assignAll(data.data!);
        chartData.value = data.chartDetails;
        totalAmount = data.totalAmount;
        nearlyDueAmount = data.nearlydueAmount;
        dueAmount = data.dueAmount;
        overdueAmount = data.overdueAmount;
        print("Data loaded successfully: ${data.data}");
      } else {
        orderDataList.clear();
        print("No data received for chartIndex: $chartIndex");
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> loadIndividualPendingPayments(String customerId) async {
    try {
      isLoading.value = true;
      var response = await _apiWorker.getAllPendingPaymentIndividual(
        customerId: customerId,
      );
      if (response.data != null) {
        individualPendingPayments.assignAll(response.data!);
        print(response.data);
        print("Individual Pending Payments loaded successfully");
      } else {
        individualPendingPayments.clear();
        print(
            "No individual pending payments found for customerId: $customerId");
      }
    } catch (e) {
      print("Error loading individual pending payments: $e");
    } finally {
      isLoading.value = false;
    }
  }

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

//   Future<void> processCustomerPayment({
//   required String checkDueDate,
//   required String checkNumber,
//   required String detail,
//   required String orderId,
//   required int paymentType,
//   required double receivedAmount,
//   required String transactionDate,
//   required String transactionId,
// }) async {
//   try {
//     isLoading.value = true;

//     // Call the API worker to process the customer payment
//     var response = await _apiWorker.customerPayment(
//       data: FormData.fromMap({
//         "check_due_date": checkDueDate,
//         "check_number": checkNumber,
//         "detail": detail,
//         "order_id": orderId,
//         "payment_type": paymentType,
//         "received_amount": receivedAmount,
//         "transaction_date": transactionDate,
//         "transaction_id": transactionId,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print("Customer payment processed successfully.");
//       // Handle success case (e.g., update the UI or show success message)
//     } else {
//       print("Failed to process customer payment. Status code: ${response.statusCode}");
//       // Handle non-success status code (e.g., show error message)
//     }
//   } catch (e) {
//     print("Error processing customer payment: $e");
//     // Handle error case (e.g., show error message)
//   } finally {
//     isLoading.value = false;
//   }
// }

  void processPayments(
      List<IndividualPendingData> selectedItemsList, int enteredAmount) {
    print("Selected Items: $selectedItemsList");
    int remainingAmount = enteredAmount;

    // for (var item in selectedItems)
    for (int i=0; i<selectedItemsList.length;i++) {
      int amountToBePaid;

      if (selectedItemsList[i].receivableAmount != null) {
        amountToBePaid = selectedItemsList[i].receivableAmount!;
      } else {
        amountToBePaid = selectedItemsList[i].orderTotal;
      }

      print(
          "Processing orderId: ${selectedItemsList[i].orderId}, Amount to be paid: $amountToBePaid, Remaining amount: $remainingAmount");

      if (remainingAmount <= 0) {
        break;
      }

      if (remainingAmount >= amountToBePaid) {
        print("Paying $amountToBePaid for orderId: ${selectedItemsList[i].orderId}");
        remainingAmount -= amountToBePaid;
      } else {
        print("Paying $remainingAmount for orderId: ${selectedItemsList[i].orderId}");
        remainingAmount = 0;
      }
    }

    if (remainingAmount > 0) {
      print("Remaining balance after payment: $remainingAmount");
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
