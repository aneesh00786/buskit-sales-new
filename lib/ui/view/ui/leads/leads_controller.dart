import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:rounded_loading_button/rounded_loading_button.dart';

enum CustomerStatus { newReq, assignedTo, rejected }

class LeadsController extends GetxController {
  final ApiWorker _apiWorker = Get.find();

  RxList<LeadCustomerData> leadsCustomerDataList = <LeadCustomerData>[].obs;

  // RoundedLoadingButtonController btnController =
  //     RoundedLoadingButtonController();

  TextEditingController customerNameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController mobileNumberTextController = TextEditingController();
  TextEditingController zipCodeTextController = TextEditingController();
  TextEditingController remarkTextController = TextEditingController();

  TextEditingController addressTextController = TextEditingController();
  TextEditingController cityTextController = TextEditingController();
  TextEditingController stateTextController = TextEditingController();

  TextEditingController businessNameTextEditingController =
      TextEditingController();
  TextEditingController businessContactTextEditingController =
      TextEditingController();

  get clearAllFileds => {
        customerNameTextController.clear(),
        emailTextController.clear(),
        mobileNumberTextController.clear(),
        zipCodeTextController.clear(),
        addressTextController.clear(),
        cityTextController.clear(),
        stateTextController.clear(),
        remarkTextController.clear(),
        businessNameTextEditingController.clear(),
        businessContactTextEditingController.clear(),
      };

  RxList<String> coustomerTabelsHeadersList = [
    "Customer name",
    "Address",
    "Town",
    "Zipcode",
    "Status",
  ].obs;

  // addLeads({required String browserPath}) async {
  //   var mapData = await addStaffMapData(browserPath);
  //   await _apiWorker.addCustomer(mapData).onError((error, stackTrace) {
  //     btnController.error();
  //     btnController.reset();
  //     return Future.error(error.toString());
  //   });
  //   btnController.success();
  //   Get.back();
  //   clearAllFileds;
  //   loadLeadsCustomerData;
  // }

  Future addLeads(
      {required String browserPath, bool isAssigned = false}) async {
    log('in1++');
    var mapData = await addStaffMapData(browserPath);
    await _apiWorker.addCustomer(mapData).onError((error, stackTrace) {
      // btnController.error();
      // btnController.reset();
      return Future.error(error.toString());
    });
    // btnController.success();

    if (isAssigned) {
      Get.close(2);
    } else {
      Get.back();
    }
    clearAllFileds;
    loadLeadsCustomerData;
  }

  Future<Map<String, dynamic>> addStaffMapData(String browserPath) async {
    Map<String, dynamic> data = {
      "fullname": customerNameTextController.text.trim(),
      "mobileno": mobileNumberTextController.text.trim(),
      "email": emailTextController.text.trim(),
      "address": addressTextController.text.trim(),
      "town": cityTextController.text.trim(),
      "state": stateTextController.text.trim(),
      "zipcode": zipCodeTextController.text.trim(),
      "businessname": businessNameTextEditingController.text.trim(),
      "businesscontact": businessContactTextEditingController.text.trim(),
      "remark": remarkTextController.text.trim(),
      "cutomerpicture":
          await NkCommonFunction.getFormData(browserPath, mapKeyName: ''),
      "salesman_id": SessionHelper.loginSavedData!.salesmanId,
      "status_type": 3,

      /// is for SalesMan
    };

    log("data: ${data}");

    return data;
  }

  Future updateLeads(LeadCustomerData leadData) async {
    var data = await _apiWorker
        .updateCustomer(leadData.toUpdateJson())
        .onError((error, stackTrace) {
      // btnController.error();
      // btnController.reset();
      return Future.error(error.toString());
    });

    if (data.statusCode == 200) {
      // btnController.success();
      Get.back<LeadCustomerData>(result: leadData);
    }
  }

  Future<List<LeadCustomerData>> get loadLeadsCustomerData async {
    var data = await _apiWorker.getLeadsData(
        SessionHelper.loginSavedData!.salesmanId!,
        paginationModel: PaginationModel());
    leadsCustomerDataList.assignAll(data.leadCustomerData!);
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

  Widget leadsCustomerStatus(CustomerStatus status, {String? assignedTo}) {
    switch (status) {
      case CustomerStatus.newReq:
        return _newReqWidget;
      case CustomerStatus.assignedTo:
        return _assignedToWidget(assignedTo ?? '');
      case CustomerStatus.rejected:
        return _rejectedWidget;
    }
  }

  Widget get _newReqWidget {
    return Container(
      padding: nkRegularPadding(),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: const MyRegularText(
        label: newStatus,
        color: buttonTextColor,
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
    return MyRegularText(
      label: assignedTo,
      color: switchColor,
    );
  }
}
