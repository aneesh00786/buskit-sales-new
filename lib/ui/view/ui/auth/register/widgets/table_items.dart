import 'package:busskit_salesexecutive/ui/view/ui/auth/register/constant/register_items_list.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/plans_table_widget.dart';
import 'package:flutter/material.dart';

class TableItems extends StatelessWidget {
  const TableItems({
    super.key,
    required this.plans,
  });

  final List<Plan> plans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TableTitle(
          title: "Dashboard",
        ),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.dashboardPlan),
        TableTitle(title: "Customers and Orders"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.customersAndOrdersPlan),
        TableTitle(title: "Products"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.productsPlan),
        TableTitle(title: "Pending Payments"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.pendingPaymentsPlan),
        TableTitle(title: "Leads"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.leadsPlan),
        TableTitle(title: "Calendar"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.calenderPlan),
        TableTitle(title: "Staff"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.staffsPlan),
        TableTitle(title: "Orders"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.ordersPlan),
        TableTitle(title: "Settings"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.settingsPlan),
        TableTitle(title: "Customer Dashboard"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.customerDashboardPlan),
        TableTitle(title: "Sales - app Feature"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.salesappFeaturePlan),
        TableTitle(title: "Customers & Orders"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.customerOrderPlan),
        TableTitle(title: "Products"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss: RegisterItemsList.productPlans),
        TableTitle(title: "Pending Payments"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.pendingPaymentPlans),
        TableTitle(title: "Calendar"),
        PlansTableWidgets(
            plans: plans,
            featureNamesListss:
                RegisterItemsList.calenderPlans),
      ],
    );
  }
}
