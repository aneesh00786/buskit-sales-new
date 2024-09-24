class AddToCartModel {
  String customerId;
  String salesmanId;
  String total;
  String discount;
  String cartId;
  List<SendCartData> cartList;

  AddToCartModel({
    required this.customerId,
    required this.salesmanId,
    required this.cartList,
    required this.total,
    required this.discount,
    required this.cartId,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'salesman_id': salesmanId,
      'total': total,
      'discount': discount,
      'cart_id': cartId,
      'cart_list': cartList.map((e) => e.toJson()).toList(),
    };
  }
}

class SendCartData {
  String productId;
  String variantId;
  String pack;
  String price;
  String discount;
  int quantity;

  SendCartData({
    required this.productId,
    required this.variantId,
    required this.pack,
    required this.price,
    required this.discount,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'Varient': variantId, 
      'Pack': pack,
      'price': price,
      'discount': discount,
      'quantity': quantity,
    };
  }
}
