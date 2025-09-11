import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:flutter/material.dart';

void showUpgradePlanDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/contact_admin.jpg',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 30),
                CustomText(
                  content: "Please contact admin for upgrade plans.",
                  textAlign: TextAlign.center,
                  fontSize: 20,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: CustomText(
                      content: 'OK',
                      color: primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showCancelPlanDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/contact_admin.jpg',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 30),
                CustomText(
                  content: "Please contact admin to cancel subsription.",
                  textAlign: TextAlign.center,
                  fontSize: 20,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: CustomText(
                      content: 'OK',
                      color: primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
