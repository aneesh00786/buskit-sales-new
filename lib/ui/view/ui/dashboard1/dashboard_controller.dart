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
  RxDouble totalRevenue = 0.20.obs;
  RxString revenueAmount = "107,431".obs;
  RxInt selectedCommunicationIndex = (-1).obs;
  TextEditingController communicationController = TextEditingController();
  SearchModel searchModel = SearchModel();
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
    isInvoiceLoading(true);
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
