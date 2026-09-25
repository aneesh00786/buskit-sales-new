import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesReturnWeekDropdown extends StatelessWidget {
  const SalesReturnWeekDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesReturnController controller = Get.find<SalesReturnController>();
    final List<String> weeks = List.generate(52, (index) => "week${index + 1}");

    return Obx(() {
      String currentSelected = controller.selectedWeeks.isNotEmpty
          ? controller.selectedWeeks.first
          : "week1";

      if (!weeks.contains(currentSelected)) {
        currentSelected = weeks.first;
      }

      return SizedBox(
        height: 45,
        width: 140,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade50,
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentSelected,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins_Regular',
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.selectedWeeks.assignAll([newValue]);
                }
              },
              items: weeks.map((week) => DropdownMenuItem<String>(
                value: week,
                child: Text(week.replaceAll("week", "Week ".tr)),
              )).toList(),
            ),
          ),
        ),
      );
    });
  }
}
