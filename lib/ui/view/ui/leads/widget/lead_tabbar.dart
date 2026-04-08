// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_customer_screen/lead_customer_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_rejected_screen/lead_rejected_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/leads_bottom_screen/lead_bottom_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsTabBar extends StatefulWidget {
  final LeadsController leadController;
  final CustomersController leadsCustomerController;
  final RejectedLeadsController  rejectedLeadsController;

  const LeadsTabBar({super.key, required this.leadController, required this.leadsCustomerController,  required this.rejectedLeadsController});

  @override

  _LeadsTabBarState createState() => _LeadsTabBarState();
}

class _LeadsTabBarState extends State<LeadsTabBar> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Leads'.tr, 'Customers'.tr, 'Rejected Leads'.tr];
  Widget _getTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return LeadBottomScreen(leadsController: widget.leadController);
      case 1:
        return LeadCustomerScreen(leadsCustomerController: widget.leadsCustomerController,);
      case 2:
        return LeadRejectedScreen(rejectedLeadsController: widget.rejectedLeadsController,); 
      default:
        return LeadBottomScreen(leadsController: widget.leadController); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  widget.leadController.updateTabIndex(_selectedTabIndex);
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.cyan : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: CustomText(
                   content: _tabs[index],

                      color: isSelected ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.bold,

                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: _getTabContent(), 
        ),
      ],
    );
  }
}
