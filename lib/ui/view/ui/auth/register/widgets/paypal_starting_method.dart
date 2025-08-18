
// ignore_for_file: use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void startPayPalPaymentFlow({
  required BuildContext context,
  required Plan plan,
  required double totalAmount,
  required int selectedQuantity,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final int? adminId = prefs.getInt('admin_id');
    final orderId = await ApiWorker().createPayPalOrder(
      amount: totalAmount.toString(),
      currency: "USD",
      adminId: adminId ?? 0,
    );
    await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => PayPalWebViewScreen(
    adminId: adminId ?? 0,
    amount: totalAmount,
    planId: plan.id ?? 0,
    orderId: orderId ?? '',
  ),
);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}



