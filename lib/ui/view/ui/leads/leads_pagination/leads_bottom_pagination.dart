// ignore_for_file: use_build_context_synchronously

import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsBottomPaginationWidget extends StatelessWidget {
  final LeadsController leadsController = Get.put(LeadsController());

  LeadsBottomPaginationWidget({super.key});

  List<dynamic> _buildPagination(int currentPage, int totalPages) {
    List<dynamic> pages = [];

    if (totalPages <= 5) {
      if (currentPage == 1 && totalPages == 5) {
        pages.addAll([1, 2, 3, '...5']);
        return pages;
      }

      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
      return pages;
    }

    if (currentPage <= 2) {
      pages.addAll([1, 2, 3, '...$totalPages']);
    } else if (currentPage == 3) {
      pages.addAll([1, 2, 3, 4, '...$totalPages']);
    } else if (currentPage == totalPages - 2) {
      pages.add('1...');
      pages
          .addAll([totalPages - 3, totalPages - 2, totalPages - 1, totalPages]);
    } else if (currentPage >= totalPages - 1) {
      pages.add('1...');
      pages.addAll([totalPages - 2, totalPages - 1, totalPages]);
    } else {
      pages.add('1...');
      pages.addAll(
          [currentPage - 1, currentPage, currentPage + 1, '...$totalPages']);
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (leadsController.totalPages.value <= 1) {
        return const SizedBox.shrink();
      }

      return Container(
        width: 280,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                if (leadsController.currentPage.value > 1) {
                  bool isOnline = await ConnectivityService().isOnline();
                  if (isOnline) {
                    leadsController.goToPreviousPage();
                  } else {
                    showCustomToastDisplay(
                        context, "You are Offline!", red, Icons.warning);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: const Icon(
                  Icons.keyboard_double_arrow_left,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildPagination(leadsController.currentPage.value,
                        leadsController.totalPages.value)
                    .map<Widget>((item) {
                  if (item is int) {
                    final bool isCurrent =
                        item == leadsController.currentPage.value;
                    return GestureDetector(
                      onTap: isCurrent
                          ? null
                          : () async {
                              bool isOnline =
                                  await ConnectivityService().isOnline();
                              if (isOnline) {
                                leadsController.goToPage(item);
                              } else {
                                showCustomToastDisplay(context,
                                    "You are Offline!", red, Icons.warning);
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 40,
                          width: 25,
                          decoration: BoxDecoration(
                            color:
                                isCurrent ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '$item',
                              style: TextStyle(
                                fontSize: 13,
                                color: isCurrent ? primaryColor : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (item is String && item.endsWith('...')) {
                    final int page = int.parse(item.replaceAll('...', ''));
                    return GestureDetector(
                      onTap: () async {
                        bool isOnline = await ConnectivityService().isOnline();
                        if (isOnline) {
                          leadsController.goToPage(page);
                        } else {
                          showCustomToastDisplay(
                              context, "You are Offline!", red, Icons.warning);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (item is String && item.startsWith('...')) {
                    final int page = int.parse(item.replaceAll('...', ''));
                    return GestureDetector(
                      onTap: () async {
                        bool isOnline = await ConnectivityService().isOnline();
                        if (isOnline) {
                          leadsController.goToPage(page);
                        } else {
                          showCustomToastDisplay(
                              context, "You are Offline!", red, Icons.warning);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }).toList(),
              ),
            ),
            InkWell(
              onTap: () async {
                if (leadsController.currentPage.value <
                    leadsController.totalPages.value) {
                  bool isOnline = await ConnectivityService().isOnline();
                  if (isOnline) {
                    leadsController.goToNextPage();
                  } else {
                    showCustomToastDisplay(
                        context, "You are Offline!", red, Icons.warning);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: const Icon(
                  Icons.keyboard_double_arrow_right,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
