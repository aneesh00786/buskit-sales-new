import 'package:busskit_salesexecutive/ui/components/category_filter/product_list/model/cart_model.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  void incrementCount(CartItem cartItem) {
    int index = cartItems.indexWhere((item) => item.detail.id == cartItem.detail.id);
    if (index != -1) {
      cartItems[index].detail.count++;
      update(); 
    }
  }

  void decrementCount(CartItem cartItem) {
    int index = cartItems.indexWhere((item) => item.detail.id == cartItem.detail.id);
    if (index != -1 && cartItems[index].detail.count > 0) {
      cartItems[index].detail.count--;
      update(); 
    }
  }
}
