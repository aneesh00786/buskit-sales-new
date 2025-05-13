import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:get/get.dart';

enum CustomerStatus { newReq, assignedTo, rejected }

class CustomersController extends GetxController {
  RxInt selectedTabIndex = 0.obs;

    RxInt totalPages = 1.obs;
  RxInt currentPage = 1.obs;

  RxList<LeadCustomerData> customersDataList = <LeadCustomerData>[].obs;
  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
  }

  RxBool isLeadsCustomerDataLoading = false.obs;
  Future<List<LeadCustomerData>> get loadLeadsCustomerData async {
    isLeadsCustomerDataLoading.value = true;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    try {
      var data = await ApiWorker()
          .getLeadsCustomerData(currentPage.value);
          totalPages.value = data.pagination?.totalPages ?? 0;
      customersDataList.assignAll(data.leadCustomerData!);
      return data.leadCustomerData!;
    } catch (e) {
      rethrow;
    } finally {
      isLeadsCustomerDataLoading.value = false;
    }
  }

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;

      loadLeadsCustomerData;
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadLeadsCustomerData;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadLeadsCustomerData;
    }
  }
}
