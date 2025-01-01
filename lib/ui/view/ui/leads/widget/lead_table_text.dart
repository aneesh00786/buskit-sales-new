
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_responce/lead_responce.dart';
import 'package:flutter/material.dart';

class LeadTableText extends StatelessWidget {
  LeadCustomerData leadCustomerData;
  String content;

  LeadTableText({
    super.key,
    required this.leadCustomerData,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 9, right: 9),
          child: CustomText(
            textAlign: TextAlign.center,
            content: content,
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
            maxLine: 3,
          ),
        ),
      ),
    ));
  }
}