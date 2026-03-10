
class SearchItem {
  final String invoiceId;
  final String orderId;
  final String productId;
  final String productName;
  final String variationId;
  final String variationName;
  final String unitType;

  SearchItem({
    required this.invoiceId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.variationId,
    required this.variationName,
    required this.unitType,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) => SearchItem(
        invoiceId: json['invoice_id'] ?? '',
        orderId: json['order_id'] ?? '',
        productId: json['product_id'] ?? '',
        productName: json['product_name'] ?? '',
        variationId: json['variation_id'] ?? '',
        variationName: json['variation_name'] ?? '',
        unitType: json['unitType'] ?? '',
      );
}