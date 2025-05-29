import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:flutter/material.dart';

class UpgradePlanButton extends StatelessWidget {
  const UpgradePlanButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStatePropertyAll(Theme.of(context).primaryColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      onPressed: () {
        showUpgradePlanDialog(context);
      },
      child: const Text(
        'UPGRADE PLAN',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
