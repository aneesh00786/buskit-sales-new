// controllers/pending_returns_controller.dart
// assuming your dio + fetchInforeturnData lives here

import 'package:busskit_salesexecutive/api_handler/api_service.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/return_info_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PendingReturnsController extends GetxController {
  // ------------------- Observables -------------------
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ReturnInfo?> returnsResponse = Rx<ReturnInfo?>(null);
  Future<void> fetchPendingReturns({
    required String cartId,
    required String companyId,
  }) async {
    // Reset previous state
    errorMessage.value = '';
    isLoading.value = true;

    try {
      // Optional: re-check internet (if not already in the function)
      final isOnline = await ConnectivityService().isOnline();
      if (!isOnline) {
        errorMessage.value = 'No internet connection';
        return;
      }
      print('cartid:$cartId');
      print('companyId:$companyId');

      final response = await ApiWorker().fetchInforeturnData(
        cartId: cartId,
        companyId: companyId,
      );

      returnsResponse.value = response;
      // print('info api response:${returnsResponse.value.toString() }');
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear data (e.g., when leaving screen)
  void clear() {
    returnsResponse.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }
}