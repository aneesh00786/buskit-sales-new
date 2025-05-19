import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentDialogContent extends StatefulWidget {
  Plan plan;
  double totalAmount;
  int selectedQuantity;
  PaymentDialogContent(
      {super.key,
      required this.plan,
      required this.totalAmount,
      required this.selectedQuantity});

  @override
  _PaymentDialogContentState createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<PaymentDialogContent> {
  final CardEditController controller = CardEditController();
  final TextEditingController _nameController = TextEditingController();
  CardFieldInputDetails? cardDetails;
  @override
  void initState() {
    super.initState();
    controller.addListener(_onCardChanged);
  }

  void _onCardChanged() {
    setState(() {
      cardDetails = controller.details;
    });
    debugPrint("Card complete: ${cardDetails?.complete}");
    debugPrint("Brand: ${cardDetails?.brand}");
    debugPrint("Last4: ${cardDetails?.last4}");
  }

  @override
  void dispose() {
    controller.removeListener(_onCardChanged);
    controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

void handleAddCard() async {
  if (cardDetails?.complete == true && _nameController.text.trim().isNotEmpty) {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: _nameController.text.trim()),
          ),
        ),
      );
      final String cardName = _nameController.text.trim();
      final String cardToken = paymentMethod.id;
      final String customerEmail = 'test@example.com'; 
      final int adminId = 123; 
      final int checkedPlanId = widget.plan.id!;
      final String licenses = widget.selectedQuantity.toString();
      final String currencyCode = "USD";
      final double amount = widget.totalAmount;

      await ApiWorker().submitCardForm(
        cardName: cardName,
        customerEmail: customerEmail,
        cardToken: cardToken,
        adminId: adminId,
        checkedPlanId: checkedPlanId,
        licenses: licenses,
        currencyCode: currencyCode,
        amount: amount,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Trial started successfully")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Payment failed: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please complete all required details")),
    );
  }
}

  Future<String> fetchPaymentIntentFromBackend() async {
    return 'pi_..._secret_...';
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
                  decoration: inputDecoration.copyWith(
                    labelText: "Card Number",
                    hintText: "**** **** **** ****",
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                if (cardDetails != null && !cardDetails!.complete)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Card details are incomplete or invalid.",
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: inputDecoration.copyWith(
                    labelText: "Card holder name",
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 16,
                  children: [
                    infoBox("Ends on", _getEndDate()),
                    const SizedBox(width: 16),
                    infoBox("Amount", "${widget.totalAmount}"),
                    const SizedBox(width: 16),
                    infoBox("Licenses", "${widget.selectedQuantity}"),
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

  String _getEndDate() {
    final now = DateTime.now();
    DateTime endDate;
    final cycle = widget.plan.billingCycle?.trim().toLowerCase();
    if (cycle == 'monthly') {
      endDate = DateTime(now.year, now.month + 1, now.day);
    } else {
      endDate = DateTime(now.year + 1, now.month, now.day);
    }
    return "${_monthName(endDate.month)} ${endDate.day}, ${endDate.year}";
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
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
