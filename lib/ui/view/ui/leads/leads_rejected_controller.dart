import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
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
  //final ApiWorker _apiWorker = Get.find();
  RxInt selectedTabIndex = 0.obs; // Track the selected tab index

  RxList<LeadCustomerData> rejectedLeadsDataList = <LeadCustomerData>[].obs;

  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  // TextEditingController customerNameTextController = TextEditingController();
  // TextEditingController emailTextController = TextEditingController();
  // TextEditingController mobileNumberTextController = TextEditingController();
  // TextEditingController zipCodeTextController = TextEditingController();
  // TextEditingController remarkTextController = TextEditingController();

  // TextEditingController addressTextController = TextEditingController();
  // TextEditingController cityTextController = TextEditingController();
  // TextEditingController stateTextController = TextEditingController();

  // TextEditingController businessNameTextEditingController =
  //     TextEditingController();
  // TextEditingController businessContactTextEditingController =
  //     TextEditingController();

  // get clearAllFields => {
  //       customerNameTextController.clear(),
  //       emailTextController.clear(),
  //       mobileNumberTextController.clear(),
  //       zipCodeTextController.clear(),
  //       addressTextController.clear(),
  //       cityTextController.clear(),
  //       stateTextController.clear(),
  //       remarkTextController.clear(),
  //       businessNameTextEditingController.clear(),
  //       businessContactTextEditingController.clear(),
  //     };

  // RxList<String> rejectedLeadsTableHeadersList = [
  //   "Customer name",
  //   "Address",
  //   "Town",
  //   "Zipcode",
  //   "Status",
  // ].obs;

  // handleRejectedLeadsStatus(int customerId, String statusResponce) async {
  //   await _apiWorker
  //       .handleLeadStatus(customerId, statusResponce)
  //       .onError((error, stackTrace) {
  //     btnController.error();
  //     btnController.reset();
  //     return Future.error(error.toString());
  //   });
  //   btnController.success();
  //   Get.back();
  //   loadRejectedLeadsData;
  // }

  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
    // loadRejectedLeadsData();
  }

  Future updateRejectedLead(LeadCustomerData leadData) async {
    var data = await ApiWorker()
        .updateCustomer(leadData.toUpdateJson())
        .onError((error, stackTrace) {
      btnController.error();
      btnController.reset();
      return Future.error(error.toString());
    });

    if (data.statusCode == 200) {
      btnController.success();
      Get.back<LeadCustomerData>(result: leadData);
    }
  }

  // Future addRejectedLead(
  //     {required String browserPath,
  //     required String assignId,
  //     bool isAssigned = false}) async {
  //   log('in1++');
  //   var mapData = await addStaffMapData(browserPath, assignId, isAssigned);
  //   await _apiWorker.addCustomer(mapData).onError((error, stackTrace) {
  //     btnController.error();
  //     btnController.reset();
  //     return Future.error(error.toString());
  //   });
  //   btnController.success();

  //   if (isAssigned) {
  //     Get.close(2);
  //   } else {
  //     Get.back();
  //   }
  //   clearAllFields;
  //   loadRejectedLeadsData;
  // }

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

  // Future<Map<String, dynamic>> addStaffMapData(
  //     String browserPath, String assignId, bool isAssigned) async {
  //   log('in2++');
  //   var image = browserPath.isNotEmpty
  //       ? await NkCommonFunction.getFormData(browserPath, mapKeyName: '')
  //       : '';
  //   log('in3++ $image');
  //   Map<String, dynamic> data = {
  //     "fullname": customerNameTextController.text.trim(),
  //     "mobileno": mobileNumberTextController.text.trim(),
  //     "email": emailTextController.text.trim(),
  //     "address": addressTextController.text.trim(),
  //     "town": cityTextController.text.trim(),
  //     "state": stateTextController.text.trim(),
  //     "zipcode": zipCodeTextController.text.trim(),
  //     "businessname": businessNameTextEditingController.text.trim(),
  //     "businesscontact": businessContactTextEditingController.text.trim(),
  //     "remark": remarkTextController.text.trim(),
  //     "customerpicture": image,
  //     "salesman_id": '',
  //     "status_type": 3,
  //     "salesman_name": "",
  //   };

  //   log("data: $data");

  //   return data;
  // }

  Future<List<LeadCustomerData>> get loadRejectedLeadsData async {
    var data = await ApiWorker().getLeadsRejectedData(
        paginationModel: PaginationModel());
    rejectedLeadsDataList.assignAll(data.leadCustomerData!);
    return data.leadCustomerData!;
  }

  /// Widget Section
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
