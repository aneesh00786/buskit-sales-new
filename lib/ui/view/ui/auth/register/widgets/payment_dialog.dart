// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/common/custom_fonts.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/login_ui/login_screen.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/model/register_plan_model.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/paypal_button_webview.dart';
import 'package:busskit_salesexecutive/ui/view/ui/auth/register/widgets/paypal_starting_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ApplePayButton(
                onPressed: () {},
              ),
              SizedBox(width: 16),
              PayPalButton(
                onPressed: () {})
              // SizedBox(
              //   height: 100,
              //   width: 200,
              //   child: PayPalWebViewScreen(
              //     adminId: 89 ?? 0,
              //     amount: widget.totalAmount,
              //     planId: widget.plan.id ?? 0,
              //     orderId: '',
              //   ),
              // )
            ],
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
}

class ApplePayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double height;
  final Color color;
  final String label;

  const ApplePayButton({
    super.key,
    required this.onPressed,
    this.height = 50,
    this.color = const Color.fromARGB(255, 240, 238, 238),
    this.label = 'Pay with Apple Pay',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          'assets/images/apple-pay-black-square-rounded-logo-19716.png',
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

class PayPalWebViewScreen extends StatefulWidget {
  final int adminId;
  final int planId;
  final double amount;
  final String orderId;

  const PayPalWebViewScreen({
    super.key,
    required this.adminId,
    required this.planId,
    required this.amount,
    required this.orderId,
  });

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  InAppWebViewController? webViewController;
  String? _htmlContent;
  late String _queryParams;
  @override
  void initState() {
    super.initState();
    _loadHtmlAndParams();
  }

  Future<void> _loadHtmlAndParams() async {
    final html = await rootBundle.loadString('assets/pay_with_paypal.html');
    _queryParams =
        '?adminId=${widget.adminId}&planId=${widget.planId}&amount=${widget.amount}&currency=USD';
    setState(() {
      _htmlContent = html;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: _htmlContent == null
            ? const Center(child: CircularProgressIndicator())
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InAppWebView(
                  initialData: InAppWebViewInitialData(
                    data: _htmlContent!,
                    baseUrl: WebUri("${ApiConstants.baseUrl}$_queryParams"),
                    encoding: 'utf-8',
                    mimeType: 'text/html',
                  ),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    controller.addJavaScriptHandler(
                      handlerName: 'paymentSuccess',
                      callback: (args) async {
                        final data = args[0];
                        final orderId = widget.orderId;
                        final adminId =
                            int.tryParse(data['adminId'].toString()) ?? 0;
                        final planId =
                            int.tryParse(data['planId'].toString()) ?? 0;
                        final amount =
                            double.tryParse(data['amount'].toString()) ?? 0.0;
                        final currency = data['currency'] ?? 'USD';
                        final licenses = data['licenses'] ?? '1';
                        await ApiWorker().saveSubscription(
                          userId: adminId,
                          planId: planId,
                          orderId: orderId,
                          amount: amount,
                          licenses: licenses,
                          currency: currency,
                        );

                        if (!mounted) return;
                        Navigator.of(context).pop();
                        _showSuccessDialog(context);
                      },
                    );
                  },
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Lottie.asset(
                'assets/images/Animation - 1726906882515.json',
              ),
            ),
            SizedBox(height: 12),
            CustomText(
              content: "Success",
              fontSize: 18,
              color: Colors.green,
              fontWeight: FontWeight.w800,
            ),
            SizedBox(height: 12),
            CustomText(
              content:
                  "14-day trial started. Login credentials have been sent to your email.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).pop();
                  await Future.delayed(Duration(milliseconds: 100));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Ok"),
              ),
            ),
          ],
        ),
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
