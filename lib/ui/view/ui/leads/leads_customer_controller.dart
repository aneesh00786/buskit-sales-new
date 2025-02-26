import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:get/get.dart';

enum CustomerStatus { newReq, assignedTo, rejected }

class CustomersController extends GetxController {
  RxInt selectedTabIndex = 0.obs;

  RxList<LeadCustomerData> customersDataList = <LeadCustomerData>[].obs;

  // RoundedLoadingButtonController btnController =
  //     RoundedLoadingButtonController();

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

  // RxList<String> customerTableHeadersList = [
  //   "Customer name",
  //   "Address",
  //   "Town",
  //   "Zipcode",
  //   "Status",
  // ].obs;

  void updateTabIndex(int newIndex) {
    selectedTabIndex.value = newIndex;
    // loadCustomerData();
  }

  // Future updateCustomer(LeadCustomerData customerData) async {
  //   var data = await _apiWorker
  //       .updateCustomer(customerData.toUpdateJson())
  //       .onError((error, stackTrace) {
  //     btnController.error();
  //     btnController.reset();
  //     return Future.error(error.toString());
  //   });

  //   if (data.statusCode == 200) {
  //     btnController.success();
  //     Get.back<LeadCustomerData>(result: customerData);
  //   }
  // }

  // Future addCustomer(
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
  //   loadCustomerData;
  // }

  // handleCustomerStatus(int customerId, String statusResponse) async {
  //   await _apiWorker
  //       .handleLeadStatus(customerId, statusResponse)
  //       .onError((error, stackTrace) {
  //     btnController.error();
  //     btnController.reset();
  //     return Future.error(error.toString());
  //   });
  //   btnController.success();
  //   Get.back();
  //   loadCustomerData;
  // }

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

  RxBool isLeadsCustomerDataLoading = false.obs;
  Future<List<LeadCustomerData>> get loadLeadsCustomerData async {
    isLeadsCustomerDataLoading.value = true;
    final salesmanId = SessionHelper.loginSavedData?.salesmanId ?? '';
    try {
      var data = await ApiWorker().getLeadsCustomerData(salesmanId,
          paginationModel: PaginationModel());
      customersDataList.assignAll(data.leadCustomerData!);
      return data.leadCustomerData!;
    } catch (e) {
      rethrow;
    } finally {
      isLeadsCustomerDataLoading.value = false;
    }
  }

  /// Widget Section
  // CustomerStatus typeToConvertStatus(int statusType) {
  //   switch (statusType) {
  //     case 1:
  //       return CustomerStatus.newReq;
  //     case 2:
  //       return CustomerStatus.assignedTo;
  //     case 3:
  //       return CustomerStatus.rejected;

  //     default:
  //       return CustomerStatus.rejected;
  //   }
  // }

  // int filterStatus(String status) {
  //   switch (status) {
  //     case "new":
  //       return 1;
  //     case "accepted":
  //       return 2;
  //     case "rejected":
  //       return 3;

  //     default:
  //       return 1;
  //   }
  // }

  // Widget customerStatus(CustomerStatus status,
  //     {String? assignedTo, Function()? onClick}) {
  //   switch (status) {
  //     case CustomerStatus.newReq:
  //       return _newReqWidget(onClick);
  //     case CustomerStatus.assignedTo:
  //       return _assignedToWidget(assignedTo ?? '');
  //     case CustomerStatus.rejected:
  //       return _rejectedWidget;
  //   }
  // }

  // Widget _newReqWidget(Function()? onClick) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: primaryColor,
  //       borderRadius:
  //           BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
  //     ),
  //     child: InkWell(
  //       onTap: onClick,
  //       child: Padding(
  //         padding: nkRegularPadding(),
  //         child: const MyRegularText(
  //           label: newStatus,
  //           color: buttonTextColor,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget get _rejectedWidget {
  //   return Container(
  //     padding: nkRegularPadding(),
  //     decoration: BoxDecoration(
  //       color: errorColor,
  //       borderRadius:
  //           BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
  //     ),
  //     child: const MyRegularText(
  //       label: rejected,
  //       color: buttonTextColor,
  //     ),
  //   );
  // }

  // Widget _assignedToWidget(String assignedTo) {
  //   return Container(
  //     padding: nkRegularPadding(),
  //     child: MyRegularText(
  //       label: assignedTo,
  //       color: switchColor,
  //     ),
  //   );
  // }
}
