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
import 'package:busskit_salesexecutive/ui/components/common_size/nk_font_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/model/dashboard_response.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_models.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashBoardController extends GetxController {
  RxDouble totalRevenue = 0.20.obs;
  RxString revenueAmount = "107,431".obs;
  RxInt selectedCommunicationIndex = (-1).obs;
  TextEditingController communicationController = TextEditingController();
  //Rx<Data> dashbordData = Data().obs;
  SearchModel searchModel = SearchModel();
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
  // ignore: unused_field
  final ApiWorker _apiWorker = ApiWorker();
  var dashbordData = ResponseModell().obs;
  Future<void> fetchDashboardData() async {
    try {
      final response = await ApiService().fetchDashboardData();
      dashbordData.value = response;
      log('Response from New Function :${response}');
    } catch (e) {
      throw Exception('Error fetching dashboard data:++ $e');
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
