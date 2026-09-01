// ignore_for_file: must_be_immutable

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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 9, right: 9),
            child: CustomText(
              textAlign: TextAlign.center,
              content: content,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
              overflow: TextOverflow.ellipsis,
              maxLine: 3,
            ),
          ),
        ));
  }
}
