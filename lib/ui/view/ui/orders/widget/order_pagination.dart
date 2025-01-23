import 'dart:developer';

import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/orders/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPaginationWidget extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    log('Total Pages ${orderController.totalPages.value}');
    return Obx(() {
      // Hide pagination if totalPages is 1
      if (orderController.totalPages.value <= 1) {
        // return SizedBox.shrink();
        return Container(
          width: 200,
          height: 50,
          color: Colors.yellow,
        );
      }

      return Container(
        width: 3 * 62.0,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: IconButton(
                icon: const Icon(
                  Icons.keyboard_double_arrow_left,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (orderController.currentPage.value > 1) {
                    orderController.goToPreviousPage();
                  }
                },
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  orderController.totalPages.value.clamp(1, 3),
                  (index) {
                    int visiblePage;
                    if (orderController.totalPages.value == 2) {
                      // For 2 total pages, show only pages 1 and 2
                      visiblePage = index + 1;
                    } else {
                      // Normal case for totalPages > 2
                      int firstPage = (orderController.currentPage.value - 1)
                          .clamp(1, orderController.totalPages.value - 2);
                      visiblePage = (firstPage + index).clamp(
                        1,
                        orderController.totalPages.value,
                      );
                    }

                    return GestureDetector(
                      onTap: () => orderController.goToPage(visiblePage),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 40,
                          width: 25,
                          decoration: BoxDecoration(
                            color:
                                orderController.currentPage.value == visiblePage
                                    ? Colors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '$visiblePage',
                              style: TextStyle(
                                fontSize: 13,
                                color: orderController.currentPage.value ==
                                        visiblePage
                                    ? primaryColor
                                    : Colors.white,
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
            SizedBox(
              height: 40,
              width: 40,
              child: IconButton(
                icon: const Icon(
                  Icons.keyboard_double_arrow_right,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (orderController.currentPage.value <
                      orderController.totalPages.value) {
                    orderController.goToNextPage();
                  }
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
