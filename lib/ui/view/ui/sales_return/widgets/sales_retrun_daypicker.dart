
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesReturnDayPicker extends StatelessWidget {
  const SalesReturnDayPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesReturnController controller = Get.find<SalesReturnController>();
    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 45, width: 140,
          child: Container(
             decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000), lastDate: DateTime(2100)
                );
                if (picked != null) {
                  controller.setSelectedDay(DateFormat('yyyy-MM-dd').format(picked));
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.selectedDayDate.value.isEmpty ? "DD-MM-YYYY" : 
                      DateFormat('dd-MM-yyyy').format(DateTime.parse(controller.selectedDayDate.value)),
                      style: const TextStyle(fontSize: 12)
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        MyThemeButton(
          buttonText: 'Go',
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          height: 45,
          onPressed: () async {
             bool isOnline = await ConnectivityService().isOnline();
             if(!isOnline) return;
             controller.currentPage.value = 1;
             await controller.updateSalesReturnList();
          },
        )
      ],
    ));
  }
}