import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/constant/register_items_list.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/currency_uinit.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/plan_amount_selection.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/plans_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPlanScreen extends StatefulWidget {
  const RegisterPlanScreen({super.key});

  @override
  State<RegisterPlanScreen> createState() => _RegisterPlanScreenState();
}

class _RegisterPlanScreenState extends State<RegisterPlanScreen> {
  late Future<List<Plan>> _fetchedPlans;
  String _currencySymbol = '\$';
  double _conversionRate = 1.0;
  List<Plan>? plans;
  @override
  void initState() {
    super.initState();
    _fetchedPlans = ApiWorker().fetchPlans();
    _loadCountryAndSetCurrency();
  }

  int? selectedPlanIndex;
  Future<void> _loadCountryAndSetCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCountry = prefs.getString('selectedCountry') ?? 'USA';
    final currencyDetails = CurrencyUtils.findCurrency(selectedCountry);
    if (currencyDetails == null || currencyDetails['code'] == 'N/A') {
      print("Currency not found for country $selectedCountry, using default.");
      setState(() {
        _currencySymbol = '\$';
        _conversionRate = 1.0;
      });
      return;
    }
    final currencySymbol = currencyDetails['symbol'] ?? '';
    try {
      final conversionResult = await CurrencyUtils.convertToLocalCurrency(
        amount: 1.0,
        fromCurrency: 'USD',
        listOfSavedData: [
          {"country": selectedCountry}
        ],
      );

      setState(() {
        _currencySymbol = currencySymbol;
        _conversionRate =
            double.tryParse(conversionResult['price'].toString()) ?? 1.0;
      });
    } catch (e) {
      print("Error fetching conversion rate: $e");
      setState(() {
        _currencySymbol = currencySymbol;
        _conversionRate = 1.0;
      });
    }
  }

  String _formatCurrency(double amount) {
    return '$_currencySymbol ${(amount * _conversionRate).toStringAsFixed(2)}';
  }

  String _getSelectedPlanText() {
    if (selectedPlanIndex == null || plans == null) {
      return 'Subscribe Basic for ₹0.00/Yr';
    }
    final selectedPlan = plans?[selectedPlanIndex ?? 0];
    final price = double.tryParse("${selectedPlan?.price}") ?? 0.0;
    return 'Subscribe ${selectedPlan?.planName} for ${_formatCurrency(price)}/Yr';
  }

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
                      if (plans!.length < 6) {
                        return const Center(
                            child: Text('Insufficient plan data.'));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: CustomText(
                                  content: "Feature",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PlanCheckboxRow(
                                    planName:
                                        '${plans?[0].planName} ${_formatCurrency(double.parse("${plans?[0].price}"))}/Mo',
                                    isSelected: selectedPlanIndex == 0,
                                    onChanged: (_) => onCheckedChanged(0),
                                  ),
                                  PlanCheckboxRow(
                                    planName:
                                        "${_formatCurrency(double.parse("${plans?[1].price}"))}/Year",
                                    isSelected: selectedPlanIndex == 1,
                                    onChanged: (_) => onCheckedChanged(1),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PlanCheckboxRow(
                                    planName:
                                        "${plans?[2].planName} ${_formatCurrency(double.parse("${plans?[2].price}"))}/Mo",
                                    isSelected: selectedPlanIndex == 2,
                                    onChanged: (_) => onCheckedChanged(2),
                                  ),
                                  PlanCheckboxRow(
                                    planName:
                                        "${_formatCurrency(double.parse("${plans?[3].price}"))}/Year",
                                    isSelected: selectedPlanIndex == 3,
                                    onChanged: (_) => onCheckedChanged(3),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PlanCheckboxRow(
                                    planName:
                                        "${plans?[4].planName}${_formatCurrency(double.parse("${plans?[4].price}"))}/Mo",
                                    isSelected: selectedPlanIndex == 4,
                                    onChanged: (_) => onCheckedChanged(4),
                                  ),
                                  PlanCheckboxRow(
                                    planName:
                                        "${_formatCurrency(double.parse("${plans?[5].price}"))}/Year",
                                    isSelected: selectedPlanIndex == 5,
                                    onChanged: (_) => onCheckedChanged(5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                      showPaymentDialog(context);
                      //subscribeDialog(context);
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

  void showPaymentDialog(
    BuildContext context,
    //Plan plan
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: PaymentDialogContent(
            //plan: plan
            ),
      ),
    );
  }
}

class PaymentDialogContent extends StatefulWidget {
  // Plan plan;
  const PaymentDialogContent({
    super.key,
    // required this.plan
  });

  @override
  _PaymentDialogContentState createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<PaymentDialogContent> {
  final CardFieldInputDetails? _cardDetails = null;

  final CardEditController controller = CardEditController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleAddCard() async {
    final details = controller.details;

    if (details.complete) {
      try {
        // Ideally, get paymentIntent client secret from your backend.
        final String clientSecret = await fetchPaymentIntentFromBackend();

        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                name: 'Test User', // Get from input if needed
              ),
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment successful")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete card details")),
      );
    }
  }

  Future<String> fetchPaymentIntentFromBackend() async {
    // Replace this with real backend call
    // The backend should create a PaymentIntent and return clientSecret
    return 'pi_..._secret_...'; // Dummy - Replace with actual
  }

  void goToPaypalScreen() async {
    final Uri paypalLoginUrl = Uri.parse('https://www.paypal.com/signin');
    if (await canLaunchUrl(paypalLoginUrl)) {
      await launchUrl(paypalLoginUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch PayPal';
    }
  }

  @override
  Widget build(BuildContext context) {
    const InputBorder lightGreyBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1),
    );

    const InputDecoration inputDecoration = InputDecoration(
      border: lightGreyBorder,
      enabledBorder: lightGreyBorder,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
      labelText: '',
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF85C3FF), Color(0xFF62D0E0)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Add Card Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: goToPaypalScreen,
            icon: Icon(Icons.account_balance_wallet, color: Colors.white),
            label: Text('PayPal', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomText(content: "OR"),
                ),
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    content: "Add new card:",
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                CardField(
                  controller: controller,
                  decoration:
                      inputDecoration.copyWith(labelText: "Card Number"),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: inputDecoration.copyWith(
                    labelText: "Card holder name",
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 16,
                  children: [
                    infoBox("Ends on", "June 5, 2025"),
                    const SizedBox(width: 16),
                    infoBox("Amount", "\$15.42"),
                    const SizedBox(width: 16),
                    infoBox("Licenses", "1"),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: handleAddCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: CustomText(content: "Add Card", color: white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoBox(String title, String value) {
    return Column(
      children: [
        CustomText(content: title, color: Colors.grey, fontSize: 18),
        CustomText(content: value, fontWeight: FontWeight.bold, fontSize: 18),
      ],
    );
  }
}
