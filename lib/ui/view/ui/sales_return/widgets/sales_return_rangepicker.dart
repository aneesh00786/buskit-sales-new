
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalesReturnRangePicker extends StatelessWidget {
  const SalesReturnRangePicker({super.key});

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final SalesReturnController controller = Get.find<SalesReturnController>();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2100)
    );
    if(picked != null) {
      String date = DateFormat('yyyy-MM-dd').format(picked);
      if(isStart) controller.rangeStartDate.value = date;
      else controller.rangeEndDate.value = date;
    }
  }

  Widget _box(BuildContext context, String date, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(context, isStart),
      child: Container(
        height: 42, width: 110,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date.isEmpty ? "YYYY-MM-DD" : date, style: const TextStyle(fontSize: 12)),
            const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SalesReturnController controller = Get.find<SalesReturnController>();
    return Obx(() => Row(
      children: [
        _box(context, controller.rangeStartDate.value, true),
        const SizedBox(width: 5),
        _box(context, controller.rangeEndDate.value, false),
        const SizedBox(width: 5),
        MyThemeButton(
          buttonText: 'Go',
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          height: 45,
          onPressed: () async {
             bool isOnline = await ConnectivityService().isOnline();
             if(!isOnline) return;
             
             if(controller.rangeStartDate.value.isEmpty || controller.rangeEndDate.value.isEmpty) {
               showCustomToastDisplay(context, "Select date range", red, Icons.close);
               return;
             }
             controller.currentPage.value = 1;
             await controller.updateSalesReturnList();
          },
        )
      ],
    ));
  }
}