  import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_table_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildTableHeader1(Widget child, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: child,
    );
  }

  Widget buildTableHeader() {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: buildHeaderText('Address'.tr, 13)),
          Expanded(child: buildHeaderText('Town'.tr, 13)),
          Expanded(child: buildHeaderText('State'.tr, 13)),
          Expanded(child: buildHeaderText('Zip Code'.tr, 13)),
          Expanded(child: buildHeaderText('Mobile No.'.tr, 13)),
          Expanded(child: buildHeaderText('Email'.tr, 13)),
          Expanded(child: buildHeaderText('Contact Person'.tr, 13)),
          Expanded(child: buildHeaderText('Contact Number'.tr, 13)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget buildHeaderText(String text, double fontSize) {
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
      int index, double fixedRowHeight) {
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
        ],
      ),
    );
  }