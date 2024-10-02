import 'dart:convert';
import 'dart:developer';

// import 'package:busskit_admin/api_handler/api_worker.dart';
// import 'package:busskit_admin/common/search_model.dart';
// import 'package:busskit_admin/ui/components/common_size/nk_font_size.dart';
// import 'package:busskit_admin/ui/components/common_size/nk_general_size.dart';
// import 'package:busskit_admin/ui/components/widgets/my_regular_text.dart';
// import 'package:busskit_admin/ui/utills/nk_date_utils.dart';
// import 'package:busskit_admin/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/database/session/sessionmanager.dart';
import 'package:busskit_salesexecutive/database/session/sp_string.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/enum/filter_date_enum.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashBoardController extends GetxController {
  RxList<Map<String, dynamic>> communicationList = [
    {
      "image":
          "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
      "name": "Andre Harmon",
      "message":
          "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
    },
    {
      "image":
          "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
      "name": "Andre Harmon",
      "message":
          "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
    },
    {
      "image":
          "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
      "name": "Andre Harmon",
      "message":
          "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
    },
    {
      "image":
          "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
      "name": "Andre Harmon",
      "message":
          "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
    },
    {
      "image":
          "https://images.unsplash.com/photo-1685736475052-18a3533c0a94?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0M3x8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60",
      "name": "Andre Harmon",
      "message":
          "Hahapura venubok elivodcu deancij bapo wucte acezehge me Zob gok co aloow zaz kup zecmieji ol je."
    },
  ].obs;
  void onInit() {
    fetchDashboardData();
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
  var selectedFilter =
      FilterDateEnum.thisMonth.obs; 
  var selectedStartDate = ''.obs;
  var selectedEndDate = ''.obs;
  var isLoading = false.obs; 
  var errorMessage = ''.obs;
  var allCategory = <Category>[].obs;
  var categoryPerformance = <CategoryPerformancee>[].obs;
  var futureResponseModel = Future<ResponseModell>.value(ResponseModell()).obs;
  final _apiService = ApiService();
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final response = await fetchData();
      dashbordData.value = response;
    } catch (e) {
      errorMessage.value = 'Error fetching dashboard data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<ResponseModell> fetchData() async {
    final salesmanId = SessionHelper.loginSavedData!.salesmanId!;
    final jsonString = await SessionManager.getStringValue(SpString.spLogin);
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    String createdToken = jsonMap['createdToken'];
    try {
      final now = DateTime.now();
      String startDate;
      String endDate;
      switch (selectedFilter.value) {
        case FilterDateEnum.thisMonth:
          startDate = DateTime(now.year, now.month, 1)
              .toIso8601String()
              .substring(0, 10);
          endDate = DateTime(now.year, now.month + 1, 0)
              .toIso8601String()
              .substring(0, 10);
          break;
        case FilterDateEnum.today:
          startDate = DateTime(now.year, now.month, now.day)
              .toIso8601String()
              .substring(0, 10);
          endDate = startDate;
          break;
        case FilterDateEnum.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startDate = startOfWeek.toIso8601String().substring(0, 10);
          endDate = now.toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.thisYear:
          startDate =
              DateTime(now.year, 1, 1).toIso8601String().substring(0, 10);
          endDate =
              DateTime(now.year, 12, 31).toIso8601String().substring(0, 10);
          break;
        case FilterDateEnum.range:
          startDate = selectedStartDate.value;
          endDate = selectedEndDate.value;
          if (startDate.isEmpty || endDate.isEmpty) {
            throw Exception(
                'Start and End dates must be set for range filter.');
          }
          break;
      }
      final apiResponse = await _apiService.fetchDashboardData(
        salesmanId: salesmanId,
        startDate: "2024-10-01",
        //startDate,
        endDate: '2024-10-30',
        //endDate,
        createdToken: createdToken,
      );

      log('Api Response: $apiResponse');
      if (apiResponse == null) {
        return ResponseModell();
      }
      return apiResponse;
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

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
      print("start_Date++${searchModel.startDate}");
      loadDahsbordData;
    } else {
      searchModel.startDate = "";
      searchModel.endDate = "";
      loadDahsbordData;
    }
    refresh();
  }

  get loadDahsbordData async {
    // var data = await _apiWorker.dashboardData();
    // log("API DASHBORD DATA IS ${data.toJson()}");
    // dashbordData = data.data!.obs as Rx<Data>;
    // log("DashBoard Data Load ++++++++++++++ ${dashbordData.value.toJson()}");
    // log("Loded  DASHBORD DATA encode ${jsonEncode(dashbordData.value)}");
    // refresh();
  }

  List<int> colorList = [
    0xff3879f1,
    0xff8fbdf7,
    0xffD3e4f9,
    0xffEff0f1,
    0xffEff0f0,
    0xffEff0e2
  ];

  // List<ChartSeries<Month, String>> getDashbordData(
  //     List<CategoryPerformance> categoryData) {
  //   List<ChartSeries<Month, String>> data = [];
  //   for (int i = 0; i < categoryData.length; i++) {
  //     data.add(StackedColumnSeries<Month, String>(
  //         dataSource: categoryData[i].month!,
  //         xValueMapper: (Month sales, _) => NKDateUtils.months[_],
  //         yValueMapper: (Month sales, _) => sales.totalCount,
  //         color: Color(colorList[i]),
  //         name: categoryData[i].category,
  //         markerSettings: MarkerSettings(isVisible: false)));
  //   }

  //   return data;
  // }

  // List to store the state of checkboxes
  var checkBoxValues = List<bool>.filled(4, false).obs;

  // Function to update the value of a checkbox
  void updateCheckBox(int index, bool value) {
    checkBoxValues[index] = value;
  }

  // List to store messages for each customer
  var messages = List.generate(
    10,
    (index) => <Message>[].obs,
  ).obs;

  // Function to send a message
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
}

class Message {
  final String text;
  final bool isSentByMe;

  Message({required this.text, required this.isSentByMe});
}
