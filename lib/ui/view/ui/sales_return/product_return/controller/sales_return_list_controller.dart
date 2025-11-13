// // sales_return_list_screen.dart   (the file that contains buildTableRow, build... )
// import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/controller/return_info_controller.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';

// class SalesReturnListController extends GetxController {
//   final returnInfoCtrl = Get.find<ReturnInfoController>();

//   // map orderId → bool (has pending returns)
//   final RxMap<String, bool> orderHasPending = <String, bool>{}.obs;

//   Future<void> loadPendingForOrder(String orderId) async {
//     await returnInfoCtrl.fetchPendingReturns(orderId);
//     orderHasPending[orderId] = returnInfoCtrl.hasAnyPendingReturn;
//   }
// }