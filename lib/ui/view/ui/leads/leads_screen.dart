import 'package:busskit_salesexecutive/measurements/ResponsiveInfo.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_customer_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/leads_rejected_controller.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_bottom_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_tabbar.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_top_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'leads_controller.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({Key? key}) : super(key: key);

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final LeadsController leadsController = Get.put(LeadsController());
  final CustomersController leadsCustomerController =
      Get.put(CustomersController());
  final RejectedLeadsController rejectedLeadsController =
      Get.put(RejectedLeadsController());

  @override
  void initState() {
    leadsController.loadLeadsCustomerData.then((value) {
      leadsController.leadsCustomerDataList.value = value;
    });
    leadsCustomerController.loadLeadsCustomerData.then((value) {
      leadsCustomerController.customersDataList.value = value;
    });
    rejectedLeadsController.loadRejectedLeadsData.then((value) {
      rejectedLeadsController.rejectedLeadsDataList.value = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () async {
          await leadsController.loadLeadsCustomerData;
        },
        child: Column(
          children: [
            Padding(
              padding: nkRegularPadding(),
              child: LeadTopScreen(
                leadsController: leadsController,
              ),
            ),
            Flexible(
              child: LeadsTabBar(
                leadController: leadsController,
                leadsCustomerController: leadsCustomerController,
                rejectedLeadsController: rejectedLeadsController,
              ),
            )
          ],
        ),
      ),
    );
  }
}
