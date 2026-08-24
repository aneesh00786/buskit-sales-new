import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: dashboardContainerHeader("Communication".tr),
                ),
                if (subscriptionController.communication.value == 'true')
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.85,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Communication'.tr,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins_Regular',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            dialogCloseButton1(context, red),
                                          ],
                                        ),
                                      ),
                                      const Expanded(child: ChatScreen()),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: primaryColor.withOpacity(0.3)),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.open_in_new,
                            size: 17,
                            color: primaryColor,
                          ),
                        ),
                      ),
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
