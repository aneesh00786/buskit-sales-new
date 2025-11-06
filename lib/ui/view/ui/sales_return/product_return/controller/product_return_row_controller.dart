import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:flutter/material.dart';
class ProductReturnRowController {
  final Cart cart;
  final TextEditingController damageCtrl;
  final TextEditingController returnCtrl;
  final TextEditingController reasonCtrl;

  ProductReturnRowController(this.cart)
      : damageCtrl = TextEditingController(text: cart.damageQty.toString()),
        returnCtrl = TextEditingController(text: cart.returnQty.toString()),
        reasonCtrl = TextEditingController(text: cart.itemReason) {
    // LISTEN TO EVERY CHANGE
    damageCtrl.addListener(() {
      cart.damageQty = int.tryParse(damageCtrl.text) ?? 0;
    });
    returnCtrl.addListener(() {
      cart.returnQty = int.tryParse(returnCtrl.text) ?? 0;
    });
    reasonCtrl.addListener(() {
      cart.itemReason = reasonCtrl.text.trim();
    });
  }

  // Optional: manual sync (not needed if listeners are active)
  void sync() {
    cart.damageQty = int.tryParse(damageCtrl.text) ?? 0;
    cart.returnQty = int.tryParse(returnCtrl.text) ?? 0;
    cart.itemReason = reasonCtrl.text.trim();
  }

  void dispose() {
    damageCtrl.dispose();
    returnCtrl.dispose();
    reasonCtrl.dispose();
  }
}