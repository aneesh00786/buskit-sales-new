// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, use_build_context_synchronously, unused_field
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/payment_dialog.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/paypal_starting_method.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/plan_amount_selection.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/quantity_manager.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/table_items.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class RegisterPlanScreen extends StatefulWidget {
  const RegisterPlanScreen({super.key});

  @override
  State<RegisterPlanScreen> createState() => _RegisterPlanScreenState();
}

class _RegisterPlanScreenState extends State<RegisterPlanScreen> {
  late Future<List<Plan>> _fetchedPlans;
  int _selectedQuantity = 1;
  List<Plan>? plans;
  Plan? selectedPlan;
  @override
  void initState() {
    super.initState();
    _fetchedPlans = ApiWorker().fetchPlans().then((fetched) {
      plans = fetched;
      selectedPlan = plans!.firstWhereOrNull(
        (p) =>
            (p.planName?.toLowerCase().trim() == 'basic') &&
            (p.billingCycle?.toLowerCase().trim() == 'monthly'),
      );
      selectedPlan ??= plans!.isNotEmpty ? plans!.first : null;
      setState(() {});
      return plans!;
    });
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _getSelectedPlanText() {
    if (selectedPlan == null) {
      return 'Subscribe Basic for \$0.00/Yr';
    }
    final price = double.tryParse(selectedPlan!.price.toString()) ?? 0.0;
    final totalPrice = price * _selectedQuantity;
    final cycle = selectedPlan!.billingCycle?.trim().toLowerCase();
    final durationLabel = (cycle == 'monthly') ? '/Mo' : '/Yr';

    return 'Subscribe ${selectedPlan!.planName} for ${_formatCurrency(totalPrice)}$durationLabel';
  }

  Map<String, List<Plan>> _groupPlansByName(List<Plan> plans) {
    final Map<String, List<Plan>> grouped = {};

    for (final plan in plans) {
      final name = plan.planName?.toLowerCase().trim();
      grouped.putIfAbsent(name ?? '', () => []).add(plan);
    }

    return grouped;
  }

  void onCheckedChanged(Plan plan) {
    setState(() {
      selectedPlan = plan;
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
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: FutureBuilder<List<Plan>>(
                    future: _fetchedPlans,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No plans available.'));
                      }
                      plans = snapshot.data ?? [];
                      final groupedPlans = _groupPlansByName(plans!);
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: CustomText(
                                    content: "Feature",
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: groupedPlans.entries.map((entry) {
                                    final planOptions = entry.value;

                                    Plan? monthlyPlan =
                                        planOptions.firstWhereOrNull(
                                      (p) =>
                                          p.billingCycle
                                              ?.trim()
                                              .toLowerCase() ==
                                          'monthly',
                                    );
                                    Plan? yearlyPlan =
                                        planOptions.firstWhereOrNull(
                                      (p) =>
                                          p.billingCycle
                                              ?.trim()
                                              .toLowerCase() ==
                                          'yearly',
                                    );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (monthlyPlan != null)
                                            PlanCheckboxRow(
                                              planName:
                                                  "${monthlyPlan.planName} ${_formatCurrency(double.tryParse(monthlyPlan.price ?? '0.0') ?? 0.0)}/Mo USD",
                                              isSelected: selectedPlan
                                                      ?.planIdentifier ==
                                                  monthlyPlan.planIdentifier,
                                              onChanged: (_) =>
                                                  onCheckedChanged(monthlyPlan),
                                            ),
                                          if (yearlyPlan != null)
                                            PlanCheckboxRow(
                                              planName:
                                                  "${_formatCurrency(double.tryParse(yearlyPlan.price ?? '0.0') ?? 0.0)}/Year USD",
                                              isSelected: selectedPlan
                                                      ?.planIdentifier ==
                                                  yearlyPlan.planIdentifier,
                                              onChanged: (_) =>
                                                  onCheckedChanged(yearlyPlan),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            )),
                      );
                    },
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
                    List<Plan> plans = snapshot.data ?? [];
                    return TableItems(plans: plans);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomText(
                  content: "Number of liescense",
                ),
                const SizedBox(
                  height: 20,
                ),
                QuantitySelector(
                  initialQuantity: _selectedQuantity,
                  onChanged: (newQty) {
                    setState(() {
                      _selectedQuantity = newQty;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      if (!mounted) return;

                      if (selectedPlan != null) {
                        final unitPrice =
                            double.tryParse(selectedPlan!.price ?? '0') ?? 0.0;
                        final totalAmount = unitPrice * _selectedQuantity;

                        showPaymentDialog(context, selectedPlan!, totalAmount,
                            _selectedQuantity);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a plan first.')),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 65, 203, 210),
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomText(
                          content: _getSelectedPlanText(),
                          textAlign: TextAlign.center,
                          fontSize: 16,
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

  void showPaymentDialog(BuildContext context, Plan plan, double totalAmount,
      int selectedQuantity) async {
    if (Stripe.publishableKey.isEmpty) {
      Stripe.publishableKey = 'pk_test_f5u40cbDttJ0TfoPDP7ynfNM00XLdPmGKM';
      await Stripe.instance.applySettings();
    }
    startPayPalPaymentFlow(
        context: context,
        plan: plan,
        selectedQuantity: selectedQuantity,
        totalAmount: totalAmount);

    // showDialog(
    //   context: context,
    //   builder: (context) => SizedBox(
    //     child: Dialog(
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //       child: PaymentDialogContent(
    //         plan: plan,
    //         totalAmount: totalAmount,
    //         selectedQuantity: selectedQuantity,
    //       ),
    //     ),
    //   ),
    // );
  }
}
