
import 'package:busskit_salesexecutive/ui/utills/extentions/string_extention.dart';
import 'package:busskit_salesexecutive/ui/utills/nk_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
            // 1. Invisible full-screen detector to close popup when clicking outside
            Positioned.fill(
              child: GestureDetector(
                onTap: _closePopup,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            // 2. The Anchored Popup
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // Offset: Moves the popup to the right (-10) and down (30) relative to icon
              offset: const Offset(-200, 30), // Adjust -200 to shift left/right
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300, // Fixed width for the popup
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _PaymentHistoryContent(orderId: widget.orderId),
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
    print('payment history button called');
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        icon: Icon(
          Icons.info_outline,
          size: widget.iconSize,
          color: Colors.blue,
        ),
        onPressed: _togglePopup,
      ),
    );
  }
}

// Separate widget for the content to handle FutureBuilder cleanly
class _PaymentHistoryContent extends StatelessWidget {
  final String orderId;

  const _PaymentHistoryContent({required this.orderId});

  Future<List<dynamic>> _fetchData() async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://test.thrivewoo.com/get_previous_partial_payment',
        data: {"order_id": orderId, "companyId": 1},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data is List ? response.data : (response.data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return []; // Handle error gracefully or rethrow
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
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No history found"),
          );
        }

        final data = snapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: Colors.grey.shade200,
              child: const Text("Payment history",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            // Table Header
             Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(child: Text("Date", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                    Expanded(child: Text("Amount", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                    Expanded(child: Text("Mode", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  ],
                ),
              ),
            const Divider(height: 1),
            // List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: data.length,
                // Inside _PaymentHistoryContent -> ListView.builder

itemBuilder: (ctx, index) {
  final item = data[index];
  
  // 1. Map the specific keys from your Postman response
  final date = item['old_received_amount_date'] ?? '-';
  final amount = item['old_received_amount'] ?? '0';
  
  
  final paymentType = item['old_payment_type'] == "0" ? "Cash" : "Card"; 

  
  // final displayDate = date.toString().contains('T') 
  //     ? date.toString().split('T')[0] 
  //     : date.toString();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        // Display mapped data
        Expanded(
          child: Text(NKDateUtils.commonDayFormat2(DateTime.parse(date)), style: const TextStyle(fontSize: 12))
        ),
        Expanded(
          child: Text(formatAmount(amount), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))
        ),
        Expanded(
          child: Text(paymentType, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))
        ),
      ],
    ),
  );
},
                
              ),
            ),
             const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}