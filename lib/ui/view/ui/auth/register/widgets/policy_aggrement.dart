import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyAgreementWidget extends StatefulWidget {
  final void Function(bool agreed) onPrivacyChanged;
  final void Function(bool agreed) onRefundChanged;

  const PolicyAgreementWidget({
    super.key,
    required this.onPrivacyChanged,
    required this.onRefundChanged,
  });

  @override
  _PolicyAgreementWidgetState createState() => _PolicyAgreementWidgetState();
}

class _PolicyAgreementWidgetState extends State<PolicyAgreementWidget> {
  bool _agreePrivacy = false;
  bool _agreeRefund = false;

  void _launchURLInDialog(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    final ValueNotifier<bool> isLoading = ValueNotifier(true);

    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => isLoading.value = true,
          onPageFinished: (_) => isLoading.value = false,
        ),
      )
      ..loadRequest(Uri.parse(url));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, loading, child) {
                    if (loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _updateAgreement(bool? newValue, bool isPrivacy) {
    setState(() {
      if (isPrivacy) {
        _agreePrivacy = newValue ?? false;
        widget.onPrivacyChanged(_agreePrivacy);
      } else {
        _agreeRefund = newValue ?? false;
        widget.onRefundChanged(_agreeRefund);
      }
    });
  }

  Widget _buildPolicyRow({
    required bool value,
    required Function(bool?) onChanged,
    required String policyText,
    required String url,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Agree to our '),
              GestureDetector(
                onTap: () => _launchURLInDialog(url),
                child: Text(
                  policyText,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
              const Text('.'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPolicyRow(
          value: _agreePrivacy,
          onChanged: (val) => _updateAgreement(val, true),
          policyText: 'Privacy Policy',
          url: '${ApiConstants.baseUrl}/Privacy_policy',
        ),
        _buildPolicyRow(
          value: _agreeRefund,
          onChanged: (val) => _updateAgreement(val, false),
          policyText: 'Refund Policy',
          url: '${ApiConstants.baseUrl}Cancellation_policy',
        ),
      ],
    );
  }
}