import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthDropdown extends StatefulWidget {
  const MonthDropdown({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MonthDropdownState createState() => _MonthDropdownState();
}

class _MonthDropdownState extends State<MonthDropdown> {
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  final Map<String, StateSetter> _monthStateSetters = {};
  StateSetter? _selectAllStateSetter;

  @override
  void initState() {
    super.initState();

    final currentMonthIndex = DateTime.now().month;
    final currentMonth = months[currentMonthIndex - 1];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      if (provider.selectedFilterMonths.isEmpty) {
        provider.updateSelectedMonths([currentMonth]);
      }
    });
  }

  void _toggleMonthSelection(BuildContext context, String month) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final selectedMonths = provider.selectedFilterMonths;

    if (selectedMonths.contains(month)) {
      selectedMonths.remove(month);
    } else {
      selectedMonths.add(month);
    }

    provider.updateSelectedMonths(List.from(selectedMonths));

    _monthStateSetters[month]?.call(() {});
    _selectAllStateSetter?.call(() {});
    setState(() {});
  }

  void _toggleSelectAll(BuildContext context, bool? value) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    if (value == true) {
      provider.updateSelectedMonths(List.from(months));
    } else {
      provider.updateSelectedMonths([]);
    }

    _selectAllStateSetter?.call(() {});
    for (var setter in _monthStateSetters.values) {
      setter.call(() {});
    }
    setState(() {});
  }

  void _clearSelection(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.updateSelectedMonths([]);

    _selectAllStateSetter?.call(() {});
    for (var setter in _monthStateSetters.values) {
      setter.call(() {});
    }
    setState(() {});
  }

  String _getSelectedText(BuildContext context) {
    final selectedMonths =
        Provider.of<DashboardProvider>(context).selectedFilterMonths;

    if (selectedMonths.length == months.length) {
      return "All months";
    } else if (selectedMonths.length == 1) {
      return selectedMonths.first;
    } else if (selectedMonths.isNotEmpty) {
      return "${selectedMonths.length} months selected";
    } else {
      return "Select Months";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      bool hasSelection = provider.selectedFilterMonths.isNotEmpty;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 45,
            width: 180, // Increased width to fit the close button
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
              child: PopupMenuButton<void>(
                tooltip: "Select Months",
                onSelected: (_) {},
                itemBuilder: (context) => [
                  PopupMenuItem<void>(
                    child: StatefulBuilder(
                      builder: (context, setStatePopup) {
                        _selectAllStateSetter = setStatePopup;
                        return CheckboxListTile(
                          value: provider.selectedFilterMonths.length ==
                              months.length,
                          onChanged: (value) {
                            _toggleSelectAll(context, value);
                          },
                          title: const Text(
                            "Select All",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                  const PopupMenuDivider(),
                  ...months.map((month) {
                    return PopupMenuItem<void>(
                      child: StatefulBuilder(
                        builder: (context, setStatePopup) {
                          _monthStateSetters[month] = setStatePopup;
                          return CheckboxListTile(
                            value:
                                provider.selectedFilterMonths.contains(month),
                            onChanged: (value) {
                              _toggleMonthSelection(context, month);
                            },
                            title: Text(month),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    );
                  }),
                ],
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getSelectedText(context),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasSelection)
                        GestureDetector(
                          onTap: () => _clearSelection(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child:
                                Icon(Icons.close, size: 16, color: Colors.grey),
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
          CustomButton(
            text: 'Go',
            onPressed: () async {
              final dashboardProvider =
                  Provider.of<DashboardProvider>(context, listen: false);
              await dashboardProvider.setTempToFilter();              
              dashboardProvider.fetchData();
            },
            color: primaryColor,
          ),
        ],
      );
    });
  }
}
