// ignore_for_file: library_private_types_in_public_api

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
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
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedTabIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                      widget.leadController.updateTabIndex(_selectedTabIndex);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontFamily: 'Poppins_Regular',
                          color: isSelected ? Colors.white : primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
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
