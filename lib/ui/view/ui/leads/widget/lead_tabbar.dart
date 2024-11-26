import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_bottom_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_customer_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_rejected_screen.dart';
import 'package:flutter/material.dart';

class LeadsTabBar extends StatefulWidget {
  final LeadsController leadController;
  final CustomersController leadsCustomerController;
  final RejectedLeadsController  rejectedLeadsController;

  LeadsTabBar({required this.leadController, required this.leadsCustomerController,  required this.rejectedLeadsController});

  @override
  _LeadsTabBarState createState() => _LeadsTabBarState();
}

class _LeadsTabBarState extends State<LeadsTabBar> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Leads', 'Customers', 'Rejected Leads'];

  // Function to handle chart tap and update the tabs
  void _onBarTapped(int index) {
    setState(() {
      _selectedTabIndex = index;  // Select the tab that was tapped
    });
    // widget.leadController.updateTabIndex(index); // Update the tab index in the controller
  }

  // Function to return the screen based on selected tab
  Widget _getTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return LeadBottomScreen(leadsController: widget.leadController);
      case 1:
        return LeadCustomerScreen(leadsCustomerController: widget.leadsCustomerController,);  // Replace with your Customers screen widget
      case 2:
        return LeadRejectedScreen(rejectedLeadsController: widget.rejectedLeadsController,);  // Replace with your Rejected Leads screen widget
      default:
        return LeadBottomScreen(leadsController: widget.leadController); // Default case
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: _getTabContent(), // Display content based on the selected tab
        ),
      ],
    );
  }
}
