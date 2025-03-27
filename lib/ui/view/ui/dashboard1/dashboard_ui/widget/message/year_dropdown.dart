import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/view/ui/dashboard1/provider/dash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YearDropdown extends StatefulWidget {
  const YearDropdown({super.key});

  @override
  _YearDropdownState createState() => _YearDropdownState();
}

class _YearDropdownState extends State<YearDropdown> {
  final int startYear = 2024;
  final int endYear = DateTime.now().year;

  late List<int> years;

  @override
  void initState() {
    super.initState();
    years = startYear <= endYear
        ? List.generate(endYear - startYear + 1, (index) => (startYear + index))
        : [];

    final currentYear = DateTime.now().year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      if (provider.selectedYear == 0) {
        provider.updateSelectedYear(currentYear);
      }
    });
  }

  void _selectYear(BuildContext context, int year) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.updateSelectedYear(year);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 45,
              width: 160,
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
                child: PopupMenuButton<int>(
                  tooltip: "Select Year",
                  onSelected: (year) => _selectYear(context, year),
                  itemBuilder: (context) => years.map((year) {
                    return PopupMenuItem<int>(
                      value: year,
                      child: ListTile(
                        title: Text(year.toString()),
                        trailing: provider.selectedYear == year
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                      ),
                    );
                  }).toList(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            provider.selectedYear.toString(),
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
            CustomButton(
              text: 'Go',
              onPressed: () async {
                print("Selected Year: ${provider.selectedYear}");
                final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.setTempToFilter();
    dashboardProvider.fetchData();
              },
              color: primaryColor,
            ),
          ],
        );
      },
    );
  }
}
