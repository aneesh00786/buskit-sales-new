  import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_dashbord/custom_toast.dart';
import 'package:flutter/material.dart';

void showCustomToast(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).viewInsets.top + 0.0,
            left: 0,
            right: 0,
            child: const Align(
              alignment: Alignment.topCenter,
              child: Material(
                color: Colors.transparent,
                child: CustomToast(
                  message: "Please Select An Order To Change Payment Details",
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    // Automatically remove the toast after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }