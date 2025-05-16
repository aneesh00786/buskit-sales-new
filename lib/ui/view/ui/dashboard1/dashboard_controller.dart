import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/notifications/notification_count_model.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'provider/dash_models.dart';

class DashBoardController extends GetxController {
  RecentOrderCountData recentOrderCountData = RecentOrderCountData();
  @override
  void onInit() {
    //fetchDashboardData();
    super.onInit();
  }

  RxDouble totalRevenue = 0.20.obs;
  RxString revenueAmount = "107,431".obs;
  RxInt selectedCommunicationIndex = (-1).obs;
  TextEditingController communicationController = TextEditingController();
  //Rx<Data> dashbordData = Data().obs;
  SearchModel searchModel = SearchModel();
  // // ignore: unused_field
  // final ApiWorker _apiWorker = ApiWorker();
  var dashbordData = ResponseModell().obs;
  var selectedFilter = FilterDateEnum.thisMonth.obs;
  var selectedStartDate = ''.obs;
  var selectedEndDate = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var allCategory = <Category>[].obs;
  var categoryPerformance = <CategoryPerformancee>[].obs;
  var futureResponseModel = Future<ResponseModell>.value(ResponseModell()).obs;
  ResponseModell response = ResponseModell();

  // Future<void> fetchDashboardData() async {
  //   try {
  //     isLoading.value = true;
  //     await _apiService.fetchDashboardData();
  //     response = await fetchData();
  //     dashbordData.value = response;
  //   } catch (e) {
  //     handleHttpResponseError(
  //       statusCode: response.statusCode ?? 0,
  //       showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
  //     );
  //     errorMessage.value = 'Error fetching dashboard data345: $e';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> fetchDashboardData() async {
  //   try {
  //     await _apiService.fetchDashboardData();
  //     await _apiService.fetchChatData(true);
  //   } catch (e) {
  //     if (e.toString().contains('Session expired')) {
  //       await SessionHelper().clearAll();
  //       if (!_isDisposed) {
  //         Get.offAllNamed(AppRoutes.login);
  //       }
  //       await Future.delayed(Duration(milliseconds: 500));
  //       _handleTokenExpiration();
  //     }
  //     log('Error fetching dashboard data: $e');
  //   }
  // }

  // Future<ResponseModell> fetchData() async {
  //   final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
  //   try {
  //     final now = DateTime.now();
  //     String startDate;
  //     String endDate;
  //     switch (selectedFilter.value) {
  //       case FilterDateEnum.thisMonth:
  //         startDate = DateTime(now.year, now.month, 1)
  //             .toIso8601String()
  //             .substring(0, 10);
  //         endDate = DateTime(now.year, now.month + 1, 0)
  //             .toIso8601String()
  //             .substring(0, 10);
  //         break;
  //       case FilterDateEnum.today:
  //         startDate = DateTime(now.year, now.month, now.day)
  //             .toIso8601String()
  //             .substring(0, 10);
  //         endDate = startDate;
  //         break;
  //       case FilterDateEnum.thisWeek:
  //         final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  //         startDate = startOfWeek.toIso8601String().substring(0, 10);
  //         endDate = now.toIso8601String().substring(0, 10);
  //         break;
  //       case FilterDateEnum.thisYear:
  //         startDate =
  //             DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
  //         endDate =
  //             DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
  //         break;
  //       case FilterDateEnum.range:
  //         startDate = selectedStartDate.value;
  //         endDate = selectedEndDate.value;
  //         if (startDate.isEmpty || endDate.isEmpty) {
  //           throw Exception(
  //               'Start and End dates must be set for range filter.');
  //         }
  //         break;
  //     }
  //     final apiResponse = await _apiService.fetchDashboardData(
  //       salesmanId: salesmanId,
  //       startDate: startDate,
  //       endDate: endDate,
  //     );

  //     log('Api Response345: ${apiResponse.statusCode}');
  //     handleHttpResponseError(
  //       statusCode: response.statusCode!,
  //       showErrorSnackBar: NkCommonFunction.showErrorSnakBar,
  //     );

  //     return apiResponse;
  //   } catch (e) {
  //     log('Error fetching data: $e');
  //     rethrow;
  //   }
  // }

  Widget revenueProgressBar(
    double value,
    Color revenueProgressBarFilledColor,
    Color revenueProgressBarColor,
  ) {
    return CircularPercentIndicator(
      radius: NkGeneralSize.nkCommonBorderRadius(borderRadius: 60.0),
      animation: true,
      circularStrokeCap: CircularStrokeCap.round,
      lineWidth: 20,
      animationDuration: 1000,
      progressColor: revenueProgressBarFilledColor,
      backgroundColor: revenueProgressBarColor,
      center: MyRegularText(
        fontSize: NkFontSize.largeFont() + 8,
        color: revenueProgressBarFilledColor,
        fontWeight: NkGeneralSize.nkBoldFontWeight(),
        label: "${(totalRevenue.value * 100).round()}%",
      ),
      percent: value,
    );
  }

  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchModel.startDate = NKDateUtils.apiDayFormat(startDate);
      searchModel.endDate = NKDateUtils.apiDayFormat(endDate);
      log("start_Date++${searchModel.startDate}");
      loadDahsbordData;
    } else {
      searchModel.startDate = "";
      searchModel.endDate = "";
      loadDahsbordData;
    }
    refresh();
  }

  get loadDahsbordData async {}

  List<int> colorList = [
    0xff3879f1,
    0xff8fbdf7,
    0xffD3e4f9,
    0xffEff0f1,
    0xffEff0f0,
    0xffEff0e2
  ];
  var checkBoxValues = List<bool>.filled(4, false).obs;
  void updateCheckBox(int index, bool value) {
    checkBoxValues[index] = value;
  }

  var messages = List.generate(
    10,
    (index) => <Message>[].obs,
  ).obs;
  void sendMessage(int customerIndex, String messageText) {
    messages[customerIndex].add(
      Message(text: messageText, isSentByMe: true),
    );
  }

  // Function to receive a message (for demonstration purposes)
  void receiveMessage(int customerIndex, String messageText) {
    messages[customerIndex].add(
      Message(text: messageText, isSentByMe: false),
    );
  }

  SpecificOrderData? fetchSpecificOrderData = SpecificOrderData();

  RxBool isInvoiceLoading = false.obs;
  Future<SpecificOrderData> loadSpecificOrderInvoiceData({
    required String orderId,
  }) async {
    fetchSpecificOrderData = null;
    isInvoiceLoading(true); // Start loading
    log("Loading Specific Order Invoice Data");

    var data = await ApiWorker().fetchSpecificOrderInvoice(
      orderId,
    );

    if (data.data != null) {
      fetchSpecificOrderData = data.data;
    }

    isInvoiceLoading(false); // Stop loading
    log('is Invoice Loading : ${isInvoiceLoading.value}');
    return fetchSpecificOrderData!;
  }
}

class Message {
  final String text;
  final bool isSentByMe;

  Message({required this.text, required this.isSentByMe});
}
