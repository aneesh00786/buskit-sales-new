// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:developer';

import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lottie/lottie.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  // ignore: library_private_types_in_public_api
  _PaymentDialogContentState createState() => _PaymentDialogContentState();
}

class _PaymentDialogContentState extends State<PaymentDialogContent> {
  final CardEditController controller = CardEditController();
  final TextEditingController _nameController = TextEditingController();
  CardFieldInputDetails? cardDetails;
  bool _isProcessing = false;

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
    if (cardDetails?.complete == true &&
        _nameController.text.trim().isNotEmpty) {
      setState(() => _isProcessing = true);
      try {
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(name: _nameController.text.trim()),
            ),
          ),
        );
        final prefs = await SharedPreferences.getInstance();
        final int? adminId = prefs.getInt('admin_id');
        final String cardName = _nameController.text.trim();
        final String cardToken = paymentMethod.id;
        final int checkedPlanId = widget.plan.id!;
        final String licenses = widget.selectedQuantity.toString();
        final String currencyCode = "USD";
        final double amount = widget.totalAmount;

        bool isSuccess = await ApiWorker().submitCardForm(
          cardName: cardName,
          cardToken: cardToken,
          adminId: adminId ?? 0,
          checkedPlanId: checkedPlanId,
          licenses: licenses,
          currencyCode: currencyCode,
          amount: amount,
        );
        cardAddedDialog(isSuccess);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Payment failed: $e")),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all required details")),
      );
    }
  }

  Future<dynamic> cardAddedDialog(bool isSuccess) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset(
                isSuccess
                    ? 'assets/images/Animation - 1726906882515.json'
                    : 'assets/images/Warning_animation.json',
              ),
            ),
            const SizedBox(height: 16),
            CustomText(
              content: isSuccess
                  ? "Trial started successfully."
                  : "Trial activation failed. Please try again.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> fetchPaymentIntentFromBackend() async {
    return 'pi_..._secret_...';
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
          PayPalButton(
            onPressed: () => startPayPalPaymentFlow(context),
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
                  decoration: inputDecoration,
                  numberHintText: "Enter Card Number",
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
                    infoBox("Amount", "${widget.totalAmount} USD"),
                    const SizedBox(width: 16),
                    infoBox("Licenses", "${widget.selectedQuantity}"),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isProcessing ? null : handleAddCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: CustomText(
                      content: _isProcessing ? "Processing..." : "Add Card",
                      color: white),
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

  void startPayPalPaymentFlow(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? adminId = prefs.getInt('admin_id');
      final orderId = await ApiWorker().createPayPalOrder(
        amount: widget.totalAmount.toString(),
        currency: "USD",
        adminId: adminId??0,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaypalSubscriptionPayment(
            sandboxMode: true,
            clientId:
                "AQClUH-2qmN7z-AKcULb_uy5Zze1GEWNeWTDAFLRsvL0QUcNdIYNXebyqashLoXTkKWaPDR04HPbQeZs",
            secretKey:
                "EHQqbzwTNz8r-t2fv83G7by1gmiigPZUUCJZ7mF8kuVwoil0dUR5IqUjw7bB5Io9DuKce4w60ObJAaCX",
            productName: 'Buskit Subscription',
            type: "DIGITAL",
            planName: widget.plan.planName??'',
            billingCycles: [
              {
                'tenure_type': 'REGULAR',
                'sequence': 1,
                "total_cycles": 12,
                'pricing_scheme': {
                  'fixed_price': {
                    'currency_code': "USD",
                    'value': widget.totalAmount,
                  }
                },
                'frequency': {
                  "interval_unit": "MONTH",
                  "interval_count": 1,
                }
              }
            ],
            paymentPreferences: const {
              "auto_bill_outstanding": true,
              "setup_fee_failure_action": "CONTINUE",
              "payment_failure_threshold": 3,
            },
            returnURL: '',
            cancelURL: '',
            onSuccess: (data) async {
              log("PayPal subscription success: $data");
              await ApiWorker().saveSubscription(
                userId: adminId??0,
                planId: widget.plan.id ?? 0,
                orderId: orderId??'',
                amount: double.tryParse(widget.totalAmount.toString()) ?? 0.0,
                licenses: widget.selectedQuantity.toString(),
                currency: "USD",
              );
              _showSuccessDialog(context);
            },
            onError: (error) {
              debugPrint("PayPal error: $error");
              _showErrorDialog(
                context,
              );
            },
            onCancel: () {
              debugPrint("PayPal cancelled");
              _showErrorDialog(
                context,
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset(
                'assets/images/Animation - 1726906882515.json',
              ),
            ),
            Text("Success"),
          ],
        ),
        content: Text(
            "14-day trial started. Login credentials have been sent to your email."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text("Go to Login"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/images/Warning_animation.json'),
            Text("Error"),
          ],
        ),
        content: Text('The trial has been Failed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}

class PayPalWebView extends StatefulWidget {
  final String orderID;

  const PayPalWebView({super.key, required this.orderID});

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final approvalUrl =
        'https://www.sandbox.paypal.com/checkoutnow?token=${widget.orderID}';

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // Optional: Print URL for debug
            debugPrint("Navigating to: $url");

            if (url.contains("yourdomain.com/success")) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            } else if (url.contains("yourdomain.com/cancel")) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pay with PayPal")),
      body: WebViewWidget(controller: controller),
    );
  }
}

class PayPalButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double height;
  final Color color;
  final String label;

  const PayPalButton({
    super.key,
    required this.onPressed,
    this.height = 50,
    this.color = const Color(0xFFFFCC00),
    this.label = 'Pay with PayPal',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          'assets/images/2-2-paypal-logo-transparent-png.png',
          height: height * 0.6,
        ),
        label: CustomText(
          content: label,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
