import 'dart:developer';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_common_function.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/checkin_checkout_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/customer_data_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/performance_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/model/visit_data_modfel.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_table_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../../api_handler/api_worker.dart';
import '../../../components/diloags/product_details_diloag/model/staff_responce.dart';
import '../customer_and_orders/customer_and_order_responce/customer_and_order_responce.dart';

class StaffController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();

  late TabController tabController;

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
  RxBool isWeekly = true.obs;
  RxInt selectedTabIndex = 0.obs;
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
  var targetControllers = <TextEditingController>[].obs;
  var salesmanTargetList = PerformanceData().obs;
  var isLoading = false.obs;
  var isLoadingPass = false.obs;
  var isTopDataLoading = false.obs;
  var checkInOutData = Rxn<CheckInOut>();
  var visitData = Rxn<VisitData>();
  var customerDatas = Rxn<CustomerData>();

  Future<void> loadWeeklyType() async {
    final weeklyType = await ApiWorker().getWeeklyType();
    log('Weekly Type fetched from API: $weeklyType');
    isWeekly.value = weeklyType == "true";
    log("Updated Weekly state: ${isWeekly.value}");
  }

  Future<void> loadSalesmanTarget(String salesmanId, String month, String year,
      String monthName, bool isFromLogin, int compId) async {
    log("✅ loadSalesmanTarget STARTED:");
    isLoading.value = true;
    try {
      var response = await ApiWorker().fetchSalesmanPerformanceData(
        monthName: monthName,
        year: int.parse(year),
        compId: compId,
        salesId: salesmanId,
        isfromLogin: isFromLogin,
      );
      if (response != null) {
        log('📊 Response contains categoryPerformance: $response');
        salesmanTargetList.update((list) {
          if (list != null) {
            list.navbarAndTargetContent = response.navbarAndTargetContent;
            list.categoryPerformance = response.categoryPerformance ?? [];
            list.valueTarget = response.valueTarget ?? [];
            list.months = response.months ?? [];
          }
        });
      } else {
        log('❌ Response was null');
      }
    } on DioException catch (e) {
      log('❗ Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSalesmanTopBarData(String monthName, int tabStatus) async {
    isTopDataLoading.value = true;
    try {
      final jsonData =
          await ApiWorker().fetchSalesmanTopBarData(monthName, tabStatus);
      if (jsonData != null) {
        switch (tabStatus) {
          case 1:
            checkInOutData.value = CheckInOut.fromJson(jsonData);
          case 2:
            checkInOutData.value = CheckInOut.fromJson(jsonData);
            break;
          case 3:
            visitData.value = VisitData.fromJson(jsonData);
            break;
          case 4:
            customerDatas.value = CustomerData.fromJson(jsonData);
            break;
          default:
            throw Exception('Invalid tabStatus: $tabStatus');
        }
      } else {
        log("No data returned from the API.");
      }
    } catch (e) {
      log("Error 2: $e");
    } finally {
      isTopDataLoading.value = false;
    }
  }

  Future<void> loadSalesmanTargetForSelectedTab({
    required int selectedTabIndex,
    required String staffId,
    required String currentYear,
    String? monthName,
    bool? isFromLogin,
    int? compId,
  }) async {
    final selectedMonth = selectedTabIndex;
    final selectedMonthName = isFromLogin == true
        ? monthName
        : DateFormat.MMMM().format(DateTime(0, selectedMonth));
    await loadSalesmanTarget(staffId, selectedMonthName ?? '', currentYear,
        selectedMonthName ?? '', isFromLogin ?? false, compId ?? 0);
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

  Future<Iterable<CustomerAndOrderData>> loadCustomer(String? id) async {
    log("SALESMAN ${selectedStaff.value.salesmanId}");
    log("StartDate ${searchModel.startDate}");
    var data = await _apiWorker.getCustomer();
    customerAndOrderList.assignAll(data.custAndOrderdata!);
    refresh();
    return data.custAndOrderdata!;
  }

  Future<List<OrderData>> loadOrderData(String? id) async {
    var data = await _apiWorker.getOrdersData(
        salesmanId: id,
        searchModel: searchModel,
        paginationModel: PaginationModel());
    orderDataList.assignAll(data.data!);
    return data.data!;
  }

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

  RxBool isScheduleLoading = false.obs;

  RxList<ScheduleListData> scheduleList = <ScheduleListData>[].obs;

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  Future<List<ScheduleListData>?> loadScheduleData(
      DateTime startDate, DateTime endDate) async {
    try {
      isScheduleLoading.value = true;

      log('Fetching schedule for salesman: , from: $startDate, to: $endDate');

      var data = await ApiWorker()
          .fetchSchedule(formatDate(endDate), formatDate(startDate));

      if (data?.data != null) {
        scheduleList.assignAll(data!.data!);
      } else {
        log('No schedule data available.');
        scheduleList.assignAll([]);
      }

      return data?.data;
    } catch (e, stacktrace) {
      log('Error fetching schedule: $e');
      log('Stacktrace: $stacktrace');
      return null;
    } finally {
      isScheduleLoading.value = false;
    }
  }

  RxBool isValueTargetLoading = false.obs;
  RxList<SalesmanValueTargetData> salesmanValueTargetList =
      <SalesmanValueTargetData>[].obs;
  RxList<String> weekList = <String>[].obs;
  Future<List<SalesmanValueTargetData>> loadSalesmanValueTarget(
      String salesmanId, String year, String? month) async {
    try {
      isValueTargetLoading.value = true;
      var data =
          await ApiWorker().fetchSalesmanValueTarget(salesmanId, year, month);
      salesmanValueTargetList.assignAll(data?.data ?? []);
      weekList.assignAll(data?.weekList ?? []);
      return data?.data ?? [];
    } finally {
      isValueTargetLoading.value = false;
    }
  }

  RxList<SalesmanTargetTableData> salesmanTargetTableList =
      <SalesmanTargetTableData>[].obs;
  RxBool isTargetLoading = false.obs;
  Future<List<SalesmanTargetTableData>> loadSalesmanTargetTableData(
      String salesmanId, String month, String year) async {
    try {
      isTargetLoading.value = true;
      log("isTargetLoadingforTab: ${isTargetLoading.value}");
      var data = await ApiWorker().fetchSalesmanTarget(salesmanId, month, year);
      salesmanTargetTableList.assignAll(data?.data ?? []);
      weekList.assignAll(data?.weekList ?? []);
      log('Salesman Target List Length :${salesmanTargetTableList.length}');
      return data?.data ?? [];
    } catch (e) {
      log("Error loading target data: $e");
      return [];
    } finally {
      isTargetLoading.value = false;
    }
  }

  RxBool isTimesheetLoading = false.obs;
  RxMap<String, StaffTimesheetData> staffTimesheetData =
      <String, StaffTimesheetData>{}.obs;

  Future<Map<String, StaffTimesheetData>> loadTimesheetData(
    String? startDate,
    String? endDate,
  ) async {
    try {
      isTimesheetLoading.value = true;
      staffTimesheetData.clear();

      var response = await ApiWorker()
          .getTimeSheetData(startDate: startDate, endDate: endDate);

      if (response.data != null && response.data!.isNotEmpty) {
        staffTimesheetData.assignAll(response.data!);
        log('✅ Fetched Timesheet Data: ${response.toJson()}');
        return response.data!;
      } else {
        log("⚠️ No timesheet data found.");
        staffTimesheetData.clear();
        return {};
      }
    } catch (e, stackTrace) {
      log('❌ Error fetching timesheet data: $e\n$stackTrace');

      staffTimesheetData.clear();
      return {};
    } finally {
      Future.delayed(const Duration(milliseconds: 50), () {
        isTimesheetLoading.value = false;
      });
    }
  }

  Future<void> updateValueBasedTarget(
    String salesmanId,
    String year,
    String month,
    Map<String, dynamic> monthTarget,
    Map<String, dynamic> weeklyTarget,
  ) async {
    try {
      var data = await ApiWorker().updateValueBasedTargetValue(
          salesmanId, year, month, monthTarget, weeklyTarget);
      log("${data.statusMessage}");
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  Future<void> updateCategoryTarget(
    String salesmanId,
    String month,
    String year,
    Map<dynamic, dynamic> categoryData,
    Map<dynamic, dynamic> weeklyTarget,
    Map<dynamic, dynamic> weeklyProjection,
  ) async {
    try {
      var data = await ApiWorker().updateCategoryTargetValue(salesmanId, month,
          year, categoryData, weeklyTarget, weeklyProjection);
      log("${data.statusMessage}");
    } catch (e) {
      log('Error: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoadingPass.value = true;
    try {
      log("This Function Worked");
      await ApiWorker().changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      Get.snackbar(
          colorText: white,
          backgroundColor: Colors.green,
          "Success",
          "Password changed successfully");
    } catch (e) {
      log("Error from controller: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoadingPass.value = false;
    }
  }
}
