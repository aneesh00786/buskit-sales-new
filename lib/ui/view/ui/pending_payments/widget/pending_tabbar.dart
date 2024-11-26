import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_chart.dart';
import 'package:flutter/material.dart';

class PendingTabBar extends StatefulWidget {
  final PendingPaymentController orderController;

  PendingTabBar({required this.orderController});

  @override
  _PendingTabBarState createState() => _PendingTabBarState();
}

class _PendingTabBarState extends State<PendingTabBar> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Nearly Due', 'Due', 'Over Due'];
  List<bool> _visibleTabs = [true, false, false, false]; // Track visibility of each tab

  // Function to handle chart tap and update the tabs
  void _onBarTapped(int index) {
    setState(() {
      _visibleTabs[index] = true; // Make the corresponding tab visible
      _selectedTabIndex = index;  // Select the tab that was tapped
    });
    widget.orderController.updateTabIndex(index); // Update the tab index in the controller
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SizedBox(
            // flex: 2,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: PendingPaymentChart(
                chartController: widget.orderController,
                onBarTapped: _onBarTapped, // Pass the callback to the chart
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedTabIndex == index;
                if (!_visibleTabs[index]) return const SizedBox.shrink(); // Hide tabs that are not visible
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                    widget.orderController.updateTabIndex(_selectedTabIndex);
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
          SizedBox(
            // flex: 3,
            height: MediaQuery.of(context).size.height * 0.8,
            child: PendingPaymentBottomWidget(
              orderController: widget.orderController,
              selectedTabIndex: _selectedTabIndex,
            ),
          ),
        ],
      ),
    );
  }
}
