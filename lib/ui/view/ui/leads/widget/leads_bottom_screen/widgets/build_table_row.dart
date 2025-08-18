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

Widget buildTableRow(
  LeadCustomerData leadCustomerData,
  BuildContext context,
  int index,
  double fixedRowHeight,
  LeadsController leadsController,
  SubscriptionController subscriptionController,
) {
  return Container(
    color: index.isEven ? Colors.grey[50] : Colors.white,
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
                              title: const Text('Delete Lead'),
                              content: const Text(
                                  'Are you sure you want to delete this lead?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    leadsController.deleteLeads(
                                        leadCustomerData.customerId.toString());
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          leadsController.deleteLead(leadCustomerData.id ?? 0);
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
