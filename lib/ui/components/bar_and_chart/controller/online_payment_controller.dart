import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PaymentController extends GetxController {
  // var selectedPaymentMethod = 'Cash'.obs;
  late RxString selectedPaymentMethod;
  var selectedPaymentMethodInt = 0.obs;
}