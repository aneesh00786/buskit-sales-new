// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 1;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      detail: fields[0] as Detail,
      productName: fields[1] as String,
      totalPrice: fields[2] as double,
      isPack: fields[3] as bool?,
      count: fields[4] as int?,
      customerId: fields[5] as String?,
      cartId: fields[6] as String?,
      draftId: fields[7] as String?,
      isChecked: fields[8] as bool?,
      draftTotal: fields[9] as num?,
      salesmanId: fields[10] as String?,
      boxType: fields[11] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.detail)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.totalPrice)
      ..writeByte(3)
      ..write(obj.isPack)
      ..writeByte(4)
      ..write(obj.count)
      ..writeByte(5)
      ..write(obj.customerId)
      ..writeByte(6)
      ..write(obj.cartId)
      ..writeByte(7)
      ..write(obj.draftId)
      ..writeByte(8)
      ..write(obj.isChecked)
      ..writeByte(9)
      ..write(obj.draftTotal)
      ..writeByte(10)
      ..write(obj.salesmanId)
      ..writeByte(11)
      ..write(obj.boxType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
