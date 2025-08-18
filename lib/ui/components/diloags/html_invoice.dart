
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/components/common_size/nk_spacing.dart';
import 'package:busskit_salesexecutive/ui/theme/close_button.dart';
import 'package:busskit_salesexecutive/database/session/sessionhelper.dart';
import 'package:busskit_salesexecutive/ui/theme/custom_toast_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

class InvoicePreview extends StatefulWidget {
  final String orderId;

  const InvoicePreview({super.key, required this.orderId});

  @override
  _InvoicePreviewState createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends State<InvoicePreview> {
  String htmlContent = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInvoice();
  }

  Future<void> loadInvoice() async {
    final request = {
      'order_id': widget.orderId,
      'companyId': SessionHelper.loginSavedData?.company_id.toString() ?? '0',
    };
    log("request $request");
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}preview-invoice');
      final response = await http.post(
        url,
        body: request,
      );

      log("Status code: ${response.statusCode}");
      log("Response body [preview-invoice]: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          htmlContent = response.body;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load invoice: ${response.statusCode}');
      }
    } catch (e) {
      log("Error: $e");
      setState(() {
        htmlContent = "<h2>Error loading invoice</h2>";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      color: white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  height: 50,
                  child: Row(
                    children: [
                      nkSmallSizeBox(),
                      GestureDetector(
                        onTap: () async {
                          var response =
                              await ApiWorker().sendInvoice(widget.orderId);

                          showCustomToastDisplay(
                              context,
                              response.statusCode == 200
                                  ? "Invoice sent successfully"
                                  : "Invoice sending Unsuccessful!",
                              response.statusCode == 200 ? Colors.green : red,
                              response.statusCode == 200
                                  ? Icons.check
                                  : Icons.close);
                        },
                        child: Container(
                          color: Colors.green,
                          width: 40,
                          child: const Center(
                            child: Icon(
                              Icons.outgoing_mail,
                              color: white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      nkSmallSizeBox(),
                      const Spacer(),
                      dialogCloseButton1(context, red),
                    ],
                  ),
                ),
                Expanded(
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(data: htmlContent),
                  ),
                ),
              ],
            ),
    );
  }

  String sanitizeHtml(String html) {
    html =
        html.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    html = html.replaceAll(RegExp(r'<link[^>]*rel="stylesheet"[^>]*>'), '');

    html = html.replaceAll(RegExp(r'<img[^>]+src="data:image[^"]+"[^>]*>'), '');

    return html;
  }
}
