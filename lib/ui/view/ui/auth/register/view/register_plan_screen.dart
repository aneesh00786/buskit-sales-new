import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_right_side_widgte.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/constant/register_items_list.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/plan_amount_selection.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/plans_table_widget.dart';
import 'package:flutter/material.dart';

class RegisterPlanScreen extends StatefulWidget {
  const RegisterPlanScreen({super.key});

  @override
  State<RegisterPlanScreen> createState() => _RegisterPlanScreenState();
}

class _RegisterPlanScreenState extends State<RegisterPlanScreen> {
  late Future<List<Plan>> _fetchedPlans;

  @override
  void initState() {
    super.initState();
    _fetchedPlans = ApiWorker().fetchPlans();
  }

  int? selectedPlanIndex;

  void onCheckedChanged(int index) {
    setState(() {
      selectedPlanIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          content: 'Register Plan',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, bottom: 16, top: 16),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: white,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                      color: black.withOpacity(0.2))
                ]),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 65, 203, 210),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomText(
                          content: "Feature",
                          color: white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlanCheckboxRow(
                              planName: "Basic \$10.00/Mo",
                              isSelected: selectedPlanIndex == 0,
                              onChanged: (_) => onCheckedChanged(0),
                            ),
                            PlanCheckboxRow(
                              planName: "Basic \$120.00/Year",
                              isSelected: selectedPlanIndex == 1,
                              onChanged: (_) => onCheckedChanged(1),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlanCheckboxRow(
                              planName: "Premium \$20.00/Mo",
                              isSelected: selectedPlanIndex == 2,
                              onChanged: (_) => onCheckedChanged(2),
                            ),
                            PlanCheckboxRow(
                              planName: "Premium \$240.00/Ye",
                              isSelected: selectedPlanIndex == 3,
                              onChanged: (_) => onCheckedChanged(3),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlanCheckboxRow(
                              planName: "Maxi \$30.00/Mo",
                              isSelected: selectedPlanIndex == 4,
                              onChanged: (_) => onCheckedChanged(4),
                            ),
                            PlanCheckboxRow(
                              planName: "Maxi \$360.00/Ye",
                              isSelected: selectedPlanIndex == 5,
                              onChanged: (_) => onCheckedChanged(5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color.fromARGB(255, 65, 203, 210),
                        Color.fromARGB(255, 145, 234, 238),
                        Color.fromARGB(255, 113, 165, 238)
                      ]),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                            color: black.withOpacity(0.2))
                      ],
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        content: "Try any plans for 14 days FREE",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: white,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomText(
                        content: "Cancel Anytime",
                        color: white,
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<Plan>>(
                  future: _fetchedPlans,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No plans available.'));
                    }
                    List<Plan> plans = snapshot.data!;
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
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF85C3FF),
                                          Color(0xFF62D0E0)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          content: "Add Card Details",
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {},
                                          icon:
                                              const Icon(Icons.apple, size: 18),
                                          label: const Text("Pay"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Row(
                                            children: [
                                              const Expanded(child: Divider()),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Row(
                                                  children: [
                                                    const Expanded(
                                                      child: Divider(
                                                        color: Colors.grey,
                                                        thickness: 1,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: CustomText(
                                                        content: "OR",
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      child: Divider(
                                                        color: Colors.grey,
                                                        thickness: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Expanded(child: Divider()),
                                            ],
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Add new card:",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: "Card holder name",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: "Card number",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "CVV",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "MM",
                                                  border: OutlineInputBorder(),
                                                ),
                                                items:
                                                    List.generate(12, (index) {
                                                  final month = (index + 1)
                                                      .toString()
                                                      .padLeft(2, '0');
                                                  return DropdownMenuItem(
                                                      value: month,
                                                      child: Text(month));
                                                }),
                                                onChanged: (_) {},
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "YY",
                                                  border: OutlineInputBorder(),
                                                ),
                                                items:
                                                    List.generate(10, (index) {
                                                  final year =
                                                      (DateTime.now().year +
                                                              index)
                                                          .toString();
                                                  return DropdownMenuItem(
                                                      value: year,
                                                      child: Text(year));
                                                }),
                                                onChanged: (_) {},
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF2F4F7),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                "Ends on: April 28, 2026",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF2F4F7),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                "Amount: ₹10256.40",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 50,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 65, 203, 210),
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: CustomText(
                          content: 'Subscribe Basic for ₹10256.40/Yr',
                          fontSize: 18,
                          color: white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
