import 'dart:async';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/common/height_width.dart';
import 'package:busskit_salesexecutive/exception_widget_handler/nk_widget_exception_handler.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_responce/order_responce.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/order_pagination.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/helpers.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/widget/orders_bottom_widget/widgets/orders_bottom_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderBottomWidget extends StatefulWidget {
  final OrderController orderController;
  final int selectedTabIndex;
  const OrderBottomWidget({
    super.key,
    required this.orderController,
    required this.selectedTabIndex,
  });

  @override
  State<OrderBottomWidget> createState() => _OrderBottomWidgetState();
}

class _OrderBottomWidgetState extends State<OrderBottomWidget> {
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController1 = ScrollController();

  Timer? _debounce;
  @override
  void didUpdateWidget(covariant OrderBottomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTabIndex != widget.selectedTabIndex) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        widget.orderController
            .loadOrderData(selectedIndex: widget.selectedTabIndex);
        widget.orderController.loadOrderCountData();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController1.addListener(() {
      if (_scrollController2.hasClients &&
          _scrollController1.position.pixels !=
              _scrollController2.position.pixels) {
        _scrollController2.jumpTo(_scrollController1.position.pixels);
      }
    });
    _scrollController2.addListener(() {
      if (_scrollController1.hasClients &&
          _scrollController2.position.pixels !=
              _scrollController1.position.pixels) {
        _scrollController1.jumpTo(_scrollController2.position.pixels);
      }
    });
  }

  String get option {
    switch (widget.selectedTabIndex) {
      case 0:
        return 'Recieved';
      case 1:
        return 'Waiting';
      case 2:
        return 'Quick Sale';
      case 3:
        return 'Processing';
      case 4:
        return 'Packed & ready for delivery';
      case 5:
        return 'Delivered';
      case 6:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (widget.orderController.isOrderLoading.value) {
          return const Center(child: Text('LOADING'));
        }
        if (widget.orderController.orderDataList.isEmpty) {
          return const Center(child: Text('Record Not Found'));
        }

        return NkWidgetExceptionHandel(
          onRetryPressed: () => {},
          data: widget.orderController.orderDataList,
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      color: primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: CustomText(
                                    content: 'SI No.',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 8,
                              child: Center(
                                child: CustomText(
                                    content: '$option List',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ),
                    // ignore: unnecessary_null_comparison
                    if (widget.orderController.orderDataList != null) ...[
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const ClampingScrollPhysics(),
                          controller: _scrollController1,
                          itemCount:
                              widget.orderController.orderDataList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            OrderData orderData =
                                widget.orderController.orderDataList[index];
                            if (orderData.cart == null ||
                                orderData.cart!.isEmpty) {
                              return Container(
                                color: index.isEven
                                    ? Colors.white
                                    : Colors.grey[50],
                                height: (fullScreenHeight(context) - 242) / 10,
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2, child: placeholderWidget()),
                                    Expanded(
                                        flex: 8, child: placeholderWidget()),
                                  ],
                                ),
                              );
                            }
                            return Container(
                              color:
                                  index.isEven ? Colors.white : Colors.grey[50],
                              height: (MediaQuery.of(context).orientation ==
                                      Orientation.portrait)
                                  ? (fullScreenHeight(context) - 250) / 10
                                  : 70,
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: CustomText(
                                        content:
                                            '${((widget.orderController.currentPage.value - 1) * 10) + (index + 1)}.',
                                        maxLine: 1,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 8,
                                    child: customerDetailsWidget(
                                        orderData.cart!.first),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        height: 50,
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            OrderPaginationWidget(
                                orderController: widget.orderController),
                            const Spacer()
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OrdersBottomTitleRow(
                        widget: widget, scrollController2: _scrollController2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


