
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/sales_return_controller.dart';

class SalesReturnWeekDropdown extends StatefulWidget {
  const SalesReturnWeekDropdown({super.key});
  @override
  State<SalesReturnWeekDropdown> createState() => _SalesReturnWeekDropdownState();
}

class _SalesReturnWeekDropdownState extends State<SalesReturnWeekDropdown> {
  final SalesReturnController controller = Get.find<SalesReturnController>();
  final GlobalKey _dropdownKey = GlobalKey();
  late List<String> weeks;
  final Map<String, StateSetter> _weekStateSetters = {};
  StateSetter? _selectAllStateSetter;

  @override
  void initState() {
    super.initState();
    // Generate 52 weeks
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (controller.selectedWeeks.isEmpty) {
          weeks = List.generate(52, (index) => "week${index + 1}");
          // Logic to set default week
          // e.g., controller.selectedWeeks.add("weekX");
       }
    });
  
  }

  void _toggleWeek(String week) {
    if (controller.selectedWeeks.contains(week)) {
      controller.selectedWeeks.remove(week);
    } else {
      controller.selectedWeeks.add(week);
    }
    _weekStateSetters[week]?.call(() {});
    _selectAllStateSetter?.call(() {});
    setState(() {});
  }

  void _toggleSelectAll(bool? value) {
    if (value == true) {
      controller.selectedWeeks.assignAll(weeks);
    } else {
      controller.selectedWeeks.clear();
    }
    _selectAllStateSetter?.call(() {});
    _weekStateSetters.forEach((_, setter) => setter(() {}));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 45, width: 140,
          child: Container(
            key: _dropdownKey,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.grey.shade50, blurRadius: 8, offset: const Offset(2, 4))],
            ),
            child: GestureDetector(
              onTap: () async {
                 final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
                 final Offset position = renderBox.localToGlobal(Offset.zero);
                 await showMenu(
                   context: context,
                   position: RelativeRect.fromLTRB(position.dx, position.dy + renderBox.size.height, position.dx + renderBox.size.width, position.dy),
                   items: <PopupMenuEntry<dynamic>>[
                     PopupMenuItem(
                       child: StatefulBuilder(builder: (c, setStatePopup) {
                         _selectAllStateSetter = setStatePopup;
                         return CheckboxListTile(
                           value: controller.selectedWeeks.length == weeks.length,
                           onChanged: _toggleSelectAll,
                           title: const Text("Select All"),
                           controlAffinity: ListTileControlAffinity.leading,
                         );
                       }),
                     ),
                     const PopupMenuDivider(),
                     ...weeks.map((week) => PopupMenuItem(
                       child: StatefulBuilder(builder: (c, setStatePopup) {
                         _weekStateSetters[week] = setStatePopup;
                         return CheckboxListTile(
                           value: controller.selectedWeeks.contains(week),
                           onChanged: (_) => _toggleWeek(week),
                           title: Text(week.replaceAll("week", "Week ")),
                           controlAffinity: ListTileControlAffinity.leading,
                         );
                       }),
                     ))
                   ]
                 );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Expanded(
                      child: Text(
                        controller.selectedWeeks.isEmpty ? "Select Weeks" : "${controller.selectedWeeks.length} weeks",
                        style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis
                      )
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}