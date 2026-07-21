class PaymentLinkResponse {
  final bool? status;
  final String? token;
  final String? url;
  final String? message;

  PaymentLinkResponse({
    this.status,
    this.token,
    this.url,
    this.message,
  });

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) {
    return PaymentLinkResponse(
      status: json['status'],
      token: json['token'],
      url: json['url'],
      message: json['message'],
    );
  }
}