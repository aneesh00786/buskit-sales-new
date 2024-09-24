import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PendingPaymentController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  RxList<OrderData> orderDataList = <OrderData>[].obs;

  RxList<String> orderTableColumCategory = [
    " Customer List",
    "Order Number",
    "Order created",
    "Order Price",
    "Status",
    ""
  ].obs;

  SearchModel searchModel = SearchModel();

  Future<List<OrderData>> get loadOrderData async {
    print("salesId++++${SessionHelper.loginSavedData!.salesmanId!}");
    print("startDate++++${searchModel.startDate.toString()}");
    var data = await _apiWorker.getPendingPaymentData(
        SessionHelper.loginSavedData!.salesmanId!,
        searchModel: searchModel,
        paginationModel: PaginationModel());
    orderDataList.assignAll(data.data!);
    return data.data!;
  }

  Widget orderStatusWidget(String status, Color color) {
    return Container(
      padding: nkRegularPadding(),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(NkGeneralSize.nkCommonBorderRadius()),
      ),
      child: MyRegularText(
        label: status,
      ),
    );
  }

  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchModel.startDate = NKDateUtils.apiDayFormat(startDate);
      searchModel.endDate = NKDateUtils.apiDayFormat(endDate);
      loadOrderData;
    } else {
      searchModel.startDate = "";
      searchModel.endDate = "";
      loadOrderData;
    }
    refresh();
  }
}
