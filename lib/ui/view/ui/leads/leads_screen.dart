import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/view/ui/leads/widget/lead_bottom_screen.dart';
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

  @override
  void initState() {
    leadsController.loadLeadsCustomerData.then((value) {
      leadsController.leadsCustomerDataList.value = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: nkRegularPadding(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              LeadTopScreen(
                leadsController: leadsController,
              ),
              LeadBottomScreen(
                leadsController: leadsController,
              )
            ],
          ),
        ),
      ),
    );
  }
}
