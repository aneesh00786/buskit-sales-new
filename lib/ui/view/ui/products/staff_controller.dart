import 'dart:convert';
import 'dart:developer';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/sales_target_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../../api_handler/api_worker.dart';
import '../../../components/diloags/product_details_diloag/model/staff_responce.dart';
import '../customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';

class StaffController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();

  RxList<StaffData> staffDataList = <StaffData>[].obs;
  RxList<Data> customerData = <Data>[].obs;
  Map<String, dynamic> mainColumn = {};

  SearchModel searchModel = SearchModel();
  PaginationModel customerPage = PaginationModel();
  DateTime selectedDate = DateTime.now();
  List<CustomerAndOrderData> customerAndOrderList =
      <CustomerAndOrderData>[].obs;
  Rx<StaffData> selectedStaff = StaffData().obs;
  RxList<OrderData> orderDataList = <OrderData>[].obs;
  RxList<String> orderTableColumCategory = [
    " Customer List",
    "Order Number",
    "Order created",
    "Order Price",
    "Status",
    ""
  ].obs;

  // List<NkCustomProgressData> progressList = [
  //   NkCustomProgressData(
  //       progress: 100, progressColor: Color(0xFF3B6491), progressText: '20%'),
  //   NkCustomProgressData(
  //       progress: 100, progressColor: Color(0xFF15396A), progressText: '60%'),
  //   NkCustomProgressData(
  //       progress: 100, progressColor: Color(0xFF7A8F3D), progressText: '80%'),
  // ];

  RxBool isPasswordVisible = false.obs;

  RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  TextEditingController salesmanNameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController mobileNumberTextController = TextEditingController();
  TextEditingController zipCodeTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController addressTextController = TextEditingController();
  TextEditingController cityTextController = TextEditingController();
  TextEditingController stateTextController = TextEditingController();
  RxList<SalesmanTargetData> salesmanTargetList = <SalesmanTargetData>[].obs;
  RxBool isTargetLoading = false.obs;
  Future<List<SalesmanTargetData>> loadSalesmanTarget(
      String salesmanId, String month, String year) async {
    try {
      isTargetLoading.value = true;

      var data = await ApiWorker().fetchSalesmanTarget(salesmanId, month, year);
      salesmanTargetList.assignAll(data.data!);
      return data.data!;
    } finally {
      isTargetLoading.value = false; // End loading
    }
  }
  Future<void> updateCategoryTarget(
    String salesmanId,
    String month,
    String year,
    Map<dynamic, String> categoryData,
    Map<dynamic, String> weeklyTarget,
  ) async {
    try {
      var data = await ApiWorker().updateCategoryTargetValue(
          salesmanId, month, year, categoryData, weeklyTarget);
      print(data.statusMessage);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
  Widget get getIsPasswordVisible {
    if (isPasswordVisible.value) {
      return IconButton(
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
        },
        icon: const Icon(Icons.visibility),
      );
    } else {
      return IconButton(
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
        },
        icon: const Icon(Icons.visibility_off),
      );
    }
  }

  // addSalesman({required String idPath, required String browserPath}) async {
  //   var mapData = await addStaffMapData(idPath, browserPath);
  //   await _apiWorker.addStaff(mapData).onError((error, stackTrace) {
  //     btnController.error();
  //     btnController.reset();
  //     return Future.error(error.toString());
  //   });
  //   btnController.success();
  //   Get.back();
  //   clearAllFileds;
  //   loadStaffDataList;
  // }

  Future<Map<String, dynamic>> addStaffMapData(
      String idPath, String browserPath) async {
    Map<String, dynamic> data = {
      "fullname": salesmanNameTextController.text.trim(),
      "mobileno": mobileNumberTextController.text.trim(),
      "email": emailTextController.text.trim(),
      "address": addressTextController.text.trim(),
      "Password": passwordTextController.text.trim(),
      "town": cityTextController.text.trim(),
      "state": stateTextController.text.trim(),
      "zipcode": zipCodeTextController.text.trim(),
      "salesmanpicture":
          await NkCommonFunction.getFormData(browserPath, mapKeyName: ''),
      "salesmanIDpicture":
          await NkCommonFunction.getFormData(idPath, mapKeyName: ''),
    };

    return data;
  }

  // Future<List<StaffData>> get loadStaffDataList async {
  //   var data = await _apiWorker.getSalesManList(searchModel);
  //   staffDataList.value = data.staffData!;
  //   return data.staffData!;
  // }

//// CV ADD THIS GET CUSTOMER////
//   Future<FetchSalesmanOfCustomer> getFetchSalesmanOfCustomer(String id) async {
//     var data = await _apiWorker.fetchSalesmanOfCustomer(id);
//     if (data.statusCode == 200) {
//       customerData.value = data.data!;
//       refresh();
//     }
//     return data;
//   }

  ////fetch customer////
  Future<Iterable<CustomerAndOrderData>> loadCustomer(String? id) async {
    log("SALESMAN ${selectedStaff.value.salesmanId}");
    print("StartDate ${searchModel.startDate}");
    var data = await _apiWorker.getCustomer(
        // id, searchModel, PaginationModel()
        );
    customerAndOrderList.assignAll(data.custAndOrderdata!);
    refresh();
    return data.custAndOrderdata!;
  }

  ////fetch order////
  Future<List<OrderData>> loadOrderData(String? id) async {
    var data = await _apiWorker.getOrdersData(
        salesmanId: id,
        searchModel: searchModel,
        paginationModel: PaginationModel());
    orderDataList.assignAll(data.data!);
    return data.data!;
  }

/*  Future<Iterable<CustomerAndOrderData>> get loadCustomer async {
    */ /*  log("SALESMAN ${selectedStaff.value.salesmanId}");*/ /*
    print("StartDate ${searchModel.startDate}");
    var data = await _apiWorker.getCustomer('', searchModel, PaginationModel());
    customerAndOrderList.assignAll(data.custAndOrderdata!);
    refresh();
    return data.custAndOrderdata!;
  }*/

  // Future<Map<String, dynamic>> get loadDataOfStaffCategory async =>
  //     jsonDecode(await rootBundle.loadString(Assets.jsonDataStaffCategoryName));

  // updateCalender(DateTime? startDate, DateTime? endDate) {
  //   selectedDate = endDate ?? DateTime.now();
  //   if (startDate != null && endDate != null) {
  //     searchModel.startDate = NKDateUtils.apiDayFormat(startDate);
  //     searchModel.endDate = NKDateUtils.apiDayFormat(endDate);
  //     loadStaffDataList;
  //     loadCustomer;
  //     loadOrderData;
  //   } else {
  //     searchModel.startDate = "";
  //     searchModel.endDate = "";
  //     loadStaffDataList;
  //     loadCustomer;
  //     loadOrderData;
  //   }
  //   refresh();
  // }

  get clearAllFileds => {
        salesmanNameTextController.clear(),
        emailTextController.clear(),
        mobileNumberTextController.clear(),
        zipCodeTextController.clear(),
        passwordTextController.clear(),
        addressTextController.clear(),
        cityTextController.clear(),
        stateTextController.clear(),
      };
}
