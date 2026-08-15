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
      catId: fields[12] as int?,
      isPromo: fields[13] as bool?,
      promoCode: fields[14] as String?,
      promoMsg: fields[15] as String?,
      bundleItems: (fields[16] as List?)?.cast<BundleItem>(),
      title: fields[17] as String?,
      bundlePrice: fields[18] as String?,
      CustomerDiscount: fields[19] as double?,
      tieredDiscount: fields[20] as num?,
      totalDiscountAmount: fields[21] as double?,
      finalPrice: fields[22] as double?,
      tierStep: fields[23] as int?,
      catTax: fields[24] as double?,
      taxAmount: fields[25] as double?,
      totalTaxAmount: fields[26] as double?,
      flatDiscount: fields[27] as num?,
      bogoDiscount: fields[28] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(29)
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
      ..write(obj.boxType)
      ..writeByte(12)
      ..write(obj.catId)
      ..writeByte(13)
      ..write(obj.isPromo)
      ..writeByte(14)
      ..write(obj.promoCode)
      ..writeByte(15)
      ..write(obj.promoMsg)
      ..writeByte(16)
      ..write(obj.bundleItems)
      ..writeByte(17)
      ..write(obj.title)
      ..writeByte(18)
      ..write(obj.bundlePrice)
      ..writeByte(19)
      ..write(obj.CustomerDiscount)
      ..writeByte(20)
      ..write(obj.tieredDiscount)
      ..writeByte(21)
      ..write(obj.totalDiscountAmount)
      ..writeByte(22)
      ..write(obj.finalPrice)
      ..writeByte(23)
      ..write(obj.tierStep)
      ..writeByte(24)
      ..write(obj.catTax)
      ..writeByte(25)
      ..write(obj.taxAmount)
      ..writeByte(26)
      ..write(obj.totalTaxAmount)
      ..writeByte(27)
      ..write(obj.flatDiscount)
      ..writeByte(28)
      ..write(obj.bogoDiscount);
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
