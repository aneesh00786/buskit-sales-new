class OnlinePaymentSession {
  final String sessionId;
  final String url;
  final int amountCents; // optional, for verification

  OnlinePaymentSession({
    required this.sessionId,
    required this.url,
    required this.amountCents,
  });

  factory OnlinePaymentSession.fromJson(Map<String, dynamic> json) {
    return OnlinePaymentSession(
      sessionId: json['sessionId'] as String,
      url: json['url'] as String,
      amountCents: json['amountCents'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'url': url,
      'amountCents': amountCents,
    };
  }

  @override
  String toString() => 'OnlinePaymentSession(sessionId: $sessionId, url: $url)';
}