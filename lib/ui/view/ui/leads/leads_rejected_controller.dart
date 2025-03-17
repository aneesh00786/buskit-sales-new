

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

enum CustomerStatus { newReq, assignedTo, rejected }

class RejectedLeadsController extends GetxController {
  RxInt selectedTabIndex = 0.obs;

  RxList<LeadCustomerData> rejectedLeadsDataList = <LeadCustomerData>[].obs;

  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
  }

  Future updateRejectedLead(LeadCustomerData leadData) async {
    final companyId = SessionHelper.loginSavedData?.company_id ?? 0;
    final sendData = leadData.toUpdateJson();
    sendData['companyId'] = companyId;
    var data =
        await ApiWorker().updateCustomer(sendData).onError((error, stackTrace) {
      btnController.error();
      btnController.reset();
      return Future.error(error.toString());
    });
    if (data.statusCode == 200) {
      btnController.success();
      Get.back<LeadCustomerData>(result: leadData);
    }
  }

  handleRejectedLeadStatus(int customerId, String statusResponse) async {
    await ApiWorker()
        .handleLeadStatus(customerId, statusResponse)
        .onError((error, stackTrace) {
      btnController.error();
      btnController.reset();
      return Future.error(error.toString());
    });
    btnController.success();
    Get.back();
    loadRejectedLeadsData;
  }
  RxBool isLeadsRejectsDataLoading = false.obs;
  Future<List<LeadCustomerData>> get loadRejectedLeadsData async {
    isLeadsRejectsDataLoading.value = false;
    try {
      var data = await ApiWorker()
          .getLeadsRejectedData(paginationModel: PaginationModel());
      rejectedLeadsDataList.assignAll(data.leadCustomerData!);
      return data.leadCustomerData!;
    } catch (e) {
      rethrow;
    } finally {
      isLeadsRejectsDataLoading.value = false;
    }
  }

  CustomerStatus typeToConvertStatus(int statusType) {
    switch (statusType) {
      case 1:
        return CustomerStatus.newReq;
      case 2:
        return CustomerStatus.assignedTo;
      case 3:
        return CustomerStatus.rejected;

      default:
        return CustomerStatus.rejected;
    }
  }

  int filterStatus(String status) {
    switch (status) {
      case "new":
        return 1;
      case "accepted":
        return 2;
      case "rejected":
        return 3;

      default:
        return 1;
    }
  }

  Widget rejectedLeadStatus(CustomerStatus status,
      {String? assignedTo, Function()? onClick}) {
    switch (status) {
      case CustomerStatus.newReq:
        return _newReqWidget(onClick);
      case CustomerStatus.assignedTo:
        return _assignedToWidget(assignedTo ?? '');
      case CustomerStatus.rejected:
        return _rejectedWidget;
    }
  }

  Widget _newReqWidget(Function()? onClick) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: nkRegularPadding(),
          child: const MyRegularText(
            label: newStatus,
            color: buttonTextColor,
          ),
        ),
      ),
    );
  }

  Widget get _rejectedWidget {
    return Container(
      padding: nkRegularPadding(),
      decoration: BoxDecoration(
        color: errorColor,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: const MyRegularText(
        label: rejected,
        color: buttonTextColor,
      ),
    );
  }

  Widget _assignedToWidget(String assignedTo) {
    return Container(
      padding: nkRegularPadding(),
      child: MyRegularText(
        label: assignedTo,
        color: switchColor,
      ),
    );
  }
}
