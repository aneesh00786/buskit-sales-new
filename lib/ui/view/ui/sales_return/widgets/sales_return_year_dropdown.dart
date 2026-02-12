
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesReturnYearDropdown extends StatefulWidget {
  const SalesReturnYearDropdown({super.key});

  @override
  State<SalesReturnYearDropdown> createState() => _SalesReturnYearDropdownState();
}

class _SalesReturnYearDropdownState extends State<SalesReturnYearDropdown> {
  final SalesReturnController controller = Get.find<SalesReturnController>();
  final GlobalKey _dropdownKey = GlobalKey();
  
  final int startYear = 2024; // Adjust start year if needed
  late List<int> years;

  @override
  void initState() {
    super.initState();
    final int currentYear = DateTime.now().year;
    // Generate years from startYear to currentYear
    years = startYear <= currentYear
        ? List.generate(currentYear - startYear + 1, (index) => (startYear + index))
        : [currentYear];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedYear.value == 0) {
        controller.selectedYear.value = currentYear;
      }
    });
  }

  void _selectYear(int year) {
    controller.setSelectedYear(year);
    // Note: We don't call update() or setState() here because Obx handles the UI 
    // and the "Go" button handles the data fetch.
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 45,
          width: 140, // Matches other dropdown widths
          child: Container(
            key: _dropdownKey,
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
            child: GestureDetector(
              onTap: () async {
                bool isOnline = await ConnectivityService().isOnline();
                if (!isOnline) {
                  showCustomToastDisplay(context, "You are Offline!", Colors.red, Icons.close);
                  return;
                }

                final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
                final Offset position = renderBox.localToGlobal(Offset.zero);
                final Size size = renderBox.size;

                await showMenu<int>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy + size.height,
                    position.dx + size.width,
                    position.dy,
                  ),
                  items: years.map((year) {
                    return PopupMenuItem<int>(
                      value: year,
                      child: ListTile(
                        title: Text(year.toString()),
                        trailing: controller.selectedYear.value == year
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          Navigator.pop(context); // Close menu
                          _selectYear(year);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedYear.value != 0
                            ? controller.selectedYear.value.toString()
                            : 'Select Year',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        // The Go Button
        MyThemeButton(
          buttonText: 'Go',
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          height: 45,
          onPressed: () async {
            bool isOnline = await ConnectivityService().isOnline();
            if (!isOnline) {
              showCustomToastDisplay(context, "You are Offline!", Colors.red, Icons.close);
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