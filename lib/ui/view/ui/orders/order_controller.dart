import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/pagination_model.dart';
import 'package:busskit_salesexecutive/common/search_model.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_general_size.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/cart_diloag/customer_cart_responce.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final ApiWorker _apiWorker = ApiWorker();
  RxList<OrderData> orderDataList = <OrderData>[].obs;
  RxList<CustomerCart> customerCartList = <CustomerCart>[].obs;

  SearchModel searchData = SearchModel();

  RxList<String> orderTableColumCategory = [
    " Customer List",
    "Order Number",
    "Order created",
    "Order Price",
    "Status",
    ""
  ].obs;

  Future<List<OrderData>> get loadOrderData async {
    // print("SalesManID++++${SessionHelper.loginSavedData!.salesmanId}");
    var data = await _apiWorker.getOrdersData(
        salesmanId: SessionHelper.loginSavedData!.salesmanId,
        searchModel: searchData,
        paginationModel: PaginationModel());
    orderDataList.assignAll(data.data!);
    return data.data!;
  }

  // Future<List<OrderData>> get loadOrderData async {
  //   var data = await _apiWorker.getOrdersData(
  //       searchModel: searchData, paginationModel: PaginationModel());
  //   orderDataList.assignAll(data.data!);
  //   return data.data!;
  // }
  updateCustomerVisitScheduleSet(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      searchData.startDate = NKDateUtils.apiDayFormat(startDate);
      searchData.endDate = NKDateUtils.apiDayFormat(endDate);
      loadOrderData;
    } else {
      searchData.startDate = "";
      searchData.endDate = "";
      loadOrderData;
    }
    refresh();
    print('444+${searchData.startDate}');
    print('444++${searchData.endDate}');
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

  filterOrderCartData(List<OrderData> orderData) {
    for (var element in orderData) {
      customerCartList.addAll(element.cart!);
    }
  }
}
