import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesReturnMonthDropdown extends StatelessWidget {
  const SalesReturnMonthDropdown({super.key});

  static const List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  Widget build(BuildContext context) {
    final SalesReturnController controller = Get.find<SalesReturnController>();

    return Obx(() {
      String currentSelected = controller.selectedMonths.isNotEmpty
          ? controller.selectedMonths.first
          : DateFormat('MMMM').format(DateTime.now());

      if (!months.contains(currentSelected)) {
        currentSelected = months[DateTime.now().month - 1];
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
                  controller.selectedMonths.assignAll([newValue]);
                }
              },
              items: months.map((month) => DropdownMenuItem<String>(
                value: month,
                child: Text(month.tr),
              )).toList(),
            ),
          ),
        ),
      );
    });
  }
}
