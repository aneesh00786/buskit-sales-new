// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/pending_payment_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_bottom_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/pending_payments/widget/pending_payment_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PendingTabBar extends StatefulWidget {
  final PendingPaymentController orderController;

  const PendingTabBar({super.key, required this.orderController});

  @override

  _PendingTabBarState createState() => _PendingTabBarState();
}

class _PendingTabBarState extends State<PendingTabBar> {
  Timer? _delayTimer;
  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All'.tr, 'Nearly Due'.tr, 'Due'.tr, 'Over Due'.tr];
  final List<bool> _visibleTabs = [true, false, false, false];
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
        showCustomToastDisplay(context, "You are Offline", red, Icons.warning);
        Future.delayed(const Duration(seconds: 3), () {
          _snackbarShown = false;
        });
      }
    }
  }

  void _startDelay() {
    _delayTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        widget.orderController.isLoadingPayment.value = false;
      });
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverToBoxAdapter(
            child: Container(
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
                  if (!_visibleTabs[index]) {
                    return const SizedBox.shrink();
                  }
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
                          widget.orderController
                              .updateTabIndex(_selectedTabIndex);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              fontFamily: 'Poppins_Regular',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ];
      },
      body: IntrinsicHeight(
        child: PendingPaymentBottomWidget(
          orderController: widget.orderController,
          selectedTabIndex: _selectedTabIndex,
        ),
      ),
    );
  }
}
