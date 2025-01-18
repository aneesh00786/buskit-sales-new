import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_common_container.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/dashboard_ui/widget/message/on_sync_widget.dart';
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
  List<bool> _visibleTabs = [true, false, false, false];
   bool _snackbarShown = false;
  void _onBarTapped(int index) async {
    bool isConnected = await ConnectivityService().isOnline();
    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _visibleTabs[index] = true;
        _selectedTabIndex = index;
      });
      widget.orderController.updateTabIndex(index);
    } else {
      if (!_snackbarShown) {
        _snackbarShown = true;
        showNoInternetSnackBar(context);
        Future.delayed(Duration(seconds: 3), () {
          _snackbarShown = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MyCommnonContainer(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 211, 211, 211)
                        .withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(4, 4),
                  ),
                ],
                borderRadius: 25,
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                isCommonBorder: true,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PendingPaymentChart(
                    chartController: widget.orderController,
                    onBarTapped: _onBarTapped,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 20),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedTabIndex == index;
                  if (!_visibleTabs[index]) {
                    return const SizedBox.shrink();
                  }
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
                          fontSize: 12,
                          fontFamily: 'Poppins_Regular',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: PendingPaymentBottomWidget(
          //     orderController: widget.orderController,
          //     selectedTabIndex: _selectedTabIndex,
          //   ),
          // )
        ];
      },
      body: IntrinsicHeight(
        child: PendingPaymentBottomWidget(
          orderController: widget.orderController,
          selectedTabIndex: _selectedTabIndex,
        ),
      ),
      // body: SizedBox.shrink(),
    );
  }
}
