// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

enum CustomerStatus { newReq, assignedTo, rejected }

class LeadsController extends GetxController {
  RxInt selectedTabIndex = 0.obs;
  RxList<LeadCustomerData> leadsCustomerDataList = <LeadCustomerData>[].obs;
  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  late LeadsForUpdatingData leadForUpdateData;

  RxInt totalPages = 1.obs;
  RxInt currentPage = 1.obs;

  RxInt selectAllocateSalesman = 0.obs;
  TextEditingController businessNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController businessContactController = TextEditingController();
  TextEditingController deliveryAddressController = TextEditingController();
  TextEditingController deliveryTownController = TextEditingController();
  TextEditingController deliveryStateController = TextEditingController();
  TextEditingController deliveryZipcodeController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  get clearAllFileds => {
        businessNameController.clear(),
        addressController.clear(),
        townController.clear(),
        stateController.clear(),
        zipcodeController.clear(),
        mobileNoController.clear(),
        emailController.clear(),
        telephoneController.clear(),
        fullnameController.clear(),
        businessContactController.clear(),
        deliveryAddressController.clear(),
        deliveryTownController.clear(),
        deliveryStateController.clear(),
        deliveryZipcodeController.clear(),
        remarkController.clear(),
      };
  RxList<String> coustomerTabelsHeadersList = [
    "Customer name",
    "Address",
    "Town",
    "Zipcode",
    "Status",
  ].obs;
  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
    // loadOrderData(chartIndex: newIndex);
  }

  void deleteLead(int id) {
    leadsCustomerDataList.removeWhere((lead) => lead.id == id);
  }

  Future getLeadsForUpdate(String customerId) async {
    var data = await ApiWorker().fetchLeadsForUpdate(customerId);
    leadForUpdateData = data;
  }

  RxBool isUpdating = false.obs;

  Future updateLeads(Map<String, dynamic> leadData, File? leadImage) async {
    isUpdating.value = true;
    var data = await ApiWorker()
        .updateCustomer(leadData, leadImage)
        .onError((error, stackTrace) {
      btnController.error();
      btnController.reset();
      return Future.error(error.toString());
    });
    isUpdating.value = true;

    if (data.statusCode == 200) {
      btnController.success();
      Get.back();
      loadLeadsCustomerData;
    }
  }

  Future<Map<String, dynamic>> addLeadsMapData() async {
    Map<String, dynamic> data = {
      "userid": SessionHelper.loginSavedData?.salesmanId ?? '',
      "salesman_id": SessionHelper.loginSavedData?.salesmanId ?? '',
      "businessname": businessNameController.text.trim(),
      "address": addressController.text.trim(),
      "town": townController.text.trim(),
      "state": stateController.text.trim(),
      "zipcode": int.tryParse(zipcodeController.text.trim()) ?? 0,
      "mobileno": int.tryParse(mobileNoController.text.trim()) ?? 0,
      "email": emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : "N/A",
      "tfn": int.tryParse(telephoneController.text.trim()) ?? 0,
      "fullname": fullnameController.text.trim(),
      "businesscontact":
          int.tryParse(businessContactController.text.trim()) ?? 0,
      "delivery_address": deliveryAddressController.text.trim(),
      "delivery_town": deliveryTownController.text.trim(),
      "delivery_state": deliveryStateController.text.trim(),
      "delivery_zipcode":
          int.tryParse(deliveryZipcodeController.text.trim()) ?? 0,
      "remark": remarkController.text.trim(),
      "status_type": 3,
      "company_id": SessionHelper.loginSavedData?.company_id ?? 0,
    };

    return data;
  }

  Future addLeads({
    required File leadsImage,
    required BuildContext context,
  }) async {
    try {
      var mapData = await addLeadsMapData();

      await ApiWorker().addCustomer(mapData, leadsImage);

      btnController.success();
      Get.back();
      clearAllFileds;
      loadLeadsCustomerData;
    } catch (error) {
      showCustomToastDisplay(
        context,
        error.toString(),
        Colors.red,
        Icons.close,
      );

      btnController.error();
      btnController.reset();

      return Future.error(error.toString());
    }
  }

  handleLeadsStatus(int customerId, String statusResponce) async {
    await ApiWorker()
        .handleLeadStatus(customerId, statusResponce)
        .onError((error, stackTrace) {
      btnController.error();
      btnController.reset();
      return Future.error(error.toString());
    });
    btnController.success();
    Get.back();
    loadLeadsCustomerData;
  }

  RxBool isLeadsCustomerDataLoading = false.obs;
  Future<List<LeadCustomerData>> get loadLeadsCustomerData async {
    isLeadsCustomerDataLoading.value = true;
    try {
      var data = await ApiWorker().getLeadsData(currentPage.value);
      totalPages.value = data.pagination?.totalPages ?? 0;
      leadsCustomerDataList.assignAll(data.leadCustomerData!);
      return data.leadCustomerData!;
    } catch (e) {
      rethrow;
    } finally {
      isLeadsCustomerDataLoading.value = false;
    }
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

  Widget leadsCustomerStatus(CustomerStatus status,
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

  void deleteLeads(String customerId) {
    ApiWorker().deleteCustomer(customerId);
    loadLeadsCustomerData;
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
