import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_dialog.dart';
import 'package:flutter/material.dart';

class UpgradePlanButton extends StatelessWidget {
  const UpgradePlanButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll(Theme.of(context).primaryColor),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Please contact admin for upgrade plans"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('ok'))
              ],
            );
            //UpgradePlanScreen();
          },
        );
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
