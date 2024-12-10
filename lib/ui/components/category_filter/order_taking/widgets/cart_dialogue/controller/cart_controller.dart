import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  void incrementCount(CartItem cartItem) {
    int index = cartItems.indexWhere((item) => item.detail.id == cartItem.detail.id);
    if (index != -1) {
      cartItems[index].detail.count++;
      update(); // Notify the UI
    }
  }

  void decrementCount(CartItem cartItem) {
    int index = cartItems.indexWhere((item) => item.detail.id == cartItem.detail.id);
    if (index != -1 && cartItems[index].detail.count > 0) {
      cartItems[index].detail.count--;
      update(); // Notify the UI
    }
  }
}
