
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/option_list.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/options_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/performance_screen/widgets/staff_target_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/products/staff_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  bool isActive = false;
  StaffController staffController =Get.put(StaffController()); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          profiloe(),
        ],
      ),
      body: Column(
        children: [
          OptionsWidget(options: defaultOption(context)),
          nkMediumSizeBox(),
          StaffTargetDialog(staffController: staffController,)
        ],
      ),
    );
  }
}

class PerformanceChartWidget extends StatefulWidget {
  const PerformanceChartWidget({super.key});

  @override
  State<PerformanceChartWidget> createState() => _PerformanceChartWidgetState();
}

class _PerformanceChartWidgetState extends State<PerformanceChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GridView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              return _buildChartContainer(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(int index) {
    List<Map<String, String>> data = [
      {"title": "title", "value": "1"},
      {"title": "title", "value": "2"},
      {"title": "title", "value": "3"},
      {"title": "title", "value": "4"},
    ];
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data[index]["value"] ?? "",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data[index]["title"] ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

