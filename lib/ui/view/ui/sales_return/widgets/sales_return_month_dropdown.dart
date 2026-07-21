
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
import 'package:busskit_salesexecutive/ui/components/widgets/my_theme_button.dart';
import 'package:busskit_salesexecutive/ui/view/ui/sales_return/controller/sales_return_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class SalesReturnMonthDropdown extends StatefulWidget {
  const SalesReturnMonthDropdown({super.key});
  @override
  State<SalesReturnMonthDropdown> createState() => _SalesReturnMonthDropdownState();
}

class _SalesReturnMonthDropdownState extends State<SalesReturnMonthDropdown> {
  final SalesReturnController controller = Get.find<SalesReturnController>();
  final GlobalKey _dropdownKey = GlobalKey();
  //  List<String> get months => ["January".tr, "February".tr, "March".tr, "April".tr, "May".tr, "June".tr, "July".tr, "August".tr, "September".tr, "October".tr, "November".tr, "December".tr];
 
  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  final Map<String, StateSetter> _monthStateSetters = {};
  StateSetter? _selectAllStateSetter;

  void _toggleMonth(String month) {
    if (controller.selectedMonths.contains(month)) {
      controller.selectedMonths.remove(month);
    } else {
      controller.selectedMonths.add(month);
    }
    _monthStateSetters[month]?.call(() {});
    _selectAllStateSetter?.call(() {});
    setState(() {});
  }

  void _toggleSelectAll(bool? value) {
    if (value == true) {
      controller.selectedMonths.assignAll(months);
    } else {
      controller.selectedMonths.clear();
    }
    _selectAllStateSetter?.call(() {});
    _monthStateSetters.forEach((_, setter) => setter(() {}));
    setState(() {});
  }

  String _getSelectedText() {
    if (controller.selectedMonths.length == months.length) return "All months".tr;
    if (controller.selectedMonths.length == 1) return controller.selectedMonths.first.tr;
    if (controller.selectedMonths.isNotEmpty) return "${controller.selectedMonths.length}" + "months selected".tr;
    return "Select Months".tr;
  }
  @override
  void initState() {
    super.initState();
    // ... any other setup ...

    // ✅ FIX: Wrap the state update in addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Ensure the default month is selected in the controller
       // This prevents the "setState during build" error
       if (controller.selectedMonths.isEmpty) {
         String currentMonth = DateFormat('MMMM').format(DateTime.now());
         controller.selectedMonths.add(currentMonth);
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50, width: 125, // Compact width
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
                 await showMenu<dynamic>(
                   context: context,
                   position: RelativeRect.fromLTRB(position.dx, position.dy + renderBox.size.height, position.dx + renderBox.size.width, position.dy),
                   items: <PopupMenuEntry<dynamic>>[
                     PopupMenuItem<dynamic>(
                       child: StatefulBuilder(builder: (c, setStatePopup) {
                         _selectAllStateSetter = setStatePopup;
                         return CheckboxListTile(
                           value: controller.selectedMonths.length == months.length,
                           onChanged: _toggleSelectAll,
                           title:  Text("Select All".tr, style: TextStyle(fontWeight: FontWeight.bold)),
                           controlAffinity: ListTileControlAffinity.leading,
                         );
                       }),
                     ),
                     const PopupMenuDivider(),
                     ...months.map((month) => PopupMenuItem<dynamic>(
                       child: StatefulBuilder(builder: (c, setStatePopup) {
                         _monthStateSetters[month] = setStatePopup;
                         return CheckboxListTile(
                           value: controller.selectedMonths.contains(month),
                           onChanged: (_) => _toggleMonth(month),
                           title: Text(month.tr),
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
                    Expanded(child: Text(_getSelectedText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
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