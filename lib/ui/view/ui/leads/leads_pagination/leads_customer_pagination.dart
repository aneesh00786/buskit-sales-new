
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsCustomerPaginationWidget extends StatelessWidget {
  final CustomersController leadsCustomerController = Get.put(CustomersController());

  LeadsCustomerPaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (leadsCustomerController.totalPages.value <= 1) {
        return const SizedBox.shrink();
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
                  if (leadsCustomerController.currentPage.value > 1) {
                    leadsCustomerController.goToPreviousPage();
                  }
                },
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  leadsCustomerController.totalPages.value.clamp(1, 3),
                  (index) {
                    int visiblePage;
                    if (leadsCustomerController.totalPages.value == 2) {
                      // For 2 total pages, show only pages 1 and 2
                      visiblePage = index + 1;
                    } else {
                      // Normal case for totalPages > 2
                      int firstPage = (leadsCustomerController.currentPage.value - 1)
                          .clamp(1, leadsCustomerController.totalPages.value - 2);
                      visiblePage = (firstPage + index).clamp(
                        1,
                        leadsCustomerController.totalPages.value,
                      );
                    }

                    return GestureDetector(
                      onTap: () => leadsCustomerController.goToPage(visiblePage),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 40,
                          width: 25,
                          decoration: BoxDecoration(
                            color:
                                leadsCustomerController.currentPage.value == visiblePage
                                    ? Colors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '$visiblePage',
                              style: TextStyle(
                                fontSize: 13,
                                color: leadsCustomerController.currentPage.value ==
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
                  if (leadsCustomerController.currentPage.value <
                      leadsCustomerController.totalPages.value) {
                    leadsCustomerController.goToNextPage();
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
