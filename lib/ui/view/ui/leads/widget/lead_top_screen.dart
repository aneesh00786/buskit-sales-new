import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/diloags/leads_diloag/add_leads_diloag.dart';
import 'package:busskit_salesexecutive/ui/utills/const_string.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/customer_and_orders_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/customer_and_orders/widgets/notification_widget.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadTopScreen extends StatelessWidget {
  final LeadsController leadsController;
  const LeadTopScreen({super.key, required this.leadsController});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AddLeadsBt(),
            Spacer(),
            NotificationWidget(),
            UpdateAminBt(),
          ],
        ),
      ],
    );
  }

  Widget get leadTopLeadsWidget {
    return GestureDetector(
      onTap: () => Get.dialog(AddLeadsDiloag(
        leadsController: leadsController,
      )),
      child: Container(
        width: 90,
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4.0), // Border radius
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leads,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
