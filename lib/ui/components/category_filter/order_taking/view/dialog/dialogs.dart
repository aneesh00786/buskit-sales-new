import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/local_database/cart_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

Future<dynamic> showSuccessFullDialog(
    {required BuildContext context,
    required String imagePath,
    required String message}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: Lottie.asset(imagePath),
          ),
        ),
        content: CustomText(
          content: message,
          fontSize: 14,
        ),
        actions: [
          SizedBox(
            width: 150,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins_Regular',
                  color: Color(0xFF727CF5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<dynamic> showSuccessFullDialogCtrl({required BuildContext context}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: Lottie.asset('assets/images/Animation - 1726906882515.json'),
          ),
        ),
        content: CustomText(
          content: 'Your order has been successfully saved as Draft'.tr,
          fontSize: 14,
        ),
        actions: [
          SizedBox(
            width: 150,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'OK'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  color: Color(0xFF727CF5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<dynamic> showFaledDialogCtrl(
    {required BuildContext context, required String customerId}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        actionsAlignment: MainAxisAlignment.center,
        title: Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset('assets/images/Warning_animation.json'),
          ),
        ),
        content: CustomText(
          content: "Couldn't save the order as draft please try again.",
          fontSize: 14,
        ),
        actions: [
          SizedBox(
            width: 150,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
                CartDatabaseManager().clearCart(customerId: customerId);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF727CF5), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'OK'.tr,
                style: const TextStyle(
                  fontFamily: 'Poppins_Regular',
                  color: Color(0xFF727CF5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<dynamic> offlineDialog(BuildContext context) {
  return showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      actionsAlignment: MainAxisAlignment.center,
      title: const Text('Offline Mode'),
      content: const Text(
          'The draft has been saved locally. It will be synced when the internet is available.'),
      actions: [
        SizedBox(
          width: 150,
          height: 45,
          child: OutlinedButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF727CF5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'OK'.tr,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                color: Color(0xFF727CF5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Future<dynamic> offlineMode1(BuildContext context) {
  return showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      actionsAlignment: MainAxisAlignment.center,
      title: const Text('Offline Mode'),
      content: const Text(
          'The draft has been saved locally. It will be synced when the internet is available.'),
      actions: [
        SizedBox(
          width: 150,
          height: 45,
          child: OutlinedButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF727CF5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'OK'.tr,
              style: const TextStyle(
                fontFamily: 'Poppins_Regular',
                color: Color(0xFF727CF5),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
