  import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_select_status.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_table_text.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          Expanded(child: _buildHeaderText('Address'.tr, 13)),
          Expanded(child: _buildHeaderText('Mobile No.'.tr, 13)),
          Expanded(child: _buildHeaderText('Town'.tr, 12)),
          Expanded(child: _buildHeaderText('State'.tr, 12)),
          Expanded(child: _buildHeaderText('Zip Code'.tr, 12)),
          Expanded(child: _buildHeaderText('Email'.tr, 12)),
          Expanded(child: _buildHeaderText('Contact Person'.tr, 12)),
          Expanded(child: _buildHeaderText('Contact Number'.tr, 12)),
          Expanded(child: _buildHeaderText('Status'.tr, 13)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, double fontSize) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins_Regular',
        ),
      ),
    );
  }

  Widget buildTableRow(LeadCustomerData leadCustomerData, BuildContext context,
      int index, double fixedRowHeight,SubscriptionController subscriptionController) {
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
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing:
                        subscriptionController.leadConversion.value != "true",
                    child: LeadsRejectedStatusSelect(
                      customerId: leadCustomerData.id!.toInt(),
                    ),
                  ),
                  if (subscriptionController.leadConversion.value != "true")
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
          )
        ],
      ),
    );
  }

  Widget buildTableHeader1(Widget child, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: child,
    );
  }