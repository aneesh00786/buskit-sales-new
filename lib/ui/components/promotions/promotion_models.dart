
class PromotionReponse {
  int? id;
  int? companyId;
  int? userId;
  String? title;
  String? description;
  String? promoType;
  String? promoCode;
  dynamic startDate;
  DateTime? endDate;
  String? applicableFor;
  String? minOrderValue;
  String? productScope;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic targetUsers;
  List<FreeItem>? freeItems;
  List<Product>? products;
  List<Deal>? deals;
  List<Category>? categories;
  List<Tier>? tiers;
  String? bundlePrice;
  List<BundleItem>? bundleItems;
  String? discountPercentage;
  int? saleDuration;
  int? offerDuration;
  String? startTime;
  String? endTime;
  String? daysOfWeek;
  String? seasonName;
  String? offerDetails;
  String? discountType;
  String? discountValue;
  String? maxDiscount;
  List<String>? brands;
  List<Product>? getProducts;

  PromotionReponse({
    this.id,
    this.companyId,
    this.userId,
    this.title,
    this.description,
    this.promoType,
    this.promoCode,
    this.startDate,
    this.endDate,
    this.applicableFor,
    this.minOrderValue,
    this.productScope,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.targetUsers,
    this.freeItems,
    this.products,
    this.deals,
    this.categories,
    this.tiers,
    this.bundlePrice,
    this.bundleItems,
    this.discountPercentage,
    this.saleDuration,
    this.offerDuration,
    this.startTime,
    this.endTime,
    this.daysOfWeek,
    this.seasonName,
    this.offerDetails,
    this.discountType,
    this.discountValue,
    this.maxDiscount,
    this.brands,
    this.getProducts,
  });

