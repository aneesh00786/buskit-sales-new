// ignore_for_file: use_build_context_synchronously

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_select_status.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_table_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_bottom_screen/widgets/edit_leads_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildTableRow(
  LeadCustomerData leadCustomerData,
  BuildContext context,
  int index,
  double fixedRowHeight,
  LeadsController leadsController,
  SubscriptionController subscriptionController,
) {
  return Container(
    decoration: BoxDecoration(
      color: index.isEven ? const Color(0xFFF8FAFC) : Colors.white,
      border: const Border(
        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.6),
      ),
    ),
    height: fixedRowHeight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.address ?? '',
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.town ?? '',
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.state ?? '',
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.zipcode.toString(),
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.businessNo ?? '',
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.email ?? '',
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.fullname ?? '',
        ),
        LeadTableText(
          leadCustomerData: leadCustomerData,
          content: leadCustomerData.mobileno ?? '',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing:
                      subscriptionController.leadAcceptanceRejection.value !=
                          "true",
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: Center(
                      child: LeadsStatusSelect(
                        customerId: leadCustomerData.id ?? 0,
                      ),
                    ),
                  ),
                ),
                if (subscriptionController.leadAcceptanceRejection.value !=
                    "true")
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showUpgradePlanDialog(context);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: fixedRowHeight - 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 20,
                    child: IconButton(
                     onPressed: () async {
                          bool isOnline =
                              await ConnectivityService().isOnline();
                          if (!isOnline) {
                            showCustomToastDisplay(
                                context, "You are Offline!", red, Icons.close);
                            return;
                          }

                          await leadsController.getLeadsForUpdate(
                              leadCustomerData.customerId ?? '');

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return EditLeadsDialog(
                                  customerId:
                                      leadCustomerData.customerId.toString(),
                                  leadsController: leadsController);
                            },
                          );
                        },
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(),
                      icon: const Icon(EneftyIcons.edit_outline, size: 20),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                    child: IconButton(
                      onPressed: () async {
                        bool isOnline = await ConnectivityService().isOnline();
                        if (!isOnline) {
                          showCustomToastDisplay(
                              context, "You are Offline!", red, Icons.close);
                          return;
                        }

                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              backgroundColor: Colors.white,
                              title: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete Lead'.tr,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins_Regular',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'Are you sure you want to delete this lead?'
                                    .tr,
                                style: const TextStyle(
                                    fontFamily: 'Poppins_Regular',
                                    fontSize: 16,
                                    color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(false),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.grey, width: 2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        child: Text(
                                          'Cancel'.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins_Regular',
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          Navigator.pop(context, true);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.redAccent,
                                              width: 2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        child: Text(
                                          'Confirm'.tr,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins_Regular',
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await leadsController.deleteLeads(
                              leadCustomerData.customerId.toString());
                        }
                      },
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        EneftyIcons.trash_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}
