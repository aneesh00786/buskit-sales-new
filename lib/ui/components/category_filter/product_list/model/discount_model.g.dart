part of 'discount_model.dart';

class CustomerDiscountModelAdapter extends TypeAdapter<CustomerDiscountModel> {
  @override
  final int typeId = 10;

  @override
  CustomerDiscountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerDiscountModel(
      customerId: fields[0] as String?,
      discounts: (fields[1] as List?)?.cast<DiscountModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomerDiscountModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.discounts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerDiscountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiscountModelAdapter extends TypeAdapter<DiscountModel> {
  @override
  final int typeId = 11;

  @override
  DiscountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscountModel(
      categoriesId: fields[0] as String?,
      value: fields[1] as String?,
      discount: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DiscountModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.categoriesId)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.discount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
