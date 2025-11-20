// class OnlinePaymentVerifyResponse {
//   final bool paid;
//   final String paymentStatus;
//   final String? paymentIntentId;
//   final Map<String, dynamic> metadata;

//   OnlinePaymentVerifyResponse({
//     required this.paid,
//     required this.paymentStatus,
//     this.paymentIntentId,
//     required this.metadata,
//   });

//   factory OnlinePaymentVerifyResponse.fromJson(Map<String, dynamic> json) {
//     return OnlinePaymentVerifyResponse(
//       paid: json['paid'] as bool? ?? false,
//       paymentStatus: json['payment_status'] as String? ?? 'unknown',
//       paymentIntentId: json['paymentIntentId'] as String?,
//       metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
//     );
//   }
// }

class OnlinePaymentVerifyResponse {
  final bool paid;
  final String paymentStatus;
  final String? paymentIntentId;
  final Map<String, dynamic> metadata;

  OnlinePaymentVerifyResponse({
    required this.paid,
    required this.paymentStatus,
    this.paymentIntentId,
    required this.metadata,
  });

  factory OnlinePaymentVerifyResponse.fromJson(Map<String, dynamic> json) {
    print("🔍 [MODEL] Parsing JSON: $json");
    print("🔍 [MODEL] JSON Keys: ${json.keys.toList()}");
    
    // Robust parsing for 'paid' field
    bool paidValue = false;
    final paidRaw = json['paid'];
    print("🔍 [MODEL] Raw 'paid' value: $paidRaw (type: ${paidRaw.runtimeType})");
    
    if (paidRaw is bool) {
      paidValue = paidRaw;
    } else if (paidRaw is String) {
      paidValue = paidRaw.toLowerCase() == 'true' || paidRaw == '1';
    } else if (paidRaw is int) {
      paidValue = paidRaw == 1;
    }
    
    print("✅ [MODEL] Parsed 'paid' as: $paidValue");
    
    // Robust parsing for 'payment_status' field
    final paymentStatusRaw = json['payment_status'] ?? json['paymentStatus'];
    print("🔍 [MODEL] Raw 'payment_status' value: $paymentStatusRaw (type: ${paymentStatusRaw.runtimeType})");
    
    final paymentStatusValue = paymentStatusRaw?.toString().toLowerCase() ?? 'unknown';
    print("✅ [MODEL] Parsed 'payment_status' as: $paymentStatusValue");
    
    // Parse paymentIntentId
    final paymentIntentIdValue = json['paymentIntentId']?.toString();
    print("✅ [MODEL] Parsed 'paymentIntentId' as: $paymentIntentIdValue");
    
    // Parse metadata
    Map<String, dynamic> metadataValue = {};
    if (json['metadata'] != null) {
      if (json['metadata'] is Map) {
        metadataValue = Map<String, dynamic>.from(json['metadata']);
      }
    }
    print("✅ [MODEL] Parsed 'metadata' keys: ${metadataValue.keys.toList()}");

    final result = OnlinePaymentVerifyResponse(
      paid: paidValue,
      paymentStatus: paymentStatusValue,
      paymentIntentId: paymentIntentIdValue,
      metadata: metadataValue,
    );
    
    print("✅ [MODEL] Final parsed object: $result");
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'paid': paid,
      'payment_status': paymentStatus,
      'paymentIntentId': paymentIntentId,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'OnlinePaymentVerifyResponse(paid: $paid, paymentStatus: $paymentStatus, paymentIntentId: $paymentIntentId, metadata: $metadata)';
  }
}
