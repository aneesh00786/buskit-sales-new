// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:developer';
import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/api_handler/api_worker.dart';
import 'package:busskit_salesexecutive/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart';
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
  bool isSendingMail = false;

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
      // log("Response body [preview-invoice]: ${response.body}");

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
      insetPadding: EdgeInsets.all(20),
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
                          setState(() {
                            isSendingMail = true;
                          });
                          var response =
                              await ApiWorker().sendInvoice(widget.orderId);
                          setState(() {
                            isSendingMail = false;
                          });

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
                        child: !isSendingMail
                            ? Container(
                                color: Colors.green,
                                width: 40,
                                child: const Center(
                                  child: Icon(
                                    Icons.outgoing_mail,
                                    color: white,
                                    size: 30,
                                  ),
                                ),
                              )
                            : CircularProgressIndicator(color: Colors.green),
                      ),
                      nkSmallSizeBox(),
                      const Spacer(),
                      dialogCloseButton1(context, red),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: InAppWebView(
                      initialData: InAppWebViewInitialData(data: htmlContent),
                      initialSettings: InAppWebViewSettings(
                          scrollBarFadeDuration: 0,
                          scrollbarFadingEnabled: false,
                          verticalScrollbarThumbColor: Colors.blue,
                          horizontalScrollbarThumbColor: Colors.blue,
                          verticalScrollbarTrackColor: Colors.grey.shade300,
                          horizontalScrollbarTrackColor: Colors.grey.shade300,
                          scrollBarStyle:
                              ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY),
                    ),
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

void showInvoicePreviewOnline(BuildContext context, String orderId) async {
  bool isOnline = await ConnectivityService().isOnline();

  if (isOnline) {
    showDialog(
      context: context,
      builder: (context) {
        return InvoicePreview(
          orderId: orderId,
        );
      },
    );
  } else {
    showCustomToastDisplay(context, "You are Offline!", red, Icons.warning);
  }
}
