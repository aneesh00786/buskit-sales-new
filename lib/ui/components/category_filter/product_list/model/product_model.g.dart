// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.detail);
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
      tax: fields[10] as String?,
      packtype: fields[11] as String?,
      pieces: fields[12] as int?,
      stock: fields[13] as num?,
      lowstock: fields[14] as num?,
      fullstock: fields[15] as num?,
      imageUrl: fields[16] as String?,
      status: fields[17] as int?,
      vStatus: fields[18] as int?,
      createdAt: fields[19] as String?,
      updatedAt: fields[20] as String?,
      count: fields[21] as double,
      saleBy: fields[22] as String?,
      totalPrice: fields[23] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Detail obj) {
    writer
      ..writeByte(24)
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
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.count)
      ..writeByte(22)
      ..write(obj.saleBy)
      ..writeByte(23)
      ..write(obj.totalPrice);
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
