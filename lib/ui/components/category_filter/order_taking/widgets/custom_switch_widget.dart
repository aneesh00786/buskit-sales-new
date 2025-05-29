import 'dart:developer';

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_regular_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final bool active;
  final String selectedName;

  const CustomSwitch({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.active,
    required this.selectedName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  final subscriptionController = Get.find<SubscriptionController>();

  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
  }

  void _toggleSwitch() {
    setState(() {
      isOn = !isOn;
    });
    widget.onChanged(isOn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isOn ? Colors.green : Colors.red,
        content: Text(isOn
            ? 'You are successfully checked-in'
            : 'You are successfully checked-out'),
        duration: const Duration(seconds: 3),
      ),
    );
    log('Active value : $isOn');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: subscriptionController.customerCheckInOut.value == "true"
          ? widget.selectedName.isNotEmpty
              ? _toggleSwitch
              : () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 50,
                              ),
                            ),
                          ),
                          Center(
                              child: CustomText(
                            content: 'Please select a customer to check-in',
                            fontSize: 17,
                          )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Ok'))
                        ],
                      );
                    },
                  );
                }
          : () {
              showUpgradePlanDialog(context);
            },
      child: Container(
        width: 140.0,
        height: 50.0,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: isOn ? Colors.green : Colors.red,
        ),
        child: Stack(
          alignment: isOn ? Alignment.centerLeft : Alignment.centerRight,
          children: [
            Padding(
              padding: isOn
                  ? const EdgeInsets.only(left: 8)
                  : const EdgeInsets.only(right: 8),
              child: MyRegularText(
                label: isOn ? "Check-in" : "Check-out",
                color: white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              curve: Curves.easeInOut,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isOn
                        ? EneftyIcons.tick_circle_outline
                        : EneftyIcons.close_circle_outline,
                    color: isOn ? Colors.green : Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
