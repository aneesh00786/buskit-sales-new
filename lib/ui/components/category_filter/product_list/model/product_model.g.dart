// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductApiResponseAdapter extends TypeAdapter<ProductApiResponse> {
  @override
  final int typeId = 12;

  @override
  ProductApiResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductApiResponse(
      statusCode: fields[0] as int,
      status: fields[1] as bool,
      message: fields[2] as String,
      data: (fields[3] as List).cast<ScidProductGroup>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductApiResponse obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.statusCode)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductApiResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScidProductGroupAdapter extends TypeAdapter<ScidProductGroup> {
  @override
  final int typeId = 13;

  @override
  ScidProductGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScidProductGroup(
      scid: fields[0] as String,
      products: (fields[1] as List).cast<ProductModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScidProductGroup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.scid)
      ..writeByte(1)
      ..write(obj.products);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScidProductGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 2;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as int?,
      productId: fields[1] as String?,
      brandname: fields[2] as String?,
      productName: fields[3] as String?,
      description: fields[4] as String?,
      reasonBySalesman: fields[5] as String?,
      imageUrl: fields[6] as String?,
      inclTax: fields[7] as String?,
      status: fields[8] as int?,
      scid: fields[9] as String?,
      catId: fields[10] as int?,
      companyId: fields[11] as int?,
      stock: fields[12] as String?,
      detail: (fields[13] as List?)?.cast<Detail>(),
      productCode: fields[14] as String?,
      catTax: fields[15] as num?,
      pName: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.brandname)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.reasonBySalesman)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.inclTax)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.scid)
      ..writeByte(10)
      ..write(obj.catId)
      ..writeByte(11)
      ..write(obj.companyId)
      ..writeByte(12)
      ..write(obj.stock)
      ..writeByte(13)
      ..write(obj.detail)
      ..writeByte(14)
      ..write(obj.productCode)
      ..writeByte(15)
      ..write(obj.catTax)
      ..writeByte(16)
      ..write(obj.pName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DetailAdapter extends TypeAdapter<Detail> {
  @override
  final int typeId = 0;

  @override
  Detail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Detail(
      id: fields[0] as int?,
      companyId: fields[1] as int?,
      productId: fields[2] as String?,
      variationId: fields[3] as String?,
      inNo: fields[4] as String?,
      barcode: fields[5] as String?,
      variationName: fields[6] as String?,
      unitType: fields[7] as String?,
      price: fields[8] as String?,
      sellPrice: fields[9] as String?,
      tax: fields[10] as num?,
      packtype: fields[11] as String?,
      pieces: fields[12] as num?,
      stock: fields[13] as num?,
      lowstock: fields[14] as num?,
      fullstock: fields[15] as num?,
      imageUrl: fields[16] as String?,
      status: fields[17] as int?,
      vStatus: fields[18] as int?,
      count: fields[21] as num,
      saleBy: fields[22] as String?,
      totalPrice: fields[23] as num?,
      sellingPrice: fields[24] as num?,
      packPrice: fields[25] as num?,
      sellingPackPrice: fields[26] as num?,
      inclTax: fields[27] as String?,
      initialQuantity: fields[28] as num?,
      unitTax: fields[29] as num?,
      pack: fields[30] as String?,
      discount: fields[31] as num?,
      totaltax: fields[32] as num?,
      productName: fields[33] as String?,
      maxDiscount: fields[34] as num?,
      promoDiscount: fields[35] as num?,
      customerDiscount: fields[36] as num?,
      initialCount: fields[37] as num?,
      bulkId: fields[38] as String?,
      bulkDiscount: fields[39] as num?,
      bulkTax: fields[40] as num?,
      bulkDiscountAmount: fields[41] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, Detail obj) {
    writer
      ..writeByte(40)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.variationId)
      ..writeByte(4)
      ..write(obj.inNo)
      ..writeByte(5)
      ..write(obj.barcode)
      ..writeByte(6)
      ..write(obj.variationName)
      ..writeByte(7)
      ..write(obj.unitType)
      ..writeByte(8)
      ..write(obj.price)
      ..writeByte(9)
      ..write(obj.sellPrice)
      ..writeByte(10)
      ..write(obj.tax)
      ..writeByte(11)
      ..write(obj.packtype)
      ..writeByte(12)
      ..write(obj.pieces)
      ..writeByte(13)
      ..write(obj.stock)
      ..writeByte(14)
      ..write(obj.lowstock)
      ..writeByte(15)
      ..write(obj.fullstock)
      ..writeByte(16)
      ..write(obj.imageUrl)
      ..writeByte(17)
      ..write(obj.status)
      ..writeByte(18)
      ..write(obj.vStatus)
      ..writeByte(21)
      ..write(obj.count)
      ..writeByte(22)
      ..write(obj.saleBy)
      ..writeByte(23)
      ..write(obj.totalPrice)
      ..writeByte(24)
      ..write(obj.sellingPrice)
      ..writeByte(25)
      ..write(obj.packPrice)
      ..writeByte(26)
      ..write(obj.sellingPackPrice)
      ..writeByte(27)
      ..write(obj.inclTax)
      ..writeByte(28)
      ..write(obj.initialQuantity)
      ..writeByte(29)
      ..write(obj.unitTax)
      ..writeByte(30)
      ..write(obj.pack)
      ..writeByte(31)
      ..write(obj.discount)
      ..writeByte(32)
      ..write(obj.totaltax)
      ..writeByte(33)
      ..write(obj.productName)
      ..writeByte(34)
      ..write(obj.maxDiscount)
      ..writeByte(35)
      ..write(obj.promoDiscount)
      ..writeByte(36)
      ..write(obj.customerDiscount)
      ..writeByte(37)
      ..write(obj.initialCount)
      ..writeByte(38)
      ..write(obj.bulkId)
      ..writeByte(39)
      ..write(obj.bulkDiscount)
      ..writeByte(40)
      ..write(obj.bulkTax)
      ..writeByte(41)
      ..write(obj.bulkDiscountAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