  factory PromotionReponse.fromJson(Map<String, dynamic> json) =>
      PromotionReponse(
        id: json["id"],
        companyId: json["company_id"],
        userId: json["user_id"],
        title: json["title"],
        description: json["description"],
        promoType: json["promo_type"],
        promoCode: json["promo_code"],
        startDate: json["start_date"],
        endDate: json["end_date"] == null
            ? null
            : DateTime.tryParse(json["end_date"]),
        applicableFor: json["applicable_for"],
        minOrderValue: json["min_order_value"],
        productScope: json["product_scope"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"]),
        targetUsers: json["target_users"],
        freeItems: json["freeItems"] == null
            ? []
            : List<FreeItem>.from(
                json["freeItems"].map((x) => FreeItem.fromJson(x))),
        products: json["products"] == null
            ? []
            : List<Product>.from(
                json["products"].map((x) => Product.fromJson(x))),
        deals: json["deals"] == null
            ? []
            : List<Deal>.from(json["deals"].map((x) => Deal.fromJson(x))),
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        tiers: json["tiers"] == null
            ? []
            : List<Tier>.from(json["tiers"].map((x) => Tier.fromJson(x))),
        bundlePrice: json["bundle_price"],
        bundleItems: json["bundle_items"] == null
            ? []
            : List<BundleItem>.from(
                json["bundle_items"].map((x) => BundleItem.fromJson(x))),
        discountPercentage: json["discount_percentage"],
        saleDuration: json["sale_duration"],
        offerDuration: json["offer_duration"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        daysOfWeek: json["days_of_week"],
        seasonName: json["season_name"],
        offerDetails: json["offer_details"],
        discountType: json["discount_type"],
        discountValue: json["discount_value"],
        maxDiscount: json["max_discount"],
        brands: json["brands"] == null
            ? []
            : List<String>.from(json["brands"].map((x) => x)),
        getProducts: json["getProducts"] == null
            ? []
            : List<Product>.from(
                json["getProducts"].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "company_id": companyId,
        "user_id": userId,
        "title": title,
        "description": description,
        "promo_type": promoType,
        "promo_code": promoCode,
        "start_date": startDate,
        "end_date": endDate?.toIso8601String(),
        "applicable_for": applicableFor,
        "min_order_value": minOrderValue,
        "product_scope": productScope,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "target_users": targetUsers,
        "freeItems": freeItems == null
            ? []
            : List<dynamic>.from(freeItems!.map((x) => x.toJson())),
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "deals": deals == null
            ? []
            : List<dynamic>.from(deals!.map((x) => x.toJson())),
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "tiers": tiers == null
            ? []
            : List<dynamic>.from(tiers!.map((x) => x.toJson())),
        "bundle_price": bundlePrice,
        "bundle_items": bundleItems == null
            ? []
            : List<dynamic>.from(bundleItems!.map((x) => x.toJson())),
        "discount_percentage": discountPercentage,
        "sale_duration": saleDuration,
        "offer_duration": offerDuration,
        "start_time": startTime,
        "end_time": endTime,
        "days_of_week": daysOfWeek,
        "season_name": seasonName,
        "offer_details": offerDetails,
        "discount_type": discountType,
        "discount_value": discountValue,
        "max_discount": maxDiscount,
        "brands":
            brands == null ? [] : List<dynamic>.from(brands!.map((x) => x)),
        "getProducts": getProducts == null
            ? []
            : List<dynamic>.from(getProducts!.map((x) => x.toJson())),
      };
}

class BundleItem {
  String? productId;
  String? variantId;
  String? unitType;
  int? quantity;

  BundleItem({
    this.productId,
    this.variantId,
    this.unitType,
    this.quantity,
  });

  factory BundleItem.fromJson(Map<String, dynamic> json) => BundleItem(
        productId: json["product_id"],
        variantId: json["variant_id"],
        unitType: json["unit_type"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "variant_id": variantId,
        "unit_type": unitType,
        "quantity": quantity,
      };
}

class Category {
  String? categoryId;
    List<String>? subIds;
    String? selected;

    Category({
        this.categoryId,
        this.subIds,
        this.selected,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json["category_id"],
        subIds: json["sub_ids"] == null ? [] : List<String>.from(json["sub_ids"]!.map((x) => x)),
        selected: json["selected"],
    );

    Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "sub_ids": subIds == null ? [] : List<dynamic>.from(subIds!.map((x) => x)),
        "selected": selected,
    };
}

class Deal {
  String? dealType;
  int? buyQuantity;
  String? buyQuantityType;
  dynamic buyProductId;
  dynamic buyVariantId;
  int? getQuantity;
  String? getQuantityType;
  String? getProductId;
  String? getVariantId;
  String? discountType;
  dynamic discountValue;

  Deal({
    this.dealType,
    this.buyQuantity,
    this.buyQuantityType,
    this.buyProductId,
    this.buyVariantId,
    this.getQuantity,
    this.getQuantityType,
    this.getProductId,
    this.getVariantId,
    this.discountType,
    this.discountValue,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
        dealType: json["deal_type"],
        buyQuantity: json["buy_quantity"],
        buyQuantityType: json["buy_quantity_type"],
        buyProductId: json["buy_product_id"],
        buyVariantId: json["buy_variant_id"],
        getQuantity: json["get_quantity"],
        getQuantityType: json["get_quantity_type"],
        getProductId: json["get_product_id"],
        getVariantId: json["get_variant_id"],
        discountType: json["discount_type"],
        discountValue: json["discount_value"],
      );

  Map<String, dynamic> toJson() => {
        "deal_type": dealType,
        "buy_quantity": buyQuantity,
        "buy_quantity_type": buyQuantityType,
        "buy_product_id": buyProductId,
        "buy_variant_id": buyVariantId,
        "get_quantity": getQuantity,
        "get_quantity_type": getQuantityType,
        "get_product_id": getProductId,
        "get_variant_id": getVariantId,
        "discount_type": discountType,
        "discount_value": discountValue,
      };
}

class FreeItem {
  String? itemType;
  String? giftName;
  int? quantity;
  String? quantityType;
  String? sampleDetails;

  FreeItem({
    this.itemType,
    this.giftName,
    this.quantity,
    this.quantityType,
    this.sampleDetails,
  });

  factory FreeItem.fromJson(Map<String, dynamic> json) => FreeItem(
        itemType: json["item_type"],
        giftName: json["gift_name"],
        quantity: json["quantity"],
        quantityType: json["quantity_type"],
        sampleDetails: json["sample_details"],
      );

  Map<String, dynamic> toJson() => {
        "item_type": itemType,
        "gift_name": giftName,
        "quantity": quantity,
        "quantity_type": quantityType,
        "sample_details": sampleDetails,
      };
}

class Product {
  String? id;
  String? type;
  String? productId;
  List<Variant>? variants;

  Product({
    this.id,
    this.type,
    this.productId,
    this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        type: json["type"],
        productId: json["product_id"],
        variants: json["variants"] == null
            ? []
            : List<Variant>.from(
                json["variants"]!.map((x) => Variant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "product_id": productId,
        "variants": variants == null
            ? []
            : List<dynamic>.from(variants!.map((x) => x.toJson())),
      };
}

class Variant {
  String? id;
  String? productId;
  String? inNo;
  String? barcode;
  String? variationName;
  String? unitType;
  String? price;
  String? sellPrice;
  String? tax;
  String? packtype;
  int? pieces;
  int? stock;
  int? lowstock;
  int? fullstock;
  String? imageUrl;
  int? status;
  int? vStatus;
  String? productName;
  String? inclTax;
  Variant({
    this.id,
    this.productId,
    this.inNo,
    this.barcode,
    this.variationName,
    this.unitType,
    this.price,
    this.sellPrice,
    this.tax,
    this.packtype,
    this.pieces,
    this.stock,
    this.lowstock,
    this.fullstock,
    this.imageUrl,
    this.status,
    this.vStatus,
    this.productName,
    this.inclTax
    
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        id: json["id"],
        productId: json["product_id"],
        inNo: json["in_no"],
        barcode: json["barcode"],
        variationName: json["variation_name"],
        unitType: json["unitType"],
        price: json["price"],
        sellPrice: json["sell_price"],
        tax: json["tax"],
        packtype: json["packtype"],
        pieces: json["pieces"],
        stock: json["stock"],
        lowstock: json["lowstock"],
        fullstock: json["fullstock"],
        imageUrl: json["image_url"],
        status: json["status"],
        vStatus: json["v_status"],
        productName: json["product_name"],
        inclTax: json["incl_tax"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "in_no": inNo,
        "barcode": barcode,
        "variation_name": variationName,
        "unitType": unitType,
        "price": price,
        "sell_price": sellPrice,
        "tax": tax,
        "packtype": packtype,
        "pieces": pieces,
        "stock": stock,
        "lowstock": lowstock,
        "fullstock": fullstock,
        "image_url": imageUrl,
        "status": status,
        "v_status": vStatus,
        "product_name": productName,
        "incl_tax": inclTax,
      };
}

class Tier {
  int? buyQuantity;
  String? buyQuantityType;
  String? discountValue;

  Tier({
    this.buyQuantity,
    this.buyQuantityType,
    this.discountValue,
  });

  factory Tier.fromJson(Map<String, dynamic> json) => Tier(
        buyQuantity: json["buy_quantity"],
        buyQuantityType: json["buy_quantity_type"],
        discountValue: json["discount_value"],
      );

  Map<String, dynamic> toJson() => {
        "buy_quantity": buyQuantity,
        "buy_quantity_type": buyQuantityType,
        "discount_value": discountValue,
      };
}
