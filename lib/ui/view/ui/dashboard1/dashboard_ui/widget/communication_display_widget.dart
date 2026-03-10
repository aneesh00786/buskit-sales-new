// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_middle_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/upgrade_plan_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicationsDisplayWidget extends StatefulWidget {
  const CommunicationsDisplayWidget({super.key});

  @override

  _CommunicationsDisplayWidgetState createState() =>
      _CommunicationsDisplayWidgetState();
}

class _CommunicationsDisplayWidgetState
    extends State<CommunicationsDisplayWidget> {
    final subscriptionController = Get.find<SubscriptionController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MyCommnonContainer(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 205, 206, 208).withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(4, 4),
            ),
          ],
          borderRadius: 25,
          height: 300,
          isCommonBorder: true,
          padding: EdgeInsets.zero,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 224, 224, 226)
                        .withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 5, bottom: 5),
                  child: const Text(
                    "Communication",
                    style: cardHeadingTextStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            if (subscriptionController.communication.value != 'true') ...[
              Expanded(
                child: Center(
                  child: UpgradePlanButton(),
                ),
              )
            ],
            if (subscriptionController.communication.value == 'true')
            const Expanded(
              child: ChatScreen(),
            ),
            nkSmallSizeBox(),
          ])),
    );
  }
}
