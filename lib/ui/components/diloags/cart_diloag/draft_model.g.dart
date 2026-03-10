part of 'draft_model.dart';

class DraftAdapter extends TypeAdapter<Draft> {
  @override
  final int typeId = 7;

  @override
  Draft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Draft(
      customerId: fields[0] as String,
      items: (fields[1] as List).cast<CartItem>(),
      cartId: fields[2] as String,
      draftId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Draft obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.cartId)
      ..writeByte(3)
      ..write(obj.draftId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
