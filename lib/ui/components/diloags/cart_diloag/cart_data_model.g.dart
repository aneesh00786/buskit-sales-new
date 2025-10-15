// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddToCartModelAdapter extends TypeAdapter<AddToCartModel> {
  @override
  final int typeId = 8;

  @override
  AddToCartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddToCartModel(
      customerId: fields[0] as String,
      salesmanId: fields[1] as String,
      total: fields[2] as String,
      cartId: fields[4] as String,
      cartList: (fields[5] as List).cast<SendCartData>(),
    );
  }

  @override
  void write(BinaryWriter writer, AddToCartModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.salesmanId)
      ..writeByte(2)
      ..write(obj.total)
      ..writeByte(4)
      ..write(obj.cartId)
      ..writeByte(5)
      ..write(obj.cartList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddToCartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SendCartDataAdapter extends TypeAdapter<SendCartData> {
  @override
  final int typeId = 9;

  @override
  SendCartData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SendCartData(
      productId: fields[0] as String,
      variantId: fields[1] as String,
      pack: fields[2] as String,
      packType: fields[3] as String,
      price: fields[4] as String,
      discount: fields[5] as num,
      quantity: fields[6] as int,
      variantName: fields[7] as String,
      maxDiscount: fields[8] as int?,
      isPromo: fields[9] as bool?,
      promoCode: fields[10] as String?,
      promoMsg: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SendCartData obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.variantId)
      ..writeByte(2)
      ..write(obj.pack)
      ..writeByte(3)
      ..write(obj.packType)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.discount)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.variantName)
      ..writeByte(8)
      ..write(obj.maxDiscount)
      ..writeByte(9)
      ..write(obj.isPromo)
      ..writeByte(10)
      ..write(obj.promoCode)
      ..writeByte(11)
      ..write(obj.promoMsg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendCartDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
