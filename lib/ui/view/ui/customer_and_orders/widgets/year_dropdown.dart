
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/cus_provider/cus_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your other necessary packages (DashboardProvider, ConnectivityService, constants, etc.)

class YearCustomerAndOrdersDropdown extends StatefulWidget {
  final Function(int) onYearSelected;

  const YearCustomerAndOrdersDropdown({
    super.key, 
    required this.onYearSelected
  });

  @override
  State<YearCustomerAndOrdersDropdown> createState() => _YearCustomerAndOrdersDropdownState();
}

class _YearCustomerAndOrdersDropdownState extends State<YearCustomerAndOrdersDropdown> {
  final int startYear = 2024;
  final int endYear = DateTime.now().year;
  late List<int> years;
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Generate years list (e.g., [2024, 2025, 2026])
    years = startYear <= endYear
        ? List.generate(endYear - startYear + 1, (index) => (startYear + index))
        : [endYear];
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: Use CustomersProvider here, not DashboardProvider
    return Consumer<CustomersProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 35, 
          child: Container(
            key: _dropdownKey,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: InkWell(
              onTap: () async {
                // 1. Calculate Menu Position
                final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
                final Offset position = renderBox.localToGlobal(Offset.zero);
                final Size size = renderBox.size;

                // 2. Show Menu
                await showMenu<int>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy + size.height,
                    position.dx + size.width,
                    position.dy + size.height + 200,
                  ),
                  items: years.map((year) {
                    return PopupMenuItem<int>(
                      value: year,
                      child: ListTile(
                        title: Text(year.toString()),
                        // Highlights the currently selected year from CustomersProvider
                        trailing: provider.selectedDashboardYear == year
                            ? const Icon(Icons.check, color: Colors.blue, size: 18)
                            : null,
                        onTap: () {
                          Navigator.pop(context); // Close the menu
                          // 3. Trigger the callback immediately
                          widget.onYearSelected(year); 
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display the selected year from Provider
                    Text(
                      provider.selectedDashboardYear.toString(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
