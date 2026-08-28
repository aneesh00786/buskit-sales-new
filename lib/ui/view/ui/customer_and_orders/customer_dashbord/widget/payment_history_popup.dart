import 'package:busskit_salesexecutive/api_handler/api_constants.dart';
import 'package:busskit_salesexecutive/ui/components/color/colors.dart';
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class PaymentHistoryButton extends StatefulWidget {
  final String orderId;
  final double iconSize;

  const PaymentHistoryButton({
    Key? key,
    required this.orderId,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  State<PaymentHistoryButton> createState() => _PaymentHistoryButtonState();
}

class _PaymentHistoryButtonState extends State<PaymentHistoryButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _togglePopup() {
    if (_isOpen) {
      _closePopup();
    } else {
      _showPopup();
    }
  }

  void _closePopup() {
    _overlayEntry?.remove();
    setState(() {
      _isOpen = false;
    });
  }

  void _showPopup() {
    setState(() {
      _isOpen = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closePopup,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-240, 30),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _PaymentHistoryContent(orderId: widget.orderId, onClose: _closePopup),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        icon: Icon(
          Icons.info_outline,
          size: widget.iconSize,
          color: primaryColor,
        ),
        onPressed: _togglePopup,
      ),
    );
  }
}

class _PaymentHistoryContent extends StatelessWidget {
  final String orderId;
  final VoidCallback onClose;

  const _PaymentHistoryContent({required this.orderId, required this.onClose});

  Future<List<dynamic>> _fetchData() async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.baseUrl1}/get_previous_partial_payment',
        data: {"order_id": orderId, "companyId": 1},
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data is List ? response.data : (response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                "No history found".tr,
                style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF2D3748)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Payment History".tr,
                        style: const TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              color: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date".tr,
                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Amount".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Mode".tr,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Poppins_Regular', fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),

            // List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: data.length,
                separatorBuilder: (context, idx) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (ctx, index) {
                  final item = data[index];
                  final date = item['old_received_amount_date'] ?? '-';
                  final amount = item['old_received_amount'] ?? '0';
                  final paymentType = item['old_payment_type'] == "0" ? "Cash" : "Card";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            NKDateUtils.commonDayFormat2(DateTime.parse(date)),
                            style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatAmount(amount),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            paymentType,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Poppins_Regular', fontSize: 11.5, fontWeight: FontWeight.w700, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
