import 'package:busskit_salesexecutive/ui/view/ui/sales_return/product_return/model/product_return_model.dart';
import 'package:flutter/material.dart';
// class ProductReturnRowController {
//   final Cart cart;
//   final TextEditingController damageCtrl;
//   final TextEditingController returnCtrl;
//   final TextEditingController reasonCtrl;

//   ProductReturnRowController(this.cart)
//       : damageCtrl = TextEditingController(text: cart.damageQty.toString()),
//         returnCtrl = TextEditingController(text: cart.returnQty.toString()),
//         reasonCtrl = TextEditingController(text: cart.itemReason) {
//     // LISTEN TO EVERY CHANGE
//     damageCtrl.addListener(() {
//       cart.damageQty = int.tryParse(damageCtrl.text) ?? 0;
//     });
//     returnCtrl.addListener(() {
//       cart.returnQty = int.tryParse(returnCtrl.text) ?? 0;
//     });
//     reasonCtrl.addListener(() {
//       cart.itemReason = reasonCtrl.text.trim();
//     });
//   }

//   // Optional: manual sync (not needed if listeners are active)
//   void sync() {
//     cart.damageQty = int.tryParse(damageCtrl.text) ?? 0;
//     cart.returnQty = int.tryParse(returnCtrl.text) ?? 0;
//     cart.itemReason = reasonCtrl.text.trim();
//   }

//   void dispose() {
//     damageCtrl.dispose();
//     returnCtrl.dispose();
//     reasonCtrl.dispose();
//   }
// }


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

    // === LISTENERS WITH VALIDATION ===
    damageCtrl.addListener(_validateAndSync);
    returnCtrl.addListener(_validateAndSync);
    reasonCtrl.addListener(() {
      cart.itemReason = reasonCtrl.text.trim();
    });
  }


  void _validateAndSync() {
  final int damage = int.tryParse(damageCtrl.text) ?? 0;
  final int returnQty = int.tryParse(returnCtrl.text) ?? 0;
  final int available = cart.suppliedQty ?? 0;

  int newDamage = damage;
  int newReturn = returnQty;

  // === NEW VALIDATION RULES ===
  // 1. Damage cannot exceed available
  // 2. Return cannot exceed damage
  if (newDamage > available) {
    newDamage = available;
    newReturn = 0; // Since return <= damage, and damage is capped
  }

  if (newReturn > newDamage) {
    newReturn = newDamage;
  }

  // === AUTO-CORRECT & SYNC ===
  if (newDamage != damage || newReturn != returnQty) {
    // Update cart
    cart.damageQty = newDamage;
    cart.returnQty = newReturn;

    // Update controllers without triggering listeners
    damageCtrl.removeListener(_validateAndSync);
    returnCtrl.removeListener(_validateAndSync);

    damageCtrl.text = newDamage.toString();
    returnCtrl.text = newReturn.toString();

    // Re-attach listeners
    damageCtrl.addListener(_validateAndSync);
    returnCtrl.addListener(_validateAndSync);

    // Optional: Show feedback
    // Get.snackbar("Corrected", "Values adjusted to meet constraints.");
  } else {
    // Valid input → just sync
    cart.damageQty = newDamage;
    cart.returnQty = newReturn;
  }
}

  // void _validateAndSync() {
  //   final int damage = int.tryParse(damageCtrl.text) ?? 0;
  //   final int returnQty = int.tryParse(returnCtrl.text) ?? 0;
  //   final int available = cart.quantity ?? 0;

  //   final total = damage + returnQty;

  //   if (total > available) {
  //     // === AUTO-CORRECT STRATEGY ===
  //     // Option 1: Cap at available, prioritize damage
  //     final remaining = available;
  //     int newDamage = damage;
  //     int newReturn = returnQty;

  //     if (damage > remaining) {
  //       newDamage = remaining;
  //       newReturn = 0;
  //     } else {
  //       newReturn = remaining - damage;
  //     }

  //     // Update cart
  //     cart.damageQty = newDamage;
  //     cart.returnQty = newReturn;

  //     // Update controllers (without triggering infinite loop)
  //     damageCtrl.removeListener(_validateAndSync);
  //     returnCtrl.removeListener(_validateAndSync);

  //     damageCtrl.text = newDamage.toString();
  //     returnCtrl.text = newReturn.toString();

  //     // Re-attach listeners
  //     damageCtrl.addListener(_validateAndSync);
  //     returnCtrl.addListener(_validateAndSync);

  //     // Optional: Show feedback (handled in UI or via GetX)
  //     // Get.snackbar("Invalid", "Total cannot exceed $available");
  //   } else {
  //     // Valid → just sync
  //     cart.damageQty = damage;
  //     cart.returnQty = returnQty;
  //   }
  // }

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