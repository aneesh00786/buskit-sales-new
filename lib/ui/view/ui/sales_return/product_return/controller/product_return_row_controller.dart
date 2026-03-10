
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:flutter/material.dart';



class ProductReturnRowController {
  final Cart cart;
  final TextEditingController damageCtrl = TextEditingController();
  final TextEditingController returnCtrl = TextEditingController();
  final TextEditingController reasonCtrl = TextEditingController();

  ProductReturnRowController(this.cart) {
    // Initialize from cart
    damageCtrl.text = cart.damageQty.toString();
    returnCtrl.text = cart.returnQty.toString();
    reasonCtrl.text = cart.itemReason ?? '';

    // === LISTENERS ===
    damageCtrl.addListener(_syncDamage);
    returnCtrl.addListener(_syncReturn);
    reasonCtrl.addListener(() {
      cart.itemReason = reasonCtrl.text.trim();
    });
  }

  void _syncDamage() {
    final value = int.tryParse(damageCtrl.text) ?? 0;
    cart.damageQty = value;
  }

  void _syncReturn() {
    final value = int.tryParse(returnCtrl.text) ?? 0;
    cart.returnQty = value;
  }

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
